FROM golang:latest

ARG JUNO_WORKERS=1

ENV JUNO_WORKERS=${JUNO_WORKERS}

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build

CMD ./juno config.toml --workers $JUNO_WORKERS