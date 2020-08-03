package com.grohden.repotagger

import com.google.gson.Gson
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.DAOFacadeDatabase
import io.ktor.config.MapApplicationConfig
import io.ktor.http.HttpMethod
import io.ktor.server.testing.TestApplicationEngine
import io.ktor.server.testing.handleRequest
import io.ktor.server.testing.withTestApplication
import io.mockk.mockk
import org.amshove.kluent.shouldBe
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

    protected fun TestApplicationEngine.login() {
        handleRequest(HttpMethod.Get, "/api/oauth").apply {
            requestHandled shouldBe true
        }
    }

    protected fun testApp(callback: TestApplicationEngine.() -> Unit) {
        withTestApplication({
            (environment.config as MapApplicationConfig).apply {
                // Set here the properties
                put("ktor.environment", "test")
            }
            moduleWithDependencies(dao = memoryDao)
        }, callback)
    }
}