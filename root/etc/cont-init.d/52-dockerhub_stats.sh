#!/usr/bin/with-contenv bash

if [ ! -f /config/app/settings.yml ]; then
	cp /opt/dockerhub-stats/config/settings.yml.example /config/app/settings.yml
fi

if [ ! -f /opt/dockerhub-stats/config/settings.yml ]; then
	ln -s /config/app/settings.yml /opt/dockerhub-stats/config/settings.yml
fi
