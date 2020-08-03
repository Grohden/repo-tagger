package com.grohden.repotagger

import io.ktor.application.ApplicationCall
import io.ktor.sessions.get
import io.ktor.sessions.sessions

const val TAGGER_SESSION_COOKIE = "SESSION_ID"

class NoSessionException : RuntimeException()


/**
 * Base session data for the app
 */
class TaggerSessionUser(
    val githubUserId: Int,
    val name: String,
    val token: String
)

/**
 * Requires a session, if no session is
 * present [NoSessionException] is thrown
 */
fun ApplicationCall.requireSession(): TaggerSessionUser {
    val session = sessions.get<TaggerSessionUser>()

    return session ?: throw NoSessionException()
}