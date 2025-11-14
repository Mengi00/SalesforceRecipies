@RestResource(urlMapping='/CL_AddPresupuestos')
global with sharing class CL_AddPresupuestos {
    global class E_Parameters {
        global string   PRES_ID 					{ get; set; } //---> deberian ser de tipo number porque asi es en oracle
        global string   CPRE_ID 					{ get; set; } //---> deberian ser de tipo number porque asi es en oracle
        global string   SALESFORCE_PRESUPUESTO_ID 	{ get; set; }
        global string   ACCOUNT_ID 					{ get; set; }
        global integer  AMOUNT 						{ get; set; }
        global string   CASE_ID 					{ get; set; }
        global Date     CLOSE_DATE 					{ get; set; }
        global string   PLAN_DE_TRATAMIENTO_ID 		{ get; set; }
        //global string NAME 						{ get; set; }
        global string   RECORD_TYPE_ID 			   	{ get; set; }
        global string   STAGE_NAME 				   	{ get; set; }
        global string   MEDICO_TRATANTE 		   	{ get; set; }   
        global Datetime FECHA_CREACION_PRESUPUESTO 	{ get; set; }   
        global string   USUARIO_PRESUPUESTO 		{ get; set; }   
        global integer  CICLO_ID 					{ get; set; }   
        global string   TIPO_HONORARIO 				{ get; set; }   
        global string   PREVISION 					{ get; set; }
		global string   ID_EXTERNO    				{ get; set; }             
		//global string PRESUPUESTO_ID 				{ get; set; }   
    }       

    
    global class E_Response {
        public Boolean success 					{ get; set; }
        public String message 					{ get; set; }
        public List<E_PresupuestoAgregado> data { get; set; }
        
        public E_Response(){
            this.data = new List<E_PresupuestoAgregado>();
        }
    } 
    
    
    class E_PresupuestoAgregado {        
        private string PRES_ID 						{ get; set; }
        private string CPRE_ID 						{ get; set; }
        private string SALESFORCE_PRESUPUESTO_ID 	{ get; set; }
        private string ESTADO_TRANSMISION_ID		{ get; set; }
        private string MENSAJE			 			{ get; set; }
    }    
    
    
    @HttpPost
	global static E_Response addPresupuestos(List<E_Parameters> nuevosPresupuestos) {  
        Map<String, Opportunity> mapPresupuesto = new Map<String, Opportunity>();
        Map<String, string> mapCasoPresupuesto = new Map<String, string>();
        List<String> lstKeyPresupuestos = new List<String>();
		List<String> listaCasosIds = new List<String>();
		List<case> CasosParaActualizar = new List<case>();
        E_Response eResponse = new E_Response();
        E_PresupuestoAgregado ePresupuestoAgregado;      
        //string PresupuestoId;
        
        
        for (E_Parameters ePresupuesto : nuevosPresupuestos) {
            ePresupuesto.ID_EXTERNO = ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : 'Q' + ePresupuesto.CPRE_ID;            
            //PresupuestoId = ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : ePresupuesto.CPRE_ID;
            
            
            //mapPresupuesto.put(PresupuestoId, addPresupuesto(ePresupuesto));
 			//lstKeyPresupuestos.add(PresupuestoId);  
            mapPresupuesto.put(ePresupuesto.ID_EXTERNO, addPresupuesto(ePresupuesto));
 			lstKeyPresupuestos.add(ePresupuesto.ID_EXTERNO);   			
            
            //mapCasoPresupuesto.put(ePresupuesto.CASE_ID, PresupuestoId);
		    //listaCasosIds.add(ePresupuesto.CASE_ID);
        } 
        
        
		//Schema.SObjectField field_O = Opportunity.Fields.FALP_IdPresupuesto__c;		  
        Schema.SObjectField field_O = Opportunity.Fields.CC_PP_NPRESUPUESTO__c;		  
        Database.upsertResult[] resultMapPresupuesto = Database.upsert(mapPresupuesto.values(), field_O, false);        
        Map<String, string> mapErrorPresupuesto = errorResults(lstKeyPresupuestos, resultMapPresupuesto);        

        /*
        //Actualizar el subjet del caso con el presupuesto ID. Para esto, tenemos que basarnos en mapErrorPresupuesto
        if(listaCasosIds.Size() > 0){
            for(case Caso : [SELECT Id, Subject FROM case WHERE id in: listaCasosIds]) {        
                if (!mapErrorPresupuesto.containsKey(mapCasoPresupuesto.get(Caso.Id))) {
                    Caso.Subject = Caso.Subject.replace('PRES: ---', 'PRES: ' + mapCasoPresupuesto.get(Caso.Id) + ' ');
                    CasosParaActualizar.add(Caso);
                    System.debug(Caso.Subject);
                }
            }
		}       
        // Actualiza el subject del caso para agregar el presupuesto Id
        update CasosParaActualizar;
		*/        
        
        for (E_Parameters ePresupuesto : nuevosPresupuestos) {
			ePresupuestoAgregado = new E_PresupuestoAgregado();
            //PresupuestoId = ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : ePresupuesto.CPRE_ID;
            
            ePresupuestoAgregado.PRES_ID = ePresupuesto.PRES_ID;
        	ePresupuestoAgregado.CPRE_ID = ePresupuesto.CPRE_ID;
            
	        if (!mapPresupuesto.containsKey(ePresupuesto.ID_EXTERNO) || (mapPresupuesto.containsKey(ePresupuesto.ID_EXTERNO) && mapPresupuesto.get(ePresupuesto.ID_EXTERNO).Id == null)) {
                ePresupuestoAgregado.ESTADO_TRANSMISION_ID 		= 'NOK';
                ePresupuestoAgregado.MENSAJE			   		=  mapErrorPresupuesto.get(ePresupuesto.ID_EXTERNO);
            } else {
                ePresupuestoAgregado.ESTADO_TRANSMISION_ID 		= 'OK';
                ePresupuestoAgregado.MENSAJE			   		= null;
                ePresupuestoAgregado.SALESFORCE_PRESUPUESTO_ID  = mapPresupuesto.get(ePresupuesto.ID_EXTERNO).Id;                
            }
       
			eResponse.data.Add(ePresupuestoAgregado);            
        }        
        
		eResponse.success = true;
        eResponse.message = null;        
        
        return eResponse;  
    }
    
    
	private static Opportunity addPresupuesto(E_Parameters ePresupuesto) {		
        Opportunity O = new Opportunity();        
        
		O.id							= ePresupuesto.SALESFORCE_PRESUPUESTO_ID;        
        O.AccountId 					= ePresupuesto.ACCOUNT_ID;
        O.Amount 						= ePresupuesto.AMOUNT;
        O.CaseId__c 					= ePresupuesto.CASE_ID;
        O.CloseDate						= ePresupuesto.CLOSE_DATE;
        O.FALP_Plan_de_tratamiento__c	= ePresupuesto.PLAN_DE_TRATAMIENTO_ID;
        //O.Name 						= ePresupuesto.NAME;
        O.Name 							= ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : ePresupuesto.CPRE_ID;
        //O.CC_PP_NPRESUPUESTO__c			= ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : 'Q' + ePresupuesto.CPRE_ID;
        O.CC_PP_NPRESUPUESTO__c			= ePresupuesto.ID_EXTERNO;
        O.RecordTypeId					= ePresupuesto.RECORD_TYPE_ID;
        O.StageName						= ePresupuesto.STAGE_NAME;
        O.Medico_Tratante__c			= ePresupuesto.MEDICO_TRATANTE;        
       	O.cc_pp_FdCP__c       			= ePresupuesto.FECHA_CREACION_PRESUPUESTO;
       	O.CC_PP_EMISORPRESUPUESTO__c 	= ePresupuesto.USUARIO_PRESUPUESTO;
      	O.cc_pp_IdCiclo__c 				= ePresupuesto.CICLO_ID;			//--> Que valores va a tener este campo? es un ID o 
      	O.CC_PP_HONORARIOS__c 			= ePresupuesto.TIPO_HONORARIO;
      	O.FALP_Prevision__c				= ePresupuesto.PREVISION;
        //O.FALP_IdPresupuesto__c		= ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : ePresupuesto.CPRE_ID; // Se elimino porque va a tener el mismo valor que O.Name
        
        return O;    
     }    
    
    
	private static Map<String, String> errorResults(List<String> keys, Database.upsertResult[] resultsUpserts){
        Map<String, string> mapResultsErrors = new Map<String, string>();
        
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
    
    
    
    
    /*
    @HttpPost
	global static E_Response addPresupuestos(List<E_Parameters> nuevosPresupuestos) {  
        E_Response eResponse = new E_Response();
        Map<String, Opportunity> mapPresupuesto = new Map<String, Opportunity>();
        
        try {
            for (E_Parameters ePresupuesto : nuevosPresupuestos) {
                eResponse.data.Add(addPresupuesto(ePresupuesto));                
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
    
	private static E_PresupuestoAgregado addPresupuesto(E_Parameters ePresupuesto) {		
        Opportunity O = new Opportunity();
        E_PresupuestoAgregado ePresupuestoAgregado = new E_PresupuestoAgregado();
        
        try {            
            // ¿Porque tenia  O.CC_PP_NPRESUPUESTO__c comentado?
            O.CC_PP_NPRESUPUESTO__c			= ePresupuesto.PRES_ID != null ? ePresupuesto.PRES_ID : ePresupuesto.CPRE_ID;
            O.AccountId 					= ePresupuesto.ACCOUNT_ID;	//'testHP';
            O.Amount 						= ePresupuesto.AMOUNT;
            O.CaseId__c 					= ePresupuesto.CASE_ID;
            O.CloseDate						= ePresupuesto.CLOSE_DATE;
            O.FALP_Plan_de_tratamiento__c	= ePresupuesto.PLAN_DE_TRATAMIENTO_ID;
            O.Name 							= ePresupuesto.NAME;
            O.RecordTypeId					= ePresupuesto.RECORD_TYPE_ID;
            O.StageName						= ePresupuesto.STAGE_NAME;
            O.Medico_Tratante__c			= ePresupuesto.MEDICO_TRATANTE; //'testHP';
            O.FALP_IdPresupuesto__c			= ePresupuesto.PRESUPUESTO_ID;         
            
            upsert O;
            
            ePresupuestoAgregado.PRES_ID        		   = ePresupuesto.PRES_ID;
        	ePresupuestoAgregado.CPRE_ID				   = ePresupuesto.CPRE_ID;
            ePresupuestoAgregado.SALESFORCE_PRESUPUESTO_ID = O.Id;
            ePresupuestoAgregado.ESTADO_TRANSMISION_ID     = 'OK';
			ePresupuestoAgregado.MENSAJE                   = NULL;
        }
       	catch (Exception e) {
            ePresupuestoAgregado.PRES_ID        		   = ePresupuesto.PRES_ID;
        	ePresupuestoAgregado.CPRE_ID				   = ePresupuesto.CPRE_ID;
            ePresupuestoAgregado.SALESFORCE_PRESUPUESTO_ID = O.Id;
            ePresupuestoAgregado.ESTADO_TRANSMISION_ID 	   = 'NOK';
          	ePresupuestoAgregado.MENSAJE 				   = e.getMessage();           
       	}           
        
        return ePresupuestoAgregado;              
     }
	*/
}