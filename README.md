# tree-planter

A webhook receiver that is designed to deploy code trees via a simple JSON
payload.

## Examples

Triggering via cURL

```bash
[vagrant@localhost ~]$ curl -H "Content-Type: application/json" -X POST -d \
'{ "tree_name": "tree-planter", "repo_url": "https://github.com/genebean/tree-planter.git" }' \
http://localhost:4567/deploy
tree: tree-planter
repo_url: https://github.com/genebean/tree-planter.git
base: /opt/trees
Running git pull
Already up-to-date.
```
