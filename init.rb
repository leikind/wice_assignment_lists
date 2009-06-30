# Include hook code here


require 'wice_assignment_lists.rb'

#ActionController::Base.send(:helper, ::WiceAssignmentLists::Helper)
#ApplicationHelper.send(:include, ::WiceAssignmentLists::Helper)
ActionView::Base.class_eval { include ::WiceAssignmentLists::Helper }

ActionController::Base.send(:include, ::WiceAssignmentLists::Controller)
