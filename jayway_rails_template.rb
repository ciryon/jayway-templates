# Application template for Jayway projects

# Replace test framework
remove_dir 'test'
# run 'gem install rspec-rails --pre'
gem 'rspec', '>= 2.0.0.beta.8', :group => :test
gem 'rspec-rails', '>= 2.0.0.beta.8', :group => :test
gem 'factory_girl', :git => 'git://github.com/szimek/factory_girl.git', :branch => 'rails3', :group => :test

# Cucumber integration test
gem 'capybara', :group => :test
gem 'database_cleaner', :group => :test
gem 'cucumber-rails', :group => :test
gem 'cucumber', '0.7.2', :group => :test
gem 'spork', :group => :test
gem 'launchy', :group => :test
gem 'cucumber', :group => :test

# Install View
gem 'haml', '3.0.2'
gem 'jayway-templates'
gem 'formtastic', :git => 'http://github.com/justinfrench/formtastic.git', :branch => 'rails3'
get 'http://github.com/justinfrench/formtastic/raw/master/generators/formtastic/templates/formtastic.rb', 'config/initializers/formtastic.rb'
gem 'compass'

remove_file 'app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.haml' , <<-HAML 
!!!
%html
  %head
    %title= yield(:title)
    = stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'print.css', :media => 'print'
    /[if lt IE 8]
      = stylesheet_link_tag 'ie.css', :media => 'screen, projection'
    = javascript_include_tag :jquery
    = csrf_meta_tag
    = yield(:head)
  %body.bp
    #container
      #header
        = yield(:title)
      #sidebar
      #content
          = yield
      #container-footer
    #footer
HAML

inject_into_file 'app/helpers/application_helper.rb',  :after => 'module ApplicationHelper' do
  <<-APPLICATION_HELPER
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  APPLICATION_HELPER
end


# Replace prototype with jQuery.
initializer 'jquery.rb', <<-JQUERY
if Rails.env.development?
ActionView::Helpers::AssetTagHelper.register_javascript_expansion \
  :jquery => %w(jquery jquery-ui rails)
else
ActionView::Helpers::AssetTagHelper.register_javascript_expansion \
  :jquery => %w(jquery.min jquery-ui.min rails)
end    
JQUERY

remove_file 'public/javascripts/controls.js'
remove_file 'public/javascripts/dragdrop.js'
remove_file 'public/javascripts/effects.js'
remove_file 'public/javascripts/prototype.js'
remove_file 'public/javascripts/rails.js'
get 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.js', 'public/javascripts/jquery.js'
get 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js', 'public/javascripts/jquery.min.js'
get 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.js', 'public/javascripts/jquery-ui.js'
get 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js', 'public/javascripts/jquery-ui.min.js'
get 'http://github.com/rails/jquery-ujs/raw/master/src/rails.js', 'public/javascripts/rails.js'

# Configure Rails Generators
application <<-GENERATORS
    config.generators do |g| 
      g.orm  :active_record  
      g.template_engine :jayway  
      g.test_framework :rspec, :fixture => true, :views => false, :view_specs => false 
      g.integration_tool :cucumber
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.stylesheets false
    end 
GENERATORS

# RVM
file ".rvmrc", <<-RVMRC
rvm gemset use #{app_name}
RVMRC

current_ruby = /=> \e\[32m(.*)\e\[m/.match(%x{rvm list})[1]
run "rvm gemset create #{app_name}"
run "rvm #{current_ruby}@#{app_name} gem install bundler"
run "rvm #{current_ruby}@#{app_name} -S bundle install"

# Run the generators
run "rvm #{current_ruby}@#{app_name} -S rails g rspec:install"
run "rvm #{current_ruby}@#{app_name} -S rails cucumber:skeleton --rspec --capybara"  
run "rvm #{current_ruby}@#{app_name} -S compass create . --using blueprint/semantic --app rails --sass-dir app/stylesheets --css-dir public/stylesheets" 


# Git
run 'touch db/.gitkeep lib/tasks/.gitkeep log/.gitkeep tmp/.gitkeep public/stylesheets/.gitkeep vendor/plugins/.gitkeep'

append_file '.gitignore' , <<-GIT 
.DS_Store
.bundle
.idea
db/*.sqlite3
log/*.log
public/stylesheets/*.css
tmp/**/*
GIT

git :init
git :add => '.'
git :commit => '-a -m "Initial commit"'
