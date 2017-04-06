FROM lsiobase/xenial
MAINTAINER phendryx

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy app files
COPY app/ /opt/dockerhub-stats/

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# package versions
ARG GRAFANA_VER="4.1.2-1486989747"
ARG INFLUX_VER="1.2.0"

# build packages as variable
ARG BUILD_PACKAGES="\
	apt-transport-https \
	binutils \
	bzip2 \
	cpp \
	cpp-5 \
	dh-python \
	distro-info-data \
	fontconfig-config \
	fonts-dejavu-core \
	g++ \
	g++-5 \
	gcc \
	gcc-5 \
	git \
	git-core \
	git-man \
	icu-devtools \
	libasan2 \
	libatomic1 \
	libc6-dev \
	libcc1-0 \
	libc-dev-bin \
	libcilkrts5 \
	liberror-perl \
	libexpat1 \
	libfontconfig \
	libfontconfig1 \
	libfreetype6 \
	libgcc-5-dev \
	libgdbm3 \
	libgmp-dev \
	libgmpxx4ldbl \
	libgomp1 \
	libicu55 \
	libicu-dev \
	libisl15 \
	libitm1 \
	liblsan0 \
	libmpc3 \
	libmpdec2 \
	libmpfr4 \
	libmpx0 \
	libperl5.22 \
	libpng12-0 \
	libpng12-0 \
	libpython3.5-minimal \
	libpython3.5-stdlib \
	libpython3-stdlib \
	libquadmath0 \
	libruby2.3 \
	libstdc++-5-dev \
	libtcl8.6 \
	libtcltk-ruby \
	libtk8.6 \
	libtsan0 \
	libubsan0 \
	libx11-6 \
	libx11-data \
	libxau6 \
	libxcb1 \
	libxdmcp6 \
	libxext6 \
	libxml2 \
	libxml2-dev \
	libxrender1 \
	libxslt1.1 \
	libxslt1-dev \
	libxss1 \
	libyaml-0-2 \
	linux-libc-dev \
	lsb-release \
	make \
	mime-support \
	perl \
	perl-modules-5.22 \
	python3 \
	python3.5 \
	python3.5-minimal \
	python3-minimal \
	rake \
	ri \
	ruby \
	ruby2.3 \
	ruby2.3-dev \
	ruby2.3-doc \
	ruby2.3-tcltk \
	ruby-dev \
	ruby-did-you-mean \
	ruby-full \
	rubygems-integration \
	ruby-minitest \
	ruby-net-telnet \
	ruby-power-assert \
	ruby-test-unit \
	ucf \
	wget \
	x11-common \
	zlib1g-dev"

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	$BUILD_PACKAGES && \

# install ruby app gems
 cd /opt/dockerhub-stats/ && \
 echo 'gem: --no-document' > \
	/etc/gemrc && \
 gem install bundler && \
 bundle install && \

# clean up
 apt-get purge -y --auto-remove \
	$BUILD_PACKAGES && \

# install runtime packages
 apt-get install -y \
	--no-install-recommends \
	cron \
	libfontconfig1 \
	libfreetype6 \
	libpng12-0 \
	netcat \
	ruby \
	wget && \

 # install influxdb and grafana
 curl -o \
 /tmp/influxdb.deb \
	"https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUX_VER}_amd64.deb" && \
 dpkg -i /tmp/influxdb.deb && \
 curl -o \
 /tmp/grafana.deb \
	"https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VER}_amd64.deb" && \
 dpkg -i /tmp/grafana.deb && \
 apt-get -f install && \

# clean up
 rm -rf \
	/root \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* && \
 mkdir -p \
	/root

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000 8083 8086
VOLUME /config
