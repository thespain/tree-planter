# tree-planter

A webhook receiver that is designed to deploy code trees via either a simple
JSON payload or the payload from a GitLab webhook. Cloned branches can also be
deleted via a the GitLab webhook.

## Startup

tree-planter is a Ruby application built on Sinatra. When run on a box without
a web server it can utilize [Passenger][passenger] in standalone mode or
[Thin][thin] as its web server.

When run on a box that already has Apache or Nginx it can be run like any other
Rack application. As such, you may need to setup [RVM][rvm] or similar if you
don't have a recent Ruby installed.

To run tree-planter via [Passenger][passenger] behind Apache you need to have
Passenger installed and configured. After that, you will need to do the
following:  
1. create a user to run the application as
2. make a directory such as `/opt/tree-planter` to use as the home of the application
3. chown that directory to your application user
4. switch to the application user and run
   `git clone https://github.com/genebean/tree-planter.git /opt/tree-planter`
5. cd into `/opt/tree-planter`
6. run `bundle install --deployment --without development test`
7. copy `/opt/tree-planterexmaple-configs/apache/10-tree-planter.conf` to your
   Apache config directory and edit as needed for your setup.
8. Restart Apache

If you want to use this with one of the Software Collections available for Red
Hat, CentOS, Fedora, and the like then you can reference the included
Vagrantfile if you need assistance in setting up Passenger.

To run tree-planter as a standalone daemon you need to:  
1. switch to the user that you want to own the cloned repos
2. Clone https://github.com/genebean/tree-planter.git
3. `cd` into the cloned directory
4. copy `config-example.json` to `config.json` and update any settings as needed
5. If using Passenger: copy `Passengerfile-example.json` to `Passengerfile.json`
   and update any settings as needed
6. if using Thin: copy `thin-example.yml` to `thin.yml` and update any settings
   as needed
7. grant the user running tree-planter write access to all directories
   specified in the config files listed above.
8. execute the following:

```bash
gem update --system
gem install bundler --no-ri --no-rdoc
bundle install --jobs=3 --without development

# if using Passenger
bundle exec passenger start

# if using thin
bundle exec thin -C thin.yml start
```


## End Points

tree-planter has the following endpoints:  
* `/` - when the base URL is opened in a browser it show you a list of the
  endpoints.
* `/deploy` - Deploys the default branch of a repository. It accepts a POST in
  the format of a GitLab webhook or in the custom format shown in the examples
  below.
* `/gitlab` - Deploys the branch of a repo referenced in the payload of a
  webhook POST from GitLab. Each branch is placed into a folder using the naming
  convention `repository_branch` such as `tree-planter_master`. All /'s are
  replaced with underscores.
* `/hook-test` - Used for testing and debugging. It displays diagnostic info
  about the payload that was POST'ed.

If using the Vagrant box or running behind Apache on your server these will all
send a fair amount of info to Apache's error log. The error log is used as a
byproduct of how Sinatra / Rack do their logging.


## Examples

### Triggering via cURL:

```bash
# first run
[vagrant@localhost opt]$ curl -H "Content-Type: application/json" -X POST -d \
'{ "tree_name": "tree-planter", "repo_url": "https://github.com/genebean/tree-planter.git" }' \
http://localhost:4567/deploy
tree: tree-planter
repo_url: https://github.com/genebean/tree-planter.git
base: /opt/trees
Running git clone https://github.com/genebean/tree-planter.git tree-planter
Cloning into 'tree-planter'...

# second run
[vagrant@localhost ~]$ curl -H "Content-Type: application/json" -X POST -d \
'{ "tree_name": "tree-planter", "repo_url": "https://github.com/genebean/tree-planter.git" }' \
http://localhost:4567/deploy
tree: tree-planter
repo_url: https://github.com/genebean/tree-planter.git
base: /opt/trees
Running git pull
Already up-to-date.
```

### Example cURL / JSON Syntax

```bash
# Pull master branch with a GitLab-like payload
curl -H "Content-Type: application/json" -X POST -d \
'{"ref":"refs/heads/master", "checkout_sha":"858f1411ecd9d0b7c8f049a98412d1b3dcb68eae", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' \
http://localhost/gitlab

# Pull develop branch with a GitLab-like payload
curl -H "Content-Type: application/json" -X POST -d \
'{"ref":"refs/heads/develop", "checkout_sha":"858f1411ecd9d0b7c8f049a98412d1b3dcb68eae", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' \
http://localhost/gitlab

# Pull feature/parsable_names branch with a GitLab-like payload
curl -H "Content-Type: application/json" -X POST -d \
'{"ref":"refs/heads/feature/parsable_names", "checkout_sha":"858f1411ecd9d0b7c8f049a98412d1b3dcb68eae", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' \
http://localhost/gitlab

# Pull default branch with a GitLab-like payload
curl -H "Content-Type: application/json" -X POST -d \
'{"ref":"refs/heads/master", "checkout_sha":"858f1411ecd9d0b7c8f049a98412d1b3dcb68eae", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' \
http://localhost/deploy

# Pull default branch with the tree-planter custom payload
curl -H "Content-Type: application/json" -X POST -d \
'{ "tree_name": "tree-planter", "repo_url": "https://github.com/genebean/tree-planter.git" }' \
http://localhost/deploy

# Delete cloned copy of feature/parsable_names branch with a GitLab-like payload
curl -H "Content-Type: application/json" -X POST -d \
'{"ref":"refs/heads/feature/parsable_names", "checkout_sha":"0000000000000000000000000000000000000000", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}' \
http://localhost/gitlab
```

[rvm]: https://rvm.io
[passenger]: https://www.phusionpassenger.com
[thin]: https://rubygems.org/gems/thin
