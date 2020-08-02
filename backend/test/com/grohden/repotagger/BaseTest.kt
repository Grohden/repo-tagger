package com.grohden.repotagger

import com.google.gson.Gson
import com.grohden.repotagger.dao.CreateUserInput
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.DAOFacadeDatabase
import com.grohden.repotagger.dao.tables.User
import io.ktor.auth.UserPasswordCredential
import io.ktor.config.MapApplicationConfig
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.server.testing.TestApplicationEngine
import io.ktor.server.testing.TestApplicationRequest
import io.ktor.server.testing.withTestApplication
import io.mockk.mockk
import org.jetbrains.exposed.sql.Database

const val DEFAULT_PASS = "123456"

@Suppress("EXPERIMENTAL_API_USAGE")
abstract class BaseTest {
    protected val gson = Gson()
    protected val mockedDao = mockk<DAOFacade>(relaxed = true)

    protected val memoryDao: DAOFacadeDatabase by lazy {
        Database
            .connect("jdbc:h2:mem:test;DB_CLOSE_DELAY=-1", driver = "org.h2.Driver")
            .let { db -> DAOFacadeDatabase(isLogEnabled = true, db = db) }
    }


    protected fun testApp(callback: TestApplicationEngine.() -> Unit) {
        withTestApplication({
            (environment.config as MapApplicationConfig).apply {
                // Set here the properties
                put("ktor.environment", "test")
                put("jwt.domain", "test")
                put("jwt.audience", "test")
                put("jwt.realm", "test")
            }
            moduleWithDependencies(dao = memoryDao)
        }, callback)
    }


    protected fun TestApplicationRequest.withContentType(type: ContentType) {
        addHeader(HttpHeaders.ContentType, type.toString())
    }

    private fun TestApplicationRequest.withAuthorization(credentials: UserPasswordCredential) {
        withAuthorization(mockedDao.findUserByCredentials(credentials)!!)
    }

    protected fun createDefaultUser(): User {
        return memoryDao.createUser(
            CreateUserInput(
                name = "grohden",
                displayName = "Gabriel",
                password = DEFAULT_PASS
            )
        )
    }

    protected fun TestApplicationRequest.withAuthorization(user: User) {
        val token = JwtProvider(
            issuer = "test",
            audience = "test"
        ).makeToken(user)

        addHeader("Authorization", "Bearer $token")
    }
}