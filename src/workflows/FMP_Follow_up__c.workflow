<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Total_Targets</fullName>
        <field>totalTargets1__c</field>
        <formula>IF( FMP_Target__r.followadequateTransportation__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followchannelsScamperOk__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followchecklist__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followcoffeeDryingSystemOk__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followcoffeePackaging__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followcontrolAccordingMonitoring__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followevaluationPulping__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followfarmMap__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followFaunaFloraRecoveryPlan__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followfermentationTanksOk__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followfriendlyMethodsReducingHerbicide__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followharvestEvaluation__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followharvestRecord__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followhasProtectionEquipment__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followhoneyWaterTreatmentTank__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followidentifyingErodedAreas__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followimplemetationSeedbedPlan__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followknowledgeAreasLots__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followmakingMonitoringPestsDiseases__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followmonitoringRecordPestDisease__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followpostControlEvaluation__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followproperCoffeeStorage__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followproperSubstratesPreparation__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followpulpCompostingPit__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)</formula>
        <name>Total Targets</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Total_Targets2</fullName>
        <field>totalTargets2__c</field>
        <formula>IF( FMP_Target__r.followpulpingMachineOk__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordHarvesting__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordOfLabor__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordPesticideApplications__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordPurchasingInputs__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordsAgrochemicalsApplications__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordSalesCPS__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecordVarietiesTreesPerLot__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followrecoveryErodedAreas__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followreforestationNativeSpecies__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followregistrationWorkPerLot__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followregulationOfShadow__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followseparationCoffeePerLot__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followseparationCoffeeQuality__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followtanksMucilageRemoverOk__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followtrainsStaffAgrochemicalsHandling__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followuseProtectionEquipment__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followusingControlMethodsForPYE__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followusingNativeSpeciesAsShading__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followwarehouseSafety__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followwastewaterManagement__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followwetmillSafety__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followwetmillWaterManagement__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followzarandaGoodCondition__c= &quot;No se cumplía y se fijaron metas&quot;, 1, 0)+IF( FMP_Target__r.followtransformationPulpsForUse__c = &quot;No se cumplía y se fijaron metas&quot;, 1, 0)</formula>
        <name>Total Targets2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Total_Targets_Complete_3</fullName>
        <field>targetsComplete3__c</field>
        <formula>IF( FMP_Target__r.followwetmillWaterManagement__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES (WetmillWaterManagement__c, &quot;La utiliza como modo de fertilización&quot;) = TRUE, 1, 0)+IF(FMP_Target__r.followzarandaGoodCondition__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(warehouseSafety__c)=&quot;Cumple&quot;, 1, 0)</formula>
        <name>Total Targets Complete 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Total_Targets_complete_1</fullName>
        <field>targetsComplete1__c</field>
        <formula>IF( FMP_Target__r.followadequateTransportation__c = &quot;No se cumplía y se fijaron metas&quot; &amp;&amp; TEXT(adequateTransportation__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followchannelsScamperOk__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(channelsScamperOk__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followchecklist__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(checklist__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followcoffeeDryingSystemOk__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(coffeeDryingSystemOk__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followcoffeePackaging__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(CofeePackaging__c,&quot;Están limpios y aptos para la cosecha&quot;)=TRUE, 1, 0)+IF( FMP_Target__r.followcontrolAccordingMonitoring__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(controlAccordingMonitoring__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followevaluationPulping__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(evaluationPulping__c ) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followfarmMap__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(farmMap__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followFaunaFloraRecoveryPlan__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(FaunaFloraRecoveryPlan__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followfermentationTanksOk__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(fermentationTanksOk__c) = &quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followfriendlyMethodsReducingHerbicide__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(FriendlyMethodsReducingHerbicide__c, &quot;Control físico/mecánico&quot;) = TRUE || INCLUDES( FriendlyMethodsReducingHerbicide__c, &quot;Cultivos de cobertura&quot;) = TRUE || INCLUDES(FriendlyMethodsReducingHerbicide__c, &quot;Mulch (colchón material orgánico)&quot;) = TRUE || INCLUDES( FriendlyMethodsReducingHerbicide__c, &quot;Distancias de siembra&quot;) = TRUE || INCLUDES(FriendlyMethodsReducingHerbicide__c, &quot;Manejo de Sombra&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followharvestEvaluation__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(harvestEvaluation__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followharvestRecord__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(harvestRecord__c, &quot;Con documentación/registros de soporte&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followhasProtectionEquipment__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(hasProtectionEquipment__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followhoneyWaterTreatmentTank__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(honeyWaterTreatmentTank__c, &quot;Las vierte en pozos de infiltración&quot;) = TRUE || INCLUDES( honeyWaterTreatmentTank__c, &quot;Planta de tratamiento de aguas mieles&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followidentifyingErodedAreas__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(identifyingErodedAreas__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followimplemetationSeedbedPlan__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(implemetationSeedbedPlan__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followknowledgeAreasLots__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(knowledgeAreasLots__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followmakingMonitoringPestsDiseases__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(makingMonitoringPestsDiseases__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followmonitoringRecordPestDisease__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(monitoringRecordPestDisease__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followpostControlEvaluation__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(postControlEvaluation__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followproperCoffeeStorage__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(properCoffeeStorage__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followproperSubstratesPreparation__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(properSubstratesPreparation__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followpulpCompostingPit__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(pulpCompostingPit__c, &quot;Procesa en compost en cuanto es posible&quot;)= TRUE, 1, 0)</formula>
        <name>Total Targets complete 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Total_Targets_complete_2</fullName>
        <field>targetsComplete2__c</field>
        <formula>IF( FMP_Target__r.followpulpingMachineOk__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(pulpingMachineOk__c, &quot;Granos enteros y limpios&quot;)=TRUE, 1, 0)+IF( FMP_Target__r.followrecordHarvesting__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(recordHarvesting__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followrecordOfLabor__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(recordOfLabor__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followrecordPesticideApplications__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(recordPesticideApplications__c, &quot;Fecha de aplicación,Dosis,Lote&quot;)=TRUE, 1, 0)+IF( FMP_Target__r.followrecordPurchasingInputs__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(recordPurchasingInputs__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followrecordsAgrochemicalsApplications__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(recordPesticideApplications__c, &quot;Fecha de aplicación,Dosis,Lote&quot;)=TRUE, 1, 0)+IF( FMP_Target__r.followrecordSalesCPS__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(recordSalesCPS__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followrecordVarietiesTreesPerLot__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(recordVarietiesTreesPerLot__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followrecoveryErodedAreas__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(RecoveryErodedAreas__c, &quot;Curvas de nivel&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Terrazas individuales&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Terrazas de banco&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Barreras vivas&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Barreras físicas&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Acequias&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Cultivos de cobertura de suelo&quot;) = TRUE || INCLUDES(RecoveryErodedAreas__c, &quot;Mulch (colchon de materia orgánica)&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followreforestationNativeSpecies__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(reforestationNativeSpecies__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followregistrationWorkPerLot__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(registrationWorkPerLot__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followregulationOfShadow__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; RegulationOfShadow__c &gt; 20, 1, 0)+IF( FMP_Target__r.followseparationCoffeePerLot__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(separationCoffeePerLot__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followseparationCoffeeQuality__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(separationCoffeeQuality__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followtanksMucilageRemoverOk__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(tanksMucilageRemoverOk__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followtrainsStaffAgrochemicalsHandling__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(trainsStaffAgrochemicalsHandling__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followtransformationPulpsForUse__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES(TransformationPulpsForUse__c, &quot;Procesa en compost en cuanto es posible&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followuseProtectionEquipment__c = &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(useProtectionEquipment__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followusingControlMethodsForPYE__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT(usingControlMethodsForPYE__c)=&quot;Cumple&quot;, 1, 0)+IF( FMP_Target__r.followusingNativeSpeciesAsShading__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; UsingNativeSpeciesAsShading__c &gt; 2, 1, 0)+IF( FMP_Target__r.followwarehouseSafety__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; TEXT (warehouseSafety__c)=&quot;Cumple&quot;, 1, 0)+IF(FMP_Target__r.followwastewaterManagement__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES (WastewaterManagement__c, &quot;Las vierte en pozos de infiltración&quot;) = TRUE || INCLUDES(WastewaterManagement__c, &quot;Planta de tratamiento de aguas mieles&quot;) = TRUE, 1, 0)+IF( FMP_Target__r.followwetmillSafety__c= &quot;No se cumplía y se fijaron metas&quot;&amp;&amp; INCLUDES (WetmillSafety__c,&quot;Ningún riesgo&quot;)=TRUE, 1, 0)</formula>
        <name>Total Targets complete 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FMP_FollowUp_Targets</fullName>
        <actions>
            <name>Total_Targets</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Total_Targets2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Total_Targets_Complete_3</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Total_Targets_complete_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Total_Targets_complete_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FMP_Follow_up__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
