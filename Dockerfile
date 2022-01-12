#FROM webcenter/openjdk-jre:8
#FROM openjdk:8u312-jre
FROM adoptopenjdk/openjdk8
MAINTAINER Sebastien LANGOUREAUX <linuxworkgroup@hotmail.com>

ENV ACTIVEMQ_CONFIG_DIR /opt/activemq/conf.tmp
ENV ACTIVEMQ_DATA_DIR /data/activemq

# Update distro and install some packages
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y python-nose vim curl supervisor logrotate locales && \
    curl --fail https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py

RUN python2 get-pip.py && \
    update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    rm -rf /var/lib/apt/lists/*

# Install stompy
RUN pip install stomp.py

# Launch app install
COPY assets/setup/ /app/setup/
RUN chmod +x /app/setup/install.sh
RUN /app/setup/install.sh


# Copy the app setting
COPY assets/entrypoint /app/
COPY assets/run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Expose all port
EXPOSE 8161
EXPOSE 61616
EXPOSE 5672
EXPOSE 61613
EXPOSE 1883
EXPOSE 61614

# Expose some folders
VOLUME ["/data/activemq"]
VOLUME ["/var/log/activemq"]
VOLUME ["/opt/activemq/conf"]

WORKDIR /opt/activemq

CMD ["/app/run.sh"]
