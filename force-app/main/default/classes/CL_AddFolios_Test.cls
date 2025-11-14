@isTest
public with sharing class CL_AddFolios_Test {
    @isTest
	private static void testmigracionSch(){
        List<CL_AddFolios.E_Parameters> params = new List<CL_AddFolios.E_Parameters>();
        CL_AddFolios.E_Parameters param = new CL_AddFolios.E_Parameters(); 
        
        Id PresTipo =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FALP_Presupuesto').getRecordTypeId();
        
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        insert newPersonAccount;        
        
		ClinicalServiceRequest PT = new ClinicalServiceRequest();        
        PT.cc_pp_Anestesista__c = true;
        PT.cc_pp_AI__c = false;
        PT.cc_pp_Comando__c = false;
        PT.CC_PP_CPLAN_ID_SICI__C = 196992;
        PT.CC_PP_EPLAN_SICI__c = 'No presupuestado Vig : S';
        PT.CC_PP_FREGISTRO_REMI__c = DateTime.newInstance(2025, 1, 27, 14, 50, 13).date();
        PT.CC_PP_GERIATRIA__c = false;
        PT.CC_PP_GSE__c = 'S';
        PT.CC_PP_LATERALIDAD__c = 'ISTMO';
        PT.CC_PP_MEDICOTRATANTE__c = 'ALBERTO SARFATIS FEIGE';
        PT.CC_PP_NPLANDETRATAMIENTO__c = '10127632';        
        PT.PatientId = newPersonAccount.Id;        
        PT.cc_pp_pap__c = false;
        PT.CC_PP_PAQUETIZADO__c = false;
        PT.cc_pp_ConvenioO__c = 'No';
        PT.CC_PP_TIPODEINGRESO__c = null;
        PT.Priority = 'Low';
        PT.CC_PP_PROC_PRIN__c = 'Cistoscopia y/o uretrocistoscopia y/o uretroscopia (proc.aut.)';
        PT.CC_PP_RIESGO_CLINICO__c = null;
        PT.CC_PP_TIPO_PLAN__c = 'CLINICO';
        PT.CC_PP_TECNICA__c = 'Convencional';
        PT.Type = 'Plan';
        PT.cc_pp_convenio__c = 'CONSALUD LE';
        PT.CC_PP_FECHACPT__c = DateTime.newInstance(2025, 1, 27, 14, 50, 13).date();
        PT.cc_pp_CyIndicaciones__c = 'BIOPSIA RENAL IZQUIERDA BAJO TC';
        PT.cc_pp_Especialidad_Clinica__c = 'ONCOLOGIA MEDICA';
        PT.Tipo_de_ingreso__c = 'PROGRAMADO';        
        PT.cc_pp_Cateter__c = false;
        //PT.PT_CPLAN_EXPIRA_PLAN = DateTime.newInstance(2025, 1, 27, 14, 50, 13);     
        insert PT;      
        
        
        List<ClinicalServiceRequest> ltsPlanTto = [SELECT Id, FALP_CaseId__c FROM ClinicalServiceRequest WHERE Id = :PT.id];
        
        
        Opportunity O = new Opportunity();  
      	O.AccountId 					= newPersonAccount.id;
      	O.Amount 						= 1276316;       
      	O.CaseId__c 					= ltsPlanTto[0].FALP_CaseId__c;
      	O.CloseDate 					= Date.newInstance(2025, 5, 4);       
      	O.FALP_Plan_de_tratamiento__c 	= PT.id;
      	O.Name 							= '314117';      
      	O.RecordTypeId 					= PresTipo;
      	O.StageName 					= 'Nuevo';
      	O.Medico_Tratante__c 			= 'ALVARO DANIEL VIDAL FAUNE';
        O.FALP_IdPresupuesto__c		    = ltsPlanTto[0].Id;
        O.CC_PP_NPRESUPUESTO__c			= '10000';
		insert O;        
        
        
        param.FICH_ID				= 550474;
        param.ESTADO 				= null;
        param.FECHA_CIERRE_CUENTA 	= Date.newInstance(2025, 5, 4);
        param.FECHA_ANULACION 		= Date.newInstance(2025, 5, 5);
        param.FECHA_FOLIO 			= Date.newInstance(2025, 5, 6);
        param.FECHA_HOSPITALIZACION	= Date.newInstance(2025, 5, 7);
        param.MOTIVO_ANULACION 		= null;
        param.MOTIVO_INGRESO 		= null;
        param.NUMERO_DE_FOLIO 		= 'FO-0000000002';
        param.NOMBRE_DE_USUARIO 	= null;
        //param.PROPIETARIO 			= '005al000005BTmGAAW';
        param.SF_CASO_ID			= PT.FALP_CaseId__c; //ltsPlanTto[0].FALP_CaseId__c;
        param.SF_PRESUPUESTO_ID		= O.id;
            
        params.add(param);
        
        Test.startTest();
        CL_AddFolios.addFolios(params);
        Test.stopTest();
    }
}