# frozen_string_literal: true

# Override
# --------
# Why it happens:
# When the resource is called from an Notification,
# it receives a Decidim::ResourceManifest
# instead of a Decidim::ParticipatorySpaceManifest
#
# How we fix it:
# We return the right manifest instead

Decidim::Proposals::PublishProposalEvent.class_eval do
  def i18n_options
    author_string =
      if (nick = author&.nickname) # User
        "#{author.name} #{link_to("@#{nick}", profile_path(nick))}"
      elsif (org = resource.authors.first).instance_of?(Decidim::Organization)
        org.name
      end
    super.merge({ author: author_string })
  end
end
