FROM golang:1.19
#COPY ./cmd/ops-test-app ./
#COPY go.mod go.sum ./
#RUN go mod download
#COPY *.go ./
ENV POSTGRESQL_HOST postgres
RUN mkdir /app
COPY . /app/
WORKDIR /app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main ./cmd/ops-test-app
EXPOSE 8080
CMD ["./main"]
