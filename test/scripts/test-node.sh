#!/bin/bash

set -e

echo
echo "🚀 Starting SonarQube plugin test for Node.js..."
echo
echo "⏳ Waiting for SonarQube to be ready..."
echo
timeout 300 bash -c 'until curl -f http://localhost:9000/api/system/status 2>/dev/null | grep -q UP; do echo "Waiting..."; sleep 5; done'
echo ""
echo "✅ SonarQube is ready!"
echo
echo "🔧 Setting up test project..."
echo
SONAR_TOKEN=$(curl -s -u admin:admin -X POST "http://localhost:9000/api/user_tokens/generate" -d "name=test-token-node" | jq -r '.token')

curl -s -u admin:admin -X POST "http://localhost:9000/api/projects/create" \
  -d "project=test-node-project" \
  -d "name=Test Project" > /dev/null

echo "🧪 Test Node.js Analysis"
echo
docker run --rm \
  --network host \
  -v $PWD/test/node:/woodpecker \
  -w /woodpecker \
  -e CI_PIPELINE_EVENT=push \
  -e CI_COMMIT_BRANCH=main \
  -e CI_PIPELINE_URL=http://localhost:8080/pipeline/1 \
  -e CI_PIPELINE_FORGE_URL=http://localhost:8080/repo \
  -e PLUGIN_SONAR_TOKEN=$SONAR_TOKEN \
  -e PLUGIN_SONAR_URL=http://localhost:9000 \
  -e PLUGIN_SONAR_PROJECT_KEY=test-node-project \
  -e PLUGIN_SONAR_PROJECT_NAME="Test Project" \
  sonar-plugin:node

echo
ANALYSIS_COUNT=$(curl -s -u admin:admin "http://localhost:9000/api/project_analyses/search?project=test-node-project" | jq '.analyses | length')
if [ "$ANALYSIS_COUNT" -eq "1" ]; then
  echo "✅ All tests passed! Node.js project analysis completed successfully with exactly 1 analysis performed."
else
  echo "❌ Test failed! Expected exactly 1 analysis, but found $ANALYSIS_COUNT analyses."
  exit 1
fi
