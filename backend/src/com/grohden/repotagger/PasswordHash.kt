package com.grohden.repotagger

import io.ktor.util.hex
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec


/**
 * Singleton responsible for hashing user
 * passwords
 *
 * TODO: consider using bcrypt for this or
 *  exploring better ktor crypto api. hashing is not
 *  the way to doit.
 */
object PasswordHash {

    /**
     * Secret hash key used to hash the passwords, and to authenticate the sessions.
     */
    private val hashKey by lazy { hex(EnvProvider.hashKeySecret) }

    /**
     * HMac SHA1 key spec for the password hashing.
     */
    private val hmacKey by lazy {
        SecretKeySpec(hashKey, "HmacSHA1")
    }


    /**
     * Method that hashes a [password] by using the globally defined secret key [hmacKey].
     */
    fun hash(password: Password): HashedPassword {
        val hmac = Mac.getInstance("HmacSHA1").apply {
            init(hmacKey)
        }

        return hex(hmac.doFinal(password.toByteArray(Charsets.UTF_8)))
    }
}
