# Maven Multi-Builder

**Maven Multi-Builder** is a shell script designed to simplify the build process for multi-module Maven projects. It allows you to configure multiple projects, specify project-specific Maven parameters, and execute builds in parallel. Additionally, you can provide global parameters that will be applied to all projects that do not have their own specific parameters.

## Features

- Build multiple Maven projects defined in a configuration file.
- Manage the order of builds in dependant projects.
- Execute builds in parallel for projects that don’t depend on each other.
- Customize Maven parameters for individual projects.
- Apply global Maven parameters across all projects.
- Automatically handles mvn clean install commands with optional flags.

## Requirements

- Maven: Ensure Maven is installed and configured in your system.
- Bash: This script is written for Bash and should run in any Unix-like environment (Linux, macOS, WSL on Windows).

## Setup

- Clone or Download the repository containing the build_projects.sh script.
- Create a configuration file named projects.cfg in the same directory as the script. (Or use the one that is provided.)

## Usage

### Configuring Projects

The projects you want to build should be defined in the projects.cfg file. Each line in the file should contain:

- A project directory path.
- An optional set of Maven parameters specific to that project.
- A pipe (|) character to separate projects that can be built in parallel.

**The projects in the first line will be built first, then the second line etc.**

### Example projects.cfg

        # Single project with specific Maven parameters
        /Users/akos/Developer/E-COLI/ecoli-common-common-backend -DskipTests
        # Single project with no specific parameters (will use global parameters, if any)
        /Users/akos/Developer/E-COLI/ecoli-another-important-common
        # Multiple projects that can be built in parallel, with different parameters
        /Users/akos/Developer/E-COLI/ecoli-backoffice-backend -U | /Users/akos/Developer/E-COLI/ecoli-yet-another-backend

### Running the Script

#### Basic Usage (No Global Parameters):

To build all projects defined in projects.cfg: `./build_projects.sh`

#### With Global Maven Parameters:

To pass global Maven parameters (e.g., -DskipTests, -U, etc.): `./build_projects.sh -DskipTests -U`

- Projects with no specific parameters in the config file will use the global parameters.
- Projects with specific parameters will ignore the global ones and use their own.

## How it works

The script reads the projects.cfg file, line by line:

- If multiple projects are on the same line separated by |, they will be run in parallel.
- It determines whether each project has specific Maven parameters or should fall back to the global ones.
- It executes mvn clean install with the appropriate parameters for each project, running in parallel where applicable. (Alternatively, the command can be changed to your wants, it does not need to be a Maven installer.)

## Error handling

- If a project build fails, the script stops and reports the failure.
- Be sure to check project-specific paths and parameters for any issues.
