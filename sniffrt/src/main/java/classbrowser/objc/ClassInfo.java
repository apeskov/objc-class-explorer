package classbrowser.objc;

public class ClassInfo {

    static long INVALID_ID = 0;

    long id;
    long superId;
    long moduleId;

    ClassInfo parent;

    String name;

    MethodInfo[] methods;
    IvarInfo[] ivars;
}

