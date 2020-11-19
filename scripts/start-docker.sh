#! /bin/bash
# temporeraly import variables
export $(cat .env)

# remove config toml, as far as it copyed to container
rm config.toml

# create config.toml, put values from .env file to config.toml
echo -n 'rpc_node="' >> config.toml && echo -n $RPC_URL >> config.toml && echo -n '"' >> config.toml
sed -i "/rpc/a client_node=\"$LCD_URL\"" config.toml
echo >> config.toml
echo '[database]' >> config.toml
sed -i "/database/a host=\"$POSTGRES_DB_HOST\"" config.toml
sed -i "/host=/a port=$POSTGRES_DB_PORT" config.toml
sed -i "/port/a name=\"$POSTGRES_DB_NAME\"" config.toml
sed -i "/name/a user=\"$POSTGRES_USER_NAME\"" config.toml
sed -i "/user/a password=\"$POSTGRES_DB_PASSWORD\"" config.toml
sed -i "/password/a ssl_mode=\"$JUNO_SSL_MODE\"" config.toml

# build cyberindexer and run it in container
sudo mv ./postgres /tmp/
docker build -t cyberindex:latest --build-arg JUNO_WORKERS=$JUNO_WORKERS .
sudo mv /tmp/postgres ./

# run postgres and hasura in containers
docker-compose up -d postgres 
sleep 10

docker-compose up -d graphql-engine 
sleep 10

# init database with basic tables
docker exec -ti cyberindex_postgres psql -f /root/schema/validator.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/pre_commit.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/block.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/transaction.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/cyberlink.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/relevance.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/message.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/object.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME

docker run -d --name cyberindex --network="host" cyberindex:latest