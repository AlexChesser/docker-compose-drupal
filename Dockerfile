FROM drupal:7.44-apache

RUN apt-get update \
    && apt-get install -y drush mysql-client \
    && rm -rf /var/lib/apt/lists/*

ENV DRUPAL_ENVIRONMENT production
EXPOSE 80

ADD ./application /var/www/html