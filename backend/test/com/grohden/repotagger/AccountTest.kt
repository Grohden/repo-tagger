package com.grohden.repotagger

import com.grohden.repotagger.dao.CreateUserInput
import io.ktor.auth.UserPasswordCredential
import io.ktor.http.ContentType
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.server.testing.handleRequest
import io.ktor.server.testing.setBody
import io.mockk.every
import org.amshove.kluent.shouldBe
import org.amshove.kluent.shouldBeEqualTo
import org.amshove.kluent.shouldBeGreaterThan
import org.amshove.kluent.shouldNotBeNullOrBlank
import kotlin.test.BeforeTest
import kotlin.test.AfterTest
import kotlin.test.Test

class AccountTest : BaseTest() {
    @BeforeTest
    fun setupBefore() {
        memoryDao.init()
    }

    @AfterTest
    fun setupAfter() {
        memoryDao.dropAll()
    }

    @Test
    fun `login should succeed with token`() = testApp {
        val user = createDefaultUser()

        handleRequest(HttpMethod.Post, "/api/login") {
            withContentType(ContentType.Application.Json)
            setBody(UserPasswordCredential(
                name = user.name,
                password = DEFAULT_PASS
            ).let { gson.toJson(it) })
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content.shouldNotBeNullOrBlank().length shouldBeGreaterThan 6
        }
    }

    @Test
    fun `request without token should fail`() = testApp {
        handleRequest(HttpMethod.Get, "/api/repository/starred").apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.Unauthorized
        }
    }

    @Test
    fun `request with token should pass`() = testApp {
        val user = createDefaultUser()

        handleRequest(HttpMethod.Get, "/api/repository/starred") {
            withAuthorization(user)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content.shouldNotBeNullOrBlank()
        }
    }

    @Test
    fun `register user should succeed`() = testApp {
        handleRequest(HttpMethod.Post, "/api/register") {
            withContentType(ContentType.Application.Json)
            setBody(
                CreateUserInput(
                    name = "grohden",
                    password = "123456",
                    displayName = "Johnny Test"
                ).let { gson.toJson(it) }
            )
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.Created
            response.content shouldBeEqualTo null
        }
    }

    @Test
    fun `register duplicated userName should fail`() = testApp {
        val user = createDefaultUser()
        val body = CreateUserInput(
            name = user.name,
            password = "123456",
            displayName = "Johnny Test"
        ).let { gson.toJson(it) }

        handleRequest(HttpMethod.Post, "/api/register") {
            withContentType(ContentType.Application.Json)
            setBody(body)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.BadRequest
            response.content shouldBeEqualTo FacadeError.USER_NAME_TAKEN.message
        }
    }
}
