package com.grohden.repotagger.api

import io.ktor.application.ApplicationCall
import io.ktor.request.ContentTransformationException
import io.ktor.request.receive


class BadRequest(
    message: String
) : RuntimeException(message)


class NotFound(
    message: String
) : RuntimeException(message)

/**
 * Requires a parameter if it's
 * not present throw [BadRequest]
 */
fun ApplicationCall.requireParam(key: String): String {
    return parameters[key] ?: throw BadRequest("Arg $key is invalid")
}

/**
 * Requires a parameter to be non null and int, otherwise
 * throws [BadRequest]
 */
fun ApplicationCall.requireIntParam(key: String): Int {
    return try {
        requireParam(key).toInt()
    } catch (error: NumberFormatException) {
        throw BadRequest("Arg $key is invalid")
    }
}

/**
 * Requires a parameter to be non null and int, otherwise
 * throws [BadRequest]
 */
suspend inline fun <reified T : Any> ApplicationCall.requireReceived(): T {
    return try {
        receive()
    } catch (error: ContentTransformationException) {
        throw BadRequest("Could not parse body contents")
    }
}