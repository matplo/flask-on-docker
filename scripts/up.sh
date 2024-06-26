#!/bin/bash

[ -z ${FOD_DIR} ] && echo "FOD_DIR not set" && exit 1
cd ${FOD_DIR}
source ${FOD_DIR}/scripts/util.sh
separator "${BASH_SOURCE}"

echo_help_message()
{
	echo_warning "[i] usage: ${BASH_SOURCE[0]} dev|prod [build]"
	echo_warning "    dev: start the development environment"
	echo_warning "    prod: start the production environment"
	echo_warning "    build: build the images before starting the environment"
}

if [ ! -e ${FOD_DIR}/users.yaml ]; then
	echo_warning "Creating empty users.yaml"
	touch ${FOD_DIR}/users.yaml 
	chmod a+rwx ${FOD_DIR}/users.yaml
fi

what=$1
if [ -z "$what" ]; then
	echo_warning "[i] No argument provided - assuming prod"
	echo_help_message
	what="prod"
	echo_help_message
fi


if [ "$what" == "dev" ]; then
	if [ "$2" == "build" ]; then
		docker-compose down -v
		docker-compose up -d --build
	else
		docker-compose down
		docker-compose up -d
	fi
elif [ "$what" == "prod" ]; then
	if [ "$2" == "build" ]; then
		docker-compose -f docker-compose.prod.yml down -v
		docker-compose -f docker-compose.prod.yml up -d --build
		${FOD_DIR}/scripts/make_db_prod.sh
	else
		docker-compose -f docker-compose.prod.yml down
		docker-compose -f docker-compose.prod.yml up -d
		${FOD_DIR}/scripts/make_db_prod.sh
	fi
else
	echo_help_message
	exit 1
fi
