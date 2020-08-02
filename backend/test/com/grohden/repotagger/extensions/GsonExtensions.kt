package com.grohden.repotagger.extensions

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken


inline fun <reified T> Gson.fromJson(json: String) =
    fromJson<T>(json, object : TypeToken<T>() {}.type)
