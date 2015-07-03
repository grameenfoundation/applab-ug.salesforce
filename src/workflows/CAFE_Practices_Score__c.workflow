<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Coffee Growing score calculation</fullName>
        <field>Coffee_Growing__c</field>
        <formula>Coffee_Growing_Practices_Met__c / 31</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Coffee Growing score</fullName>
        <actions>
            <name>Coffee Growing score calculation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAFE_Practices_Score__c.Coffee_Growing_Practices_Met__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
