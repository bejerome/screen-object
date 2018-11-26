require 'appium_lib'
require 'rspec/expectations'

module Android
  module LocatorHelpers

    #options for wait_for apply
    def check_elements_exist(elements_arr)
      failed_elements =[]

      elements_arr.each do |element|

        if element.is_a? String

          #scroll_text_to_view(element,:down) if element_does_not_exist(element)
          has_text?(element) ? log_info("text #{element} exists") : failed_elements << element

        elsif element[:text] || element[:marked]

          has_text?(element.values.first) ? log_info("text #{element} exists") : failed_elements << element

        else

          element_exists(element) ? log_info("element #{element} exists") : failed_elements << element

        end
      end

      if failed_elements.size > 0

        error_msg = "\n"
        failed_elements.each do |err|
          error_msg = error_msg + err.to_s

        end

        log_error(error_msg)

      end
    end

    def get_element(locator)
      $driver.find_element locator
    end

    def find(locator)
      $driver.find_element locator
    end

    def get_elements(element)
     $driver.find_elements(element)
    end

    def get_element_children(parent,child)
      pclass = set_up(parent)
      pid = parent.default
      cclass = set_up(child)
      cid = child.default
      $driver.find_element(:uiautomator,"new UiSelector().#{pclass}(\"#{pid}\").childSelector(new UiSelector().#{cclass}(\"#{cid}\"));")
    end

    def get_element_by_description(locator)
      $driver.find_element(:uiautomator,"new UiSelector().descriptionMatches(\"#{locator}\").instance(0)")
    end
    #goto_contribution_card
    # goto_investments_card
    # goto_loans_card

    def get_element_text_children(parent)
      pfunc = set_up(parent)
      pid = parent.values[0]
      $driver.find_elements(:uiautomator,"new UiSelector().#{pfunc}(\"#{pid}\").childSelector(new UiSelector().className(\"android.widget.TextView\"));")
    end

    def set_up(val)

      sid = val.keys.first
      criteria = {
          id: "resourceId",
          class: "className",
          description: "descriptionContains"
      }

      criteria[sid]

    end

    def isEnabled(locator)

      wait_for(@driver.find_element(locator).enabled?)

    end


    def checked?(locator)

      @driver.find_element(locator).checked?
    rescue Selenium::WebDriver::Error::NoSuchElementError
      raise("element #{locator} does not exist")
    end

    def enabled?(criteria,identifier)

      func = self.set_up(criteria)
      @driver.exists {"new UiSelector().#{func}(\"#{identifier}\").instance(0).enabled(true)"} ? true : false

    end

  end
end


