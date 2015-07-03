<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SFL_score</fullName>
        <field>SFL_Score__c</field>
        <formula>Environment_score__c + Gender_Score__c + Productivity_score__c + Services_score__c + Trade_score__c + Wellbeing_score__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wellbeing_score</fullName>
        <description>Sums up all the wellbeing metrics whenever any of these changes for a value higher than 0</description>
        <field>Wellbeing_score__c</field>
        <formula>Wellbeing_Assets__c  + wellbeing_CropRevenueNetCropIncome__c + Wellbeing_EstimatedRevenuePercent__c + wellbeing_FSAssessmentSurvey__c + wellbeing_Perception__c + wellbeing_PPI_FinalScore__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>servicesUseInputsCreditTrainingArea</fullName>
        <field>services_UseInputsCreditTrainingArea__c</field>
        <formula>LAC_SFL_Scores_Farm__r.Organic_fertilized_area_Ha__c / LAC_SFL_Scores_Farm__r.Coffee_planted_area_Ha__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wellbeingCropRevenueScore</fullName>
        <field>wellbeing_CropRevenueNetCropIncomeScore__c</field>
        <formula>(LAC_SFL_Scores_Farmer__r.productivity__c * CASE(YEAR(TODAY()), 2013, 3728.97, 2014, 5636.32, 2015, 5636.32, 5636.32) * 20/100 * (1 + (1 - LAC_SFL_Scores_Farmer__r.socioe_percentageOfIncomeCoffee__c))) / LAC_SFL_Scores_Farmer__r.socioe_personsInHousehold__c

/*
NOTES:
there are two fields that must contain the members belong to household
LAC_Farmer_Details__c.Family_Members__c &amp;  
CBL2_Farmer__c.socioe_personsInHousehold__c (There are more values in this field)

Coffee value is getting from www.federaciondecafeteros.org (125 kgs/COP)
- 2013: 466.121,00 125 Kgs/COP
- 2014: 704.540,00 125 Kgs/COP

For &quot;Profit Margin&quot; we are going to use a static value (until we get that information from cooperative or farmer), the value is 20%
*/</formula>
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
    <rules>
        <fullName>SFL_score</fullName>
        <actions>
            <name>SFL_score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6</booleanFilter>
        <criteriaItems>
            <field>SFL_Scoring__c.Environment_score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Gender_Score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Productivity_score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Services_score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Trade_score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Wellbeing_score__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Calculates SFL score</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFL_wellbeing_score</fullName>
        <actions>
            <name>Wellbeing_score</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6</booleanFilter>
        <criteriaItems>
            <field>SFL_Scoring__c.Wellbeing_Assets__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.wellbeing_CropRevenueNetCropIncome__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.Wellbeing_EstimatedRevenuePercent__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.wellbeing_FSAssessmentSurvey__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.wellbeing_Perception__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>SFL_Scoring__c.wellbeing_PPI_FinalScore__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
