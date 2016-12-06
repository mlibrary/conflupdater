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
end
