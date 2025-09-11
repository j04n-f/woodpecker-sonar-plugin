FROM ubuntu:24.04

# Install Node.js and sonar-scanner dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    openjdk-17-jre \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV SONAR_SCANNER_VERSION=7.2.0.5079

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME=/usr/share/maven
ENV PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

RUN mkdir -p /opt && \
    curl -fSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip -o /opt/sonar-scanner.zip && \
    unzip -qq /opt/sonar-scanner.zip -d /opt && \
    mv /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64 /sonar-scanner && \
    rm /opt/sonar-scanner.zip && \
    ln -s /sonar-scanner/bin/sonar-scanner /bin/sonar-scanner && \
    sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /sonar-scanner/bin/sonar-scanner

ENV PATH="/opt/sonar-scanner/bin:${PATH}"

COPY bin/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]