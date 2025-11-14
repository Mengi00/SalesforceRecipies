/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class trgAddParticipantesDeEncuestasTest {

    @isTest
    static void testParticipanteWithMatchingContact() {
        // Step 1: Create a mock Contact with RUT__c
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            RUT__c = 123456
        );
        insert contact;

        // Step 2: Create a Participante_de_Encuesta__c record with the same RUT__c
        Participante_de_Encuesta__c participante = new Participante_de_Encuesta__c(
            RUT__c = '123456',
            Carga_de_Participante_de_Encuesta_Id__c = 'a2Mal000003jETJEA2'
        );

        // Step 3: Insert the participant and verify trigger behavior
        Test.startTest();
        insert participante;
        Test.stopTest();

        // Step 4: Query the inserted participant
        Participante_de_Encuesta__c insertedParticipante = [
            SELECT Id, ContactId__c, Estado__c 
            FROM Participante_de_Encuesta__c 
            WHERE Id = :participante.Id
        ];

        // Step 5: Verify that the ContactId__c was assigned and Estado__c is 'Encontrado'
        System.assertEquals(contact.Id, insertedParticipante.ContactId__c, 'ContactId__c should be assigned.');
        System.assertEquals('Encontrado', insertedParticipante.Estado__c, 'Estado__c should be "Encontrado".');
    }

    @isTest
    static void testParticipanteWithoutMatchingContact() {
        // Step 1: Create a Participante_de_Encuesta__c record with a non-matching RUT__c
        Participante_de_Encuesta__c participante = new Participante_de_Encuesta__c(
            RUT__c = '999999', // No matching contact exists with this RUT__c
            Carga_de_Participante_de_Encuesta_Id__c = 'a2Mal000003jETJEA2'
        );

        // Step 2: Insert the participant and verify trigger behavior
        Test.startTest();
        insert participante;
        Test.stopTest();

        // Step 3: Query the inserted participant
        Participante_de_Encuesta__c insertedParticipante = [
            SELECT Id, ContactId__c, Estado__c 
            FROM Participante_de_Encuesta__c 
            WHERE Id = :participante.Id
        ];

        // Step 4: Verify that ContactId__c is null and Estado__c is 'No Encontrado'
        System.assertEquals(null, insertedParticipante.ContactId__c, 'ContactId__c should not be assigned.');
        System.assertEquals('No Encontrado', insertedParticipante.Estado__c, 'Estado__c should be "No Encontrado".');
    }

    
}