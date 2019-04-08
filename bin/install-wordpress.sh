#!/bin/bash

# Exit if any command fails.
set -e

# These are the containers and values for the development site.
CLI='wp-cli'
CONTAINER='wordpress'
SITE_TITLE='Example WP Site'

# Get the host port for the WordPress container.
HOST_PORT=$(docker-compose port $CONTAINER 80 | awk -F : '{printf $2}')

# Wait until the Docker containers are running and the WordPress site is
# responding to requests.
echo -en "Attempting to connect to WordPress..."
until $(curl -L http://localhost:$HOST_PORT -so - 2>&1 | grep -q "WordPress"); do
    echo -n '.'
    sleep 5
done
echo ''

# Install WordPress.
echo -e "Installing WordPress..."
# The `-u 33` flag tells Docker to run the command as a particular user and
# prevents permissions errors. See: https://github.com/WordPress/gutenberg/pull/8427#issuecomment-410232369
docker-compose run --rm -u 33 $CLI core install --title="$SITE_TITLE" --admin_user=admin --admin_password=password --admin_email=test@test.com --skip-email --url=http://localhost:$HOST_PORT --quiet

# Make sure the uploads and upgrade folders exist and we have permissions to add files.
echo -e "Ensuring that files can be uploaded..."
docker-compose run --rm $CONTAINER chmod 767 /var/www/html/wp-content/plugins
docker-compose run --rm $CONTAINER chmod 767 /var/www/html/wp-config.php
docker-compose run --rm $CONTAINER chmod 767 /var/www/html/wp-settings.php
docker-compose run --rm $CONTAINER mkdir -p /var/www/html/wp-content/uploads
docker-compose run --rm $CONTAINER chmod -v 767 /var/www/html/wp-content/uploads
docker-compose run --rm $CONTAINER mkdir -p /var/www/html/wp-content/upgrade
docker-compose run --rm $CONTAINER chmod 767 /var/www/html/wp-content/upgrade

CURRENT_WP_VERSION=$(docker-compose run -T --rm $CLI core version)
echo -e "Current WordPress version: $CURRENT_WP_VERSION..."

# If the 'wordpress' volume wasn't during the down/up earlier, but the post port has changed, we need to update it.
echo -e "Checking the site's url..."
CURRENT_URL=$(docker-compose run -T --rm $CLI option get siteurl)
if [ "$CURRENT_URL" != "http://localhost:$HOST_PORT" ]; then
	docker-compose run --rm -u 33 $CLI option update home "http://localhost:$HOST_PORT" --quiet
	docker-compose run --rm -u 33 $CLI option update siteurl "http://localhost:$HOST_PORT" --quiet
fi

# Install a dummy favicon to avoid 404 errors.
echo -e "Installing a dummy favicon..."
docker-compose run --rm $CONTAINER touch /var/www/html/favicon.ico

# Configure site constants.
echo -e "Configuring site constants..."
docker-compose run --rm -u 33 $CLI config set WP_DEBUG true --raw --type=constant --quiet
docker-compose run --rm -u 33 $CLI config set SCRIPT_DEBUG true --raw --type=constant --quiet