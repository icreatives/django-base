FROM ubuntu:16.04
MAINTAINER python.devs@icg.co.nz

# Trick to make sure we can use 'source' command.
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL repository containing the most recent stable release (9.3)
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update

RUN apt-get install -y build-essential
# RUN apt-get install -y python-software-properties
RUN apt-get install -y --fix-missing python-software-properties
RUN apt-get install -y software-properties-common
RUN apt-get install -y postgresql
RUN apt-get install -y postgresql-client
RUN apt-get install -y postgresql-contrib

RUN apt-get install -y nginx

RUN apt-get install -y curl git vim

RUN apt-get install -y python-dev python-setuptools

# RUN apt-get install upstart-sysv
RUN apt-get install -y --fix-missing upstart-sysv

RUN apt-get install -y sendmail

RUN apt-get install -y rabbitmq-server

RUN easy_install pip
RUN pip install uwsgi ipython virtualenvwrapper

# needed for Pillow
RUN apt-get install -y ffmpeg
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libpq-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libxslt1-dev
RUN apt-get install -y libtiff-dev
RUN apt-get install -y uuid-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib

# Xapian
RUN apt-get install -y --fix-missing libxapian-dev

# openSSL needs this one
RUN apt-get install -y --fix-missing libffi-dev

####################
# PostgreSQL stuff #
####################

# run these commands as user postgres to create databases etc
USER postgres

# Create psql user 'docker' with password 'docker' and have him own a database 'docker'
# which will be the universal database credentials for each application image
RUN /etc/init.d/postgresql start && psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
#RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf

#RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

RUN sed -i '1s/^/local all docker trust\n/' /etc/postgresql/*/main/pg_hba.conf
# RUN sed -i '1s/^/local all docker trust\n/' /etc/postgresql/9.6/main/pg_hba.conf
#RUN echo "local all all trust" >> /etc/postgresql/9.6/main/pg_hba.conf

##################
# End PostgreSQL #
##################
USER root

RUN mkdir /srv/www

WORKDIR /srv/www

RUN touch /var/log/uwsgi.log

ADD uwsgi.conf /etc/init/uwsgi.conf
RUN chmod 755 /etc/init/uwsgi.conf

ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh

ENTRYPOINT ["/root/start.sh"]
