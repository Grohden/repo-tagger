# repo_tagger

Backend application for repo tagger

## Getting Started

This project is written in kotlin using ktor and it's
meant to be a tagger manager for github repositories.

A user may:
 * Manage tags for a repository
 * Search all repositories with a tag

### Setup 

### Requirements
JDK 8

### Env variables
To run the project, first load the needed env variables:

```bash
# Hash secret for passwords
# hashing algorithm, it should
# be a hex string without 0x
# (this means that 0123456789abcdef are 
# only allowed chars)
export HASH_KEY_SECRET=""

# Hash secret for JWT token generator
export JWT_KEY_SECRET=""
```

There's a helper `env.dev.sh` with default variables you can
use, but as the name suggests, you should only use it for dev.

### Run server

Once you have correct env variables on your path run:
 * `./gradlew run`

And you will have the tagger API ready to accept requests.

### Unit Testing

Once you have correct env variables on your path run:
 * `./gradlew test`

If you get a `BUILD SUCESSFUL` it means all current tests
are passing.

## Libs

* Ktor - Server layer in kotlin
* Exposed - DSL and DAO layers in kotlin
* Hikari - DB connection pool  

### NSFAQ (Not so frequent asked questions)

* Why use DTOs?
    * A: https://github.com/JetBrains/Exposed/issues/497 
* Where's the service layer?
    * Planned. But to cut complexity I decided to let the facade
    layer handle the business logic - and I'm aware that it's not good.