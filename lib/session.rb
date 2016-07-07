require 'logger'
require "faraday"
require_relative 'check_errors'
include CheckErrors

class Session
  attr_reader :url, :password, :resource_url, :login_url

  def initialize(url, password, resource_url, login_url)
    @url = url
    @password = password
    @resource_url = resource_url
    @login_url = login_url
    @conn = aspace_connect
    @rsp = aspace_login
    @session = get_session
  end

  def get_export
    rec = get_resource
    export = rec.body
    if rec.success?
      export
    else
      CheckErrors.handle_errors(export)
    end
  end

  private    
  def aspace_connect
    Faraday.new(:url => @url) do |req|
      req.request :url_encoded
      req.adapter :net_http
    end
  end

  def aspace_login
    @conn.post do |req|
      req.url @login_url
      req.params['password'] = @password
    end
  end

  def get_session
    if @rsp.success?
      LOG.info("Logged in")
      MultiJson.load(@rsp.body)['session']
    else
      CheckErrors.handle_errors("Problem with login: #{@rsp.body}")
    end
  end

  def get_resource
    @conn.get do |req|
      req.url @resource_url
      req.headers['X-ArchivesSpace-Session'] = @session
    end
  end
end
