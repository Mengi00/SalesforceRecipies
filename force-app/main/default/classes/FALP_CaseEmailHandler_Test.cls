@isTest
private class FALP_CaseEmailHandler_Test {

    @testSetup
    static void setupData() {
        // Crear un caso con número de plan
        Case c = new Case(FALP_PLANFALP__c = 'MKD123456');
        insert c;
    }

    @isTest
    static void testEmailWithValidPlan() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Consulta sobre PLANFALP MKD123456';
        email.plainTextBody = 'Hola, tengo una duda sobre el plan.';
        
        //email.headers = new Messaging.InboundEmail.Header[] {new Messaging.InboundEmail.Header('X-Test', 'HeaderValue')};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test@example.com';
        env.toAddress = 'soporte@empresa.com';

        FALP_CaseEmailHandler handler = new FALP_CaseEmailHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        System.assert(result.success, 'El correo debería procesarse correctamente.');
    }

    @isTest
    static void testEmailWithoutPlan() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Consulta general';
        email.plainTextBody = 'No hay número de plan aquí.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test2@example.com';

        Test.startTest();
        FALP_CaseEmailHandler handler = new FALP_CaseEmailHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);
        Test.stopTest();

        System.assert(result.success, 'El correo debería marcarse como procesado aunque no tenga plan.');
    }

    @isTest
    static void testEmailWithSalesforceToken() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Re: PLANFALP MKD123456';
        email.plainTextBody = 'Este correo contiene un thread token de Salesforce.';

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test3@example.com';

        FALP_CaseEmailHandler handler = new FALP_CaseEmailHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        System.assert(result.success, 'El correo debe ser ignorado por contener token.');
    }

    @isTest
    static void testEmailWithAttachments() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'PLANFALP MKD123456';
        email.plainTextBody = 'Adjunto archivos.';

        // Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment bAtt = new Messaging.InboundEmail.BinaryAttachment();
        bAtt.fileName = 'archivo.pdf';
        bAtt.body = Blob.valueOf('contenido');
        bAtt.mimeTypeSubType = 'application/pdf';

        // Adjuntos de texto
        Messaging.InboundEmail.TextAttachment tAtt = new Messaging.InboundEmail.TextAttachment();
        tAtt.fileName = 'nota.txt';
        tAtt.body = 'Texto plano';

        email.binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { bAtt };
        email.textAttachments = new Messaging.InboundEmail.TextAttachment[] { tAtt };

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'test4@example.com';

        FALP_CaseEmailHandler handler = new FALP_CaseEmailHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        System.assert(result.success, 'El correo con adjuntos debe procesarse correctamente.');
    }
}