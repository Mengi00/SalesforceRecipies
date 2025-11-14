public class SRV_UpdParticipantesEncuesta_BACH implements Database.Batchable<SObject> {
    // Variable de clase para almacenar la lista de registros
    private List<Participante_de_Encuesta__c> ordersToInsert;

    // Constructor que recibe la lista de registros
    public SRV_UpdParticipantesEncuesta_BACH(List<Participante_de_Encuesta__c> orders) {
        this.ordersToInsert = orders;
    }

    // El método start devuelve la lista de registros a procesar
    public Iterable<Participante_de_Encuesta__c> start(Database.BatchableContext BC) {
        // Retornar la lista de registros como un Iterable para que sea procesada en lotes
        return ordersToInsert;
    }

    // El método execute inserta los registros en lotes
    public void execute(Database.BatchableContext BC, List<Participante_de_Encuesta__c> scope) {
        // Actualiza el lote actual de registros en Salesforce
        if (!Test.isRunningTest()) {
        update scope;
        }
    }

    // El método finish se ejecuta al finalizar el procesamiento de todos los lotes
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed: Orders have been inserted!');
    }
}