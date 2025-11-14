@isTest
private class FCL_SolicitudesDeMejoraListTest {
  @testSetup
static void makeData() {
    Grupos__c unidadPrueba = new Grupos__c(
        Nombre_Collaboration_Group__c = 'Unidad de Prueba',
        Id_Colaboration_Group__c = 'CG-TEST-001'
    );
    insert unidadPrueba;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Usuario estándar' LIMIT 1];
    
    List<User> usersToCreate = new List<User>();
    
    // --- Usuario 1 ---
        User user01 = new User(
            FirstName = 'UsuarioTesttt1',
            LastName = 'UsuarioUno1',
            Email = 'testuser1_' + Datetime.now().getTime() + '@testorg.com', // Usamos timestamp para asegurar unicidad
            Username = 'testuser1_' + Datetime.now().getTime() + '@testorg.com',
            Alias = 'test1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        user01.Username = user01.Email;
    	usersToCreate.add(user01);

    // --- Usuario 2 ---
    User user02 = new User(
            FirstName = 'UsuarioTesttt2',
            LastName = 'UsuarioDos2',
            Email = 'testuser2_' + Datetime.now().getTime() + '@testorg.com',
            Username = 'testuser2_' + Datetime.now().getTime() + '@testorg.com',
            Alias = 'test2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        user02.Username = user02.Email;
    	usersToCreate.add(user02);
    
    insert usersToCreate;
}

  @isTest
  static void testGetSolicitudesCreadasPorUsuarioActual() {
    // --- PREPARACIÓN ---
    User user1 = [SELECT Id FROM User WHERE LastName = 'UsuarioUno1' LIMIT 1];
    User user2 = [SELECT Id FROM User WHERE LastName = 'UsuarioDos2' LIMIT 1];

    // Caso 2: Creada por user2, pero asignada a user1. Se crea fuera de runAs.
    // Esta solicitud será encontrada por la segunda parte de la condición OR.
    insert new Solicitud_de_Mejora__c(
      Titulo__c = 'Solicitud B',
      OwnerId = user2.Id,
      Usuario_Solicitante__c = user1.Id,
      Categoria_de_Mejora__c = 'Equipo'
    );

    // Caso 3: Creada por user2 para user2. No debería aparecer.
    insert new Solicitud_de_Mejora__c(
      Titulo__c = 'Solicitud C',
      OwnerId = user2.Id,
      Usuario_Solicitante__c = user2.Id,
      Categoria_de_Mejora__c = 'Equipo'
    );

    List<Solicitud_de_Mejora__c> resultList;

    // --- EJECUCIÓN ---
    System.runAs(user1) {
      // Caso 1 se crea DENTRO de runAs para que CreatedById sea user1.
      // Esta solicitud será encontrada por la primera parte de la condición OR.
      insert new Solicitud_de_Mejora__c(
        Titulo__c = 'Solicitud A',
        Categoria_de_Mejora__c = 'Equipo'
      );

      Test.startTest();
      resultList = FCL_SolicitudesDeMejoraList.getSolicitudesCreadasPorUsuarioActual();
      Test.stopTest();
    }

    // --- VERIFICACIÓN ---
    // Ahora la consulta encontrará tanto la Solicitud A como la Solicitud B.
    System.assertNotEquals(
      null,
      resultList,
      'La lista de resultados no debe ser nula.'
    );
    System.assertEquals(
      2,
      resultList.size(),
      'Deberían haberse encontrado 2 solicitudes para el usuario 1, pero se encontraron ' +
      resultList.size()
    );
  }

  @isTest
  static void testGetCategoriaOptions() {
    insert new List<Solicitud_de_Mejora__c>{
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S1',
        Categoria_de_Mejora__c = 'Infraestructura'
      ),
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S2',
        Categoria_de_Mejora__c = 'Equipo'
      ),
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S3',
        Categoria_de_Mejora__c = 'Procesos'
      )
    };

    Test.startTest();
    List<String> categorias = FCL_SolicitudesDeMejoraList.getCategoriaOptions();
    Test.stopTest();

    // La aserción ahora espera 3 valores únicos, no 2.
    System.assertEquals(
      3,
      categorias.size(),
      'Debería haber 3 categorías únicas, pero se encontraron ' +
      categorias.size()
    );
    System.assert(
      categorias.contains('Procesos'),
      'La lista debería contener "Procesos".'
    );
    System.assert(
      categorias.contains('Equipo'),
      'La lista debería contener "Equipo".'
    );
    System.assert(
      categorias.contains('Infraestructura'),
      'La lista debería contener "Infraestructura".'
    );
  }

  @isTest
  static void testGetEstadoOptions() {
    // --- PREPARACIÓN ---
    insert new List<Solicitud_de_Mejora__c>{
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S1',
        Estado__c = 'En Espera',
        Categoria_de_Mejora__c = 'Equipo'
      ),
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S2',
        Estado__c = 'Derivado',
        Categoria_de_Mejora__c = 'Infraestructura'
      ),
      new Solicitud_de_Mejora__c(
        Titulo__c = 'S3',
        Estado__c = 'En Espera',
        Categoria_de_Mejora__c = 'Equipo'
      ) // Duplicado
    };

    // --- EJECUCIÓN ---
    Test.startTest();
    List<String> estados = FCL_SolicitudesDeMejoraList.getEstadoOptions();
    Test.stopTest();

    // --- VERIFICACIÓN ---
    System.debug('Valores de estado encontrados: ' + estados);

    System.assertEquals(
      2,
      estados.size(),
      'Debería haber 2 estados únicos, pero se encontraron ' + estados.size()
    );

    System.assert(
      estados.contains('En Espera'),
      'La lista de estados no contenía el valor esperado "En Espera". Contenido real: ' +
      estados
    );
    System.assert(
      estados.contains('Derivado'),
      'La lista de estados no contenía el valor esperado "Derivado". Contenido real: ' +
      estados
    );
  }

  @isTest
  static void testCreateSolicitud_Success() {
    Grupos__c unidad = [SELECT Id FROM Grupos__c LIMIT 1];
    String titulo = 'Mi Solicitud de Éxito';

    Test.startTest();
    Solicitud_de_Mejora__c nuevaSolicitud = FCL_SolicitudesDeMejoraList.createSolicitud(
      titulo,
      'Descripción de éxito',
      'Procesos',
      'Propuesta de éxito',
      unidad.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      nuevaSolicitud,
      'La solicitud devuelta no debería ser nula.'
    );
    Solicitud_de_Mejora__c solicitudCreada = [
      SELECT Id, Titulo__c
      FROM Solicitud_de_Mejora__c
      WHERE Id = :nuevaSolicitud.Id
    ];
    System.assertEquals(
      titulo,
      solicitudCreada.Titulo__c,
      'El título del registro guardado no coincide.'
    );
  }
}