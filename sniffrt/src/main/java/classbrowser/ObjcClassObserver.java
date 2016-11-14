package classbrowser;

import classbrowser.MessagingProto.Request;
import classbrowser.MessagingProto.Response;
import classbrowser.objc.ClassAccumulator;
import classbrowser.objc.ModuleInfo;
import classbrowser.objc.ClassInfo;
import com.google.protobuf.InvalidProtocolBufferException;

import java.io.IOException;
import java.util.Collection;

public class ObjcClassObserver implements ConnectionHandler.ConnectionHandlerListener {

    private String executableName;
    private ConnectionHandler connectionHandler;
    private ClassAccumulator accumulator = new ClassAccumulator();

    private Process patientProcess;

    private ObjcClassObserverDelegate delegate;

    /**
     * @param delegate listener of Sniffer RT events
     */
    public ObjcClassObserver(ObjcClassObserverDelegate delegate) {

        this.delegate = delegate;
        connectionHandler = new ConnectionHandler(this);
    }

    /**
     * Setter of tested executable name
     *
     * @param executable path to executable
     */
    public void setExecutable(String executable) {
        this.executableName = executable;
    }

    /**
     *  This method should be called first place.
     */
    public void startSniffing() throws Exception {

        try {
            patientProcess = new ProcessBuilder(executableName).inheritIO().start();
            connectionHandler.startProcessing();

        } catch (IOException e) {
            e.printStackTrace();
            throw new Exception("Sniff Runtime was not able to run tested application");
        }
    }

    /**
     *  Call this method at the every end.
     *
     *  This will stop reading socket and close connection.
     *
     *  @param killTestedProcess If true will destroy sniffed process,
     *                           else just leave it running
     */
    public void stopSniffing(boolean killTestedProcess) {

        byte[] msg = Request.newBuilder()
                .setType(Request.Type.Close)
                .build()
                .toByteArray();

        connectionHandler.sendMsg(msg);

        // Blocking call. Will wait for socket
        // closure and join of reading thread
        connectionHandler.stopProcessing();
    }

    public void askModuleList() {

        byte[] msg = Request.newBuilder()
                .setType(Request.Type.GetModuleList)
                .build()
                .toByteArray();

        connectionHandler.sendMsg(msg);
    }

    public void askMainModuleClasses() throws Exception {

        byte[] msg = Request.newBuilder()
                .setType(Request.Type.GetClassesForModule)
                .setModuleId(accumulator.getMainModuleId())
                .build()
                .toByteArray();

        connectionHandler.sendMsg(msg);
    }

    /******************************************
     * Getters
     *****************************************/

    public ModuleInfo[] getModules() {
        return accumulator.getModules();
    }

    public Collection<ClassInfo> getClasses() {
        return accumulator.getClasses();
    }

    /******************************************
     * Connection listener interface section
     *****************************************/

    @Override
    public void onMessageReceived(byte[] data) {

        try {
            Response msg = Response.parseFrom(data);

            switch (msg.getType()) {

                case ModuleList:

                    accumulator.addModuleList(msg.getModuleList());
                    delegate.newInfoAvailable();
                    break;

                case Class:

                    accumulator.addClassInfo(msg.getClassInfo());
                    break;

                case EndOfList:

                    accumulator.resolveDependencyAndMerge();
                    delegate.newInfoAvailable();
                    break;
            }

        } catch (InvalidProtocolBufferException e) {
            System.err.println("[ERROR] Received unsupported message.");
            e.printStackTrace();
        }
    }

    @Override
    public void onClose() {

        try {

            patientProcess.destroyForcibly().waitFor();

        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onError() {
        // TODO: To be implemented
    }

}
