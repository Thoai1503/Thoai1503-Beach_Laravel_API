# Sử dụng PHP 8.2 với Apache
FROM php:8.2-apache

# Cài đặt các extension cần thiết
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    curl \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd pdo_mysql mbstring zip

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Tạo thư mục làm việc
WORKDIR /var/www/html

# Sao chép toàn bộ project Laravel vào container
COPY . .

# Cấp quyền cho thư mục storage và bootstrap/cache
RUN chmod -R 777 storage bootstrap/cache

# Cài đặt dependencies của Laravel
RUN composer install --no-dev --optimize-autoloader

# Cache cấu hình Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port 8080 (Railway yêu cầu)
EXPOSE 8080

# Khởi động Laravel khi container chạy
CMD php artisan serve --host=0.0.0.0 --port=8080
