require 'ass_lists_config.rb'
module WiceAssignmentLists
  
  def self.deprecated_call(old_name, new_name, opts) #:nodoc:
    if opts[old_name] && ! opts[new_name]
      opts[new_name] = opts[old_name]
      opts.delete(old_name)
      puts "WiceGrid: Parameter :#{old_name} is deprecated, use :#{new_name} instead!"
    end      
  end
  
  
  module AssignmentListsGlobalBlockTable   #:nodoc:    
    @@table = HashWithIndifferentAccess.new
    
    def self.[](k)
      @@table[k]
    end
    
    def self.[]=(k, v)
      @@table[k] = v
    end
    
  end
  
  module Controller

    def self.included(base)   #:nodoc:
      base.extend(ClassMethods)
    end
  
    module ClassMethods
    
    
      # Controller class method to setup filtering. The method either takes a block or a method name to filter objects.
      # See README for code examples.
      #
      # 
      # * +name+ is the name of the widget.
      # Attributes:      
      # * <tt>:method_to_retrieve_object_name</tt> - Method which will be called for every object in a list to retrieve
      #   a label for the item.
      # * <tt>:method_name</tt> - Name of the method which will be called for every AJAX call from the filter field. Using a method
      #   and a block for filtering are mutually exclusive. 
      def assignment_lists_filter(assignment_lists_name, opts = {}, &block)

        options = {
          :method_to_retrieve_object_id => :id, 
          :method_to_retrieve_object_name => :name
        }

        WiceAssignmentLists.deprecated_call(:active_record_method_to_retrieve_object_id, :method_to_retrieve_object_id, opts)
        WiceAssignmentLists.deprecated_call(:active_record_method_to_retrieve_object_name, :method_to_retrieve_object_name, opts)
        
        options.merge!(opts)
        method_name = options[:method_name]
               
        exclude_param_name = assignment_lists_name.to_s + '_exclude'
        search_param_name = assignment_lists_name.to_s + '_search'
        controller_wrapper_method_name = 'filter_' + assignment_lists_name.to_s

        if block_given? and method_name
          raise ::ArgumentError.new("assignment_lists_filter: cannot take a block and a method name at the same time")
        end

        if method_name.nil? and not block_given?
          raise ArgumentError.new("assignment_lists_filter: specify either a method name returning object, or a block")
        end

        code_for_eval = <<"END_OF_STATEMENT"
          def #{controller_wrapper_method_name}
            to_exclude = params[:#{exclude_param_name}].split(',').collect{|i| i.to_i}
END_OF_STATEMENT

        if block_given?
          
          #logger.debug('+++' + self.to_s)          
          
          AssignmentListsGlobalBlockTable[assignment_lists_name] = block

          code_for_eval += <<"END_OF_STATEMENT"

              list = AssignmentListsGlobalBlockTable[:#{assignment_lists_name}].call(params[:#{search_param_name}])
END_OF_STATEMENT

        else

          code_for_eval += <<"END_OF_STATEMENT"
              list = #{method_name}(params[:#{search_param_name}])
END_OF_STATEMENT

        end

        code_for_eval += <<"END_OF_STATEMENT"
          render :text => list.reject{|p| to_exclude.index(p.id)}.collect{|ed| [ed.#{options[:method_to_retrieve_object_id]}, ed.#{options[:method_to_retrieve_object_name]}]}.to_json
        end
END_OF_STATEMENT


        # logger.debug("generated code\n" + code_for_eval)
        self.class_eval code_for_eval    
      end
    end
  end
  
  module Helper

    # overriding Rails options_for_select to get title="..."
    def options_for_select(container, selected = nil)   #:nodoc:
      container = container.to_a if Hash === container

      options_for_select = container.inject([]) do |options, element|
        text, value = option_text_and_value(element)
        escaped_text = html_escape(text.to_s)        
        selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
        options << %(<option title="#{escaped_text}" value="#{html_escape(value.to_s)}"#{selected_attribute}>#{escaped_text}</option>)
      end

      options_for_select.join("\n")
    end
    

    def search_control(name, js_update_function_name, js_handler_variable_name, options)   #:nodoc:
      return '' if options[:filter_on].blank?
      
      filter_action_name = 'filter_' + name
      exclude_parameter = name + '_exclude'
      search_parameter = name + '_search'
      filter_field_name = name + '_filter'
      context_parameters_string = context_parameters(options)
      
      text_field_tag(filter_field_name, '', :id => filter_field_name, 
        :class => 'wal_filter',
        :autocomplete => "off",
        :style => "width: #{options[:left_column_width] - 20 }px;") +
      
      observe_field(filter_field_name,
        :frequency => 0.5,
        :success => js_update_function_name + '(request.responseText)',
        :url => {:action => filter_action_name, :only_path => false},
        :with => "'#{exclude_parameter}=' + #{js_handler_variable_name}.values() + '&#{search_parameter}=' + encodeURIComponent(value)" +
          context_parameters_string,
        :before   => "$('#{filter_field_name}').className='wal_filter wal_filter_spinner'",
        :complete   => "$('#{filter_field_name}').className='wal_filter'" 
        
      ) 
    end
    
    def insert_update_function(js_update_function_name, js_handler_variable_name)   #:nodoc:
      "\n<script type=\"text/javascript\">
      //<![CDATA[
        function #{js_update_function_name}(json_code){
          #{js_handler_variable_name}.repopulateListFromJSON(json_code);
        }
        image = new Image();
        image.src = \"#{WiceAssignmentLists::Defaults::SPINNER_IMAGE_NAME}\";
        //]]>
        </script>\n"  #the two last lines are for preloading the spinner image.
    end
       
    def context_parameters(options)   #:nodoc:
      if options[:context_parameters].blank?
        ''
      else
        ' + \'&' + options[:context_parameters].to_query + "'"
      end
    end
    
    def remove_button(js_handler_variable_name, options)   #:nodoc:
      button_to_function(options[:remove_button_label], "#{js_handler_variable_name}.moveElementBetweenLists(1)")
    end

    def add_button(js_handler_variable_name, options)   #:nodoc:
      button_to_function(options[:add_button_label], "#{js_handler_variable_name}.moveElementBetweenLists(0)")
    end

    def insert_initialization_of_js_handler(js_handler_variable_name, dom_id1, dom_id2, name)   #:nodoc:
      "\n<script type=\"text/javascript\">
      //<![CDATA[
        var #{js_handler_variable_name} = new AssignmentLists('#{dom_id1}', '#{dom_id2}', '#{name}' );
        Event.observe(window, 'load', function() { #{js_handler_variable_name}.updateHiddenField(); });
      //]]>
      </script>\n"
    end
    
    
    # Creates an assignment lists widget. See README for examples of code.
    #
    # * +name+ is the name of the widget and also the name of the HTTP parameter which will be sent from the form. 
    # * +all_elements_list+ is a complete list of items.
    # * <tt>list2</tt> is a list of items to be displayed in the right column (a subset of +all_elements_list+ is expected)  
    # Attributes:
    # * <tt>:label1</tt> - Name of the left list.
    # * <tt>:label2</tt> - Name of the right list.
    # * <tt>:method_to_retrieve_object_name</tt> - Method which will be called for every object in a list to retrieve
    # a label for the item.
    # * <tt>:left_column_width</tt> - Width of the right column in pixels. The default value can be changed in <tt>lib/ass_lists_config.rb</tt>.
    # * <tt>:right_column_width</tt> - Width of the right column in pixels. The default value can be changed in <tt>lib/ass_lists_config.rb</tt>.
    # * <tt>:rows_to_show</tt> - Number of rows to show in a list. The default value (10) can be changed in <tt>lib/ass_lists_config.rb</tt>.
    # * <tt>:add_button_label</tt> - The label on a button which moves items from the left list to the right list. 
    #   The default value can be changed in <tt>lib/ass_lists_config.rb</tt>.
    # * <tt>:remove_button_label</tt> - The label on a button which moves items from the right list to the left list. 
    #   The default value can be changed in <tt>lib/ass_lists_config.rb</tt>.
    # * <tt>:filter_on</tt> - Defines whether the filter field is present or not.
    # * <tt>:context_parameters</tt> - A hash of HTTP parameters to be sent together with the AJAX request of the filter field.

    def assignment_lists(name, all_elements_list, list2, opts = {})

      options = {:left_column_width    => WiceAssignmentLists::Defaults::LEFT_COLUMN_WIDTH,
                 :right_column_width   => WiceAssignmentLists::Defaults::RIGHT_COLUMN_WIDTH,
                 :rows_to_show         => WiceAssignmentLists::Defaults::ROWS_TO_SHOW,
                 :add_button_label     => WiceAssignmentLists::Defaults::ADD_BUTTON_LABEL,
                 :remove_button_label  => WiceAssignmentLists::Defaults::REMOVE_BUTTON_LABEL,
                 :spinner_image_name   => WiceAssignmentLists::Defaults::SPINNER_IMAGE_NAME,
                 :method_to_retrieve_object_name => :name,
                 :label1               => '',
                 :label2               => '',
                 :filter_on            => true,
                 :context_parameters => {} }
                 
      WiceAssignmentLists.deprecated_call(:active_record_method_to_retrieve_object_name, :method_to_retrieve_object_name, opts)                 

      options.merge!(opts)
      name = name.to_s

      list1 = all_elements_list - list2

      list1 = options_from_collection_for_select(list1, :id, options[:method_to_retrieve_object_name])
      list2 = options_from_collection_for_select(list2, :id, options[:method_to_retrieve_object_name])

      dom_id1 = name + '_id1'
      dom_id2 = name + '_id2'

      js_handler_variable_name = 'handler_' + name
      search_control_content = ''
      update_function_content = ''
      
      if options[:filter_on]
        js_update_function_name = name + '_update'
        extra_row = 1
        
        search_control_content = search_control(name, js_update_function_name, js_handler_variable_name, options)
        update_function_content = insert_update_function(js_update_function_name, js_handler_variable_name)
      else
        extra_row = 0
      end
      
      # and here goes the mess
      update_function_content + '<table><tr><td style="text-align: center;" >' + options[:label1]  +
      %!</td><td></td><td style="text-align: center;" >#{options[:label2]}</td></tr><tr>! +
      %!<td style="vertical-align: top; text-align: left; width: #{options[:left_column_width]}px;">\n! +
      search_control_content +
      %!<select multiple="multiple" style="width: #{options[:left_column_width]}px;" id="#{dom_id1}"!  + 
      %!name="#{dom_id1}" size="#{options[:rows_to_show]}">#{list1}!  +
      '</select></td><td style="width:100px; vertical-align: top; text-align: center;" ><p>' +
      remove_button(js_handler_variable_name, options) + '</p><p>' + add_button(js_handler_variable_name, options) +
      %!</p></td><td style="vertical-align: top; text-align: center; width:#{options[:right_column_width]}px;" >! + 
      %!<select multiple="multiple" style="width: #{options[:right_column_width]}px;"  id="#{dom_id2}" ! +
      %!name="#{dom_id2}" size="#{options[:rows_to_show] + extra_row}">! +
      "#{list2}</select></td></tr></table>" + 
      insert_initialization_of_js_handler(js_handler_variable_name, dom_id1, dom_id2, name) 
    end      
  end
end