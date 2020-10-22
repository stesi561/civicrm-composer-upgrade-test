#! /bin/bash

if [ -z "${DRUPAL_PROJECT}" -o -z "${DRUPAL_VERSION}" -o -z "${CIVICRM_OLD_VERSION}" -o -z "${CIVICRM_NEW_VERSION}"  -o -z "${CIVICRM_OLD_ASSET_PLUGIN_VERSION}" -o -z "${CIVICRM_NEW_ASSET_PLUGIN_VERSION}"]; then
    echo "This script requires the following environment variables:"
    echo "DRUPAL_PROJECT"
    echo "DRUPAL_VERSION"
    echo "CIVICRM_OLD_VERSION"
    echo "CIVICRM_NEW_VERSION"
    exit 1
fi

## CONFIGURATION
# Probably shift these to a separate conf file

# Where composer will be run in
WORKSPACE=workspace
PROJECT_DIRECTORY=drupal-root

# Where to look for composer.json files for drupal projects - no trailing slash
AVAILBLE_COMPOSER_PROJECTS=composer-projects

# Get filename that composer project will be - this allows us to set
# up a more complicated initial state.
DRUPAL_PROJECT_COMPOSER_FILE=$(sed 's!/!_!g' <<< "${DRUPAL_VERSION}")

# PREPARE WORKSPACE
pushd "${WORKSPACE}"

if [ -f "${AVAILBLE_COMPOSER_PROJECTS}/${DRUPAL_PROJECT_COMPOSER_FILE}.json" ]; then
    # CASE 1
    #
    # We have a predefined composer.install/composer.json that matches
    # the drupal project
    cd $PROJECT_DRUPAL
    cp "${AVAILBLE_COMPOSER_PROJECTS}/${DRUPAL_PROJECT_COMPOSER_FILE}.json" composer.json
    if [ -f "${AVAILBLE_COMPOSER_PROJECTS}/${DRUPAL_PROJECT_COMPOSER_FILE}.install" ]; then
	cp "${AVAILBLE_COMPOSER_PROJECTS}/${DRUPAL_PROJECT_COMPOSER_FILE}.install" composer.install
    fi

    # Todo add error handling here.
    composer install
else
    
    # CASE 2
    #
    # We are just passing through the DRUPAL PROJECT straight into composer


    # Todo add error handling here
    composer create-project "${DRUPAL_VERSION}" "${PROJECT_DRUPAL}"
fi

# We should now have the CMS codebase

# Get the civicrm codebase

# Todo add error handling
composer config extra.enable-patching true
composer require civicrm/civicrm-asset-plugin:'${CIVICRM_OLD_ASSET_PLUGIN_VERSION}'
composer require civicrm/civicrm-{core,packages,drupal-8}:"${CIVICRM_OLD_VERSION}"


# Now test the upgrade
composer require civicrm/civicrm-asset-plugin:'${CIVICRM_NEW_ASSET_PLUGIN_VERSION}' --no-update
composer require civicrm/civicrm-{core,packages,drupal-8}:"${CIVICRM_NEW_VERSION}" --no-update
composer update civicrm/civicrm-asset-plugin civicrm/civicrm-{core,packages,drupal-8} --with-dependencies

# We need some way to test that this runs correctly


# We should possibly also consider some way of testing to confirm that p


popd
