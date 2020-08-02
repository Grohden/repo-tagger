package com.grohden.repotagger

import com.grohden.repotagger.api.DetailedRepository
import com.grohden.repotagger.dao.CreateUserInput
import com.grohden.repotagger.dao.tables.SourceRepositoryDTO
import com.grohden.repotagger.extensions.fromJson
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.handleRequest
import org.amshove.kluent.*
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test

class RepositoryTest : BaseTest() {
    @BeforeTest
    fun setupBefore() {
        memoryDao.init()
    }

    @AfterTest
    fun setupAfter() {
        memoryDao.dropAll()
    }

    @Test
    fun `should list all tags of a repository`() = testApp {
        val user = memoryDao.createUser(
            CreateUserInput(
                name = "grohden",
                displayName = "Gabriel",
                password = "123456"
            )
        )

        val repository = memoryDao.createUserRepository(
            user = user,
            githubId = 130309267,
            name = "Johnny test",
            description = "test",
            url = ""
        )

        val tags = listOf(
            memoryDao.createUserTag(user, "dart"),
            memoryDao.createUserTag(user, "kotlin")
        )

        tags.forEach { tag ->
            memoryDao.createTagRelationToRepository(tag.id, repository.id)
        }


        handleRequest(HttpMethod.Get, "/api/repository/details/${repository.githubId}") {
            withContentType(ContentType.Application.Json)
            withAuthorization(user)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content shouldNotBe null

            val repo = response.content!!.let {
                gson.fromJson<DetailedRepository>(it)
            }

            repo.userTags.map { it.name }
                .shouldContainAll(tags.map { it.name })
        }
    }

    @Test
    fun `should list all repositories of a tag`() = testApp {
        val user = memoryDao.createUser(
            CreateUserInput(
                name = "grohden",
                displayName = "Gabriel",
                password = "123456"
            )
        )

        val tag = memoryDao.createUserTag(user, "dart")
        val repositories = listOf(
            memoryDao.createUserRepository(
                user = user,
                githubId = 130309267,
                name = "Johnny test",
                description = "test",
                url = ""
            )
        )

        repositories.forEach { repository ->
            memoryDao.createTagRelationToRepository(tag.id, repository.id)
        }

        handleRequest(HttpMethod.Get, "/api/repository/all-by-tag/${tag.id}") {
            withContentType(ContentType.Application.Json)
            withAuthorization(user)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content shouldNotBe null

            val repos = response.content!!.let {
                gson.fromJson<List<SourceRepositoryDTO>>(it)
            }

            repos.map { it.name }
                .shouldContainAll(repositories.map { it.name })
        }
    }


    @Test
    fun `should delete a tag of a repository`() = testApp {
        val user = memoryDao.createUser(
            CreateUserInput(
                name = "grohden",
                displayName = "Gabriel",
                password = "123456"
            )
        )

        val repository = memoryDao.createUserRepository(
            user = user,
            githubId = 130309267,
            name = "Johnny test",
            description = "test",
            url = ""
        )
        val tag = memoryDao.createUserTag(user, "dart")

        memoryDao.createTagRelationToRepository(tag.id, repository.id)


        handleRequest(
            HttpMethod.Delete,
            "/api/repository/${repository.githubId}/remove-tag/${tag.id}"
        ) {
            withContentType(ContentType.Application.Json)
            withAuthorization(user)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content shouldBe null
        }

        memoryDao.findUserTagsByRepository(
            userId = user.id.value,
            repositoryId = repository.id
        ).shouldBeEmpty()
    }
}
