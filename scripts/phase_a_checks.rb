#!/usr/bin/env -S bundle exec rails runner
# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength -- one read-only transaction around all checks

# Phase A data checks for the 0.31 upgrade (#228).
#
# Run (repo root; namespace and pod explicit; script comes in via stdin, nothing is written in the pod):
#   set -o pipefail
#   NS=pitc-decidim-stlu-prod
#   oc get pods -n "$NS"                      # pick the rails pod by name
#   POD=<rails-pod-name>
#   oc exec -i -n "$NS" -c rails "$POD" -- \
#     env PGOPTIONS='-c default_transaction_read_only=on -c statement_timeout=30s' \
#     bin/rails runner - < scripts/phase_a_checks.rb > phase_a_checks.txt
#   echo "exit: $?"                           # 1 = at least one check failed, see "FAILED" lines
#
# Guarantees and limits:
# - PGOPTIONS makes every DB connection of this process read-only with a 30s statement timeout from
#   the moment it connects, so this also covers DB access by initializers during `rails runner` boot.
#   It only affects this one process, not the running app.
# - Inside the script, all queries additionally run in ONE transaction declared READ ONLY (works even
#   without PGOPTIONS), then rolled back. The database rejects INSERT/UPDATE/DELETE/DDL and nextval().
#   Rails' while_preventing_writes is kept as a third, weaker layer.
# - Not covered: non-DB side effects of booting (cache, files, network), same as any `rails runner`
#   on the pod. The checks themselves touch no files, cache or network.
# - If the connection fails with "unsupported startup parameter: options", a connection pooler sits in
#   between; run without the PGOPTIONS line and rely on the in-script read-only transaction.
# - Load: aggregates run in SQL (COUNT/GROUP BY); only small lookup sets (tenants, a few components,
#   ~10 cron rows) are loaded into Ruby.
# - Output: hosts, ids, counts, map provider names and ENV variable NAMES. No ENV values, no map_config
#   contents, no exception messages (only the exception class).

FAILED = Set.new

def check(title, &)
  puts "\n== #{title}"
  ActiveRecord::Base.transaction(requires_new: true, &) # savepoint: a failing check doesn't abort the rest
rescue StandardError => e
  FAILED << title
  puts "  FAILED (#{e.class})"
end

conn = ActiveRecord::Base.connection
ActiveRecord::Base.while_preventing_writes do
  ActiveRecord::Base.transaction do
    conn.execute('SET TRANSACTION READ ONLY')
    conn.execute("SET LOCAL statement_timeout = '30s'")

    hosts = Decidim::Organization.pluck(:id, :host).to_h
    # component id -> host, only for the given ids (a handful)
    component_hosts = lambda do |ids|
      Decidim::Component.where(id: ids).includes(:participatory_space)
                        .to_h { [_1.id, hosts[_1.participatory_space&.decidim_organization_id]] }
    end
    by_component_to_host = lambda do |counts|
      map = component_hosts.call(counts.keys)
      counts.each_with_object(Hash.new(0)) { |(cid, n), acc| acc[map[cid]] += n }
    end
    components_per_host = ->(name) { by_component_to_host.call(Decidim::Component.where(manifest_name: name).group(:id).count) }

    check('Tenants: id | host | secondary hosts | tenant_type') do
      Decidim::Organization.order(:id).pluck(:id, :host, :secondary_hosts, :tenant_type).each do |row|
        row[2] = Array(row[2]).join(',')
        puts "  #{row.join(' | ')}"
      end
    end

    check('A1 anonymous_codes: code groups per tenant') do
      pp Decidim::AnonymousCodes::Group.group(:decidim_organization_id).count.transform_keys(&hosts)
    end

    check('A3 Initiative types not offline: host | id | title | signature_type | document handler | sms | ' \
          'extra fields') do
      Decidim::InitiativesType.where.not(signature_type: :offline).order(:decidim_organization_id)
                              .pluck(:decidim_organization_id, :id, Arel.sql("title->>'de'"), :signature_type,
                                     :document_number_authorization_handler, :validate_sms_code_on_votes,
                                     :collect_user_extra_fields).each do |org, *rest|
        puts "  #{[hosts[org], *rest].join(' | ')}"
      end
    end

    check('A4 navigation_maps blueprints / reporting_proposals components per tenant') do
      pp navigation_maps: Decidim::NavigationMaps::Blueprint.group(:decidim_organization_id).count.transform_keys(&hosts),
         reporting_proposals: components_per_host.call('reporting_proposals')
    end

    check('C2 User groups per tenant: total / verified') do
      pp total: Decidim::UserGroup.group(:decidim_organization_id).count.transform_keys(&hosts),
         verified: Decidim::UserGroup.verified.group(:decidim_organization_id).count.transform_keys(&hosts)
    end

    check('C4 Header snippets containing <script: id | host') do
      pp Decidim::Organization.where('header_snippets ILIKE ?', '%<script%').pluck(:id, :host)
    end

    check('C5 Deprecated: sortitions components | collaborative drafts | meeting polls per tenant') do
      pp sortitions: components_per_host.call('sortitions'),
         collaborative_drafts: by_component_to_host.call(Decidim::Proposals::CollaborativeDraft.group(:decidim_component_id).count),
         meeting_polls: by_component_to_host.call(Decidim::Meetings::Poll.joins(:meeting)
                                                     .group('decidim_meetings_meetings.decidim_component_id').count)
    end

    check('Maps: host | map_config provider (only tenants with a provider set); map ENV variable names') do
      pp Decidim::Organization.where("map_config->>'provider' <> ''").pluck(:host, Arel.sql("map_config->>'provider'"))
      pp ENV.keys.grep(/MAPS|HERE/i).sort
    end

    check('Delayed jobs: pending | failed | cron (job class, schedule)') do
      pp pending: Delayed::Job.where(failed_at: nil, cron: nil).count,
         failed: Delayed::Job.where.not(failed_at: nil).count,
         cron: Delayed::Job.where.not(cron: nil)
                           .pluck(Arel.sql("substring(handler from 'job_class: (\\S+)')"), :cron)
    end

    check('Freeze baseline: host | scopes | areas | process types | assembly types; categories total') do
      counts = [Decidim::Scope, Decidim::Area, Decidim::ParticipatoryProcessType, Decidim::AssembliesType]
               .map { _1.group(:decidim_organization_id).count }
      hosts.sort.each { |id, host| puts "  #{[host, *counts.map { _1.fetch(id, 0) }].join(' | ')}" }
      puts "  categories: #{Decidim::Category.count}"
    end

    raise ActiveRecord::Rollback
  end
end

puts "\n#{FAILED.empty? ? 'All checks ran.' : "FAILED checks: #{FAILED.join('; ')}"}"
exit(FAILED.empty? ? 0 : 1)
# rubocop:enable Metrics/BlockLength
