public with sharing class fCL_CasesChartView {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> obtenerDatosGrafico(Id userId) {
       
        //currentID
        Id currentUserId = UserInfo.getUserId();
        string eu =  [SELECT Email, Id FROM User WHERE Id =: currentUserId].Email;
        
        //listas de collaboration group en las que hace parte
        List<CollaborationGroupMember> collabgroupnameq =[select CollaborationGroup.Name from CollaborationGroupMember where Member.Email =:eu];
        
        //Lista string y for() Para cambiar de Id a String evitar errores
        List<String> collabgroupnames = new List<String>();
        for(CollaborationGroupMember cgm: collabgroupnameq){

            collabgroupnames.add(cgm.CollaborationGroup.Name);
        }
        //lista de servicios en caso, trae id casos
        list<Servicios_en_Caso__c> servncaso  = [select Caso__r.id FROM Servicios_en_Caso__c where Caso__r.Status ='Derivación' and Nombre_de_Grupo__c in :collabgroupnames ];
    
        List<string> casosid = new List<string>();        
        for (servicios_en_Caso__c senc : servncaso) {
            casosid.add(senc.caso__r.id);
        }
        
        // Obtener los casos asociados a los grupos del usuario
        
        List<Case> casos = [SELECT Id, cc_ap_Tipo_de_Gestion__c 
                            FROM Case 
                            WHERE Id IN :casosid];
        
        // Agrupar casos por tipo de gestión
        Map<String, Integer> casosPorTipo = new Map<String, Integer>();

        for (Case caso : casos) {
            String tipoGestion = caso.cc_ap_Tipo_de_Gestion__c;
            if (String.isNotBlank(tipoGestion)) {

                if (!casosPorTipo.containsKey(tipoGestion)) {
                    casosPorTipo.put(tipoGestion, 0);
                }
                casosPorTipo.put(tipoGestion, casosPorTipo.get(tipoGestion) + 1);
            }
        }
        
        // Preparar datos para el gráfico
        List<DatoGrafico> datosGrafico = new List<DatoGrafico>();
        for (String tipoGestion : casosPorTipo.keySet()) {
            datosGrafico.add(new DatoGrafico(tipoGestion, casosPorTipo.get(tipoGestion)));
        }
        
        // Preparar el resultado
        Map<String, Object> resultado = new Map<String, Object>();
        resultado.put('datosGrafico', datosGrafico);
        resultado.put('totalCasos', casos.size());
        
        System.debug(resultado);
        return resultado;

    }
    
    // Clase interna para representar los datos del gráfico
    public class DatoGrafico {
        @AuraEnabled public String tipoGestion { get; set; }
        @AuraEnabled public Integer cantidad { get; set; }
        
        public DatoGrafico(String tipoGestion, Integer cantidad) {
            this.tipoGestion = tipoGestion;
            this.cantidad = cantidad;
        }
    }
}