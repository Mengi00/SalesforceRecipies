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
public class SRV_UpdParticipantesEncuesta_BACHTest {
/*
    @isTest
    static void testBatchExecution_Success() {
        // Step 1: Create mock Participante_de_Encuesta__c records to update
        List<Participante_de_Encuesta__c> participantesList = new List<Participante_de_Encuesta__c>();

        for (Integer i = 0; i < 2; i++) {
            Participante_de_Encuesta__c participante = new Participante_de_Encuesta__c();
            participante.Carga_de_Participante_de_Encuesta_Id__c ='a2OWe000001GxOXMA0';
            participante.Rut__c ='1234567';
            participante.Estado__c = 'No Encontrado';
            participantesList.add(participante);
        }
        // Insert the initial records
        insert participantesList;

        // Step 2: Modify the Estado__c field for update
        for (Participante_de_Encuesta__c participante : participantesList) {
            participante.Estado__c = 'Encontrado';
        }

        // Step 3: Start the test and execute the batch job
        Test.startTest();
        SRV_UpdParticipantesEncuesta_BACH batchJob = new SRV_UpdParticipantesEncuesta_BACH(participantesList);
        Database.executeBatch(batchJob, 2);  // Set batch size to 2
        Test.stopTest();

        // Step 4: Query the updated records and verify the changes
        List<Participante_de_Encuesta__c> updatedParticipantes = [
            SELECT Id, Name, Estado__c FROM Participante_de_Encuesta__c
        ];

        System.assertEquals(2, updatedParticipantes.size(), 'Two participants should be updated.');
        for (Participante_de_Encuesta__c participante : updatedParticipantes) {
            System.assertEquals('Encontrado', participante.Estado__c, 'Estado__c should be "Encontrado".');
        }
    }*/

    @isTest
    static void testBatchExecution_EmptyList() {
        // Step 1: Create an empty list of Participante_de_Encuesta__c
        List<Participante_de_Encuesta__c> emptyList = new List<Participante_de_Encuesta__c>();

        // Step 2: Start the test and execute the batch job
        Test.startTest();
        SRV_UpdParticipantesEncuesta_BACH batchJob = new SRV_UpdParticipantesEncuesta_BACH(emptyList);
        Database.executeBatch(batchJob, 1);  // Batch size 1 to handle empty list
        Test.stopTest();

        // Step 3: Verify that no records were updated
        List<Participante_de_Encuesta__c> updatedParticipantes = [
            SELECT Id FROM Participante_de_Encuesta__c
        ];
        System.assertEquals(0, updatedParticipantes.size(), 'No participants should be updated.');
    }
}