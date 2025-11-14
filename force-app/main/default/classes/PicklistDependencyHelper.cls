public class PicklistDependencyHelper {

    public static Map<String, List<String>> obtenerDependenciasUnidadSubUnidad() {
        // Definir los nombres de los campos
        String campoControlador = 'cc_ap_Origen_de_requerimiento__c';  // ← CAMBIA por tu campo controlador
        String campoDependiente = 'cc_ap_Sub_rea_del_Requerimiento__c'; // ← CAMBIA por tu campo dependiente

        // Describe de los campos
        Schema.DescribeFieldResult descCtrl = Schema.SObjectType.Case.fields.getMap().get(campoControlador).getDescribe();
        Schema.DescribeFieldResult descDep = Schema.SObjectType.Case.fields.getMap().get(campoDependiente).getDescribe();
        
        List<Schema.PicklistEntry> valoresCtrl = descCtrl.getPicklistValues();
        List<Schema.PicklistEntry> valoresDep = descDep.getPicklistValues();

        // Mapa resultado
        Map<String, List<String>> mapaDependencias = new Map<String, List<String>>();
        
        // Alfabeto Base64
        String base64Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

        // Mapear dependencias
        for (Schema.PicklistEntry valDep : valoresDep) {
            // Obtener el 'validFor' serializando el PicklistEntry
            String validForStr = (String)((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(valDep))).get('validFor');
            if (String.isBlank(validForStr)) {
                continue;
            }

            // Decodificar Base64
            List<String> chars = validForStr.split('');
            Integer totalCtrlVals = valoresCtrl.size();
            
            for (Integer i = 0; i < totalCtrlVals; i++) {
                Integer charIndex = i / 6; // Cada caracter codifica 6 bits
                Integer bitPosition = 5 - Math.mod(i, 6);
                
                Integer charValue = base64Alphabet.indexOf(chars[charIndex]);
                Integer mask = 1 << bitPosition;
                
                Boolean bitActivo = (charValue & mask) != 0;
                if (bitActivo) {
                    String valorControlador = valoresCtrl[i].getValue();
                    String valorDependiente = valDep.getValue();
                    
                    if (!mapaDependencias.containsKey(valorControlador)) {
                        mapaDependencias.put(valorControlador, new List<String>());
                    }
                    mapaDependencias.get(valorControlador).add(valorDependiente);
                }
            }
        }
        
        return mapaDependencias;
    }
        public static Map<String, List<String>> obtenerDependenciasGerenciaUnidad() {
        // Definir los nombres de los campos
        String campoControlador = 'Gerencia__c';  // ← CAMBIA por tu campo controlador
        String campoDependiente = 'cc_ap_Origen_de_requerimiento__c'; // ← CAMBIA por tu campo dependiente

        // Describe de los campos
        Schema.DescribeFieldResult descCtrl = Schema.SObjectType.Servicios_en_Caso__c.fields.getMap().get(campoControlador).getDescribe();
        Schema.DescribeFieldResult descDep = Schema.SObjectType.Servicios_en_Caso__c.fields.getMap().get(campoDependiente).getDescribe();
        
        List<Schema.PicklistEntry> valoresCtrl = descCtrl.getPicklistValues();
        List<Schema.PicklistEntry> valoresDep = descDep.getPicklistValues();

        // Mapa resultado
        Map<String, List<String>> mapaDependencias = new Map<String, List<String>>();
        
        // Alfabeto Base64
        String base64Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

        // Mapear dependencias
        for (Schema.PicklistEntry valDep : valoresDep) {
            // Obtener el 'validFor' serializando el PicklistEntry
            String validForStr = (String)((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(valDep))).get('validFor');
            if (String.isBlank(validForStr)) {
                continue;
            }

            // Decodificar Base64
            List<String> chars = validForStr.split('');
            Integer totalCtrlVals = valoresCtrl.size();
            
            for (Integer i = 0; i < totalCtrlVals; i++) {
                Integer charIndex = i / 6; // Cada caracter codifica 6 bits
                Integer bitPosition = 5 - Math.mod(i, 6);
                
                Integer charValue = base64Alphabet.indexOf(chars[charIndex]);
                Integer mask = 1 << bitPosition;
                
                Boolean bitActivo = (charValue & mask) != 0;
                if (bitActivo) {
                    String valorControlador = valoresCtrl[i].getValue();
                    String valorDependiente = valDep.getValue();
                    
                    if (!mapaDependencias.containsKey(valorControlador)) {
                        mapaDependencias.put(valorControlador, new List<String>());
                    }
                    mapaDependencias.get(valorControlador).add(valorDependiente);
                }
            }
        }
        System.debug('Mapa de dependencias: ' + mapaDependencias);
        return mapaDependencias;
    }
}