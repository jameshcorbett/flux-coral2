FROM fluxrm/flux-sched:alpine

LABEL maintainer="James Corbett <corbett8@llnl.gov>"

ARG USER=flux
ARG UID=1000
ARG GID=1000

# copy scripts into image
COPY scripts/ /scripts
RUN sudo /scripts/install-deps.sh

# Add configured user to image with sudo access:
#
RUN sudo /scripts/add_docker_user.sh

USER $USER
WORKDIR /home/$USER

