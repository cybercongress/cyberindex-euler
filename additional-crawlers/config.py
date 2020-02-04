import os

DATABASE_USER = os.environ.get("DATABASE_USER", "cyber")
DATABASE_PASSWORD = os.environ.get("DATABASE_PASSWORD", "1postgres1")
DATABASE_HOST = os.environ.get("DATABASE_HOST", "localhost")
DATABASE_PORT = os.environ.get("DATABASE_PORT", 5432)
DATABASE_NAME = os.environ.get("DATABASE_NAME", "cyberindex")
HASURA_URL = os.environ.get("HASURA_URL", "localhost:8090")
HASURA_ADMIN_SECRET = os.environ.get("HASURA_ADMIN_SECRET", "pleased2fuckgoogle")
