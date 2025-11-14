@isTest
public with sharing class CL_AddPresupuestos_Test {
    @isTest
	private static void testmigracionSch(){
		Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Fred';
        newPersonAccount.LastName = 'Smith';
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        insert newPersonAccount;      
         
        //CodeSet cs = new CodeSet(Code = '12345', Name='FIEBRE PARATIFOIDEA B');
        //insert cs;
        //CodeSetBundle csb = new CodeSetBundle();
        //csb.Name = 'FIEBRE PARATIFOIDEA B';
        //csb.CodeSet1Id = cs.Id;
        //insert  csb;
        
        List<CL_AddPresupuestos.E_Parameters> params = new List<CL_AddPresupuestos.E_Parameters>();
        CL_AddPresupuestos.E_Parameters param = new CL_AddPresupuestos.E_Parameters(); 
        
        param.PRES_ID 					= '310255';
        param.CPRE_ID 					= '310255';		
        param.ACCOUNT_ID 				= newPersonAccount.id;// '001al00001UpIVKAA3';
        param.AMOUNT 					= 1000;
        param.CASE_ID 					= '500al00000VWJPUAA5';
        param.CLOSE_DATE 				= Date.newInstance(2025, 5, 3);
        param.PLAN_DE_TRATAMIENTO_ID 	= null;
        //param.NAME 						= 'Pres-448263'; ///PRES_NQ310255';
        param.RECORD_TYPE_ID 			= '012al000003V4NNAA0';
        param.STAGE_NAME 				= 'Nuevo';
        param.MEDICO_TRATANTE 			= 'MARCELA FRITIS CACERES';        
        param.FECHA_CREACION_PRESUPUESTO= DateTime.newInstance(2025, 1, 27, 14, 50, 13);
       	param.USUARIO_PRESUPUESTO		= 'Usuario test';
      	param.CICLO_ID					= 123;				
      	param.TIPO_HONORARIO			= 'Institucional';
      	param.PREVISION					= 'Test';
        //param.PRESUPUESTO_ID 			= null;
        
        params.add(param);
        
        Test.startTest();
        CL_AddPresupuestos.addPresupuestos(params);
        //Assert.areEqual(param.PT_PRIORIDAD, 'Low');
        Test.stopTest();
    }
}