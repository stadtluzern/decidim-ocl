# frozen_string_literal: true

return unless Object.const_defined?('Decidim::QuestionCaptcha')

Decidim::QuestionCaptcha.configure do |config|
  config.questions = {
    de: [
      {
        'question' => 'Nenne eine Farbe die im Schweizer Wappen vorkommt.',
        'answers' => 'weiss,rot,Weiss,Rot'
      }
    ]
  }
end
