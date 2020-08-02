package com.grohden.repotagger.api

import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.tables.User
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.dao.tables.toDTOList
import com.grohden.repotagger.github.api.GithubClient
import io.ktor.application.call
import io.ktor.auth.authenticate
import io.ktor.auth.authentication
import io.ktor.http.HttpStatusCode
import io.ktor.request.receiveOrNull
import io.ktor.response.respond
import io.ktor.routing.*

fun Route.userTag(
    dao: DAOFacade,
    github: GithubClient
) {
    authenticate {
        route("/tag") {

            /**
             * Lists all tags owned by current user
             *
             * Returns OK and a list of [UserTagDTO]
             */
            get("/list") {
                val user = call.authentication.principal<User>()!!
                val tags = dao.findUserTags(user)

                call.respond(HttpStatusCode.OK, tags)
            }

            /**
             * FIXME: should be moved to repository
             *
             * Registers a user tag on a repository
             *
             * Receives a [CreateTagInput]
             *
             * Returns OK response with the newly created [UserTagDTO]
             */
            post("/add") {
                val input = call.receiveOrNull<CreateTagInput>()!!
                val user = call.authentication.principal<User>()!!

                var repo = dao.findUserRepositoryByGithubId(user, input.repoGithubId)
                if (repo == null) {
                    val remoteRepo = github.repositoryById(input.repoGithubId)

                    repo = dao.createUserRepository(
                        user = user,
                        githubId = remoteRepo.id,
                        name = remoteRepo.name,
                        description = remoteRepo.description,
                        url = remoteRepo.url
                    )
                }

                val tag = dao.createOrFindUserTag(user, input.tagName).also { tag ->
                    dao.createTagRelationToRepository(
                        tagId = tag.id,
                        repositoryId = repo.id
                    )
                }

                call.respond(HttpStatusCode.OK, tag)
            }
        }
    }
}