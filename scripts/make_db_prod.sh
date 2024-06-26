#!/bin/bash

[ -z ${FOD_DIR} ] && echo "FOD_DIR not set" && exit 1
cd ${FOD_DIR}
source ${FOD_DIR}/scripts/util.sh
separator "${BASH_SOURCE}"

user_manip() {
	docker-compose -f docker-compose.prod.yml exec web python user_manip.py $@
}

if [[ -z "$(user_manip list)" ]]; then
	echo_warning "No users found, adding test user"
	user_manip add --username test --password test --email test@test.com
fi

echo_warning "Recreating database"
docker-compose -f docker-compose.prod.yml exec web python manage.py create_db
docker-compose -f docker-compose.prod.yml exec web python manage.py seed_db

# this is to check if the db exists
# docker-compose -f docker-compose.prod.yml exec db psql --username=hello_flask --dbname=hello_flask_prod -c "\l"
# docker-compose -f docker-compose.prod.yml exec db psql --username=hello_flask --dbname=hello_flask_prod -c "\dt"
# docker-compose -f docker-compose.prod.yml exec db psql --username=hello_flask --dbname=hello_flask_prod -c "SELECT * FROM users;"

# docker volume inspect flask-on-docker_postgres_data

user_manip list
