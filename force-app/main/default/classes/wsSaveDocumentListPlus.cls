global class wsSaveDocumentListPlus {

    @InvocableMethod(label='Guardar Documento en List Plus')
    public static void wsDocumentBase64 (List<NewProformaActionRequest> requests){
        for (NewProformaActionRequest request : requests) {
            wsDocumentBase64Future(request.caseId, request.documentId);
        }
    }
    
   	@future( callout = true)
    public static void wsDocumentBase64Future (String caseId, String documentId){
        Case caso = [Select Id , cc_pp_idListplus__c From Case Where Id =: caseId];
        ContentVersion file = [SELECT Title, VersionData FROM ContentVersion WHERE IsLatest = TRUE and ContentDocumentId=:documentId];
    	String bodyBase64 = EncodingUtil.base64Encode(file.VersionData);
        wsListPlusParser.requestDocument reqBody = new wsListPlusParser.requestDocument();
        reqBody.Usuario = System.label.FALP_AyP_userIntegration;
        reqBody.Clave = System.label.FALP_AyP_passIntegration;
        reqBody.Casoid = caso.cc_pp_idListplus__c != null ? Integer.ValueOf(caso.cc_pp_idListplus__c) : null;
        reqBody.Casosalesforce = CaseId;
        reqBody.Nomdocu = file.Title;
        reqBody.Tipodoc = 'pdf';
        reqBody.Documento = bodyBase64;
        final String sJSON = JSON.serialize(reqBody);
        System.debug('sJSON::::: ' + sJSON);
        String nameCredential = (wsListPlusParser.isSandbox()) ? 'ComunicadorCloudhubUAT' : 'ComunicadorProd';
        Http objHttp2 = new Http();
        HttpRequest objRequest2 = new HttpRequest();
        HttpResponse objResponse2 = new HttpResponse();
        objRequest2.setEndpoint('callout:'+nameCredential+'/GuardarArchivosListPlus');
        objRequest2.setMethod('POST');
        objRequest2.setHeader('Content-Type', 'application/json');
        objRequest2.setHeader('accept', 'application/json');  
        objRequest2.setTimeout(120000);
        objRequest2.setBody(sJSON);
        System.debug('objRequest::::: ' + objRequest2);
        System.debug('objRequest::::: ' + objRequest2.getEndPoint());
        try{
            objResponse2 = objHttp2.send(objRequest2);
            System.debug('objResponse::::: ' + objResponse2);
            System.debug('objResponse::::: ' + objResponse2.getBody());
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    

    global class NewProformaActionRequest {   
        @InvocableVariable
        global String caseId;  
        @InvocableVariable
        global String documentId;
      }
    
}