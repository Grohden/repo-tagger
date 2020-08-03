package com.grohden.repotagger.utils

import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.server.testing.TestApplicationRequest

fun TestApplicationRequest.withContentType(type: ContentType) {
    addHeader(HttpHeaders.ContentType, type.toString())
}
