# This migration re-applies all previously installed migrations from decidim_initiatives

require "#{Rails.root}/db/migrate/20210112095510_create_decidim_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095511_create_decidim_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095512_create_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095513_create_decidim_initiatives_committee_members.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095514_add_decidim_user_group_id_to_decidim_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095515_change_signature_interval_to_optional.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095516_add_decidim_user_group_id_to_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095517_remove_scope_from_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095518_add_banner_image_to_initiative_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095519_add_hashtag_to_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095520_add_initiative_supports_count_to_initiative.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095521_create_decidim_initiatives_decidim_initiatives_type_scopes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095522_remove_supports_required_from_decidim_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095523_add_scopes_for_all_initiative_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095524_add_scoped_type_to_initiative.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095525_update_initiative_scoped_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095526_remove_unused_attributes_from_initiative.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095527_add_initiative_notification_dates.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095528_create_initiative_extra_data.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095529_create_static_pages.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095530_optional_validation_support.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095531_add_offline_votes_to_initiative.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095532_drop_initiative_description_index.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095533_create_initiative_description_index.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095534_enable_pg_trgm_extension_for_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095535_drop_decidim_initiatives_extra_data.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095536_remove_requires_validation_from_decidim_initiatives_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095537_add_unique_on_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095538_rename_signature_time_fields_to_signature_date.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095539_fix_user_groups_ids_on_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095540_make_initiative_authors_polymorphic.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095541_add_reference_to_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095542_add_collect_extra_user_fields_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095543_add_online_signature_enabled_to_initiative_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095544_add_extra_fields_legal_information_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095545_add_min_committee_members_to_initiative_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095546_add_encrypted_metadata_to_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095547_add_timestamp_to_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095548_add_hash_id_to_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095549_add_validate_sms_code_on_votes_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095550_add_document_number_authorization_handler_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095551_add_undo_online_signatures_enabled_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095552_add_promoting_committee_option.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095553_move_signature_type_to_initative_type.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095554_index_foreign_keys_in_decidim_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095555_index_foreign_keys_in_decidim_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095556_add_custom_signature_end_time_option.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095557_add_attachments_enabled_option.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095558_add_area_to_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210112095559_add_area_enabled_option_to_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141994_add_settings_to_initiatives_types.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141995_add_scopes_to_initiatives_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141996_allow_multiple_initiative_votes_counter_caches.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141997_allow_multiple_offline_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141998_remove_user_groups_from_initiative_votes.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210203141999_add_commentable_counter_cache_to_initiatives.decidim_initiatives"
require "#{Rails.root}/db/migrate/20210811125883_add_followable_counter_cache_to_initiatives.decidim_initiatives"

class ReinstallDecidimInitiativesForOCL < ActiveRecord::Migration[6.0]
  def up
    say_with_time 'Altes Zeug' do
      CreateDecidimInitiativesTypes.new.migrate(:up)
      CreateDecidimInitiatives.new.migrate(:up)
      CreateDecidimInitiativesVotes.new.migrate(:up)
      CreateDecidimInitiativesCommitteeMembers.new.migrate(:up)
      AddDecidimUserGroupIdToDecidimInitiatives.new.migrate(:up)
      ChangeSignatureIntervalToOptional.new.migrate(:up)
      AddDecidimUserGroupIdToDecidimInitiativesVotes.new.migrate(:up)
      RemoveScopeFromDecidimInitiativesVotes.new.migrate(:up)
      AddBannerImageToInitiativeType.new.migrate(:up)
      AddHashtagToInitiatives.new.migrate(:up)
      AddInitiativeSupportsCountToInitiative.new.migrate(:up)
      CreateDecidimInitiativesDecidimInitiativesTypeScopes.new.migrate(:up)
      RemoveSupportsRequiredFromDecidimInitiativesTypes.new.migrate(:up)
      AddScopesForAllInitiativeTypes.new.migrate(:up)
      AddScopedTypeToInitiative.new.migrate(:up)
      UpdateInitiativeScopedType.new.migrate(:up)
      RemoveUnusedAttributesFromInitiative.new.migrate(:up)
      AddInitiativeNotificationDates.new.migrate(:up)
      CreateInitiativeExtraData.new.migrate(:up)
      CreateStaticPages.new.migrate(:up)
      OptionalValidationSupport.new.migrate(:up)
      AddOfflineVotesToInitiative.new.migrate(:up)
      DropInitiativeDescriptionIndex.new.migrate(:up)
      CreateInitiativeDescriptionIndex.new.migrate(:up)
      EnablePgTrgmExtensionForInitiatives.new.migrate(:up)
      DropDecidimInitiativesExtraData.new.migrate(:up)
      RemoveRequiresValidationFromDecidimInitiativesType.new.migrate(:up)
      AddUniqueOnVotes.new.migrate(:up)
      RenameSignatureTimeFieldsToSignatureDate.new.migrate(:up)
      FixUserGroupsIdsOnInitiatives.new.migrate(:up)
      MakeInitiativeAuthorsPolymorphic.new.migrate(:up)
      AddReferenceToInitiatives.new.migrate(:up)
      AddCollectExtraUserFieldsToInitiativesTypes.new.migrate(:up)
      AddOnlineSignatureEnabledToInitiativeType.new.migrate(:up)
      AddExtraFieldsLegalInformationToInitiativesTypes.new.migrate(:up)
      AddMinCommitteeMembersToInitiativeType.new.migrate(:up)
      AddEncryptedMetadataToDecidimInitiativesVotes.new.migrate(:up)
      AddTimestampToDecidimInitiativesVotes.new.migrate(:up)
      AddHashIdToDecidimInitiativesVotes.new.migrate(:up)
      AddValidateSmsCodeOnVotesToInitiativesTypes.new.migrate(:up)
      AddDocumentNumberAuthorizationHandlerToInitiativesTypes.new.migrate(:up)
      AddUndoOnlineSignaturesEnabledToInitiativesTypes.new.migrate(:up)
      AddPromotingCommitteeOption.new.migrate(:up)
      MoveSignatureTypeToInitativeType.new.migrate(:up)
      IndexForeignKeysInDecidimInitiatives.new.migrate(:up)
      IndexForeignKeysInDecidimInitiativesVotes.new.migrate(:up)
      AddCustomSignatureEndTimeOption.new.migrate(:up)
      AddAttachmentsEnabledOption.new.migrate(:up)
      AddAreaToInitiatives.new.migrate(:up)
      AddAreaEnabledOptionToInitiatives.new.migrate(:up)
      AddSettingsToInitiativesTypes.new.migrate(:up)
      AddScopesToInitiativesVotes.new.migrate(:up)
      AllowMultipleInitiativeVotesCounterCaches.new.migrate(:up)
      AllowMultipleOfflineVotes.new.migrate(:up)
      RemoveUserGroupsFromInitiativeVotes.new.migrate(:up)
      AddCommentableCounterCacheToInitiatives.new.migrate(:up)
    end

    say_with_time 'Neues Zeug' do
      AddFollowableCounterCacheToInitiatives.new.migrate(:up)
    end
  end

  def down
    say_with_time 'Neues Zeug' do
      AddFollowableCounterCacheToInitiatives.new.migrate(:down)
    end

    say_with_time 'Altes Zeug' do
      AddCommentableCounterCacheToInitiatives.new.migrate(:down)

      # RemoveUserGroupsFromInitiativeVotes.new.migrate(:down)
      add_column :decidim_initiatives_votes, :decidim_user_group_id, :integer
      add_index  :decidim_initiatives_votes, :decidim_user_group_id

      # AllowMultipleOfflineVotes.new.migrate(:down)
      remove_column :decidim_initiatives, :offline_votes
      add_column :decidim_initiatives, :offline_votes, :integer

      # AllowMultipleInitiativeVotesCounterCaches.new.migrate(:down)
      remove_column :decidim_initiatives, :online_votes
      add_column :decidim_initiatives, :initiative_supports_count, :integer,
                 null: false, default: 0
      add_column :decidim_initiatives, :initiative_votes_count, :integer,
                 null: false, default: 0

      AddScopesToInitiativesVotes.new.migrate(:down)
      AddSettingsToInitiativesTypes.new.migrate(:down)
      AddAreaEnabledOptionToInitiatives.new.migrate(:down)
      AddAreaToInitiatives.new.migrate(:down)
      AddAttachmentsEnabledOption.new.migrate(:down)
      AddCustomSignatureEndTimeOption.new.migrate(:down)
      IndexForeignKeysInDecidimInitiativesVotes.new.migrate(:down)
      IndexForeignKeysInDecidimInitiatives.new.migrate(:down)

      # MoveSignatureTypeToInitativeType.new.migrate(:down)
      remove_column :decidim_initiatives_types, :signature_type
      add_column :decidim_initiatives_types, :online_signature_enabled, :boolean,
                 null: false, default: true

      AddPromotingCommitteeOption.new.migrate(:down)
      AddUndoOnlineSignaturesEnabledToInitiativesTypes.new.migrate(:down)
      AddDocumentNumberAuthorizationHandlerToInitiativesTypes.new.migrate(:down)
      AddValidateSmsCodeOnVotesToInitiativesTypes.new.migrate(:down)
      AddHashIdToDecidimInitiativesVotes.new.migrate(:down)
      AddTimestampToDecidimInitiativesVotes.new.migrate(:down)
      AddEncryptedMetadataToDecidimInitiativesVotes.new.migrate(:down)
      AddMinCommitteeMembersToInitiativeType.new.migrate(:down)
      AddExtraFieldsLegalInformationToInitiativesTypes.new.migrate(:down)
      AddOnlineSignatureEnabledToInitiativeType.new.migrate(:down)
      AddCollectExtraUserFieldsToInitiativesTypes.new.migrate(:down)
      AddReferenceToInitiatives.new.migrate(:down)
      MakeInitiativeAuthorsPolymorphic.new.migrate(:down)
      FixUserGroupsIdsOnInitiatives.new.migrate(:down)
      RenameSignatureTimeFieldsToSignatureDate.new.migrate(:down)
      AddUniqueOnVotes.new.migrate(:down)
      RemoveRequiresValidationFromDecidimInitiativesType.new.migrate(:down)
      DropDecidimInitiativesExtraData.new.migrate(:down)
      EnablePgTrgmExtensionForInitiatives.new.migrate(:down)
      CreateInitiativeDescriptionIndex.new.migrate(:down)
      DropInitiativeDescriptionIndex.new.migrate(:down)
      AddOfflineVotesToInitiative.new.migrate(:down)
      OptionalValidationSupport.new.migrate(:down)
      CreateStaticPages.new.migrate(:down)
      CreateInitiativeExtraData.new.migrate(:down)
      AddInitiativeNotificationDates.new.migrate(:down)
      RemoveUnusedAttributesFromInitiative.new.migrate(:down)

      # UpdateInitiativeScopedType.new.migrate(:down)
      # Not reversible???

      # AddScopedTypeToInitiative.new.migrate(:down)
      # Deleting the table soon anyways

      # AddScopesForAllInitiativeTypes.new.migrate(:down)
      # Deleting the table soon anyways

      #RemoveSupportsRequiredFromDecidimInitiativesTypes.new.migrate(:down)
      add_column :decidim_initiatives_types, :supports_required, :integer,
                 null: false, default: 0

      CreateDecidimInitiativesDecidimInitiativesTypeScopes.new.migrate(:down)
      AddInitiativeSupportsCountToInitiative.new.migrate(:down)
      AddHashtagToInitiatives.new.migrate(:down)
      AddBannerImageToInitiativeType.new.migrate(:down)
      RemoveScopeFromDecidimInitiativesVotes.new.migrate(:down)
      AddDecidimUserGroupIdToDecidimInitiativesVotes.new.migrate(:down)

      # ChangeSignatureIntervalToOptional.new.migrate(:down)
      # Deleting the table soon anyways

      AddDecidimUserGroupIdToDecidimInitiatives.new.migrate(:down)
      CreateDecidimInitiativesCommitteeMembers.new.migrate(:down)
      CreateDecidimInitiativesVotes.new.migrate(:down)
      CreateDecidimInitiatives.new.migrate(:down)
      CreateDecidimInitiativesTypes.new.migrate(:down)
    end
  end
end
