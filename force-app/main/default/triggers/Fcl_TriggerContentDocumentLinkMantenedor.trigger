trigger Fcl_TriggerContentDocumentLinkMantenedor on ContentDocumentLink (after insert) {
    // Obtener todos los ContentDocumentId del trigger
    Set<Id> contentDocIds = new Set<Id>();
    for (ContentDocumentLink cdl : Trigger.new) {
        contentDocIds.add(cdl.ContentDocumentId);
    }

    // Consultar los ContentDocumentLink relacionados
    List<ContentDocumentLink> relatedLinks = [
        SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
        FROM ContentDocumentLink 
        WHERE ContentDocumentId IN :contentDocIds
    ];

    // Obtener los LinkedEntityId que son casos
    Set<Id> caseIds = new Set<Id>();
    for (ContentDocumentLink link : relatedLinks) {
        if (link.ShareType == 'V' || link.Visibility != 'AllUsers') {
            caseIds.add(link.LinkedEntityId);
        }
    }

    // Obtener los casos con su tipo de registro
    Map<Id, String> caseRecordTypes = new Map<Id, String>();
    for (Case c : [
        SELECT Id, RecordType.Name 
        FROM Case 
        WHERE Id IN :caseIds
    ]) {
        caseRecordTypes.put(c.Id, c.RecordType.Name);
    }

    // Lista de ContentDocumentLink a actualizar
    List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();

    for (ContentDocumentLink link : relatedLinks) {
        if ((link.ShareType == 'I' || link.Visibility != 'AllUsers') &&
            caseRecordTypes.containsKey(link.LinkedEntityId) &&
            caseRecordTypes.get(link.LinkedEntityId) == 'Casos Clínica Servicio Paciente') {
            
            ContentDocumentLink updatedLink = link.clone(false, false, false, false);
            updatedLink.Id = link.Id;
            updatedLink.Visibility = 'AllUsers';
            updatedLink.ShareType = 'I';
            toUpdate.add(updatedLink);
        }
    }

    if (!toUpdate.isEmpty()) {
        try {
            update toUpdate;
        } catch (Exception e) {
            System.debug('Error actualizando ContentDocumentLink: ' + e.getMessage());
        }
    }
}