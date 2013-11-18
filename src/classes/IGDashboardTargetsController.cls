/**
 *
 * Copyright (c) 2013 AppLab, Grameen Foundation
 *
 *  This is the controller class for IG/NUSAF Dashboard pop-up page that updates targets
 *  Its test methods are in the IGDashboardTests class 
 **/
public class IGDashboardTargetsController {
    private Boolean saved = false;
    private Community_Based_Trainer_Target__c target; 
    private Person__c trainer;
    private List<SelectOption> activities;
    private List<SelectOption> communityBasedTrainers;
    
    public IGDashboardTargetsController(){
        setUp();
    }
    
    public void setUp(){
        target = new Community_Based_Trainer_Target__c();
        trainer = new Person__c();
    }
    
    /*
    * Fetches all Person__c objects of type IG/NUSAF - these are the Field Staff 
    * and avails then to the dropdown list on the page as list-options
    */
    public List<SelectOption> getCommunityBasedTrainers(){
        List<SelectOption> options = new List<SelectOption>();
        Person__c[] trainers = database.query(IGDashboardHelpers.getCommunityBasedTrainers());
        options.add(new SelectOption('','-- SET FOR ALL Community Based Trainers --'));
        for (Person__c trainer1 : trainers) {
           options.add(new SelectOption(string.valueOf(trainer1.Id), trainer1.First_Name__c + ' ' + trainer1.Last_Name__c));
        } 
        return options;
    }
    
    /*
    * Fetches surveys for IG/NUSAF monitoring that are supposed to feed into this dashboard 
    * The surveys are known by the post-processing method and are generally referred to as
    * activities. (Each activity is a survey)
    */
    public List<SelectOption> getActivities(){
        List<SelectOption> options = new List<SelectOption>();
        Survey__c[] surveys = database.query(IGDashboardHelpers.getActivities());
        options.add(new SelectOption('','-- Select Activity --'));
        for (Survey__c survey : surveys) {
           options.add(new SelectOption(string.valueOf(survey.Id), survey.Survey_Name__c));
        } 
        return options;
    }
    
    /*
    * gets the target object for binding to UI controller
    * also a setter method for use in testing
    */
    public Community_Based_Trainer_Target__c getTarget(){
        return this.target;
    }
    public void setTarget(Community_Based_Trainer_Target__c target){
        this.target = target;
    }
    
    /*
    * gets the trainer person object for binding to UI controller
    * also a setter method for use in testing
    */
    public Person__c getTrainer(){
    return this.trainer;
    }
    public void setTrainer(Person__c trainer){
        this.trainer = trainer;
    }

    public Boolean getSaved() {
        return this.saved;
    }
    public void setSaved(Boolean saved) {
        this.saved = saved;
    }
    
    public void save() {
        if(target.Survey__c != null && target.Target_Value__c > 0.0){
            Community_Based_Trainer_Target__c[] currentTargets = database.query(IGDashboardHelpers.getCurrentTargets(target.Survey__c));
            //no existing targets
            if(currentTargets.isEmpty()){
                //for all CBTs
                if(trainer.Id == null){
                    IGDashboardHelpers.setNewTargetsForAll(target.Survey__c, target.Target_Value__c);
                    this.saved = true;
                }
                else{
                    //for one CBT
                    IGDashboardHelpers.setNewTargetForCBT(target.Survey__c, target.Target_Value__c, trainer.Id);
                    this.saved = true;
                }
            }
            else{
                //there are existing targets
                //for all CBTs
                if(trainer.Id == null){
                    Person__c[] trainers = database.query(IGDashboardHelpers.getCommunityBasedTrainers());
                    for(Person__c trainer2 : trainers){
                        Community_Based_Trainer_Target__c foundTarget = IGDashboardHelpers.getTarget(trainer2.Id, currentTargets);
                        if(foundTarget == null){
                            //not found, create new 
                            IGDashboardHelpers.setNewTargetForCBT(target.Survey__c, target.Target_Value__c, trainer2.Id);
                        }
                        else{
                            //IGDashboardHelpers.updateTargetForCBT(target.Survey__c, target.Target_Value__c, trainer2.Id);
                            foundTarget.Target_Value__c = target.Target_Value__c;
                            update foundTarget;
                        }
                    }
                    this.saved = true;
                }
                else{
                    //for one CBT
                    Community_Based_Trainer_Target__c updateTarget = currentTargets[0];
                    updateTarget.Target_Value__c = target.Target_Value__c;
                    update updateTarget;
                    this.saved = true;
                }
            }
        }
    }
}