<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Cow_Peas_Sale_Farmer_FCI_ID_Created</fullName>
        <field>Farmer_FCI_ID__c</field>
        <formula>Ewarehouse_Sale__r.FCI_ID_Prefix__c + Commercial_Purchase_Group_ID__c+&apos;/&apos;+Last_3_Digits_of_Farmer_ID__c</formula>
        <name>Cow Peas Sale Farmer FCI ID Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Cow Peas Sale Farrmer FCI ID Created</fullName>
        <actions>
            <name>Cow_Peas_Sale_Farmer_FCI_ID_Created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Sale_Record__c.FCI_ID_Prefix__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This is when the FCI ID to farmer is created under a new sale that involves Cow Peas sale</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>