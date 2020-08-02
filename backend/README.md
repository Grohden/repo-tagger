# Repo tagger backend

Backend application for repo tagger

## Getting Started

This project is written in kotlin using ktor and exposed.

### Development

### Requirements

* JDK
* Env variables set, see `.env.example` on root folder

### Run server

Once you have correct env variables on your path run:
 * `./gradlew run`

And you will have the tagger app ready at [http://localhost:8080](http://localhost:8080).

### Logs

Almost all logs are disabled by default, you can enable
them by changing `resources/application.conf` `environment` entry
to `dev`.

A more fine grained control can be achieved by editing `logback.xml`

### Unit Testing

Once you have correct env variables on your path run:
 * `./gradlew test`

If you get a `BUILD SUCESSFUL` it means all current tests
are passing.