@isTest
public class wsListPlus_tst {
    
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Afiliacion_CO__c> afis = new List<Afiliacion_CO__c>();
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(name='Account '+i,
                billingcity='New York', billingcountry='USA'));
        }
        insert accounts;
        // find the account just inserted. add contact for each
        for (Account account : [select id from account]) {
            contacts.add(new Contact(firstname='first',
                lastname='last', accountId=account.id));
        }
        insert contacts;
        afis.add(new Afiliacion_CO__c(Contacto__c = contacts[0].id, Cuenta__c = accounts[0].id));
        insert afis;
        Case c = new Case();
        c.ClosedDate = Date.Today();
        c.cc_pp_convenio__c = 'FONASA LE';
        c.AccountId = accounts[0].id;
        insert c;
    }
    
    
    @isTest
    static void testGetListPlus() {
        List<wsListPlus.NewProformaActionRequest> lst_req = new List<wsListPlus.NewProformaActionRequest>();
        wsListPlus.NewProformaActionRequest req = new wsListPlus.NewProformaActionRequest();
        
        Account cuenta = New Account();
        cuenta.LastName = 'IoS';
        insert cuenta;
        Case cas = New Case();
        cas.cc_pp_NPlandeTratamiento__c = '1234';
        cas.cc_pp_NPresupuesto__c = '1234';
        cas.AccountId = cuenta.Id;
        insert cas;
        req.caseId = cas.Id;        
        ClinicalServiceRequest planT = new ClinicalServiceRequest();
        planT.FALP_CaseId__c = cas.Id;
        planT.Type = 'Plan de tratamiento';
        planT.PatientId = cuenta.Id;
        planT.CC_PP_NPLANDETRATAMIENTO__c = cas.cc_pp_NPlandeTratamiento__c;
        insert planT;
        
        Opportunity presu = new Opportunity();
        presu.CC_PP_NPRESUPUESTO__c = cas.cc_pp_NPresupuesto__c;
        presu.CaseId__c = cas.Id;
        presu.Name = 'test IoS';
        presu.StageName = 'Nuevo';
        presu.CloseDate = Date.today();
        insert presu;
        req.caseId = cas.Id;
        lst_req.add(req);
        test.StartTest();
        test.setMock(HttpCalloutMock.class, new wsListPLusMock_tst() );
        wsListPlus.wsGetListPlus(lst_req);
        test.stopTest();
    } 
	
    @isTest
    static void testWrapper(){
        test.StartTest();
        wsListPlusParser.request request=new wsListPlusParser.request(); 
        request.Nroiden = '';
        request.Nombre = '';
        request.Apepat = '';
        request.Apemat = '';
        request.Fecnactex = '';
        request.Genero = 1;
        request.Direccion = '';
        request.Pais = '';
        request.Region = '';
        request.Comuna = '';
        request.Nacionalidad = '';
        request.Telefono = '';
        request.Email = '';
        request.Fonasa = 1;
        wsListPlusParser.requestPlan requestPlan=new wsListPlusParser.requestPlan();
        requestPlan.sistema_origen = '';
        requestPlan.usuario = '';
        requestPlan.fecha_accion = '';
        requestPlan.id_plan_tto = '';
        requestPlan.opcion = '';
        test.stopTest();
    }
    @isTest
    static void testGetListPlusError() {
        List<wsListPlus.NewProformaActionRequest> lst_req = new List<wsListPlus.NewProformaActionRequest>();
        wsListPlus.NewProformaActionRequest req = new wsListPlus.NewProformaActionRequest();
        
        Case cas = [Select Id From Case Limit 1];
        req.caseId = cas.Id;
        lst_req.add(req);
        test.StartTest();
        try{
        	wsListPlus.wsGetListPlus(lst_req);
        } catch (Exception e) {
                System.debug(e.getMessage());
            }
        test.stopTest();
    } 

    
    
    @isTest
    static void testSaveDocumentListPlus() {
        List<wsSaveDocumentListPlus.NewProformaActionRequest> lst_req = new List<wsSaveDocumentListPlus.NewProformaActionRequest>();
        wsSaveDocumentListPlus.NewProformaActionRequest req = new wsSaveDocumentListPlus.NewProformaActionRequest();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
		insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Case cas = [Select Id From Case Limit 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = cas.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        req.caseId = cas.Id;
        req.documentId = documents[0].Id;
        lst_req.add(req);
        test.StartTest();
        test.setMock(HttpCalloutMock.class, new wsListPLusMock_tst() );
        wsSaveDocumentListPlus.wsDocumentBase64(lst_req);
        test.stopTest();
    } 

    @isTest
    static void testSaveDocumentListPlusError() {
        List<wsSaveDocumentListPlus.NewProformaActionRequest> lst_req = new List<wsSaveDocumentListPlus.NewProformaActionRequest>();
        wsSaveDocumentListPlus.NewProformaActionRequest req = new wsSaveDocumentListPlus.NewProformaActionRequest();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
		insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Case cas = [Select Id From Case Limit 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = cas.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        req.caseId = cas.Id;
        req.documentId = documents[0].Id;
        lst_req.add(req);
        test.StartTest();
        test.setMock(HttpCalloutMock.class, new wsListPLusMock_tst() );
        
        try{
        	wsSaveDocumentListPlus.wsDocumentBase64(lst_req);
        } catch (Exception e) {
                System.debug(e.getMessage());
            }
        test.stopTest();
    } 
}