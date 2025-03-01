#!/usr/bin/env bash
TAG=latest

# Enable common error handling options.
set -o errexit
set -o nounset
set -o pipefail

# Parse input arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -t | --tag)
        TAG="$2"
        shift
        shift
        ;;
        # Add the ability to specify build-arg MAMBA_USER_ID
    -u | --user-id)
        MAMBA_USER_ID="$2"
        shift
        shift
        ;;
    *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

# Use 'latest' as the default tag if not specified
if [ -z "$TAG" ]; then
    TAG="latest"
fi

# Build the Docker image
if [ -z "${MAMBA_USER_ID+x}" ]; then
    docker build --network=host -t opera-adt/dolphin:"$TAG" --file docker/Dockerfile .
else
    docker build --network=host -t opera-adt/dolphin:"$TAG" --build-arg MAMBA_USER_ID="$MAMBA_USER_ID" --file docker/Dockerfile .
fi

# To run the image and see the help message....
echo "To run the image and see the help message:"
echo "docker run --rm -it opera-adt/dolphin:$TAG dolphin --help"
#
echo "To run the workflow on a configuration in the current directory...."
echo "docker run --user \$(id -u):\$(id -g) -v \$PWD:/work --rm -it opera-adt/dolphin:$TAG dolphin run dolphin_config.yaml"
echo "To run on a PGE runconfig:"
echo "docker run --user \$(id -u):\$(id -g) -v \$PWD:/work --rm -it opera-adt/dolphin:$TAG dolphin run --pge runconfig.yaml"
# where...
#     --user $(id -u):$(id -g)  # Needed to avoid permission issues when writing to the mounted volume.
#     -v $PWD:/work  # Mounts the current directory to the /work directory in the container.
#     --rm  # Removes the container after it exits.
#     -it  # Needed to keep the container running after the command exits.
#     opera-adt/dolphin:latest  # The name of the image to run.
#     dolphin run dolphin_config.yaml # The `dolphin` command that is run in the container
