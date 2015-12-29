FROM ubuntu:14.04
MAINTAINER Jeremy Shimko <jeremy.shimko@gmail.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools && \
    echo "mongodb-org hold" | dpkg --set-selections && echo "mongodb-org-server hold" | dpkg --set-selections && \
    echo "mongodb-org-shell hold" | dpkg --set-selections && \
    echo "mongodb-org-mongos hold" | dpkg --set-selections && \
    echo "mongodb-org-tools hold" | dpkg --set-selections


# mongod config
ENV AUTH yes
ENV STORAGE_ENGINE wiredTiger
ENV JOURNALING yes
ENV REP_SET rs0
ENV MONGO_SECONDARY mongo2:27017
ENV MONGO_ARBITER mongo3:27017

# mongo root user (change me!)
ENV MONGO_ROOT_USER root
ENV MONGO_ROOT_PASSWORD root123

# mongo app user + database (change me!)
ENV MONGO_APP_USER myAppUser
ENV MONGO_APP_PASSWORD myAppPassword
ENV MONGO_APP_DATABASE myAppDatabase

RUN mkdir /opt/mongo
ADD mongodb-keyfile /opt/mongo/mongodb-keyfile
ADD mongo_setup_users.sh /opt/mongo/mongo_setup_users.sh
ADD mongo_setup_repset.sh /opt/mongo/mongo_setup_repset.sh
ADD check-keyfile.sh /opt/mongo/check-keyfile.sh

RUN chmod +x /opt/mongo/check-keyfile.sh
RUN /opt/mongo/check-keyfile.sh
ADD run.sh /run.sh
RUN chown -R mongodb:mongodb /opt/mongo
RUN chmod 600 /opt/mongo/mongodb-keyfile

VOLUME /data/db

EXPOSE 27017 28017

CMD ["/run.sh"]
