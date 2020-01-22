require_dependency 'imports_controller'

# Patches Redmine's ImportsController dynamically.
module ImportIssuePatch
	def self.included(base) # :nodoc:
		Rails.logger.info("**********************************")
		base.extend(ClassMethods)

		base.send(:include, InstanceMethods)

		# Same as typing in the class 
		base.class_eval do
			unloadable # Send unloadable so it will not be unloaded in development
			#Override methods
		  
		end
		
		#THE before_action IS WHO GIVES THE AUTHORIZATION TO EXECUTE THE FUNCTION
		#before_action :authorize, :except => [:archive, :unarchive, :archived?, :unarchived?]
		  
		Rails.logger.info("++++++++++++++++++++++++++++")
	#End included
	end
	
#End Module
end
  
module ClassMethods

end
  
module InstanceMethods

	def new_entry
		
	#End new
	end
	
	def create_entry
		@import = TimeEntryImport.new
		@import.user = User.current
		@import.file = params[:file]
		@import.set_default_settings

		if @import.save
			Rails.logger.info("-------------TimeEntryImport-------------------")
			Rails.logger.info(@import)
			Rails.logger.info("-------------TimeEntryImport-------------------")
			redirect_to import_mapping_entry_path(@import)
		else
		  render :action => 'new_entry'
		end
	#End create_entry
	end
	
	def mapping_entry
		if request.post?
			respond_to do |format| format.html {
				if params[:previous]
					redirect_to import_settings_path(@import)
				else
					redirect_to import_run_path(@import)
				end
			}
			end
		end
				
		Rails.logger.info("mapping_entry")
	#End mapping_entry
	end
	
#End Module
end

# Add module to Issue Import
Rails.configuration.to_prepare do
	Rails.logger.info("Sending... ImportIssuePatch")
	ImportsController.send(:include, ImportIssuePatch)
	Rails.logger.info("ImportIssuePatch sent")
end