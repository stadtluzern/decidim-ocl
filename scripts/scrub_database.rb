#!/usr/bin/env -S bundle exec rails runner
# frozen_string_literal: true

# rubocop:disable Rails/SquishedSQLHeredocs, Metrics/BlockLength, Style/HashEachMethods -- multi-line SQL/PL/pgSQL; rows are arrays

# Scrubs a COPY of the decidim.swiss database (e.g. a PROD dump restored into a throwaway Postgres)
# so it can be used on DEV for the upgrade rehearsal (#228): secrets, personal data and participant
# content are replaced; ids, relations, structure and admin-authored content (spaces, components,
# categories, scopes, areas, taxonomies, static pages) stay, so migrations and the taxonomy import
# behave as on PROD.
#
# NEVER run this against PROD, INT or DEV directly. Flow (see upgrade_steps.html phase A):
#   docker run -d --rm --name scrub -e POSTGRES_PASSWORD=scrub -p 55433:5432 postgis/postgis:14-3.3-alpine
#   gunzip -c dumps/stlu-prod-<date>.sql.gz | PGPASSWORD=scrub psql -q -h localhost -p 55433 -U postgres postgres
#   RAILS_DB_HOST=localhost RAILS_DB_PORT=55433 RAILS_DB_USERNAME=postgres RAILS_DB_PASSWORD=scrub \
#     RAILS_DB_NAME=postgres SCRUB_CONFIRM=postgres [SCRUB_TEST_PASSWORD=…] \
#     scripts/scrub_database.rb   # from the repo root; same as: bin/rails runner scripts/scrub_database.rb
#   PGPASSWORD=scrub pg_dump -cOx -h localhost -p 55433 -U postgres postgres \
#     | gzip > dumps/stlu-prod-<date>-scrubbed.sql.gz
#   docker stop scrub   # the unscrubbed copy is gone with the container
#
# Works with plain SQL only, so it runs with the 0.31 code against a 0.29 dump (and vice versa).
# Allowlist: every string/text/json/inet column of every table must be classified below (or match
# KEEP_NAMES). An unclassified column aborts the run before anything is changed, so new tables or
# columns (module updates) cannot slip through.
#
# SCRUB_TEST_PASSWORD (optional): sets this password for all org admins and system admins, so the
# team can log in on DEV. Their placeholder emails are printed at the end. Everyone else can't log in.

TEXT_TYPES = %i[string text jsonb json inet citext].freeze

# Structural columns that never hold personal data: class names, identifiers of manifests, enums.
KEEP_NAMES = /\A(\w+_type|manifest_name|locale|slug|state|status|role|reference|question_type|section_type|
                scope_name|\w*color|content_type|service_name|checksum|variation_digest|event|event_class|
                event_name|action|visibility|item_type|key|token_for_type)\z/x

# Admin-authored, public structure: kept as is.
KEEP_TABLES = %w[
  ar_internal_metadata schema_migrations data_migrations
  decidim_accountability_milestones decidim_accountability_results decidim_accountability_statuses
  decidim_accountability_timeline_entries decidim_area_types decidim_areas decidim_assemblies
  decidim_assemblies_types decidim_attachment_collections decidim_budgets_budgets decidim_budgets_projects
  decidim_categories decidim_collaborative_texts_documents decidim_components decidim_conferences
  decidim_conferences_media_links decidim_conferences_partners decidim_conferences_registration_types
  decidim_content_block_attachments decidim_content_blocks decidim_contextual_help_sections
  decidim_elections_elections decidim_elections_questions decidim_elections_response_options
  decidim_forms_answer_options decidim_forms_display_conditions decidim_forms_question_matrix_rows
  decidim_forms_questionnaires decidim_forms_questions decidim_forms_response_options
  decidim_gamification_badge_scores decidim_hashtags decidim_initiatives_settings decidim_initiatives_types
  decidim_meetings_agenda_items decidim_meetings_agendas decidim_meetings_answer_options
  decidim_meetings_questions decidim_meetings_response_options decidim_meetings_services decidim_metrics
  decidim_navbar_links_navbar_links decidim_navigation_maps_blueprint_areas decidim_navigation_maps_blueprints
  decidim_newsletters decidim_pages_pages decidim_participatory_documents_annotations
  decidim_participatory_documents_documents decidim_participatory_documents_sections
  decidim_participatory_process_groups decidim_participatory_process_steps decidim_participatory_process_types
  decidim_participatory_processes decidim_participatory_space_links decidim_participatory_space_private_users
  decidim_plans_sections decidim_plans_tags decidim_proposals_participatory_texts decidim_proposals_proposal_states
  decidim_reminder_records decidim_resource_links decidim_resource_permissions decidim_scope_types decidim_scopes
  decidim_short_links decidim_static_page_topics decidim_static_pages decidim_surveys_surveys decidim_taxonomies
  decidim_taxonomy_filters decidim_templates_templates decidim_term_customizer_translation_sets
  decidim_term_customizer_translations decidim_awesome_config decidim_awesome_config_constraints
  decidim_awesome_editor_images decidim_awesome_follow_up_questionnaire_statuses decidim_awesome_authorization_groups
  redirect_rules request_environment_rules active_storage_attachments active_storage_variant_records
].freeze

# Whole table content is personal, tokens or history and not needed for the rehearsal.
TRUNCATE_TABLES = %w[
  delayed_jobs decidim_notifications decidim_private_exports oauth_access_grants oauth_access_tokens
  active_hashcash_stamps decidim_api_jwt_denylists decidim_messaging_messages decidim_messaging_receipts
  decidim_messaging_participations decidim_messaging_conversations
].freeze

# Actions: :lorem = text of the same length; :json = every string value in the JSON replaced (keys and
# structure kept); :null = NULL ('' / {} / [] where NOT NULL); :pseudo = salted md5 (unique values stay
# unique, not reversible); :log_json = JSON scrubbed except structural keys (*_type, *_id, manifest_name, …);
# :at_json = JSON scrubbed except *_at timestamps (keeps e.g. user group verified_at).

COLUMNS = {
  'active_storage_blobs' => { filename: :filename, metadata: :keep },
  'decidim_action_logs' => { extra: :log_json },
  'decidim_amendments' => {},
  'decidim_anonymous_codes_groups' => { title: :keep },
  'decidim_anonymous_codes_tokens' => { token: :pseudo },
  'decidim_assembly_members' => { full_name: :member_name, birthplace: :null, gender: :null, position: :keep,
                                  position_other: :lorem },
  'decidim_attachments' => { title: :json, description: :json, file: :keep, file_size: :keep, link: :url },
  'decidim_authorizations' => { name: :keep, unique_id: :pseudo, metadata: :null, verification_metadata: :null,
                                verification_attachment: :null },
  'decidim_authorization_transfer_records' => {},
  'decidim_awesome_authorization_members' => { email: :email },
  'decidim_awesome_follow_up_questionnaire_messages' => { body: :lorem, session_token: :pseudo },
  'decidim_awesome_follow_up_questionnaires' => { name: :keep, reply_to: :email, responder_email_field: :keep,
                                                  responder_name_field: :keep, settings: :keep },
  'decidim_awesome_proposal_extra_fields' => { private_body: :lorem, vote_weight_totals: :keep },
  'decidim_blogs_posts' => { title: :json, body: :json },
  'decidim_categorizations' => {},
  'decidim_coauthorships' => {},
  'decidim_collaborative_texts_suggestions' => { changeset: :json },
  'decidim_collaborative_texts_versions' => { body: :lorem },
  'decidim_comments_comment_votes' => {},
  'decidim_comments_comments' => { body: :json },
  'decidim_conference_speakers' => { full_name: :speaker_name, affiliation: :json, avatar: :null, personal_url: :null,
                                     position: :json, short_bio: :json, twitter_handle: :null },
  'decidim_debates_debates' => { title: :json, description: :json, instructions: :json, information_updates: :json,
                                 conclusions: :json, comments_layout: :keep, image: :keep },
  'decidim_elections_voters' => { data: :json },
  'decidim_elections_votes' => { voter_uid: :pseudo },
  'decidim_endorsements' => {},
  'decidim_follows' => {},
  'decidim_forms_answer_choices' => { body: :json, custom_body: :lorem },
  'decidim_forms_answers' => { body: :lorem, ip_hash: :null, session_token: :pseudo },
  'decidim_forms_response_choices' => { body: :json, custom_body: :lorem },
  'decidim_forms_responses' => { body: :lorem, ip_hash: :null, session_token: :pseudo },
  'decidim_guest_meeting_registration_registration_requests' => { email: :email, name: :name, form_data: :json,
                                                                  session_token: :pseudo, cancellation_token: :pseudo,
                                                                  confirmation_token: :pseudo },
  'decidim_identities' => { provider: :keep, uid: :pseudo },
  'decidim_impersonation_logs' => { reason: :lorem },
  'decidim_initiatives' => { title: :json, description: :json, answer: :json, answer_url: :url, hashtag: :null,
                             online_votes: :keep, offline_votes: :keep },
  'decidim_initiatives_votes' => { encrypted_metadata: :null, hash_id: :pseudo, timestamp: :keep },
  'decidim_likes' => {},
  'decidim_meetings_answer_choices' => { body: :json, custom_body: :lorem },
  'decidim_meetings_meetings' => { title: :json, description: :json, address: :lorem, location: :json,
                                   location_hints: :json, closing_report: :json, attending_organizations: :lorem,
                                   online_meeting_url: :url, registration_url: :url, video_url: :url, audio_url: :url,
                                   registration_email_custom_content: :keep, registration_terms: :keep,
                                   reminder_message_custom_content: :keep, salt: :keep },
  'decidim_meetings_questionnaires' => {},
  'decidim_meetings_registrations' => { code: :keep },
  'decidim_meetings_response_choices' => { body: :json, custom_body: :lorem },
  'decidim_moderations' => { reported_content: :lorem },
  'decidim_organizations' => {
    smtp_settings: :null, omniauth_settings: :null, aspsms_user_key: :null, aspsms_password: :null,
    **%i[admin_terms_of_service_body available_authorizations available_locales colors content_security_policy
         cta_button_path cta_button_text default_locale description external_domain_allowlist facebook_handler
         favicon file_upload_settings github_handler header_snippets highlighted_content_banner_action_subtitle
         highlighted_content_banner_action_title highlighted_content_banner_action_url highlighted_content_banner_image
         highlighted_content_banner_short_description highlighted_content_banner_title host
         id_documents_explanation_text id_documents_methods instagram_handler logo machine_translation_display_priority
         map_config name official_img_footer official_url omnipresent_banner_short_description
         omnipresent_banner_title omnipresent_banner_url reference_prefix secondary_hosts short_name tenant_type
         time_zone twitter_handler welcome_notification_body welcome_notification_subject
         youtube_handler].index_with(:keep)
  },
  'decidim_participatory_documents_evaluation_assignments' => {},
  'decidim_participatory_documents_suggestion_notes' => { body: :json },
  'decidim_participatory_documents_suggestions' => { body: :json, answer: :json },
  'decidim_participatory_documents_valuation_assignments' => {},
  'decidim_plans_plan_contents' => { body: :json },
  'decidim_plans_plans' => { title: :json, answer: :json, update_token: :null },
  'decidim_proposals_collaborative_drafts' => { title: :lorem, body: :lorem, address: :lorem },
  'decidim_proposals_evaluation_assignments' => {},
  'decidim_proposals_proposal_notes' => { body: :lorem },
  'decidim_proposals_proposals' => { title: :json, body: :json, address: :lorem, answer: :json, cost_report: :json,
                                     execution_period: :json, participatory_text_level: :keep },
  'decidim_proposals_valuation_assignments' => {},
  'decidim_reporting_proposals_category_valuators' => {},
  'decidim_reporting_proposals_taxonomy_evaluators' => {},
  'decidim_reports' => { reason: :keep, details: :lorem },
  'decidim_searchable_resources' => { content_a: :lorem, content_b: :lorem, content_c: :lorem, content_d: :lorem },
  'decidim_share_tokens' => { token: :pseudo },
  'decidim_sortitions_sortitions' => { title: :keep, additional_info: :json, cancel_reason: :json, witnesses: :json,
                                       candidate_proposals: :keep, selected_proposals: :keep },
  'decidim_system_admins' => { email: :system_email, encrypted_password: :no_password, reset_password_token: :null,
                               unlock_token: :null },
  'decidim_taxonomizations' => {},
  'decidim_term_customizer_constraints' => {},
  'decidim_user_blocks' => { justification: :lorem },
  'decidim_user_group_memberships' => {},
  'decidim_user_reports' => { reason: :keep, details: :lorem },
  'decidim_users' => {
    email: :email, unconfirmed_email: :null, name: :name, nickname: :nickname, about: :null, personal_url: :null,
    avatar: :null, officialized_as: :json, extended_data: :at_json, delete_reason: :null,
    encrypted_password: :no_password, previous_passwords: :null, api_key: :null, session_token: :null,
    confirmation_token: :null, invitation_token: :null, reset_password_token: :null, unlock_token: :null,
    newsletter_token: :null, current_sign_in_ip: :null, last_sign_in_ip: :null,
    type: :keep, roles: :keep, direct_message_types: :keep, notification_types: :keep, notification_settings: :keep,
    notifications_sending_frequency: :keep
  },
  'decidim_verifications_conflicts' => { unique_id: :pseudo },
  'decidim_verifications_csv_data' => { email: :email },
  'oauth_applications' => { name: :keep, organization_name: :keep, organization_url: :keep, organization_logo: :keep,
                            redirect_uri: :keep, scopes: :keep, type: :keep, uid: :pseudo, secret: :pseudo },
  'versions' => { object: :null, object_changes: :null, old_object_changes: :null, comment: :null, whodunnit: :keep }
}.freeze

conn = ActiveRecord::Base.connection
db = conn.select_value('select current_database()')
host = ActiveRecord::Base.connection_db_config.configuration_hash[:host]
abort "Refusing: set SCRUB_CONFIRM=#{db} to scrub database '#{db}' on '#{host}' (a COPY, never PROD/INT/DEV)." \
  unless ENV['SCRUB_CONFIRM'] == db

column_types = conn.select_rows(<<~SQL).group_by(&:first)
  select c.table_name, c.column_name, c.udt_name, c.is_nullable = 'YES', c.data_type = 'ARRAY'
  from information_schema.columns c join information_schema.tables t using (table_schema, table_name)
  where c.table_schema = 'public' and t.table_type = 'BASE TABLE'
SQL

text_udt = /\A_?(varchar|text|jsonb|json|inet|citext|bpchar)\z/
plan = {}
unclassified = []
column_types.each do |table, cols|
  next if TRUNCATE_TABLES.include?(table)

  config = COLUMNS[table]
  cols.select { |_, _, udt| udt.match?(text_udt) }.each do |_, col, udt, nullable, array|
    action = if KEEP_TABLES.include?(table) || col.match?(KEEP_NAMES) then :keep
             elsif config&.key?(col.to_sym) then config[col.to_sym]
             end
    if action.nil?
      unclassified << "#{table}.#{col}"
    elsif action != :keep
      (plan[table] ||= []) << [col, action, udt.delete_prefix('_'), nullable, array]
    end
  end
end
abort "Unclassified columns, classify them in #{__FILE__} first:\n  #{unclassified.join("\n  ")}" if unclassified.any?

salt = conn.quote(SecureRandom.hex(16))
expr = lambda do |col, action, udt, nullable, array|
  c = conn.quote_column_name(col)
  json = udt.start_with?('json')
  case action
  when :null
    if nullable then 'NULL'
    elsif array then "'{}'"
    elsif json then "'{}'::#{udt}"
    else
      "''"
    end
  when :lorem then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE pg_temp.lorem(length(#{c})) END"
  when :json then "pg_temp.scrub_json(#{c}::jsonb, NULL)::#{udt}"
  when :log_json then "pg_temp.scrub_json(#{c}::jsonb, '(_type|_id|manifest_name|^type|^class|locale|_at)$')::#{udt}"
  when :at_json then "pg_temp.scrub_json(#{c}::jsonb, '_at$')::#{udt}"
  when :pseudo then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE md5(#{c} || #{salt}) END"
  when :email then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE 'user-' || id || '@example.invalid' END"
  when :system_email then "'system-' || id || '@example.invalid'"
  when :name then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE 'User ' || id END"
  when :nickname then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE 'user_' || id END"
  when :member_name then "'Member ' || id"
  when :speaker_name then "'Speaker ' || id"
  when :url then "CASE WHEN #{c} IS NULL OR #{c} = '' THEN #{c} ELSE 'https://example.invalid/' || id END"
  when :filename then "'file-' || id || coalesce(substring(#{c} from '\\.[A-Za-z0-9]{1,8}$'), '')"
  when :no_password then "''"
  else
    raise "Unknown action #{action.inspect} for #{col}"
  end
end

ActiveRecord::Base.transaction do
  conn.execute(<<~SQL)
    CREATE FUNCTION pg_temp.lorem(n int) RETURNS text LANGUAGE sql IMMUTABLE AS
      $$ SELECT left(repeat('Lorem ipsum dolor sit amet. ', n / 28 + 1), n) $$;
    CREATE FUNCTION pg_temp.scrub_json(j jsonb, keep text, k text DEFAULT NULL) RETURNS jsonb LANGUAGE plpgsql IMMUTABLE AS $$
    BEGIN
      IF j IS NULL THEN RETURN NULL; END IF;
      CASE jsonb_typeof(j)
      WHEN 'object' THEN
        RETURN (SELECT coalesce(jsonb_object_agg(e.key, pg_temp.scrub_json(e.value, keep, e.key)), '{}'::jsonb)
                FROM jsonb_each(j) e);
      WHEN 'array' THEN
        RETURN (SELECT coalesce(jsonb_agg(pg_temp.scrub_json(a.value, keep, k) ORDER BY a.o), '[]'::jsonb)
                FROM jsonb_array_elements(j) WITH ORDINALITY a(value, o));
      WHEN 'string' THEN
        IF keep IS NOT NULL AND k IS NOT NULL AND k ~ keep THEN RETURN j; END IF;
        RETURN to_jsonb(pg_temp.lorem(length(j #>> '{}')));
      ELSE RETURN j;
      END CASE;
    END $$;
  SQL

  # One statement for tables referencing each other; no CASCADE, so an unexpected FK fails loudly.
  truncate = TRUNCATE_TABLES.select { column_types.key?(_1) }
  conn.execute("TRUNCATE #{truncate.map { conn.quote_table_name(_1) }.join(', ')}")
  puts "truncated #{truncate.join(', ')}"

  plan.each do |table, cols|
    sets = cols.map { |col, *rest| "#{conn.quote_column_name(col)} = #{expr.call(col, *rest)}" }
    n = conn.update("UPDATE #{conn.quote_table_name(table)} SET #{sets.join(', ')}")
    puts "scrubbed #{table} (#{n} rows): #{cols.map(&:first).join(', ')}"
  end

  if (pw = ENV.fetch('SCRUB_TEST_PASSWORD', '')).present?
    digest = conn.quote(Devise::Encryptor.digest(Decidim::User, pw))
    conn.update("UPDATE decidim_users SET encrypted_password = #{digest} WHERE admin AND deleted_at IS NULL")
    conn.update("UPDATE decidim_system_admins SET encrypted_password = #{digest}")
    puts "\nTest logins (password from SCRUB_TEST_PASSWORD):"
    conn.select_rows(<<~SQL).each { |org, email| puts "  org #{org}: #{email}" }
      select decidim_organization_id, email from decidim_users
      where admin and deleted_at is null and email <> '' order by 1, 2
    SQL
    conn.select_values('select email from decidim_system_admins order by 1').each { puts "  /system: #{_1}" }
  end

  # Verification: no real email address may remain in a scrubbed column; kept columns are only reported.
  email = %q('[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')
  leaks = []
  column_types.each do |table, cols|
    next if TRUNCATE_TABLES.include?(table)

    cols.select { |_, _, udt| udt.match?(text_udt) }.each do |_, col|
      c = conn.quote_column_name(col)
      n = conn.select_value(<<~SQL).to_i
        select count(*) from #{conn.quote_table_name(table)}
        where regexp_replace(#{c}::text, '[A-Za-z0-9._%+-]+@example\\.invalid', '', 'g') ~ #{email}
      SQL
      next if n.zero?

      scrubbed = plan[table]&.any? { |pc, *| pc == col }
      leaks << "#{table}.#{col}: #{n} rows" if scrubbed
      puts "note: kept column #{table}.#{col} contains email-like text in #{n} rows (admin content)" unless scrubbed
    end
  end
  raise "Email addresses left in scrubbed columns:\n  #{leaks.join("\n  ")}" if leaks.any?

  puts "\nDone: #{plan.size} tables scrubbed, #{TRUNCATE_TABLES.size} truncated, database '#{db}'."
end
# rubocop:enable Rails/SquishedSQLHeredocs, Metrics/BlockLength, Style/HashEachMethods
