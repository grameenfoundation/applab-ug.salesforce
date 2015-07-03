<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Pegion Peas Sale Farmer FCI ID Created</fullName>
        <field>Farmer_FCI_ID__c</field>
        <formula>Ewarehouse_Sale__r.FCI_ID_Prefix__c + Commercial_Purchase_Group_ID__c+&apos;/&apos;+ Last_3_Digits_of_Farmer_ID__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Pegion Peas Sale Farmer FCI ID Created</fullName>
        <actions>
            <name>Pegion Peas Sale Farmer FCI ID Created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sale_Record__c.FCI_ID_Prefix__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This is when the FCI ID to farmer is created under a new sale that involves Pegion Peas sale</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
