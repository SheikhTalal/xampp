# Stage 1: PHP 7.4 with Apache
FROM php:7.4-apache AS php7

WORKDIR /var/www/html/php7

# Copy your PHP 7.4 project files to the container
COPY htdocs /var/www/html/php7

# Install additional dependencies if needed
RUN docker-php-ext-install mysqli

# Stage 2: PHP 8.1 with Apache
FROM php:8.1-apache AS php8_1

WORKDIR /var/www/html/php8_1

# Copy your PHP 8.1 project files to the container
COPY htdocs /var/www/html/php8_1

# Install additional dependencies if needed
RUN docker-php-ext-install mysqli

# Stage 3: PHP 8.2 with Apache
FROM php:8.2-apache AS php8_2

WORKDIR /var/www/html/php8_2

# Copy your PHP 8.2 project files to the container
COPY htdocs /var/www/html/php8_2

# Install additional dependencies if needed
RUN docker-php-ext-install mysqli

# Stage 4: Final stage with PHP 8.2 and additional services
FROM php:8.2-apache

WORKDIR /var/www/html

# Copy the desired PHP version from the corresponding stage
COPY --from=php7 /var/www/html/php7 /var/www/html/php7
COPY --from=php8_1 /var/www/html/php8_1 /var/www/html/php8_1
COPY --from=php8_2 /var/www/html/php8_2 /var/www/html/php8_2

# Install MySQL and phpMyAdmin
RUN apt-get update && apt-get install -y \
    mariadb-server \
    phpmyadmin

# Expose ports 80 for HTTP and 3306 for MySQL
EXPOSE 80
EXPOSE 3306

# Start the Apache web server and MySQL when the container launches
CMD ["bash", "-c", "service mysql start && apache2-foreground"]
