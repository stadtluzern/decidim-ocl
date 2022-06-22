# frozen_string_literal: true

namespace :ocl do
  namespace :initiatives do
    desc 'Run all cleaners'
    task clean_all: %i[clean_notifications clean_comments clean_action_logs] do
      puts 'All tasks have run!'
    end

    desc 'Deletes all remaining initiative notifications'
    task clean_notifications: :environment do
      direct_notifications = Decidim::Notification.where(decidim_resource_type: 'Decidim::Initiative')
      puts "Removing #{direct_notifications.count} initiative notifications…"
      direct_notifications.delete_all
      puts 'Done!'

      badge_notifications = Decidim::Notification.where("extra->>'badge_name' = ?", 'initiatives')
      puts "Removing #{badge_notifications.count} badge notifications…"
      badge_notifications.delete_all
      puts 'Done!'

      assembly_plan_notifications =
        Decidim::Notification.where(
          id: Decidim::Notification
          .where(event_class: 'Decidim::ComponentPublishedEvent').select do |n|
            n.event_class_instance.instance_variable_get(:@resource)&.manifest_name == 'plans'
          end
          .pluck(:id)
        )
      puts "Removing #{assembly_plan_notifications.count} assembly plan publish notifications…"
      assembly_plan_notifications.delete_all
      puts 'Done!'
    end

    desc 'Deletes all remaining initiative comments'
    task clean_comments: :environment do
      comments = Decidim::Comments::Comment.where(decidim_root_commentable_type: 'Decidim::Initiative')
      puts "Removing #{comments.count} initiative comments…"
      comments.delete_all
      puts 'Done!'
    end

    desc 'Deletes all remaining initiative action logs'
    task clean_action_logs: :environment do
      resource_logs = Decidim::ActionLog.where(resource_type: 'Decidim::Initiative')
      puts "Removing #{resource_logs.count} initiative resource action logs…"
      resource_logs.delete_all
      puts 'Done!'

      participatory_space_logs = Decidim::ActionLog.where(participatory_space_type: 'Decidim::Initiative')
      puts "Removing #{participatory_space_logs.count} initiative participatory space action logs…"
      participatory_space_logs.delete_all
      puts 'Done!'
    end
  end
end
