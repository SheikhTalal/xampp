FROM debian:11

# Install necessary dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        wget \
        libc6-i386 \
        lib32stdc++6 \
        lib32z1 \
        libbz2-1.0:i386 \
        libgtk-3-0:i386 \
        libxslt1.1:i386 \
        libnss3:i386 \
        libasound2:i386

# Download and install XAMPP
RUN wget -O /tmp/xampp-installer.run "https://yer.dl.sourceforge.net/project/xampp/XAMPP%20Linux/8.2.4/xampp-linux-x64-8.2.4-0-installer.run" \
    && chmod 755 /tmp/xampp-installer.run \
    && /tmp/xampp-installer.run --mode unattended --installer-language English

# Copy Apache configuration files
COPY httpd.conf /opt/lampp/etc/httpd.conf
COPY httpd-xampp.conf /opt/lampp/etc/extra/httpd-xampp.conf

# Copy PHP configuration file
COPY php.ini /opt/lampp/etc/php.ini

# Copy MySQL configuration file
COPY my.cnf /opt/lampp/etc/my.cnf

# Copy ProFTPD configuration file
COPY proftpd.conf /opt/lampp/etc/proftpd.conf

# Start XAMPP
CMD ["bash", "-c", "sudo /opt/lampp/lampp start"]

# Expose necessary ports for Apache and MySQL
EXPOSE 80
EXPOSE 443
EXPOSE 3306
