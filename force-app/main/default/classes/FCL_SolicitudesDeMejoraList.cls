public with sharing class FCL_SolicitudesDeMejoraList {
  @AuraEnabled(cacheable=true)
  public static List<Solicitud_de_Mejora__c> getSolicitudesCreadasPorUsuarioActual() {
    // Obtener el Id del usuario actual
    Id userId = UserInfo.getUserId();
    // Validación inicial: si no hay userId, retorna una lista vacía
    if (userId == null) {
      return new List<Solicitud_de_Mejora__c>();
    }
    // Consulta para obtener las solicitudes creadas por el usuario actual
    System.debug('userId: ' + userId);
    List<Solicitud_de_Mejora__c> solicitudes = [
      SELECT
        Id,
        Name,
        Titulo__c,
        Estado__c,
        Categoria_de_Mejora__c,
        CreatedDate,
        CreatedById,
        Usuario_Solicitante__c
      FROM Solicitud_de_Mejora__c
      WHERE
        (Usuario_Solicitante__c = NULL
        AND CreatedById = :userId)
        OR Usuario_Solicitante__c = :userId
      ORDER BY CreatedDate DESC
    ];
    System.debug('solicitudes: ' + solicitudes);
    return solicitudes;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getCategoriaOptions() {
    List<String> categorias = new List<String>();
    // Solo trae las Categorias distintas de las solicitudes
    for (AggregateResult ar : [
      SELECT Categoria_de_Mejora__c
      FROM Solicitud_de_Mejora__c
      GROUP BY Categoria_de_Mejora__c
    ]) {
      String categoria = (String) ar.get('Categoria_de_Mejora__c');
      if (categoria != null) {
        categorias.add(categoria);
      }
    }
    return categorias;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> getEstadoOptions() {
    List<String> estados = new List<String>();
    // Solo trae los Estados distintos de las solicitudes
    for (AggregateResult ar : [
      SELECT Estado__c
      FROM Solicitud_de_Mejora__c
      GROUP BY Estado__c
    ]) {
      String estado = (String) ar.get('Estado__c');
      if (estado != null) {
        estados.add(estado);
      }
    }
    return estados;
  }

  // Metodo para crear el nuevo registro de Solicitud de Mejora
  @AuraEnabled
  public static Solicitud_de_Mejora__c createSolicitud(
    String titulo,
    String descripcion,
    String categoria,
    String propuesta,
    Id unidadResponsablePropuesta
  ) {
    try {
      // Creamos el nuevo registro de Solicitud de Mejora
      Solicitud_de_Mejora__c nuevaSolicitud = new Solicitud_de_Mejora__c();

      nuevaSolicitud.Titulo__c = titulo;
      nuevaSolicitud.Descripci_n__c = descripcion;
      nuevaSolicitud.Categoria_de_Mejora__c = categoria;
      nuevaSolicitud.Propuesta_de_Mejora__c = propuesta;
      nuevaSolicitud.Unidad_Responsable__c = unidadResponsablePropuesta;

      System.debug('Valores antes de insert: ' + nuevaSolicitud);
      insert nuevaSolicitud;

      System.debug('nuevaSolicitud creada: ' + nuevaSolicitud);
      return nuevaSolicitud;
    } catch (Exception e) {
      System.debug('Error al crear la solicitud: ' + e.getMessage());
      throw new AuraHandledException(
        'Error al crear la solicitud: ' + e.getMessage()
      );
    }
  }
}