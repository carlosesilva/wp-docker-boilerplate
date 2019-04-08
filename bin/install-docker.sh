#!/bin/bash

# Exit if any command fails.
set -e

# Check that Docker is running.
if ! docker info >/dev/null 2>&1; then
	echo -e "Docker isn't running. Please check that you've started your Docker app, and see it in your system tray."
	exit 1
fi

# Stop existing containers.
echo -e "Stopping Docker containers..."
docker-compose down --remove-orphans >/dev/null 2>&1

# Download image updates.
echo -e "Downloading Docker image updates..."
docker-compose pull

# Launch the containers.
echo -e "Starting Docker containers..."
docker-compose up -d >/dev/null
