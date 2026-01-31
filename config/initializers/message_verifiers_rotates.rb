Rails.application.config.after_initialize do |app|
  # Create an old SHA1 key generator
  sha1_key_generator =
    ActiveSupport::KeyGenerator.new(
      app.secret_key_base,
      iterations: 1000,
      hash_digest_class: OpenSSL::Digest::SHA1
    )

  # Create rotates for all the currently used veririfier
  # In theory all the verifiers but ActiveStorage can be
  # removed from the list in a few months from now on.

  # Note: ActiveStorage is used by trix to create permanent signed ids
  # for the attached images of the blog posts.
  # 
  verifiers = ["ActiveStorage"]

  verifiers.each do |verifier|
    app
      .message_verifier(verifier)
      .rotate(sha1_key_generator.generate_key(verifier))
  end
end
