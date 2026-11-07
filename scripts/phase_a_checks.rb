# frozen_string_literal: true

# Phase A data checks for the 0.31 upgrade (#228). READ-ONLY: every write raises.
# Run (from the repo root, with the oc project of the target environment selected):
#   oc exec -i -c rails "$(oc get pod -l app=rails -o name | head -1)" -- \
#     sh -c 'cat > /tmp/phase_a_checks.rb && bin/rails runner /tmp/phase_a_checks.rb' \
#     < scripts/phase_a_checks.rb | tee phase_a_checks.txt
# Prints no secrets: for ENV it only reports which map variables are set.

def check(title)
  puts "\n== #{title}"
  yield
rescue StandardError => e
  puts "  ERROR #{e.class}: #{e.message.lines.first&.strip}"
end

ActiveRecord::Base.while_preventing_writes do
  hosts = Decidim::Organization.pluck(:id, :host).to_h
  components = ->(name) { Decidim::Component.where(manifest_name: name) }
  per_tenant = ->(scope) { scope.map { hosts[_1.organization.id] }.tally }

  check('Tenants: id | host | secondary hosts | tenant_type') do
    Decidim::Organization.order(:id).each do |o|
      puts "  #{[o.id, o.host, o.secondary_hosts.join(','), o.try(:tenant_type)].join(' | ')}"
    end
  end

  check('A1 anonymous_codes: code groups per tenant') do
    pp Decidim::AnonymousCodes::Group.all.map { |g| hosts[g.organization.id] }.tally
  end

  check('A3 Initiative types not offline: org | id | title | signature_type | document handler | sms | extra fields') do
    Decidim::InitiativesType.where.not(signature_type: :offline).order(:decidim_organization_id).each do |t|
      puts "  #{[hosts[t.decidim_organization_id], t.id, t.title['de'], t.signature_type,
                 t.document_number_authorization_handler.inspect, "sms=#{t.validate_sms_code_on_votes}",
                 "extra_fields=#{t.collect_user_extra_fields}"].join(' | ')}"
    end
  end

  check('A4 navigation_maps blueprints / reporting_proposals components per tenant') do
    pp navigation_maps: (Decidim::NavigationMaps::Blueprint.all.map { |b| hosts[b.decidim_organization_id] }.tally rescue 'n/a'),
       reporting_proposals: per_tenant.(components.('reporting_proposals'))
  end

  check('C2 User groups per tenant (verified / total)') do
    groups = Decidim::UserGroup.all
    pp groups.group_by { hosts[_1.decidim_organization_id] }
             .transform_values { |gs| "#{gs.count { _1.verified? }}/#{gs.size}" }
  end

  check('C4 Header snippets containing <script: id | host') do
    pp Decidim::Organization.where('header_snippets ILIKE ?', '%<script%').pluck(:id, :host)
  end

  check('C5 Deprecated: sortitions components | collaborative drafts | meeting polls per tenant') do
    pp sortitions: components.('sortitions').map { [hosts[_1.organization.id], _1.id, _1.published?] },
       collaborative_drafts: Decidim::Proposals::CollaborativeDraft.find_each.map { hosts[_1.organization.id] }.tally,
       meeting_polls: Decidim::Meetings::Poll.find_each.map { hosts[_1.meeting.organization.id] }.tally
  end

  check('Maps: tenants with HERE in map_config; map ENV variables that are set (names only)') do
    pp Decidim::Organization.pluck(:host, :map_config).select { |_, c| c.to_s.downcase.include?('here') }
    pp ENV.keys.grep(/MAPS|HERE/i).sort
  end

  check('Delayed jobs: pending | failed | cron (job class, schedule)') do
    pp pending: Delayed::Job.where(failed_at: nil, cron: nil).count,
       failed: Delayed::Job.where.not(failed_at: nil).count,
       cron: Delayed::Job.where.not(cron: nil).pluck(:cron, :handler).map { |c, h| [h[/job_class: (\S+)/, 1], c] }
  end

  check('Freeze baseline: host | scopes | areas | process types | assembly types; categories total') do
    Decidim::Organization.order(:id).each do |o|
      puts "  #{[o.host, Decidim::Scope.where(organization: o).count, Decidim::Area.where(organization: o).count,
                 Decidim::ParticipatoryProcessType.where(organization: o).count,
                 Decidim::AssembliesType.where(organization: o).count].join(' | ')}"
    end
    puts "  categories: #{Decidim::Category.count}"
  end
end
