package com.grohden.repotagger

import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.CreateUserInput
import com.grohden.repotagger.dao.tables.UserTagDTO
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.handleRequest
import io.ktor.server.testing.setBody
import org.amshove.kluent.shouldBe
import org.amshove.kluent.shouldBeEqualTo
import org.amshove.kluent.shouldNotBeEmpty
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test

class UserTagTest : BaseTest() {
    @BeforeTest
    fun setupBefore() {
        memoryDao.init()
    }

    @AfterTest
    fun setupAfter() {
        memoryDao.dropAll()
    }

    @Test
    fun `should create and list tag`() = testApp {
        val user = createDefaultUser()

        handleRequest(HttpMethod.Post, "/api/tag/add") {
            withContentType(ContentType.Application.Json)
            withAuthorization(user)
            setBody(CreateTagInput(
                tagName = "jojo",
                repoGithubId = 130309267
            ).let { gson.toJson(it) })
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content.let {
                gson.fromJson(it, UserTagDTO::class.java)
            }.name shouldBeEqualTo "jojo"
        }

        val tags = memoryDao.findUserTags(user).apply {
            shouldNotBeEmpty()
        }

        tags.first().apply {
            name shouldBeEqualTo "jojo"
        }

    }
}
