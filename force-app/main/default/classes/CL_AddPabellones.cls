@RestResource(urlMapping='/CL_AddPabellones')
global class CL_AddPabellones {
    global class E_Parameters {
        global integer  RESERVA_PABELLON_ID				{ get; set; }
        global integer	SOLICITUD_PABELLON_ID			{ get; set; }
        global string 	SALESFORCE_PABELLON_ID			{ get; set; }
        global string   CATEGORIA						{ get; set; }
        global string   ESTADO							{ get; set; }
        global string   PACIENTE_ID 					{ get; set; }
        global string   SUCURSAL						{ get; set; }
        global string   PLAN_ID				    		{ get; set; }
        global datetime	FECHA_SOLICITUD	           		{ get; set; }
        global datetime	FECHA_RESERVA_PABELL_CONFIMADO	{ get; set; }
        global datetime	FECHA_INGRESO	           		{ get; set; }
        global string	COMENTARIO						{ get; set; }
        global datetime	HORA_INICIO_RESERVA				{ get; set; }
        global datetime	HORA_TERMINO_RESERVA			{ get; set; }
        global string   ID_EXTERNO    					{ get; set; }
    }
    
    global class E_Response {
        public Boolean success 				 { get; set; }
        public String  message 				 { get; set; }
        public List<E_PabellonAgregado> data { get; set; }
        
        public E_Response(){
            this.data = new List<E_PabellonAgregado>();
        }
    } 
    
    
    class E_PabellonAgregado {        
        private integer RESERVA_PABELLON_ID		{ get; set; }        
        private integer SOLICITUD_PABELLON_ID	{ get; set; }
        private string  SALESFORCE_PABELLON_ID 	{ get; set; }
        private string  ESTADO_TRANSMISION_ID	{ get; set; }
        private string  MENSAJE			 		{ get; set; }
    }    
    

    @HttpPost
	global static E_Response addPabellones(List<E_Parameters> nuevosPabellones) {
   		Map<String, ClinicalEncounter> mapPabellon = new Map<String, ClinicalEncounter>();
        List<String> lstKeyPabellones = new List<String>();
        
        
        //List<String> PlanesId = new List<String>();
        Map<String, String> PlanesId = new Map<String, String>();
        
        
        List<Case> Casos = new List<Case>();
        E_Response eResponse = new E_Response();
        E_PabellonAgregado ePabellonAgregado;
        
        for (E_Parameters ePabellon : nuevosPabellones) {
            ePabellon.ID_EXTERNO = 'P' + String.valueOf(ePabellon.SOLICITUD_PABELLON_ID) + '-'+ String.valueOf(ePabellon.RESERVA_PABELLON_ID);
            mapPabellon.put(ePabellon.ID_EXTERNO, addPabellon(ePabellon));
 			lstKeyPabellones.add(ePabellon.ID_EXTERNO);           
            
            // aqui agregar el arreglo para actualizar el estado a "Agendado Por Integracion" del caso 
            //PlanesId.add(ePabellon.PLAN_ID);
            PlanesId.put(ePabellon.PLAN_ID, ePabellon.ESTADO);
            
        }
        
        Schema.SObjectField field_CE = ClinicalEncounter.Fields.Enc_Clinico_Id_Externo__c;        
        Database.upsertResult[] resultMapPabellon = Database.upsert(mapPabellon.values(),field_CE, false);            
        Map<String, string> mapErrorPabellon = errorResults(lstKeyPabellones, resultMapPabellon);
        
        //Obtener los CasosId desde los planes
        for(case Caso : [SELECT Id, cc_pp_NPlandeTratamiento__c FROM case WHERE cc_pp_NPlandeTratamiento__c in: PlanesId.keySet() AND status ='Agendamiento' AND FALP_Estado_Agendamiento__c in ('Por agendar', null)]) {
            
            if (PlanesId.get(Caso.cc_pp_NPlandeTratamiento__c) == 'Solicitada') {
                Caso.FALP_Estado_Agendamiento__c = 'solicitado(pabellon)';    
            } else if (PlanesId.get(Caso.cc_pp_NPlandeTratamiento__c) == 'Reservada') {
                Caso.FALP_Estado_Agendamiento__c = 'Agendado por integración';    
            }
          /*
            switch (PlanesId.get(Caso.cc_pp_NPlandeTratamiento__c)) {
                when 'Solicitada'{
            		Caso.FALP_Estado_Agendamiento__c = 'solicitado(pabellon)';            
                }
                when 'Reservada' {
                	Caso.FALP_Estado_Agendamiento__c = 'Agendado por integración';            
                }
            }
            */
			Casos.add(Caso);                
        }
        
        //for(case Caso : [SELECT Id FROM case WHERE cc_pp_NPlandeTratamiento__c in: PlanesId AND status ='Agendamiento' AND FALP_Estado_Agendamiento__c = 'Por agendar']){
        //    Caso.FALP_Estado_Agendamiento__c = 'Agendado por integración';
		//	Casos.add(Caso);
        //}
        
        //Actualizar Estado agendamiento de los casos
        Update(Casos);
        
		for (E_Parameters ePabellon : nuevosPabellones) {
			ePabellonAgregado = new E_PabellonAgregado();
            
            ePabellonAgregado.RESERVA_PABELLON_ID   = ePabellon.RESERVA_PABELLON_ID;
            ePabellonAgregado.SOLICITUD_PABELLON_ID = ePabellon.SOLICITUD_PABELLON_ID;			
            
	        if (!mapPabellon.containsKey(ePabellon.ID_EXTERNO) || (mapPabellon.containsKey(ePabellon.ID_EXTERNO) && mapPabellon.get(ePabellon.ID_EXTERNO).Id == null)) {
                ePabellonAgregado.ESTADO_TRANSMISION_ID		= 'NOK';
                ePabellonAgregado.MENSAJE			   		=  mapErrorPabellon.get(ePabellon.ID_EXTERNO);
            } else {
                ePabellonAgregado.ESTADO_TRANSMISION_ID 	= 'OK';
                ePabellonAgregado.MENSAJE			   		=  null;
                ePabellonAgregado.SALESFORCE_PABELLON_ID	= mapPabellon.get(ePabellon.ID_EXTERNO).Id;
            }

			eResponse.data.Add(ePabellonAgregado);            
        }
        
        eResponse.success = true;
        eResponse.message = null;
        
        return eResponse;          
    }
    
        
	private static ClinicalEncounter addPabellon(E_Parameters ePabellon) {		
        ClinicalEncounter CE = new ClinicalEncounter();
        
        CE.Enc_Clinico_Id_Externo__c			= ePabellon.ID_EXTERNO;
        CE.id									= ePabellon.SALESFORCE_PABELLON_ID;
        CE.FALP_N_Plan_de_Tratamiento__c		= ePabellon.PLAN_ID;       
        CE.Reserva_Pabellon_Id__c     			= ePabellon.RESERVA_PABELLON_ID;	
        CE.Solicitud_Pabellon_Id__c        		= ePabellon.SOLICITUD_PABELLON_ID;		
        CE.Category  							= ePabellon.CATEGORIA;
        CE.Status    							= ePabellon.ESTADO;
        CE.PatientId 							= ePabellon.PACIENTE_ID;			
       	CE.Sucursal__c							= ePabellon.SUCURSAL;
      	CE.Fecha_Solicitud__c    				= ePabellon.FECHA_SOLICITUD;
      	CE.Fecha_Reserva_Pabellon_Confirmada__c	= ePabellon.FECHA_RESERVA_PABELL_CONFIMADO;
       	CE.Comentario__c						= ePabellon.COMENTARIO; 
       	CE.StartDate							= ePabellon.HORA_INICIO_RESERVA;
		CE.EndDate								= ePabellon.HORA_TERMINO_RESERVA;

        return CE;
     }
        
   	private static Map<String, String> errorResults(List<String> keys, Database.upsertResult[] resultsUpserts){
        Map<String, String> mapResultsErrors = new Map<String, String>();
        for (Integer i =0; i < resultsUpserts.size(); i++ ) {
            if (!resultsUpserts[i].isSuccess()){
                for(Database.Error err : resultsUpserts[i].getErrors()){
                    //System.debug('The following error has occurred.');          
                    //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    mapResultsErrors.put(keys[i], err.getStatusCode() + ': ' + err.getMessage() +' campos:'+ err.getFields());
                    //System.debug('EC fields that affected this error: ' + err.getFields());
                }
            }
        }
        return mapResultsErrors;
    }         
}



/*		*** BACKUP ***

@RestResource(urlMapping='/CL_AddPabellones')
global class CL_AddPabellones {
    global class E_Parameters {
        global integer  RESERVA_PABELLON_ID				{ get; set; }
        global integer	SOLICITUD_PABELLON_ID			{ get; set; }
        global string 	SALESFORCE_PABELLON_ID			{ get; set; }
        global string   CATEGORIA						{ get; set; }
        global string   ESTADO							{ get; set; }
        global string   PACIENTE_ID 					{ get; set; }
        global string   SUCURSAL						{ get; set; }
        global string   PLAN_ID				    		{ get; set; }
        global datetime	FECHA_SOLICITUD	           		{ get; set; }
        global datetime	FECHA_RESERVA_PABELL_CONFIMADO	{ get; set; }
        global datetime	FECHA_INGRESO	           		{ get; set; }
        global string	COMENTARIO						{ get; set; }
        global datetime	HORA_INICIO_RESERVA				{ get; set; }
        global datetime	HORA_TERMINO_RESERVA			{ get; set; }
    }       

    
    global class E_Response {
        public Boolean success 				 { get; set; }
        public String  message 				 { get; set; }
        public List<E_PabellonAgregado> data { get; set; }
        
        public E_Response(){
            this.data = new List<E_PabellonAgregado>();
        }
    } 
    
    
    class E_PabellonAgregado {        
        private integer RESERVA_PABELLON_ID		{ get; set; }        
        private integer SOLICITUD_PABELLON_ID	{ get; set; }
        private string  SALESFORCE_PABELLON_ID 	{ get; set; }
        private string  ESTADO_TRANSMISION_ID	{ get; set; }
        private string  MENSAJE			 		{ get; set; }
    }    
    

    @HttpPost
	global static E_Response addPabellones(List<E_Parameters> nuevosPabellones) {
   		Map<Integer, ClinicalEncounter> mapPabellon = new Map<Integer, ClinicalEncounter>();
        List<Integer> lstKeyPabellones = new List<Integer>();
        List<String> PlanesId = new List<String>();
        List<Case> Casos = new List<Case>();
        E_Response eResponse = new E_Response();
        E_PabellonAgregado ePabellonAgregado;
        
        for (E_Parameters ePabellon : nuevosPabellones) {
            mapPabellon.put(ePabellon.RESERVA_PABELLON_ID, addPabellon(ePabellon));
 			lstKeyPabellones.add(ePabellon.RESERVA_PABELLON_ID);           
            
            // aqui agregar el arreglo para actualizar el estado a "Agendado Por Integracion" del caso 
            PlanesId.add(ePabellon.PLAN_ID);
        }
        
        Schema.SObjectField field_CE = ClinicalEncounter.Fields.Enc_Clinico_Id_Externo__c;        
        Database.upsertResult[] resultMapPabellon = Database.upsert(mapPabellon.values(),field_CE, false);            
        Map<integer, string> mapErrorPabellon = errorResults(lstKeyPabellones, resultMapPabellon);
        
        //Obtener los CasosId desde los planes
        for(case Caso : [SELECT Id FROM case WHERE cc_pp_NPlandeTratamiento__c in: PlanesId AND status ='Agendamiento' AND FALP_Estado_Agendamiento__c = 'Por agendar']){
            Caso.FALP_Estado_Agendamiento__c = 'Agendado por integración';
			Casos.add(Caso);
        }
        
        //Actualizar Estado agendamiento de los casos
        Update(Casos);
        
		for (E_Parameters ePabellon : nuevosPabellones) {
			ePabellonAgregado = new E_PabellonAgregado();
            
            ePabellonAgregado.RESERVA_PABELLON_ID   = ePabellon.RESERVA_PABELLON_ID;
            ePabellonAgregado.SOLICITUD_PABELLON_ID = ePabellon.SOLICITUD_PABELLON_ID;			
            
	        if (!mapPabellon.containsKey(ePabellon.RESERVA_PABELLON_ID) || (mapPabellon.containsKey(ePabellon.RESERVA_PABELLON_ID) && mapPabellon.get(ePabellon.RESERVA_PABELLON_ID).Id == null)) {
                ePabellonAgregado.ESTADO_TRANSMISION_ID		= 'NOK';
                ePabellonAgregado.MENSAJE			   		=  mapErrorPabellon.get(ePabellon.RESERVA_PABELLON_ID);
            } else {
                ePabellonAgregado.ESTADO_TRANSMISION_ID 	= 'OK';
                ePabellonAgregado.MENSAJE			   		=  null;
                ePabellonAgregado.SALESFORCE_PABELLON_ID	= mapPabellon.get(ePabellon.RESERVA_PABELLON_ID).Id;
            }

			eResponse.data.Add(ePabellonAgregado);            
        }
        
        eResponse.success = true;
        eResponse.message = null;
        
        return eResponse;          
    }
    
        
	private static ClinicalEncounter addPabellon(E_Parameters ePabellon) {		
        ClinicalEncounter CE = new ClinicalEncounter();
        
        CE.id									= ePabellon.SALESFORCE_PABELLON_ID;
        CE.FALP_N_Plan_de_Tratamiento__c		= ePabellon.PLAN_ID;       
        CE.Enc_Clinico_Id_Externo__c			= 'P' + String.valueOf(ePabellon.SOLICITUD_PABELLON_ID) + '-'+ String.valueOf(ePabellon.RESERVA_PABELLON_ID);
        CE.Reserva_Pabellon_Id__c     			= ePabellon.RESERVA_PABELLON_ID;	
        CE.Solicitud_Pabellon_Id__c        		= ePabellon.SOLICITUD_PABELLON_ID;		
        CE.Category  							= ePabellon.CATEGORIA;
        CE.Status    							= ePabellon.ESTADO;
        CE.PatientId 							= ePabellon.PACIENTE_ID;			
       	CE.Sucursal__c							= ePabellon.SUCURSAL;
      	CE.Fecha_Solicitud__c    				= ePabellon.FECHA_SOLICITUD;
      	CE.Fecha_Reserva_Pabellon_Confirmada__c	= ePabellon.FECHA_RESERVA_PABELL_CONFIMADO;
       	CE.Comentario__c						= ePabellon.COMENTARIO; 
       	CE.StartDate							= ePabellon.HORA_INICIO_RESERVA;
		CE.EndDate								= ePabellon.HORA_TERMINO_RESERVA;

        return CE;
     }
        
   	private static Map<Integer, String> errorResults(List<Integer> keys, Database.upsertResult[] resultsUpserts){
        Map<Integer, String> mapResultsErrors = new Map<Integer, String>();
        for (Integer i =0; i < resultsUpserts.size(); i++ ) {
            if (!resultsUpserts[i].isSuccess()){
                for(Database.Error err : resultsUpserts[i].getErrors()){
                    //System.debug('The following error has occurred.');          
                    //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    mapResultsErrors.put(keys[i], err.getStatusCode() + ': ' + err.getMessage() +' campos:'+ err.getFields());
                    //System.debug('EC fields that affected this error: ' + err.getFields());
                }
            }
        }
        return mapResultsErrors;
    }         


}

*/








/*    
    @HttpPost
	global static E_Response addPabellones(List<E_Parameters> nuevosPabellones) {  
        E_Response eResponse = new E_Response();
        
        try {
            for (E_Parameters ePabellon : nuevosPabellones) {
                eResponse.data.Add(addPabellon(ePabellon));                
            }
            
            eResponse.success = true;
        	eResponse.message = null;
        }
        catch (Exception e) {
            eResponse.success = false;
        	eResponse.message = e.getMessage();          	
      	} 
        
        return eResponse;
    }
    
	private static E_PabellonAgregado addPabellon(E_Parameters ePabellon) {		
		ClinicalEncounter CE = new ClinicalEncounter(); 		
        E_PabellonAgregado ePabellonAgregado = new E_PabellonAgregado();
        
        try {     
        	CE.Solicitud_Pabellon_Id__c        		= ePabellon.SOLICITUD_PABELLON_ID;			
			CE.Reserva_Pabellon_Id__c     			= ePabellon.RESERVA_PABELLON_ID;	
            CE.Category  							= ePabellon.CATEGORIA; 				// 'Encounter';
            CE.Status    							= ePabellon.ESTADO;					// 'Finished';
            CE.PatientId 							= ePabellon.PACIENTE_ID;			
        	CE.Sucursal__c							= ePabellon.SUCURSAL;
            CE.Presupuesto_Falp__c  				= ePabellon.PRESUPUESTO_ID;	            	
        	CE.Fecha_Solicitud__c    				= ePabellon.FECHA_SOLICITUD;	           		
        	CE.Fecha_Reserva_Pabellon_Confirmada__c	= ePabellon.FECHA_RESERVA_PABELL_CONFIMADO;
            CE.StartDate							= ePabellon.FECHA_INGRESO;
        	CE.Comentario__c						= ePabellon.COMENTARIO;            

            upsert CE;

            ePabellonAgregado.SOLICITUD_PABELLON_ID 	= ePabellon.SOLICITUD_PABELLON_ID;			
			ePabellonAgregado.RESERVA_PABELLON_ID   	= ePabellon.RESERVA_PABELLON_ID;
            ePabellonAgregado.SALESFORCE_PABELLON_ID	= CE.Id;
            ePabellonAgregado.ESTADO_TRANSMISION_ID    	= 'OK';
			ePabellonAgregado.MENSAJE                  	= NULL;
        }
       	catch (Exception e) {
            ePabellonAgregado.SOLICITUD_PABELLON_ID 	= ePabellon.SOLICITUD_PABELLON_ID;			
			ePabellonAgregado.RESERVA_PABELLON_ID   	= ePabellon.RESERVA_PABELLON_ID;            
            ePabellonAgregado.SALESFORCE_PABELLON_ID	= CE.Id;
            ePabellonAgregado.ESTADO_TRANSMISION_ID 	= 'NOK';
          	ePabellonAgregado.MENSAJE 					= 'Error al tratar de agregar Encuentro Clinico: ' + e.getMessage();           
       	}  
        
        return ePabellonAgregado;                             
     }
*/