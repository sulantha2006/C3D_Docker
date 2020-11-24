FROM debian:buster as builder
USER root
ARG DEBIAN_FRONTEND="noninteractive"
ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
           git \
           bash \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* \
     && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
     && dpkg-reconfigure --frontend=noninteractive locales \
     && update-locale LANG="en_US.UTF-8"
RUN echo "Downloading Convert3D ..." \
    && mkdir -p /opt/convert3d \
    && curl -fsSL --retry 5 https://sourceforge.net/projects/c3d/files/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz/download \
    | tar -xz -C /opt/convert3d --strip-components 1

FROM debian:buster-slim
ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
           git \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/* \
     && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
     && dpkg-reconfigure --frontend=noninteractive locales \
     && update-locale LANG="en_US.UTF-8"
COPY --from=builder /opt/convert3d /opt/convert3d
ENV C3DPATH="/opt/convert3d" \
    PATH="/opt/convert3d/bin:$PATH"
RUN echo $(/opt/convert3d/bin/c3d -version)
ENV SHELL=/bin/bash
CMD ["/bin/bash"]
