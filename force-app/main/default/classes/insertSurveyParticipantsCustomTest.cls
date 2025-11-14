@isTest
public class insertSurveyParticipantsCustomTest {
  
    @testSetup
    static void setupTestData() {
        // Create sample Contacts with RUT__c and FirstName fields populated.
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact contact = new Contact(
                LastName = 'TestLastName' + i,
                RUT__c = 123456 + i,
                FirstName = 'TestFirstName' + i
            );
            contacts.add(contact);
        }
        insert contacts;
// Cargo valores de prueba para una Survey, ya que no se puede generar un Mock de un registro de Survey
                        List<Survey> vSurvey = (List<Survey>) Test.loadData(
                            Survey.sObjectType, 'SurveyData'
                        );
                
                        Survey srv = [Select id from Survey limit 1];


    Cargas_de_Participantes_de_Encuestas__c carga  = new Cargas_de_Participantes_de_Encuestas__c();
         carga.Estado__c='Iniciado'  ;
         carga.SurveyId__c = srv.id;

         insert carga;


    }

    @isTest
    static void testInsertSurveyParticipants() {
        // Fetch test Contacts
        List<Contact> testContacts = [SELECT Id, RUT__c, FirstName FROM Contact LIMIT 200];
        Cargas_de_Participantes_de_Encuestas__c crg = [Select id from Cargas_de_Participantes_de_Encuestas__c limit 1];

        // Prepare input parameters
        insertSurveyParticipantsCustom.InputParams inputParams = new insertSurveyParticipantsCustom.InputParams();
        inputParams.RutList = testContacts;
        inputParams.CargaId = crg.id;

        // Execute the method
        Test.startTest();
        insertSurveyParticipantsCustom.insertSurveyParticipants(new List<insertSurveyParticipantsCustom.InputParams>{inputParams});
        Test.stopTest();

        // Verify that Participante_de_Encuesta__c records are created
        List<Participante_de_Encuesta__c> participants = [
            SELECT Id, Rut__c, Carga_de_Participante_de_Encuesta_Id__c, Tipo_De_Paciente__c 
            FROM Participante_de_Encuesta__c
            WHERE Carga_de_Participante_de_Encuesta_Id__c = :crg.id
        ];

        // Assert that the correct number of records were inserted
        System.assertEquals(2, participants.size(), 'Expected 2 Participante_de_Encuesta__c records to be created.');

        // Validate data fields
        for (Integer i = 0; i < 2; i++) {
            Participante_de_Encuesta__c participant = participants[i];
            System.assertEquals(String.valueOf(testContacts[i].RUT__c), participant.Rut__c, 'RUT__c should match Contact.RUT__c');
            System.assertEquals(crg.id, participant.Carga_de_Participante_de_Encuesta_Id__c, 'CargaId should match the input');
            System.assertEquals(testContacts[i].FirstName, participant.Tipo_De_Paciente__c, 'FirstName should match Contact.FirstName');
        }
    }
}