# cvs2svn has some dependencies that are no longer widely available
# (e.g., Python 2.x and an oldish version of the Subversion library).
# This Dockerfile builds images that can be used to run or test
# cvs2svn. Note that it is based on debian:jessie, which is pretty
# old. But this is the most recent version of Debian where the
# required dependencies are easily available. One way to use this is
# to run
#
#     make docker-image
#
# to make an image for running cvs2svn, or
#
#     make docker-test
#
# to make an image for testing cvs2svn and to run those tests using
# the image.

FROM debian:jessie AS run

# Clear out dead secondary repos, point to the archive, and disable expiration checks
RUN rm -rf /etc/apt/sources.list.d/* && \
    echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/10-nocheckvalid

# Update and install dependencies, forcing acceptance of expired archive keys
RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends \
        python \
        python-bsddb3 \
        subversion \
        rcs \
        cvs

RUN mkdir /src
WORKDIR /src
COPY . .
RUN ${PYTHON:-python} ./setup.py install

# The CVS repository can be mounted here:
VOLUME ["/cvs"]

# A volume for storing temporary files can be mounted here:
VOLUME ["/tmp"]

ENTRYPOINT ["cvs2svn"]

FROM run AS test

RUN ln -s /tmp cvs2svn-tmp

ENTRYPOINT ["./run-tests.py"]
