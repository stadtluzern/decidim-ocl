# frozen_string_literal: true

# Serves the 0.31 upgrade documents (planning.html, upgrade_steps.html, open_questions.html
# in the repo root) to org admins of the current tenant, behind the normal Decidim login.
# Temporary: remove together with the route and the three files once the upgrade is done (#228).
class UpgradeDocsController < Decidim::ApplicationController
  DOCS = %w[planning upgrade_steps open_questions].freeze

  before_action :authenticate_user!
  before_action :ensure_admin!

  def show
    doc = DOCS.find { _1 == params[:doc] } || raise(ActionController::RoutingError, 'Not Found')

    # no-store: otherwise the browser shows its cached copy after logout.
    response.headers['Cache-Control'] = 'no-store'
    send_file Rails.root.join("#{doc}.html"), type: 'text/html', disposition: 'inline'
  end

  private

  def ensure_admin!
    raise ActionController::RoutingError, 'Not Found' unless current_user.admin?
  end
end
