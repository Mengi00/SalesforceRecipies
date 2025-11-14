public with sharing class CasosListController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForUserGroups(Id userId) {
        
        List<Id> emails = new list<Id>();
        List<User> email = [
            SELECT SenderEmail 
            FROM User 
            WHERE id = :userId
        ];
        for (User e : email) {
            emails.add(e.SenderEmail);
        }
        System.debug('emails: ' + emails);
        
        List<Id> usuarios = new list<Id>();
        List<User> getUsuario = [
            SELECT id 
            FROM User 
            WHERE SenderEmail = :emails
        ];
        
        
        for (User u : getUsuario ) {
            usuarios.add(u.Id);
        }
        System.debug('usuarios: ' + usuarios);
        
        List<Id> groupIds = new List<Id>();
        List<CollaborationGroupMember> groupMembers = [
            SELECT CollaborationGroupId 
            FROM CollaborationGroupMember 
            WHERE MemberId = :usuarios
        ];
        for (CollaborationGroupMember gm : groupMembers) {
            groupIds.add(gm.CollaborationGroupId);
        }
        
        System.debug('groupIds: ' + groupIds);
        
        List<Id> caseIds = new List<Id>();
        List<Servicios_en_Caso__c> serviceCases = [
            SELECT Caso__c 
            FROM Servicios_en_Caso__c 
            WHERE Grupo__c IN :groupIds
        ];
        for (Servicios_en_Caso__c sc : serviceCases) {
            caseIds.add(sc.Caso__c);
        }
        System.debug('caseIds: ' + caseIds);
        
        return [SELECT Id,cc_ap_AC__c,cc_ap_Tipo_de_Gestion__c, CaseNumber, Subject, cc_ap_Estados__c,CreatedDate,Nombre_Completo_Chile__c
                FROM Case  
                WHERE Id IN :caseIds and cc_ap_Estados__c = 'Derivación'];
    }
}