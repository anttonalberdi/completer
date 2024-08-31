import os
import argparse

def split_file(input_file, output_dir, lines_per_file=1000):
    # Ensure the output directory exists
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Get the base file name and extension
    base_name = os.path.basename(input_file)
    file_name, file_extension = os.path.splitext(base_name)

    with open(input_file, 'r') as file:
        file_number = 1
        while True:
            lines = []
            for _ in range(lines_per_file):
                line = file.readline()
                if not line:
                    break
                lines.append(line)
            
            # If no lines were read, break the loop
            if not lines:
                break
            
            # Create the output file name with the proper numbering
            output_file = os.path.join(output_dir, f'{file_name}_{file_number}{file_extension}')
            with open(output_file, 'w') as subfile:
                subfile.writelines(lines)
            
            # Increment the file number for the next subfile
            file_number += 1

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Split a text file into smaller files with a specified number of lines each.")
    parser.add_argument('-i', '--input', required=True, help="Input text file to split")
    parser.add_argument('-o', '--output', required=True, help="Directory to save the output files")
    
    # Parse the arguments
    args = parser.parse_args()

    # Call the function with the provided arguments
    split_file(args.input, args.output)