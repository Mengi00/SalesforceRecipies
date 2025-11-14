@isTest
public class CVSReaderInvocableTest {

    @isTest
    static void testReadCSV_Success() {
        // Step 1: Create a mock ContentVersion record
        String csvData = 'Name;Email;RUT\nJohn Doe;john@example.com;123456;Radiologia\nJane Doe;jane@example.com;654321;Radiologia';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test CSV',
            VersionData = Blob.valueOf(csvData),
            PathOnClient = 'Prueba.csv'
        );
        insert contentVersion;

        // Step 2: Set up input parameters
        CVSReaderInvocable.InputParams input = new CVSReaderInvocable.InputParams();
        input.contentVersionIds = new List<Id>{ contentVersion.Id };
        input.firstLineAsHeader = true;
        input.rutColumnIndex = 2;
        input.tpdColumnIndex = 3;

        // Step 3: Invoke the method and assert the results
        Test.startTest();
        List<CVSReaderInvocable.OutputParams> result = 
            CVSReaderInvocable.readCSV(new List<CVSReaderInvocable.InputParams>{ input });
        Test.stopTest();

        // Step 4: Verify that the contacts were processed correctly
        System.assertEquals(1, result.size(), 'One output parameter should be returned.');
        System.assertEquals(2, result[0].contacts.size(), 'Two contacts should be processed.');

        System.assertEquals(123456, result[0].contacts[0].RUT__c, 'First contact RUT should match.');
        System.assertEquals(654321, result[0].contacts[1].RUT__c, 'Second contact RUT should match.');
    }

    @isTest
    static void testReadCSV_InvalidRUT() {
        // Step 1: Create a mock ContentVersion record with invalid RUT
        String csvData = 'Name;Email;RUT\nJohn Doe;john@example.com;invalidRUT';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test CSV with Invalid RUT',
            VersionData = Blob.valueOf(csvData),
            PathOnClient = 'Prueba.csv'
        );
        insert contentVersion;

        // Step 2: Set up input parameters
        CVSReaderInvocable.InputParams input = new CVSReaderInvocable.InputParams();
        input.contentVersionIds = new List<Id>{ contentVersion.Id };
        input.firstLineAsHeader = true;
        input.rutColumnIndex = 2;

        // Step 3: Invoke the method and assert the results
        Test.startTest();
        List<CVSReaderInvocable.OutputParams> result = 
            CVSReaderInvocable.readCSV(new List<CVSReaderInvocable.InputParams>{ input });
        Test.stopTest();

        // Step 4: Verify that the invalid RUT row was skipped
        System.assertEquals(1, result.size(), 'One output parameter should be returned.');
        System.assertEquals(0, result[0].contacts.size(), 'No contacts should be processed due to invalid RUT.');
    }

    
}