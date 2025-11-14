@isTest
public class SRV_InsertSurveyInvitations_BACHTest {

  /*  @isTest
    static void testBatchExecution_Success() {
        // Create a valid Survey record to use its ID in the SurveyInvitation
       

        // Create a list with exactly two SurveyInvitation records to match the batch size
        List<SurveyInvitation> invitationsList = new List<SurveyInvitation>();
        for (Integer i = 0; i < 2; i++) {
            SurveyInvitation invitation = new SurveyInvitation();
            
            invitation.CommunityId = '0DBal000000exsbGAA'; 
            invitation.Name = 'Test Invitation ' + i;
            invitation.SurveyId = '0KdWe00000005PVKAY';
            invitationsList.add(invitation);
        }

        // Start the test and execute the batch job
        Test.startTest();
        SRV_InsertSurveyInvitations_BACH batchJob = new SRV_InsertSurveyInvitations_BACH(invitationsList);
        
        // Ensure batch size matches the number of records to trigger only one execute call
        Database.executeBatch(batchJob, 2); 
        Test.stopTest();

        // Verify that the records were inserted correctly
        List<SurveyInvitation> insertedInvitations = [SELECT Id, Name, UUID, CommunityId FROM SurveyInvitation];

        System.assertEquals(2, insertedInvitations.size(), 'Two invitations should be inserted.');

        for (Integer i = 0; i < 2; i++) {
            System.assertEquals('Test Invitation ' + i, insertedInvitations[i].Name, 'Invitation name mismatch.');
         
        }
    }*/

    @isTest
    static void testBatchExecution_EmptyList() {
        // Execute the batch with an empty list of invitations
        List<SurveyInvitation> emptyList = new List<SurveyInvitation>();

        Test.startTest();
        SRV_InsertSurveyInvitations_BACH batchJob = new SRV_InsertSurveyInvitations_BACH(emptyList);
        Database.executeBatch(batchJob, 1); // Batch size 1 to handle empty list gracefully
        Test.stopTest();

        // Verify that no records were inserted
        List<SurveyInvitation> insertedInvitations = [SELECT Id FROM SurveyInvitation];
        System.assertEquals(0, insertedInvitations.size(), 'No invitations should be inserted.');
    }
}