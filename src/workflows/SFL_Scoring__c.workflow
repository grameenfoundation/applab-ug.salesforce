<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>servicesUseInputsCreditTrainingArea</fullName>
        <field>services_UseInputsCreditTrainingArea__c</field>
        <formula>LAC_SFL_Scores_Farm__r.Organic_fertilized_area_Ha__c / LAC_SFL_Scores_Farm__r.Coffee_planted_area_Ha__c</formula>
        <name>servicesUseInputsCreditTrainingArea</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wellbeingCropRevenueScore</fullName>
        <field>wellbeing_CropRevenueNetCropIncomeScore__c</field>
        <formula>LAC_SFL_Scores_Farmer__r.productivity__c * CASE(YEAR(TODAY()), 2013, 3.728, 2014, 5.636, 5.636) * (1 + (1 - LAC_SFL_Scores_Farmer__r.socioe_percentageOfIncomeCoffee__c)) / LAC_SFL_Scores_Farmer__r.socioe_personsInHousehold__c

/*
NOTES:
there are two fields that must contain the members belong to household
LAC_Farmer_Details__c.Family_Members__c &amp;  
CBL2_Farmer__c.socioe_personsInHousehold__c (There are more values in this field)

Coffee value is getting from www.federaciondecafeteros.org (125 kgs/COP)
*/</formula>
        <name>wellbeingCropRevenueScore</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LAC_SFL_Scoring</fullName>
        <actions>
            <name>servicesUseInputsCreditTrainingArea</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>wellbeingCropRevenueScore</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CBL2_Farmer__c.socioe_personsInHousehold__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Calculate fields to use in SFL Scoring</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
