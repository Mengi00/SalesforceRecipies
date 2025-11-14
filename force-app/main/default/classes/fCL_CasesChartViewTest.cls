@isTest
private class fCL_CasesChartViewTest {

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

        // Crear casos con tipo de gestión
        Case testCase1 = new Case(
            cc_ap_Tipo_de_Gestion__c = 'Reclamo',
            Status = 'Derivación',
            Subject = 'Test Case 1'
        );
        Case testCase2 = new Case(
            cc_ap_Tipo_de_Gestion__c = 'Sugerencia',
            Status = 'Derivación',
            Subject = 'Test Case 2'
        );
        insert new List<Case>{ testCase1, testCase2 };

        // Crear Servicios_en_Caso__c
        Servicios_en_Caso__c serviceCase1 = new Servicios_en_Caso__c(
            Caso__c = testCase1.Id,
            Nombre_de_Grupo__c = 'Test Group'
        );
        Servicios_en_Caso__c serviceCase2 = new Servicios_en_Caso__c(
            Caso__c = testCase2.Id,
            Nombre_de_Grupo__c = 'Test Group'
        );
        insert new List<Servicios_en_Caso__c>{ serviceCase1, serviceCase2 };
    }

    @isTest
    static void testObtenerDatosGrafico() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];

        // Simular el contexto del usuario actual(garantiza que el metodo se ejecute con los permisos del usuario de prueba)
        System.runAs(testUser) {
            // Iniciar prueba
            Test.startTest();
            Map<String, Object> resultado = fCL_CasesChartView.obtenerDatosGrafico(testUser.Id);
            Test.stopTest();

            // Validar los resultados
            System.assertNotEquals(null, resultado, 'El resultado no debe ser nulo');
            System.assert(resultado.containsKey('datosGrafico'), 'El resultado debe contener la clave "datosGrafico"');
            System.assert(resultado.containsKey('totalCasos'), 'El resultado debe contener la clave "totalCasos"');

            // Validar los datos del gráfico
            List<fCL_CasesChartView.DatoGrafico> datosGrafico = (List<fCL_CasesChartView.DatoGrafico>) resultado.get('datosGrafico');
            System.assertEquals(2, datosGrafico.size(), 'Debe haber 2 tipos de gestión en el gráfico');
            System.assertEquals(2, resultado.get('totalCasos'), 'El total de casos debe ser 2');

            // Validar los valores individuales
            Map<String, Integer> expectedValues = new Map<String, Integer>{
                'Reclamo' => 1,
                'Sugerencia' => 1
            };
            for (fCL_CasesChartView.DatoGrafico dato : datosGrafico) {
                System.assert(expectedValues.containsKey(dato.tipoGestion), 'El tipo de gestión debe estar en los valores esperados');
                System.assertEquals(expectedValues.get(dato.tipoGestion), dato.cantidad, 'La cantidad debe coincidir con los valores esperados');
            }
        }
    }
}