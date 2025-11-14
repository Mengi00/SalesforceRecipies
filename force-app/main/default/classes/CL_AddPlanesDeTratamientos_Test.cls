/**********************************************************************************************************************************************************************************
 * Nombre de la Clase Apex : CL_AddPlanesDeTratamientos_test
 * Versión                 : 1.0
 * Fecha de Creación       : 07/01/2025
 * Funcionalidad           : Realiza los test de las clases involucradas en la migración de casos falp_migracionCase_sch, falp_migracionCase_bch, falp_migracionCase_CTRL
 * Clase de Prueba         : 
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Isaías Osorio       07/01/2025       Versión inicial
 * 
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 **********************************************************************************************************************************************************************************/
@isTest
public with sharing class CL_AddPlanesDeTratamientos_Test {
    @isTest
    private static void testmigracionSch(){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        insert newPersonAccount;

        
        CodeSet cs = new CodeSet(Code = '12345', Name='FIEBRE PARATIFOIDEA B');
        insert cs;
        CodeSetBundle csb = new CodeSetBundle();
        csb.Name = 'FIEBRE PARATIFOIDEA B';
        csb.CodeSet1Id = cs.Id;
        insert  csb;
        List<CL_AddPlanesDeTratamientos.E_Parameters> params = new List<CL_AddPlanesDeTratamientos.E_Parameters>();
        CL_AddPlanesDeTratamientos.E_Parameters param = new CL_AddPlanesDeTratamientos.E_Parameters();

        
        param.UPDATE_SOLO_PT = false;
        //SALESFORCE_ENCUENTR_CLINICO_ID
        //SALESFORCE_PLAN_TRATAMIENTO_ID
        //SALESFORCE_CASO_ID
        //SALESFORCE_PROCEDIMI_MEDICO_ID      
        param.EC_SUCURSAL = 'Infante';
		param.EC_CATEGORIA = 'Encounter';
        param.EC_ESTADO = 'Finished';
        param.PT_ANESTESISTA = true;
        param.PT_APROBACION_INTERNA = false;
        param.PT_COMANDO = false;      
        param.PT_CPLAN_ID = 196992;
        param.PT_CPQD_ID = 20000;      
        param.PT_ESTADO_PLAN_DE_TRATAMIENTO = 'No presupuestado Vig : S';
        param.PT_FECHA_REGISTRO_REMI = DateTime.newInstance(2025, 1, 27, 14, 50, 13);     
        param.PT_GERIATRIA = false;
        param.PT_GSE = 'S';       
        param.PT_LATERALIDAD = 'ISTMO';
        param.PT_MEDICO_TRATANTE = 'ALBERTO SARFATIS FEIGE';       
        param.PT_NUMERO_PLAN_DE_TRATAMIENTO = '10127632';
        param.PT_PACIENTE_ID = newPersonAccount.Id;
        param.PT_PACIENTE_APRUEBA_PRESUPUEST = false;
        param.PT_PAQUETIZADO = false;
        param.PT_PLAN_CONVENIO_ONCOLOGICO = 'No';
        param.PT_PLAZO_DE_INGRESO = null;       
        param.PT_PRIORIDAD = 'Low';
        param.PT_PROCEDIMIENTO_PRINCIPAL = 'Cistoscopia y/o uretrocistoscopia y/o uretroscopia (proc.aut.)';        
        param.PT_RIESGO_CLINICO = null;
        param.PT_TIPO_PLAN = 'CLINICO';
        param.PT_TECNICA = 'Convencional';
        param.PT_TIPO = 'Plan';      
        param.PT_PLAN_PREVISIONAL = 'CONSALUD LE';
        param.PT_PLAN_TRATAMIENTO_CREADO_EL = DateTime.newInstance(2025, 1, 27, 14, 50, 13);
        param.PT_INSTRUCCIONES_DE_PACIENTE = 'BIOPSIA RENAL IZQUIERDA BAJO TC';
        param.PT_ESPECIALIDAD_CLINICA = 'ONCOLOGIA MEDICA';
        param.PT_TIPO_DE_INGRESO = 'PROGRAMADO';
        param.PT_PROCEDIMIENTOS =cs.Code+';';
        //PT_PATOLOGIA
        //PT_NUMERO_DE_CICLOS
        //PT_ESQUEMA
        param.PT_CATETER = false;
        param.PT_CPLAN_EXPIRA_PLAN = DateTime.newInstance(2025, 1, 27, 14, 50, 13);
        //PT_CPLAN_CANDIDATO_A_PAGO
        //PT_CPLAN_FECHA_ANULAR
        //PT_NUMERO_DE_SESIONES
        //PT_VIGENCIA        
        param.PM_ESTADO = 'On Hold';
        param.PM_MOTIVO_DE_ESTADO_ID = cs.Code;
        param.PM_CODIGO = cs.Code;
        
        
        params.add(param);

        
        Test.startTest();
        CL_AddPlanesDeTratamientos.addPlanesDeTratamientos(params);
        Assert.areEqual(param.PT_PRIORIDAD, 'Low');
        Test.stopTest();
    }
}