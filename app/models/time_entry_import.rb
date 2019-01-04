class TimeEntryImport < Import
  def self.menu_item
    :time_entries
  end

  # Returns the objects that were imported
  def saved_objects
    TimeEntry.where(:id => saved_items.pluck(:obj_id)).order(:id).preload(:activity, :project, :issue => [:tracker, :priority, :status])
  end

  def mappable_custom_fields
    TimeEntryCustomField.all
  end

  def allowed_target_activities(row)
    project(row).activities
  end

  def project(row)
	issue_id = row_value(row, 'issue_id')
	
	if Issue.exists?(issue_id)
		issue = Issue.find(issue_id)
		return issue.project
	end
    
  end

  private
  
  def configUser(row, time_entry)
	user_id = row_value(row, 'user')
	
	if user_id.present?
		Rails.logger.debug("Hay usuario id")
		
		if user.allowed_to?(:import_time_user, nil, :global => true)
			Rails.logger.debug("Tiene permisos")
			user_import = User.find_by_login(user_id)
			
			if !user_import.nil?
				time_entry.user = user_import
			else
				Rails.logger.debug("No existe usuario")
			end
		else
			Rails.logger.debug("No Tiene permisos para imputar horas a otros usuarios")
		end
	else
		time_entry.user = user
	end
  end

  def build_object(row)
    object = TimeEntryFile.new
	
	issue_id = row_value(row, 'issue_id')
	
	if Issue.exists?(issue_id)
		issue = Issue.find(issue_id)
		object.issue = issue
		
		object.project = issue.project
		
		configUser(row, object)
	
		if activity_name = row_value(row, 'activity')
			activity_id = allowed_target_activities(row).named(activity_name).first.try(:id)
		end
	
		if TimeEntryActivity.exists?(activity_id)
			object.activity = TimeEntryActivity.find(activity_id)
		else
			object.activity_id = -1
		end
		
	else
		object.issue_id = -1
		object.project_id = -1
		object.activity_id = -1
	end
	
	begin
		Rails.logger.debug("Fecha en archivo")
		Rails.logger.debug(row_value(row, 'spent_on'))
		Rails.logger.debug("Fecha en archivo")
		spent_on = Date.strptime(row_value(row, 'spent_on'), '%d/%m/%Y')
		Rails.logger.debug("Fecha parsed")
		Rails.logger.debug(spent_on)
		Rails.logger.debug("Fecha parsed")
		object.spent_on = spent_on
	rescue   
		Rails.logger.error("Fecha en formato no válido")
	end
		
	object.hours = row_value(row, 'hours')
	object.comments = row_value(row, 'comments')
	
    object
  end
end