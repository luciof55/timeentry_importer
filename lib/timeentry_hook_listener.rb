 class TimeentryHookListener < Redmine::Hook::ViewListener
	render_on :view_issues_sidebar_issues_bottom, :partial => "imports/issues_sidebar"
	render_on :view_projects_show_sidebar_bottom, :partial => "imports/projects_show_sidebar"
	render_on :view_welcome_index_left, :partial => "imports/welcome_index"
	render_on :view_timelog_edit_form_bottom, :partial => "timelog/timelog_edit_form"
	
	def controller_timelog_edit_before_save(context={})
		Rails.logger.info("--------------- TimeentryHookListener - controller_timelog_edit_before_save -  START -----------------")
		
		time_entry = context[:time_entry]
		
		Rails.logger.info(time_entry)
		
		Rails.logger.info("*************************************")
		
		time_entry_params = context[:params][:time_entry]
		
		if time_entry_params[:user_id]
		
			if User.current.allowed_to?(:import_time_user, nil, :global => true)
			
				user_id = time_entry_params[:user_id].to_i
				
				Rails.logger.info(user_id)
				
				if user_id
					user = User.find(user_id)
					if user
						Rails.logger.info("--------------- Setting user " + user_id.to_s + " -----------------")
						time_entry.user = user
					else
						Rails.logger.info("--------------- User " + user_id.to_s + " not found -----------------")
					end
				end
				
			else
				Rails.logger.info("---------------Current user does not have permission -----------------")
			end
			
		else
			Rails.logger.info("---------------Request param user not found -----------------")
		end
		
		Rails.logger.info("--------------- TimeentryHookListener - controller_timelog_edit_before_save -  END -----------------")
	end
end