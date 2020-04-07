
#!/bin/bash
# Run this script from /cyberindex folder.
# This script will stop and delete all cyberindex-related: containers, docker network, docker images, config.toml and postgress db directory.
# if you need to save some of those - copy out of the /cyberindex folder.

docker stop cyberindex

docker stop cyberindex_hasura

docker stop cyberindex_postgres

docker rm cyberindex

docker rm cyberindex_hasura

docker rm cyberindex_postgres

docker stop cyberindex_additional_crawlers

docker rm cyberindex_additional_crawlers

rm -rf postgres

docker network rm cyberindex_cyberindex-net

docker image rm cyberindex_additional-crawlers

docker image rm cyberindex

rm config.toml