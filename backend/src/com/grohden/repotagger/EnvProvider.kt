package com.grohden.repotagger

object EnvProvider {
    private val env by lazy { System.getenv() }

    val hashKeySecret by lazy { env["HASH_KEY_SECRET"]!! }
    val githubClientId by lazy { env["GITHUB_CLIENT_ID"] }
    val githubClientSecret by lazy { env["GITHUB_CLIENT_SECRET"] }
    val personalAccessToken by lazy { env["PERSONAL_ACCESS_TOKEN"] }

    fun validate() {
        assert(env["HASH_KEY_SECRET"]?.isNotBlank() == true) {
            "HASH_KEY_SECRET variable must not be null or blank"
        }
    }
}