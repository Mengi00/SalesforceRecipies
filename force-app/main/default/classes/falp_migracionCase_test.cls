/**********************************************************************************************************************************************************************************
 * Nombre de la Clase Apex : falp_migracionCase_test
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
public with sharing class falp_migracionCase_test {
    @TestSetup
    static void makeData(){
        String idRTPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account cuenta = new Account(FirstName = 'NameTest', LastName = 'Test', RecordTypeId = idRTPersonAccount);
        cuenta.RUT__pc = 10000001;
        cuenta.Rut_DV__pc = '6';
        insert cuenta;
        Contact Contacto = new Contact(FirstName = 'NameTest', LastName = 'Test');
        insert Contacto;
        //insertar un paquete de codigo y conjunto de paquete de codigo

        String idRTCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ServiceRequest').getRecordTypeId();
        Case caso1 = new Case(AccountId = cuenta.Id, ContactId =Contacto.Id, Subject ='test', RecordTypeId = idRTCase);
        caso1.FALP_Temp_por_Procesar__c = true;
        caso1.falp_Temp_Caso_Migrado__c = false;
        caso1.cc_pp_proc_prin__c = 'test ioS';
        caso1.cc_pp_NPresupuesto__c = 'ioS123';
        caso1.cc_pp_nfolio__c = 123.123;
        caso1.cc_pp_FdCP__c =Date.valueOf('2024-12-11');
        caso1.cc_pp_Fecha_Pabellon__c =Date.valueOf('2024-12-11');
        caso1.cc_pp_proc_prin__c = 'IoS';
        caso1.cc_pp_NPlandeTratamiento__c = '467564';
        caso1.SuppliedCompany = '7862';
        caso1.cc_ap_numerodegestion__c = '7867';
        insert caso1;
        CodeSet codigo = new CodeSet();
        codigo.Name = 'IoS';
        codigo.Code = 'IoS-123';
        insert codigo;
        CodeSetBundle paqueteCodigo = new CodeSetBundle();
        paqueteCodigo.Name = 'test';
        paqueteCodigo.CodeSet1Id = codigo.Id;
        insert paqueteCodigo;
    }
    @isTest
    private static void testmigracionSch(){
        Test.startTest();
        falp_migracionCase_sch mySchedulable = new falp_migracionCase_sch();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, mySchedulable);
        Test.stopTest();
    }
}