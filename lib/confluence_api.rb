require 'typhoeus'
require 'json'

class ConfluenceApi

  attr_reader :base_url, :user, :pass

  # @param base_url [String] rest api url for confluence 
  #   e.g. https://localhost/confluence/rest/api
  # @param user [String] username for admin user
  # @param pass [String] corresponding password for user
  def initialize(base_url: nil, user: nil, pass: nil)
    @base_url= base_url
    @user= user
    @pass= pass
  end

  # Get pages in give space.
  #
  # @param space_key [String] key uniquely identifying confluence space
  def pages_in_space(space_key: nil)
    parameters = {
      limit: 1000,
      expand: 'children,ancestors'
    }
    target_url = @base_url + "/space/#{space_key}/content/page"
    resp = Typhoeus.get(target_url, params: parameters, userpwd: "#{@user}:#{@pass}")

    if resp.response_code == 200
      r = JSON.parse(resp.body)
      results = JSON.parse(resp.body)['results']
    end
  end

  # Get version of page.
  #
  # @param page_title [String] title of page
  # @param space_key [String] key uniquely identifying confluence space
  def page_version(page_title: nil, space_key: nil)
    parameters = {
      title: page_title,
      spackeKey: space_key,
      expand: 'version,history'
    }
    target_url = @base_url + "/content"
    resp = Typhoeus.get(target_url, params: parameters, userpwd: "#{@user}:#{@pass}")

    if resp.response_code == 200
      result = JSON.parse(resp.body)['results'].first
      result['version']['number']
    end
  end

  # curl -u admin:admin -X GET "http://localhost:8080/confluence/rest/api/content?title=myPage%20Title&spaceKey=TST&expand=history"
  def find_page_by_title(title: nil, space_key: nil)
    parameters = {
      title: title,
      spaceKey: space_key,
      expand: 'ancestors,version'
    }
    target_url = @base_url + "/content"

    resp = Typhoeus.get(target_url, params: parameters, userpwd: "#{@user}:#{@pass}")

    hsh = JSON.parse(resp.response_body)

    # Return a page hash or empty hash
    hsh['results'].first || Hash.new
  end

  #curl -u admin:admin -X POST -H 'Content-Type: application/json' 
  #-d'{"type":"page","title":"new page", "ancestors":[{"id":456}],
  #"space":{"key":"TST"},"body":{"storage":{"value":"<p>This is a new page</p>","representation":"storage"}}}'
  #http://localhost:8080/confluence/rest/api/content/ 
  #
  #"Vulnerability Scans" id: 13205813
  #
  # Post JSON blob to Confluence to create a new page as child of existing page
  def new_child_page(title: nil, ancestor_id: nil, space_key: nil, content: '')
    headers = {
      'Content-Type': 'application/json'
    }
    data = {
      type: 'page',
      title: title,
      ancestors: [{id: ancestor_id}],
      space: {key: space_key},
      body: {storage: {value: content, representation: "storage"}}
    }

    target_url = @base_url + "/content"
    resp = Typhoeus.post(target_url, body: data.to_json, headers: headers, userpwd: "#{@user}:#{@pass}")

    binding.pry

    resp.response_code
  end
  
  # curl -u admin:admin -X PUT -H 'Content-Type: application/json' -d 'content'
  # http://localhost:8080/confluence/rest/api/content/3604482 
  # '{"id":"3604482","type":"page","title":"new page","space":{"key":"TST"},"body":{"storage":{"value":"<p>This is the updated text for the new page</p>","representation":"storage"}},"version":{"number":2}}' 
  # Post JSON blob to Confluence to update an existing page
  def update_page(page: {}, space_key: nil,  content: '')
    headers = {
      'Content-Type': 'application/json'
    }
    data = {
      id: page['id'],
      type: 'page',
      title: page['title'],
      space: {key: space_key},
      version: {number: page['version']['number'] + 1},
      body: {storage: {value: content, representation: "storage"}}
    }

    target_url = "#{@base_url}/content/#{page['id']}" 
    resp = Typhoeus.put(target_url, body: data.to_json, headers: headers, userpwd: "#{@user}:#{@pass}")
    resp.response_code
  end
end
