#!/usr/bin/env ruby
# frozen_string_literal: true

# Runbook for the Decidim 0.29.7 -> 0.31.8 upgrade (decidim.swiss#228), phases B and C of upgrade_steps.html.
#
#   scripts/upgrade_runbook.rb <env> status         # show all steps with their state
#   scripts/upgrade_runbook.rb <env> run            # run from the first step that is not done, stop on failure
#   scripts/upgrade_runbook.rb <env> redo <step>    # run one step again (asks for confirmation on once-steps)
#   scripts/upgrade_runbook.rb <env> reset          # start a fresh state.yml (old one is kept as state-<time>.yml)
#
# <env> is int, prod or dev. State and logs live in tmp/runbook/<env>/ (state.yml, <step>.log).
# RUNBOOK_DRY=1 prints the commands instead of running them.
#
# Step kinds:
#   cmd    shell command, run locally with the helpers from the guide (pod, r, rr, db); optional `expect` regex on its output
#   manual something a human does (ArgoCD sync, smoke test); the script asks whether it is done
#   once   like cmd, but not idempotent (sends mails, imports data): never re-run without typing the step id

require 'yaml'
require 'time'
require 'fileutils'
require 'open3'

UPGRADE_TASKS = %w[
  decidim:upgrade:attachments_cleanup
  decidim_proposals:upgrade:set_categories
  decidim:upgrade:clean:clean_deleted_users
  decidim:upgrade:fix_nickname_casing
  decidim:upgrade:fix_action_log
  decidim:upgrade:clean:remove_private_exports_attachments
  decidim:upgrade:remove_deleted_users_left_data
  decidim:upgrade:fix_deleted_private_follows
  decidim:upgrade:decidim_update_valuators
  decidim:upgrade:decidim_action_log_valuation_assignment
  decidim:upgrade:decidim_paper_trail_valuation_assignment
  decidim:upgrade:clean:invalid_private_exports
  decidim_surveys:upgrade:fix_survey_permissions
].freeze

TASK_PATTERN = 'taxonomies:(make_plan|import_all_plans|reset_counters)|upgrade:(attachments_cleanup|' \
               'clean:clean_deleted_users|fix_nickname_casing|fix_action_log|clean:remove_private_exports_attachments|' \
               'remove_deleted_users_left_data|fix_deleted_private_follows|decidim_update_valuators|' \
               'decidim_action_log_valuation_assignment|decidim_paper_trail_valuation_assignment|' \
               'clean:invalid_private_exports|user_groups:remove )|proposals:upgrade:set_categories|' \
               'surveys:upgrade:fix_survey_permissions'

JOB_CLASS = 'h[/job_class: (\S+)/, 1]'

STEPS = [
  # Phase B
  { id: 'b-0-down', kind: :manual, desc: 'Deployment repo: 0-down on main, ArgoCD sync done, public URLs blocked' },
  { id: 'b-freeze-check', kind: :cmd, desc: 'Freeze baseline (compare with the phase A note)',
    cmd: %q(rr 'Decidim::Organization.order(:id).each { |o| puts [o.host, Decidim::Scope.where(organization: o).count, Decidim::Area.where(organization: o).count, Decidim::ParticipatoryProcessType.where(organization: o).count, Decidim::AssembliesType.where(organization: o).count].join(" | ") }; puts "categories: #{Decidim::Category.count}"') },
  { id: 'b-db-dump', kind: :cmd, desc: 'DB dump to dumps/',
    cmd: %q(mkdir -p dumps && f="dumps/stlu-$ENV-$(date +%F-%H%M).sql.gz" && db 'pg_dump -cOx "$POSTGRES_DB"' | gzip > "$f" && ls -lh "$f") },
  { id: 'b-db-restore-test', kind: :manual, desc: 'Dump restored into local PostGIS 14, row counts equal (see guide)' },
  { id: 'b-s3-backup', kind: :cmd, desc: 'S3 bucket mirrored to dumps/s3-<env> (incremental after the phase A sync)',
    cmd: %q(mkdir -p dumps && s3 sync --delete --only-show-errors "s3://$(bucket)" "/dumps/s3-$ENV") },
  { id: 'b-s3-backup-check', kind: :cmd, desc: 'Object count of the mirror equals the bucket',
    cmd: %q(remote=$(s3 ls --recursive --summarize "s3://$(bucket)" | awk '/Total Objects/ {print $3}'); mirror=$(find "dumps/s3-$ENV" -type f | wc -l); echo "remote=$remote mirror=$mirror"; [ -n "$remote" ] && [ "$remote" = "$mirror" ]) },
  { id: 'b-queue-drained', kind: :cmd, desc: 'No pending jobs left', expect: /\A0\Z/,
    cmd: %q(rr 'p Delayed::Job.where(failed_at: nil, cron: nil).count') },
  { id: 'b-failed-jobs-export', kind: :cmd, desc: 'Export failed jobs to dumps/',
    cmd: %q(mkdir -p dumps && rr 'puts Delayed::Job.where.not(failed_at: nil).to_json' > "dumps/failed-jobs-$ENV-$(date +%F).json" && ls -lh dumps/failed-jobs-$ENV-*.json) },
  { id: 'b-delete-cron-rows', kind: :cmd, desc: 'Delete cron rows (db:migrate recreates them)',
    cmd: %q(rr 'p Delayed::Job.where.not(cron: nil).delete_all') },

  # Phase C
  { id: 'c-1-deploy', kind: :manual, desc: 'Deployment repo: 1-deploy on main, ArgoCD sync done, rails pod up' },
  { id: 'c-image', kind: :cmd, desc: 'Rails runs the new image', expect: /git-#{ENV.fetch('SHA', '\h{40}')}\Z/,
    cmd: %q(oc get deploy rails -o jsonpath='{.spec.template.spec.containers[?(@.name=="rails")].image}') },
  { id: 'c-workers-stopped', kind: :cmd, desc: 'delayed-job and metrics-exporter scaled to 0', expect: /\A0 0\Z/,
    cmd: %q(oc get deploy delayed-job rails-metrics-exporter -o jsonpath='{.items[*].spec.replicas}') },
  { id: 'c-migration-logs', kind: :cmd, desc: 'migrate-database init container log',
    cmd: %q(oc logs "$(pod)" -c migrate-database --tail=50) },
  { id: 'c-data-migrate', kind: :cmd, desc: 'Data migrations', cmd: 'r data:migrate' },
  { id: 'c-data-migrations-check', kind: :cmd, desc: 'All 11 data migrations, including initiatives', expect: /20260208135004/,
    cmd: %q(rr 'puts ActiveRecord::Base.connection.select_values("select version from data_migrations order by version")') },
  { id: 'c-tasks-present', kind: :cmd, desc: 'All 17 one-time tasks exist', expect: /\A17\Z/,
    cmd: %(r -AT | grep -cE '#{TASK_PATTERN}') },
  { id: 'c-revoke-sms-present', kind: :cmd, desc: 'decidim:verifications:revoke:sms exists', expect: /\A1\Z/,
    cmd: %q(r -AT | grep -c 'decidim:verifications:revoke:sms') },
  { id: 'c-make-plan', kind: :cmd, desc: 'Generate taxonomy plans', cmd: 'r decidim:taxonomies:make_plan' },
  { id: 'c-plans-copy-out', kind: :cmd, desc: 'Copy generated plans to plans/generated',
    cmd: %q(rm -rf plans/generated && oc cp -c rails "$(pod)":/app-src/tmp/taxonomies plans/generated && ls plans/generated) },
  { id: 'c-plans-transform', kind: :manual, desc: 'Tenant plans applied to plans/final, diff contains only the agreed moves' },
  { id: 'c-plans-copy-in', kind: :cmd, desc: 'Copy plans/final into the pod',
    cmd: %q(oc exec -c rails "$(pod)" -- sh -c 'rm -f /app-src/tmp/taxonomies/*_plan.json' && for f in plans/final/*_plan.json; do oc cp -c rails "$f" "$(pod)":/app-src/tmp/taxonomies/ || exit 1; done) },
  { id: 'c-import-plans', kind: :once, desc: 'Import taxonomy plans', cmd: 'r decidim:taxonomies:import_all_plans' },
  { id: 'c-reset-counters', kind: :cmd, desc: 'Reset taxonomy counters', cmd: 'r decidim:taxonomies:reset_counters' },
  { id: 'c-results-copy-out', kind: :cmd, desc: 'Copy import results to plans/result, check for errors', expect: /\Aclean\Z/,
    cmd: %q(rm -rf plans/result && oc cp -c rails "$(pod)":/app-src/tmp/taxonomies plans/result && (grep -il error plans/result/*_result.json || echo clean)) },
  *UPGRADE_TASKS.map { |task| { id: "c-#{task.split(':').last.tr('_', '-')}", kind: :cmd, desc: task, cmd: "r #{task}" } },
  { id: 'c-smoke-test', kind: :manual, desc: 'Smoke test per tenant (login, filters, survey, initiative, upload, export)' },
  { id: 'c-go-no-go', kind: :manual, desc: 'GO decision taken (last point for rollback without side effects)' },
  { id: 'c-revoke-sms', kind: :once, desc: 'Revoke SMS authorizations', cmd: 'r decidim:verifications:revoke:sms' },
  { id: 'c-user-groups-remove', kind: :once, desc: 'Convert user groups (queues mails)', cmd: 'r decidim:upgrade:user_groups:remove' },
  { id: 'c-queued-jobs', kind: :cmd, desc: 'Queued jobs per queue',
    cmd: %q(rr 'pp Delayed::Job.where(failed_at: nil).group(:queue).count') },
  { id: 'c-2-up', kind: :manual, desc: 'Deployment repo: 2-up on main, ArgoCD sync done (POINT OF NO RETURN)' },
  { id: 'c-cron-rows', kind: :cmd, desc: 'Cron rows recreated, no ComputeMetricsJob', expect: /\A(?!.*ComputeMetricsJob).*SendNotificationMailDigestDailyJob/m,
    cmd: %(rr 'pp Delayed::Job.where.not(cron: nil).pluck(:cron, :handler).map { |c, h| [#{JOB_CLASS}, c] }') }
].freeze

# Same helpers as the shell setup in upgrade_steps.html.
PRELUDE = <<~'SH'
  set -o pipefail
  oc project -q "pitc-decidim-stlu-$ENV" >/dev/null || exit 1
  pod() { oc get pods -l app=rails -o name | cut -d/ -f2 | head -n1; }
  r()   { oc exec -c rails "$(pod)" -- bundle exec rails "$@"; }
  rr()  { r runner "$1"; }
  db()  { oc exec -i postgresql-0 -c postgresql -- bash -c "$1"; }
  bucket() { oc get secret ocp4-s3-storage -o jsonpath='{.data.bucket}' | base64 -d; }
  s3()  { local j; j=$(oc get secret ocp4-s3-storage -o json) || return 1
          docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -e AWS_DEFAULT_REGION=none -v "$PWD/dumps:/dumps" \
            -e AWS_ACCESS_KEY_ID="$(jq -r '.data["access-key-id"] | @base64d' <<<"$j")" \
            -e AWS_SECRET_ACCESS_KEY="$(jq -r '.data["secret-access-key"] | @base64d' <<<"$j")" \
            amazon/aws-cli --endpoint-url "$(jq -r '.data.endpoint | @base64d' <<<"$j")" s3 "$@"; }
SH

class Runbook
  # Commands use relative paths (dumps/, plans/), so always run from the repo root.
  Dir.chdir(File.expand_path('..', __dir__))

  def initialize(env)
    abort "unknown env #{env.inspect}, use int, prod or dev" unless %w[int prod dev].include?(env)
    @env = env
    @dir = File.expand_path("../tmp/runbook/#{env}", __dir__)
    @state_file = File.join(@dir, 'state.yml')
    FileUtils.mkdir_p(@dir)
    @state = File.exist?(@state_file) ? YAML.safe_load_file(@state_file) : new_state
  end

  def status
    STEPS.each do |step|
      s = steps[step[:id]] || {}
      extra = s['duration_s'] ? format('%6.1fs', s['duration_s']) : ''
      puts format('%-8s %-6s %-42s %s %s', s['status'] || 'pending', step[:kind], step[:id], extra, step[:desc])
    end
  end

  def run
    STEPS.each do |step|
      next if steps.dig(step[:id], 'status') == 'done'
      exit 1 unless execute(step)
    end
    puts "\nAll steps done for #{@env}."
  end

  def redo(id)
    step = STEPS.find { |s| s[:id] == id } or abort "unknown step #{id.inspect}, see `status`"
    if step[:kind] == :once && steps.dig(id, 'status') == 'done'
      print "#{id} is not idempotent and already ran. Type the step id to run it again: "
      abort 'aborted' unless $stdin.gets.to_s.strip == id
    end
    execute(step)
  end

  def reset
    FileUtils.mv(@state_file, File.join(@dir, "state-#{Time.now.strftime('%F-%H%M%S')}.yml")) if File.exist?(@state_file)
    @state = new_state
    save
    puts "Fresh #{@state_file}"
  end

  private

  def new_state = { 'env' => @env, 'created_at' => Time.now.iso8601, 'steps' => {} }
  def steps = @state['steps']
  def save = File.write(@state_file, @state.to_yaml)

  def execute(step)
    puts "\n== #{step[:id]}: #{step[:desc]}"
    record = { 'kind' => step[:kind].to_s, 'started_at' => Time.now.iso8601 }
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ok = step[:kind] == :manual ? confirm_manual : run_command(step, record)
    record.merge!('status' => ok ? 'done' : 'failed', 'finished_at' => Time.now.iso8601,
                  'duration_s' => (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).round(1))
    steps[step[:id]] = record
    save
    puts ok ? '   done' : "   FAILED, see #{record['log'] || 'above'}. Fix it, then `run` again."
    ok
  end

  def confirm_manual
    print '   Done? [y/N] '
    $stdin.gets.to_s.strip.casecmp?('y')
  end

  def run_command(step, record)
    log = File.join(@dir, "#{step[:id]}.log")
    record['log'] = log
    record['command'] = step[:cmd]
    if ENV['RUNBOOK_DRY']
      puts "   [dry] #{step[:cmd]}"
      return true
    end

    output = +''
    status = nil
    File.open(log, 'w') do |f|
      f.puts "# #{Time.now.iso8601} #{step[:cmd]}"
      Open3.popen2e({ 'ENV' => @env }, 'bash', '-c', "#{PRELUDE}\n#{step[:cmd]}") do |_stdin, out, wait|
        out.each_line { |line| print "   #{line}"; f.write(line); output << line }
        status = wait.value
      end
    end
    record['exit'] = status.exitstatus
    return false unless status.success?
    return true unless step[:expect]

    matched = step[:expect].match?(output.strip)
    puts "   output does not match #{step[:expect].inspect}" unless matched
    matched
  end
end

USAGE = File.read(__FILE__)[/^#   scripts.*?(?=\n#\n)/m].gsub(/^# ?/, '')
env, command, arg = ARGV
abort USAGE unless %w[status run redo reset].include?(command)
runbook = Runbook.new(env.to_s)
case command
when 'status' then runbook.status
when 'run' then runbook.run
when 'redo' then exit(runbook.redo(arg.to_s) ? 0 : 1)
when 'reset' then runbook.reset
end
