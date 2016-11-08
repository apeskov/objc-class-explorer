package classbrowser;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;

public class Connection {

    final String host = "localhost";
    final int port = 2000;
    final int connectionTimeout = 2000;

    Socket socket;
    DataInputStream input;
    DataOutputStream output;

    public void run() throws IOException {

        socket = new Socket(host, port);

        input = new DataInputStream(socket.getInputStream());
        output = new DataOutputStream(socket.getOutputStream());

        output.close();
        input.close();
        socket.close();
    }
}
