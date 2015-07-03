<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateLB</fullName>
        <field>LB__c</field>
        <formula>IF( Stage__c = &apos;LB&apos;, 1, 0)</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateXP</fullName>
        <field>XP__c</field>
        <formula>IF( Stage__c = &apos;XP&apos;, 1, 0)</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Define_LB_XP</fullName>
        <actions>
            <name>UpdateLB</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateXP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Mana_Food_Consumption_Record__c.Stage__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Define if the record is LB or XP (Ex-post)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
