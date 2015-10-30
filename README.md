# tree-planter

A webhook receiver that is designed to deploy code trees via a simple JSON
payload.

## Startup

tree-planter is a Ruby application and uses [Thin][thin] as it's web server.
As such, you may need to setup [RVM][rvm] or similar if you don't have a
recent Ruby installed. To run tree-planter as a daemon you need to:
* switch to the user that you want to own the cloned repos
* Clone https://github.com/genebean/tree-planter.git
* `cd` into the cloned directory
* copy `config-example.json` to `config.json` and update any settings as needed
* copy `thin-example.yml` to `thin.yml` and update any settings as needed
* grant the user running tree-planter write access to all directories
  specified in the config files listed above.
* execute the following:

```bash
gem update --system
gem install bundler --no-ri --no-rdoc
bundle install --jobs=3 --without development
bundle exec thin -C thin.yml start
```

## Examples

Triggering via cURL:

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

[rvm]: https://rvm.io
[thin]: https://rubygems.org/gems/thin
