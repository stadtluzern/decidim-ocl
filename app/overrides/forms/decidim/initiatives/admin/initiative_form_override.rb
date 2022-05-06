Decidim::Initiatives::Admin::InitiativeForm.class_eval do
  def signature_type_options
    Decidim::Initiative.signature_types.keys.map do |type|
      [
        I18n.t(
          type,
          scope: %w(activemodel attributes initiative signature_type_values)
        ), type
      ]
    end
  end
end