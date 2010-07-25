class AssignmentListsPrototypeGenerator < Rails::Generator::Base
  def active_js_framework
    ':prototype'
  end

  def inactive_js_framework
    ':jquery'
  end

  def manifest
    record do |m|
      # js
      m.file "javascripts/assignment_lists_prototype.js",  "public/javascripts/assignment_lists_prototype.js"
      
      # config
      m.directory "config/initializers"
      m.template "../../common_templates/initializers/ass_lists_config.rb",  "config/initializers/ass_lists_config.rb"


      # css
      m.file "../../common_templates/stylesheets/assignment_lists.css",  "public/stylesheets/assignment_lists.css"

      # images
      m.directory "public/images/icons/"
      
      %w(wal_edit.png wal_spinner.gif).each do |f|
        m.file "../../common_templates/icons/#{f}",  "public/images/icons/#{f}"
      end
    end
  end
end

