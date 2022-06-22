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

 Decidim::IconHelper.module_eval do
   def resource_icon(resource, options = {})
     if resource.class.name == 'Decidim::Comments::Comment'
       icon 'comment-square', options
     elsif resource.respond_to?(:component)
       component_icon(resource.component, options)
     elsif resource.respond_to?(:manifest)
       manifest_icon(resource.manifest, options)
     elsif resource.is_a?(Decidim::User)
       icon 'person', options
     else
       icon 'bell', options
     end
   rescue NoMethodError
     icon 'bell', options
   end
 end
