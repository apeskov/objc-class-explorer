package classbrowser;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;

public class ConnectionHandler {

    private final String HOST = "localhost";
    private final int PORT = 2000;

    private final int attemptNum = 10;
    private final int attemptTimeout = 50;

    private Socket socket;
    private DataInputStream input;
    private DataOutputStream output = null;

    private boolean continueReading = false;
    private Thread readerThread;

    private ConnectionHandlerListener delegate;

    /**
     * Constructor with specifying message receiver
     *
     * @param delegate message receiver and event listener
     */
    ConnectionHandler(ConnectionHandlerListener delegate) {
        this.delegate = delegate;
    }

    /**
     * Delegate interface for parsing messages received
     * from sniffer rt.
     */
    interface ConnectionHandlerListener {

        /**
         * Will called upon message arrival.
         * Message data is completed and can be parsed.
         *
         * @param data buffer with message content
         */
        void onMessageReceived(byte[] data);

        void onClose();

        void onError();
    }

    /**
     * Entry point of socket connection handler.
     *
     * Will initialize socket, wait for connection and start additional thread
     * for handling incoming data.
     *
     * @throws IOException if was not able to connect to the sniff rt server.
     */
    void startProcessing() throws Exception {

        /**
         * Attempt to connect for several times. Because of
         * sniff rt requires some time to start listen port
         */
        for (int i = 0; i < attemptNum; i++) {
            try {
                socket = new Socket(HOST, PORT);
                break;
            } catch (IOException e) { Thread.sleep(attemptTimeout); }
        }
        if (!socket.isConnected())
            throw new IOException("Was not able to connect after " + attemptNum + " attempts.");

        input = new DataInputStream(socket.getInputStream());
        output = new DataOutputStream(socket.getOutputStream());
        continueReading = true;

        /* Start reading loop in separate thread */
        readerThread = new Thread( this::readLoop );
        readerThread.start();
    }

    private void readLoop () {

        while (continueReading) {
            try {
                /**
                 * Read header of incoming message. Header is 32bit
                 * integer(4 byte) with size of following message.
                 */
                int ch1 = input.read();
                int ch2 = input.read();
                int ch3 = input.read();
                int ch4 = input.read();
                if ((ch1 | ch2 | ch3 | ch4) < 0) {
                    // EOF - finish reading thread
                    // Socket was closed by server
                    delegate.onClose();
                    return;
                }

                int msgSize = (ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0);

                byte[] data = new byte[msgSize];
                int len = input.read(data, 0, msgSize);

                if (len == -1) return;
                if (len != msgSize) return; // TODO: Add support of messages biggest then 1024

                delegate.onMessageReceived(data);

            } catch (IOException e) {
                e.printStackTrace();
                return;
            }
        }
    }

    void sendMsg(byte[] data) {

        try {
            output.writeInt(data.length);
            output.write(data, 0 , data.length);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Blocking call. Will wait for finishing reader thread.
     */
    void stopProcessing() {

        continueReading = false;

        try {
            socket.shutdownInput();
            socket.shutdownOutput();

            readerThread.join();
            socket.close();

        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
