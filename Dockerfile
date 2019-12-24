# Dockerized  ScanServer for Brother MFC 7320
#
# VERSION               0.0.1

FROM armv7/armhf-ubuntu:16.10
MAINTAINER Willy Hardy <willy@omg.lol>

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
    net-tools

RUN apt-get clean

RUN mkdir -p /tmp/

# Install scanservjs
RUN mkdir -p /tmp/scanservjs
WORKDIR /tmp/scanservjs
RUN wget -O /tmp/scanservjs/scanservjs.tar.gz $(curl -s https://api.github.com/repos/sbs20/scanservjs/releases/latest | grep browser_download_url | cut -d '"' -f 4)
RUN tar -xf scanservjs.tar.gz
RUN ./scanservjs/install.sh

# Add launcher
ADD start.sh /start.sh
RUN chmod +x /start.sh

# Start scan service(s)
#CMD /start.sh
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/start.sh"]
EXPOSE 8080