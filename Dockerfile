# Main build: Ubuntu with SOPA Snakemake pipeline
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /workspace

# Install system dependencies
# - curl: for downloading pixi and other tools
# - git: for cloning repositories
# - build-essential: C/C++ compilers needed by some packages
# - libhdf5-dev: HDF5 support for data files
# - libgeos-dev: Geometry library for spatial operations
# - libproj-dev: Cartographic projections
# - wget: for downloading additional tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libhdf5-dev \
    libgeos-dev \
    libproj-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install pixi (cross-platform package manager)
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:${PATH}"

# Copy pixi configuration files
COPY pixi.toml pixi.lock* ./

# Install all dependencies via pixi (including Snakemake)
RUN pixi install

# Copy the SOPA workflow
COPY sopa-workflow/workflow /workspace/workflow

# Create directories for input/output
RUN mkdir -p /data/input /data/output /data/results

# Create wrapper script for SOPA Snakemake pipeline
RUN cat > /usr/local/bin/sopa-pipeline << 'EOF'
#!/bin/bash
echo "SOPA Snakemake Pipeline"
echo "======================="
echo ""
echo "Usage: sopa-pipeline --configfile /path/to/config.yaml --config data_path=/path/to/data"
echo ""
echo "Available config templates:"
echo "  - workflow/config/xenium/"
echo "  - workflow/config/cosmx/"
echo "  - workflow/config/visium_hd/"
echo "  - workflow/config/example_commented.yaml"
echo ""
echo "Example:"
echo "  sopa-pipeline --configfile workflow/config/xenium/xenium.yaml --config data_path=/data/input"
echo ""
EOF
RUN chmod +x /usr/local/bin/sopa-pipeline

# Create a run script that sets up the environment and runs snakemake
RUN cat > /usr/local/bin/run-sopa << 'EOF'
#!/bin/bash
cd /workspace
pixi run snakemake -s workflow/Snakefile "$@"
EOF
RUN chmod +x /usr/local/bin/run-sopa

# Set the default command to show help
CMD ["sopa-pipeline"]

# Metadata
LABEL maintainer="massimiliano.volpe@scilifelab.se"
LABEL description="SOPA for spatial transcriptomics segmentation"
LABEL version="2.0"