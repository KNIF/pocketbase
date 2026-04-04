FROM golang:1.25-alpine AS builder

WORKDIR /src
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH:-amd64} go build -trimpath -ldflags="-s -w" -o /out/pocketbase ./examples/base

FROM alpine:3.22

RUN addgroup -S pocketbase && adduser -S -G pocketbase pocketbase

WORKDIR /pb
COPY --from=builder /out/pocketbase /usr/local/bin/pocketbase
RUN mkdir -p /pb/pb_data /pb/pb_migrations /pb/pb_public \
    && chown -R pocketbase:pocketbase /pb/pb_data /pb/pb_migrations /pb/pb_public

EXPOSE 8090
VOLUME ["/pb/pb_data", "/pb/pb_migrations", "/pb/pb_public"]

USER pocketbase
ENTRYPOINT ["pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/pb/pb_data"]
