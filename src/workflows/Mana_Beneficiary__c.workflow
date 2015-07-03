<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Turn Off Do Not Call</fullName>
        <description>This uses the &quot;Permitir SMS&quot; field of the Mana Beneficiary to set the DoNotCall field of the Contact</description>
        <field>DoNotCall</field>
        <literalValue>0</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Turn on Do Not Call</fullName>
        <description>This uses the &quot;Permitir SMS&quot; field of the Mana Beneficiary to set the DoNotCall field of the Contact</description>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Turn Off Beneficiary Contact Do Not Call</fullName>
        <actions>
            <name>Turn Off Do Not Call</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This uses the &quot;Permitir SMS&quot; field of the Mana Beneficiary to set the DoNotCall field of the Contact</description>
        <formula>AND( ISCHANGED( Permitir_SMS_Household__c ), Permitir_SMS_Household__c = &apos;Sí&apos;,  Contact__r.DoNotCall = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Turn On Beneficiary Contact Do Not Call</fullName>
        <actions>
            <name>Turn on Do Not Call</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This uses the &quot;Permitir SMS&quot; field of the Mana Beneficiary to set the DoNotCall field of the Contact</description>
        <formula>AND( ISCHANGED( Permitir_SMS_Household__c ), Permitir_SMS_Household__c = &apos;No&apos;,  Contact__r.DoNotCall = FALSE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
