package io.genox.tink;

import com.getcapacitor.Logger;

public class Tink {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
