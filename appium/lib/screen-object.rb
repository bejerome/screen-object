=begin
***********************************************************************************************************
SPDX-Copyright: Copyright (c) Capital One Services, LLC
SPDX-License-Identifier: Apache-2.0
Copyright 2016 Capital One Services, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License. 
***********************************************************************************************************
=end

require 'appium_lib'
require 'screen-object/load_appium'
require 'screen-object/accessors'
require 'screen-object/elements'
require 'screen-object/screen_factory'
require 'screen-object/accessors/element'
require_relative 'screen-object/android_lib/operations'
include Android::Operations

# this module adds screen object when included.
# This module will add instance methods and screen object that you use to define and interact with mobile objects

module ScreenObject


  DEFAULT_OPTS = {
      :timeout => 60,
      :retry_frequency => 2,
      :post_timeout => 1,
      :timeout_message => 'Timed out waiting...',
      :screenshot_on_error => false,
      :error_mesg => "element could not be found"

  } unless const_defined?(:RESET)

  class WaitError < RuntimeError
  end

  def self.included(cls)
    cls.extend ScreenObject::Accessors
  end

  def driver
    ScreenObject::AppElements::Element.new('').driver
  end

  def swipe(start_x,start_y,end_x,end_y,touch_count,duration)
    driver.swipe(:start_x => start_x, :start_y => start_y, :end_x => end_x, :end_y => end_y,:touchCount => touch_count,:duration => duration)
  end

  def screenshot(opts={:path=> "./screenshots",:file_name=>"fail"})
    default_path = opts[:path]
    dir_path = opts || default_path
    suffix = "_#{Time.now.strftime('%s_%L')}.png"
    file_full_path = "#{dir_path}/#{opts[:file_name]}#{suffix}"
    $driver.screenshot(file_full_path)
    log_debug $driver.get_android_inspect
  end

  def scroll(direction)
    sleep 2
    size = driver.driver.manage.window.size
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


  def landscape
    driver.driver.rotate :landscape
  end

  def portrait
    driver.driver.rotate :portrait
  end

  def back
    driver.back
  end


  def wait_poll(opts,&block)
    test = opts[:until]
    if test.nil?
      cond = opts[:until_exists]
      raise "Must provide :until or :until_exists" unless cond

      test = lambda {"#{cond}?"}

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



  def wait_for(options_or_timeout=DEFAULT_OPTS, &block)
    #note Hash is preferred, number acceptable for backwards compat
    default_timeout = DEFAULT_OPTS[:timeout]
    timeout = options_or_timeout || default_timeout
    post_timeout = DEFAULT_OPTS[:post_timeout]
    retry_frequency = DEFAULT_OPTS[:retry_frequency]
    timeout_message = DEFAULT_OPTS[:timeout_message]
    screenshot_on_error = DEFAULT_OPTS[:screenshot_on_error]

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
        log_error(msg)
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

  def wait_until_exists(timeout = DEFAULT_OPTS[:timeout], locator)
    sleep 1
    wait_for(timeout: timeout,
             timeout_message: "could not find element") do
      locator.exists?
    end

  end

  def wait_until_does_not_exists(timeout = DEFAULT_OPTS[:timeout], locator)
    sleep 1
    wait_for(timeout: timeout,
             timeout_message: "could not find element") do
      not locator.exists?
    end

  end

  def check_elements_exist(*elements_arr)
    failed_elements =[]

    elements_arr.each do |element|

      ("#{element}?") ? log_info("#{element.locator.join(" ")} is visible") : failed_elements << element.locator.join(" ")

    end

    if failed_elements.size > 0

      error_msg = "\n"
      failed_elements.each do |err|
        error_msg = error_msg + err.to_s

      end

      log_error(error_msg)

    end
  end

  def wait_step(timeout = 5, message = nil, &block)
    default_wait = driver.default_wait
    wait = Selenium::WebDriver::Wait.new(:timeout => driver.set_wait(timeout), :message => message)
    wait.until &block
    driver.set_wait(default_wait)
  end

  def enter
    #pending implementation
  end

  def scroll_down_find(locator,locator_value,num_loop = 15)
    scr = driver.window_size
    screenHeightStart = (scr.height) * 0.5
    scrollStart = screenHeightStart.to_i
    screenHeightEnd = (scr.height) * 0.2
    scrollEnd = screenHeightEnd.to_i
    for i in 0..num_loop
      begin
        if (driver.find_element(locator,locator_value).displayed?)
          break
        end
      rescue
        driver.swipe(:start_x => 0,:start_y => scrollStart,:end_x =>0,:end_y =>scrollEnd,:touchCount => 2,:duration => 0)
        false
      end
    end
  end

  def scroll_down_click(locator,locator_value,num_loop = 15)
    scr = driver.window_size
    screenHeightStart = (scr.height) * 0.5
    scrollStart = screenHeightStart.to_i
    screenHeightEnd = (scr.height) * 0.2
    scrollEnd = screenHeightEnd.to_i
    for i in 0..num_loop
      begin
        if (driver.find_element(locator,locator_value).displayed?)
          driver.find_element(locator,locator_value).click
          break
        end
      rescue
        driver.swipe(:start_x => 0,:start_y => scrollStart,:end_x =>0,:end_y =>scrollEnd,:touchCount => 2,:duration => 0)
        false
      end
    end
  end

  def scroll_up_find(locator,locator_value,num_loop = 15)
    scr = driver.window_size
    screenHeightStart = (scr.height) * 0.5
    scrollStart = screenHeightStart.to_i
    screenHeightEnd = (scr.height) * 0.2
    scrollEnd = screenHeightEnd.to_i
    for i in 0..num_loop
      begin
        if (driver.find_element(locator,locator_value).displayed?)
          break
        end
      rescue
        driver.swipe(:start_x => 0,:start_y => scrollEnd,:end_x =>0,:end_y =>scrollStart,:touchCount => 2,:duration => 0)
        false
      end
    end
  end


  def scroll_up_click(locator,locator_value,num_loop = 15)
    scr = driver.window_size
    screenHeightStart = (scr.height) * 0.5
    scrollStart = screenHeightStart.to_i
    screenHeightEnd = (scr.height) * 0.2
    scrollEnd = screenHeightEnd.to_i
    for i in 0..num_loop
      begin
        if (driver.find_element(locator,locator_value).displayed?)
          driver.find_element(locator,locator_value).click
          break
        end
      rescue
        driver.swipe(:start_x => 0,:start_y => scrollEnd,:end_x =>0,:end_y =>scrollStart,:touchCount => 2,:duration => 0)
        false
      end
    end
  end


  def drag_and_drop_element(source_locator,source_locator_value,target_locator,target_locator_value)
    l_draggable = driver.find_element(source_locator,source_locator_value)
    l_droppable = driver.find_element(target_locator,target_locator_value)
    obj1= Appium::TouchAction.new
    obj1.long_press(:x => l_draggable.location.x,:y => l_draggable.location.y).move_to(:x => l_droppable.location.x,:y => l_droppable.location.y).release.perform
  end

  def keyboard_hide
    begin
      driver.hide_keyboard
    rescue
      false
    end
  end

end
