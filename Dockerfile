# syntax=docker/dockerfile:1

# Build the application from source
FROM golang AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /dns-reverse-proxy

# Run the tests in the container
FROM build-stage AS run-test-stage
RUN go test -v ./...

# Deploy the application binary into a lean image
FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /dns-reverse-proxy /dns-reverse-proxy

EXPOSE 53/tcp
EXPOSE 53/udp

USER nonroot:nonroot

ENTRYPOINT ["/dns-reverse-proxy"]