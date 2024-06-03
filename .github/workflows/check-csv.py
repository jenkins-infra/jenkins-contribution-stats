import csv
import urllib.parse
import os

# Path to the CSV file
csv_file = "data/honored_contributor.csv"

# ANSI escape codes for colors
RED = '\033[31m'  # Red color for error messages
GREEN = '\033[32m'  # Green color for success messages
NC = '\033[0m'  # Reset color

# Get the name of the current script
script_name = os.path.basename(__file__)

def is_valid_url(url):
    """
    Checks if the given string is a valid URL.

    Parameters:
    url (str): The string to check.

    Returns:
    bool: True if the string is a valid URL, False otherwise.
    """
    try:
        result = urllib.parse.urlparse(url)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False

try:
    # Open the CSV file
    with open(csv_file, 'r') as file:
        reader = csv.reader(file)
        headers = next(reader)  # Skip the header
        gh_handles = set()  # Set to store GitHub handles for uniqueness check
        for row in reader:
            # Remove leading and trailing spaces and double quotes from each value
            row = [value.strip().strip('"') for value in row]
            # Check if the row has the same number of columns as the header
            if len(row) != len(headers):
                print(f"{RED}[{script_name}]: Error: Row {row} does not have the same number of columns as the header.{NC}")
                exit(1)
            # Check if the URLs are valid
            if not is_valid_url(row[5]) or not is_valid_url(row[6]):
                print(f"{RED}[{script_name}]: Error: Invalid URL in row {row}{NC}")
                exit(1)
            # Check if the GitHub handle is unique
            if row[2] in gh_handles:
                print(f"{RED}[{script_name}]: Error: Duplicate GitHub handle {row[2]}{NC}")
                exit(1)
            gh_handles.add(row[2])
            # Check if all fields except COMPANY and FULL NAME are not null
            if not all(row[i] for i in range(len(row)) if i not in [3, 4]):
                print(f"{RED}[{script_name}]: Error: Null value in row {row}{NC}")
                exit(1)
    # If all checks pass, print a success message
    print(f"{GREEN}[{script_name}]: {csv_file} is valid and not empty.{NC}")
except FileNotFoundError:
    # If the CSV file does not exist, print an error message
    print(f"{RED}[{script_name}]: Error: {csv_file} does not exist.{NC}")
except csv.Error as e:
    # If the CSV file is not valid, print an error message
    print(f"{RED}[{script_name}]: Error: {csv_file} is not a valid CSV file. {e}{NC}")
