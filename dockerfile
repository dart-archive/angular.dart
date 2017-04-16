#
# Dart Dockerfile
#
# https://github.com/dockerfile/dart
#

# Pull base image.
FROM dockerfile/ubuntu

# Install Dart.
RUN \
  mkdir -p /tmp/dart && \
  cd /tmp/dart && \
  curl -O http://storage.googleapis.com/dart-archive/channels/stable/release/39553/linux_packages/debian_wheezy/dart_1.6.0-1_amd64.deb && \
  dpkg -i dart_1.6.0-1_amd64.deb && \
  rm -fr /tmp/dart

# Set environment variables.
ENV PATH /usr/lib/dart/bin:$PATH

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]
