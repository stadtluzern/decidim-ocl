# frozen_string_literal: true

Decidim::Meetings::Directory::MeetingsController.class_eval do
  def meetings
    is_past_meetings = params.dig('filter', 'with_any_date')&.include?('past')
    @meetings ||= paginate(custom_search.order(start_time: is_past_meetings ? :desc : :asc))
  end

  private

  def custom_search
    upcoming = params.dig('filter', 'with_any_date')&.include?('upcoming')
    base = search.result
    return base unless upcoming

    base.where(start_time: DateTime.now..)
  end
end
