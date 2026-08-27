package io.genox.tink

import com.getcapacitor.Logger

class Tink {
    fun echo(value: String?): String? {
        Logger.info("Echo", value)
        return value
    }
}
