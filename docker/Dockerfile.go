FROM sonar-plugin

# Install Node.js and sonar-scanner dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    make \
    golang-go \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*