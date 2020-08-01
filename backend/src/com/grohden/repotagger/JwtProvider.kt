package com.grohden.repotagger

import com.auth0.jwt.JWT
import com.auth0.jwt.JWTVerifier
import com.auth0.jwt.algorithms.Algorithm
import com.grohden.repotagger.dao.tables.User
import java.util.*

class JwtProvider(
    private val issuer: String,
    private val audience: String
) {
    private val secret by lazy { EnvProvider.jwtKeySecret }
    private val validityInMs = 36_000_00 * 10 // 10 hours
    private val algorithm = Algorithm.HMAC512(secret)

    val verifier: JWTVerifier = JWT
        .require(algorithm)
        .withAudience(audience)
        .withIssuer(issuer)
        .build()

    /**
     * Produce a token for the given user
     */
    fun makeToken(user: User): String = JWT.create()
        .withSubject("Authentication")
        .withIssuer(issuer)
        .withAudience(audience)
        .withClaim("id", user.idForJWT)
        .withExpiresAt(getExpiration())
        .sign(algorithm)

    /**
     * Calculate the expiration Date based on current time + the given validity
     */
    private fun getExpiration() = Date(System.currentTimeMillis() + validityInMs)
}