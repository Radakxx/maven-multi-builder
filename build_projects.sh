#!/bin/bash

# Define the config file that contains project paths
CONFIG_FILE="projects.cfg"

# Check if the config file exists
if [[ ! -f $CONFIG_FILE ]]; then
  echo "Config file $CONFIG_FILE not found!"
  exit 1
fi

# Maven command to use, allowing for flags passed in as arguments
MVN_CMD="mvn clean install"

# Global Maven parameters (passed as arguments to the script)
GLOBAL_MVN_PARAMS="$*"

# Function to build a single project
build_project() {
  local project_dir=$1
  local project_params=$2

  echo "Building project in $project_dir with params: ${project_params}..."

  cd "$project_dir" || { echo "Failed to cd into $project_dir"; exit 1; }

  # Execute the Maven clean install command with any passed flags
  $MVN_CMD ${project_params}

  # Check if the last command was successful
  if [[ $? -ne 0 ]]; then
    echo "Build failed for project in $project_dir"
    exit 1
  fi

  echo "Build finished for $project_dir"
}

# Loop through each line in the config file
while IFS= read -r line; do
  # Skip empty lines and lines starting with a comment '#'
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    continue
  fi

  # Split the line by pipe ('|') to run parallel jobs
  IFS='|' read -ra projects <<< "$line"

  # Start building each project in parallel
  for project_info in "${projects[@]}"; do

    # Extract project directory and its parameters (if any)
    project_dir=$(echo "$project_info" | awk '{print $1}')         # First part is the directory
    project_params=$(echo "$project_info" | awk '{$1=""; print $0}' | xargs)  # Everything after the first field (trim spaces)

    # If there are no specific parameters for the project, use global parameters
    if [[ -z "$project_params" ]]; then
      project_params="$GLOBAL_MVN_PARAMS"
    fi

    ##project_dir=$(echo "$project_dir" | xargs) # Remove any extra spaces
    build_project "$project_dir" "$project_params" & # Run in the background
  done

  # Wait for all background jobs (parallel builds) to finish
  wait

  echo "All projects in this line have been built!"
done < "$CONFIG_FILE"

echo "All builds completed!"
