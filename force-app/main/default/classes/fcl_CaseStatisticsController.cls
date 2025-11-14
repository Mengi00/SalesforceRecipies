public with sharing class fcl_CaseStatisticsController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getCaseStatistics() {
        Map<String, Integer> statistics = new Map<String, Integer>();
        
        // ID de usuario actual
        Id currentUserId = UserInfo.getUserId();
        // Email de usuario
        string eu =  [SELECT Email, Id FROM User WHERE Id =: currentUserId].Email;
        // Lista de Grupos a los que petenece el usuario
        
        List<CollaborationGroupMember> collabgroupnameq =[select CollaborationGroup.Name from CollaborationGroupMember where Member.Email =:eu];
        

        //Lista string y for() Para cambiar de Id a String evitar errores
        List<String> collabgroupnames = new List<String>();
        for(CollaborationGroupMember cgm: collabgroupnameq){

            collabgroupnames.add(cgm.CollaborationGroup.Name);
        }
        List<Servicios_en_Caso__c> SecGet = [select Caso__r.id FROM Servicios_en_Caso__c where Caso__r.Status ='Derivación' and Nombre_de_Grupo__c in :CollabGroupnames ];
        List<String> CasosList = new List<String>();
        
        for (Servicios_en_Caso__c sc : SecGet) {
            if (CasosList.Contains(sc.Caso__r.Id)) {  
                System.System.debug('Caso Contado');             
            }
            else {
            CasosList.add(sc.Caso__r.Id);
            }
  
        }

        // Cantidad de casos asociados a los grupos del usuario
        Integer myCasesG = [select count() FROM Case where Status ='Derivación' and id in :CasosList ];
        

        String emailuser = [select Email From user where id = : currentUserId].Email;
        
        List<EmailMessage> emailmessages = [select id, toAddress, Parent.Id from EmailMessage where ToAddress =: emailuser and Parent.Status = 'Derivación' and Parent.id in :CasosList];
        List<String> DCase = new List<String>();
           for (EmailMessage em : emailmessages) {
            if (DCase.Contains(em.Parent.Id)) {  
                System.System.debug('Caso Contado');             
            }
            else {
            DCase.add(em.Parent.Id);
            }
  
        }

        Integer myCases = [select count() FROM Case where id in :DCase ];
        
        statistics.put('myCases', myCases);
        statistics.put('AreaCases', myCasesG);
        
        return statistics;
    }
}