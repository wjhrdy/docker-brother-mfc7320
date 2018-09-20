# Dockerized Tor Relay Node on Raspberry Pi
#
# VERSION               0.0.1

FROM ubuntu:latest
MAINTAINER ToXic0 "toxicpublic@gmail.com"

# Install dependencies
RUN apt-get update 
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get -y install \
    sane-utils \
    hplip \
    unzip \
    imagemagick \
    usbutils \
    tesseract-ocr \
    tesseract-ocr-eng \
    apache2 \
    libapache2-mod-php \
    coreutils \
    php \
    php-json \
    php-curl \
    tar \
    zip \
    php-fpdf \ 
    libpaper-utils \
    sed \
    grep \
    psutils \
    lsb-release \
    git \
    curl \
    nodejs \
    npm \
    vim \
    net-tools
RUN apt-get clean

# Fix tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN echo "tzdata tzdata/Areas select Europe\ntzdata tzdata/Zones/Europe select Berlin" > /tmp/tzdate-preseed.txt
RUN debconf-set-selections /tmp/tzdate-preseed.txt
#RUN echo "Europe/Paris" > /etc/timezone    

RUN mkdir -p /tmp/

# Install Brother drivers
WORKDIR /tmp/
RUN git clone https://github.com/toxic0berliner/brother-drivers-installer.git
WORKDIR /tmp/brother-drivers-installer/
RUN chmod +x brother-drivers-installer.sh
RUN ./brother-drivers-installer.sh mfc-7320 USB

# Install php-scanner-server
RUN wget -O /tmp/PHP-Scanner-Server.zip "https://github.com/GM-Script-Writer-62850/PHP-Scanner-Server/archive/master.zip"
RUN unzip -q /tmp/PHP-Scanner-Server.zip -d /tmp
RUN mv /tmp/PHP-Scanner-Server-master/* /var/www/html

# Setup apache for php-scanner server
RUN rm /var/www/html/index.html
RUN adduser www-data lp
RUN mkdir -p /var/www/html/scans
RUN mkdir -p /var/www/html/config/parallel
RUN chown www-data /var/www/html/scans 
RUN chown -R www-data /var/www/html/config

RUN a2enmod headers
RUN echo "ServerName scanner.local" >> /etc/apache2/sites-available/000-default.conf
RUN systemctl enable apache2 

#RUN rm -rf /start.sh

# Add launcher
ADD start.sh /start.sh

# Start scan service(s)
#CMD /start.sh
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/start.sh"]
