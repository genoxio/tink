package io.genox.tink

import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "Tink")


class TinkPlugin : Plugin() {
    private val implementation: Tink = Tink()
    private val LOGTAG = "TinkPlugin"

    @PluginMethod
    fun openTink(call: PluginCall) {
        Log.println(Log.INFO, LOGTAG, "open tink method")

        // more logic
        call.resolve()
    }
}
