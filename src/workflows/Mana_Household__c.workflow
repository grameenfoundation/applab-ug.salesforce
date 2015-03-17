<?xml version="1.0" encoding="UTF-8"?>
<<<<<<< HEAD
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata"/>

=======
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Household_Latitude</fullName>
        <field>Latitude__c</field>
        <formula>Registration_Submission_Record__r.gfsurveys__gps_y__c</formula>
        <name>Update Household Latitude</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Household_Longitude</fullName>
        <field>Longitude__c</field>
        <formula>Registration_Submission_Record__r.gfsurveys__gps_x__c</formula>
        <name>Update Household Longitude</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Household Latitude</fullName>
        <actions>
            <name>Update_Household_Latitude</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Latitude__c),NOT(ISBLANK(Registration_Submission_Record__c)), NOT(ISBLANK( Registration_Submission_Record__r.gfsurveys__gps_y__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Household Longitude</fullName>
        <actions>
            <name>Update_Household_Longitude</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Longitude__c),NOT(ISBLANK(Registration_Submission_Record__c)), NOT(ISBLANK( Registration_Submission_Record__r.gfsurveys__gps_x__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
>>>>>>> origin/ci
