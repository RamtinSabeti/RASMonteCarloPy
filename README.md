
# HEC-RAS Simulation and Monte Carlo Experiment Workflow

This repository provides a comprehensive Python script to facilitate hydraulic simulations and uncertainty analyses using HEC-RAS. The script integrates multiple functionalities, including:

- Extracting depth time series from HDF5 files.
- Generating Monte Carlo experiments for hydraulic models.
- Running HEC-RAS simulations in parallel groups.

## Features

1. **Depth Time Series Extraction**:
   - Extracts water depth time series data from HDF files.
   - Customizable parameters for time range and cell index.

2. **Monte Carlo Experiment Generator**:
   - Creates modified hydrographs based on random peak increases.
   - Supports flexible land cover Manning's n values.

3. **Parallel HEC-RAS Simulations**:
   - Automates the execution of multiple HEC-RAS projects in parallel.
   - Optimized for batch processing.

## Prerequisites

1. **Python Packages**:
   - `numpy`
   - `h5py`
   - `matplotlib`
   - `multiprocessing` (built-in)
   - `pywin32`

   Install the required packages via:
   ```bash
   pip install numpy h5py matplotlib pywin32
   ```

2. **HEC-RAS**:
   - Ensure HEC-RAS is installed on your system.
   - Verify the COM interface (`RAS641.HECRASCONTROLLER`) is registered.

## Usage

### Depth Time Series Extraction

Specify file paths and parameters in the `file_paths_to_output_dirs` dictionary. Example:
```python
file_paths_to_output_dirs = {
    "C:/path/to/example.hdf": "C:/path/to/output/directory"
}
```

Run the script to save water depth time series for specified HDF files.

### Monte Carlo Experiment Generator

Modify the `base_hydrograph_path`, `num_experiments`, and `output_dir` in the `generate_monte_carlo_experiments` function call. Example:
```python
generate_monte_carlo_experiments(
    base_hydrograph_path="C:/path/to/Base_Hydrograph.txt",
    num_experiments=1000,
    output_dir="C:/path/to/output",
)
```

### Parallel HEC-RAS Simulations

List the project file paths and define group sizes in the `run_parallel_simulations` function call. Example:
```python
run_parallel_simulations(
    project_paths=["C:/path/to/project1.prj", "C:/path/to/project2.prj"],
    group_size=2,
)
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributions

Contributions, issues, and feature requests are welcome. Feel free to open an issue or submit a pull request.

## Contact

For questions or feedback, please contact [Your Name or Organization].

