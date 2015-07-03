<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Household Latitude</fullName>
        <field>Latitude__c</field>
        <formula>Registration_Submission_Record__r.gfsurveys__gps_y__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update Household Longitude</fullName>
        <field>Longitude__c</field>
        <formula>Registration_Submission_Record__r.gfsurveys__gps_x__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Household Latitude</fullName>
        <actions>
            <name>Update Household Latitude</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Latitude__c),NOT(ISBLANK(Registration_Submission_Record__c)), NOT(ISBLANK( Registration_Submission_Record__r.gfsurveys__gps_y__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Household Longitude</fullName>
        <actions>
            <name>Update Household Longitude</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISBLANK(Longitude__c),NOT(ISBLANK(Registration_Submission_Record__c)), NOT(ISBLANK( Registration_Submission_Record__r.gfsurveys__gps_x__c )))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
