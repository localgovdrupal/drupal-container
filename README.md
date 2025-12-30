# LocalGov Drupal Docker container

Container for LocalGov Drupal CI, includes Apache, PHP and Composer.

## Running tests with Docker Compose

To use with the the included `docker-compose.yml` file, create a LocalGov Drupal install in an html directory in the git root, start `docker-compose` and then run the tests.

Something like:

```bash
git clone git@github.com:localgovdrupal/drupal-container.git localgovdrupal-testing
cd localgovdrupal-testing
composer create-project --stability dev --keep-vcs localgovdrupal/localgov-project ./html
docker-compose up -d
./run-tests.sh
docker-compose stop
```

## Building the Docker image

### Automated builds (GHCR)

Multi-architecture images (amd64/arm64) are automatically built and pushed to GitHub Container Registry on every push to `php*` branches:

```
ghcr.io/<owner>/drupal-container:<php-version>-apache
```

For example: `ghcr.io/localgovdrupal/drupal-container:php-8.3-apache`

You can also trigger a build manually via the [Actions tab](../../actions/workflows/build-push.yml).

### Manual builds (Docker Hub)

The Docker image also lives in [Docker Hub](https://hub.docker.com/repository/docker/localgovdrupal/apache-php). Ask in [Slack](https://localgovdrupal.slack.com/) if you need the permissions to push new images.

Build and push manually with:

```bash
export branch=$(git symbolic-ref --short HEAD)
docker build . -t localgovdrupal/apache-php:$branch
docker push localgovdrupal/apache-php:$branch
```

## Maintainers

This project is currently maintained by: 

 - Finn Lewis: https://github.com/finnlewis 
 - Stephen Cox: https://github.com/stephen-cox
