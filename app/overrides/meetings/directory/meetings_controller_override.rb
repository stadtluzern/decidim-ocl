# frozen_string_literal: true

Decidim::Meetings::Directory::MeetingsController.class_eval do
  def meetings
    @meetings ||= paginate(search.result.order(start_time: :desc))
  end

  def default_filter_params
    {
      date: ["past", "upcoming"],
      search_text: "",
      activity: "all",
      scope_id: default_filter_scope_params,
      space: default_filter_space_params,
      type: default_filter_type_params,
      origin: default_filter_origin_params,
      category_id: default_filter_category_params
    }
  end
end
