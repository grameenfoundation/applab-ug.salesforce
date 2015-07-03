<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateDate</fullName>
        <field>retiredDate__c</field>
        <formula>TODAY()</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateRetiredDate</fullName>
        <actions>
            <name>UpdateDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EMP_Organization_Member__c.reasonToRetire__c</field>
            <operation>notEqual</operation>
            <value>Activo</value>
        </criteriaItems>
        <description>Update the date related to reasonToRetire field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
