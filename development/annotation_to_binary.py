import pandas as pd
import argparse

def process_file(values_file, input_file, output_file):
    # Read the list of values from the .txt file
    with open(values_file, 'r') as f:
        values = [line.strip() for line in f if line.strip()]

    # Initialize a list to store clean rows
    clean_rows = []

    # Attempt to read the input file line by line
    try:
        with open(input_file, 'r') as f:
            for line in f:
                # Split the line by tab and check if it has the expected number of columns
                columns = line.strip().split('\t')
                if len(columns) >= 9:  # Check for at least 9 columns
                    clean_rows.append(columns)
    except Exception as e:
        print(f"Error reading input file: {e}")
        return

    # Convert clean rows to a DataFrame
    df = pd.DataFrame(clean_rows)
    
    # Extract genome and trait columns
    genomes = df[1].tolist()  # Genome information in the 2nd column (index 1)
    traits = df[8].tolist()   # Trait information in the 9th column (index 8)

    # Create a DataFrame with genomes as rows and values as columns
    data = []
    for genome in set(genomes):  # Use set to avoid processing duplicate genomes
        # Get traits associated with the genome
        genome_traits = {trait for g, trait in zip(genomes, traits) if g == genome}
        
        # Create a row for this genome
        row = [1 if value in genome_traits else 0 for value in values]
        data.append(row)

    # Create the final DataFrame
    result_df = pd.DataFrame(data, index=list(set(genomes)), columns=values)
    
    # Save the DataFrame to the output file
    result_df.to_csv(output_file)
    print(f"Output saved to {output_file}")

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Process genome and trait file to output presence/absence table.")
    parser.add_argument('-v', '--values', required=True, help="Text file containing values to check")
    parser.add_argument('-i', '--input', required=True, help="Input file with genome and trait information")
    parser.add_argument('-o', '--output', required=True, help="Output CSV file")

    # Parse the arguments
    args = parser.parse_args()

    # Call the function with the provided arguments
    process_file(args.values, args.input, args.output)