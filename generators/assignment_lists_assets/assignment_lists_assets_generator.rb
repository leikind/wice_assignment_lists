class AssignmentListsAssetsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # config
      m.directory "config/initializers"
      m.file "initializers/ass_lists_config.rb",  "config/initializers/ass_lists_config.rb"

      # js & css
      m.file "javascripts/assignment_lists_jquery.js",  "public/javascripts/assignment_lists_jquery.js"
      m.file "javascripts/assignment_lists_prototype.js",  "public/javascripts/assignment_lists_prototype.js"

      m.file "stylesheets/assignment_lists.css",  "public/stylesheets/assignment_lists.css"

      # images
      m.directory "public/images/icons/"
      
      %w(wal_edit.png wal_spinner.gif).each do |f|
        m.file "icons/#{f}",  "public/images/icons/#{f}"
      end
    end
  end
end

