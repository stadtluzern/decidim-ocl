# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  mount Decidim::Core::Engine => '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '.well-known/security.txt', to: 'wellknown#security'

  get 'status/health', to: 'status#health'
  get 'status/readiness', to: 'status#readiness'
end
