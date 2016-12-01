# frozen_string_literal: true
require 'erb'

class Taghosts
  TOP_TAGS=["quod", "ictc", "www-lib", "prep", "search", "redhat", "lss", "windows", "mysql", "solr", "dev", "virtual", "apache", "hatcher", "ht", "macc", "prod", "jessie", "debian", "linux"].freeze
  HEADERS=["hostname"] + TOP_TAGS + ["other_tags"]

  attr_reader :page_id, :space_key, :page_version, :source

  def initialize(page_id: nil, space_key: nil, page_version: nil, source: nil) 
    @page_id = page_id
    @space_key = space_key
    @page_version = page_version
    @source = source
  end

  # Create page update data from source
  #
  # @return [Hash] Structured for json format expected by confluence.
  def page_update
    # Read in source file into array of row_data arrays
    rows = Array.new()
    IO.foreach(source) { |line| rows << process_line(line) }

    # Create update data
    post_data = 
    {
        "body": {
            "storage": {
                "representation": "storage",
                "value": html_content(data: rows)
            }
        },
        "id": page_id,
        "space": {
            "key": space_key
        },
        "title": "Taghosts Inventory",
        "type": "page",
        "version": {
            "number": @page_version.to_i + 1
        }
    }
  end

  # Create html content
  # @return [String] html content for confluence page replacement
  def html_content(data: Array.new)
    # emit html table formatted for confluence
    erb = ERB.new(File.read('lib/templates/table.html.erb'))
    table_html = erb.result binding
  end

  # Process source file line into table row data
  #
  # @param line [String] whitespace delimited line from source file
  # @return [Array] table row values corresponding to table headers
  def process_line(line)
   input_tokens = line.split(' ')

   # initialize row values with a space
   row_vals = Array.new(size=HEADERS.length, default=' ')

   # slice off first value as the hostname
   row_vals[0] = input_tokens.slice!(0)

   # Make an array for holding other tags
   other_tags = Array.new()

   # Mark an x in the proper spot for the top 20 tags
   #   append any non-matching tag to the other tags array
   input_tokens.each do |tag|
     index = TOP_TAGS.index tag
     if index
       row_vals[index + 1]='x'
     else
       other_tags << tag
     end
   end

   row_vals[HEADERS.length-1] = other_tags.join(' ') 

   return row_vals
  end
end
