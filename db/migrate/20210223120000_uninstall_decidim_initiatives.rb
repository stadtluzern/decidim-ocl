# This migration reverses all migrations from decidim_initiatives

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

class UninstallDecidimInitiatives < ActiveRecord::Migration[5.2]
  def up
    AddCommentableCounterCacheToInitiatives.down
    RemoveUserGroupsFromInitiativeVotes.down
    AllowMultipleOfflineVotes.down
    AllowMultipleInitiativeVotesCounterCaches.down
    AddScopesToInitiativesVotes.down
    AddSettingsToInitiativesTypes.down
    AddAreaEnabledOptionToInitiatives.down
    AddAreaToInitiatives.down
    AddAttachmentsEnabledOption.down
    AddCustomSignatureEndTimeOption.down
    IndexForeignKeysInDecidimInitiativesVotes.down
    IndexForeignKeysInDecidimInitiatives.down
    MoveSignatureTypeToInitativeType.down
    AddPromotingCommitteeOption.down
    AddUndoOnlineSignaturesEnabledToInitiativesTypes.down
    AddDocumentNumberAuthorizationHandlerToInitiativesTypes.down
    AddValidateSmsCodeOnVotesToInitiativesTypes.down
    AddHashIdToDecidimInitiativesVotes.down
    AddTimestampToDecidimInitiativesVotes.down
    AddEncryptedMetadataToDecidimInitiativesVotes.down
    AddMinCommitteeMembersToInitiativeType.down
    AddExtraFieldsLegalInformationToInitiativesTypes.down
    AddOnlineSignatureEnabledToInitiativeType.down
    AddCollectExtraUserFieldsToInitiativesTypes.down
    AddReferenceToInitiatives.down
    MakeInitiativeAuthorsPolymorphic.down
    FixUserGroupsIdsOnInitiatives.down
    RenameSignatureTimeFieldsToSignatureDate.down
    AddUniqueOnVotes.down
    RemoveRequiresValidationFromDecidimInitiativesType.down
    DropDecidimInitiativesExtraData.down
    EnablePgTrgmExtensionForInitiatives.down
    CreateInitiativeDescriptionIndex.down
    DropInitiativeDescriptionIndex.down
    AddOfflineVotesToInitiative.down
    OptionalValidationSupport.down
    CreateStaticPages.down
    CreateInitiativeExtraData.down
    AddInitiativeNotificationDates.down
    RemoveUnusedAttributesFromInitiative.down
    UpdateInitiativeScopedType.down
    AddScopedTypeToInitiative.down
    AddScopesForAllInitiativeTypes.down
    RemoveSupportsRequiredFromDecidimInitiativesTypes.down
    CreateDecidimInitiativesDecidimInitiativesTypeScopes.down
    AddInitiativeSupportsCountToInitiative.down
    AddHashtagToInitiatives.down
    AddBannerImageToInitiativeType.down
    RemoveScopeFromDecidimInitiativesVotes.down
    AddDecidimUserGroupIdToDecidimInitiativesVotes.down
    ChangeSignatureIntervalToOptional.down
    AddDecidimUserGroupIdToDecidimInitiatives.down
    CreateDecidimInitiativesCommitteeMembers.down
    CreateDecidimInitiativesVotes.down
    CreateDecidimInitiatives.down
    CreateDecidimInitiativesTypes.down
  end

  def down
    CreateDecidimInitiativesTypes.up
    CreateDecidimInitiatives.up
    CreateDecidimInitiativesVotes.up
    CreateDecidimInitiativesCommitteeMembers.up
    AddDecidimUserGroupIdToDecidimInitiatives.up
    ChangeSignatureIntervalToOptional.up
    AddDecidimUserGroupIdToDecidimInitiativesVotes.up
    RemoveScopeFromDecidimInitiativesVotes.up
    AddBannerImageToInitiativeType.up
    AddHashtagToInitiatives.up
    AddInitiativeSupportsCountToInitiative.up
    CreateDecidimInitiativesDecidimInitiativesTypeScopes.up
    RemoveSupportsRequiredFromDecidimInitiativesTypes.up
    AddScopesForAllInitiativeTypes.up
    AddScopedTypeToInitiative.up
    UpdateInitiativeScopedType.up
    RemoveUnusedAttributesFromInitiative.up
    AddInitiativeNotificationDates.up
    CreateInitiativeExtraData.up
    CreateStaticPages.up
    OptionalValidationSupport.up
    AddOfflineVotesToInitiative.up
    DropInitiativeDescriptionIndex.up
    CreateInitiativeDescriptionIndex.up
    EnablePgTrgmExtensionForInitiatives.up
    DropDecidimInitiativesExtraData.up
    RemoveRequiresValidationFromDecidimInitiativesType.up
    AddUniqueOnVotes.up
    RenameSignatureTimeFieldsToSignatureDate.up
    FixUserGroupsIdsOnInitiatives.up
    MakeInitiativeAuthorsPolymorphic.up
    AddReferenceToInitiatives.up
    AddCollectExtraUserFieldsToInitiativesTypes.up
    AddOnlineSignatureEnabledToInitiativeType.up
    AddExtraFieldsLegalInformationToInitiativesTypes.up
    AddMinCommitteeMembersToInitiativeType.up
    AddEncryptedMetadataToDecidimInitiativesVotes.up
    AddTimestampToDecidimInitiativesVotes.up
    AddHashIdToDecidimInitiativesVotes.up
    AddValidateSmsCodeOnVotesToInitiativesTypes.up
    AddDocumentNumberAuthorizationHandlerToInitiativesTypes.up
    AddUndoOnlineSignaturesEnabledToInitiativesTypes.up
    AddPromotingCommitteeOption.up
    MoveSignatureTypeToInitativeType.up
    IndexForeignKeysInDecidimInitiatives.up
    IndexForeignKeysInDecidimInitiativesVotes.up
    AddCustomSignatureEndTimeOption.up
    AddAttachmentsEnabledOption.up
    AddAreaToInitiatives.up
    AddAreaEnabledOptionToInitiatives.up
    AddSettingsToInitiativesTypes.up
    AddScopesToInitiativesVotes.up
    AllowMultipleInitiativeVotesCounterCaches.up
    AllowMultipleOfflineVotes.up
    RemoveUserGroupsFromInitiativeVotes.up
    AddCommentableCounterCacheToInitiatives.up
  end
end
