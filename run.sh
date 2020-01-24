#! /bin/bash
docker-compose up -d
sleep 2
docker exec -ti cyberindex_postgres psql -f /root/schema/transaction.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/block.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/validator.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/pre_commit.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/link.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/transaction.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/block.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/validator.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/pre_commit.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/link.sql -d cyberbasedocker
docker exec -ti cyberindex_postgres psql -f /root/schema/transaction.sql -d cyberbase
docker exec -ti cyberindex_postgres psql -f /root/schema/link.sql -d cyberbase
docker build -t cyberindex:latest .
docker run -d --name cyberindex --network="host" cyberindex:latest