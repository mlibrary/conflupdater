# frozen_string_literal: true

require 'erb'
require 'json'
require 'pry'


TOP_TAGS=["quod", "ictc", "lib", "prep", "search", "www", "redhat", "lss", "windows", "mysql", "solr", "dev", "virtual", "apache", "hatcher", "ht", "macc", "prod", "jessie", "debian", "linux"].freeze

HEADERS=["hostname"] + TOP_TAGS + ["other_tags"]

# @input [String] whitespace delimited taghosts line
# @return [Array] table row values corresponding to top tags
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

# Array of row_data arrays
rows = Array.new()

# Read in taghosts file
IO.foreach('active-servers') do |line|
  rows << process_line(line)
end

# emit html table formatted for confluence

erb = ERB.new(File.read('table.html.erb'))
table_html = erb.result
    
# Create post data in json format
post_data = 
{
    "body": {
        "storage": {
            "representation": "storage",
            "value": table_html
        }
    },
    "id": "6095488",
    "space": {
        "key": "LAS"
    },
    "title": "Taghosts Inventory",
    "type": "page",
    "version": {
        "number": 4
    }
}.to_json

File.open('update.json', 'w') do |file|
  file << post_data
end

puts "done"



