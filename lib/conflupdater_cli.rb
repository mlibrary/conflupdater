# frozen_string_literal: true
require 'pp'
require 'thor'
require 'config'
require 'json'
require 'highline'
require 'pathname'
require 'pry'

require_relative 'taghosts'
require_relative 'confluence_api'
require_relative 'pages_display'

Signal.trap("INT"){
  puts "Interrupt.  Exiting."
  exit
}

class ConflupdaterCLI < Thor
  APP_ROOT = Pathname.new File.expand_path('../../',  __FILE__)

  desc "taghosts PATH", "Update taghosts inventory page from source data at PATH."
  option :name,   default: "Taghosts Inventory", desc: "Title of taghosts page."
  option :parent, default: "General Articles",   desc: "Title of parent page."
  def taghosts(path)
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 

    # Parse Taghosts data to content
    path ||= Settings.source_file
    content = Taghosts.new(source: path)

    result = con.update_or_create_page(title: name, parent_title: parent, 
                                       space_key: Settings.space_key, content: content)

    puts "Result: #{result}"
    puts "End of Line"
  end

  desc "vulnscan NAME PATH", "Add or update vulnscan page named NAME from content at PATH."
  option :parent, default: "Vulnerability Scans", desc: "Title of parent page."
  def vulnscan(name, path)
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 

    # Get body content from provided file
    content = File.read(path)

    vuln_page_title = "Vulnerability Scans"
    vuln_page = con.find_page_by_title(title: vuln_page_title, space_key: Settings.space_key)

    result = con.update_or_create_page(title: name, parent_title: parent, 
                                       space_key: Settings.space_key, content: content)
    
    puts "Result: #{result}"
    puts "End of Line"
  end

  desc "pages", "List pages in configured space."
  def pages
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 
    resp = con.pages_in_space(space_key: Settings.space_key)
    pages = PagesDisplay.new(resp)
    puts pages.to_s
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
    config_file = File.join(APP_ROOT,'config/conflupdater.yml')
    unless File.exist? config_file
      puts "Unable to read config: #{config_file}"
      exit
    end

    Config.load_and_set_settings(config_file)
    Settings.user ||= prompt_for_user
    Settings.pass ||= prompt_for_pass
  end
  
  # get user & pass
  def prompt_for_user
    cli = HighLine.new
    user = cli.ask("Enter Username:")
    return user
  end

  def prompt_for_pass
    cli = HighLine.new
    pass = cli.ask("Enter Password:") { |q| q.echo = "*" }
    return pass
  end

end

