require "awesome_print"
require "influxdb"
require "sinatra"

def get_data
  port = 8086
  port = ENV['INFLUXDB_PORT'].to_i unless ENV['INFLUXDB_PORT'].nil?

  influxdb = InfluxDB::Client.new database: "dockerhub_stats", port: port
  query = 'select max(pull_count) as count from dockerhub_stats where time > now() - 1h group by repo,arch'
  res = influxdb.query(query)

  data = []
  res.each do |repo|
    repo_name = repo['tags']['repo']
    count = repo['values'][0]['count']
    arch = repo['tags']['arch']
    data << { name: repo_name, count: count, arch: arch }
  end

  data
end

set :logging, true
set :dump_errors, true
set :bind, '0.0.0.0'

get '/stats' do
  content_type :json
  get_data.to_json
end
