# Redmine - project management software
# Copyright (C) 2006-2016  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'csv'

class ImportsEntryController < ApplicationController

  before_action :find_import, :only => [:show_entry, :mapping_entry, :run_entry]
  before_action :authorize_global_import

  helper :issues
  helper :queries
  include QueriesHelper

  def new_entry
  end

  def create_entry
		@import = TimeEntryImport.new
		@import.user = User.current
		@import.file = params[:file]
		@import.set_default_settings

		if @import.save
			redirect_to import_mapping_entry_path(@import)
		else
			redirect_to(new_issues_import_entry_path(@import), flash: {error: l(:label_error_import_save)})
		end
	#End create_entry
	end

  def show_entry
	if @import.unsaved_items.count > 0
		if @import.saved_items.count > 0
			Rails.logger.error("-------------ERRORS Rolling back!!!!-------------------")
			TimeEntry.destroy(@import.saved_items.pluck(:obj_id))
		end
		render "imports_entry/show_entry_errors"
	else
		Rails.logger.debug("-------------NO ERRORS-------------------")
	end
  end

  def mapping_entry
		
		if request.post?
			Rails.logger.debug("mapping_entry POST")
			respond_to do |format| format.html {
				if params[:previous]
					redirect_to new_issues_import_entry_path(@import)
				else
					redirect_to import_run_entry_path(@import)
				end
			}
			end
		else
			begin
				Rails.logger.debug("mapping_entry - GET")
				@import.parse_file
			
				rescue CSV::MalformedCSVError => e
					redirect_to(new_issues_import_entry_path(@import), flash: {error: l(:error_invalid_csv_file_or_settings)})
				rescue ArgumentError, EncodingError => e
					redirect_to(new_issues_import_entry_path(@import), flash: {error: l(:error_invalid_csv_file_or_settings)})
				rescue SystemCallError => e
					redirect_to(new_issues_import_entry_path(@import), flash: {error: l(:error_invalid_csv_file_or_settings)})
			end
		end

	#End mapping_entry
	end

  def run_entry
    if request.post?
		@current = @import.run(:max_items => max_items_per_request, :max_time => 10.seconds)
		respond_to do |format|
			format.html {
				if @import.finished?
					redirect_to import_entry_path(@import)
				else
					redirect_to import_run_entry_path(@import)
				end
			}
			format.js
		end
    end
  end

  private
  
  def authorize_global_import
	return User.current.allowed_to?(:log_time, nil, :global => true)
  end
  
  def find_import
    @import = Import.where(:user_id => User.current.id, :filename => params[:id]).first
    if @import.nil?
      render_404
      return
    elsif @import.finished? && action_name != 'show_entry'
      redirect_to import_entry_path(@import)
      return
    end
    update_from_params if request.post?
  end

  def update_from_params
    if params[:import_settings].is_a?(Hash)
      @import.settings ||= {}
      @import.settings.merge!(params[:import_settings])
      @import.save!
    end
  end

  def max_items_per_request
    5
  end
end
