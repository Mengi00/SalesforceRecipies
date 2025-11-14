global class FALP_CaseEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            
            System.debug('Subject: ' + email.subject);
            System.debug('Body: ' + email.plainTextBody);
            System.debug('envelope.fromAddress: ' + envelope.fromAddress);

            String emailEjecutivo = envelope.fromAddress;
            String subject = email.subject != null ? email.subject.toUpperCase() : '';
            String body = email.plainTextBody;
            
            // Detectar si es un correo de verificación de Gmail
            System.debug('subject::: '+subject);
            Boolean isGmailVerification = subject.containsIgnoreCase('Gmail Forwarding Confirmation') || subject.containsIgnoreCase('Gmail Confirmación de reenvío');

            if (isGmailVerification) {
                System.debug('isGmailVerification::: '+isGmailVerification);
                sendEmail(email.plainTextBody, email.subject, System.Label.FALP_Email_Confirmacion, null);
                result.success = true;
                return result;
            }
            String originalSenderName = '';
            String originalSenderEmail = '';
            String emailEjecutivo2 = '';
            //Extraccion de remitente original
            String headersAsText = '';
            if (email.headers != null) {
                for (Messaging.InboundEmail.Header h : email.headers) {
                    // Convertir lista de encabezados a texto
                    headersAsText += h.name + ': ' + h.value + '\n';
                    if (h.name.equalsIgnoreCase('From')) {
                        // Ejemplo: "Juan Pérez" <juan.perez@example.com>
                        Pattern p = Pattern.compile('"?([^"]*)"?\\s*<([^>]+)>');
                        Matcher m = p.matcher(h.value);
                        if (m.find()) {
                            originalSenderName = m.group(1);
                            originalSenderEmail = m.group(2);
                        } else {
                            // Si no hay nombre, solo correo
                            originalSenderEmail = h.value;
                        }
                    }
                    if (h.name.equalsIgnoreCase('Delivered-To')) {
                        // Ejemplo: "Juan Pérez" <juan.perez@example.com>
                        Pattern p = Pattern.compile('"?([^"]*)"?\\s*<([^>]+)>');
                        Matcher m = p.matcher(h.value);
                        if (m.find()) {
                            emailEjecutivo2 = m.group(2);
                        } else {
                            // Si no hay nombre, solo correo
                            emailEjecutivo2 = h.value;
                        }
                    }
                }
            }
            System.debug('emailEjecutivo2::: '+emailEjecutivo2);
            // 🚫 Ignorar si el cuerpo contiene el token de Salesforce
            if (body != null && body.containsIgnoreCase('thread')) {
                result.success = true;
                return result;
            }

            // 🔍 Buscar número de plan en asunto o cuerpo
            String planNumber = extractPlanNumber(subject);
            if (planNumber == null) {
                planNumber = extractPlanNumber(body);
            }
            System.debug('planNumber::: '+planNumber);
            if (planNumber != null) {
                List<Case> cases = [
                    SELECT Id, FALP_PLANFALP__c 
                    FROM Case 
                    WHERE FALP_PLANFALP__c = :planNumber 
                    LIMIT 1
                ];

                if (!cases.isEmpty()) {
                    Case matchedCase = cases[0];
                    // 📩 Crear EmailMessage
                    EmailMessage message = new EmailMessage();
                    message.ParentId = matchedCase.Id;
                    message.Subject = email.subject;
                    message.FromAddress = originalSenderEmail;//emailEjecutivo;
                    message.ToAddress = emailEjecutivo2;//envelope.toAddress;
                    message.TextBody = email.plainTextBody;
                    message.HtmlBody = email.htmlBody;
                    message.Incoming = true;
                    message.Status = '3'; // Received
                    
                    message.Headers = headersAsText;
                    message.MessageIdentifier = email.messageId;
                    insert message;

                    // 📎 Adjuntar archivos binarios
                    if (email.binaryAttachments != null) {
                        for (Messaging.InboundEmail.BinaryAttachment bAtt : email.binaryAttachments) {
                            Attachment attachment = new Attachment();
                            attachment.ParentId = matchedCase.Id;
                            attachment.Name = bAtt.fileName;
                            attachment.Body = bAtt.body;
                            attachment.ContentType = bAtt.mimeTypeSubType;
                            insert attachment;
                        }
                    }

                    // 📎 Adjuntar archivos de texto
                    if (email.textAttachments != null) {
                        for (Messaging.InboundEmail.TextAttachment tAtt : email.textAttachments) {
                            Attachment attachment = new Attachment();
                            attachment.ParentId = matchedCase.Id;
                            attachment.Name = tAtt.fileName;
                            attachment.Body = Blob.valueOf(tAtt.body);
                            attachment.ContentType = 'text/plain';
                            insert attachment;
                        }
                    }

                    result.success = true;
                } else {
                    sendAutoReply(emailEjecutivo, emailEjecutivo2, subject, email, originalSenderName, originalSenderEmail);
                }
            } else {
                sendAutoReply(emailEjecutivo, emailEjecutivo2, subject, email, originalSenderName, originalSenderEmail);
            }
        } catch (Exception e) {
            System.debug('Error al procesar el correo: ' + e.getMessage());
        }

        return result;
    }

    private String extractPlanNumber(String text) {
        if (text == null) return null;
        Pattern planPattern = Pattern.compile('PLANFALP\\s*([A-Z]{3}\\d+)');
        Matcher matcher = planPattern.matcher(text);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private void sendAutoReply(String ccAddress, String emailEjecutivo2, String originalSubject, Messaging.InboundEmail email, String originalSenderName, String toAddress) {
        String bodyText = 'Estimado usuario '+originalSenderName+',\n\n' +
            'No hemos podido recepcionar su correo correctamente, ya que no se identifica un plan de tratamiento asociado a su solicitud.' +
            'Para poder ingresar su solicitud, por favor reenvíe el correo a su ejecutivo ('+emailEjecutivo2+') indicando:\n\n' +
            'RUT del paciente\n\n' +
            'Número de atención que se le indicó al enviarle el presupuesto, con el formato "PLANFALP abc123456"\n\n'+
            'Este es un mensaje automático. Por favor, no responda a este correo.\n\n'+
            'Quedamos atentos a su respuesta a través del canal indicado.\n\n'+
            'Saludos cordiales.\n\n\n\n'+
            'Correo original:\n\n'+
            'Asunto: '+email.subject+'\n\n'+
            'Cuerpo: '+email.plainTextBody+'\n\n';
        sendEmail(bodyText, 'No se pudo procesar su correo: ' + originalSubject, toAddress, ccAddress);
        
    }
    private void sendEmail(String bodyText, String subject, String toAddress, String ccAddress){
        Messaging.SingleEmailMessage reply = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.FALP_Email_NoReplay];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (owea.size() > 0 ) {
            reply.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        reply.setToAddresses(new String[] { toAddress });
        if(ccAddress != null){
            reply.setCcAddresses(new String[] { ccAddress });
        }
        reply.setSubject(subject);
        reply.setPlainTextBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { reply });
    }
}