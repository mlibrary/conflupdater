# frozen_string_literal: true
require 'pp'
require 'thor'
require 'config'
require 'json'
require 'pry'

require_relative 'taghosts'

class ConflupdaterCLI < Thor
  desc "taghosts", "Update taghosts inventory page."
  def taghosts
    configure unless configured?
    puts "Querying existing page."
    puts "Updating page."
    taghosts = Taghosts.new(page_id: Settings.page_id,
                            space_key: Settings.space_key,
                            page_version: '8',
                            source: Settings.source_file)
    update_data = taghosts.page_update
    pp update_data.to_json
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
