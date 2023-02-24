# frozen_string_literal: true

#  Copyright (c) 2006-2023, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

# Handles actions on the /.well-known path
class WellknownController < ApplicationController
  def security
    file = file_for(tenant) || not_found
    render plain: file.read
  end

  private

  def organization
    Decidim::Organization.find_by(host: request.host)
  end

  def tenant
    (organization.tenant_type || 'other').to_sym
  end

  def file_for(tenant)
    path = Rails.root.join("lib/tenant_files/#{tenant}/security.txt")
    return unless path.exist?

    path
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
