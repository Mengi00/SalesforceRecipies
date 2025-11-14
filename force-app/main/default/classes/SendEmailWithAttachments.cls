public class SendEmailWithAttachments {

    public class EmailRequest {
        @InvocableVariable(label = 'Correo Destinatario')
        public String emailAddress;
        
        @InvocableVariable(label = 'Id de documento')
        public List<String> contentDocumentIds;
        
        @InvocableVariable(label = 'Asunto')
        public String subject;
        
        @InvocableVariable(label = 'Cuerpo')
        public String body;
        
        @InvocableVariable(label = 'Email del Servicio')
        public String fromemail;
        
        @InvocableVariable(label = 'Id del Caso')
        public Id caseId; // Agregado para asociar el correo al caso
    }

    @InvocableMethod(label = 'Enviar Email con Adjuntos')
    public static void sendEmailWithAttachments(List<EmailRequest> requests) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (EmailRequest request : requests) {
            if (request.contentDocumentIds != null && !request.contentDocumentIds.isEmpty()) {
                List<ContentVersion> contentVersions = [
                    SELECT Id, VersionData, FileType
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :request.contentDocumentIds
                ];

                List<Id> contentVersionIds = new List<Id>();

                for (ContentVersion cv : contentVersions) {
                    contentVersionIds.add(cv.Id);
                }

                emailMessages.add(createSingleEmailMessage(request, contentVersionIds));
            }
        }

        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }

    private static Messaging.SingleEmailMessage createSingleEmailMessage(EmailRequest request, List<Id> contentVersionIds) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :request.fromemail];

        //Parametros del Email
        email.setSubject(request.subject);
        email.setToAddresses(request.emailAddress.split(','));
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        // Consulta para recuperar el MessageIdentifier
        String threadId = null;
        List<EmailMessage> emails = [
            SELECT MessageIdentifier 
            FROM EmailMessage 
            WHERE RelatedToId = :request.caseId 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        if (!emails.isEmpty()) {
            threadId = emails[0].MessageIdentifier;
            email.setInReplyTo(threadId);
            email.setReferences(threadId);
        }

        // Agrega el cuerpo del mensaje con el token de hilo al final
        String emailBodyWithThreadId = request.body + '\n\n' + 'Ref: Case ' + request.caseId;
        email.setPlainTextBody(emailBodyWithThreadId);
        email.setEntityAttachments(contentVersionIds);
        
        // Asocia el correo al caso especificado
        if (request.caseId != null) {
            email.setWhatId(request.caseId);
        }

        return email;
    }
}