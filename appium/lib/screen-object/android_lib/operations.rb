require 'appium_lib'
require_relative 'drag_helpers'
require_relative 'texthelpers'
require_relative 'touch_helpers'
require_relative 'wait_helpers'
require_relative 'logging_helper'
require_relative 'locatorhelpers'
require 'appium_lib/common/wait'
require 'appium_lib/android/uiautomator2/helper'
require 'rubygems'

module Android
  module Operations

    include Android::DragHelpers
    include Android::TextHelpers
    include Android::TouchHelpers
    include Android::WaitHelpers
    include Android::LocatorHelpers
    include LoginHelper
    include Appium::Android::Uiautomator2::Helper
    include Appium::Android::Uiautomator2::Element

    def screenshot_and_raise(e)

      screenshot("FAIL_")
      log_error e

    end

    def screenshot(file)

      app = GlobalVars.instance
      suffix = "_#{Time.now.strftime('%s_%L')}.png"
      file_full_path = "./screenshots/#{file}#{suffix}"
      $driver.screenshot(file_full_path)
      app.screenshots << file_full_path

    end

  end
end


