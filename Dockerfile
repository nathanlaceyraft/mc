FROM golang:1.26-alpine AS build

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

#compile binary from source
RUN CGO_ENABLED=0 GOFIPS140=latest go build -ldflags='-s -w' -o mc main.go

RUN apk add -U --no-cache ca-certificates
RUN apk add -U curl
RUN curl -s -q https://raw.githubusercontent.com/minio/mc/master/LICENSE -o /go/LICENSE
RUN curl -s -q https://raw.githubusercontent.com/minio/mc/master/CREDITS -o /go/CREDITS

FROM scratch

COPY --from=build /usr/src/app/mc  /usr/bin/mc
COPY --from=build /go/CREDITS /licenses/CREDITS
COPY --from=build /go/LICENSE /licenses/LICENSE
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/usr/bin/mc"]
