module LoginHelper

  require "fileutils"
  require_relative '../../../../features/support/lib/color_helper'
  include ColorHelper
  # These methods are not part of the API.
  #
  # They may change at any time.

  # !@visibility private
  # blue
  def log_warn(msg)
    puts blue(" WARN: #{msg}") if msg
  end

  # !@visibility private
  # green
  def log_info(msg)
    puts green(" INFO: #{msg}") if msg
  end

  # !@visibility private
  # red
  def log_error(msg)

    puts red("ERROR: #{msg}") if msg
    raise(msg)
  end

  def log_debug(msg)
    puts blue("DEBUG: #{msg}") if msg
  end
  # !@visibility private
  def self.log_to_file(message)
    timestamp = self.timestamp

    begin
      File.open(self.appium_log_file, "a:UTF-8") do |file|
        message.split($-0).each do |line|
          file.write("#{timestamp} #{line}#{$-0}")
        end
      end
    rescue => e
      message =
          %Q{Could not write:

#{message}

to calabash.log because:

#{e}
          }
      self.log_debug(message)
    end
  end


  # @!visibility private
  def self.timestamp
    Time.now.strftime("%Y-%m-%d_%H-%M-%S")
  end

  # @!visibility private
  def self.logs_directory
    path = File.join(ENV["HOME_DIR"], "logs")
    FileUtils.mkdir_p(path)
    path
  end

  # @!visibility private
  def self.appium_log_file
    path = File.join(self.logs_directory, "rs.log")
    if !File.exist? path
      FileUtils.touch(path)
    end
    path
  end
end


World(LoginHelper)