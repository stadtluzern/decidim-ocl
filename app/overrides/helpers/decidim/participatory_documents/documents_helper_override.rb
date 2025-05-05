 # frozen_string_literal: true

 # Override
 # --------
 # Why it happens:
 # The role can be nil, but user_role_config_for can not handle nils
 #
 # How we fix it:
 # Return :none as an atom instead, to handle a none value gracefully

Decidim::ParticipatoryDocuments::DocumentsHelper.module_eval do
  def user_role_config
    return @user_role_config if @user_role_config

    space = current_participatory_space

    @user_role_config =
      if current_user.admin?
        space.user_role_config_for(current_user, :organization_admin)
      else
        role = space.user_roles.find_by(user: current_user)
        space.user_role_config_for(current_user, role&.role || :none)
      end
  end
end
