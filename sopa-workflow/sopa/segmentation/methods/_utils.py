import shutil
from pathlib import Path


def _get_executable_path(name: str, default_dir: str) -> Path | str:
    import os
    # Apptainer support: if BAYSOR_APPTAINER_IMAGE is set, use apptainer exec
    apptainer_image = os.environ.get("BAYSOR_APPTAINER_IMAGE")
    if apptainer_image:
        # Return a command template to be formatted with the actual baysor command
        return f"apptainer exec {apptainer_image} baysor"
        if not apptainer_image:
            # Use vpetukhov/baysor:latest from Docker Hub by default
            apptainer_image = "docker://vpetukhov/baysor:latest"
        if apptainer_image:
            return f"apptainer exec {apptainer_image} baysor"

    if shutil.which(name) is not None:
        return name

    default_path = Path.home() / default_dir / "bin" / name
    if default_path.exists():
        return default_path

    bin_path = Path.home() / ".local" / "bin" / name
    raise FileNotFoundError(
        f"Please install {name} and ensure that either `{default_path}` executes {name}, or that `{name}` is an existing command (add it to your PATH, or create a symlink at {bin_path})."
    )
