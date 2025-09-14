# Woodpecker SonarQube Plugin

A Docker-based plugin for [Woodpecker CI](https://woodpecker-ci.org/) that integrates with SonarQube for code quality analysis. This plugin supports multiple programming languages including Node.js, Go, and Flutter/Dart.

## Quick Start

### Basic Usage

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

See the [DOCS](./docs.md) for usage instructions and documentation.

## Development

### Prerequisites

- Docker and Docker Compose
- Git
- Bash shell
- `curl` and `jq` (for setup script)

### Development Environment Setup

This project includes a complete development environment with Gitea (Git forge), Woodpecker CI, and SonarQube for testing the plugin locally.

#### Quick Setup

1. **Build the plugin images first:**
   ```bash
   ./scripts/build.sh
   ```

2. **Start the development environment:**
   ```bash
   ./scripts/setup-environment.sh
   ```

   This script will:
   - Start Gitea, Woodpecker CI, and SonarQube services
   - Create a Gitea admin user (`woodpecker/woodpecker123`)
   - Configure OAuth for Woodpecker-Gitea integration
   - Create a test repository (`test-sonar-plugin`)
   - Set up SonarQube with a test project
   - Generate API tokens and configure services

3. **Complete manual setup steps:**
   - Login to Woodpecker at http://localhost:8000
   - Enable the test repository
   - Add the SonarQube token as a secret (provided by setup script)

### Building Images

Build all variants:
```bash
./scripts/build.sh
```

Build specific variant:
```bash
./scripts/build.sh --variant node
```

Build and push to registry:
```bash
./scripts/build.sh --registry ghcr.io/your-org/repo --push
```

### Testing

#### Local Development Testing

1. **Start the development environment** (if not already running):
   ```bash
   ./scripts/setup-environment.sh
   ```

2. **Navigate to the test project:**
   ```bash
   cd test/node
   ```

3. **Initialize git and push to test:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin http://localhost:3000/woodpecker/test-sonar-plugin.git
   git push -u origin main
   ```

   This will trigger a Woodpecker pipeline that uses the local plugin image.

#### Automated Test Suite

Run the comprehensive test suite:
```bash
./test/run.sh
```

### Development Workflow

1. **Make changes** to the plugin code
2. **Rebuild images:** `./scripts/build.sh`
3. **Test changes** by pushing to the test repository
4. **Monitor pipeline** in Woodpecker UI
5. **Check results** in SonarQube UI

### Project Structure

```
├── bin/entrypoint.sh              # Main plugin entrypoint
├── docker/                        # Dockerfile variants
│   ├── Dockerfile                # Base image
│   ├── Dockerfile.node           # Node.js variant
│   ├── Dockerfile.go             # Go variant
│   └── Dockerfile.flutter        # Flutter variant
├── scripts/
│   ├── build.sh                  # Build script for all variants
│   └── setup-environment.sh      # Development environment setup
├── test/                          # Test projects and scripts
│   ├── node/                     # Node.js test project
│   ├── go/                       # Go test project
│   ├── flutter/                  # Flutter test project
│   └── run.sh                    # Test runner script
├── docker-compose.yml            # Development services
└── .env                          # Generated OAuth credentials
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Set up development environment: `./scripts/setup-environment.sh`
4. Build plugin images: `./scripts/build.sh`
5. Add tests for your changes
6. Run the test suite: `./test/run.sh`
7. Test with the local development environment
8. Submit a pull request

---

For more information about Woodpecker CI plugins, visit the [official documentation](https://woodpecker-ci.org/docs/usage/plugins/overview).
