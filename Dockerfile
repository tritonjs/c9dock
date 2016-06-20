# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Jared Allard <jaredallard@outlook.com>

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone --depth=1 https://github.com/tritonjs/c9.io /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/
ADD conf/standalone.js /cloud9/settings/standalone.js

# Add User settings
ADD HOME_.c9/user.settings /root/.c9/user.settings

ADD fetch-init.sh /root/fetch-init.sh

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 3000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
ENTRYPOINT ["/bin/bash", "--login", "-c", "cd /root; bash fetch-init.sh"] 
