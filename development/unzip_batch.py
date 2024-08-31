import os
import zipfile
import argparse

def unzip_files(batch_file, source_dir, output_dir):
    # Ensure the output directory exists
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Read the batch file
    with open(batch_file, 'r') as f:
        identifiers = f.read().splitlines()
    
    # Loop through each identifier in the batch file
    for identifier in identifiers:
        # Construct the expected .zip file name
        zip_filename = f"{identifier}.zip"
        zip_filepath = os.path.join(source_dir, zip_filename)
        
        # Check if the zip file exists
        if os.path.exists(zip_filepath):
            # Unzip the file to the output directory
            with zipfile.ZipFile(zip_filepath, 'r') as zip_ref:
                zip_ref.extractall(output_dir)
            print(f"Unzipped: {zip_filename}")
        else:
            print(f"Zip file not found for: {identifier}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Unzip files listed in a batch file.")
    parser.add_argument('-b', '--batch', required=True, help="Batch file containing list of identifiers")
    parser.add_argument('-s', '--source', required=True, help="Directory containing the zip files")
    parser.add_argument('-o', '--output', required=True, help="Directory to save the unzipped files")
    
    # Parse the arguments
    args = parser.parse_args()

    # Call the function with the provided arguments
    unzip_files(args.batch, args.source, args.output)