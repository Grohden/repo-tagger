package com.grohden.repotagger

import com.grohden.repotagger.api.account
import com.grohden.repotagger.api.repository
import com.grohden.repotagger.api.userTag
import com.grohden.repotagger.dao.DAOFacade
import com.grohden.repotagger.dao.DAOFacadeDatabase
import com.grohden.repotagger.github.api.GithubClient
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import io.ktor.application.*
import io.ktor.auth.Authentication
import io.ktor.auth.jwt.jwt
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.features.json.GsonSerializer
import io.ktor.client.features.json.JsonFeature
import io.ktor.client.features.logging.LogLevel
import io.ktor.client.features.logging.Logging
import io.ktor.features.*
import io.ktor.gson.gson
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.http.content.defaultResource
import io.ktor.http.content.resources
import io.ktor.http.content.static
import io.ktor.request.path
import io.ktor.response.respond
import io.ktor.routing.route
import io.ktor.routing.routing
import io.ktor.server.netty.EngineMain
import org.jetbrains.exposed.sql.Database
import org.slf4j.event.Level

/**
 * Pool of JDBC connections used.
 */
val pool by lazy {
    HikariDataSource().apply {
        driverClassName = "org.h2.Driver"
        jdbcUrl = "jdbc:h2:mem:test"
        username = ""
        password = ""
    }
}

fun main(args: Array<String>) {
    EnvProvider.validate()
    EngineMain.main(args)
}


@Suppress("EXPERIMENTAL_API_USAGE")
fun Application.getEnv(entry: String) =
    environment.config.property(entry).getString()

val Application.envKind
    get() = getEnv("ktor.environment")

val Application.isDev
    get() = envKind == "dev"

val Application.isTesting
    get() = envKind == "test"


/**
 * This is our DAO (data access object), it manages our connections and
 * manipulations of the data source (currently a in memory db)
 *
 * We may wish in the future to use many DAO's (for many entities),
 * in that case we should consider using a DI approach.
 *
 * FIXME: as soon as the last db connection is killed the h2 mem db loses
 *  it's contents, thanks to hikari this doesn't happen.
 *  We should consider using a persistent DB.
 */
fun Application.getDao(): DAOFacade {
    return DAOFacadeDatabase(
        isLogEnabled = isDev,
        db = Database.connect(pool)
    )
}

/**
 * Our http client used by the server to communicate
 * with other APIs
 */
fun Application.makeClient(): HttpClient {
    @Suppress("EXPERIMENTAL_API_USAGE")
    return HttpClient(CIO) {
        install(Logging) {
            level = when {
                isDev -> LogLevel.INFO
                isTesting -> LogLevel.INFO
                else -> LogLevel.NONE
            }
        }
        install(JsonFeature) {
            serializer = GsonSerializer()
        }
    }
}

@Suppress("unused") // Referenced in application.conf
fun Application.module() {
    val dao = getDao().also {
        it.init()
    }

    environment.monitor.subscribe(ApplicationStopped) { pool.close() }
    moduleWithDependencies(dao = dao)
}

fun Application.moduleWithDependencies(dao: DAOFacade) {
    val client = makeClient()
    val github = GithubClient(client)

    install(DefaultHeaders) {
        header(HttpHeaders.Server, "") // OWASP recommended
    }

    install(ConditionalHeaders)

    if (isDev || isTesting) {
        install(CallLogging) {
            level = Level.INFO
            filter { call -> call.request.path().startsWith("/") }
        }

        install(CORS) {
            method(HttpMethod.Options)
            method(HttpMethod.Put)
            method(HttpMethod.Delete)
            method(HttpMethod.Patch)
            header(HttpHeaders.Authorization)
            header(HttpHeaders.ContentType)
            allowCredentials = true
            anyHost() // @TODO: Don't do this in production if possible. Try to limit it.
        }
    }

    install(DataConversion)

    val jwtIssuer = getEnv("jwt.domain")
    val jwtAudience = getEnv("jwt.audience")
    val jwtRealm = getEnv("jwt.realm")
    val jwtProvider = JwtProvider(jwtIssuer, jwtAudience)

    install(Authentication) {
        jwt {
            realm = jwtRealm
            verifier(jwtProvider.verifier)
            validate {
                it.payload.getClaim("id").asInt()?.let(dao::findUserById)
            }
        }
    }

    install(ContentNegotiation) {
        // TODO: retry kotlinx serialization, had some problems with
        //  kotlin dsl in gradle buildscript
        gson()
    }

    routing {
        if (isDev || isTesting) {
            trace { application.log.trace(it.buildText()) }
        }

        static("/") {
            resources("web")
            defaultResource("web/index.html")
        }

        route("api") {
            account(dao, github, jwtProvider)
            repository(dao, github)
            userTag(dao, github)
        }

        install(StatusPages) {
            exception<AuthenticationException> {
                call.respond(HttpStatusCode.Unauthorized)
            }
            exception<AuthorizationException> {
                call.respond(HttpStatusCode.Forbidden)
            }
        }
    }
}


class AuthenticationException : RuntimeException()
class AuthorizationException : RuntimeException()

