package classbrowser.test.func;

import classbrowser.ObjcClassObserver;

import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

import classbrowser.ObjcClassObserverDelegate;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

public class ObjcClassObserverTest implements ObjcClassObserverDelegate {

    Semaphore smp;

    @Before
    public void preparation() {
        smp = new Semaphore(0);
    }

    @Override
    public void newInfoAvailable() {
        smp.release();
    }

    @Test
    public void receiveModuleList() throws Exception{

        ObjcClassObserver observer = new ObjcClassObserver(this);

        observer.setExecutable("build/xcode/Release/test_app");
        observer.startSniffing();
        observer.askModuleList();

        assertTrue("Time is out. No message from serve.", smp.tryAcquire(100, TimeUnit.MILLISECONDS));
        assertNotEquals(observer.getModules().length, 0);

        observer.stopSniffing(true);
    }


    @Test
    public void receiveMainModuleClasses() throws Exception{

        ObjcClassObserver observer = new ObjcClassObserver(this);

        try {
            observer.setExecutable("build/xcode/Release/test_app");
            observer.startSniffing();

            observer.askModuleList();
            assertTrue("Time is out. No message from serve.", smp.tryAcquire(1, 100000, TimeUnit.MILLISECONDS));

            observer.askMainModuleClasses();
            assertTrue("Time is out. No message from serve.", smp.tryAcquire(1, 10000, TimeUnit.MILLISECONDS));

            assertNotEquals(observer.getClasses().size(), 2);

        } finally {
            observer.stopSniffing(true);
        }
    }

}
