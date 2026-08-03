FROM golang:1.26-alpine AS build

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

#compile binary from source
RUN CGO_ENABLED=0 GOFIPS140=latest go build -ldflags='-s -w' -o mc main.go

RUN apk add -U --no-cache ca-certificates

FROM alpine:3.23.5

COPY --from=build /usr/src/app/mc  /usr/bin/mc
COPY --from=build /usr/src/app/CREDITS /licenses/CREDITS
COPY --from=build /usr/src/app/LICENSE /licenses/LICENSE
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Create symbolic links from /bin to /usr/bin
RUN /bin/sh -c 'for f in /bin/*; do ln -s "$f" "/usr/bin/$(basename "$f")"; done 2>/dev/null'

ENTRYPOINT ["/usr/bin/mc"]
