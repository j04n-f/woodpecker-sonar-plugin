---
name: SonarQube
icon: https://raw.githubusercontent.com/j04n-f/woodpecker-sonar-plugin/refs/heads/main/sonar.svg
description: A Docker-based plugin for Woodpecker CI that integrates with SonarQube for code quality analysis
author: Woodpecker CI SonarQube Plugin Contributors
tags: [sonarqube, code-quality, analysis, testing]
containerImage: ghcr.io/j04n-f/sonar-plugin
containerImageUrl: https://github.com/j04n-f/woodpecker-sonar-plugin/pkgs/container/sonar-plugin
url: https://github.com/j04n-f/woodpecker-sonar-plugin
---

# woodpecker-sonar-plugin

A Docker-based plugin for [Woodpecker CI](https://woodpecker-ci.org/) that integrates with SonarQube for code quality analysis. This plugin supports multiple programming languages including Node.js, Go, and Flutter/Dart.

## Basic Usage

Add this step to your `.woodpecker.yml` pipeline:

```yaml
steps:
  - name: code-analysis
    image: ghcr.io/j04n-f/sonar-plugin
    settings:
      sonar_token:
        from_secret: sonar_token
      sonar_url: https://sonarcloud.io
      sonar_project_key: your-project-key
      sonar_project_name: "Your Project Name"
```

### Debug Mode

For troubleshooting and verbose logging:

```yaml
steps:
  - name: code-analysis
    image: ghcr.io/j04n-f/sonar-plugin
    settings:
      sonar_token:
        from_secret: sonar_token
      sonar_url: https://sonarcloud.io
      sonar_project_key: your-project-key
      sonar_debug: true
```

## Language-Specific Variants

### Node.js Projects
```yaml
steps:
  - name: code-analysis
    image: ghcr.io/j04n-f/sonar-plugin:node
    settings:
      sonar_token:
        from_secret: sonar_token
      sonar_url: https://sonarcloud.io
      sonar_project_key: your-node-project
```

### Go Projects
```yaml
steps:
  - name: code-analysis
    image: ghcr.io/j04n-f/sonar-plugin:go
    settings:
      sonar_token:
        from_secret: sonar_token
      sonar_url: https://sonarcloud.io
      sonar_project_key: your-go-project
```

### Flutter Projects
```yaml
steps:
  - name: code-analysis
    image: ghcr.io/j04n-f/sonar-plugin:flutter
    settings:
      sonar_token:
        from_secret: sonar_token
      sonar_url: https://sonarcloud.io
      sonar_project_key: your-flutter-project
```

## Settings

| Settings Name          | Default | Description                                                                        |
| ---------------------- | ------- | ---------------------------------------------------------------------------------- |
| `sonar_token`          | _none_  | **Required.** SonarQube authentication token                                       |
| `sonar_url`            | _none_  | SonarQube server URL (can be set in sonar-project.properties)                     |
| `sonar_project_key`    | _none_  | Project key (can be set in sonar-project.properties)                              |
| `sonar_project_name`   | _none_  | Project display name (can be set in sonar-project.properties)                     |
| `sonar_debug`          | `false` | Enable verbose logging for debugging (set to `true`)                              |

## Configuration with sonar-project.properties

Alternatively, you can configure your project using a `sonar-project.properties` file in your repository root:

```properties
sonar.host.url=https://sonarcloud.io
sonar.projectKey=your-project-key
sonar.projectName=Your Project Name
sonar.projectVersion=1.0.0

# Source configuration
sonar.sources=src/
sonar.tests=test/
sonar.sourceEncoding=UTF-8
```

## Available Docker Images

- `sonar-plugin` - Base image with SonarScanner CLI
- `sonar-plugin:node` - Includes Node.js runtime
- `sonar-plugin:go` - Includes Go runtime  
- `sonar-plugin:flutter` - Includes Flutter/Dart SDK
