#!/bin/bash

# if keyfile hasn't been generated, provide instructions and exit the build
if [ ! -s /opt/mongo/mongodb-keyfile ]; then
  RED="\e[31m"
  BLUE="\e[34m"
  WHITE="\e[39m"

  echo -e "${RED}"
  echo "You must generate a Mongo keyfile for internal auth before building this container."
  echo "More info: https://docs.mongodb.org/v3.0/tutorial/enable-internal-authentication/"
  echo -e "${BLUE}"
  echo "From the root of this project, run the command:"
  echo -e "${WHITE}"
  echo "  openssl rand -base64 741 > mongodb-keyfile"
  echo -e "${BLUE}"
  echo "Once the key has been generated, try building the container again."
  echo -e "${WHITE}"
  exit 1
fi
