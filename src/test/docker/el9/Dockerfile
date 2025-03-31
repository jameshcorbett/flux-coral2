FROM fluxrm/flux-sched:el9

LABEL maintainer="James Corbett <corbett8@llnl.gov>"

ARG USER=fluxuser
ARG UID=1000
ARG GID=1000

# copy scripts into image
COPY scripts/ /scripts
RUN sudo /scripts/install-deps.sh -y

# Add configured user to image with sudo access:
#
RUN sudo /scripts/add_docker_user.sh

COPY /scripts/kubectl.sh /scripts/sync-kube-config.sh /usr/local/share/
RUN sudo chmod 755 /usr/local/share/kubectl.sh \
  && sudo chmod 755 /usr/local/share/sync-kube-config.sh \
  && sudo /usr/local/share/kubectl.sh \
  && echo "source /usr/local/share/sync-kube-config.sh" | sudo tee -a /etc/profile.d/99-sync-kube-config.sh \
  && sudo chmod 755 /etc/profile.d/99-sync-kube-config.sh

USER $USER
WORKDIR /home/$USER
