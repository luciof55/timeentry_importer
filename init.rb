require_dependency 'timeentry_hook_listener'

Redmine::Plugin.register :timeentry_importer do
  name 'Timeentry Importer plugin'
  author 'Lucio Ferrero'
  description 'This is a plugin for Redmine that allows import time entries form a csv file'
  version '0.0.1'
  url 'http://github.com/luciof55/timeentry_importer'
  author_url 'https://www.linkedin.com/in/lucioferrero/'
end