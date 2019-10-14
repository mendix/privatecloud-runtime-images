#!/bin/sh -e

# This is documented here:
# https://docs.openshift.com/container-platform/4.1/openshift_images/create-images.html#use-uid_create-images

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-mendix}:x:$(id -u):0:${USER_NAME:-mendix} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

exec "$@"
