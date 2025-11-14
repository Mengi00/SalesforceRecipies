@isTest
private class fcl_CaseStatisticsControllerTest {

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

        // Crear un grupo de colaboración
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'Test Group',
            CollaborationType = 'Public'
        );
        insert testGroup;

        // Asociar el usuario al grupo de colaboración
        CollaborationGroupMember testGroupMember = new CollaborationGroupMember(
            CollaborationGroupId = testGroup.Id,
            MemberId = testUser.Id
        );
        insert testGroupMember;

        // Crear casos asociados al grupo
        Case testCase1 = new Case(
            Status = 'Derivación',
            Subject = 'Test Case 1'
        );
        Case testCase2 = new Case(
            Status = 'Derivación',
            Subject = 'Test Case 2'
        );
        insert new List<Case>{ testCase1, testCase2 };

        // Asociar casos al grupo
        Servicios_en_Caso__c serviceCase1 = new Servicios_en_Caso__c(
            Caso__c = testCase1.Id,
            Nombre_de_Grupo__c = 'Test Group'
        );
        Servicios_en_Caso__c serviceCase2 = new Servicios_en_Caso__c(
            Caso__c = testCase2.Id,
            Nombre_de_Grupo__c = 'Test Group'
        );
        insert new List<Servicios_en_Caso__c>{ serviceCase1, serviceCase2 };
        
        // Crear un EmailMessage relacionado con un caso
        EmailMessage emailMessage1 = new EmailMessage(
            ToAddress = 'testuser@example.com',
            ParentId = testCase1.Id
        );
        insert emailMessage1;
    }

    @isTest
    static void testGetCaseStatistics() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];

        // Simular el contexto del usuario actual
        System.runAs(testUser) {
            // Iniciar prueba
            Test.startTest();
            Map<String, Integer> statistics = fcl_CaseStatisticsController.getCaseStatistics();
            Test.stopTest();

            // Validar los resultados
            System.assertNotEquals(null, statistics, 'El resultado no debe ser nulo');
            System.assert(statistics.containsKey('myCases'), 'El resultado debe contener la clave "myCases"');
            System.assert(statistics.containsKey('AreaCases'), 'El resultado debe contener la clave "AreaCases"');

            // Validar los valores de las estadísticas
            System.assertEquals(1, statistics.get('myCases'), 'El número de casos relacionados con correos electrónicos debe ser 1');
            System.assertEquals(2, statistics.get('AreaCases'), 'El número de casos en estado "Derivación" debe ser 2');
        }
    }
}