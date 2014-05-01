<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Update Ewarehouse Farmer Object</fullName>
        <active>false</active>
        <formula>DATEVALUE( CreatedDate ) &gt; DATE(YEAR(TODAY())-1, MONTH(TODAY()), DAY(TODAY()))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
