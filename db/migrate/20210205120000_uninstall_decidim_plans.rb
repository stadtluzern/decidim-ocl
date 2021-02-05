# This migration reverses all migrations from decidim_plans

require "#{Rails.root}/db/migrate/20201001151633_enable_pg_trgm_extension_for_plans.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151634_create_decidim_plans.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151635_create_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151636_create_decidim_plans_plan_contents.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151637_create_decidim_plans_plan_collaborator_requests.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151638_create_decidim_plans_attached_proposals.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151639_add_help_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151640_add_mandatory_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151641_add_section_type_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151642_add_answer_length_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151643_create_version_associations.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151644_add_transaction_id_column_to_versions.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151645_add_update_token_to_decidim_plans.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151646_add_closed_at_to_decidim_plans.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151647_fix_plan_closing_workflow_states.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151648_create_decidim_plans_tags_and_plan_taggings.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151649_change_plans_related_proposals_to_resource_links.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151650_add_settings_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151651_add_information_to_decidim_plans_sections.decidim_plans"
require "#{Rails.root}/db/migrate/20201001151652_add_comment_to_versions.decidim_plans"

class UninstallDecidimPlans < ActiveRecord::Migration[5.2]
  def up
    AddCommentToVersions.down
    AddInformationToDecidimPlansSections.down
    AddSettingsToDecidimPlansSections.down
    ChangePlansRelatedProposalsToResourceLinks.down
    CreateDecidimPlansTagsAndPlanTaggings.down
    #FixPlanClosingWorkflowStates.down
    AddClosedAtToDecidimPlans.down
    AddUpdateTokenToDecidimPlans.down
    AddTransactionIdColumnToVersions.down
    CreateVersionAssociations.down
    AddAnswerLengthToDecidimPlansSections.down
    AddSectionTypeToDecidimPlansSections.down
    AddMandatoryToDecidimPlansSections.down
    AddHelpToDecidimPlansSections.down
    CreateDecidimPlansAttachedProposals.down
    CreateDecidimPlansPlanCollaboratorRequests.down
    CreateDecidimPlansPlanContents.down
    CreateDecidimPlansSections.down
    CreateDecidimPlans.down
    EnablePgTrgmExtensionForPlans.down
  end

  def down
    EnablePgTrgmExtensionForPlans.up
    CreateDecidimPlans.up
    CreateDecidimPlansSections.up
    CreateDecidimPlansPlanContents.up
    CreateDecidimPlansPlanCollaboratorRequests.up
    CreateDecidimPlansAttachedProposals.up
    AddHelpToDecidimPlansSections.up
    AddMandatoryToDecidimPlansSections.up
    AddSectionTypeToDecidimPlansSections.up
    AddAnswerLengthToDecidimPlansSections.up
    CreateVersionAssociations.up
    AddTransactionIdColumnToVersions.up
    AddUpdateTokenToDecidimPlans.up
    AddClosedAtToDecidimPlans.up
    #FixPlanClosingWorkflowStates.up
    CreateDecidimPlansTagsAndPlanTaggings.up
    ChangePlansRelatedProposalsToResourceLinks.up
    AddSettingsToDecidimPlansSections.up
    AddInformationToDecidimPlansSections.up
    AddCommentToVersions.up
  end
end
