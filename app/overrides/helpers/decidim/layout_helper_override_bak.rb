# frozen_string_literal: true

Decidim::LayoutHelper.module_eval do
  def application_path(path)
    img_path = try_path(path)
    # img_path ||= try_alternate_filename(path)
    # img_path ||= try_alternate_directory(path)

    img_path = URI(img_path).path if Decidim.cors_enabled
    Rails.root.join("public/#{img_path}")
  end

  private

  def try_path(path)
    asset_pack_path(path)
  rescue Webpacker::Manifest::MissingEntryError
    nil
  end

  def try_alternate_filename(path)
    parts = path.split('.')[..-2].join('.')
    ext = path.split('.')[-1]
    asset_pack_path("#{parts}_icon.#{ext}")
  rescue Webpacker::Manifest::MissingEntryError
    nil
  end

  # def try_alternate_directory(path)
  #   parts = path.split('.')[..-2].join('.')
  #   ext = path.split('.')[-1]
  #   asset_pack_path("#{parts}/icon.#{ext}")
  # rescue Webpacker::Manifest::MissingEntryError
  #   nil
  # end
end
