require 'sinatra'
require 'json'
require 'pp'

config_obj = JSON.parse(File.read((Dir.pwd) + "/config.json"))

get '/' do
  "<h1>Tree Planter</h1>
   <h2>To use this tool you need to send a post to #{request.url}deploy</h2>"
end

get '/deploy/:tree' do
  "Deploying #{params['tree']}"
end

post '/deploy' do
  payload = JSON.parse(request.body.read)
  deployTree(payload['repo_name'], payload['repo_url'],config_obj)
end

def deployTree(tree_name, repo_url, the_config_obj)
  base = the_config_obj['base_dir']
  user = the_config_obj['git_user']

  pp "tree: #{tree_name}\nrepo_url: #{repo_url}\nbase: #{base}\nuser: #{user}\n"

  Dir.chdir(base)
  tree_exists = Dir.exists?("./#{tree_name}")
  if tree_exists
    Dir.chdir(tree_name)
    deployCommmand = "git pull"
  else
    deployCommmand = "git clone #{repo_url} #{tree_name}"
  end

  `#{deployCommmand}`
end
