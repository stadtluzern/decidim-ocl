# frozen_string_literal: true

Decidim::Meetings::Directory::MeetingsController.class_eval do
  def meetings
    @meetings ||= paginate(search.result.order(start_time: :desc))
  end

  def default_filter_params
    {
      search_text: "",
      with_any_date: ["past", "upcoming"],
      title_or_description_cont: "",
      activity: "all",
      with_any_scope: default_filter_scope_params,
      with_any_space: default_filter_space_params,
      with_any_type: default_filter_type_params,
      with_any_origin: default_filter_origin_params,
      with_any_global_category: default_filter_category_params
    }
  end
end
