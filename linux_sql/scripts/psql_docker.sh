#!/bin/sh

# capture arguments
cmd=$1
db_username=$2
db_password=$3

# start docker, if not already actively running
sudo systemctl status docker || sudo systemctl start docker

docker container inspect jrvs-psql

# container_status now holds an exit code (0 for if the instance exists, 1 otherwise)

# now we read the value of the command passed into the script

# first case: we want to create a docker container
case $cmd in 
	create)
	if [ $container_status -eq 0 ]; then
		echo 'Container already exists'
		exit 1
	fi

# if there are not exactly three arguments
	if [ $# -ne 3 ]; then
		echo 'Create requires username and password'
		exit 1
	fi

# if number of arguments is 3 and container_status is 1, then we create the container instance
	docker volume create pgdata
	docker run -d \
            --name jrvs-psql \
            -e POSTGRES_USER=$db_username \
            -e POSTGRES_PASSWORD=$db_password \
            -v pgdata:/var/lib/postgresql/data \
            -p 5432:5432 \
            postgres:9.6-alpine
	exit $?

# exit code of latest command
	;;

	start | stop)
# here we should check whether or not the instance has been created; if it hasn't, we exit with code 1
	if [ $container_status -eq 1 ]; then
		echo 'Container not yet created'
		exit 1
	fi

# insert $cmd into the docker command to start/stop the container (now that we've determined that it exists)

	docker container $cmd jrvs-psql
	exit $?
	;;

# now we handle all other cases, represented by a star
	*)
	echo 'Illegal command'
	echo 'Commands: start | stop | create'
	exit 1
	;;

esac

exit 0
