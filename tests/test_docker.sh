#!/bin/sh
# this is a very simple script that tests the docker configuration for cookiecutter-django
# it is meant to be run from the root directory of the repository, eg:
# sh tests/test_docker.sh

set -x

# install test requirements
pip install -r requirements.txt
echo "requirements installed"

# create a cache directory
mkdir -p .cache/docker
cd .cache/docker
echo "cache/docker directory created"

rm -rf my_awesome_project
echo "remove old project folder"

# create the project using the default settings in cookiecutter.json
cookiecutter ../../ --no-input

cd my_awesome_project

chmod +x run.sh
echo "cookiecutter created for my_awesome_project"

# run the project's type checks
# docker-compose -f local.yml run django mypy my_awesome_project
echo "docker compose django my_awesome_project"

# run the project's tests
docker-compose -f local.yml run django pytest
echo "docker compose django pytest"

# return non-zero status code if there are migrations that have not been created
docker-compose -f local.yml run django python manage.py makemigrations --dry-run --check || { echo "ERROR: there were changes in the models, but migration listed above have not been created and are not saved in version control"; exit 1; }
echo "docker compose django migrations"

# Test support for translations
docker-compose -f local.yml run django python manage.py makemessages
echo "docker compose django makemessages"
