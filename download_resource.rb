## get download to work. Log
require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'multi_json'
require 'yaml'
require 'logger'
require_relative 'lib/session'
require_relative 'lib/check_errors'
include CheckErrors

def download(rec)
    filename = "#{@resource_id}_marc.xml"
    begin
      LOG.info("Resource #{@resource_id} found")
      File.delete(filename) if File.exist?(filename)
      file = File.open(filename, "w")
      file.write(rec)
      LOG.info("Resource #{@resource_id} downloaded to #{filename}")
    rescue IOError => e
      CheckErrors.handle_errors(e)
    ensure
      file.close unless file.nil?
    end

  unless File.exist?(filename)
    CheckErrors.handle_errors("File must exist: #{filename}")
  end
end

@repo_id = ARGV[0]
@resource_id = ARGV[1]
LOG = Logger.new(STDOUT)
CheckErrors.check_arguments(ARGV)
begin
  config_file = "config.yml"
  CONFIG = YAML.load_file(config_file)
rescue
  err = "#{$!}"
  CheckErrors.handle_errors(err)
end
mode = %w(dev prod)
user = CONFIG['user']
password = CONFIG['password']
url = CONFIG['aspace'][mode[0]]
login = "/users/#{user}/login"
resource = "repositories/#{@repo_id}/resources/marc21/#{@resource_id}.xml"
aspace_session = Session.new(url,password,resource,login)
rec = aspace_session.get_export
download(rec)
