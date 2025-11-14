@isTest
private class fCL_RequerimientosDeMejoraTest {
  // El método @testSetup crea los datos base una sola vez, haciendo las pruebas más rápidas.
  @testSetup
  static void makeData() {
    // 1. Crear un usuario que será el "Responsable"
    Profile p = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Usuario estándar'
      LIMIT 1
    ];
    User responsableUser = new User(
      Alias = 'resp',
      Email = 'responsable@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Responsable',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'responsable@testorg.com'
    );
    insert responsableUser;

    // 2. Crear una Unidad (Grupo) y asignarle el responsable
    Grupos__c unidad = new Grupos__c(
      Nombre_Collaboration_Group__c = 'Unidad de Prueba',
      Id_Colaboration_Group__c = 'CG-TEST-002',
      Usuario_Responsable__c = responsableUser.Id
    );
    insert unidad;

    // 3. Crear una Solicitud de Mejora padre
    Solicitud_de_Mejora__c solicitud = new Solicitud_de_Mejora__c(
      Titulo__c = 'Solicitud Padre de Prueba',
      Categoria_de_Mejora__c = 'Tecnología'
    );
    insert solicitud;

    // 4. Crear un Requerimiento de Mejora para las pruebas
    Requerimiento_de_Mejora__c req = new Requerimiento_de_Mejora__c(
      Titulo__c = 'Requerimiento de Prueba Principal',
      Solicitud_de_Mejora__c = solicitud.Id,
      Unidad_Responsable__c = unidad.Id,
      Estado__c = 'Derivado',
      Prioridad__c = 'Alta'
    );
    insert req;
  }

  @isTest
  static void testGetRequerimientosByResponble() {
    // --- PREPARACIÓN ---
    User responsableUser = [
      SELECT Id
      FROM User
      WHERE UserName = 'responsable@testorg.com'
    ];

    // --- EJECUCIÓN ---
    List<Requerimiento_de_Mejora__c> resultList;
    System.runAs(responsableUser) {
      // Ejecutamos como si fuéramos el usuario responsable
      Test.startTest();
      resultList = fCL_RequerimientosDeMejora.getRequerimientosByResponble();
      Test.stopTest();
    }

    // --- VERIFICACIÓN ---
    // Debería encontrar el registro que creamos en @testSetup porque cumple todas las condiciones.
    System.assertEquals(
      1,
      resultList.size(),
      'Debería encontrar un requerimiento para el responsable.'
    );
  }

  // Prueba #1: Verifica que la fecha se establece correctamente en la primera vista.
  @isTest
  static void testMarkAsViewed_FirstView() {
    // --- PREPARACIÓN ---
    Requerimiento_de_Mejora__c req = [
      SELECT Id, Fecha_Primera_Visualizacion__c
      FROM Requerimiento_de_Mejora__c
      LIMIT 1
    ];
    // Verificación inicial: La fecha debe ser nula.
    System.assertEquals(
      null,
      req.Fecha_Primera_Visualizacion__c,
      'La fecha inicial debe ser nula.'
    );

    // --- EJECUCIÓN ---
    Test.startTest();
    fCL_RequerimientosDeMejora.markAsViewed(req.Id);
    Test.stopTest();

    // --- VERIFICACIÓN ---
    Requerimiento_de_Mejora__c reqAfterUpdate = [
      SELECT Id, Fecha_Primera_Visualizacion__c
      FROM Requerimiento_de_Mejora__c
      WHERE Id = :req.Id
    ];
    System.assertNotEquals(
      null,
      reqAfterUpdate.Fecha_Primera_Visualizacion__c,
      'La fecha debería haberse actualizado después de la primera llamada.'
    );
  }

  // Prueba #2: Verifica que la fecha NO cambia en visitas posteriores.
  @isTest
  static void testMarkAsViewed_SubsequentView() {
    // --- PREPARACIÓN ---
    // Creamos un requerimiento con una fecha ya establecida.
    DateTime fechaOriginal = System.now().addDays(-1);
    Requerimiento_de_Mejora__c req = [
      SELECT Id
      FROM Requerimiento_de_Mejora__c
      LIMIT 1
    ];
    req.Fecha_Primera_Visualizacion__c = fechaOriginal;
    update req;

    // --- EJECUCIÓN ---
    // Llamamos al método sobre un registro que ya tiene la fecha.
    Test.startTest();
    fCL_RequerimientosDeMejora.markAsViewed(req.Id);
    Test.stopTest();

    // --- VERIFICACIÓN ---
    // Verificamos que la fecha NO haya cambiado.
    Requerimiento_de_Mejora__c reqAfterSecondCall = [
      SELECT Id, Fecha_Primera_Visualizacion__c
      FROM Requerimiento_de_Mejora__c
      WHERE Id = :req.Id
    ];
    System.assertEquals(
      fechaOriginal,
      reqAfterSecondCall.Fecha_Primera_Visualizacion__c,
      'La fecha no debería haber cambiado en la segunda llamada.'
    );
  }

  @isTest
  static void testGetDetails() {
    // --- PREPARACIÓN ---
    Requerimiento_de_Mejora__c req = [
      SELECT Id
      FROM Requerimiento_de_Mejora__c
      LIMIT 1
    ];

    // --- EJECUCIÓN ---
    Test.startTest();
    Requerimiento_de_Mejora__c result = fCL_RequerimientosDeMejora.getDetails(
      req.Id
    );
    Test.stopTest();

    // --- VERIFICACIÓN ---
    System.assertNotEquals(null, result, 'El resultado no debería ser nulo.');
    System.assertEquals(req.Id, result.Id, 'El Id del registro no coincide.');
    System.assertEquals(
      'Unidad de Prueba',
      result.Unidad_Responsable__r.Nombre_Collaboration_Group__c,
      'El nombre de la unidad relacionada no es correcto.'
    );
  }

  @isTest
  static void testGetCategoriaOptions() {
    // Consulta que trae TODOS los campos necesarios
    Grupos__c miGrupo = [
      SELECT Id, Id_Colaboration_Group__c
      FROM Grupos__c
      WHERE Nombre_Collaboration_Group__c = 'Unidad de Prueba'
      LIMIT 1
    ];
    // --- PREPARACIÓN ---
    // La data base ya tiene un requerimiento con categoría 'Tecnología' desde el @testSetup.
    // Creamos más datos para probar la agregación.
    Solicitud_de_Mejora__c solProceso = new Solicitud_de_Mejora__c(
      Titulo__c = 'S Proceso',
      Categoria_de_Mejora__c = 'Procesos'
    );
    insert solProceso;
    insert new Requerimiento_de_Mejora__c(
      Titulo__c = 'Req Proceso',
      Solicitud_de_Mejora__c = solProceso.Id,
      Prioridad__c = 'Media',
      Unidad_Responsable__c = miGrupo.Id
    );

    // --- EJECUCIÓN ---
    Test.startTest();
    List<String> categorias = fCL_RequerimientosDeMejora.getCategoriaOptions();
    Test.stopTest();

    // --- VERIFICACIÓN ---
    System.assertEquals(
      2,
      categorias.size(),
      'Debería haber 2 categorías únicas: Tecnología y Proceso.'
    );
    System.assert(
      categorias.contains('Tecnología'),
      'La lista debería contener "Tecnología".'
    );
  }

  @isTest
  static void testGetEstadoOptions() {
    // Consulta que trae TODOS los campos necesarios
    Grupos__c miGrupo = [
      SELECT Id, Id_Colaboration_Group__c
      FROM Grupos__c
      WHERE Nombre_Collaboration_Group__c = 'Unidad de Prueba'
      LIMIT 1
    ];
    // --- PREPARACIÓN ---
    // Ya existe un registro con estado 'Derivado'. Creamos otro.
    insert new Requerimiento_de_Mejora__c(
      Titulo__c = 'Req Revisado',
      Estado__c = 'Revisado',
      Solicitud_de_Mejora__c = [SELECT Id FROM Solicitud_de_Mejora__c LIMIT 1]
      .Id,
      Prioridad__c = 'Baja',
      Unidad_Responsable__c = miGrupo.Id
    );

    // --- EJECUCIÓN ---
    Test.startTest();
    List<String> estados = fCL_RequerimientosDeMejora.getEstadoOptions();
    Test.stopTest();

    // --- VERIFICACIÓN ---
    System.assertEquals(
      2,
      estados.size(),
      'Debería haber 2 estados únicos: Derivado y Revisado.'
    );
    System.assert(
      estados.contains('Derivado'),
      'La lista debería contener "Derivado".'
    );
  }

  @isTest
  static void testGetPrioridadOptions() {
    // Consulta que trae TODOS los campos necesarios
    Grupos__c miGrupo = [
      SELECT Id, Id_Colaboration_Group__c
      FROM Grupos__c
      WHERE Nombre_Collaboration_Group__c = 'Unidad de Prueba'
      LIMIT 1
    ];
    // --- PREPARACIÓN ---
    // Ya existe un registro con prioridad 'Alta'. Creamos otro.
    insert new Requerimiento_de_Mejora__c(
      Titulo__c = 'Req Media',
      Prioridad__c = 'Media',
      Solicitud_de_Mejora__c = [SELECT Id FROM Solicitud_de_Mejora__c LIMIT 1]
      .Id,
      Unidad_Responsable__c = miGrupo.Id
    );

    // --- EJECUCIÓN ---
    Test.startTest();
    List<String> prioridades = fCL_RequerimientosDeMejora.getPrioridadOptions();
    Test.stopTest();

    // --- VERIFICACIÓN ---
    System.assertEquals(
      2,
      prioridades.size(),
      'Debería haber 2 prioridades únicas: Alta y Media.'
    );
    System.assert(
      prioridades.contains('Alta'),
      'La lista debería contener "Alta".'
    );
  }
}