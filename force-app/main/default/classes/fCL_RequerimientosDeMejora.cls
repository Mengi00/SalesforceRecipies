public with sharing class fCL_RequerimientosDeMejora {
  @AuraEnabled(cacheable=true)
  public static List<Requerimiento_de_Mejora__c> getRequerimientosByResponble() {
    // Obtener el Id del usuario actual.
    // Se utiliza UserInfo.getUserId() para obtener el Id del usuario que está ejecutando la consulta.
    Id userId = UserInfo.getUserId();

    // Validación inicial: si no hay userId, no hay nada que hacer.
    if (userId == null) {
      return new List<Requerimiento_de_Mejora__c>();
    }
    System.debug('UserId recibido: ' + userId);

    List<Requerimiento_de_Mejora__c> resultadoRequerimientos = [
      SELECT
        Id,
        Name,
        Titulo__c,
        Estado__c,
        Categoria_de_Mejora__c,
        CreatedDate,
        Prioridad__c
      FROM Requerimiento_de_Mejora__c
      WHERE
        Unidad_Responsable__r.Usuario_Responsable__c = :userId // devuelve una lista de requerimientos donde el usuario actual es el responsable de la unidad
        AND Estado__c = 'Derivado' // filtra los requerimientos que no han sido viistos
      ORDER BY CreatedDate DESC
    ];

    System.debug('resultadoRequerimientos: ' + resultadoRequerimientos);
    return resultadoRequerimientos;
  }

  // --- MÉTODO 1: Registra la primera vista (Realiza una actualización) ---
  // No es 'cacheable' porque realiza una operación de escritura en la base de datos (DML).
  @AuraEnabled(cacheable=false)
  public static void markAsViewed(Id recordId) {
    // Primero, buscamos el registro para ver si ya ha sido visto.
    // Esto evita actualizaciones innecesarias en cada carga de la página.
    List<Requerimiento_de_Mejora__c> requerimientos = [
      SELECT Id, Fecha_Primera_Visualizacion__c
      FROM Requerimiento_de_Mejora__c
      WHERE Id = :recordId AND Fecha_Primera_Visualizacion__c = NULL
      LIMIT 1
    ];

    // Si la lista no está vacía, significa que encontramos el registro Y que su fecha de vista es nula.
    if (!requerimientos.isEmpty()) {
      Requerimiento_de_Mejora__c reqToUpdate = requerimientos[0];
      reqToUpdate.Fecha_Primera_Visualizacion__c = System.now();

      // Realizamos la actualización
      update reqToUpdate;
    }
  }

  // --- MÉTODO 2: Obtiene los detalles para mostrar (Solo lectura) ---
  // Es 'cacheable' para que sea muy rápido y eficiente.
  @AuraEnabled(cacheable=true)
  public static Requerimiento_de_Mejora__c getDetails(Id recordId) {
    System.debug('Id de usuario: ' + UserInfo.getUserId());
    System.debug('getDetails llamado con recordId: ' + recordId);
    Requerimiento_de_Mejora__c req;
    try {
      req = [
        SELECT
          Id,
          Name,
          Titulo__c,
          Descripcion_requerimiento__c,
          Prioridad__c,
          Categoria_de_Mejora__c,
          Fecha_de_Derivacion__c,
          Fecha_de_Revision__c,
          Unidad_Responsable__r.Nombre_Collaboration_Group__c,
          Solicitud_de_Mejora__r.Name
        FROM Requerimiento_de_Mejora__c
        WHERE Id = :recordId
        LIMIT 1
      ];
      System.debug('Registro encontrado: ' + req);
    } catch (Exception e) {
      System.debug('Error en getDetails: ' + e.getMessage());
      throw new AuraHandledException(
        'No se pudo obtener el detalle: ' + e.getMessage()
      );
    }
    return req;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getCategoriaOptions() {
    List<String> categorias = new List<String>();
    // Agrupa por el campo fuente en el objeto relacionado
    for (AggregateResult ar : [
      SELECT Solicitud_de_Mejora__r.Categoria_de_Mejora__c cat
      FROM Requerimiento_de_Mejora__c
      WHERE Solicitud_de_Mejora__r.Categoria_de_Mejora__c != NULL
      GROUP BY Solicitud_de_Mejora__r.Categoria_de_Mejora__c
    ]) {
      String categoria = (String) ar.get('cat');
      if (categoria != null) {
        categorias.add(categoria);
      }
    }
    return categorias;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getEstadoOptions() {
    List<String> estados = new List<String>();
    // Solo trae los Estados distintos de los Requerimientos
    for (AggregateResult ar : [
      SELECT Estado__c
      FROM Requerimiento_de_Mejora__c
      GROUP BY Estado__c
    ]) {
      String estado = (String) ar.get('Estado__c');
      if (estado != null) {
        estados.add(estado);
      }
    }
    return estados;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getPrioridadOptions() {
    List<String> prioridades = new List<String>();
    // Solo trae las Prioridades distintas de los Requerimientos
    for (AggregateResult ar : [
      SELECT prioridad__c
      FROM Requerimiento_de_Mejora__c
      GROUP BY prioridad__c
    ]) {
      String prioridad = (String) ar.get('Prioridad__c');
      if (prioridad != null) {
        prioridades.add(prioridad);
      }
    }
    return prioridades;
  }
}