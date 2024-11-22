
import os
import numpy as np
import h5py
import win32com.client
import time
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import multiprocessing

# Function: Save depth time series from HDF file
def save_depth_time_series(file_path, water_surface_dataset_path, start_time_str, end_time_str, cell_index, output_dir):
    startTime = datetime.strptime(start_time_str, '%d%b%Y %H:%M')
    endTime = datetime.strptime(end_time_str, '%d%b%Y %H:%M')
    time_values = [startTime + timedelta(minutes=15 * x) for x in range(int((endTime - startTime).total_seconds() / 900))]

    with h5py.File(file_path, 'r') as hdf_file:
        water_surface_data = hdf_file[water_surface_dataset_path][:]

        if cell_index >= water_surface_data.shape[1]:
            raise IndexError(f"Cell index {cell_index} is out of bounds for the water surface data.")

        adjusted_cell_index = cell_index - 1
        cell_data = water_surface_data[:, adjusted_cell_index]

        min_length = min(len(time_values), len(cell_data))
        time_values = time_values[:min_length]
        cell_data = cell_data[:min_length]

        initial_water_surface = cell_data[0]
        water_depth = cell_data - initial_water_surface

        base_name = os.path.splitext(os.path.basename(file_path))[0]
        depth_file_name = os.path.join(output_dir, f'{base_name}_Water_Depth_Cell_{adjusted_cell_index + 1}.txt')
        np.savetxt(depth_file_name, np.column_stack([time_values, water_depth]), fmt='%s', delimiter=', ', header='Time, Water Depth')

# Function: Generate Monte Carlo experiments
def generate_monte_carlo_experiments(base_hydrograph_path, num_experiments, output_dir):
    base_hydrograph = np.loadtxt(base_hydrograph_path)
    land_cover_types = [
        ('NoData', 0.1, 0.1),
        ('Unclassified', 0.025, 0.08),
        ('Developed - High Intensity', 0.08, 0.16),
        ('Developed - Medium Intensity', 0.06, 0.12),
        ('Developed - Low Intensity', 0.1, 0.1),
        ('Developed - Open Space', 0.03, 0.05),
        ('Cultivated Crops', 0.1, 0.1),
        ('Pasture-Hay', 0.1, 0.1),
        ('Grassland-Herbaceous', 0.1, 0.1),
        ('Palustrine Emergent Wetland', 0.02, 0.06),
    ]

    for i in range(num_experiments):
        hydrograph_peak_increase = 1 + (99 * np.random.rand())
        modified_hydrograph = np.copy(base_hydrograph)
        modified_hydrograph[30:48] *= (hydrograph_peak_increase / 100 + 1)
        np.savetxt(os.path.join(output_dir, f'Hydrograph_{i+1}.txt'), modified_hydrograph, fmt='%.6f')

# Function: Run HEC-RAS simulation
def run_hecras(project_path):
    try:
        hRAS = win32com.client.Dispatch('RAS641.HECRASCONTROLLER')
        hRAS.Project_Open(project_path)
        hRAS.Compute_CurrentPlan()

        while not hRAS.Compute_Complete():
            time.sleep(5)

        hRAS.Project_Save()
        hRAS.QuitRAS()
    except Exception as e:
        print(f"Error running HEC-RAS simulation for project: {project_path}: {e}")
    finally:
        hRAS = None

# Function: Run simulations in parallel
def run_parallel_simulations(project_paths, group_size):
    chunks = [project_paths[i:i + group_size] for i in range(0, len(project_paths), group_size)]

    for chunk in chunks:
        processes = []
        for path in chunk:
            process = multiprocessing.Process(target=run_hecras, args=(path,))
            processes.append(process)
            process.start()

        for process in processes:
            process.join()

# Main script parameters
file_paths_to_output_dirs = {
    # Example configuration for HDF and HEC-RAS projects
    'C:/path/to/example.hdf': 'C:/path/to/output/directory'
}

# Example usage (replace with real values)
if __name__ == "__main__":
    # Example: Run depth time series extraction
    for file_path, output_dir in file_paths_to_output_dirs.items():
        save_depth_time_series(
            file_path=file_path,
            water_surface_dataset_path="/path/to/dataset",
            start_time_str="10JUL1968 09:00",
            end_time_str="12JUL1968 09:00",
            cell_index=1,
            output_dir=output_dir,
        )

    # Example: Generate Monte Carlo experiments
    generate_monte_carlo_experiments(
        base_hydrograph_path="C:/path/to/Base_Hydrograph.txt",
        num_experiments=10,
        output_dir="C:/path/to/output",
    )

    # Example: Run HEC-RAS simulations in parallel
    run_parallel_simulations(
        project_paths=["C:/path/to/project1.prj", "C:/path/to/project2.prj"],
        group_size=2,
    )
