package com.grohden.repotagger

object EnvProvider {
    private val env by lazy { System.getenv() }

    val hashKeySecret by lazy { env["HASH_KEY_SECRET"]!! }
    val jwtKeySecret by lazy { env["JWT_KEY_SECRET"]!! }

    fun validate() {
        assert(env["HASH_KEY_SECRET"]?.isNotBlank() == true) {
            "HASH_KEY_SECRET variable must not be null or blank"
        }
        assert(env["JWT_KEY_SECRET"]?.isNotBlank() == true) {
            "JWT_KEY_SECRET variable must not be null or blank"
        }
    }
}