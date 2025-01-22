Decidim::Templates::AdminEngine.class_eval do
  routes do
    get '/admin/templates/questionnaire_template/new_import',
        controller: 'questionnaire_templates',
        action: 'new_import',
        as: 'new_import_questionnaire_template'
    post '/admin/templates/questionnaire_template/import',
         controller: 'questionnaire_templates',
         action: 'import',
         as: 'import_questionnaire_template'
    resources :questionnaire_templates do
      member do
        get :export
      end
    end
  end
end
