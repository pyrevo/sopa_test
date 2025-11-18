# SOPA Snakemake Pipeline User Guide

This Docker container provides the complete SOPA spatial transcriptomics Snakemake pipeline ready-to-use. No additional installation needed!

## Quick Start

### 1. Build the Container

```bash
# Clone the repository
git clone https://github.com/pyrevo/sopa_test.git
cd sopa_test

# Build the SOPA pipeline container
docker buildx build --platform linux/amd64 -t sopa-pipeline:latest . --load
```

### 2. Test Installation

```bash
# Check available commands and configs
docker run --rm sopa-pipeline:latest sopa-pipeline
```

### 3. Run Your First Analysis

```bash
# Run SOPA pipeline on your data
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input
```

## Pipeline Overview

The SOPA Snakemake pipeline automates the complete spatial transcriptomics analysis workflow:

1. **Data Conversion**: Convert raw data to SpatialData format
2. **Image Processing**: Create overlapping patches for analysis
3. **Segmentation**: Run cell segmentation (CellPose, Baysor, etc.)
4. **Aggregation**: Count transcripts within segmented cells
5. **Visualization**: Generate interactive explorer and reports

## Directory Structure

Place your input files in these folders on your host machine:

```
your_project/
├── data/
│   ├── input/          # Your spatial transcriptomics data
│   │                   # (Xenium output folder, CosMx files, etc.)
│   ├── output/         # Analysis results (auto-created)
│   └── results/        # Final results
```

These will be accessible at `/data/` inside the container.

## Configuration Files

Choose the appropriate config file for your data type:

### Xenium Data
```bash
# CellPose segmentation (recommended for most users)
run-sopa --configfile workflow/config/xenium/cellpose.yaml --config data_path=/data/input

# Baysor segmentation (for high-resolution analysis)
run-sopa --configfile workflow/config/xenium/baysor.yaml --config data_path=/data/input

# Combined CellPose + Baysor
run-sopa --configfile workflow/config/xenium/cellpose_baysor.yaml --config data_path=/data/input
```

### Other Platforms
```bash
# CosMx data
run-sopa --configfile workflow/config/cosmx/cellpose.yaml --config data_path=/data/input

# Visium HD data
run-sopa --configfile workflow/config/visium_hd/cellpose.yaml --config data_path=/data/input
```

## Basic Usage Examples

### Run Complete Pipeline

```bash
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 4
```

### Dry Run (see what will happen)

```bash
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --dry-run
```

### Custom Output Location

```bash
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input \
  --config sdata_path=/data/output/my_analysis.zarr
```

### Run Specific Steps Only

```bash
# Only run segmentation
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input resolve_cellpose

# Only run aggregation
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input aggregate
```

## Advanced Configuration

### Customize Segmentation Parameters

Create your own config file by copying and modifying existing ones:

```bash
# Copy a template
docker run --rm sopa-pipeline:latest \
  cat workflow/config/xenium/cellpose.yaml > my_config.yaml

# Edit my_config.yaml with your parameters
# Then run with your custom config
docker run --rm -v $(pwd)/data:/data -v $(pwd)/my_config.yaml:/workspace/my_config.yaml sopa-pipeline:latest \
  run-sopa --configfile /workspace/my_config.yaml --config data_path=/data/input
```

### Memory and Performance

```bash
# Use multiple cores for faster processing
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 8

# Limit memory usage
docker run --rm -v $(pwd)/data:/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --resources mem_mb=16000
```

## Output Files

After successful completion, the pipeline generates:

- **`/data/input.zarr/`**: SpatialData Zarr store with processed data
- **`/data/input.explorer/experiment.xenium`**: Interactive explorer file
- **`/data/input.explorer/analysis_summary.html`**: HTML report
- **Segmentation results**: Cell boundaries and properties in the Zarr store

## Troubleshooting

### Container won't start on Mac M1/M2
Add `--platform linux/amd64` to your docker run command.

### Permission denied errors
Make sure the data directories have proper permissions:
```bash
chmod -R 755 data/
```

### Out of memory
Increase Docker memory in Docker Desktop settings (8GB+ recommended for large datasets).

### Pipeline fails with "No such file or directory"
Check that your data path is correct and the files exist:
```bash
ls -la data/input/
```

### Segmentation parameters not working
Verify your config file syntax:
```bash
docker run --rm -v $(pwd)/my_config.yaml:/workspace/my_config.yaml sopa-pipeline:latest \
  python -c "import yaml; print(yaml.safe_load(open('/workspace/my_config.yaml')))"
```

## Getting Help

### Available Commands
```bash
# Show pipeline help
docker run --rm sopa-pipeline:latest sopa-pipeline

# List all config files
docker run --rm sopa-pipeline:latest find workflow/config -name "*.yaml"

# Check Snakemake version
docker run --rm sopa-pipeline:latest pixi run snakemake --version
```

### Config File Reference
```bash
# View example config with all options
docker run --rm sopa-pipeline:latest cat workflow/config/example_commented.yaml
```

## Tools Included

- **SOPA Snakemake Pipeline**: Complete analysis workflow
- **Multiple Segmentation Methods**: CellPose, Baysor, ProSeg, StarDist
- **Data Format Support**: Xenium, CosMx, Visium HD, MERSCOPE, etc.
- **Python Scientific Stack**: numpy, pandas, scanpy, squidpy
- **Snakemake**: Workflow management
- **SpatialData**: Modern spatial omics data format

## Next Steps

After running the pipeline:

1. **Open the Explorer**: The `.xenium` file can be opened in spatial analysis tools
2. **View Reports**: Check `analysis_summary.html` for quality metrics
3. **Access Results**: Load the `.zarr` file in Python for further analysis
4. **Customize Analysis**: Modify config files for your specific needs

## Contact

For issues or questions, please contact [your-email@example.com]
