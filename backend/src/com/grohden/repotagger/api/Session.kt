package com.grohden.repotagger.api

import com.grohden.repotagger.EnvProvider
import com.grohden.repotagger.TaggerSessionUser
import com.grohden.repotagger.github.api.GithubClient
import io.ktor.application.call
import io.ktor.auth.OAuthServerSettings
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.response.header
import io.ktor.response.respond
import io.ktor.response.respondRedirect
import io.ktor.routing.Route
import io.ktor.routing.get
import io.ktor.routing.route
import io.ktor.sessions.get
import io.ktor.sessions.sessions
import io.ktor.sessions.set

/**
 * Account related api api
 */
fun Route.session(
    usePersonalToken: Boolean,
    githubClient: GithubClient,
    githubOAuthProvider: OAuthServerSettings.OAuth2ServerSettings
) {
    /**
     * This is where the frontend web will hit the server asking for the OAuth
     * redirection
     *
     * If the server is dev or test, you are supposed to provide a personal access token
     * and this wil end up creating your session using the provided token
     *
     * On production, this will redirect to github oauth route
     */
    route("/oauth") {
        handle {
            val token = EnvProvider.personalAccessToken
            if (token != null && usePersonalToken) {
                val userData = githubClient.userData(token)

                call.sessions.set(
                    TaggerSessionUser(
                        githubUserId = userData.id,
                        name = userData.login,
                        token = token
                    )
                )

                val referer = call.request.headers["referer"];
                if (referer != null) {
                    call.respondRedirect("$referer#/home")
                } else {
                    call.respondRedirect("/#/home")
                }
                return@handle
            }


            val clientId = EnvProvider.githubClientId!!;
            val githubOauthUrl = "https://github.com/login/oauth/authorize"

            call.respondRedirect("$githubOauthUrl?client_id=$clientId")
        }
    }


    get("/has-session") {
        val has = call.sessions.get<TaggerSessionUser>() != null
        call.respond(HttpStatusCode.OK, has)
    }

    /**
     * This is where github will hit us with the temp generated code,
     * we then use this code to generate the user token and redirect him
     *
     * We may redirect him to the provided URL or home if none is provided by github
     */
    route("/login") {
        handle {
            val code = call.parameters["code"] ?: error("no code for auth")
            val accessData = githubClient.accessToken(
                clientId = githubOAuthProvider.clientId,
                clientSecret = githubOAuthProvider.clientSecret,
                code = code
            )

            val userData = githubClient.userData(accessData.accessToken)

            call.sessions.set(
                TaggerSessionUser(
                    githubUserId = userData.id,
                    name = userData.login,
                    token = accessData.accessToken
                )
            )

            if (accessData.redirectUri != null) {
                call.respondRedirect(accessData.redirectUri)
            } else {
                call.respondRedirect("/#/home")
            }
        }
    }
}
