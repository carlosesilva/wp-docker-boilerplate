#!/bin/bash

# Exit if any command fails
set -e

# Check Docker is installed and running
. "$(dirname "$0")/install-docker.sh"

# Set up WordPress Development site.
. "$(dirname "$0")/install-wordpress.sh"

CURRENT_URL=$(docker-compose run -T --rm wp-cli option get siteurl)

echo -e "\n----------\n"

echo -e "WordPress is up and running at the following url: $CURRENT_URL"
echo -e ""
echo -e "Access the above install using the following credentials:"
echo -e 'Default username: "admin", password: "password"'

echo -e "\n----------\n"
