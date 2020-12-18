FROM php:7.4-fpm

LABEL Lucky Fernanda R<luckyprojec@gmail.com>

RUN apt-get update && apt-get install -y \
        git \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libjpeg-dev\
        libpng-dev \
        libaio1 \
        libldap2-dev \
        libzip-dev \
        libssl-dev \ 
        zlib1g-dev \
        php7.4-gd \
    && docker-php-ext-install pdo pdo_mysql mysqli bcmath zip\
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
    --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
    --enable-gd-native-ttf \
    && docker-php-ext-install gd iconv gettext\
    && docker-php-ext-install ldap

# Install XDebug - Required for code coverage in PHPUnit
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Copy over the php conf
COPY /conf/apache/docker-php.conf /etc/apache2/conf-enabled/docker-php.conf

# Copy over the php ini
COPY /conf/php/docker-php.ini $PHP_INI_DIR/conf.d/


# Set the timezone
ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN printf "log_errors = On \nerror_log = /dev/stderr\n" > /usr/local/etc/php/conf.d/php-logs.ini

# Enable mod_rewrite
# RUN a2enmod rewrite
# apache configurations, mod rewrite
#RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# Install Composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Add the files and set permissions
WORKDIR /var/www/html
ADD . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80