#!/bin/bash

# get the .sh location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# install postgres server and mongodb
sudo yum install -y postgresql-server postgresql-jdbc

# upgrade spark python to work with python 3
sudo yum upgrade -y spark-python

# update spark log4j to be quiet and restart
sudo cp setup/log4j.properties /usr/lib/spark/conf/
sudo chmod 644 /usr/lib/spark/conf/log4j.properties
sudo service spark-master restart
sudo service spark-worker restart

# create initial database
sudo service postgresql initdb

# setup authentication
echo "host    cloudera    cloudera     127.0.0.1/32   trust" > /tmp/pg
sudo cat /var/lib/pgsql/data/pg_hba.conf >> /tmp/pg
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.DIST
sudo mv /tmp/pg /var/lib/pgsql/data/pg_hba.conf

# start postgres server during boot
sudo chkconfig --level 345 postgresql on

# start postgres server
sudo service postgresql start

# set permissions so postgres can read csv files
chmod 755 /home/cloudera/Downloads/big-data-3

# create postgres account for cloudera user
sudo -u postgres psql -c "CREATE USER cloudera"

# make cloudera account admin
sudo -u postgres psql -c "ALTER USER cloudera with superuser"

# create default db for cloudera account
sudo -u postgres createdb cloudera

# decompress csv files
gzip -d *.csv.gz

# set permissions so postgres can read csv files
chmod 644 *.csv

# create and load tables for hands on
psql -f $DIR/setup/init-postgres.sql

#give permissions for the files so the postgres will be able read the csv files
chmod 755 $DIR/buy-clicks.csv
chmod 755 $DIR/game-clicks.csv
chmod 755 $DIR/ad-clicks.csv

#load the data from csv files into postgres
psql  << EOF
COPY buyclicks FROM '$DIR/buy-clicks.csv' DELIMITER ',' CSV HEADER;
COPY gameclicks FROM '$DIR/game-clicks.csv' DELIMITER ',' CSV HEADER;
COPY adclicks FROM '$DIR/ad-clicks.csv' DELIMITER ',' CSV HEADER;
EOF

# download and install anaconda for pandas, jupyter
wget http://repo.continuum.io/archive/Anaconda3-4.0.0-Linux-x86_64.sh
bash Anaconda3-4.0.0-Linux-x86_64.sh

# add postgres jdbc jar to spark classpath
echo "export SPARK_CLASSPATH=/usr/share/java/postgresql-jdbc-8.4.704.jar" >> ~/.bashrc

# set environment variables to load spark libs in jupyter
echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"notebook\"" >> ~/.bashrc
echo "export PYSPARK_DRIVER_PYTHON=jupyter"  >> ~/.bashrc

cd mongodb
./setup.sh
cd ..

