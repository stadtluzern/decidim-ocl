# frozen_string_literal: true

module DecidimOCL
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  module ApplicationMailer
    def set_smtp
      reply_to = I18n.t('decidim_ocl.reply_to', default: '').presence
      mail.reply_to = [reply_to] if mail.reply_to.blank? && reply_to

      super
    end
  end
end
