namespace "wal" do
  desc "Copy images and the javascript file to public"
  task :copy_resources_to_public do
    puts "copying assignment_lists.js to /public/javascripts/"
    FileUtils.copy(
      File.join(RAILS_ROOT,  '/vendor/plugins/wice_assignment_lists/javascripts/assignment_lists.js'), 
      File.join(RAILS_ROOT,  '/public/javascripts/')
    )

    puts "copying assignment_lists.css to /public/stylesheets/"
    FileUtils.copy(
      File.join(RAILS_ROOT,  '/vendor/plugins/wice_assignment_lists/stylesheets/assignment_lists.css'), 
      File.join(RAILS_ROOT,  '/public/stylesheets/')
    )


    FileUtils.mkdir_p(File.join(RAILS_ROOT,  "/public/images/icons/"))
    %w( wal_spinner.gif wal_edit.png ).each do |file|
      puts "copying #{file} to /public/images/icons/"   
      FileUtils.copy(
        File.join(RAILS_ROOT,  "/vendor/plugins/wice_assignment_lists/images/#{file}"), 
        File.join(RAILS_ROOT,  '/public/images/icons')
      )
    end
  end
end
