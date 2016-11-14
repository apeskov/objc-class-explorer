package classbrowser.test.func;

import classbrowser.ObjcClassObserver;

import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

import classbrowser.ObjcClassObserverDelegate;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

public class ObjcClassObserverTest implements ObjcClassObserverDelegate {

    Semaphore smp;

    ObjcClassObserver observer;

    @Before
    public void setUp() {
        smp = new Semaphore(0);

        observer = new ObjcClassObserver(this);
        observer.setExecutable("build/xcode/Release/test_app");
    }

    @After
    public void tearDown() {
        observer.stopSniffing(true);
    }


    @Override
    public void newInfoAvailable() {
        smp.release();
    }

    /*****************************
     * Tests
     *****************************/

    @Test
    public void receiveModuleList() throws Exception{

        observer.startSniffing();
        observer.askModuleList();

        assertTrue("Time is out. No message from serve.", smp.tryAcquire(1000000, TimeUnit.MILLISECONDS));
        assertNotEquals(observer.getModules().length, 0);
    }


    @Test
    public void receiveMainModuleClasses() throws Exception{

        observer.setExecutable("build/xcode/Release/test_app");
        observer.startSniffing();

        observer.askModuleList();
        assertTrue("Time is out. No message from serve.", smp.tryAcquire(1, 100, TimeUnit.MILLISECONDS));

        observer.askMainModuleClasses();
        assertTrue("Time is out. No message from serve.", smp.tryAcquire(1, 100, TimeUnit.MILLISECONDS));

        assertNotEquals(observer.getClasses().size(), 2);
    }
}
