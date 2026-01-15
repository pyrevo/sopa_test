# Use the official NVIDIA CUDA base image
# This image is based on Ubuntu 22.04 and includes CUDA 12.6.0
FROM nvidia/cuda:12.6.0-base-ubuntu22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /workspace

# Install system dependencies required for SOPA and scientific computing
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    libgl1 \
    libglib2.0-0 \
    build-essential \
    libhdf5-dev \
    libgeos-dev \
    libproj-dev \
    unzip \
    curl \
    git \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages via pip
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    geopandas \
    shapely \
    anndata \
    zarr \
    scanpy \
    squidpy \
    jupyter \
    jupyterlab \
    snakemake

# Install PyTorch with CUDA 12.6 support
RUN pip install --no-cache-dir \
    torch==2.6.0 \
    torchvision==0.21.0 \
    torchaudio==2.6.0 \
    --index-url https://download.pytorch.org/whl/cu126

# Install SOPA and Cellpose
RUN pip install --no-cache-dir \
    sopa \
    cellpose==3.1.0


# Install Apptainer (Singularity) from official release
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    squashfs-tools \
    libseccomp-dev \
    uidmap \
    fuse2fs \
    cryptsetup \
    runc \
    libfuse3-3 \
    fakeroot \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/apptainer/apptainer/releases/download/v1.3.1/apptainer_1.3.1_amd64.deb \
    && dpkg -i apptainer_1.3.1_amd64.deb \
    && rm apptainer_1.3.1_amd64.deb

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
snakemake -s workflow/Snakefile "$@"
EOF
RUN chmod +x /usr/local/bin/run-sopa

# Default command to show help
CMD ["sopa-pipeline"]

# Metadata
LABEL maintainer="massimiliano.volpe@scilifelab.se"
LABEL description="SOPA for spatial transcriptomics segmentation with NVIDIA CUDA support"
LABEL version="2.0"
LABEL cuda.version="12.6"