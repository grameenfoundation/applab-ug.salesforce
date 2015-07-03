<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Send Acknowledgement Letter</fullName>
        <actions>
            <name>Send Acknowledgement</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Posted</value>
        </criteriaItems>
        <description>used to remind donation owner to send acknowledgement for any donations that are Posted / Closed Won.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Send Acknowledgement</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please send an acknowledgement for this donation</description>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
