trigger EmailMessageTrigger on Email_Message__c (before insert, before update) {
//Este trigger requiere aplicar framework para que la logica este en un handler
    for (Email_Message__c email : Trigger.new) {
    
        if(email.Subject__c != null){
             email.Name__c = email.Subject__c.substring(0, Math.min(email.Subject__c.length(), 255));
        }
        
        if (email.ParentId__c != null) {
            email.RelatedToId__c = email.ParentId__c;
        }
        
        
        //Se requiere excluir esta ejecucion si no dispone de permiso para cambiar los audit field
        
        if (Trigger.isInsert && Trigger.isBefore) {
        
            if (email.CreatedDate__c != null) {
                email.CreatedDate = email.CreatedDate__c;
            }
        }
    }
}