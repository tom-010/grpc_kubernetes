FROM golang AS build

ENV location /app

WORKDIR ${location}/server

ADD ./server ${location}/server


# Download all the dependencies
RUN go get -d ./...
# Install the package
RUN go install ./...


RUN CGO_ENABLED=0 go build -o /bin/go-grpc-greeter-server


# Build stage II : Go binaries are self-contained executables.
FROM scratch
COPY --from=build /bin/go-grpc-greeter-server /bin/go-grpc-greeter-server


ENTRYPOINT ["/bin/go-grpc-greeter-server"]
EXPOSE 50051