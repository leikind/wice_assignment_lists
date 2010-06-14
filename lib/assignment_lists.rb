module AssignmentLists

  module Defaults
  end

  module Controller

    # Controller method to setup filtering. To be used inside a filter method.
    # The method takes a block which is expected to return a list of
    # found objects, and renders the response in the correct format.
    # The parameter of the block is the search string.
    #
    # The argument is the name of the view widget (first argument to +assignment_lists+)
    # Example:
    #   def filter
    #     assignment_lists_filter(:users) do |str|
    #       User.find(:all, :conditions => ['name LIKE ?', "%" + str + "%"])
    #     end
    #   end
    def assignment_lists_filter(name)
      list = yield params["#{name}_search"]
      to_exclude = params["#{name}_exclude"].split(',').map(&:to_i)
      render :json => list.reject{|p| to_exclude.index(p.id)}.collect{|ed|
         [ed.id, ed.name]
       }.to_json
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
      return '' if options[:filter_path].blank?

      exclude_parameter = name + '_exclude'
      search_parameter = name + '_search'
      filter_field_name = name + '_filter'
      context_parameters_string = context_parameters(options)

      observer_options = {
        :frequency => 0.5,
        :url => options[:filter_path],
        :with => "'#{exclude_parameter}=' + #{js_handler_variable_name}.values() + '&#{search_parameter}=' + encodeURIComponent(value)" + context_parameters_string,
      }

      observer_options.merge!(if AssignmentLists::Defaults::JS_FRAMEWORK == :jquery
        {
          :success => "#{js_handler_variable_name}.repopulateListFromJSON(request)",
          :datatype => 'json',
          :before   => "$('##{filter_field_name}').addClass('wal_filter wal_filter_spinner')",
          :complete   => "$('##{filter_field_name}').removeClass('wal_filter_spinner')"
        }
      else
        {
          :success => "#{js_handler_variable_name}.repopulateListFromJSON(request.responseJSON)",
          :before   => "$('#{filter_field_name}').className='wal_filter wal_filter_spinner'",
          :complete   => "$('#{filter_field_name}').className='wal_filter'"
        }
      end)

      text_field_tag(filter_field_name, '', :id => filter_field_name,
        :class => 'wal_filter',
        :autocomplete => "off",
        :style => "width: #{options[:left_column_width] - 20 }px;") +
      observe_field(filter_field_name, observer_options)
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
      javascript_tag(
        if AssignmentLists::Defaults::JS_FRAMEWORK == :jquery
          %`$(document).ready(function(){\n` +
          %`  #{js_handler_variable_name} = new AssignmentLists('#{dom_id1}', '#{dom_id2}', '#{name}');\n` +
          %`  #{js_handler_variable_name}.updateHiddenField();\n`
        else
          %`Event.observe(window, 'load', function() {\n` +
          %`  #{js_handler_variable_name} = new AssignmentLists('#{dom_id1}', '#{dom_id2}', '#{name}' );\n` +
          %`  #{js_handler_variable_name}.updateHiddenField();\n`
        end +
        %`  image = new Image();\n` +
        %`  image.src = "#{AssignmentLists::Defaults::SPINNER_IMAGE_NAME}";\n` +
        %`})`)
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
    # * <tt>:filter_path</tt> - The path for the Ajax request to post to. If absent, no filter field is rendered.
    # * <tt>:context_parameters</tt> - A hash of HTTP parameters to be sent together with the AJAX request of the filter field.

    def assignment_lists(name, all_elements_list, list2, opts = {})

      options = {:left_column_width    => AssignmentLists::Defaults::LEFT_COLUMN_WIDTH,
                 :right_column_width   => AssignmentLists::Defaults::RIGHT_COLUMN_WIDTH,
                 :rows_to_show         => AssignmentLists::Defaults::ROWS_TO_SHOW,
                 :add_button_label     => AssignmentLists::Defaults::ADD_BUTTON_LABEL,
                 :remove_button_label  => AssignmentLists::Defaults::REMOVE_BUTTON_LABEL,
                 :spinner_image_name   => AssignmentLists::Defaults::SPINNER_IMAGE_NAME,
                 :method_to_retrieve_object_name => :name,
                 :label1               => '',
                 :label2               => '',
                 :filter_path   => nil,
                 :context_parameters => {} }

      options.merge!(opts)


      name = name.to_s

      list1 = all_elements_list - list2

      list1 = options_from_collection_for_select(list1, :id, options[:method_to_retrieve_object_name])
      list2 = options_from_collection_for_select(list2, :id, options[:method_to_retrieve_object_name])

      dom_id1 = name + '_id1'
      dom_id2 = name + '_id2'

      js_handler_variable_name = 'handler_' + name
      search_control_content = ''

      if options[:filter_path]
        js_update_function_name = name + '_update'
        extra_row = 1

        search_control_content = search_control(name, js_update_function_name, js_handler_variable_name, options)
      else
        extra_row = 0
      end

      # and here goes the mess
      res = '<table><tr><td style="text-align: center;" >' + options[:label1]  +
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

      res.respond_to?(:html_safe) ? res.html_safe : res

    end
  end
end