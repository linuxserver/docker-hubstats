require "httparty"
require "awesome_print"
require "influxdb"
require "yaml"

def processs_org(org)
  arch = 'x86'
  case(org)
  when 'linuxserver' then
    arch = 'x86'
  when 'lsioarmhf' then
    arch = 'armhf'
  end

  res = HTTParty.get(
    "https://hub.docker.com/v2/repositories/#{org}/",
    query: { page_size: 100 })
  data = JSON.parse(res.body)

  pull_counts = {}
  while data.include?('next') && data['next'].nil? == false
    url = data['next']
    res = HTTParty.get(url)
    data = JSON.parse(res.body)
    pull_counts.merge!(process_counts(data, arch))
  end

  pull_counts
end

def process_counts(data, arch)
  pull_counts = {}
  data['results'].each do |repo|
    name = repo['name']
    count = repo['pull_count']
    pull_counts[name] = { arch: arch, pull_count: count}
  end

  pull_counts
end

def insert_counts(data)
  influxdb = InfluxDB::Client.new database: "dockerhub_stats", port: 18086
  data.each do |repo, repo_data|
    influx_data = {
      values: { pull_count: repo_data[:pull_count] },
      tags:   { repo: repo, arch: repo_data[:arch] }
    }
    influxdb.write_point("dockerhub_stats", influx_data)
  end

end

def run
  orgs = nil

  unless ENV['DOCKERHUB_ORGS'].nil?
    orgs = ENV['DOCKERHUB_ORGS'].split(',')
  end

  if orgs.nil?
    config_file = File.dirname(__FILE__) + "/config/settings.yml"
    config = YAML.load_file(config_file)

    orgs = config["orgs"]
  end

  ap orgs
  exit

  counts = {}
  orgs.each do |org|
    counts.merge!(processs_org(org))
  end

  insert_counts(counts)
end

run
