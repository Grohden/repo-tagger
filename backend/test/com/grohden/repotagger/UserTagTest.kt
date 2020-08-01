package com.grohden.repotagger

import com.grohden.repotagger.dao.CreateTagInput
import com.grohden.repotagger.dao.CreateUserInput
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.handleRequest
import io.ktor.server.testing.setBody
import org.amshove.kluent.shouldBe
import org.amshove.kluent.shouldBeEqualTo
import org.amshove.kluent.shouldNotBeEmpty
import kotlin.test.Test

class UserTagTest : BaseTest() {
    @Test
    fun `should create and list tag`() = testApp(getInMemoryDao()) { dao ->
        val user = dao.createUser(
            CreateUserInput(
                name = "grohden",
                displayName = "Gabriel",
                password = "123456"
            )
        )

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
        }

        dao.findUserTags(user).shouldNotBeEmpty()
        // Can't test it :DDD
        // https://github.com/JetBrains/Exposed/issues/848#issuecomment-630813355
        // Strangely, this works with the server. Hikari may be interfering.

        // val jojo = tags.first()
        // jojo.name shouldBeEqualTo "jojo"
    }
}
