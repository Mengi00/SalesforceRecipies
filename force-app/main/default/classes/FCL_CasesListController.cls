public with sharing class FCL_CasesListController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForUserGroups(Id userId) {      
        List<String> emails = new list<String>();
        List<User> email = [
            SELECT Email 
            FROM User 
            WHERE id = :userId
        ];
        for (User e : email) {
            emails.add(e.Email);
        }
        System.debug('emails: ' + emails);
        
        List<Id> usuarios = new list<Id>();
        List<User> getUsuario = [
            SELECT id 
            FROM User 
            WHERE Email = :emails
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

        List<Case> resultCases = [SELECT Id,cc_ap_AC__c,cc_ap_Tipo_de_Gestion__c, CaseNumber, Subject, Status, Fecha_de_Creacion_N__c,Nombre_Completo_Chile__c,cc_ap_Sub_rea_del_Requerimiento__c, FCL_Dias_faltantes_Semaforo__c, cc_ap_Origen_de_requerimiento__c,(SELECT Nombre_de_Grupo__c FROM Servicios_en_Caso__r)
                FROM Case 
                WHERE Id IN :caseIds and Status = 'Derivado'
                ];
        System.debug('resultCases: ' + resultCases);
        return resultCases;
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCasesForUserGroups(Id userId) {
        List<String> emails = new list<String>();
        List<User> email = [
            SELECT Email 
            FROM User 
            WHERE id = :userId 
        ];
        for (User e : email) {
            emails.add(e.Email);
        }
        System.debug('emails: ' + emails);
        
        List<Id> usuarios = new list<Id>();
        List<User> getUsuario = [
            SELECT id 
            FROM User 
            WHERE Email = :emails
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

        List<Case> caseList = [SELECT Id,cc_ap_AC__c,cc_ap_Tipo_de_Gestion__c, CaseNumber, Subject, Status,Fecha_de_Creacion_N__c,Nombre_Completo_Chile__c,cc_ap_Sub_rea_del_Requerimiento__c,cc_ap_Origen_de_requerimiento__c,FCL_Dias_faltantes_Semaforo__c, (SELECT Nombre_de_Grupo__c FROM Servicios_en_Caso__r)
                FROM Case
                WHERE Id IN :caseIds 
                ];

        System.debug('caseList: ' + caseList);
        return caseList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getEstadoOptions(){
    
    List<String> estados = new List<String>();
    // Solo trae los Status distintos de los casos con el tipo de registro deseado
    for (AggregateResult ar : [
        SELECT Status 
        FROM Case 
        WHERE RecordType.Name LIKE '%Servicio Paciente'
        GROUP BY Status
    ]) {
        String status = (String)ar.get('Status');
        if (status != null) {
            estados.add(status);
        }
    }
    return estados;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSubUnidadesPorUsuario(Id userId) {
        // Obtener los grupos del usuario
        Set<String> subUnidades = new Set<String>();
        List<Id> groupIds = new List<Id>();
        for (CollaborationGroupMember gm : [
            SELECT CollaborationGroupId, CollaborationGroup.Name 
            FROM CollaborationGroupMember 
            WHERE MemberId = :userId
            ]) {
        subUnidades.add(gm.CollaborationGroup.Name);
        }
        return new List<String>(subUnidades);
    }

}