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
docker exec -u docker -t drupal bash -c "cd /var/www/html && ./bin/paratest --processes=4"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# Set return code depending on number of tests that failed.
exit $RESULT
