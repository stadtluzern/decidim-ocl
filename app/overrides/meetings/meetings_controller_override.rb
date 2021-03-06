# frozen_string_literal: true

Decidim::Meetings::MeetingsController.class_eval do
  def meetings
    @meetings ||= paginate(search.results.order(:start_time))
  end
end
