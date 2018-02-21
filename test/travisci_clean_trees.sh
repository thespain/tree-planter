#!/bin/bash
set -e

echo "Removing all files from ${TRAVIS_BUILD_DIR}/trees/"
rm -rf ${TRAVIS_BUILD_DIR}/trees/*

