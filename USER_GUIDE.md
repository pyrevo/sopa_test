# SOPA Snakemake Pipeline User Guide

This Docker container provides the complete SOPA spatial transcriptomics Snakemake pipeline ready-to-use. No additional installation needed!

## Quick Start

### 1. Get the Container

```bash
# Pull the pre-built container
docker pull ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest
```

### 2. Organize Your Data

Create a project folder and organize your files like this:

```bash
# Create your project directory
mkdir my_sopa_project
cd my_sopa_project

# Create the required 'input' folder
mkdir input

# Copy your spatial transcriptomics data files to the input folder
# For Xenium: transcripts.parquet, cells.parquet, morphology.ome.tif, etc.
# For CosMx: transcripts.csv, metadata_file.csv, etc.
cp /path/to/your/data/files/* input/
```

**Required directory structure:**
```
/your/project/folder/
├── input/           # Put your spatial transcriptomics data here
│   ├── transcripts.parquet    # Xenium data
│   ├── cells.parquet         # Xenium data
│   └── morphology.ome.tif     # Xenium data
│   # OR for CosMx:
│   ├── transcripts.csv
│   └── metadata_file.csv
└── output/          # This will be created automatically with results
```

### 3. Run SOPA on Your Data

```bash
# Replace /your/project/folder with your actual folder path
docker run --rm \
  -v /your/project/folder:/data \
  ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input \
  --config sdata_path=/data/output/analysis.zarr
```

### 4. Access Results

After the pipeline completes, your results will be in `/your/project/folder/output/`:
- `analysis.zarr/` - SpatialData with processed results
- `analysis.explorer/` - Interactive visualization files
- `analysis_summary.html` - Quality metrics report

## Pipeline Overview

The SOPA Snakemake pipeline automates the complete spatial transcriptomics analysis workflow:

1. **Data Conversion**: Convert raw data to SpatialData format
2. **Image Processing**: Create overlapping patches for analysis
3. **Segmentation**: Run cell segmentation (CellPose, Baysor, etc.)
4. **Aggregation**: Count transcripts within segmented cells
5. **Visualization**: Generate interactive explorer and reports

## Data Preparation

### Supported Data Types

The SOPA pipeline supports multiple spatial transcriptomics platforms:

#### Xenium Data
- **Input**: Xenium analyzer output directory
- **Contains**: `transcripts.parquet`, `cells.parquet`, morphology images, etc.
- **Config**: `workflow/config/xenium/cellpose.yaml`

#### CosMx Data
- **Input**: CosMx analysis output directory  
- **Contains**: `transcripts.csv`, `metadata_file.csv`, etc.
- **Config**: `workflow/config/cosmx/cellpose.yaml`

#### Visium HD Data
- **Input**: Space Ranger output directory
- **Contains**: `spatial/tissue_positions.parquet`, `filtered_feature_bc_matrix/`, etc.
- **Config**: `workflow/config/visium_hd/stardist.yaml`

### Directory Structure

Your data directory should contain the raw files from your spatial transcriptomics platform. For example:

```
your_xenium_data/
├── transcripts.parquet
├── cells.parquet
├── cell_boundaries.parquet
├── morphology.ome.tif
├── experiment.xenium
└── ...
```

### Mounting Data to Container

Use Docker volume mounts (`-v`) to make your local data accessible:

```bash
# Mount your project folder to /data inside container
-v /Users/username/my_project:/data
```

**Important**: Use absolute paths, not relative paths like `~/data` or `./data`.

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
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 4
```

### Dry Run (see what will happen)

```bash
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --dry-run
```

### Custom Output Location

```bash
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input \
  --config sdata_path=/data/output/analysis.zarr
```

### Run Specific Steps Only

```bash
# Only run segmentation
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input resolve_cellpose

# Only run aggregation
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input aggregate
```

### Interactive Usage

For debugging or running multiple commands, start the container interactively:

```bash
# Start container with interactive shell
docker run --rm -it -v $(pwd):/data ghcr.io/pyrevo/sopa_test/sopa-pipeline:latest bash

# Now you're inside the container - you can run commands interactively:
cd /workspace

# Check your data
ls -la /data/input/

# Run SOPA pipeline
run-sopa --configfile workflow/config/xenium/cellpose.yaml --config data_path=/data/input

# Test different configurations
run-sopa --configfile workflow/config/xenium/baysor.yaml --config data_path=/data/input --dry-run

# Exit when done
exit
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
docker run --rm -v $(pwd):/data -v $(pwd)/my_config.yaml:/workspace/my_config.yaml sopa-pipeline:latest \
  run-sopa --configfile /workspace/my_config.yaml --config data_path=/data/input
```

### Memory and Performance

```bash
# Use multiple cores for faster processing
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
  run-sopa --configfile workflow/config/xenium/cellpose.yaml \
  --config data_path=/data/input --cores 8

# Limit memory usage
docker run --rm -v $(pwd):/data sopa-pipeline:latest \
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
ls -la /path/to/your/project/input/
```

### Segmentation parameters not working
Verify your config file syntax:
```bash
docker run --rm -v $(pwd):/data -v $(pwd)/my_config.yaml:/workspace/my_config.yaml sopa-pipeline:latest \
  python -c "import yaml; print(yaml.safe_load(open('/workspace/my_config.yaml')))"
```

### Permission issues with mounted volumes
Ensure your data directories have proper permissions:
```bash
# On macOS/Linux
chmod -R 755 /path/to/your/data/

# On Windows, ensure Docker has access to the drive/folder
```

### Container can't find my data files
- Use **absolute paths** in volume mounts (not `~/` or `./`)
- Ensure the data directory exists before running
- Check that files aren't hidden or have special characters in names

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
- **Multiple Segmentation Methods**: CellPose (with GPU support), Baysor (config available), ProSeg, StarDist
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
