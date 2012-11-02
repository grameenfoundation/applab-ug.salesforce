<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Membership</fullName>
        <field>Need_Update__c</field>
        <literalValue>1</literalValue>
        <name>Update Membership</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set NeedsUpdate</fullName>
        <actions>
            <name>Update_Membership</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Membership_Query__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
