
FROM golang:1.24-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go mod tidy

RUN go build -o bin/server cmd/server/main.go

EXPOSE 1030

CMD ["/app/bin/server"]
