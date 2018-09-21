# Dockerized  ScanServer for Brother MFC 7320
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
    tesseract-ocr-fra \
    tesseract-ocr-osd \
    coreutils \
    tar \
    zip \
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
    net-tools \
    tzdata
RUN apt-get clean

# Fix tzdata
#RUN dpkg-reconfigure -f noninteractive tzdata
RUN echo "tzdata tzdata/Areas select Europe\ntzdata tzdata/Zones/Europe select Paris" > /tmp/tzdate-preseed.txt
RUN debconf-set-selections /tmp/tzdate-preseed.txt
RUN echo "Europe/Paris" > /etc/timezone    

RUN mkdir -p /tmp/

# Install Brother drivers
WORKDIR /tmp/
RUN git clone https://github.com/toxic0berliner/brother-drivers-installer.git
WORKDIR /tmp/brother-drivers-installer/
RUN chmod +x brother-drivers-installer.sh
RUN ./brother-drivers-installer.sh mfc-7320 USB
# Cleanup to remove unmet dependencies on brother packages that prevent from using apt for some strange reason
RUN sed -i 's/libc6 (>= 2.3.4-1)//g' /var/lib/dpkg/status

# Install scanservjs
RUN mkdir -p /tmp/scanservjs
WORKDIR /tmp/scanservjs
RUN wget -O /tmp/scanservjs/scanservjs.tar.gz $(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)
RUN tar -xf scanservjs.tar.gz
RUN ./scanservjs/install.sh
ADD device.conf /var/www/scanservjs/device.conf
RUN chown scanservjs:users /var/www/scanservjs/device.conf
RUN chmod 644 /var/www/scanservjs/device.conf

# Setup brscan-skey
ADD scan-pdf-ocr.sh /opt/brother/scanner/brscan-skey/script/scan-pdf-ocr.sh
RUN chmod  +x /opt/brother/scanner/brscan-skey/script/scan-pdf-ocr.sh
RUN rm /opt/brother/scanner/brscan-skey/brscan-skey-0.2.4-0.cfg
ADD brscan-skey.cfg /opt/brother/scanner/brscan-skey/brscan-skey-0.2.4-0.cfg


# Add launcher
ADD start.sh /start.sh

# Start scan service(s)
#CMD /start.sh
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/start.sh"]
