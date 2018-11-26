require_relative 'wait_helpers'
require_relative 'locatorhelpers'
require 'rspec/expectations'

module Android
  module TextHelpers
    include Android::WaitHelpers
    include Appium::Android::Uiautomator2::Helper
    include LocatorHelpers
    include RSpec::Expectations
    include RSpec::Matchers
    module_function



    def has_text?(text)

      begin

        $driver.find_element(:uiautomator, "new UiSelector().text(\"#{text}\")")
        true

      rescue Selenium::WebDriver::Error::NoSuchElementError
        false
      end
    end

    def find_text(text)

      begin

        if ENV['PLATFORM_NAME'].include?('ios')

          $driver.find_element(:name,text)
        else

          $driver.find_element(:uiautomator, "new UiSelector().text(\"#{text}\")")
        end
      rescue Appium::Core::Wait::TimeoutError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def find_text_contains(value)

      begin
        $driver.find_element(:uiautomator, "new UiSelector().textContains(\"#{value}\")")
      rescue RuntimeError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def find_text_matches(regex)

      begin
        $driver.find_element(:uiautomator, "new UiSelector().textMatches(\"#{regex}\")")
      rescue RuntimeError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def find_text_start_with(string_val)

      begin
        $driver.find_element(:uiautomator, "new UiSelector().textStartsWith(\"#{string_val}\")")
      rescue RuntimeError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def get_header_text
      e = $driver.find_element(:uiautomator, "new UiSelector().resourceId(\"com.massmutual.android.RetireSmart:id\/toolbar\").childSelector(new UiSelector().className(\"android.widget.TextView\"))").text;
    end

    def get_all_element_text_children(uialocator)

      $driver.find_element(:uiautomator, "new UiSelector().resourceId(\"com.massmutual.android.RetireSmart:id\/toolbar\").childSelector(new UiSelector().className(\"android.widget.TextView\"))")
    end

    def get_element_by_text(text_val)
      $driver.complex_find_contains("*","#{text_val}")
    end


    def click_element_by_text(text)

      if text.is_a? Hash
        val = text.values.first
      else
        val = text
      end

      begin
        element = $driver.find_element(:uiautomator, "new UiSelector().text(\"#{val}\")")
        element.click
      rescue Appium::Core::Wait::TimeoutError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def clear(locator)
      find(locator).clear
    end

    def set_text(locator, input)
      if $driver.device_is_ios?
        find(locator).type input
      else
        find(locator).send_keys input
      end

    end

    def set_text_by_index(index, input)

      begin
        element = $driver.find_element(:uiautomator, "new UiSelector().className(\"android.widget.EditText\").enabled(true).instance(#{index});")
        element.send_keys input
      rescue Appium::Core::Wait::TimeoutError => e
        log_error("Could not find text field \"#{index}\" on the current screen: #{e}")
      end

    end

    def assert_text(text, should_find = true)
      log_error "Text \"#{text}\" was #{should_find ? 'not ' : ''}found." if has_text?(text) ^ should_find

      true
    end

    def get_text(locator)
      $driver.find_element(locator).text
    end

    def keyboard_enter_text(text, options = {})
      wait_for_keyboard
      perform_action('keyboard_enter_text', text)
    end

    def keyboard_enter_char(character, options = {})
      keyboard_enter_text(character[0,1], options)
    end

    # Appends `text` into the first view matching `uiquery`.
    def enter_text(locator, text)
      element = find(locator)
      if element.enabled?

        element.send_keys text

      end
    end

    def clear_text_in(query_string)
      find(query_string).clear

    end

    # Clears the text of the currently focused view.
    def clear_text(query_string)
      find(query_string).clear
    end

    def clear_text_by_index(index)
      begin
        $driver.find_element(:uiautomator, "UiSelector().className(\"android.widget.EditText\").enabled(true).instance(0);").clear
      rescue RuntimeError => e
        log_error("Could not find textfield with index \"#{index}\" on the current screen: #{e}")
      end
    end

    def escape_backslashes(str)
      backslash = "\\"
      str.gsub(backslash, backslash*4)
    end

    def escape_newlines(str)
      newline = "\n"
      str.gsub(newline, "\\n")
    end

    def escape_quotes(str)
      str.gsub("'", "\\\\'")
    end

    def escape_string(str)
      escape_newlines(escape_quotes(escape_backslashes(str)))
    end

    # Sets the selection of the currently focused view.
    #
    # @param [Integer] selection_start The start of the selection, can be
    #  negative to begin counting from the end of the string.
    # @param [Integer] selection_end The end of the selection, can be
    #  negative to begin counting from the end of the string.
    def set_selection(selection_start, selection_end)
      perform_action("set_selection", selection_start, selection_end)
    end

    def keyboard_visible?

      if @driver.is_keyboard_shown == "true"
        true
      elsif @driver.is_keyboard_shown == "false"
        false
      else
        log_error "Could not detect keyboard visibility. '#{@driver.is_keyboard_shown}'"
      end
    end

    def wait_for_keyboard(opt={})
      params = opt.clone
      params[:timeout_message] ||= "Timed out waiting for the keyboard to appear"
      params[:timeout] ||= 5

      wait_for(params) do
        keyboard_visible?
      end
    end

    def hide_keyboard
      @driver.hide_keyboard
    end

    def validate_phone_number_format(num_str, country)

      case country

      when "usa"

        if /\(?[0-9]{3}\)?-[0-9]{3}-[0-9]{4}/.match(num_str).nil?
          log_error("invalid format")
        else
          log_info("number format #{num_str} is xxx-xxx-xxxx")
        end

      else

        log_error("country #{country} is invalid")

      end

    end

    def format_number(number)

      result = '%.2f' % number
      result.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

    end

    def get_scenario_tags(scenario)
      @eyes_current_tags = {}
      eyes_tag_name_regexp = /@eyes_(?<tag_name>[a-z,A-Z, \_]+) \"(?<value>.*)\"/
      scenario.tags.each do |t|
        match_data = t.name.match eyes_tag_name_regexp
        @eyes_current_tags[match_data[:tag_name].to_sym] = match_data[:value] if match_data
      end
    end

    def rs_app_random_number(from_num,to_num)
      p DataMagic.randomize(from_num..to_num)

    end

    def rs_app_return_random_digits(num_digits)
      (num_digits.to_i).times.map { rand(1..9) }.join.to_i
    end

    def strip_trailing_zero(n)

      n.to_s.sub(/\.?0+$/, '')

    end

    def rs_app_get_digits_from_string(str_val)

      /\d+/.match(str_val)[0]

    end

    def is_amount_percent?(str_val)

      /\d+[%]/.match(str_val.to_f)[0]

    end

    def is_letter?(str_val)

      str_val =~ /[a-zA-Z0-9\s]+/

    end

    def is_numeric?(str_val)

      str_val =~ /[[:digit:]]/

    end

    def current_time_text
      time = Time.now.getutc + Time.zone_offset('EST')
      "#{(time).strftime("%d %B %Y - %I:%M:%S %p")}  (i.e. #{time})"
    end

    def validate_element_text(element_text, expected)

      begin
        actual_text = element_text
        find_value = actual_text.gsub(/[[:space:]]+/, ' ').strip
        expected_value = expected
        message = "\n Expected: #{expected_value}  \n Found:    #{find_value}\n"
        (expect(find_value).to eq(expected_value)) ? log_info(message) : log_error(message)
      rescue Selenium::WebDriver::Error::NoSuchElementError => e
        log_error "Element #{expected_value} not found on screen"
      end


    end

    def find_webview_text(value)

      begin
        $driver.string_visible_exact('*',value)
        log_info "text #{value} is visible"
      rescue Appium::Core::Wait::TimeoutError => e
        log_error("Could not find text \"#{value}\" on the current screen: #{e}")
      end

    end

    def validate_pop_up_error_msg_box(expected_title, expected_msg)

      wait_for_element_exists({:id=> 'android:id/button1'})
      validate_element_text({:id =>'android:id/message'}, expected_msg) unless expected_msg == ""
      validate_element_text({:id =>'android:id/alertTitle'}, expected_title) unless expected_title == ""
      click_on :id=> 'android:id/button1'
      sleep 1

    end

  end
end


