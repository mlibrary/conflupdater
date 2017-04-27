# frozen_string_literal: true
require 'erb'

class Taghosts
  TOP_TAGS=["quod", "ictc", "www-lib", "prep", "search", "redhat", "lss", "windows", "mysql", "solr", "dev", "virtual", "apache", "hatcher", "ht", "macc", "prod", "jessie", "debian", "linux"].freeze
  HEADERS=["hostname"] + TOP_TAGS + ["other_tags"]

  attr :content

  # take source and return content for the page
  def initialize(source: nil) 
    @content = Taghosts.convert_content(source: source)
  end

  def to_s
    @content || ''
  end

  # Convert source data to page content
  #
  # @return [Hash] Structured for json format expected by confluence.
  def self.convert_content(source: nil)
    # Read in source file into array of row_data arrays
    rows = Array.new()
    IO.foreach(source) { |line| rows << process_line(line) }

    # Use processed data
    html_content(data: rows)
  end

  # Create html content
  # @return [String] html content for confluence page replacement
  def self.html_content(data: Array.new)
    # emit html table formatted for confluence
    erb = ERB.new(File.read('lib/templates/table.html.erb'))
    table_html = erb.result binding
  end

  # Process source file line into table row data
  #
  # @param line [String] whitespace delimited line from source file
  # @return [Array] table row values corresponding to table headers
  def self.process_line(line)
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
