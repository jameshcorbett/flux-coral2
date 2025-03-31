FROM fluxrm/flux-sched:noble

LABEL maintainer="James Corbett <corbett8@llnl.gov>"

ARG USER=fluxuser
ARG UID=1000
ARG GID=1000
ARG KUBECTL_VERSION=latest

# copy scripts into image
COPY scripts/ /scripts
RUN /scripts/install-deps.sh

# Add configured user to image with sudo access:
#
RUN /scripts/add_docker_user.sh

COPY ./kubectl.sh ./sync-kube-config.sh /usr/local/share/
RUN sudo chmod 755 /usr/local/share/kubectl.sh \
  && sudo chmod 755 /usr/local/share/sync-kube-config.sh \
  && sudo /usr/local/share/kubectl.sh \
  && echo "source /usr/local/share/sync-kube-config.sh" | sudo tee -a /etc/bash.bashrc \
  && sudo chmod 755 /etc/bash.bashrc


USER $USER
WORKDIR /home/$USER
