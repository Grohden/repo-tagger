package com.grohden.repotagger

object EnvProvider {
    private val env by lazy { System.getenv() }

    val hashKeySecret by lazy { env["HASH_KEY_SECRET"]!! }
    val jwtKeySecret by lazy { env["JWT_KEY_SECRET"]!! }


    fun validate() {
        assert(hashKeySecret.isNotBlank())
        assert(jwtKeySecret.isNotBlank())
    }
}