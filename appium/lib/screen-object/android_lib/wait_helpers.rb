
module Android
  module WaitHelpers
    class WaitError < RuntimeError
    end

    def wait_poll(opts,&block)
      test = opts[:until]
      if test.nil?
        cond = opts[:until_exists]
        raise "Must provide :until or :until_exists" unless cond

        test = lambda {element_exists(cond)}

      end
      wait_for(opts) do
        if test.call
          true
        else
          yield
          false
        end
      end

    end



    def wait_for(options_or_timeout=$appium_timeout, &block)
      #note Hash is preferred, number acceptable for backwards compat
      default_timeout = $appium_timeout[:timeout]
      timeout = options_or_timeout || default_timeout
      post_timeout = $appium_timeout[:post_timeout]
      retry_frequency = $appium_timeout[:retry_frequency]
      timeout_message = $appium_timeout[:timeout_message]
      screenshot_on_error = $appium_timeout[:screenshot_on_error]

      if options_or_timeout.is_a?(Hash)
        timeout = options_or_timeout[:timeout] || default_timeout
        retry_frequency = options_or_timeout[:retry_frequency] || retry_frequency
        post_timeout = options_or_timeout[:post_timeout] || post_timeout
        timeout_message = options_or_timeout[:timeout_message]
        if options_or_timeout.key?(:screenshot_on_error)
          screenshot_on_error = options_or_timeout[:screenshot_on_error]
        end
      end

      begin
        Timeout::timeout(timeout, WaitError) do
          sleep(retry_frequency) until yield
        end
        sleep(post_timeout) if post_timeout > 0
      rescue WaitError => e
        msg = timeout_message || e
        if screenshot_on_error
          sleep(retry_frequency)
          return screenshot_and_retry(msg, &block)
        else
          raise wait_error(msg)
        end
      rescue => e
        handle_error_with_options(e, nil, screenshot_on_error)
      end
    end

    def handle_error_with_options(ex, timeout_message, screenshot_on_error)
      error_class = (ex && ex.class) || RuntimeError
      error = error_class.new(timeout_message || ex.message)

      if screenshot_on_error
        screenshot_and_raise error
      else
        log_error(timeout_message || ex.message)
      end
    end

    def element_exists(locator)
      $driver.find_element(locator)
      true
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def elements_exists(locator)
      $driver.find_elements(locator)
      true
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def element_does_not_exist(locator)
      !element_exists(locator)
    end

    def screenshot_and_retry(msg, &block)
      path  = screenshot
      res = yield
      # Validate after taking screenshot
      if res
        FileUtils.rm_f(path)
        return res
      else
        embed(path, 'image/png', msg)
        raise wait_error(msg)
      end
    end


    def wait(seconds = $appium_timeout[:timeout])
      $driver.set_implicit_wait seconds
      yield
      $driver.set_implicit_wait 15
    end

    #options for wait_for apply
    def wait_for_element_exists(locator)
      if locator[:marked] || locator[:text]
        wait_for_text(locator.values.first)
      else
        begin
          $driver.wait_true($appium_timeout[:timeout]){element_exists(locator)}
        rescue RuntimeError => e
          raise("finds element #{locator}: #{e} for #{$appium_timeout[:timeout]} seconds")
        end
      end

    end



    #options for wait_for apply
    def wait_for_element_does_not_exist(locator)
      sleep 1
      begin
        $driver.wait_true($appium_timeout[:timeout]){not element_exists(locator)}
        true
      rescue RuntimeError => e
        raise("finds element #{locator}: #{e} for #{$appium_timeout[:timeout]} seconds")
      end
    end

    #options for wait_for apply
    def wait_for_elements_do_not_exist(elements_arr, options={})
      if elements_arr.is_a?(String)
        elements_arr = [elements_arr]
      end
      options[:timeout_message] = options[:timeout_message] || "Timeout waiting for no elements matching: #{elements_arr})}"
      wait_for(options) do
        elements_arr.none? { |q| element_exists(q) }
      end
    end


    def wait_error(msg)
      (msg.is_a?(String) ? WaitError.new(msg) : msg)
    end


    def until_element_exists(uiquery, opts = {})
      sleep 1
      wait_for(timeout: $appium_timeout[:timeout],
               timeout_message: "text #{text} is visible") do
        not element_exists(uiquery)
      end
      log_debug "element #{uiquery} not visible"
    end


    def until_element_does_not_exist(uiquery)
      sleep 1
      wait_for(timeout: $appium_timeout[:timeout],
               timeout_message: "text #{uiquery} is visible") do
        not element_exists(uiquery)
      end
      log_debug "element #{uiquery} not visible"
      true
    end



    def wait_for_text(text)

      sleep 1
      wait_for(timeout: $appium_timeout[:timeout],
               timeout_message: "text #{text} is visible") do
        assert_text(text)
      end
      log_debug "#{text} visible"

    end

    def wait_for_contains_text(text)
      begin
        $driver.complex_find_contains("*","?")
        log_info "#{text} is visible"
      rescue ElementNotFoundError => e
        log_error("Unable to find #{text}\n error details: #{e} ")
      end
    end

    def wait_until_text_disappears(text)
      sleep 1
      wait_for(timeout_message: "text #{text} is visible") do

       lambda {not has_text?(text)}

      end
      log_debug "#{text} not visible"
    end

    def wait_for_activity(activity_name, options={})
      wait_for(options) do
        perform_action('get_activity_name')['message'] == activity_name
      end
    end
  end
end
