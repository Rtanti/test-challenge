FROM golang:1.20-alpine AS builder
WORKDIR /app
RUN adduser -D gouser && chown -R gouser /app
USER gouser
COPY go.mod go.sum cmd /app/
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main ./ops-test-app

FROM alpine:latest AS runner
COPY --from=builder /app/main /main
RUN adduser -D gouser && chown -R gouser /main
USER gouser
EXPOSE 8080
ENTRYPOINT ["/main"]
