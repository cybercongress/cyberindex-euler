#! /bin/bash
export $(cat .env)

docker-compose up -d additional-crawlers

docker exec -ti cyberindex_postgres psql -f /root/schema/karma.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/rewards.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/acc_by_activity.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/twitter.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/cyberlinks.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/gift_info.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -c "\copy gift_info FROM /root/schema/gift_info.csv with csv HEADER" -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/pre_commit_view.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -c "\copy old_pre_commits FROM /root/schema/old_pre_commits.csv with csv HEADER" -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/accounts_analytics.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME
docker exec -ti cyberindex_postgres psql -f /root/schema/cohorts.sql -d $POSTGRES_DB_NAME -U $POSTGRES_USER_NAME

docker-compose up -d cohorts