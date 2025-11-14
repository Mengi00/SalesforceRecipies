public with sharing class SolicitudDeMejoraController {
    
 public class FormData {
        @AuraEnabled
        public String Titulo { get; set; }
        @AuraEnabled
        public String TipoMejora { get; set; }
        @AuraEnabled
        public String Mejora { get; set; }
        @AuraEnabled
        public String Descripcion { get; set; }
        @AuraEnabled
        public String UnidadR { get; set; }
    }

    @AuraEnabled
    public static String createSolicitudDeMejora(FormData formData) {
        try {
            Solicitud_de_Mejora__c nuevaSolicitud = new Solicitud_de_Mejora__c(
                Titulo__c = formData.Titulo,//Titulo__c
                Categoria_de_Mejora__c = formData.TipoMejora, //Categoria_de_Mejora__c
                Descripci_n__c = formData.Descripcion,//Descripci_n__c
                Unidad_Responsable__c = formData.UnidadR ,//Unidad_Responsable__c
                Estado__c = 'Derivado' //Estado__c
            );
        
            insert nuevaSolicitud;
            
            return nuevaSolicitud.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al crear la solicitud: ' + e.getMessage());
        }
    }


}