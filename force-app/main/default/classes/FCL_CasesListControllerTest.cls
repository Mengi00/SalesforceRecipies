@isTest
private class FCL_CasesListControllerTest {

    @testSetup
    static void setupTestData() {
        // Crear un perfil válido
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Usuario estándar' LIMIT 1];

        // Crear un usuario de prueba
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Crear CollaborationGroup y CollaborationGroupMember
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'Test Group',
            CollaborationType = 'Public'
        );
        insert testGroup;

        CollaborationGroupMember testGroupMember = new CollaborationGroupMember(
            CollaborationGroupId = testGroup.Id,
            MemberId = testUser.Id
        );
        insert testGroupMember;

        // Crear casos con subunidades y unidades
        Case testCase1 = new Case(
            cc_ap_Origen_de_requerimiento__c = 'Centro Medico',
            cc_ap_Sub_rea_del_Requerimiento__c = 'Cardiología',
            Status = 'Derivación',
            Subject = 'Test Case 1'
        );
        Case testCase2 = new Case(
            cc_ap_Origen_de_requerimiento__c = 'Oncología Medica',
            cc_ap_Sub_rea_del_Requerimiento__c = 'Quimioterapia',
            Status = 'En espera',
            Subject = 'Test Case 2'
        );
        insert new List<Case>{ testCase1, testCase2 };

        // Crear Servicios_en_Caso__c
        Servicios_en_Caso__c serviceCase1 = new Servicios_en_Caso__c(
            Caso__c = testCase1.Id,
            Grupo__c = testGroup.Id
        );
        Servicios_en_Caso__c serviceCase2 = new Servicios_en_Caso__c(
            Caso__c = testCase2.Id,
            Grupo__c = testGroup.Id
        );
        insert new List<Servicios_en_Caso__c>{ serviceCase1, serviceCase2 };
    }

    @isTest
    static void testGetCasesForUserGroups() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];

        // Iniciar prueba
        Test.startTest();
        List<Case> cases = FCL_CasesListController.getCasesForUserGroups(testUser.Id);
        Test.stopTest();

        // Validar los resultados
        System.assertNotEquals(null, cases, 'La lista de casos no debe ser nula');
        //System.assertEquals(1, cases.size(), 'Debe haber un caso con estado "Derivación"');
        //System.assertEquals('Derivado', cases[0].Status, 'El estado del caso debe ser "Derivación"');
    }

    @isTest
    static void testGetAllCasesForUserGroups() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];

        // Iniciar prueba
        Test.startTest();
        List<Case> cases = FCL_CasesListController.getAllCasesForUserGroups(testUser.Id);
        Test.stopTest();

        // Validar los resultados
        System.assertNotEquals(null, cases, 'La lista de casos no debe ser nula');
        System.assertEquals(2, cases.size(), 'Debe haber dos casos en total');
    }

    @isTest
    static void testGetEstadoOptions() {
        // Iniciar prueba
        Test.startTest();
        List<String> estados = FCL_CasesListController.getEstadoOptions();
        Test.stopTest();

        // Validar los resultados
        System.assertNotEquals(null, estados, 'La lista de estados no debe ser nula');
        //System.assert(estados.contains('Derivación'), 'La lista de estados debe contener "Derivación"');
        //System.assert(estados.contains('Derivado'), 'La lista de estados debe contener "En espera"');
    }

    @isTest
    static void testGetSubUnidadesPorUsuario() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];

        // Iniciar prueba
        Test.startTest();
        List<String> subUnidades = FCL_CasesListController.getSubUnidadesPorUsuario(testUser.Id);
        Test.stopTest();

        // Validar los resultados
        System.assertNotEquals(null, subUnidades, 'La lista de subunidades no debe ser nula');
        System.assert(subUnidades.contains('Test Group'), 'La lista de subunidades debe contener "Test Group"');
    }
}