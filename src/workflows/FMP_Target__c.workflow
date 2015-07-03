<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FMP Total Cost</fullName>
        <field>FMP_Total_Cost__c</field>
        <formula>Seedbed_Cost__c + Renewal_Coffee_Planting_Cost__c + Expansion_Crop_Cost__c + Recepa_Block_Cost__c + Selective_Pruning_Cost__c + Desuchering_Cost__c + Management_Herbs_Cost__c + Shadow_Management_Cost__c+ Soil_Analysis_Cost__c + Soil_Amendment_Cost__c + Broca_Traps_Cost__c +  Conservation_Practices_Terrazas_Cost__c + Conservation_Practices_Cajuelas_Cost__c + Conservation_Practices_Barreras_Cost__c + Conservation_Practices_Acequias_Cost__c +  Buffer_Zones_Acequias_Cost__c + Buffer_Zones_Barrera_Viva_Cost__c + Soil_Fertilization_Composta_Cost__c + Soil_Fertilization_Bocashi_Cost__c + Soil_Fertilization_Lombricomposta_Cost__c + Soil_Fert_Gallinaza_certificada_Cost__c + Soil_Fertilization_KMag_Cost__c + Soil_Fertilization_KS_Cost__c + Soil_Fertilization_NPKMgB_Cost__c + Soil_Fertilization_NPK_Cost__c + Soil_Fertilization_NP_Cost__c + Soil_Fertilization_NK_Cost__c + Soil_Fertilization_KCl_Cost__c + Soil_Fertilization_NS_Cost__c + Soil_Fertilization_Urea_N_Cost__c + Soil_Fert_Nitrato_amonio_N_Cost__c + Foliar_Fert_Sulfato_potasio_Cost__c + Foliar_Fert_Sulfato_cobre_Cost__c + Foliar_Fert_Sulfato_Zinc_Cost__c + Foliar_Fert_Sulfato_magnesio_Cost__c + Foliar_Fert_Sulfato_hierro_Cost__c + Foliar_Fert_Sulfato_manganeso_Cost__c + Foliar_Fert_Borax_Cost__c + Foliar_Fert_Bayfolan_forte_Cost__c + Foliar_Fert_Multicafe_Cost__c + Foliar_Fert_Ferticafe_Cost__c + Micro_FoliarLixiviadoLombricomposta_Cost__c + Micro_Foliar_preparados_localmente_Cost__c + Micro_Foliar_EM_comercial_Cost__c + MIPE_Caldo_bordeles_Cost__c + MIPE_Caldo_Sulfocalcico_Cost__c + MIPE_Timorex_Gold_Cost__c + MIPE_Alto_10_S_Cost__c + MIPE_Duet_Cost__c + MIPE_Opus_Cost__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FMP Total Cost</fullName>
        <actions>
            <name>FMP Total Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FMP_Target__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
