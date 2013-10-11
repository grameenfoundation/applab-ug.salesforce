/**
 *  Virtual class that sets up the basic methods to be used by all components that have a group of child components in them
 */

public with sharing virtual class ParentComponentBase {

    // A map that contains all the child components that are part of the section that this parent controlls
    private Map<String, ChildComponentBase> childMap;
    public virtual Map<String, ChildComponentBase> getChildMap() {
        return childMap;
    }
    public virtual void setChildMap(String key, ChildComponentBase base) {
        if (this.childMap == null) {
            this.childMap = new Map<String, ChildComponentBase>();
        }
        this.childMap.put(key, base);
    }

    // Allows this controller to talk to parent maps
    private Map<String, ParentComponentBase> parentMap;
    public virtual Map<String, ParentComponentBase> getParentMap() {
        return parentMap;
    }
    public virtual void setParentMap(String key, ParentComponentBase base) {
        if (this.parentMap == null) {
            this.parentMap = new Map<String, ParentComponentBase>();
        }
        this.parentMap.put(key, base);
    }

    // Return the controller so it can be assigned to a child
    public ParentComponentBase getThis() {
        return this;
    }

    // The key for the section that this parent belongs to
    private String sectionKey;
    public String getSectionKey() {
        return this.sectionKey;
    }
    public void setSectionKey(String value) {
        this.sectionKey = value;
    }

    private String key;
    public String getKey() {
        return this.key;
    }
    public void setKey(String key) {
        this.key = key;
        if (this.parentComponentController != null && key != null) {
            this.parentComponentController.setParentMap(key, this);
        }
    }

    // Parent controller if needed. Allows for multi layered components
    private ParentComponentBase parentComponentController;
    public ParentComponentBase getParentComponentController() {
        return this.parentComponentController;
    }
    public void setParentComponentController (ParentComponentBase controller) {
        this.parentComponentController = controller;
        if (this.key != null && controller != null) {
            this.parentComponentController.setParentMap(this.key, this);
        }
    }

    // The parameters that are taken from all the child components
    private Map<String, String> parameters;
    public Map<String, String> getParameters() {
        return this.parameters;
    }
    public void setParameters(Map<String, String> params) {
        this.parameters = params;
    }
    public String getParameter(String key) {

        if (getParameters() == null) {
            rebuildParameters();
        }

        // May still not have a param map after rebuilding, if this is called from a constructor
        // and rebuildParameters() is overrode
        if (getParameters() == null) {
            return '';
        }
        String value = this.getParameters().get(key);
        if (value == null) {
            return '';
        }
        return value;
    }
    public void addParameter(String key, String value) {
        if (this.parameters == null) {
            rebuildParameters();
        }
        this.parameters.put(key, value);
    }

    public Boolean hasKey(String key) {
        if (this.parameters == null) {
            return false;
        }
        return this.parameters.containsKey(key);
    }

    /**
     *  Loop through all the child components and add their values to the parameter map
     */
    public virtual void rebuildParameters() {

        if (this.parameters == null) {
            this.parameters = new Map<String, String>();
        }
        if (this.childMap == null) {
            return;
        }
        for (String key : getChildMap().keySet()) {

            this.parameters.put(key, this.childMap.get(key).getValues());
        }
    }

    // Debugging method to return the location of an action.
    public virtual String getHandle() {
        return 'DEFAULT IMPLEMENTATION';
    }

    static testMethod void testAll() {

        ParentComponentBase base = new ParentComponentBase();
        base.setParentMap('kill', base.getThis());
        ChildComponentBase child = new ChildComponentBase();
        base.setChildMap('Them', child);
        base.setParentComponentController(base.getThis());
        base.getHandle();
        base.addParameter('all', 'Thrash');
        base.getParameter('all');
    }
}