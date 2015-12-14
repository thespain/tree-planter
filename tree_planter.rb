require 'json'
require 'open3'
require 'pp'
require 'sinatra'

config_obj = JSON.parse(File.read((Dir.pwd) + "/config.json"))

get '/' do
  "<h1>Tree Planter</h1>
   <h2>To use this tool you need to send a post to #{request.url}deploy</h2>"
end

# Deploys a repository using the default branch
post '/deploy' do
  payload = JSON.parse(request.body.read)
  logger.info("json payload: #{payload.inspect}")

  endpoint    = 'deploy'
  tree_name   = payload['tree_name']
  branch_name = ''
  repo_url    = payload['repo_url']
  logger.info("endpoint = #{endpoint}")
  logger.info("tree name = #{tree_name}")
  logger.info("repo url = #{repo_url}")
  logger.info("")

  deploy_tree(endpoint, tree_name, branch_name, repo_url, config_obj)
end

# Parses the payload from GitLab and deploys a specific branch of a repository.
post '/gitlab' do
  payload = JSON.parse(request.body.read)
  logger.info("json payload: #{payload.inspect}")
  
  # Determine event type
  if payload['ref'].split('/')[1].eql? "heads"
    endpoint     = 'gitlab'
    tree_name    = (payload['repository']['url'].split('/')[-1]).split('.')[0]
    branch_name  = payload['ref'].split('/')[2]
    repo_name    = payload['repository']['name']
    repo_url     = payload['repository']['url']
    checkout_sha = payload['checkout_sha']

    logger.info("repo name    = #{repo_name}")
    logger.info("repo url     = #{repo_url}")
    logger.info("branch name  = #{branch_name}")
    logger.info("checkout sha = #{checkout_sha}")
    logger.info("")

    deploy_tree(endpoint, tree_name, branch_name, repo_url, config_obj)

  elsif payload['ref'].split('/')[1].eql? "tags"
    tag_name = payload['ref'].split('/')[2]
    logger.info("tag = #{tag_name}")
  end

end

# Simply prints the
post '/hook-test' do
  payload = JSON.parse(request.body.read)
  logger.info("json payload: #{payload.inspect}")
end

def deploy_tree(endpoint, tree_name, branch_name, repo_url, config_obj)
  base         = config_obj['base_dir']

  stream do |body_content|
    body_content << "endpoint = #{endpoint}\n"
    body_content << "tree: #{tree_name}\n"
    body_content << "branch: #{branch_name}\n"
    body_content << "repo_url: #{repo_url}\n"
    body_content << "base: #{base}\n"

    logger.info("endpoint = #{endpoint}")
    logger.info("tree: #{tree_name}")
    logger.info("branch: #{branch_name}")
    logger.info("repo_url: #{repo_url}")
    logger.info("base: #{base}")

    if Dir.exists?(base)
      Dir.chdir(base)

      case endpoint
        when 'deploy'
          repo_path = "#{tree_name}"

        when 'gitlab'
          repo_path =("#{tree_name}_#{branch_name}")

        else
          repo_path = nil
          abort("Failing... endpoint #{endpoint} unknown")
      end
      logger.info("repo_path: #{repo_path}")

      if !repo_path.nil?
        repo_exists = Dir.exists?("./#{repo_path}")
      else
        repo_exists = nil
        abort("No repo path was set.")
      end

      if repo_exists
        Dir.chdir(tree_name)
        deploy_command = "git pull"
      else
        if branch_name.eql? ''
          deploy_command = "git clone #{repo_url} #{repo_path}"
        else
          deploy_command = "git clone -b #{branch_name} --single-branch #{repo_url} #{repo_path}"
        end
      end

      body_content << "Running #{deploy_command}\n"
      logger.info("Running #{deploy_command}")

      Open3.popen2e(deploy_command) do |stdin, stdout_err, wait_thr|

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
