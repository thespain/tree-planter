#!/bin/bash

echo 'Running tests against the locally running container...'

root_check=`curl -s 127.0.0.1:80 | grep 'To use this tool you need to send a post to one of the following' -c`

if [ $root_check -eq 1 ]; then
  echo 'GET / rendered correctly'
else
  echo 'GET / did not render correctly'
  exit 1
fi

pre_branch='{"ref":"refs/heads/'
post_branch='", "repository":{"name":"tree-planter", "url":"https://github.com/genebean/tree-planter.git" }}'
payload="${pre_branch}master${post_branch}"
echo 'Posting this payload:'
echo ${payload}|jq -C .
echo

curl -s -H "Content-Type: application/json" -X POST -d "${payload}" http://127.0.0.1:80/gitlab

master_check=`ls -d ${TRAVIS_BUILD_DIR}/trees/tree-planter___master/ |wc -l`

if [ $master_check -eq 1 ]; then
  echo 'Successfully pulled master'
else
  echo 'Failed to pull master'
  exit 1
fi

if [ "${TRAVIS_BRANCH}" != "master" ] && [ "${TRAVIS_BRANCH}" != "develop" ]; then
  payload="${pre_branch}${TRAVIS_BRANCH}${post_branch}"
  echo 'Posting this payload:'
  echo ${payload}|jq -C .
  echo

  curl -s -H "Content-Type: application/json" -X POST -d "${payload}" http://127.0.0.1:80/gitlab
  branch_dir=`echo "tree-planter___${TRAVIS_BRANCH}" | sed 's/\//___/g'`
  branch_check=`ls -d ${TRAVIS_BUILD_DIR}/trees/${branch_dir}/ |wc -l`

  if [ $branch_check -eq 1 ];then
    echo "Successfully pulled the ${TRAVIS_BRANCH} branch"
  else
    echo "Failed to pull the ${TRAVIS_BRANCH} branch"
    exit 1
  fi
fi

