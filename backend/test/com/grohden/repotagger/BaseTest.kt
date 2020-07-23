package com.grohden.repotagger

import com.google.gson.Gson
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.DAOFacadeDatabase
import com.grohden.repotagger.dao.tables.User
import io.ktor.auth.UserPasswordCredential
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.server.testing.TestApplicationEngine
import io.ktor.server.testing.TestApplicationRequest
import io.ktor.server.testing.withTestApplication
import io.mockk.every
import io.mockk.mockk
import org.jetbrains.exposed.sql.Database

const val DEFAULT_USER = "jonny.test"
const val DEFAULT_PASS = "123456"

abstract class BaseTest {
    protected val gson = Gson()
    protected val mockedDao = mockk<DAOFacade>(relaxed = true)

    protected fun getInMemoryDao(): DAOFacade {
        return Database
            .connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1", driver = "org.h2.Driver")
            .let(::DAOFacadeDatabase)
            .apply { init() }
    }

    protected fun testApp(callback: TestApplicationEngine.() -> Unit) {
        withTestApplication({
            moduleWithDependencies(testing = true, dao = mockedDao)
        }, callback)
    }

    /**
     * Mocks our server, but not using mocked dao.
     * This may be useful for a more e2e approach
     *
     * Note: [mockedDao] mock methods will not work unless
     * [mockedDao] is passed as [dao] param.
     */
    protected fun testApp(
        dao: DAOFacade,
        callback: TestApplicationEngine.(dao: DAOFacade) -> Unit
    ) {
        withTestApplication({
            moduleWithDependencies(testing = true, dao = dao)
        }) { callback(this, dao) }
    }


    protected fun TestApplicationRequest.withContentType(type: ContentType) {
        addHeader(HttpHeaders.ContentType, type.toString())
    }

    protected fun TestApplicationRequest.withAuthorization(
        userName: String = DEFAULT_USER,
        password: String = DEFAULT_PASS
    ) {
        withAuthorization(UserPasswordCredential(userName, password))
    }

    private fun TestApplicationRequest.withAuthorization(credentials: UserPasswordCredential) {
        withAuthorization(mockedDao.findUserByCredentials(credentials)!!)
    }

    protected fun TestApplicationRequest.withAuthorization(user: User) {
        val token = JwtConfig.makeToken(user)

        addHeader("Authorization", "Bearer $token")
    }

    protected fun mockFindUserByCredential(
        userId: Int = 1,
        userName: String = DEFAULT_USER,
        password: String = DEFAULT_PASS
    ) {
        val credentials = UserPasswordCredential(userName, password)

        every { mockedDao.findUserByCredentials(credentials) } returns mockk {
            every { idForJWT } returns userId
            every { name } returns userName
            every { displayName } returns "Johnny Test"
            every { passwordHash } returns PasswordHash.hash(password)
        }
    }

    protected fun mockFindUserById(
        userId: Int = 1,
        userName: String = DEFAULT_USER,
        password: String = DEFAULT_PASS
    ) {
        every { mockedDao.findUserById(userId) } returns mockk {
            every { idForJWT } returns userId
            every { name } returns userName
            every { displayName } returns "Johnny Test"
            every { passwordHash } returns PasswordHash.hash(password)
        }
    }
}