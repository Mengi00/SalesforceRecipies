trigger FeedCommentChangeServicioPaciente on FeedComment(after insert) {
    Set<Id> setFeedId = new Set<Id>();
    Set<Id> casoIdsToUpdate = new Set<Id>();

    for (FeedComment feed : Trigger.new) {
        if (feed.ParentId != null && feed.ParentId.getSObjectType() == Case.SObjectType) {
            setFeedId.add(feed.FeedItemId);
        } 
    }
  Map<Id,FeedItem> map_Feed = new  Map<Id,FeedItem>([Select Id, ParentId, Type From FeedItem Where Id =: setFeedId]);
    
    for (FeedComment feed : Trigger.new) {
        if (feed.ParentId != null && feed.ParentId.getSObjectType() == Case.SObjectType && map_Feed.containsKey(feed.FeedItemId) && map_Feed.get(feed.FeedItemId).Type == 'TextPost' ) {
            casoIdsToUpdate.add(feed.ParentId);
        } 
    }
    
    if (!casoIdsToUpdate.isEmpty()) {
        List<Case> casosToUpdate = [SELECT Id, RecordType.Name, Status FROM Case WHERE Id IN :casoIdsToUpdate AND  RecordType.Name = 'Casos Clínica Servicio Paciente'];
        
        
            for (Case caso : casosToUpdate) {
            // Aquí verificamos que el caso tenga el RecordType correcto antes de actualizarlo.
                if (caso.Status != 'Cerrado'){
            caso.Status = 'Elaboración de respuesta';
        }}
        update casosToUpdate;
}
}