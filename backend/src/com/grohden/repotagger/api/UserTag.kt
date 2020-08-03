package com.grohden.repotagger.api

import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.tables.UserTagDTO
import com.grohden.repotagger.github.api.GithubClient
import com.grohden.repotagger.requireSession
import io.ktor.application.call
import io.ktor.http.HttpStatusCode
import io.ktor.request.receiveOrNull
import io.ktor.response.respond
import io.ktor.routing.Route
import io.ktor.routing.get
import io.ktor.routing.post
import io.ktor.routing.route

fun Route.userTag(
    githubClient: GithubClient,
    dao: DAOFacade
) {
    route("/tag") {

        /**
         * Lists all tags owned by current user
         *
         * Returns OK and a list of [UserTagDTO]
         */
        get("/list") {
            val session = call.requireSession()
            val tags = dao.findUserTags(
                userGithubId = session.githubUserId
            )

            call.respond(HttpStatusCode.OK, tags)
        }


        /**
         * Lists all repositories by a tag
         *
         * Returns OK and a list of [DetailedRepository]
         */
        get("/{tagId}/repositories") {
            val tagId = call.parameters["tagId"]!!.toInt()
            val session = call.requireSession()
            val repositories = dao.findRepositoriesByUserTag(
                userGithubId = session.githubUserId,
                tagId = tagId
            ).toSimpleRepositoryList()

            call.respond(HttpStatusCode.OK, repositories)
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
            val session = call.requireSession()

            var repo = dao.findUserRepositoryByGithubId(
                userGithubId = session.githubUserId,
                repoGithubId = input.repoGithubId
            )

            if (repo == null) {
                // We avoid hitting the rate limit
                // and also spamming a LOT of requests
                // by saving the repo when it's created
                // TODO: we will be outsync with github data
                //  we need to put some "last time updated"
                //  tolerance into the [SourceRepositoryTable]
                val githubRepo = githubClient.repositoryById(
                    input.repoGithubId,
                    session.token
                )

                repo = dao.createUserRepository(
                    userGithubId = session.githubUserId,
                    repoGithubId = input.repoGithubId,
                    name = githubRepo.name,
                    ownerName = githubRepo.owner.login,
                    description = githubRepo.description,
                    language = githubRepo.language,
                    htmlUrl = githubRepo.htmlUrl,
                    stargazersCount = githubRepo.stargazersCount,
                    forksCount = githubRepo.forksCount
                )
            }

            val tag = dao.createOrFindUserTag(
                userGithubId = session.githubUserId,
                tagName = input.tagName
            ).also { tag ->
                dao.createTagRelationToRepository(
                    tagId = tag.tagId,
                    repoId = repo.repoId
                )
            }

            call.respond(HttpStatusCode.OK, tag)
        }
    }
}