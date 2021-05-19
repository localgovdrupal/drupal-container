##
# LocalGov Drupal web container.

FROM php:7.4-apache

# Install PHP and related packages.
RUN apt-get update && \
    apt-get install -y \
      curl \
      git \
      libcurl4-openssl-dev \
      libfreetype6-dev \
      libicu-dev \
      libjpeg62-turbo-dev \
      libonig-dev \
      libpng-dev \
      libxml2-dev \
      libzip-dev \
      mariadb-client \
      patch \
      zlib1g-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg  && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install \
      bcmath \
      curl \
      gettext \
      intl \
      mbstring \
      mysqli \
      pdo \
      pdo_mysql \
      zip  && \
    apt-get clean && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/cache/*

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add a docker user.
RUN useradd -m -s /bin/bash -G www-data -p docker docker

# Configure Apache.
ENV APACHE_RUN_USER docker
ENV APACHE_RUN_GROUP docker
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
COPY config/apache2/docker.conf /etc/apache2/conf-available/docker.conf
COPY config/apache2/vhost.conf /etc/apache2/sites-available/vhost.conf
RUN a2enmod \
      expires \
      headers \
      rewrite && \
    a2dissite 000-default.conf && \
    a2ensite vhost.conf && \
    ln -s /etc/apache2/conf-available/docker.conf /etc/apache2/conf-enabled/docker.conf && \
    rm -fr /var/www/*

# Configure PHP.
COPY config/php/docker.ini /usr/local/etc/php/conf.d/localgovdrupal.ini

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
