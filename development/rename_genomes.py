import os
import argparse

def rename_files(directory):
    # List all .fna files in the specified directory
    for filename in os.listdir(directory):
        if filename.endswith(".fna"):
            # Construct the full path to the current file
            old_filepath = os.path.join(directory, filename)
            
            # Extract the base name without extension and the new name
            base_name = filename[:-4]  # Remove the ".fna" extension
            new_name = base_name[:15] + ".fna"
            
            # Construct the full path for the new file name
            new_filepath = os.path.join(directory, new_name)
            
            # Rename the file
            os.rename(old_filepath, new_filepath)
            print(f"Renamed {old_filepath} to {new_filepath}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Rename .fna files in the specified directory.")
    parser.add_argument('-d', '--directory', required=True, help="Directory containing the .fna files")
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Call the function with the provided directory
    rename_files(args.directory)