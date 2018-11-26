
module Android
  module TouchHelpers


    def click_button(val)
      $driver.button(val).click
    end

    def click_on(locator)
      if locator.is_a? String
        scroll_text_to_view(locator, :down)
        sleep 1
        element = find_text(locator)
      elsif locator[:text] || locator[:marked]
        text = locator.values.first
        scroll_text_to_view(text, :down)
        sleep 1
        element = find_text(text)
      else
        element = $driver.wait_true(Android::WaitHelpers::DEFAULT_OPTS[:timeout]) {find(locator)}
      end
      element.click

    end


    def tap_mark(mark, *args)
      Appium::TouchAction.new($driver).single_tap(element).perform
    end


    def double_tap(locator)

      if wait_for {$driver.find_element(locator).enabled?}
        Appium::TouchAction.new($driver).double_tap(locator).perform
      end

    end

    def long_press(locator)

      if wait_for {$driver.find_element(locator).enabled?}
        Appium::TouchAction.new($driver).long_press(locator).perform
      end

    end

    def drag()

      $driver.touch_action.down(element).move_to(10, 100).up(50, 50).perform

    end

    def press_back_button

      $driver.press_keycode(4)

    end

    def press_menu_button
      $driver.press_keycode(82)
    end

    def press_app_switch_button
      $driver.press_keycode(187)
    end

    def press_home_button
      $driver.press_keycode(3)
    end

    def flick(*args)

      Appium::TouchAction.new($driver).swipe(start_x: (width / 2).to_int, start_y: (height / 4).to_int, end_x: (width / 2).to_int, end_y: height - 100).perform

    end

    def move_element_left(options={})
      $driver.touch_action.down(element).move().perform
    end

    def move_element_right(options={})
      $driver.touch_action.down(element).move().perform
    end

    def move_element_up(x_val,y_val)
      $driver.touch_action.up(element).move(x_val,y_val).perform
    end

    def move_element_down(x_val,y_val)
      $driver.touch_action.down(element).move(x_val,y_val).perform
    end

    def move_element_up_to(x_val,y_val)
      $driver.touch_action.up(element).move(x_val,y_val).perform
    end

    def move_element_down_to(x_val,y_val)
      $driver.touch_action.down(element).move(x_val,y_val).perform
    end

    def pinch_out(options={})
      pinch("* id:'content'", :out, options)
    end

    def pinch_in(options={})
      pinch("* id:'content'", :in, options)
    end

    def pinch(query_string, direction, options={})
      execute_gesture(Gesture.with_parameters(Gesture.pinch(direction, options), {query_string: query_string}.merge(options)))
    end

    def find_coordinate(uiquery, options={})
      log_error "Cannot find nil" unless uiquery

      element = execute_uiquery(uiquery)

      log_error "No elements found. Query: #{uiquery}" if element.nil?

      x = element["rect"]["center_x"]
      y = element["rect"]["center_y"]

      if options[:offset]
        x += options[:offset][:x] || 0
        y += options[:offset][:y] || 0
      end

      [x, y]
    end

    def tap_when_element_exists(locator, options={})
      if locator.is_a? String
        element = get_element_by_text(locator)

      else
        element = $driver.wait_true(Android::WaitHelpers::DEFAULT_OPTS[:timeout]) {self.find(locator)}
      end
      element.click
    end

    def long_press_when_element_exists(query_string, options={})

    end


    def scroll_down_to(element={},x,y)
      Appium::TouchAction.new($driver.scroll(element, x, y).perform)
    end

    def scroll_up_to(locator,x,y)
      Appium::TouchAction.new($driver.scroll(locator, x, y).perform)
    end

    def fast_scroll_up
      sleep 2
      size = $driver.driver.manage.window.size
      height = size.height
      width = size.width
      Appium::TouchAction.new($driver).swipe(start_x: (width / 2).to_int, start_y: (height / 4).to_int, end_x: (width / 2).to_int, end_y: height - 100).perform
    end

    def scroll_up

      scroll(:up)

    end

    def scroll_down

      scroll(:down)

    end

    def scroll(direction)
      sleep 2
      size = $driver.driver.manage.window.size
      height = size.height
      width = size.width
      if direction != :up && direction != :down && direction != :left && direction != :right
        log_error 'Only upwards and downwards left right scrolling is supported for now'
      end

      if direction == :up
        Appium::TouchAction.new($driver).swipe(start_x: (width / 2).to_int, start_y: (height / 4).to_int, end_x: (width / 2).to_int, end_y: (height/2) - 100).perform
      elsif direction == :down
        Appium::TouchAction.new($driver).swipe(start_x: (width / 2).to_int, start_y: (height / 4).to_int, end_x: (width / 2).to_int, end_y: 100).perform
      elsif direction == :left
        Appium::TouchAction.new($driver).swipe(start_x: (width - 600).to_int, start_y: (height / 2).to_int, end_x: (width/2).to_int, end_y: height / 2).perform
      elsif direction == :right
        Appium::TouchAction.new($driver).swipe(start_x: 752, start_y: (height / 2).to_int, end_x: (width - 600).to_int, end_y: height / 2).perform
      end


    end

    def scroll_element_to_view(item,direction)

      wait_poll(timeout_message: "Unable to find '#{item}'",
                retry_frequency: 0.5,
                until_exists: item) do

        scroll(direction)
        log_debug "drag element to view"

      end

      nav = $driver.find_element(id:'bottom_navigation_view').rect
      nav_y = nav.y

      wait_poll(timeout_message: "Unable to find '#{item}'",
                retry_frequency: 0.5,
                until: lambda { (nav_y - 250)  >= get_element_location(item).y }) do

        scroll(direction)
        log_debug "drag above nav"

      end

      log_info "found element >>>>> #{item}"

    end

    def scroll_text_to_view(item, direction)

      wait_poll(timeout: 60,
                timeout_message: "Unable to find '#{item}'",
                retry_frequency: 1,
                until: lambda {has_text?(item)}) do

        scroll(direction)
        log_debug "drag element #{direction} to view"

      end

    end

    def get_element_location(locator)
      if locator.is_a? String
        find_elem
      end
      $driver.find_element(locator).rect

    end

    def scroll_down_click_on_text(text)

      scroll_text_to_view(text,:down)
      sleep 2
      click_element_by_text(text)

    end


    def swipe_element(locator, direction)

      element = find(locator).rect
      start_x = element.x
      start_y = element.y
      end_x = (element.width + start_x)
      end_y = (element.height + start_y)
      mid_x = (start_x + end_x)/2
      mid_y = (start_y + end_y)/2


      if direction == :up
        Appium::TouchAction.new($driver).swipe(start_x: (mid_x), start_y: (mid_y), end_x: mid_x, end_y: mid_y+(mid_y/4)).perform

      elsif direction == :down

        Appium::TouchAction.new($driver).swipe(start_x: (mid_x), start_y: mid_y+(mid_y/4), end_x: mid_x, end_y: mid_y).perform

      elsif direction == :left

        Appium::TouchAction.new($driver).swipe(start_x: start_x + (mid_y/6), start_y: mid_y, end_x: mid_x-(mid_x/4), end_y: mid_y).perform

      elsif direction == :right
        Appium::TouchAction.new($driver).swipe(start_x: mid_x, start_y: mid_y, end_x: mid_x+(mid_x/4), end_y: mid_y).perform

      end

    end

    def scroll_to_beginning(step=15)
      sleep 2
      begin
        $driver.find_element(:uiautomator, "new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollToBeginning(#{step});")
      rescue UiObjectNotFoundException => e
        p "#{e}: rescure here"
      end

    end


    def scroll_down_webview_to_text(text)

      $driver.find_element(:uiautomator, "new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollIntoView(new UiSelector().descriptionContains(\"#{text}\").instance(0));")

    end

    def tappium(coordinate = [0.50, 0.50], count = 1)
      Appium::TouchAction.new.tap(x: coordinate[0], y: coordinate[0], count: count)
    end

    # Runs the appium press action. wip
    # Params:
    # +destination+:: point value indicate press location.
    #
    def pressium(destination)
      x = destination[0]
      y = destination[1]

      action = Appium::TouchAction.new
      action.press(x: x, y: y).wait(5).release.perform
    end

    # Puts the elements location into a point array of [x,y]. Useful in above methods.
    # Params:
    # +element+:: An element on the screen in obj form.
    #
    def capture_destination(element)
      x = element.location.x
      y = element.location.y
      [x, y]
    end

    def click_alert_button(val)
      $driver.alert_click(val)
    end

    def close_alert
      $driver.alert_dismiss
    end
  end
end