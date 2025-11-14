@isTest
private class fCL_CasesChartViewOnTime2Test {

    @testSetup
    static void setupTestData() {
        // Crear un perfil válido
        Profile profile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Usuario estándar'
            LIMIT 1
        ];

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

        // Crear grupo de Chatter
        CollaborationGroup group1 = new CollaborationGroup(Name = 'Cardiología', CollaborationType = 'Public');
        insert group1;

        // Agregar miembro al grupo
        CollaborationGroupMember member = new CollaborationGroupMember(
            CollaborationGroupId = group1.Id,
            MemberId = testUser.Id
        );
        insert member;

        // Crear caso de prueba
        Case c = new Case(
            Subject = 'Test Caso en plazo',
            cc_ap_Tipo_de_Gestion__c = 'Reclamo',
            cc_ap_Estados__c = 'En espera',
            cc_ap_Origen_de_requerimiento__c = 'Centro Medico',
            cc_ap_Sub_rea_del_Requerimiento__c = 'Cardiología',
            CreatedDate = Date.today().addDays(-10)
        );
        insert c;

        // Crear servicio asociado al caso
        Servicios_en_Caso__c servicio = new Servicios_en_Caso__c(
            Caso__c = c.Id,
            Nombre_de_Grupo__c = 'Cardiología' // Nombre del grupo de Chatter
        );
        insert servicio;

        // Crear un usuario de sistema para insertar días festivos
        User systemUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];

        // Crear días festivos dentro de un contexto de sistema
        System.runAs(systemUser) {
            List<Holiday> testHolidays = new List<Holiday>();
            testHolidays.add(
                new Holiday(
                    Name = 'Test Holiday 1', // Campo obligatorio
                    ActivityDate = Date.today().addDays(-1)
                )
            );
            testHolidays.add(
                new Holiday(
                    Name = 'Test Holiday 2', // Campo obligatorio
                    ActivityDate = Date.today().addMonths(-1)
                )
            );
            insert testHolidays;
        }
    }

    static testMethod void testObtenerDatosGrafico_AllFilters() {
        Test.startTest();

        // Obtener el usuario de prueba
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testuser@example.com'
            LIMIT 1
        ];
        System.runAs(testUser) {
            Map<String, Object> resultado = fCL_CasesChartViewOnTime2.obtenerDatosGrafico(
                String.valueOf(Date.today().year()),
                new List<String>{String.valueOf(Date.today().month())},
                'Reclamo',
                'En espera',
                'Centro Medico',
                'Cardiología',
                'Instituto Oncológico'
            );
            System.assertNotEquals(null, resultado);
            System.assert(resultado.containsKey('datosGrafico'));
            System.assert(resultado.containsKey('totalCasos'));
        }
        Test.stopTest();
    }

    static testMethod void testGetTipoRequerimientoOptions() {
        Test.startTest();
        List<String> opciones = fCL_CasesChartViewOnTime2.getTipoRequerimientoOptions();
        System.assertNotEquals(null, opciones);
        Test.stopTest();
    }

    static testMethod void testObtenerDatosGrafico_SinMeses() {
        Test.startTest();
        // Obtener el usuario de prueba
        User testUser = [
            SELECT Id
            FROM User
            WHERE Email = 'testuser@example.com'
            LIMIT 1
        ];
        System.runAs(testUser) {
            Map<String, Object> resultado = fCL_CasesChartViewOnTime2.obtenerDatosGrafico(
                null,
                null,
                null,
                null,
                null,
                null,
                null
            );
            System.assertNotEquals(null, resultado);
        }
        Test.stopTest();
    }

    static testMethod void testObtenerUnidadesPorServicios() {
        Test.startTest();
        List<String> serviciosUsuario = new List<String>{'Cardiología'};
        List<String> unidades = fCL_CasesChartViewOnTime2.obtenerUnidadesPorServicios(serviciosUsuario);
        System.assertNotEquals(null, unidades);
        System.assert(unidades.contains('Centro Medico'));
        Test.stopTest();
    }

    static testMethod void testObtenerSubunidadesPorUnidadYServicios() {
        Test.startTest();
        String unidadSeleccionada = 'Centro Medico';
        List<String> serviciosUsuario = new List<String>{'Cardiología'};
        List<String> subunidades = fCL_CasesChartViewOnTime2.obtenerSubunidadesPorUnidadYServicios(unidadSeleccionada, serviciosUsuario);
        System.assertNotEquals(null, subunidades);
        Test.stopTest();
    }

    static testMethod void testObtenerGerenciasPorUsuario() {
        Test.startTest();
        List<String> serviciosUsuario = new List<String>{'Cardiología'};
        List<String> gerencias = fCL_CasesChartViewOnTime2.obtenerGerenciasPorUsuario(serviciosUsuario);
        System.assertNotEquals(null, gerencias);
        Test.stopTest();
    }

    static testMethod void testObtenerDiasFestivos() {
        Test.startTest();
        Integer anioSeleccionado = Date.today().year();
        Set<Date> diasFestivos = fCL_CasesChartViewOnTime2.obtenerDiasFestivos(anioSeleccionado);
        System.assertNotEquals(null, diasFestivos);
        System.assert(diasFestivos.contains(Date.today().addDays(-1)));
        Test.stopTest();
    }

    static testMethod void testCalcularDiasHabiles() {
        Test.startTest();
        Date fechaCreacion = Date.today().addDays(-10);
        Set<Date> diasFestivos = new Set<Date>{Date.today().addDays(-1)};
        Integer diasHabiles = fCL_CasesChartViewOnTime2.calcularDiasHabiles(fechaCreacion, diasFestivos);
        System.assertNotEquals(null, diasHabiles);
        System.assert(diasHabiles > 0);
        Test.stopTest();
    }
}