# Include hook code here
require 'wice_assignment_lists.rb'

ActionView::Base.class_eval { include ::WiceAssignmentLists::Helper }
ActionController::Base.send(:include, ::WiceAssignmentLists::Controller)
