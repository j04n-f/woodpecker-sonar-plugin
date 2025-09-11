#!/bin/bash

set -e

echo
echo "🚀 Starting SonarQube plugin tests..."
echo

echo "🏗️  Building SonarQube image..."
echo
docker build -f $PWD/test/Dockerfile.sonar -t sonarqube:community .
echo

echo "📦 Starting SonarQube container..."
echo
docker run -d --name sonarqube-test -p 9000:9000 sonarqube:community