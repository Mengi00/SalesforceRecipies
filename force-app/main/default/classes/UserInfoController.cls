public with sharing class UserInfoController {
    @AuraEnabled(cacheable=true)
    public static UserInfo getUserInfo(Id userId) { 
        // Consulta SOQL para obtener el nombre del grupo al que pertenece el usuario con el ID proporcionado.
        List<CollaborationGroupMember> groupMembers = [SELECT CollaborationGroup.Name FROM CollaborationGroupMember WHERE Member.id = :userId];
        System.debug('groupMembers: ' + groupMembers);

        // Se crea un conjunto para almacenar los nombres de las subunidades.
        Set<String> subunitNames = new Set<String>();
    

        // Se valida si el usuario pertenece a algún grupo.
        if(!groupMembers.isEmpty()) {
        // Se recorren los grupos a los que pertenece el usuario.
            for (CollaborationGroupMember groupMember : groupMembers) {
                // Agregar el nombre del grupo al conjunto.
                subunitNames.add(groupMember.CollaborationGroup.Name);
            }
        }
        System.debug('subunitNames: ' + subunitNames);
        // Se obtiene el mapeo de las subunidades a las unidades.
        Map<String, String> subunitToUnitMap = getSubunitToUnitMapping();

        // Se crea un conjunto para almacenar los nombres de las unidades.
        Set<String> unitNames = new Set<String>();
        for(String subunit : subunitNames){
            if(subunitToUnitMap.containsKey(subunit)){
                unitNames.add(subunitToUnitMap.get(subunit));
            }
        }
        System.debug('unitNames: ' + unitNames);
        // Consulta SOQL para obtener el nombre y departamento del usuario con el ID.
        User user = [SELECT Name, Department FROM User WHERE Id = :userId LIMIT 1];

        // Se retorna un objeto UserInfo con los valores obtenidos.
        return new UserInfo(user.Name, user.Department, new List<String>(subunitNames), new List<String>(unitNames));
    }

    public static Map<String, String> getSubunitToUnitMapping(){
        // Se crea un mapeo de subunidades a unidades.
        Map<String, String> subunitToUnit = new Map<String, String>();
        
       // Consulta SOQL para obtener las subunidades y unidades de los casos.
        for(Case c: [ SELECT cc_ap_Origen_de_requerimiento__c, cc_ap_Sub_rea_del_Requerimiento__c 
        FROM Case 
        WHERE cc_ap_Origen_de_requerimiento__c != null 
        AND cc_ap_Sub_rea_del_Requerimiento__c != null]){
            subunitToUnit.put(c.cc_ap_Sub_rea_del_Requerimiento__c, c.cc_ap_Origen_de_requerimiento__c);
        }
        System.debug('subunitToUnit: ' + subunitToUnit);
        return subunitToUnit;
    }

    public class UserInfo {
        // Se habilitan los atributos para ser accesibles desde LWC o Aura.
        @AuraEnabled public String name;
        @AuraEnabled public String department;
        @AuraEnabled public List<String> subunitNames;
        @AuraEnabled public List<String> unitNames;

        // Constructor que inicializa los atributos con los valores obtenidos del usuario.
        public UserInfo(String name, String department, List<String> subunitNames, List<String> unitNames) {
            this.name = name;
            this.department = department;
            this.subunitNames = subunitNames;
            this.unitNames = unitNames;
        }
    } 
}