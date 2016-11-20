require "httparty"
require "awesome_print"
require "influxdb"
require "yaml"

config_file = File.dirname(__FILE__) + "/config/settings.yml"
config = YAML.load_file(config_file)

email = config["email"]
password = config["password"]
org 	 = config["org"]

data = { username: email,
		 password: password }

res = HTTParty.post("https://hub.docker.com/v2/users/login/", body: data).body
token = JSON.parse(res)["token"]

headers = { token: token}
res = HTTParty.get(
  "https://hub.docker.com/v2/repositories/#{org}/",
  query: { page_size: 100 },
  headers: headers)

data = JSON.parse(res.body)

pull_counts = {}
data["results"].each do |repo|
	pull_counts[repo["name"]] = repo["pull_count"]
end

influxdb = InfluxDB::Client.new database: "dockerhub_stats"
pull_counts.each do |repo, count|
	data = {
	  values: { pull_count: count },
	  tags:   { repo: repo }
	}

	influxdb.write_point("dockerhub_stats", data)
end
