# SOPA Snakemake Pipeline Docker Container

Docker-based environment providing the complete SOPA spatial transcriptomics Snakemake pipeline ready-to-use.

## 🎯 Purpose

This repository provides a ready-to-use Docker container with the official SOPA Snakemake pipeline, allowing collaborators to run complete spatial transcriptomics analysis workflows without complex installation steps.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Git

### Get the Container

```bash
# Clone the repository
git clone https://github.com/pyrevo/sopa_test.git
cd sopa_test

# Build the SOPA pipeline container
docker buildx build --platform linux/amd64 -t sopa-pipeline:latest . --load
```

### Test Installation

```bash
# Check available commands
docker run --rm sopa-pipeline:latest sopa-pipeline
```

## 📦 What's Included

- **SOPA Snakemake Pipeline**: Complete workflow with all segmentation methods
- **Multiple Segmentation Options**: CellPose, Baysor, ProSeg, StarDist
- **Spatial Data Formats**: Support for Xenium, CosMx, Visium HD, and more
- **Analysis Stack**: scanpy, squidpy, geopandas, seaborn, numpy, pandas
- **Pixi Environment**: Efficient Python/R package management
- **Snakemake**: Workflow orchestration
- **Ubuntu 22.04**: Stable base system with required libraries

## 🔧 Usage

### Using Your Own Data Files

If you have spatial transcriptomics data on your local machine:

```bash
# Pull the container (one time only)
docker pull ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest

# Run SOPA on your data
# Replace /path/to/your/project with your working directory
# Put your data in a subfolder called 'input'
# Results will be saved in 'output' subfolder

docker run --rm \
  -v /path/to/your/project:/data \
  ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input \
  --config sdata_path=/data/output/analysis.zarr
```

**Example directory structure:**
```
/path/to/your/project/
├── input/           # Put your Xenium/CosMx data here
│   ├── transcripts.parquet
│   ├── cells.parquet
│   └── ...
└── output/          # Results will be created here
    ├── analysis.zarr/
    ├── analysis.explorer/
    └── analysis_summary.html
```

### Basic Pipeline Commands

```bash
# Show help and available configs
docker run --rm sopa-pipeline:latest sopa-pipeline

# Run SOPA pipeline (mount your current directory)
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input

# Run with multiple cores for faster processing
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 4
```

The container includes configs for multiple platforms:

**Xenium:**
- `workflow/config/xenium/cellpose.yaml` - CellPose segmentation
- `workflow/config/xenium/baysor.yaml` - Baysor segmentation
- `workflow/config/xenium/cellpose_baysor.yaml` - Combined approach

**Other Platforms:**
- `workflow/config/cosmx/` - CosMx data
- `workflow/config/visium_hd/` - Visium HD data
- `workflow/config/example_commented.yaml` - Template with all options

### Advanced Usage

```bash
# Dry run to see what will be executed (no actual processing)
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --dry-run

# Run specific rule only (e.g., just segmentation)
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input resolve_cellpose

# Use multiple cores for faster processing
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 8
```

## 📁 Directory Structure

```
sopa_test/
├── Dockerfile              # SOPA pipeline container build
├── pixi.toml              # Python/R dependencies
├── sopa-workflow/         # Official SOPA repository
│   └── workflow/          # Snakemake pipeline
├── README.md              # This file
├── data/
│   ├── input/            # Your spatial transcriptomics data
│   ├── output/           # Analysis results (auto-created)
│   └── results/          # Final results
└── scripts/
    ├── build_and_test.sh # Build helper
    └── run_docker.sh     # Run helper
```

## 📊 Pipeline Output

The SOPA pipeline generates:

- **SpatialData Zarr**: `/data/input.zarr` - Processed spatial data
- **Explorer Files**: `/data/input.explorer/` - Interactive visualization
- **Reports**: `analysis_summary.html` - Analysis summary
- **Segmentation Results**: Cell boundaries and transcript assignments

## 🛠 Troubleshooting

### M1 Mac Users
Use `--platform linux/amd64` for compatibility:
```bash
docker buildx build --platform linux/amd64 -t sopa-pipeline:latest . --load
```

### Memory Issues
Increase Docker memory allocation (8GB+ recommended for large datasets).

### Permission Issues
```bash
# Fix data directory permissions
chmod -R 755 data/
```

### Pipeline Errors
```bash
# Check available config options
docker run --rm sopa-pipeline:latest cat workflow/config/example_commented.yaml
```

## 📖 Documentation

- [SOPA Documentation](https://gustaveroussy.github.io/sopa) - Official SOPA docs
- [Snakemake Documentation](https://snakemake.readthedocs.io/) - Workflow details
- [DOCKER_USAGE.md](DOCKER_USAGE.md) - Detailed Docker usage
- [SETUP_VERIFICATION.md](SETUP_VERIFICATION.md) - Setup verification steps

## 🔄 Future Plans

- Add example datasets for testing
- Include benchmarking scripts
- Add support for custom segmentation methods
- Integrate with Nextflow for HPC environments

## 📝 License

[Add your license here]
