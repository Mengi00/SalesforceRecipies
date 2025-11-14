/**********************************************************************************************************************************************************************************
 * Nombre de la Clase Apex : falp_migracionCase_bch
 * Versión                 : 1.0
 * Fecha de Creación       : 07/01/2025
 * Funcionalidad           : Toma los casos de la migración de la plataforma y gerera la estructura que le corresponde
 * Clase de Prueba         : falp_migracionCase_test
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Isaías Osorio       07/01/2025       Versión inicial
 * 
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 **********************************************************************************************************************************************************************************/

public with sharing class falp_migracionCase_bch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Iterable<Case> start(Database.BatchableContext BC){
        List<Case> listCase = [SELECT Id, AccountId, cc_pp_proc_prin__c, Sucursal__c, cc_pp_convenio__c, cc_pp_medicotratante__c, cc_pp_EPlan_sici__c,
        cc_pp_NPlandeTratamiento__c, cc_pp_Comando__c, cc_pp_FechaCPT__c, cc_pp_geriatria__c, cc_pp_Anestesista__c, cc_pp_STdT__c,
        cc_pp_CyIndicaciones__c, cc_pp_Especialidad_Clinica__c, cc_pp_ConvenioO__c, cc_pp_Riesgo_Clinico__c,
        Fecha_sugerida_de_cirug_a__c, Tipo_de_ingreso__c, cc_pp_EmisorPresupuesto__c, cc_pp_TdP__c,cc_pp_FRegistro_Remi__c,
        cc_pp_FdCP__c, cc_pp_NPresupuesto__c, cc_pp_honorarios__c, cc_pp_Valor_Presupuesto__c, F_cierre_Caso__c, cc_pp_nfolio__c,
        cc_pp_Inicio_Pabellon__c, cc_pp_termino_Pabellon__c, cc_pp_Fecha_Pabellon__c, cc_pp_ficha__c, Seguro_complementario__c,
        Abono__c, Monto_abono__c, Print_cta_bancaria_respaldo__c, Monto_motor__c, Cuotas_motor__c, Deudas_FALP__c, GSE__c, Nombre_2__c,
        Nombre_1__c, Parentesco_2__c, Parentesco_1__c, Renta_estimada_2__c, Profesi_n_o_lugar_de_trabajo_2__c,
        Renta_estimada_1__c, Profesi_n_o_lugar_de_trabajo_1__c, cc_pp_Estado_Ppto_sici__c, cc_pp_Fecha_de_Vigencia__c,
        cc_pp_AI__c, cc_pp_paquetizado__c, Priority, cc_pp_Patologia__c, cc_pp_NoCiclos__c, cc_pp_esquema__c, cc_pp_Cateter__c, cc_ap_Descripci_n__c,
        SuppliedCompany, cc_ap_numerodegestion__c,cc_pp_institucion__c
        FROM Case 
        WHERE RecordType.DeveloperName =: 'ServiceRequest' AND FALP_Temp_por_Procesar__c =: true AND falp_Temp_Caso_Migrado__c =false AND ContactId != null];
        return listCase;
    }
    public void execute(Database.BatchableContext bc, List<Case> listCase){
        // process each batch of records
        falp_migracionCase_CTRL.migrarCasos(listCase);
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}