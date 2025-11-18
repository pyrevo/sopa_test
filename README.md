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
- **Multiple Segmentation Options**: CellPose (with GPU support), Baysor (config available), ProSeg, StarDist
- **Spatial Data Formats**: Support for Xenium, CosMx, Visium HD, and more
- **Analysis Stack**: scanpy, squidpy, geopandas, seaborn, numpy, pandas
- **Pixi Environment**: Efficient Python/R package management
- **Snakemake**: Workflow orchestration
- **Ubuntu 22.04**: Stable base system with required libraries

## 🔧 Usage

### Using Your Own Data Files

If you have spatial transcriptomics data on your local machine:

#### Step 1: Set up your project folder
```bash
# Create a project directory for your analysis
mkdir my_sopa_analysis
cd my_sopa_analysis

# Create the required 'input' subfolder
mkdir input
```

#### Step 2: Add your data files
```bash
# Copy your spatial transcriptomics files to the input folder
# For Xenium: transcripts.parquet, cells.parquet, morphology.ome.tif, etc.
# For CosMx: transcripts.csv, metadata_file.csv, etc.
cp /path/to/your/data/* input/
```

#### Step 3: Pull and run the container
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

### Interactive Container Usage

For more control, you can start the container interactively and run commands from inside:

```bash
# Start container with interactive shell
docker run --rm -it -v $(pwd):/data ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest bash

# Now you're inside the container, run SOPA commands:
cd /workspace
run-sopa --configfile workflow/config/xenium/cellpose.yaml --config data_path=/data/input

# Or explore the environment:
ls /data/input/
pixi run python --version
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

## 🧪 Testing Dependencies

To ensure all dependencies are properly included, run these tests:

```bash
# Test all dependencies are importable
docker run --rm ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest pixi run test-dependencies

# Test SOPA pipeline configurations load correctly
docker run --rm ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest pixi run test-pipeline-configs

# Test actual pipeline execution (dry run)
docker run --rm -v $(pwd):/data ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml --dry-run
```

## 🔍 Dependency Verification

To ensure we don't miss important dependencies, we:

1. **Check SOPA's optional dependencies** in `pyproject.toml`
2. **Include all segmentation backends**: CellPose, StarDist, Baysor, ProSeg
3. **Test imports** of all critical packages
4. **Validate config files** can be loaded
5. **Run dry-run tests** of the pipeline
6. **Monitor for runtime errors** during actual execution

The container includes all SOPA extras: `sopa[cellpose,stardist,baysor,wsi]`

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

### Missing Dependencies
If you encounter `ImportError` or `ModuleNotFoundError`:
```bash
# Test all dependencies
docker run --rm sopa-pipeline:latest pixi run test-dependencies

# Report the issue with the missing package name
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
