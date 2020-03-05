FROM golang:latest

ARG JUNO_WORKERS=1

ENV JUNO_WORKERS=${JUNO_WORKERS}

WORKDIR /app

COPY . .

RUN make build

CMD ./build/cyberindex config.toml --workers $JUNO_WORKERS