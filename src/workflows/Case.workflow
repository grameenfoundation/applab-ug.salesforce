<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>OnResponseChanged</fullName>
        <active>false</active>
        <formula>ISCHANGED( Response__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
