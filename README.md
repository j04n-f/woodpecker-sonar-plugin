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

The project includes comprehensive tests for all language variants: Run tests:

```bash
./test/run.sh
```

### Project Structure

```
├── bin/entrypoint.sh          # Main plugin entrypoint
├── docker/                    # Dockerfile variants
│   ├── Dockerfile            # Base image
│   ├── Dockerfile.node       # Node.js variant
│   ├── Dockerfile.go         # Go variant
│   └── Dockerfile.flutter    # Flutter variant
├── scripts/build.sh          # Build script
├── test/                     # Test projects and scripts
└── docker-compose.yml        # Development SonarQube instance
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Run the test suite
5. Submit a pull request

---

For more information about Woodpecker CI plugins, visit the [official documentation](https://woodpecker-ci.org/docs/usage/plugins/overview).
