#!/bin/bash

set -e

echo
echo "🧹 Cleaning up..."
echo

docker stop sonarqube-test
docker rm sonarqube-test

echo
echo "🎉 Cleanup completed successfully!"