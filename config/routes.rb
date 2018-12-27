# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

  get   '/issues/imports_entry/new_entry', :to => 'imports_entry#new_entry', :as => 'new_issues_import_entry'
  post  '/imports_entry', :to => 'imports_entry#create_entry', :as => 'imports_entry'
  get   '/imports_entry/:id', :to => 'imports_entry#show_entry', :as => 'import_entry'
  match '/imports_entry/:id/mapping', :to => 'imports_entry#mapping_entry', :via => [:get, :post], :as => 'import_mapping_entry'
  match '/imports_entry/:id/run_entry', :to => 'imports_entry#run_entry', :via => [:get, :post], :as => 'import_run_entry'