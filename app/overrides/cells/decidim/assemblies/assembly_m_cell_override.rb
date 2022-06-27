# frozen_string_literal: true

# Override
# --------
# Why it happens:
# We want to simplify the display of assemblies in a list.
#
# How we fix it:
# We modify the class which is responsible for displaying assemblies in a list.
# This is more or less intended in decidim.

Decidim::Assemblies::AssemblyMCell.module_eval do
  include ApplicationHelper

  def has_image? # rubocop:disable Naming/PredicateName
    true
  end

  def followers_count
    if model.respond_to?(:followers_count)
      model.followers_count
    else
      model.followers.count
    end
  end

  def has_badge? # rubocop:disable Naming/PredicateName
    false
  end

  def description
    nil
  end

  private

  def resource_image_path
    model.attached_uploader(:hero_image).path || 'organization-default-image.png'
  end

  def statuses
    []
  end
end
