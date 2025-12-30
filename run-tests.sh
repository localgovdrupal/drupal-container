#!/bin/bash

##
# Run all tests!
RESULT=0

# Fix ownership of code base.
docker exec -t drupal bash -c "chown -R docker:docker /var/www/html"

# Ensure everything is up to date.
docker exec -u docker -t drupal bash -c "cd /var/www/html && composer install"

# Coding standards checks.
echo "Checking coding standards"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpcs -p"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# Deprecated code checks.
echo "Checking for deprecated code"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpstan analyse -c ./phpstan.neon ./web/profiles/contrib/localgov/ ./web/modules/contrib/localgov_* ./web/themes/contrib/localgov_*"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# PHPUnit tests.
echo "Running tests"
docker exec -t drupal bash -c "mkdir -p /var/www/html/web/sites/simpletest && chmod 777 /var/www/html/web/sites/simpletest"
# Older versions of Paratest (the one required by LocalGov 1.x) don't pickup
# environmental variables, so it's necessary to change the config file directly.
docker exec -u docker -t drupal bash -c 'sed -i "s#http://localgov.lndo.site#http://drupal#" /var/www/html/phpunit.xml.dist'
# Add SYMFONY_DEPRECATIONS_HELPER to phpunit.xml.dist to prevent deprecation notices
# from causing test failures - Drupal core and contrib have many deprecations
docker exec -u docker -t drupal bash -c 'sed -i "/<env name=\"SIMPLETEST_BASE_URL\"/a\    <env name=\"SYMFONY_DEPRECATIONS_HELPER\" value=\"disabled\"/>" /var/www/html/phpunit.xml.dist'
# Use PHPUnit directly instead of Paratest to avoid JUnit XML parsing bugs
# See: https://github.com/localgovdrupal/localgov_subsites/issues/140
# Set SYMFONY_DEPRECATIONS_HELPER=disabled to prevent deprecation notices from causing test failures
# Drupal core and contrib modules have many deprecations that don't affect test validity
docker exec -u docker -t drupal bash -c "cd /var/www/html && SYMFONY_DEPRECATIONS_HELPER=disabled ./bin/phpunit"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# Set return code depending on number of tests that failed.
exit $RESULT
