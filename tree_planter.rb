require 'json'
require 'open3'
require 'pp'
require 'sinatra'

config_obj = JSON.parse(File.read((Dir.pwd) + "/config.json"))

get '/' do
  "<h1>Tree Planter</h1>
   <h2>To use this tool you need to send a post to #{request.url}deploy</h2>"
end

post '/deploy' do
  payload = JSON.parse(request.body.read)
  logger.info("json payload: #{payload.inspect}")

  tree_name = payload['tree_name']
  repo_url  = payload['repo_url']
  logger.info("tree name = #{tree_name}")
  logger.info("repo url = #{repo_url}")

  deployTree(tree_name, repo_url, config_obj)
end

def deployTree(tree_name, repo_url, config_obj)
  base         = config_obj['base_dir']

  stream do |body_content|
    body_content << "tree: #{tree_name}\n"
    body_content << "repo_url: #{repo_url}\n"
    body_content << "base: #{base}\n"

    logger.info("tree: #{tree_name}")
    logger.info("repo_url: #{repo_url}")
    logger.info("base: #{base}")

    if Dir.exists?(base)
      Dir.chdir(base)

      tree_exists = Dir.exists?("./#{tree_name}")
      if tree_exists
        Dir.chdir(tree_name)
        deployCommand = "git pull"
      else
        deployCommand = "git clone #{repo_url} #{tree_name}"
      end

      body_content << "Running #{deployCommand}\n"
      logger.info("Running #{deployCommand}")

      Open3.popen2e(deployCommand) do |stdin, stdout_err, wait_thr|

        while line = stdout_err.gets
          body_content << line
          logger.info(line)
        end

        exit_status = wait_thr.value
        if exit_status.success?
          status 200
          #body body_content
        else
          status 500
          #body body_content
        end
      end # end Open3
    else
      status 500
      msg = "#{base} cannot be found"
      body_content << "#{msg}\n"
      logger.info(msg)
    end
  end
end
