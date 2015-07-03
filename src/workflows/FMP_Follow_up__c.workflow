<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Total Score</fullName>
        <field>followUp_Total_Score__c</field>
        <formula>followUpfmp_Agrochemicals_Score__c  +  followUpfmp_Environment_Score__c  +  followUpfmp_Harvest_Score__c  +  followUpfmp_Lot_Score__c  +  followUpfmp_MIPE_Score__c  +  followUpfmp_Record_score__c  +  followUpfmp_Seedbed_Score__c  +  followUpfmp_Shadow_Score__c  +  followUpfmp_Soil_Score__c  +  followUpfmp_Wedmill_Score__c  +  followUpfmp_Weeds_Score__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FMP_Followup_Score</fullName>
        <actions>
            <name>Total Score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FMP_Follow_up__c.followUpfmp_Agrochemicals_Score__c</field>
            <operation>greaterOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
