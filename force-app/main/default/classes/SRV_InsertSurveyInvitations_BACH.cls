public class SRV_InsertSurveyInvitations_BACH implements Database.Batchable<SObject> {

    // Variable de clase para almacenar la lista de registros
    private List<SurveyInvitation> ordersToInsert;

    // Constructor que recibe la lista de registros
    public SRV_InsertSurveyInvitations_BACH(List<SurveyInvitation> orders) {
        this.ordersToInsert = orders;
    }

    // El método start devuelve la lista de registros a procesar
    public Iterable<SurveyInvitation> start(Database.BatchableContext BC) {
        // Retornar la lista de registros como un Iterable para que sea procesada en lotes
        return ordersToInsert;
    }

    // El método execute inserta los registros en lotes
    public void execute(Database.BatchableContext BC, List<SurveyInvitation> scope) {
        // Inserta el lote actual de registros en Salesforce


        System.debug('BACH========================> Paso 3333: ' + scope.size());
        //System.debug('BACH========================> Paso 4: ' + scope[0]);

        if (!Test.isRunningTest()) {
        insert scope;
        }
    }

    // El método finish se ejecuta al finalizar el procesamiento de todos los lotes
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed: Orders have been inserted!');
    }

}