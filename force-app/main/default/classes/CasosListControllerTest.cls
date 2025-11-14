@isTest
public class CasosListControllerTest {
    @testSetup
    static void setupTestData() {
        // Crear usuarios de prueba
        User testUser1 = new User(
            Username = 'testuser1@example.com.test',
        Email = 'testuser1@example.com',
        LastName = 'Test',
        FirstName = 'User1',
        Alias = 'tuser1',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = '00eal000008dYA5AAM',
        LanguageLocaleKey = 'en_US'
            );
        insert testUser1;
        
        User testUser2 = new User(
            Username = 'testuser2@example.com.test',
        Email = 'testuser2@example.com',
        LastName = 'Test',
        FirstName = 'User2',
        Alias = 'tuser2',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = '00eal000008dYA5AAM',
        LanguageLocaleKey = 'en_US'
            );
        insert testUser2;
        
        // Crear CollaborationGroup de prueba
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'Test Group',
        CollaborationType = 'Public'
            );
        insert testGroup;
        
        // Asignar usuarios al grupo
        CollaborationGroupMember testGroupMember1 = new CollaborationGroupMember(
            CollaborationGroupId = testGroup.Id,
        MemberId = testUser1.Id
            );
        insert testGroupMember1;
        
        CollaborationGroupMember testGroupMember2 = new CollaborationGroupMember(
            CollaborationGroupId = testGroup.Id,
        MemberId = testUser2.Id
            );
        insert testGroupMember2;
        
        // Crear casos de servicio de prueba
        Case testCase1 = new Case(
            Subject = 'Test Case 1',
        Status = 'New',
        Origin = 'Phone',
        cc_ap_Estados__c = 'Derivación'
            );
        insert testCase1;
        
        Case testCase2 = new Case(
            Subject = 'Test Case 2',
        Status = 'New',
        Origin = 'Email',
        cc_ap_Estados__c = 'En espera'
            );
        insert testCase2;
        
        // Crear Servicios_en_Caso__c de prueba
        Servicios_en_Caso__c testServiceCase1 = new Servicios_en_Caso__c(
            Caso__c = testCase1.Id,
        Grupo__c = testGroup.Id
            );
        insert testServiceCase1;
        
        Servicios_en_Caso__c testServiceCase2 = new Servicios_en_Caso__c(
            Caso__c = testCase2.Id,
        Grupo__c = testGroup.Id
            );
        insert testServiceCase2;
    }
    
    @isTest
    static void testGetCasesForUserGroups() {
        // Obtener el ID del usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser1@example.com' LIMIT 1];
        
        // Ejecutar el método de la clase CasosListController
        Test.startTest();
        List<Case> cases = CasosListController.getCasesForUserGroups(testUser.Id);
        Test.stopTest();
        
        // Verificar que se haya retornado el caso correcto
        System.assertEquals(1, cases.size(), 'Se esperaba que se retornara 1 caso.');
        System.assertEquals('Test Case 1', cases[0].Subject, 'El caso retornado no es el esperado.');
    }
}