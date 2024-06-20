#!/usr/bin/env bash

set -e

# check wether required tools are available


# Checks for the presence of the GitHub command line tool
if ! command -v "gh" >/dev/null 2>&1
then
    echo "ERROR: command line 'gh' required but not found. Exiting."
    exit 1
fi


# Checks for the presence of the Json Query tool
if ! command -v "jq" >/dev/null 2>&1
then
    echo "ERROR: command line 'jq' required but not found. Exiting."
    exit 1
fi

# Check presence of the "datamash" tool (CSV manipulation tool)
if ! command -v "datamash" >/dev/null 2>&1
then
    echo "ERROR: command line 'datamash' required but not found. Exiting."
    exit 1
fi

# Check for "jenkins-contribution-aggregator" presence and minimal version
if ! command -v "jenkins-contribution-aggregator" >/dev/null 2>&1
then
    echo "ERROR: command line 'jenkins-contribution-aggregator' required but not found. Exiting."
    exit 1
fi

## TODO: (code duplication) This could be refactored and moved to a bash sub routine
# The target version of the jenkins-contribution-aggregator tool that we want to have installed.
top_target_version=1.2.10

# Fetch the currently installed version of the jenkins-contribution-aggregator tool.
# The 'awk' command is used to extract the version number from the output of the 'jenkins-contribution-aggregator version' command.
top_installed_version=$(jenkins-contribution-aggregator version | awk '{print $NF}')

# Compare the installed version with the target version.
# The 'sort -V' command is used to sort the version numbers in version sort order, and 'head -n 1' is used to get the smallest version.
# If the smallest version is not the target version, it means the installed version is less than the target version.
if [[ $(echo -e "$top_target_version\n$top_installed_version" | sort -V | head -n 1) != "$top_target_version" ]]; then
    # If the installed version is less than the target version, print an error message in red and bold.
    echo -e "Error: installed version ($top_installed_version) is less than target version ($top_target_version)."
    # Suggest the user to update the jenkins-contribution-aggregator tool using the 'brew upgrade' command.
    echo -e "Please update the jenkins-contribution-aggregator tool thanks to the following command:"
    # Print the 'brew upgrade' command in blue and bold.
    echo -e "   brew upgrade jenkins-contribution-aggregator"
    # Exit the script with a status of 1 to indicate an error.
    exit 1
fi


# check for "jenkins-contribution-extractor" presence and minimal version
if ! command -v "jenkins-contribution-extractor" >/dev/null 2>&1
then
    echo "ERROR: command line 'jenkins-contribution-extractor' required but not found. Exiting."
    exit 1
fi

## TODO: (code duplication) This could be refactored and moved to a bash sub routine
# The target version of the jenkins-contribution-extractor tool that we want to have installed.
stats_target_version=0.2.16

# Fetch the currently installed version of the jenkins-contribution-extractor tool.
# The 'awk' command is used to extract the version number from the output of the 'jenkins-contribution-extractor version' command.
stats_installed_version=$(jenkins-contribution-extractor version | awk '{print $NF}')

# Compare the installed version with the target version.
# The 'sort -V' command is used to sort the version numbers in version sort order, and 'head -n 1' is used to get the smallest version.
# If the smallest version is not the target version, it means the installed version is less than the target version.
if [[ $(echo -e "$stats_target_version\n$stats_installed_version" | sort -V | head -n 1) != "$stats_target_version" ]]; then
    # If the installed version is less than the target version, print an error message in red and bold.
    echo -e "Error: installed version ($stats_installed_version) is less than target version ($stats_target_version)."
    # Suggest the user to update the jenkins-contribution-extractor tool using the 'brew upgrade' command.
    echo -e "Please update the jenkins-contribution-extractor tool thanks to the following command:"
    # Print the 'brew upgrade' command in blue and bold.
    echo -e "   brew upgrade jenkins-contribution-extractor"
    # Exit the script with a status of 1 to indicate an error.
    exit 1
fi



# The scripts require the GNU date. A special executable needs to be installed 
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v "gdate" >/dev/null 2>&1
    then
        echo "ERROR: command line 'gdate' required but not found."
        echo "You should be able to install it with \"brew install coreutils\""
        echo ""
        echo "exiting...."
        exit 1
    fi
fi



