<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FMP_Diagnostic_Score</fullName>
        <field>fmp_Total_Score__c</field>
        <formula>fmp_Agrochemicals_Score__c  +  fmp_Environment_Score__c  +  fmp_Harvest_Score__c  +  fmp_Lot_Score__c  +  fmp_MIPE_Score__c  +  fmp_Record_score__c  +  fmp_Seedbed_Score__c  +  fmp_Shadow_Score__c  +  fmp_Soil_Score__c  +  fmp_Weeds_Score__c  +  fmp_Wetmill_Score__c</formula>
        <name>FMP_Diagnostic_Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FMP_Diagnostic_Score</fullName>
        <actions>
            <name>FMP_Diagnostic_Score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FMP_Diagnostic__c.fmp_Agrochemicals_Score__c</field>
            <operation>greaterOrEqual</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
