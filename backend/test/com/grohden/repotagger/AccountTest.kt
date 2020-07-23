package com.grohden.repotagger

import com.grohden.repotagger.dao.CreateUserInput
import com.grohden.repotagger.routes.FacadeError
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
import kotlin.test.Test

class AccountTest : BaseTest() {
    @BeforeTest
    fun setupBefore() {
        mockFindUserByCredential()
    }

    @Test
    fun `login should succeed with token`() = testApp {
        handleRequest(HttpMethod.Post, "/login") {
            withContentType(ContentType.Application.Json)
            setBody(
                UserPasswordCredential(
                    name = DEFAULT_USER,
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
        handleRequest(HttpMethod.Get, "/repository/starred").apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.Unauthorized
        }
    }

    @Test
    fun `request with token should pass`() = testApp {
        val name = "grohden"
        mockFindUserByCredential(userName = name)
        mockFindUserById(userName = name)

        handleRequest(HttpMethod.Get, "/repository/starred") {
            withAuthorization(userName = name)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.OK
            response.content.shouldNotBeNullOrBlank()
        }
    }

    @Test
    fun `register user should succeed`() = testApp {
        // Mockk returns a empty stub.
        every { mockedDao.findUserByUserName(any()) } returns null

        handleRequest(HttpMethod.Post, "/register") {
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
        val body = CreateUserInput(
            name = "grohden",
            password = "123456",
            displayName = "Johnny Test"
        ).let { gson.toJson(it) }

        // user is already mocked, and theoretically already on DB
        handleRequest(HttpMethod.Post, "/register") {
            withContentType(ContentType.Application.Json)
            setBody(body)
        }.apply {
            requestHandled shouldBe true
            response.status() shouldBeEqualTo HttpStatusCode.BadRequest
            response.content shouldBeEqualTo FacadeError.USER_NAME_TAKEN.message
        }
    }
}
