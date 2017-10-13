Data sets and scripts for Coursera Big Data Specialization.
====================
https://www.coursera.org/specializations/bigdata

Cloudera Docker Image
--------------------
For those taking this course.  Cloudera now has a docker image, allowing you to avoid installing an entire virtual machine environment.

https://hub.docker.com/r/cloudera/quickstart/

Install docker

`sudo apt-get install docker.io`

Pull the latest Image

`docker pull cloudera/quickstart:latest`

Make note of the docker image on your system

`docker images`

Start up the docker Image, from the terminal while you're in the root directory
of this project.

`
docker run --hostname=quickstart.cloudera --privileged=true -t -i -v <PATH_TO_COURSE_MATERIAL>:/home/cloudera/data  <IMAGE_NUM> /usr/bin/docker-quickstart
`

This works for the hadoop parts of the course.. but now the pyspark parts.  This is due to CentOS 6.9 being heavily tied to Python 2.6.. which is quite old.
