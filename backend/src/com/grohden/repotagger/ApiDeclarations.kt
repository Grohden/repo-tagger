package com.grohden.repotagger

import io.ktor.application.ApplicationCall
import io.ktor.http.HttpStatusCode
import io.ktor.response.respondText

/**
 * Extension to show standard error messages
 */
suspend fun ApplicationCall.respondError(
    status: HttpStatusCode,
    errorMessage: FacadeError
) = this.respondText(status = status) { errorMessage.message }

/**
 * Error messages exhibited by facades/api
 */
enum class FacadeError(val message: String) {
    INVALID_PAYLOAD("invalid payload"),
    USER_NAME_TAKEN("User name already taken"),
    GITHUB_NAME_NOT_FOUND("Github api returned error, user name may not exist")
}