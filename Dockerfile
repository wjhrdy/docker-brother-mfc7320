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

# Install scanservjs
RUN mkdir -p /tmp/scanservjs
WORKDIR /tmp/scanservjs
RUN wget -O /tmp/scanservjs/scanservjs.tar.gz $(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)
RUN tar -xf scanservjs.tar.gz
RUN ./scanservjs/install.sh

# Add launcher
ADD start.sh /start.sh

# Start scan service(s)
#CMD /start.sh
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/start.sh"]
