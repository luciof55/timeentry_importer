 class TimeentryHookListener < Redmine::Hook::ViewListener
	render_on :view_issues_sidebar_issues_bottom, :partial => "imports/issues_sidebar"
	render_on :view_projects_show_sidebar_bottom, :partial => "imports/projects_show_sidebar"
	render_on :view_welcome_index_left, :partial => "imports/welcome_index"
end