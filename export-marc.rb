require 'rubygems'
require 'pry'
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
      f.write(record.body)
    end
    puts "EAD for record #{@record_id}, repo: #{@repo_code} is available: #{filename}"
  rescue IOError => err
    raise RuntimeError, err
  end
end
def get_record
  ead_uri = "/resources/marc21/#{@record_id}.xml"
  record = @client.get(ead_uri)
  raise RuntimeError, "Record #{@record_id} not found for #{@repo_code}" unless record.status_code == 200
  record
end

def set_repo
  repo = @client.repositories.find { |r| r['repo_code'] == @repo_code }
  raise ArgumentError, "#{@repo_code} doesn't exist" if repo.nil?
  @client.config.base_repo = repo['uri']
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
set_repo
rec = get_record
write_to_file(rec)
