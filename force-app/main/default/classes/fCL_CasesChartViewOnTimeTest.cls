@isTest
private class fCL_CasesChartViewOnTimeTest {
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

    // Crear caso EN PLAZO (estimado mayor a días transcurridos hábiles)
    Case casoEnPlazo = new Case(
      Subject = 'Test Caso en plazo',
      cc_ap_Tipo_de_Gestion__c = 'Reclamo',
      cc_ap_Estados__c = 'En espera',
      cc_ap_Origen_de_requerimiento__c = 'Centro Medico',
      cc_ap_Sub_rea_del_Requerimiento__c = 'Cardiología',
      CreatedDate = System.today().addDays(-2) // Mes actual
    );
    // Crear caso FUERA DE PLAZO (estimado menor que días hábiles)
    Case casoFueraPlazo = new Case(
      Subject = 'Test Caso Fuera de Plazo',
      cc_ap_Tipo_de_Gestion__c = 'Reclamo', // Asegurar que coincida con el filtro
      cc_ap_Estados__c = 'En espera',
      cc_ap_Origen_de_requerimiento__c = 'Oncología Medica',
      cc_ap_Sub_rea_del_Requerimiento__c = 'Quimioterapia',
      CreatedDate = System.today().addMonths(-1).addDays(-10), // Mes anterior
      Status = 'Nuevo'
    );

    insert new List<Case>{ casoEnPlazo, casoFueraPlazo };

    //  Crear CollaborationGroup y CollaborationGroupMember
    CollaborationGroup testGroup1 = new CollaborationGroup(
      //Name = 'Test Group',
      Name = 'Cardiología',
      CollaborationType = 'Public'
    );
    CollaborationGroup testGroup2 = new CollaborationGroup(
      //Name = 'Test Group',
      Name = 'Quimioterapia',
      CollaborationType = 'Public'
    );
    insert new List<CollaborationGroup>{ testGroup1, testGroup2 };

    // Crear Servicios_en_Caso__c
    Servicios_en_Caso__c serviceCase1 = new Servicios_en_Caso__c(
      Caso__c = casoEnPlazo.Id,
      Grupo__c = testGroup1.Id
    );
    Servicios_en_Caso__c serviceCase2 = new Servicios_en_Caso__c(
      Caso__c = casoFueraPlazo.Id,
      Grupo__c = testGroup2.Id
    );
    insert new List<Servicios_en_Caso__c>{ serviceCase1, serviceCase2 };

    // asociar el usuario al grupo
    CollaborationGroupMember testGroupMember1 = new CollaborationGroupMember(
      CollaborationGroupId = testGroup1.Id,
      MemberId = testUser.Id
    );
    CollaborationGroupMember testGroupMember2 = new CollaborationGroupMember(
      CollaborationGroupId = testGroup2.Id,
      MemberId = testUser.Id
    );
    insert new List<CollaborationGroupMember>{
      testGroupMember1,
      testGroupMember2
    };

    // Crear un usuario de sistema para insertar días festivos
    User systemUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];

    // Crear días festivos dentro de un contexto de sistema
    System.runAs(systemUser) {
      List<Holiday> testHolidays = new List<Holiday>();
      testHolidays.add(
        new Holiday(
          Name = 'Test Holiday', // Agregar un valor para el campo obligatorio Name
          ActivityDate = Date.today().addDays(-2)
        )
      );
      insert testHolidays;
    }
  }

  @isTest
  static void testObtenerDatosGrafico() {
    Test.startTest();

    // Debugging: Log the test setup data
    System.debug('Test setup data created.');

    // Obtener el usuario de prueba
    User testUser = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser@example.com'
      LIMIT 1
    ];

    // Ejecutar el método dentro del contexto del usuario
    System.runAs(testUser) {
      // Llamar al metodo
      Map<String, Object> result = fCL_CasesChartViewOnTime.obtenerDatosGrafico(
        String.valueOf(Date.today().year()),
        new List<String>{ '3', '4' },
        'Reclamo', // Asegurar que coincida con los datos de prueba
        'En espera',
        'Test Group',
        null,
        null
      );

      // Depuración para verificar el resultado
      System.debug('Resultado de obtenerDatosGrafico: ' + result);

      // Validar que el resultado no sea nulo
      System.assertNotEquals(null, result, 'El resultado no debe ser nulo');

      // Validar que el resultado contenga las claves esperadas
      System.assert(
        result.containsKey('datosGrafico'),
        'El resultado debe contener datosGrafico'
      );
      System.assert(
        result.containsKey('totalCasos'),
        'El resultado debe contener totalCasos'
      );
      System.assert(
        result.containsKey('casosFiltrados'),
        'El resultado debe contener casos filtrados'
      );

      // Validar que datosGrafico no sea nulo
      List<Object> datosGrafico = (List<Object>) result.get('datosGrafico');
      System.assertNotEquals(
        null,
        datosGrafico,
        'datosGrafico no debe ser nulo'
      );

      /*// Validar el número de entradas en datosGrafico
      System.assertEquals(
        2,
        datosGrafico.size(),
        'El resultado de datosGrafico debe contener 2 entradas'
      );*/

      for (Object o : datosGrafico) {
        Map<String, Object> entry = (Map<String, Object>) o;
        System.assertNotEquals(
          null,
          entry,
          'Cada entrada en datosGrafico no debe ser nula'
        );

        String mes = (String) entry.get('mes');
        Decimal porcentajeEnPlazo = (Decimal) entry.get('porcentajeEnPlazo');
        Decimal porcentajeFueraPlazo = (Decimal) entry.get(
          'porcentajeFueraPlazo'
        );

        System.assertNotEquals(null, mes, 'El mes no debe ser nulo');
        System.assertNotEquals(
          null,
          porcentajeEnPlazo,
          'El porcentajeEnPlazo no debe ser nulo'
        );
        System.assertNotEquals(
          null,
          porcentajeFueraPlazo,
          'El porcentajeFueraPlazo no debe ser nulo'
        );

        System.assert(
          porcentajeEnPlazo + porcentajeFueraPlazo == 100,
          'La suma de porcentajes debe ser 100'
        );

        // Validar que haya al menos un valor distinto de 0
        System.assert(
          porcentajeEnPlazo > 0 || porcentajeFueraPlazo > 0,
          'Debe haber al menos un porcentaje no cero'
        );
      }
    }

    Test.stopTest();
  }

  @isTest
  static void testObtenerDatosGrafico_sinMeses() {
    Test.startTest();
    Map<String, Object> resultado = fCL_CasesChartViewOnTime.obtenerDatosGrafico(
      null,
      new List<String>{},
      null,
      null,
      null,
      null,
      null
    );
    System.assertNotEquals(null, resultado, 'El resultado no debe ser nulo');
    System.assert(
      resultado.containsKey('datosGrafico'),
      'El resultado debe contener datosGrafico'
    );
    System.assert(
      resultado.containsKey('totalCasos'),
      'El resultado debe contener totalCasos'
    );
    System.assert(
      resultado.containsKey('casosFiltrados'),
      'El resultado debe contener casos filtrados'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetTipoRequerimientoOptions() {
    Test.startTest();
    // llamar al metodo
    List<String> options = fCL_CasesChartViewOnTime.getTipoRequerimientoOptions();
    System.debug('Opciones de Tipo de Requerimiento: ' + options);
    // Validar el resultado es esperado
    System.assertNotEquals(null, options, 'Las opciones no deben ser nulas');
    System.assert(!options.isEmpty(), 'Las opciones no deben estar vacías');
    Test.stopTest();
  }

  @isTest
  static void testObtenerUnidadesPorServicios() {
    Test.startTest();

    // Crear datos de prueba
    List<String> serviciosUsuario = new List<String>{ 'Cardiología', 'Quimioterapia' };

    // Llamar al método
    List<String> unidades = fCL_CasesChartViewOnTime.obtenerUnidadesPorServicios(serviciosUsuario);

    // Validar que el resultado no sea nulo ni vacío
    System.assertNotEquals(null, unidades, 'Las unidades no deben ser nulas');
    System.assert(!unidades.isEmpty(), 'Las unidades no deben estar vacías');

    Test.stopTest();
  }

  @isTest
  static void testObtenerSubunidadesPorUnidadYServicios() {
    Test.startTest();

    // Crear datos de prueba
    String unidadSeleccionada = 'Centro Medico';
    List<String> serviciosUsuario = new List<String>{ 'Cardiología', 'Quimioterapia' };

    // Llamar al método
    List<String> subunidades = fCL_CasesChartViewOnTime.obtenerSubunidadesPorUnidadYServicios(unidadSeleccionada, serviciosUsuario);

    // Validar que el resultado no sea nulo ni vacío
    System.assertNotEquals(null, subunidades, 'Las subunidades no deben ser nulas');
    System.assert(!subunidades.isEmpty(), 'Las subunidades no deben estar vacías');

    Test.stopTest();
  }

  @isTest
  static void testObtenerGerenciasPorUsuario() {
    Test.startTest();

    // Crear datos de prueba
    List<String> unidadesUsuario = new List<String>{ 'Centro Medico', 'Oncología Medica' };

    // Debugging: Log the test input
    System.debug('Test input services: ' + unidadesUsuario);

    // Llamar al método
    List<String> gerencias = fCL_CasesChartViewOnTime.obtenerGerenciasPorUsuario(unidadesUsuario);

    // Debugging: Log the result of the method call
    System.debug('Result from obtenerGerenciasPorUsuario: ' + gerencias);

    // Validar que el resultado no sea nulo ni vacío
    System.assertNotEquals(null, gerencias, 'Las gerencias no deben ser nulas');
    System.assert(!gerencias.isEmpty(), 'Las gerencias no deben estar vacías');

    Test.stopTest();
  }
}