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
post_branch='", "repository":{"name":"tree-planter", "url":'\"https://github.com/${TRAVIS_REPO_SLUG}.git\"' }}'
payload="${pre_branch}master${post_branch}"
echo 'Posting this payload:'
echo ${payload}|jq -C .
echo

curl -s -H "Content-Type: application/json" -X POST -d "${payload}" http://127.0.0.1:80/gitlab

master_check=`ls -d ${TRAVIS_BUILD_DIR}/trees/tree-planter___master/ |wc -l`

if [ $master_check -eq 1 ]; then
  echo 'Successfully pulled master'

  echo
  echo "Testing that pulled files are owned by me (${USER})"
  ls -ld ${TRAVIS_BUILD_DIR}/trees/
  ls -ld ${TRAVIS_BUILD_DIR}/trees/tree-planter___master/

  if [ "`stat -c '%U' ${TRAVIS_BUILD_DIR}/trees`" != "`stat -c '%U' ${TRAVIS_BUILD_DIR}/trees/tree-planter___master/`" ]; then
    echo 'Ownership is not the same on ./trees and ./trees/tree-planter___master'
    exit 1
  fi
else
  echo 'Failed to pull master'
  exit 1
fi

echo "Testing pulling into alternate path"
post_branch_with_path='", "repository":{"name":"tree-planter", "url":'\"https://github.com/${TRAVIS_REPO_SLUG}.git\"'}, "repo_path":"custom_path"}'
payload_with_path="${pre_branch}master${post_branch_with_path}"
echo 'Posting this payload:'
echo ${payload_with_path}|jq -C .
echo

curl -s -H "Content-Type: application/json" -X POST -d "${payload_with_path}" http://127.0.0.1:80/gitlab

custom_path_check=`ls -d ${TRAVIS_BUILD_DIR}/trees/custom_path/ |wc -l`

if [ $custom_path_check -eq 1 ]; then
  echo 'Successfully pulled master to alternate path'

  echo
  echo "Testing that pulled files are owned by me (${USER})"
  ls -ld ${TRAVIS_BUILD_DIR}/trees/
  ls -ld ${TRAVIS_BUILD_DIR}/trees/custom_path/

  if [ "`stat -c '%U' ${TRAVIS_BUILD_DIR}/trees`" != "`stat -c '%U' ${TRAVIS_BUILD_DIR}/trees/custom_path/`" ]; then
    echo 'Ownership is not the same on ./trees and ./trees/custom_path'
    exit 1
  fi
else
  echo 'Failed to pull master to alternate path'
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
