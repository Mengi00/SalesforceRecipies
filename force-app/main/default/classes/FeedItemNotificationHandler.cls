public class FeedItemNotificationHandler {
    
    // Cache estático para evitar queries repetidas
    private static CustomNotificationType notificationType;
    private static List<User> ejecutivosCache;
    
    public static void handleAfterInsert(List<FeedItem> newFeedItems) {
        // Obtener el ID del tipo de registro
        Id casoClinicaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('cc_ap_rt').getRecordTypeId();
        
        // Recolectar IDs de casos para consultar
        Set<Id> caseIds = new Set<Id>();
        for (FeedItem fi : newFeedItems) {
            // Verificar si el FeedItem es de un Caso (ParentId empieza con '500')
            if (fi.ParentId != null && String.valueOf(fi.ParentId).startsWith('500')) {
                caseIds.add(fi.ParentId);
            }
        }
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        // Consultar los casos con el tipo de registro específico
        Map<Id, Case> casosClinica = new Map<Id, Case>([
            SELECT Id, RecordTypeId, CaseNumber, Subject, OwnerId, Owner.Name
            FROM Case
            WHERE Id IN :caseIds 
            AND RecordTypeId = :casoClinicaRecordTypeId and Status = 'Cerrado'
        ]);
        
        if (casosClinica.isEmpty()) {
            return;
        }
        
        // Obtener ejecutivos una sola vez
        List<User> ejecutivosServicio = getEjecutivosServicio();
        
        if (ejecutivosServicio.isEmpty()) {
            System.debug('No se encontraron ejecutivos activos para notificar');
            return;
        }
        
        // Obtener tipo de notificación una sola vez
        CustomNotificationType notifType = getNotificationType();
        
        if (notifType == null) {
            System.debug('No se encontró el tipo de notificación configurado');
            return;
        }
        
        // List<CustomNotification> notifications = new List<CustomNotification>();
        
        // Procesar notificaciones
        for (FeedItem fi : newFeedItems) {
            if (casosClinica.containsKey(fi.ParentId)) {
                Case casoActual = casosClinica.get(fi.ParentId);
                sendCustomNotification(fi, casoActual, ejecutivosServicio, notifType);
            }
        }
    }
    
    /**
     * Obtiene los ejecutivos de servicio (con cache para evitar múltiples queries)
     */
    private static List<User> getEjecutivosServicio() {
        if (ejecutivosCache == null) {
            ejecutivosCache = [
                SELECT Id, Name, Email, UserRole.Name
                FROM User
                WHERE UserRole.Name IN ('Ejecutivo Atención Paciente', 'Jefe de Atencion Paciente')
                AND IsActive = true
            ];
        }
        return ejecutivosCache;
    }
    
    /**
     * Obtiene el tipo de notificación (con cache para evitar múltiples queries)
     */
    private static CustomNotificationType getNotificationType() {
        if (notificationType == null) {
            List<CustomNotificationType> notificationTypes = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType 
                LIMIT 1
            ];
            
            if (!notificationTypes.isEmpty()) {
                notificationType = notificationTypes[0];
            }
        }
        return notificationType;
    }
    
    /**
     * Envía la notificación personalizada
     */
    private static void sendCustomNotification(
        FeedItem feedItem, 
        Case caso, 
        List<User> usuarios,
        CustomNotificationType notifType
    ) {
        try {
            // Crear y configurar la notificación
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            // Título más descriptivo
            String title = 'Nuevo comentario en Caso Clínica #' + caso.CaseNumber;
            
            // Cuerpo con más información
            String body = String.format(
                'Usuario {0} agregó un comentario en el caso: {1}',
                new List<String>{
                    UserInfo.getName(),
                    caso.Subject != null ? caso.Subject : 'Sin asunto'
                }
            );
            
            // Limitar longitud del body si es necesario (máximo 750 caracteres)
            if (body.length() > 750) {
                body = body.substring(0, 747) + '...';
            }
            
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notifType.Id);
            notification.setTargetId(caso.Id);
            
            // Agregar destinatarios
            Set<String> recipientIds = new Set<String>();
            for (User u : usuarios) {
                recipientIds.add(u.Id);
            }
            
            // Enviar solo si hay destinatarios
            if (!recipientIds.isEmpty()) {
                notification.send(recipientIds);
                System.debug('Notificación enviada a ' + recipientIds.size() + ' usuarios para caso ' + caso.CaseNumber);
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error enviando notificación: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            // No lanzar la excepción para no interrumpir el proceso
        }
    }
}