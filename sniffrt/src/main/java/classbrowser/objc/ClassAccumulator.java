package classbrowser.objc;

import classbrowser.MessagingProto.Response;

import java.util.Collection;
import java.util.HashMap;

public class ClassAccumulator {

    private ModuleInfo[] modules = null;
    private int mainModuleId = -1;

    private HashMap<Long, ClassInfo> totalClassList = new HashMap<Long, ClassInfo>();
    private HashMap<Long, ClassInfo> unresolvedClassList = new HashMap<Long, ClassInfo>();
    private HashMap<Long, ClassInfo> newlyArrived = new HashMap<Long, ClassInfo>();

    /**
     * Class info which will be added to accumulator as a new record without
     * solving dependencies and relationships with currently presented classes.
     * Please call {@link #resolveDependencyAndMerge resolveDependencyAndMerge}
     * method after all new classes will be added.
     *
     * @param info Class info which should be added to total class tree
     */
    public void addClassInfo(Response.ClassInfo info) {

        ClassInfo cls = new ClassInfo();

        cls.name = info.getName();
        cls.id = info.getId();
        cls.superId = info.getSuperClassId();
        cls.moduleId = info.getModuleId();

        int count = info.getMethodsCount();
        cls.methods = new MethodInfo[count];

        for (int i = 0; i < count; i++) {
            cls.methods[i] = new MethodInfo();
            cls.methods[i].name = info.getMethods(i).getSelector();
            cls.methods[i].types = info.getMethods(i).getTypeEncoding();
        }

        count = info.getIvarsCount();
        cls.ivars = new IvarInfo[count];

        for (int i = 0; i < count; i++) {
            cls.ivars[i] = new IvarInfo();
            cls.ivars[i].name = info.getIvars(i).getName();
            cls.ivars[i].type = Type.fromEncoded( info.getIvars(i).getTypeEncoding() );
        }

        // TODO: Implement converter of all over info fields...

        newlyArrived.put(cls.id, cls);
    }

    public void addModuleList(Response.ModulesListInfo info) {

        int count = info.getModulesCount();
        mainModuleId = (int)info.getMainModuleId();
        modules = new ModuleInfo[count];

        for (int i = 0; i < count; i++) {
            int id = (int)info.getModules(i).getId();

            modules[id] = new ModuleInfo();
            modules[id].name = info.getModules(i).getName();
            modules[id].classCount = info.getModules(i).getClassesCount();
        }
    }

    /**
     *
     */
    public void resolveDependencyAndMerge() {

        while (!newlyArrived.isEmpty()) {

            ClassInfo clsInfo;
            ClassInfo superClsInfo;

            clsInfo = newlyArrived.values().iterator().next(); // first element

            /** Resolve dependency for cls */
            superClsInfo = newlyArrived.get(clsInfo.superId);
            if (superClsInfo == null) superClsInfo = totalClassList.get(clsInfo.superId);
            if (superClsInfo == null) superClsInfo = unresolvedClassList.get(clsInfo.superId);


            if (superClsInfo == null) {
                /**
                 * Super class was not found. That mean that it's contained in other module
                 * and was not loaded yet.
                 * So just add it list of uncompleted classes.
                 */
                unresolvedClassList.put(clsInfo.id, clsInfo);
            } else {
                clsInfo.parent = superClsInfo;
                totalClassList.put(clsInfo.id, clsInfo);
            }

            newlyArrived.remove(clsInfo.id);
        }
    }

    /******************************************
     * Getters
     *****************************************/

    public Collection<ClassInfo> getClasses() {
        return totalClassList.values();
    }

    public ModuleInfo[] getModules() {
        return modules;
    }

    public long getMainModuleId() {
        return mainModuleId;
    }

}
