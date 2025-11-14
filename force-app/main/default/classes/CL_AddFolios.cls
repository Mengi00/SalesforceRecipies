@RestResource(urlMapping='/CL_AddFolios')
global with sharing class CL_AddFolios {
    global class E_Parameters {
        global Integer FICH_ID				{ get; set; }	//"FICH_ID": 563093
        global string SALESFORCE_FOLIO_ID	{ get; set; }
        global string NUMERO_DE_FOLIO 		{ get; set; }   //===> Eliminar este campos ==> "NUMERO_DE_FOLIO": "FO-0000000002", ---> se usa realmente este valor ya que ahora usamos FICH_ID
        global Datetime FECHA_FOLIO 		{ get; set; }	//"FECHA_FOLIO": "2024-10-27T00:00:00",
        global Date FECHA_HOSPITALIZACION	{ get; set; }   //"FECHA_HOSPITALIZACION": "2024-12-09T00:00:00",       
        global string ESTADO 				{ get; set; }	//"ESTADO": "Folio abierto",
        global string MOTIVO_INGRESO 		{ get; set; }	//"MOTIVO_INGRESO": "CIRUGIA",
        global string NOMBRE_DE_USUARIO 	{ get; set; }	//"NOMBRE_DE_USUARIO": "User2",
        global Date FECHA_ANULACION 		{ get; set; }	//"FECHA_ANULACION": "2025-02-09T00:00:00",
        global string MOTIVO_ANULACION 		{ get; set; }	//"MOTIVO_ANULACION": null,       
        global Date FECHA_CIERRE_CUENTA 	{ get; set; }	//"FECHA_CIERRE_CUENTA": "2025-02-20T00:00:00",
        global string PROPIETARIO 			{ get; set; }   //"PROPIETARIO": "005al000005BTmGAAW"   
        global string SF_CASO_ID			{ get; set; }	//Nuevo
        global string SF_PRESUPUESTO_ID	    { get; set; }	//Nuevo

    }

    
    global class E_Response {
        public Boolean success 				{ get; set; }
        public String message 				{ get; set; }
        public List<E_FolioAgregado> data 	{ get; set; }
        
        public E_Response() {
            this.data = new List<E_FolioAgregado>();
        }
    }

    //Llamar a esta clase 
    //class E_ResponseData {
    class E_FolioAgregado {        
        private Integer FICH_ID		 			{ get; set; }
        private string SALESFORCE_FOLIO_ID 		{ get; set; }
        private string ESTADO_TRANSMISION_ID	{ get; set; }
        private string MENSAJE			 		{ get; set; }
    }
     
    
    @HttpPost
	global static E_Response addFolios(List<E_Parameters> nuevosFolios) {
		Map<Integer, FALP_Folio__c> mapFolio = new Map<Integer, FALP_Folio__c>();
        Map<Integer, string> mapErrorFolio;
        Map<string, string> mapPresupuestosIdSalesforceOracle = new Map<string, string>();
        Map<string, string> mapPresupuestosIdCasoId = new Map<string, string>();
        List<FALP_RelacionPresupuestoFolio__c> eRelacionesPresFolio = new List<FALP_RelacionPresupuestoFolio__c>();    
        List<Integer> lstKeyFolios = new List<Integer>();
        List<string> PresupuestosId = new List<string>();
        List<string> CasosId = new List<string>();
        List<Case> Casos = new List<Case>();
        Database.upsertResult[] resultMapFolio;            
        E_Response eResponse = new E_Response();
        E_FolioAgregado eFolioAgregado;
        
        //List<ClinicalServiceRequest> ltsPlanTto = [SELECT CaseId__c FROM ClinicalServiceRequest WHERE Id = :idSplanesTtos];

        
        
        //---------------------------------OBTENER CASOS DE LOS PRESUESTOS ------------------------------------------------------
        //----------------- Antes 
        //for (E_Parameters eFolio : nuevosFolios) {
        //    mapFolio.put(eFolio.FICH_ID, addFolio(eFolio));
 		//	  lstKeyFolios.add(eFolio.FICH_ID);
        //    PresupuestosId.add(eFolio.SF_PRESUPUESTO_ID);
        //}
        ////Mapear id de los presupuestos entre los Ids de Oracle v/s SF y su caso asociado
		//for(Opportunity presupuestos : [SELECT Id, CC_PP_NPRESUPUESTO__c, CaseId__c FROM Opportunity WHERE Id in: PresupuestosId]){
        //    //Mapear id de los presupuestos entre los Ids de Oracle v/s SF
        //  	mapPresupuestosIdSalesforceOracle.put(presupuestos.Id,presupuestos.CC_PP_NPRESUPUESTO__c);        
        //    // obtener los casos que deben ser actualizados
        //    CasosId.add(presupuestos.CaseId__c);
        //}        
        //---------------- Ahora
        for (E_Parameters eFolio : nuevosFolios) {
 			PresupuestosId.add(eFolio.SF_PRESUPUESTO_ID);            
        }
		for(Opportunity presupuestos : [SELECT Id, CC_PP_NPRESUPUESTO__c, CaseId__c FROM Opportunity WHERE Id in: PresupuestosId]) {
            //Mapear Presupuesto Casos del presuepesto
            mapPresupuestosIdCasoId.put(presupuestos.Id, presupuestos.CaseId__c);   

            //Mapear id de los presupuestos entre los Ids de Oracle v/s SF
            mapPresupuestosIdSalesforceOracle.put(presupuestos.Id,presupuestos.CC_PP_NPRESUPUESTO__c);
            
            // obtener los casos que deben ser actualizados
            CasosId.add(presupuestos.CaseId__c);        
        }
        for (E_Parameters eFolio : nuevosFolios) {
            eFolio.SF_CASO_ID = mapPresupuestosIdCasoId.get(eFolio.SF_PRESUPUESTO_ID);
            mapFolio.put(eFolio.FICH_ID, addFolio(eFolio));
 			lstKeyFolios.add(eFolio.FICH_ID);
        }        
		//----------------------------------------------------------------------------------------------------
        

        
        
        Schema.SObjectField field_F = FALP_Folio__c.Fields.Id_Externo__c;
        mapErrorFolio = errorResults(lstKeyFolios, Database.upsert(mapFolio.values(), field_F, false));

        //Obtener los CasosId que deben ser actualizados
        for(case Caso : [SELECT Id FROM case WHERE id in: CasosId AND status ='Agendado, pendiente folio' AND FALP_Estado_de_Folio__c = 'Pendiente']){
            Caso.FALP_Estado_de_Folio__c = 'Generado';
			Casos.add(Caso);
        }
        
        //Actualizar Estado agendamiento de los casos
        Update(Casos);
        
        for (E_Parameters eFolio : nuevosFolios) {
			eFolioAgregado = new E_FolioAgregado();
            
            eFolioAgregado.FICH_ID = eFolio.FICH_ID;

	        if (!mapFolio.containsKey(eFolio.FICH_ID) || (mapFolio.containsKey(eFolio.FICH_ID) && mapFolio.get(eFolio.FICH_ID).Id == null)) {
                eFolioAgregado.ESTADO_TRANSMISION_ID 	= 'NOK';
                eFolioAgregado.MENSAJE			   		=  mapErrorFolio.get(eFolio.FICH_ID);
            } else {
                eFolioAgregado.ESTADO_TRANSMISION_ID 	= 'OK';
                eFolioAgregado.MENSAJE			   		=  null;
                eFolioAgregado.SALESFORCE_FOLIO_ID  = mapFolio.get(eFolio.FICH_ID).Id;

				//insertar relacion Presupuesto Folio               
                eRelacionesPresFolio.Add(addRelacionPresFolio(eFolio, mapFolio.get(eFolio.FICH_ID).Id, mapPresupuestosIdSalesforceOracle.get(eFolio.SF_PRESUPUESTO_ID)));
                

            }

			eResponse.data.Add(eFolioAgregado);            
        }
        
        
        if (eRelacionesPresFolio.size() > 0){            
            //upsert eRelacionesPresFolio; //---> //Database.upsert(eRelacionesPresFolio, field_F, false);//---> cual seria el campo para hacer el upsert???
            
            //Schema.SObjectField field_RPF = FALP_RelacionPresupuestoFolio__c.Fields.Folio_Id__c;		            
            Schema.SObjectField field_RPF = FALP_RelacionPresupuestoFolio__c.Fields.FALP_PresFolio_Id_Externo__c;		            
            Database.upsert(eRelacionesPresFolio, field_RPF, false);	//---> cual seria el campo para hacer el upsert???
            
            
			// aqui agregar el arreglo para actualizar el estado a "Agendado Por Integracion" del caso 
            //PlanesId.add(ePabellon.PLAN_ID);
        }
        
		eResponse.success = true;
        eResponse.message = null;
        
        return eResponse;  
    }    

    
	private static FALP_Folio__c addFolio(E_Parameters eFolio) {		
        FALP_Folio__c F = new FALP_Folio__c(); 

        	//F.id							= eFolio.SALESFORCE_FOLIO_ID;
            F.FALP_Estado__c 				= eFolio.ESTADO;
            F.FALP_FechaCierreCuenta__c 	= eFolio.FECHA_CIERRE_CUENTA;
            F.FALP_FechaAnulacion__c 		= eFolio.FECHA_ANULACION;
            F.FALP_FechaFolio__c			= eFolio.FECHA_FOLIO;
            F.FALP_FechaHospitalizacion__c	= eFolio.FECHA_HOSPITALIZACION;
            F.FALP_MotivoAnulacion__c 		= eFolio.MOTIVO_ANULACION;//'testHP'; // 
            F.FALP_MotivoIngreso__c			= eFolio.MOTIVO_INGRESO;
            F.Name							= String.valueOf(eFolio.FICH_ID);
        	F.Id_Externo__c					= eFolio.FICH_ID;
            F.FALP_NombreUsuario__c			= eFolio.NOMBRE_DE_USUARIO;
            F.OwnerId						= eFolio.PROPIETARIO;       
        
        return F;
     }
    
    
    private static FALP_RelacionPresupuestoFolio__c addRelacionPresFolio(E_Parameters eFolio, id folioId, String PresupuestoOracleId) {	
    	FALP_RelacionPresupuestoFolio__c RPF = new FALP_RelacionPresupuestoFolio__c(); 
        
        RPF.Folio_Id__c					 = String.valueOf(eFolio.FICH_ID);	//--> Es necesario si hariamos un select por los que ya existen?        
        RPF.CC_PP_Folio__c				 = folioId;
        RPF.CC_PP_Presupuesto__c		 = eFolio.SF_PRESUPUESTO_ID;
		RPF.FALP_Caso__c				 = eFolio.SF_CASO_ID;
        RPF.Name 						 = PresupuestoOracleId + '-F'+ String.valueOf(eFolio.FICH_ID);
        RPF.FALP_PresFolio_Id_Externo__c = PresupuestoOracleId + '-'+ String.valueOf(eFolio.FICH_ID);
        ////rfolioPres.Name = 'Pres'+presupuesto.Name+' - F'+caso.cc_pp_nfolio__c;
        //RPF.Name = 'Pres' + eFolio.FICH_ID+' - F'+ folioId;
                
        return RPF;
	}
    
    
   	private static Map<Integer, String> errorResults(List<Integer> keys, Database.upsertResult[] resultsUpserts){
        Map<Integer, string> mapResultsErrors = new Map<Integer, string>();
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

/*    
    @HttpPost
	global static E_Response addFolios(List<E_Parameters> nuevosFolios) {  
        E_Response eResponse = new E_Response();                
        
        try {
            for (E_Parameters eFolio : nuevosFolios) {
                eResponse.data.Add(addFolio(eFolio));                
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
    
    
    private static E_FolioAgregado addFolio(E_Parameters eFolio) {
        FALP_Folio__c F = new FALP_Folio__c(); 
        E_FolioAgregado eFolioAgregado = new E_FolioAgregado();
		
        try {
            F.FALP_Estado__c 				= eFolio.ESTADO;
            F.FALP_FechaCierreCuenta__c 	= eFolio.FECHA_CIERRE_CUENTA;
            F.FALP_FechaAnulacion__c 		= eFolio.FECHA_ANULACION;
            F.FALP_FechaFolio__c			= eFolio.FECHA_FOLIO;
            F.FALP_FechaHospitalizacion__c	= eFolio.FECHA_HOSPITALIZACION;
            F.FALP_MotivoAnulacion__c 		= eFolio.MOTIVO_ANULACION;//'testHP'; // 
            F.FALP_MotivoIngreso__c			= eFolio.MOTIVO_INGRESO;
            F.Name							= eFolio.FICH_ID;   // cual dejamos aqui? o NUMERO_DE_FOLIO; ??
            F.FALP_NombreUsuario__c			= eFolio.NOMBRE_DE_USUARIO;
            F.OwnerId						= eFolio.PROPIETARIO;
             
            upsert F;
            
            eFolioAgregado.FICH_ID 				 = F.Name;
            eFolioAgregado.SALESFORCE_FOLIO_ID   = F.Id;
            eFolioAgregado.ESTADO_TRANSMISION_ID = 'OK';
            eFolioAgregado.MENSAJE 				 = NULL;
        }
       	catch (Exception e) {
            eFolioAgregado.FICH_ID     			 = eFolio.FICH_ID;
            eFolioAgregado.SALESFORCE_FOLIO_ID   = F.Id;
            eFolioAgregado.ESTADO_TRANSMISION_ID = 'NOK';
          	eFolioAgregado.MENSAJE 				 = e.getMessage();
       	}           
        
        return eFolioAgregado;        
    }
*/