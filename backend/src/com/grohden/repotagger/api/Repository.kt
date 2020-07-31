package com.grohden.repotagger.api

import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.tables.User
import com.grohden.repotagger.dao.tables.toDTOList
import com.grohden.repotagger.github.api.GithubClient
import io.ktor.application.call
import io.ktor.auth.authenticate
import io.ktor.auth.authentication
import io.ktor.http.HttpStatusCode
import io.ktor.response.respond
import io.ktor.routing.Route
import io.ktor.routing.get
import io.ktor.routing.route

fun Route.repository(dao: DAOFacade, github: GithubClient) {
    authenticate {
        route("/repository") {
            /**
             * List user starred repositories
             */
            get("/starred") {
                val user = call.authentication.principal<User>()!!
                val starred = github.userStarred(user.name)

                call.respond(starred)
            }

            /**
             * List repositories that are related to the given tag id
             */
            get("/all-by-tag/{tagId}") {
                val tagId = call.parameters["tagId"]!!.toInt()
                val user = call.authentication.principal<User>()!!
                val repos = dao
                    .findRepositoriesByUserTag(user.id.value, tagId)
                    .toDTOList()

                call.respond(HttpStatusCode.OK, repos)
            }
        }
    }
}