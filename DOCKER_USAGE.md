# Docker Usage Guide for SOPA-Baysor Benchmark

## Quick Start

### Build the Docker Image

```bash
# Build locally
docker build -t sopa-baysor:local .

# Or use docker-compose
docker-compose build

# Or use the helper script
chmod +x scripts/build_and_test.sh
./scripts/build_and_test.sh
```

### Running on Mac M1 (via Rosetta)

```bash
# Build for linux/amd64 platform
docker buildx build --platform linux/amd64 -t sopa-baysor:local .

# Run with platform flag
docker run --platform linux/amd64 -it --rm sopa-baysor:local
```

## Running the Container

### Interactive Shell

```bash
# Using docker-compose
docker-compose run --rm sopa-baysor

# Using docker directly
docker run -it --rm \
    -v $(pwd)/data:/data \
    -v $(pwd)/results:/data/results \
    sopa-baysor:local

# Using helper script
chmod +x scripts/run_docker.sh
./scripts/run_docker.sh
```

### Run Specific Commands

```bash
# Run all tests
docker-compose run --rm sopa-baysor pixi run test-all

# Run SOPA test
docker-compose run --rm sopa-baysor pixi run test-sopa

# Install and test Baysor
docker-compose run --rm sopa-baysor pixi run install-baysor
docker-compose run --rm sopa-baysor pixi run test-baysor
```

### Start Jupyter Lab

```bash
# Using docker-compose
docker-compose up jupyter

# Using docker directly
docker run -it --rm \
    -p 8888:8888 \
    -v $(pwd)/data:/data \
    -v $(pwd)/notebooks:/workspace/notebooks \
    sopa-baysor:local \
    pixi run jupyter

# Access at: http://localhost:8888
```

## Example Workflows

### SOPA Segmentation

```bash
docker-compose run --rm sopa-baysor pixi run python scripts/run_sopa.py \
    --input /data/input/sample.h5ad \
    --output /data/output/sopa
```

### Baysor Segmentation

```bash
docker-compose run --rm sopa-baysor pixi run baysor run \
    --config /workspace/configs/baysor_config.toml \
    -o /data/output/baysor \
    /data/input/transcripts.csv \
    :cell_id
```

## GitHub Actions

The repository includes automated Docker builds via GitHub Actions:

- **Triggers**: Pushes to main, PRs, or manual workflow dispatch
- **Builds**: Multi-arch images (linux/amd64, linux/arm64)
- **Registry**: GitHub Container Registry (ghcr.io)
- **Tags**: Branch names, PRs, SHAs, and `latest` for main branch

### Pulling from GitHub Container Registry

```bash
# Pull the latest image
docker pull ghcr.io/pyrevo/sopa_test/sopa-baysor:latest

# Run it
docker run -it --rm ghcr.io/pyrevo/sopa_test/sopa-baysor:latest
```

## Directory Structure

```
```
.
├── Dockerfile                      # Docker build configuration
├── pixi.toml                       # Dependency management
├── docker-compose.yml              # Service orchestration
├── .github/
│   └── workflows/
│       └── docker-build.yml        # CI/CD pipeline
├── data/
```

## Troubleshooting

### Issue: Baysor installation fails
**Solution**: Baysor requires Julia. Ensure the `install-baysor` task runs successfully.
```bash
docker-compose run --rm sopa-baysor pixi run install-baysor
```

### Issue: Permission denied on volumes
**Solution**: Fix permissions on mounted directories.
```bash
chmod -R 777 data/ results/
```

### Issue: Out of memory during build
**Solution**: Increase Docker memory in Docker Desktop settings (recommend 16GB+).

### Issue: M1 Mac compatibility
**Solution**: Some packages may not have ARM builds. Use platform flag:
```bash
docker build --platform linux/amd64 -t sopa-baysor:local .
docker run --platform linux/amd64 -it --rm sopa-baysor:local
```

### Issue: SOPA/Baysor version conflicts
**Solution**: Check pixi.lock for exact versions.
```bash
# Update dependencies
pixi update
# Rebuild Docker image
docker-compose build --no-cache
```

## Resource Requirements

- **CPU**: 4-8 cores recommended
- **Memory**: 16-32GB recommended
- **Disk**: 20GB+ for Docker image and data

## Development

### Adding New Dependencies

1. Edit `pixi.toml` to add packages
2. Rebuild the Docker image:
   ```bash
   docker-compose build --no-cache
   ```

### Testing Changes

1. Make changes to Dockerfile or pixi.toml
2. Run build and test script:
   ```bash
   ./scripts/build_and_test.sh
   ```

### Debugging

```bash
# Enter container with bash shell
docker-compose run --rm sopa-baysor bash

# Check installed packages
pixi list

# Check Python packages
pixi run python -c "import sys; print(sys.path)"
pixi run pip list

# Check Julia packages
pixi run julia -e 'using Pkg; Pkg.status()'
```
