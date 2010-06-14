# Include hook code here
require 'assignment_lists.rb'

ActionView::Base.class_eval { include ::AssignmentLists::Helper }
ActionController::Base.send(:include, ::AssignmentLists::Controller)
