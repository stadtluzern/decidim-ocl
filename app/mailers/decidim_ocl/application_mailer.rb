# frozen_string_literal: true

module DecidimOCL
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  module ApplicationMailer
    def set_smtp
      opts = { scope: 'decidim_ocl.reply_to', default: '' }
      tenant_type = organization.tenant_type.presence

      reply_to = I18n.t(tenant_type, **opts).presence if tenant_type
      reply_to ||= I18n.t(:default, **opts).presence

      mail.reply_to = reply_to && [reply_to]

      super
    end
  end
end
