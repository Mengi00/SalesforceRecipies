trigger FeedItemChangeServicioPaciente on FeedItem (after insert) {
    Set<Id> casoIdsToUpdate = new Set<Id>();
        
    // Llamada al manejador de notificaciones
    if (Trigger.isAfter && Trigger.isInsert) {
        FeedItemNotificationHandler.handleAfterInsert(Trigger.new);
    }


    for (FeedItem feed : Trigger.new) {
        if (feed.ParentId != null && feed.ParentId.getSObjectType() == Case.SObjectType) {
            casoIdsToUpdate.add(feed.ParentId);
        } 
    }

    if (!casoIdsToUpdate.isEmpty()) {
        List<Case> casosToUpdate = [SELECT Id, RecordType.Name, Status FROM Case WHERE Id IN :casoIdsToUpdate AND RecordType.Name = 'Casos Clínica Servicio Paciente'];

        for (Case caso : casosToUpdate) {
            if (caso.Status != 'Cerrado'){
            // Aquí verificamos que el caso tenga el RecordType correcto antes de actualizarlo.
            caso.Status = 'Elaboración de respuesta';

        
        }
	}
        update casosToUpdate;
    }
}