package classbrowser.test.func;

import classbrowser.Connection;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class connectionTest {
    Process sniffRtProcess;

    @Before
    public void preparation() throws IOException {
        // run sniffer rt as a subprocess
        sniffRtProcess = new ProcessBuilder("build/xcode/Release/test_app").start();
    }

    @After
    public void finishing() throws IOException {

        if (sniffRtProcess != null) {
            sniffRtProcess.destroy();
            sniffRtProcess = null;
        }
    }

    @Test
    public void startConnectionTest() {

        try {
            Connection connection = new Connection();
            connection.run();

        } catch (Exception e) {
            Assert.fail(e.toString());
        }

    }

}
