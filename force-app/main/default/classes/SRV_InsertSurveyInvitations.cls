public class SRV_InsertSurveyInvitations {
    public class InputParams {
        @invocableVariable(label='Lista de Invitaciones' required=true)
        public list<SurveyInvitation> Invitaciones;
    }

    @InvocableMethod(label='Insertar Invitaciones de Encuesta')
    public static void InsertSurveyInvitations(List<InputParams> inputs) {
        List<SurveyInvitation> invitaciones_OK = new List<SurveyInvitation>();
        List<Participante_de_Encuesta__c> participantes = new List<Participante_de_Encuesta__c>();


        for (InputParams input : inputs) {            
            for (SurveyInvitation invitacion : input.Invitaciones) {
                //Armo el participante a insertar
                Participante_de_Encuesta__c participante = new Participante_de_Encuesta__c();
                participante.id = invitacion.UUID; 
                System.debug('participante.id: ' + participante.id);             
               
                //Valido que tiene Community ID, si es as, queire decir que es un participanete Valido
                if (invitacion.CommunityId != null) {
                    invitaciones_OK.add(invitacion);
                    participante.Estado__c = 'Enviado';
                } else {
                    //En Caso de que no sea un participante Valido, obtengo el estado que viene del Flow de envio de invitaciones
                    participante.Estado__c = invitacion.name;
                }

                participantes.add(participante);
            }
        }

        // Crear una instancia de la clase batch Para la creacion de Invitaciones
        SRV_InsertSurveyInvitations_BACH batchJob = new SRV_InsertSurveyInvitations_BACH(invitaciones_OK);

        // Ejecutar el batch con un tamaño de lote de 100 registros por ejecución
        Database.executeBatch(batchJob, 100);    
        

        // Crear una instancia de la clase batch Para la actualizacion del estado de los Participantes
        SRV_UpdParticipantesEncuesta_BACH batchJob2 = new SRV_UpdParticipantesEncuesta_BACH(participantes);
        
        // Ejecutar el batch con un tamaño de lote de 100 registros por ejecución
        Database.executeBatch(batchJob2, 100);
    
      }

      
}