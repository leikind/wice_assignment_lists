if defined?(AssignmentLists::Defaults)

  # AssignmentLists::Defaults::JS_FRAMEWORK = <%= inactive_js_framework %>
  AssignmentLists::Defaults::JS_FRAMEWORK = <%= active_js_framework %>

  # The label on a button which moves items from the left list to the right list.
  AssignmentLists::Defaults::ADD_BUTTON_LABEL    = ' &gt;&gt; '

  # The label on a button which moves items from the right list to the left list.
  AssignmentLists::Defaults::REMOVE_BUTTON_LABEL = ' &lt;&lt; '

  # Path to the spinner image. Make sure to change it in the css, here it is used only for preloading the image with javascript.
  AssignmentLists::Defaults::SPINNER_IMAGE_NAME  = '/images/icons/wal_spinner.gif'

  # Width of the left column in pixels
  AssignmentLists::Defaults::LEFT_COLUMN_WIDTH   = 150

  # Width of the right column in pixels    
  AssignmentLists::Defaults::RIGHT_COLUMN_WIDTH  = 150

  # Number of rows to show in a list
  AssignmentLists::Defaults::ROWS_TO_SHOW        =  10
end