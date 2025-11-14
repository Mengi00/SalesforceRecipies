global class wsListPlus {

    @InvocableMethod(label='Crear List Plus')
    global static void wsgetListPlus (List<NewProformaActionRequest> requests) {
        
        /*List<Id> caseIds = new List<Id>();
        
        for (NewProformaActionRequest request : requests) {
            caseIds.add(request.caseId);           
        }
        Id casid  = !caseIds.isEmpty() ? caseIds[0] : null;*/
        Id casid =requests[0].caseId;
        List<Case> cases = [SELECT Id, Account.FALP_Seguro_complementario__c, Account.Ficha_Paciente__c, ContactId, Contact.Rut_Display__c, Contact.FirstName, Contact.MiddleName, Contact.LastName, Contact.suffix, 
                            Contact.Birthdate, Contact.Gender__c, Contact.MailingStreet, Contact.Pais_de_Origen__c, Contact.MailingState, Contact.MailingCity,
                            cc_edad__c,cc_pp_geriatria__c,cc_pp_Anestesista__c,owner.Name, Contact.GenderIdentity, Seguro_complementario__c,
                            Contact.MobilePhone, Contact.Email, Url_Documento_Traspaso__c, cc_pp_NPresupuesto__c, cc_pp_NPlandeTratamiento__c, cc_pp_institucion__c,
                            cc_pp_ficha__c, Contact.Prevision__c, Contact.Tramo_Fonasa__c
                            FROM Case 
                            WHERE Id =:casid];
        ClinicalServiceRequest planTratamiento = [SELECT Id, cc_pp_Anestesista__c, cc_pp_geriatria__c FROM ClinicalServiceRequest 
                                                    WHERE FALP_CaseId__c =:casid AND cc_pp_NPlandeTratamiento__c =:cases[0].cc_pp_NPlandeTratamiento__c];
        Opportunity presupuestoF = [SELECT Id, cc_pp_TdP__c FROM Opportunity 
                                                    WHERE CaseId__c =:casid AND CC_PP_NPRESUPUESTO__c =:cases[0].cc_pp_NPresupuesto__c Limit 1];



        Integer ResultTramo;
        Integer ResultGenero;
        
        Map<String,Integer> TramoFonasa = new Map<String,Integer>{
            'A' => 1,
            'B' => 2,
            'C' => 3,
            'D' => 4
            };
            
        Map<String, integer> MGenero = new Map<String,Integer>{
            'Mujer' => 1,
            'Hombre' => 2,
            'No binario' => 3,
            'No enumerado' => 3
            };
        
        if(!cases.isEmpty() && cases.size() > 0 ) {
            Case caso = cases[0];
            
            wsListPlusParser.request reqBody = new wsListPlusParser.request();
            reqBody.Usuario = System.label.FALP_AyP_userIntegration;
            reqBody.Clave = System.label.FALP_AyP_passIntegration;
            reqBody.Tipoiden = 1;
            if(caso.Contact != null) {
                ResultTramo = TramoFonasa.get(caso.Contact.Tramo_Fonasa__c);
                ResultGenero = caso.Contact.GenderIdentity == null ? 3 : MGenero.get(caso.Contact.GenderIdentity); 
                reqBody.Fonasa = ResultTramo;
            	reqBody.Nroiden = caso.Contact.Rut_Display__c;
                reqBody.Nombre = caso.Contact.FirstName + (caso.Contact.MiddleName != null ? ' '+caso.Contact.MiddleName : '');
                reqBody.Apepat = caso.Contact.LastName;
                reqBody.Apemat = caso.Contact.suffix;
                reqBody.Fecnactex = caso.Contact.Birthdate != null ? String.valueOf(caso.Contact.Birthdate.day()) + '-' + String.valueOf(caso.Contact.Birthdate.month()) + '-' + String.valueOf(caso.Contact.Birthdate.year()) : null;
                reqBody.Genero = ResultGenero;
                reqBody.Direccion = caso.Contact.MailingStreet;
                reqBody.Pais = caso.Contact.Pais_de_Origen__c; 
                reqBody.Region = caso.Contact.MailingState;
                reqBody.Comuna = caso.Contact.MailingCity;
                reqBody.Nacionalidad = caso.Contact.Pais_de_Origen__c; 
                reqBody.Telefono = caso.Contact.MobilePhone;
                reqBody.Email = caso.Contact.Email;
                System.debug('caso.Contact.Email::: '+caso.Contact.Email);
            }


            reqBody.Nhc = String.valueOf(caso.Account.Ficha_Paciente__c);//caso.cc_pp_ficha__c;
            //calcular la edad con base al remi del plan de tratamiento
            reqBody.Edad = caso.cc_edad__c != null ? Integer.valueOf(caso.cc_edad__c) : null;
            reqBody.Tipoprevi = presupuestoF.cc_pp_TdP__c;
            reqBody.Prevision = caso.Contact.Prevision__c;
            System.debug('caso.Contact.Prevision__c::: '+caso.Contact.Prevision__c);
            reqBody.Segurocomple = caso.Account.FALP_Seguro_complementario__c != null ? 1: null;
            reqBody.Requiereevaa = planTratamiento.cc_pp_Anestesista__c == true ? 1 : 2;
            reqBody.Requiereevag = planTratamiento.cc_pp_geriatria__c == true ? 1 : 2;
            reqBody.Fai = caso.cc_pp_NPresupuesto__c;
            reqBody.Derivado = 'si';
            reqBody.Contactoderi = String.valueOf(Caso.OwnerId).startsWith('005') ? caso.owner.Name: '';
            reqBody.Casosalesforce = caso.Id;
            reqBody.Nomdocu = '?';
            reqBody.Tipodoc = '?';
            reqBody.Urldes = '?';

            final String sJSON = JSON.serialize(reqBody);
            System.debug('sJSON::: '+ sJSON);
            String nameCredential = (wsListPlusParser.isSandbox()) ? 'ComunicadorCloudhubUAT' : 'ComunicadorProd';
            Http objHttp = new Http();
            HttpRequest objRequest = new HttpRequest();
            objRequest.setEndpoint('callout:' +nameCredential+ '/CrearListPlus');
            objRequest.setMethod('POST');
            objRequest.setHeader('Content-Type', 'application/json');
            objRequest.setHeader('accept', 'application/json');  
            objRequest.setTimeout(120000);
            objRequest.setBody(sJSON);

            System.debug('objRequest::::: ' + objRequest);
            System.debug('objRequest::::: ' + objRequest.getEndpoint());

            try {
                HttpResponse objResponse = objHttp.send(objRequest);
                System.debug('objResponse::::: ' + objResponse);
                if (objResponse.getStatusCode() == 200) {
                    System.debug(objResponse.getBody()); 
                    System.debug(objResponse.getBody().substringBetween('&lt;IdCaso>','&lt;/IdCaso>')); // cc_pp_idListplus
                    Case cas = new Case();
                    cas.Id = caso.Id;
                    cas.cc_pp_idListplus__c = objResponse.getBody().substringBetween('&lt;IdCaso>','&lt;/IdCaso>');
                    update cas;
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    
    global class NewProformaActionRequest {   
        @InvocableVariable
        global String caseId;
    }
    
}