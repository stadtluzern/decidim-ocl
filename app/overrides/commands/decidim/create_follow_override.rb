# frozen_string_literal: true

Decidim::CreateFollow.class_eval do
  private

  def create_follow!
    @follow = Decidim::Follow.find_by(
        followable: form.followable,
        user: current_user
    ) || Decidim::Follow.create!(
        followable: form.followable,
        user: current_user
    )
  end
end
