# Сyberindex 

>  - for cosmos-SDK v37.23 based networks go to [37-23](https://github.com/cybercongress/cyberindex/tree/cybergraph-37-32) branch
> - for cosmos-SDK v38.33 based networks go to [38-33](https://github.com/cybercongress/cyberindex/tree/cybergraph-38-33) branch
> common releases: [v0.1.37](https://github.com/cybercongress/cyberindex/releases/tag/v0.1.37), [v0.1.38](https://github.com/cybercongress/cyberindex/releases/tag/v0.1.38)

Cyberindex is a cosmos-sdk based blockchain data aggregator and exporter that provides the
ability for developers and clients to query for indexed chain data.

## Table of Contents

  - [Components](#components)
  - [Docker](#docker)
  - [Usage](#usage)
  - [Schemas](#schemas)

## Components

The cyberindex contains 4 services wrapped in docker-compose file:

- [Juno](https://github.com/fissionlabsio/juno) - Cosmos Hub data aggregator and exporter. In other words, it can be seen
as an ETL layer atop of the Cosmos Hub.
- PostgreSQL - as database
- Hasura - as graphQL engine ontop of them
- Additional crawlers - special tool for the Game of Links monitors backend. 

## Docker

- Open and fill `.env` file with all necessary data
- To install in docker run `make docker`.

Cyberindex, Hasura and Postgres would be deployed in docker containers.

**Note** Not necessary to create `config.toml` for docker installation, it would be generated automatically from `.env` file.

Example of filled `.env` file:

```bash
POSTGRES_DB_FOLDER=./postgres
POSTGRES_DB_HOST=localhost
POSTGRES_DB_PORT=5432
POSTGRES_DB_NAME=cyberindex
POSTGRES_USER_NAME=cyber
POSTGRES_DB_PASSWORD=postgres111
HASURA_PORT=8090
HASURA_ADMIN_SECRET=hasura111
JUNO_SSL_MODE=disable
JUNO_WORKERS=6
RPC_URL=http://localhost:26657
LCD_URL=http://localhost:1317
FQDN_RPC_URL=<cyberd_fqdn_http/https_rpc>
```

## Usage

Juno as part of cyberindex internally runs a single worker that consumes from a single queue. The
queue contains block heights to aggregate and export to a PostgreSQL database.
Juno will start a new block even listener where for each new block, it will
enqueue the height. A worker listens for new heights and queries for various data
related to the block height to persist. For each block height, juno will persist
the block, the validators that committed/signed the block, all the pre-commits
for the block and the transactions in the block.

In addition, it will also sync missing blocks from `--start-height` to the latest
known height.

```shell
$ juno /path/to/config.toml [flags]
```

## Schemas

The schema definitions are contained in the `schema/` directory. Note, these
schemas are not necessarily optimal and are subject to change! However, feel
free to fork this tool and expand upon the schemas as you see fit. Any tweaks
will most likely require adjustments to the `database` wrapper.
