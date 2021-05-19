# LocalGov Drupal Docker container

Container for LocalGov Drupal CI, includes Apache, PHP and Composer.

## Running tests with Docker Compose

To use with the the included `docker-compose.yml` file, create a LocalGov Drupal install in an html directory in the git root, start `docker-compose` and then run the tests.

Something like:

```bash
git clone git@github.com:localgovdrupal/drupal-container.git localgovdrupal-testing
cd localgovdrupal-testing
composer create-project --stability dev localgovdrupal/localgov-project ./html
docker-compose up -d
./run-tests.sh
docker-compose stop
```

## Building the Docker image

The Docker image lives in [Docker Hub](https://hub.docker.com/repository/docker/localgovdrupal/apache-php). Ask in [Slack](https://localgovdrupal.slack.com/) if you need the permissions to push new images.

Build with:

```bash
docker build . -t localgovdrupal/apache-php:php7.4
docker push localgovdrupal/apache-php:php7.4
```
