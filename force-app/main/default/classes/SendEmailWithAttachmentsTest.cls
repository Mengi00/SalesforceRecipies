@IsTest
public class SendEmailWithAttachmentsTest {

    @TestSetup
    static void setupTestData() {
        // Crear un ContentDocument y su ContentVersion para la prueba
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true
        );
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
    }

    @IsTest
    static void testSendEmailWithAttachments() {
        // Obtener el ContentDocumentId para la prueba
        ContentVersion contentVersion = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];

        // Crear una solicitud de email
        SendEmailWithAttachments.EmailRequest emailRequest = new SendEmailWithAttachments.EmailRequest();
        emailRequest.emailAddress = 'giorgio.meniconi@falp.org';
        emailRequest.subject = 'Test Email Subject';
        emailRequest.body = 'This is a test email body.';
        emailRequest.contentDocumentIds = new List<String>{contentVersion.ContentDocumentId};

        // Contar el número de envíos de correo electrónico antes de la prueba
        Integer emailInvocationsBefore = Limits.getEmailInvocations();

        // Llamar al método que se está probando
        Test.startTest();
            SendEmailWithAttachments.sendEmailWithAttachments(new List<SendEmailWithAttachments.EmailRequest>{emailRequest});
            // Contar el número de envíos de correo electrónico después de la prueba
            Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();


        // Verificar que se haya enviado un email
        System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'Se debe enviar un correo electrónico.');
    }

    @IsTest
    static void testSendEmailWithoutAttachments() {
        // Crear una solicitud de email sin adjuntos
        SendEmailWithAttachments.EmailRequest emailRequest = new SendEmailWithAttachments.EmailRequest();
        emailRequest.emailAddress = 'giorgio.meniconi@falp.org';
        emailRequest.subject = 'Test Email Subject without attachments';
        emailRequest.body = 'This is a test email body without attachments.';
        emailRequest.contentDocumentIds = new List<String>();

        // Contar el número de envíos de correo electrónico antes de la prueba
        Integer emailInvocationsBefore = Limits.getEmailInvocations();

        // Llamar al método que se está probando
        Test.startTest();
        SendEmailWithAttachments.sendEmailWithAttachments(new List<SendEmailWithAttachments.EmailRequest>{emailRequest});
        Test.stopTest();

        // Contar el número de envíos de correo electrónico después de la prueba
        Integer emailInvocationsAfter = Limits.getEmailInvocations();

        // Verificar que no se haya enviado un email
        System.assertEquals(emailInvocationsBefore, emailInvocationsAfter, 'No se debe enviar un correo electrónico sin adjuntos.');
    }
}