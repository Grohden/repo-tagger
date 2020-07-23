package com.grohden.repotagger.routes

import com.grohden.repotagger.JwtConfig
import com.grohden.repotagger.dao.CreateUserInput
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.github.api.GithubClient
import io.ktor.application.call
import io.ktor.auth.UserPasswordCredential
import io.ktor.client.features.logging.DEFAULT
import io.ktor.client.features.logging.Logger
import io.ktor.http.HttpStatusCode
import io.ktor.request.receiveOrNull
import io.ktor.response.respond
import io.ktor.response.respondText
import io.ktor.routing.Routing
import io.ktor.routing.post

/**
 * Account related api routes
 */
fun Routing.account(
    dao: DAOFacade,
    github: GithubClient
) {
    val logger = Logger.DEFAULT

    /**
     * Registers a user on the system
     *
     * Receives a [CreateUserInput]
     *
     * Returns a confirmation string or error if the user
     * already exists in database or github doesn't find it
     */
    post("/register") {
        val input = call.receiveOrNull<CreateUserInput>()

        if (input == null) {
            call.respondError(
                status = HttpStatusCode.BadRequest,
                errorMessage = FacadeError.INVALID_PAYLOAD
            )
            return@post
        }

        val foundUser = dao.findUserByUserName(input.name)
        if (foundUser != null) {
            call.respondError(
                status = HttpStatusCode.BadRequest,
                errorMessage = FacadeError.USER_NAME_TAKEN
            )

            return@post
        }


        try {
            github.userData(input.name).also {
                assert(it.login.isNotBlank())
            }
        } catch (pokemon: Throwable) {
            logger.log(pokemon.message ?: "Unknown error")

            call.respondError(
                status = HttpStatusCode.BadRequest,
                errorMessage = FacadeError.GITHUB_NAME_NOT_FOUND
            )

            return@post
        }


        dao.createUser(input)
        call.respond(HttpStatusCode.Created)
    }

    /**
     * Logs a user based on given credential
     *
     * Receives a [UserPasswordCredential]
     *
     * Returns a token which should be user for authenticated
     * requests
     */
    post("/login") {
        val user = call
            .receiveOrNull<UserPasswordCredential>()
            ?.let { dao.findUserByCredentials(it) }

        if (user == null) {
            call.respondText(status = HttpStatusCode.BadRequest) {
                "Invalid username or password"
            }
        } else {
            call.respondText(status = HttpStatusCode.OK) {
                JwtConfig.makeToken(user)
            }
        }
    }
}