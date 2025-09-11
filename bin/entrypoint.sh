#!/bin/sh

# Function to build sonar-scanner arguments
build_sonar_args() {
    local args=""
    
    # Add host URL if provided, otherwise rely on sonar-project.properties
    if [ -n "${PLUGIN_SONAR_URL}" ]; then
        args="$args -Dsonar.host.url=\"${PLUGIN_SONAR_URL}\""
    fi
    
    # SONAR_TOKEN is required
    if [ -z "${PLUGIN_SONAR_TOKEN}" ]; then
        echo "Error: PLUGIN_SONAR_TOKEN is required"
        exit 1
    fi
    args="$args -Dsonar.token=\"${PLUGIN_SONAR_TOKEN}\""
    
    # Add project name if provided, otherwise rely on sonar-project.properties
    if [ -n "${PLUGIN_SONAR_PROJECT_NAME}" ]; then
        args="$args -Dsonar.projectName=\"${PLUGIN_SONAR_PROJECT_NAME}\""
    fi
    
    # Add project key if provided, otherwise rely on sonar-project.properties
    if [ -n "${PLUGIN_SONAR_PROJECT_KEY}" ]; then
        args="$args -Dsonar.projectKey=\"${PLUGIN_SONAR_PROJECT_KEY}\""
    fi
    
    # Add debug flag if enabled
    if [ "${PLUGIN_SONAR_DEBUG}" = "true" ]; then
        args="$args -Dsonar.verbose=true"
    fi
    
    # Always add quality gate wait and CI links
    args="$args -Dsonar.qualitygate.wait=true"
    
    if [ -n "${CI_PIPELINE_URL}" ]; then
        args="$args -Dsonar.links.ci=\"${CI_PIPELINE_URL}\""
    fi
    
    if [ -n "${CI_PIPELINE_FORGE_URL}" ]; then
        args="$args -Dsonar.links.scm=\"${CI_PIPELINE_FORGE_URL}\""
    fi
    
    echo "$args"
}

# Check if sonar-project.properties exists and warn if required parameters are missing
if [ ! -f "sonar-project.properties" ] && { [ -z "${PLUGIN_SONAR_PROJECT_KEY}" ] || [ -z "${PLUGIN_SONAR_URL}" ]; }; then
    echo "Warning: sonar-project.properties not found and some required parameters are missing."
    echo "Either provide a sonar-project.properties file or set PLUGIN_SONAR_URL and PLUGIN_SONAR_PROJECT_KEY environment variables."
fi

if [ "$CI_PIPELINE_EVENT" = "pull_request" ]; then
    SONAR_ARGS=$(build_sonar_args)
    
    eval sonar-scanner "$SONAR_ARGS" \
        -Dsonar.pullrequest.key="\"${CI_COMMIT_PULL_REQUEST}\"" \
        -Dsonar.pullrequest.branch="\"${CI_COMMIT_SOURCE_BRANCH}\"" \
        -Dsonar.pullrequest.base="\"${CI_COMMIT_TARGET_BRANCH}\""

    [ $? -eq 0 ] || exit 1
    exit 0

elif [ "$CI_PIPELINE_EVENT" = "push" ] || [ "$CI_PIPELINE_EVENT" = "manual" ]; then

    SONAR_ARGS=$(build_sonar_args)
    
    eval sonar-scanner "$SONAR_ARGS" \
        -Dsonar.branch.name="\"${CI_COMMIT_BRANCH}\""

    [ $? -eq 0 ] || exit 1
    exit 0

else
    echo "Event $CI_PIPELINE_EVENT not supported!"
    exit 1
fi
