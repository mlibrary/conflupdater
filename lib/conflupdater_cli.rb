# frozen_string_literal: true

require 'pp'
require 'thor'
require 'config'
require 'pry'


class ConflupdaterCLI < Thor
  desc "taghosts", "Update taghosts inventory page."
  def taghosts
    configure unless configured?
    puts "Querying existing page."
  end

  desc "print", "Print configuration."
  def print
    configure unless configured?
    pp Settings.to_h
  end

  ## Non-task functions 
  private 

  def configured?
    defined?(Settings) ? true : false
  end

  def configure
    config_file = 'config/taghosts.yml'
    Config.load_and_set_settings(config_file)
  end
end
