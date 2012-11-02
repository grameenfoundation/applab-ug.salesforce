<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetCkwActive</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>SetCkwActive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Activate Ckw</fullName>
        <actions>
            <name>SetCkwActive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the date that the CKW becomes active</description>
        <formula>NOT( ISNULL(Active_Date__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
