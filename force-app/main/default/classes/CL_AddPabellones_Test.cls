@isTest
public with sharing class CL_AddPabellones_Test {
    @isTest
	private static void testmigracionSch(){
        List<CL_AddPabellones.E_Parameters> params = new List<CL_AddPabellones.E_Parameters>();
        CL_AddPabellones.E_Parameters param = new CL_AddPabellones.E_Parameters();
        
        
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        insert newPersonAccount;
        
        
        param.SOLICITUD_PABELLON_ID				= 123456;
        param.RESERVA_PABELLON_ID				= 100001;
        param.CATEGORIA							= 'Pabellon';
        param.ESTADO							= 'Finished';
        param.PACIENTE_ID 						= newPersonAccount.Id; //'001WE00000OUP86YAH';
        param.SUCURSAL							= 'Antonio Varas';
		//param.PRESUPUESTO_ID	           		= null;
        param.FECHA_SOLICITUD	           		= Date.newInstance(2025, 5, 4);
        param.FECHA_RESERVA_PABELL_CONFIMADO	= Date.newInstance(2025, 5, 5);
        param.FECHA_INGRESO	           			= Date.newInstance(2025, 5, 6);
        param.COMENTARIO						= 'This is a test';
        param.HORA_INICIO_RESERVA				= DateTime.newInstance(2025, 1, 27, 13, 50, 13);
        param.HORA_TERMINO_RESERVA				= DateTime.newInstance(2025, 1, 27, 14, 50, 13);            
            
        params.add(param);
        
        Test.startTest();
        CL_AddPabellones.addPabellones(params);
        Test.stopTest();        
    }
}