<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update 3%2E0 CKW Net Pay</fullName>
        <description>Calculates and updates the net performance pay of a 3.0 CKW</description>
        <field>Net_Performance_Compensation__c</field>
        <formula>Compensation_in_UGX__c -  No_FO_Visit_Penalty__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Calculate 3%2E0 CKW Net Performance Pay</fullName>
        <actions>
            <name>Update 3%2E0 CKW Net Pay</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>C3P0_CKW_Performance__c.Total_Interactions_by_CKW__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Calculate 3.0 CKW Net Performance Pay</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
