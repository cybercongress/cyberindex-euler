import os

DATABASE_USER = os.environ.get("DATABASE_USER", "root")
DATABASE_PASSWORD = os.environ.get("DATABASE_PASSWORD", "root")
DATABASE_HOST = os.environ.get("DATABASE_HOST", "localhost")
DATABASE_PORT = os.environ.get("DATABASE_PORT", 5432)
DATABASE_NAME = os.environ.get("DATABASE_NAME", "cyber")
HASURA_URL = os.environ.get("HASURA_URL", "localhost:8080")
HASURA_ADMIN_SECRET = os.environ.get("HASURA_ADMIN_SECRET", "hasura")
RPC_URL = os.environ.get("RPC_URL", "https://titan.cybernode.ai")
