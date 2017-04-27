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

  desc "taghosts", "Update taghosts inventory page."
  def taghosts
    configure unless configured?
    user, pass = prompt_for_credentials

    # Obtain current version of page
    con = ConfluenceApi.new(base_url: Settings.base_url, user: Settings.user, pass: Settings.pass) 
    version = con.page_version(page_title: Settings.page_title, space_key: Settings.space_key)

    # Update content of page
    taghosts = Taghosts.new(page_id: Settings.page_id,
                            space_key: Settings.space_key,
                            page_version: version,
                            source: Settings.source_file)
    update_data = taghosts.page_update
    puts update_data.to_json
  end

  desc "vulnscan", "Add or update vulnscan NAME from PATH."
  def vulnscan(name, path)
    configure unless configured?
    user, pass = prompt_for_credentials

    con = ConfluenceApi.new(base_url: Settings.base_url, user: user, pass: pass) 

    # Get Vulnerabilities Page
    vuln_page_title = "Vulnerability Scans"
    vuln_page = con.find_page_by_title(title: vuln_page_title, space_key: Settings.space_key)

    if vuln_page.empty?
      puts "Unable to find parent page: #{vuln_page_title}"
      exit
    end

    # Get existing vulnerabilities page if extant
    scan_page = con.find_page_by_title(title: name, space_key: Settings.space_key)

    # Get body content
    # Straight up read from the path
    content = File.read(path)

    if scan_page.empty?
      # Create new child page
      puts "creating new page"
      result = con.new_child_page(title: name, ancestor_id: vuln_page['id'], 
                         space_key: Settings.space_key, content: content)
    else
      # Update page
      puts "updating page"
      result = con.update_page(page: scan_page, space_key: Settings.space_key, content: content)
    end
    
    # Update/Create Page
    puts "Result: #{result}"
    puts "End of Line"
  end

  desc "pages", "List pages in configured space."
  def pages
    configure unless configured?
    user, pass = prompt_for_credentials

    con = ConfluenceApi.new(base_url: Settings.base_url, user: user, pass: pass) 
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
  end
  
  # get user & pass
  def prompt_for_credentials
    cli = HighLine.new
    user = cli.ask("Enter Username:")
    pass = cli.ask("Enter Password:") { |q| q.echo = "*" }
    return [user, pass]
  end

end

