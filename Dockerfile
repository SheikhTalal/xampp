FROM debian:11

# Install necessary dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        wget \
        sudo \
        vim \
        apt-utils \
        libc6-i386 \
        lib32stdc++6 \
        lib32z1 \
        libbz2-1.0:i386 \
        libgtk-3-0:i386 \
        libxslt1.1:i386 \
        libnss3:i386 \
        libasound2:i386

# Set root password to root, format is 'user:password'.
RUN echo 'root:root' | chpasswd

RUN apt-get update --fix-missing && \
  apt-get upgrade -y && \
  # curl is needed to download the xampp installer, net-tools provides netstat command for xampp
  apt-get -y install curl net-tools && \
  apt-get -yq install openssh-server supervisor && \
  # Few handy utilities which are nice to have
  apt-get -y install nano less --no-install-recommends && \
  apt-get clean
  
# Download and install XAMPP
RUN wget -O /tmp/xampp-installer.run "https://yer.dl.sourceforge.net/project/xampp/XAMPP%20Linux/8.2.4/xampp-linux-x64-8.2.4-0-installer.run" \
    && sudo chmod +x /tmp/xampp-installer.run \
    && sudo /tmp/xampp-installer.run --mode unattended --installer-language en \
    && ln -sf /opt/lampp/lampp /usr/bin/lampp && \
  # Enable XAMPP web interface(remove security checks)
    sed -i.bak s'/Require local/Require all granted/g' /opt/lampp/etc/extra/httpd-xampp.conf && \
  # Enable error display in php
    sed -i.bak s'/display_errors=Off/display_errors=On/g' /opt/lampp/etc/php.ini && \
  # Enable includes of several configuration files
    mkdir /opt/lampp/apache2/conf.d && \
    echo "IncludeOptional /opt/lampp/apache2/conf.d/*.conf" >> /opt/lampp/etc/httpd.conf && \
  # Create a /www folder and a symbolic link to it in /opt/lampp/htdocs. It'll be accessible via http://localhost:[port]/www/
  # This is convenient because it doesn't interfere with xampp, phpmyadmin or other tools in /opt/lampp/htdocs
    mkdir /www && \
    ln -s /www /opt/lampp/htdocs && \
  # SSH server
    mkdir -p /var/run/sshd && \
  # Allow root login via password
    sed -ri 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# copy supervisor config file to start openssh-server
RUN { \
     echo '[program:openssh-server]'; \
     echo 'command=/usr/sbin/sshd -D'; \
     echo 'numprocs=1'; \
     echo 'autostart=true'; \
     echo 'autorestart=true'; \
     } > "/etc/supervisor/conf.d/supervisord-openssh-server.conf";
RUN { \
        echo '/opt/lampp/lampp start'; \
        echo '/usr/bin/supervisord -n'; \        
    } > "/startup.sh";


VOLUME [ "/var/log/mysql/", "/var/log/apache2/", "/www", "/opt/lampp/apache2/conf.d/" ]

EXPOSE 3306
EXPOSE 22
EXPOSE 80

CMD ["sh", "/startup.sh"]
