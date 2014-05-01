<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Backyard_Garden_Stage</fullName>
        <description>Update the household object with the backyard garden stage value from the production record.</description>
        <field>Fase_de_la_huerta__c</field>
        <formula>TEXT(Backyard_Garden_Stage__c)</formula>
        <name>Update Backyard Garden Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Household__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Household Backyard Garden Stage</fullName>
        <actions>
            <name>Update_Backyard_Garden_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Mana_Household_Production_Record__c.Backyard_Garden_Stage__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This rule sets the &quot;Fase de la huerta&quot; field on the master household with info from the &quot;Backyard Garden Stage&quot; field when a new Household Production Record is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
