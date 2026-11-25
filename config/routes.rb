# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # Temporary (#228): upgrade documents for org admins; remove after the 0.31 upgrade.
  get 'upgrade/:doc', to: 'upgrade_docs#show', constraints: { doc: /planning|upgrade_steps|open_questions/ }

  mount Decidim::Core::Engine => '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '.well-known/security.txt', to: 'wellknown#security'

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'
end
