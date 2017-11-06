require 'rubygems'
require 'pry'
require 'open3'
require 'archivesspace/client'

def help
  puts "ruby #{$0} repo_code record_id"
  puts "ruby #{$0} fales 100"
end
def check_params
  unless ARGV.count == 2
    help
    raise ArgumentError, "Script needs two arguments" unless ARGV.count == 2
  end

end
def load_config_yaml(config)
  yaml = YAML.load_file(config)
  hsh = {}
  # read yaml hash and symbolize keys to new hash
  # to create config object for archivesspace-client
  yaml.each_key { |k|
    hsh[k.to_sym] = yaml[k]
  }
  hsh
end

def write_to_file(record)
  filename = "#{@record_id}.xml"
  begin
    File.open(filename,"w") do |f|
      f.write(record)
    end
    puts "marcxml for record #{@record_id}, repo: #{@repo_code} is available: #{filename}"
  rescue IOError => err
    raise RuntimeError, err
  end
end
def get_record
  @ead_uri = "/resources/marc21/#{@record_id}.xml"
  url = "#{@client.config.base_uri}#{@repo_uri}#{@ead_uri}"
  token = "X-ArchivesSpace-Session: #{@client.token}"
  cmd = "curl -H '#{token}' '#{url}'"
  record,e,s = Open3.capture3(cmd)
  raise RuntimeError, "Record #{@record_id} not found for #{@repo_code}" if record =~ /Resource not found/
  record
end

def get_repo_uri
  repo = @client.repositories.find { |r| r['repo_code'] == @repo_code }
  raise ArgumentError, "#{@repo_code} doesn't exist" if repo.nil?
  @repo_uri = repo['uri']
end
def login
  hsh = load_config_yaml(@config_file)
  config = ArchivesSpace::Configuration.new(hsh)
  @client =  ArchivesSpace::Client.new(config).login
end

@repo_code = ARGV[0]
@record_id = ARGV[1]
check_params

@config_file = "config.yml"
login
get_repo_uri
rec = get_record
write_to_file(rec)
