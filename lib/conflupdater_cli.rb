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


  desc "push TITLE PARENT SPACE PATH", 
    "Push content to confluence."
  long_desc <<-LONGDESC
    `conflupdater push` will push content in file at PATH to page TITLE
    under page PARENT in SPACE_key.

    The space key can be specifed with --space_key or in the config/conflupdater.yml file.
  LONGDESC
  option :space_key 
  def push(title, parent, path)
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 

    space_key ||= options[:space_key] || Settings.space_key
    unless space_key
      puts "Space key needs to be provide in config or on command line"
      exit
    end

    content = File.read(path)

    result = con.update_or_create_page(title: title, parent_title: parent, 
                                       space_key: space_key, content: content)

    puts "Result: #{result}"
    puts "End of Line"
  end

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

  desc "vulnscan NAME", "Add or update vulnscan page named NAME from content at PATH."
  option :parent, default: "Vulnerability Scans", desc: "Title of parent page."
  def vulnscan(name)
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 

    # Get body content from provided file
    if(!Settings.vulnscan_reports_dir)
      warn "Must set vulnscan_reports_dir in config"
      exit 2
    end
    path = "#{Settings.vulnscan_reports_dir}/#{name}.xml"
    content = File.read(path)

    result = con.update_or_create_page(title: name, parent_title: options.parent, 
                                       space_key: Settings.space_key, content: content)
    
    puts "Result: #{result}"
    puts "End of Line"
  end

  desc "spaces", "List global space names and keys."
  def spaces
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 
    res = con.spaces
    res.each do |space|
      puts sprintf('%-40s %5s',space['name'], space['key'])
    end
  end

  desc "pages", "List pages in configured space."
  def pages
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 
    resp = con.pages_in_space(space_key: Settings.space_key)
    pages = PagesDisplay.new(resp)
    puts pages.to_s
  end

  desc "find", "Find page titled NAME."
  def find(name)
    configure unless configured?
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 
    resp = con.find_page_by_title(title: name, space_key: Settings.space_key)
    pp resp
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

