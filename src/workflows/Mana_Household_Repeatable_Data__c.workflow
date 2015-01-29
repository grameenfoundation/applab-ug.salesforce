<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Food_Security_Classification</fullName>
        <field>Food_Security_Classification__c</field>
        <formula>IF(Food_Security_Score__c==0,&quot;Seguro&quot;,
IF(TEXT(FS_Children__c)==&quot;Sí&quot;,
IF(Food_Security_Score__c&lt;7,&quot;Leve&quot;,
IF(Food_Security_Score__c&lt;12,&quot;Moderado&quot;,&quot;Severo&quot;)),
IF(Food_Security_Score__c&lt;5,&quot;Leve&quot;,
IF(Food_Security_Score__c&lt;8,&quot;Moderado&quot;,&quot;Severo&quot;))))</formula>
        <name>Update Food Security Classification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Food Security Classification</fullName>
        <actions>
            <name>Update_Food_Security_Classification</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
