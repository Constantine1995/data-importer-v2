FROM php:8.2-fpm

# Install dependencies and netcat-openbsd
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    tzdata \
    netcat-openbsd

# Clearing the cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the time zone
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/Europe/Moscow /etc/localtime && echo "Europe/Moscow" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html

COPY . .

# Folder permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Open the port
EXPOSE 8000

# Start the Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]