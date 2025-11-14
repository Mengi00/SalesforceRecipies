@RestResource(urlMapping='/CL_AddPlanesDeTratamientos')
global with sharing class CL_AddPlanesDeTratamientos {
    global class E_Parameters {
        global Boolean  UPDATE_SOLO_PT                  { get; set; }
        global String   SALESFORCE_ENCUENTR_CLINICO_ID  { get; set; }
        global String   SALESFORCE_PLAN_TRATAMIENTO_ID  { get; set; }
        global String   SALESFORCE_CASO_ID              { get; set; }
        global String   SALESFORCE_PROCEDIMI_MEDICO_ID  { get; set; }
        global string   EC_ID_EXTERNO    				{ get; set; }
        global String   EC_SUCURSAL						{ get; set; }
        global String   EC_CATEGORIA					{ get; set; }
        global String   EC_ESTADO					    { get; set; }
        global Boolean  PT_ANESTESISTA	 				{ get; set; }
        global Boolean  PT_APROBACION_INTERNA 			{ get; set; }
        global Boolean  PT_COMANDO 						{ get; set; }
        global Integer  PT_CPLAN_ID	 					{ get; set; }
        global Integer  PT_CPQD_ID 						{ get; set; }
        global String   PT_ESTADO_PLAN_DE_TRATAMIENTO	{ get; set; }
        global datetime PT_FECHA_REGISTRO_REMI			{ get; set; }
        global Boolean  PT_GERIATRIA		 			{ get; set; }
        global String   PT_GSE 							{ get; set; }
        global String   PT_LATERALIDAD 					{ get; set; }
        global String   PT_MEDICO_TRATANTE				{ get; set; }
        global String   PT_NUMERO_PLAN_DE_TRATAMIENTO 	{ get; set; }
        global String   PT_PACIENTE_ID 					{ get; set; }
        global Boolean  PT_PACIENTE_APRUEBA_PRESUPUEST 	{ get; set; }
        global Boolean  PT_PAQUETIZADO		 			{ get; set; }
        global String  	PT_PLAN_CONVENIO_ONCOLOGICO 	{ get; set; }
        global String   PT_PLAZO_DE_INGRESO				{ get; set; }
        global String  	PT_PRIORIDAD 					{ get; set; }
        global String  	PT_PROCEDIMIENTO_PRINCIPAL 		{ get; set; }
        global String   PT_RIESGO_CLINICO				{ get; set; }
        global String   PT_TIPO_PLAN 					{ get; set; }
        global String   PT_TECNICA 						{ get; set; }
        global String   PT_TIPO 						{ get; set; }
        global String   PT_PLAN_PREVISIONAL				{ get; set; }
        global datetime PT_PLAN_TRATAMIENTO_CREADO_EL	{ get; set; }
        global String   PT_INSTRUCCIONES_DE_PACIENTE	{ get; set; }
        global String   PT_ESPECIALIDAD_CLINICA			{ get; set; }
		global String   PT_TIPO_DE_INGRESO   	   		{ get; set; }
        global String   PT_PROCEDIMIENTOS				{ get; set; }
        global String   PT_PATOLOGIA                    { get; set; }
        global Integer  PT_NUMERO_DE_CICLOS             { get; set; }
        global String   PT_ESQUEMA                      { get; set; }
        global Boolean  PT_CATETER                      { get; set; }
        global Datetime PT_CPLAN_EXPIRA_PLAN            { get; set; }
        global String   PT_CPLAN_CANDIDATO_A_PAGO       { get; set; }
        global DateTime PT_CPLAN_FECHA_ANULAR           { get; set; }
        global Integer  PT_NUMERO_DE_SESIONES           { get; set; }
        global Boolean  PT_VIGENCIA                     { get; set; }
        global String   PT_PREVISION					{ get; set; }
        global String   PM_ESTADO						{ get; set; }
        global String   PM_MOTIVO_DE_ESTADO_ID			{ get; set; }
        global String   PM_CODIGO						{ get; set; }
    }    
    
     
    global class E_Response {
        public Boolean success 				{ get; set; }
        public String message 				{ get; set; }
        public List<E_PlanDeTratamientoAgregado> data 	{ get; set; }
        
        public E_Response(){
            this.data = new List<E_PlanDeTratamientoAgregado>();
        }
    }   
    
    
	class E_PlanDeTratamientoAgregado {
        private Integer CPLAN_ID						{ get; set; }
        private Integer CPQD_ID							{ get; set; }
        private string SF_PLAN_DE_TRATAMIENTO_ID		{ get; set; }
        private string ENCUENTRO_CLINICO_ID 			{ get; set; }
        private string CASO_ID							{ get; set; }
        private string PROCEDIMIENTO_MEDICO_ID 			{ get; set; }
        private string ESTADO_TRANSMISION_ID			{ get; set; }
        private string MENSAJE			 				{ get; set; }
    }
    
    
    @HttpPost
	global static E_Response addPlanesDeTratamientos(List<E_Parameters> nuevosPlanesDeTratamientos) {
        Map<String, ClinicalEncounter> mapEncuentroCli = new Map<String, ClinicalEncounter>();
        Map<String, ClinicalServiceRequest> mapPlanTto = new Map<String, ClinicalServiceRequest>();
        List<String> lstkeyEncuentroCli = new List<String>();
        E_Response eResponse = new E_Response();
		E_PlanDeTratamientoAgregado ePlanDeTratamientoAgregado;        
        
        
        //try {
        //Construiir los encuentros clinicos
        for (E_Parameters eParams : nuevosPlanesDeTratamientos) {
	        if(!eParams.UPDATE_SOLO_PT) {
                eParams.EC_ID_EXTERNO = eParams.PT_CPLAN_ID != null ? String.valueOf(eParams.PT_CPLAN_ID) : 'Q' + String.valueOf(eParams.PT_CPQD_ID); //->eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO trae directamente si es quimio o no
                
    	        mapEncuentroCli.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO,addEncuentroClinico(eParams));
                lstkeyEncuentroCli.add(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
            }
        }
        

        
        //Database.upsertResult[] resultmapEncuentroCli = Database.upsert(mapEncuentroCli.values(), false);
        //Schema.SObjectField field_CE = ClinicalEncounter.Fields.FALP_N_Plan_de_Tratamiento__c;            
        Schema.SObjectField field_CE = ClinicalEncounter.Fields.Enc_Clinico_Id_Externo__c;            
        Database.upsertResult[] resultmapEncuentroCli = Database.upsert(mapEncuentroCli.values(),field_CE, false);            
        Map<String, string> mapErrorEclinico = errorResults(lstkeyEncuentroCli, resultmapEncuentroCli);
        List<String> lstkeyPlanTto = new List<String>();
        List<String> ltsCodeIdCSB = new List<String>();//lista de codesetbundles


        //procesar los planes de tratamiento
        for (E_Parameters eParams : nuevosPlanesDeTratamientos) {
        	if (eParams.UPDATE_SOLO_PT && eParams.SALESFORCE_ENCUENTR_CLINICO_ID != null){
            	mapPlanTto.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO, addPlanDeTratamiento(eParams, eParams.SALESFORCE_ENCUENTR_CLINICO_ID));
                lstkeyPlanTto.add(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
            } else if(mapEncuentroCli.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id != null){
                mapPlanTto.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO, addPlanDeTratamiento(eParams, mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id));
                lstkeyPlanTto.add(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
                
                //agregado de codigos de los procedimientos medicos para busqueda de paquetes de conjuntos de codigos
                ltsCodeIdCSB.add(eParams.PM_MOTIVO_DE_ESTADO_ID);
                ltsCodeIdCSB.add(eParams.PM_CODIGO);
                if (eParams.PT_PROCEDIMIENTOS != null && eParams.PT_PROCEDIMIENTOS != '') {
                	ltsCodeIdCSB.addAll(eParams.PT_PROCEDIMIENTOS.split(';'));
                }
            }
		}
        
        
        //Schema.SObjectField field_PTratamiento = ClinicalServiceRequest.Fields.CC_PP_NPLANDETRATAMIENTO__c;
        Schema.SObjectField field_PTratamiento = ClinicalServiceRequest.Fields.FALP_Pres_Id_Externo__c;
        //Database.upsertResult[] resultmapPlanTto = Database.upsert(mapPlanTto.values(), false);
        Database.upsertResult[] resultmapPlanTto = Database.upsert(mapPlanTto.values(),field_PTratamiento, false);
        Map<String, string> mapErrorPlanTto = errorResults(lstkeyPlanTto, resultmapPlanTto);
        
        
        //procesar FALP_RelacionPlanProcedimiento__c
        Map<String, CodeSetBundle> mapCodeSetBundle = new Map<String, CodeSetBundle>();
        if (ltsCodeIdCSB.Size() > 0){
			for(CodeSetBundle csb : [SELECT Id, CodeSet1.Code FROM CodeSetBundle WHERE CodeSet1.Code in: ltsCodeIdCSB]){
            	mapCodeSetBundle.put(csb.CodeSet1.Code, csb);
            }
        }
        
        
		Map<String, FALP_RelacionPlanProcedimiento__c> mapRplanProcedimiento = new Map<String, FALP_RelacionPlanProcedimiento__c>();
        List<String> lstkeyRPlanProcedimiento = new List<String>();
        
        for (E_Parameters eParams : nuevosPlanesDeTratamientos){
        	if (!eParams.UPDATE_SOLO_PT && eParams.PT_PROCEDIMIENTOS != null && eParams.PT_PROCEDIMIENTOS != '' && mapPlanTto.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id != null){
            	for (String eProc : (List<String>)eParams.PT_PROCEDIMIENTOS.split(';')){
					if (mapCodeSetBundle.containsKey(eProc)){
                    	mapRplanProcedimiento.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO+'-'+eProc,addProcedimiento(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id, 
                        mapCodeSetBundle.get(eProc).Id, eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO+'-'+eProc));
                        lstkeyRPlanProcedimiento.add(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO+'-'+eProc);
                    }
                }
            }
		}
        
        
		Map<String, string> mapErrorRProcedimiento = new Map<String, string>();
		if (mapRplanProcedimiento.size()>0){
		   	Schema.SObjectField field_Procedimiento = FALP_RelacionPlanProcedimiento__c.FALP_Id_R_Plan_Procedimiento__c;
            Database.upsertResult[] resultmapRPlanProcedimento = Database.upsert(mapRplanProcedimiento.Values(), field_Procedimiento, false);
            mapErrorRProcedimiento = errorResults(lstkeyRPlanProcedimiento, resultmapRPlanProcedimento);
            //System.debug('mapRplanProcedimiento.Values(): '+mapRplanProcedimiento.Values());
        }
        
        
		//consulta casos generados a los planes de tratamiento
        Set<Id> idSplanesTtos = new Set<Id>();
        for (ClinicalServiceRequest platto : mapPlanTto.values()){
        	idSplanesTtos.add(platto.Id);
        }
        
        
		List<ClinicalServiceRequest> ltsPlanTto = [SELECT Id, FALP_CaseId__c FROM ClinicalServiceRequest WHERE Id in :idSplanesTtos];
        Map<Id, ClinicalServiceRequest> mapPlanTtoCaso = new Map<Id, ClinicalServiceRequest>(ltsPlanTto);
        //procesar procedimientos medicos del paciente
        Map<String, PatientMedicalProcedure> mapPMPs = new Map<String, PatientMedicalProcedure>();
        Map<String, string> mapErrorPMP = new Map<String, string>();
        if (ltsCodeIdCSB.size()>0) {
        	//Crear map de codigos a medicoProcedimiento
            List<String> lstkeyPMP = new List<String>();
            for (E_Parameters eParams : nuevosPlanesDeTratamientos) {
            	if (eParams.PT_CPLAN_ID != null) { // Solo para registros NO Quimio 
                	if (!eParams.UPDATE_SOLO_PT && mapEncuentroCli.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id != null
                    	&& mapPlanTto.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id != null 
                        && mapCodeSetBundle.containsKey(eParams.PM_MOTIVO_DE_ESTADO_ID) && mapCodeSetBundle.containsKey(eParams.PM_CODIGO)) {
							System.debug('entra a crear medicoProcedimiento::: '+eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
                            mapPMPs.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO, addProcedimientoMedico(eParams, mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id, 
                            mapPlanTtoCaso.get(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id).FALP_CaseId__c, mapCodeSetBundle.get(eParams.PM_MOTIVO_DE_ESTADO_ID).Id,
                            mapCodeSetBundle.get(eParams.PM_CODIGO).Id));
                            lstkeyPMP.add(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
					} else if(!eParams.UPDATE_SOLO_PT) {
                            mapErrorPMP.put(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO, 'No se encontraron los parametros necesarios para la creacion del procedimiento médico.');
                    }
                }
			}
            
            if(mapPMPs.size()>0){
				Schema.SObjectField field_PMP = PatientMedicalProcedure.FALP_Id_Codigo_Externo__c;
                Database.upsertResult[] resultmapPMP = Database.upsert(mapPMPs.values(), field_PMP, false);
                mapErrorPMP.putAll(errorResults(lstkeyPMP, resultmapPMP));
            }
		}            

            for (E_Parameters eParams : nuevosPlanesDeTratamientos) {
                ePlanDeTratamientoAgregado = new E_PlanDeTratamientoAgregado();
                
                //try {
                    ePlanDeTratamientoAgregado.CPLAN_ID	= eParams.PT_CPLAN_ID;
                    ePlanDeTratamientoAgregado.CPQD_ID	= eParams.PT_CPQD_ID;
					// Agregar Encuentro Clinico
                    String errorMjs = '';
                    if((!eParams.UPDATE_SOLO_PT && !mapEncuentroCli.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO)) ||
                        (mapEncuentroCli.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id == null)){
                            errorMjs = mapErrorEclinico.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO);
                    }else{
                        ePlanDeTratamientoAgregado.ENCUENTRO_CLINICO_ID = eParams.SALESFORCE_ENCUENTR_CLINICO_ID != null ? eParams.SALESFORCE_ENCUENTR_CLINICO_ID : mapEncuentroCli.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id;
                    }
                    // Agregar Plan de Tratamiento
                    if(!mapPlanTto.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) ||
                        (mapPlanTto.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id == null)){
                        errorMjs =mapErrorPlanTto.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) ? errorMjs +' '+mapErrorPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) : errorMjs;
                    }else{
                        ePlanDeTratamientoAgregado.SF_PLAN_DE_TRATAMIENTO_ID = mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id;
                        // Agregar el caso relacionado
                        if(!mapPlanTtoCaso.containsKey(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id) ||
                            (mapPlanTtoCaso.containsKey(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id) && mapPlanTtoCaso.get(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id).FALP_CaseId__c == null)){
                            errorMjs =errorMjs+ ' Error al crear el caso';
                        }else{
                            ePlanDeTratamientoAgregado.CASO_ID = mapPlanTtoCaso.get(mapPlanTto.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id).FALP_CaseId__c;
                        }
                        if(mapErrorRProcedimiento != null && !mapErrorRProcedimiento.isEmpty() && eParams.PT_PROCEDIMIENTOS != null && eParams.PT_PROCEDIMIENTOS != ''){                            
                            for(String eProc : (List<String>)eParams.PT_PROCEDIMIENTOS.split(';')){
                                String llaveRPP = eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO+'-'+eProc;
                                if(mapErrorRProcedimiento.containsKey(llaveRPP)){
                                    errorMjs =mapErrorRProcedimiento.containsKey(llaveRPP) ? errorMjs +' Error RPP'+mapErrorRProcedimiento.get(llaveRPP) : errorMjs;
                                }
                            }
                        }
                    }
                    // Agregar el procedimiento medico del paciente
                    if((!eParams.UPDATE_SOLO_PT && !mapPMPs.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO)) || 
                        (mapPMPs.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) && mapPMPs.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id == null)){
                        errorMjs =mapErrorPMP.containsKey(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) ? errorMjs +' '+mapErrorPMP.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO) : errorMjs;
                    }else{
                        ePlanDeTratamientoAgregado.PROCEDIMIENTO_MEDICO_ID =eParams.SALESFORCE_PROCEDIMI_MEDICO_ID != null ? eParams.SALESFORCE_PROCEDIMI_MEDICO_ID : mapPMPs.get(eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO).Id;
                    }
                    // Agregado de errores de los distintos campos
                    ePlanDeTratamientoAgregado.ESTADO_TRANSMISION_ID = errorMjs != '' ? 'NOK' : 'OK';
                    ePlanDeTratamientoAgregado.MENSAJE				 = errorMjs != '' ? errorMjs : null;
                /*}
        		catch (Exception e) {
					ePlanDeTratamientoAgregado.ESTADO_TRANSMISION_ID	 = 'NOK';
                    ePlanDeTratamientoAgregado.MENSAJE					 = e.getMessage();
        		}*/
                eResponse.data.Add(ePlanDeTratamientoAgregado);
            }
            eResponse.success = true;
        	eResponse.message = null;
        /*}
        catch (Exception e) {
            eResponse.success = false;
        	eResponse.message = e.getMessage();
      	} */
        
        return eResponse;
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
    
    
    private static ClinicalEncounter addEncuentroClinico(E_Parameters eParams) {
        ClinicalEncounter CE = new ClinicalEncounter();

        //CE.Enc_Clinico_Id_Externo__c  = eParams.PT_CPLAN_ID != null ? String.valueOf(eParams.PT_CPLAN_ID) : 'Q' + String.valueOf(eParams.PT_CPQD_ID); //->eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO trae directamente si es quimio o no
		CE.Enc_Clinico_Id_Externo__c    = eParams.EC_ID_EXTERNO;
        CE.Category  					= eParams.EC_CATEGORIA; 				// 'Encounter';
        CE.Status 						= eParams.EC_ESTADO;					// 'Finished';
        CE.StartDate 					= eParams.PT_FECHA_REGISTRO_REMI.date();
        CE.PatientId 					= eParams.PT_PACIENTE_ID;				// id de la cuenta, no del contacto
        
        return CE;
    }
    
    
    //-----------------------------------------------------------------------------------------------------------------------------
    private static ClinicalServiceRequest addPlanDeTratamiento(E_Parameters eParams, string EncounterId) {
		ClinicalServiceRequest PT = new ClinicalServiceRequest();
        /*if(eParams.SALESFORCE_PLAN_TRATAMIENTO_ID != null && eParams.SALESFORCE_PLAN_TRATAMIENTO_ID != ''){
            PT.Id = eParams.SALESFORCE_PLAN_TRATAMIENTO_ID;
        }*/
        PT.cc_pp_Anestesista__c        		= eParams.PT_ANESTESISTA;            
        PT.cc_pp_AI__c                 		= eParams.PT_APROBACION_INTERNA;
        PT.cc_pp_Comando__c            		= eParams.PT_COMANDO;
        PT.CC_PP_CPLAN_ID_SICI__C      		= eParams.PT_CPLAN_ID != null ? eParams.PT_CPLAN_ID : eParams.PT_CPQD_ID;
        PT.CC_PP_EPLAN_SICI__c         		= eParams.PT_ESTADO_PLAN_DE_TRATAMIENTO;
        PT.CC_PP_FREGISTRO_REMI__c     		= eParams.PT_FECHA_REGISTRO_REMI.date();
        PT.CC_PP_GERIATRIA__c          		= eParams.PT_GERIATRIA;
        PT.CC_PP_GSE__c               		= eParams.PT_GSE;
        PT.CC_PP_LATERALIDAD__c        		= eParams.PT_LATERALIDAD;
        PT.CC_PP_MEDICOTRATANTE__c     		= eParams.PT_MEDICO_TRATANTE; 
        PT.CC_PP_NPLANDETRATAMIENTO__c 		= eParams.PT_NUMERO_PLAN_DE_TRATAMIENTO;
        PT.PatientId                   		= eParams.PT_PACIENTE_ID;
        PT.cc_pp_pap__c                		= eParams.PT_PACIENTE_APRUEBA_PRESUPUEST;
        PT.CC_PP_PAQUETIZADO__c        		= eParams.PT_PAQUETIZADO;
        PT.cc_pp_ConvenioO__c          		= eParams.PT_PLAN_CONVENIO_ONCOLOGICO;
        PT.CC_PP_TIPODEINGRESO__c     		= eParams.PT_PLAZO_DE_INGRESO;
        PT.Priority                  		= eParams.PT_PRIORIDAD;
        PT.CC_PP_PROC_PRIN__c        		= eParams.PT_PROCEDIMIENTO_PRINCIPAL;
        PT.CC_PP_RIESGO_CLINICO__c   	    = eParams.PT_RIESGO_CLINICO;
        PT.CC_PP_TIPO_PLAN__c         		= eParams.PT_TIPO_PLAN;
        PT.CC_PP_TECNICA__c           		= eParams.PT_TECNICA;
        PT.Type                       		= eParams.PT_TIPO;
        PT.cc_pp_convenio__c   		   		= eParams.PT_PLAN_PREVISIONAL;
        PT.CC_PP_FECHACPT__c   		   		= eParams.PT_PLAN_TRATAMIENTO_CREADO_EL.date();
        PT.cc_pp_CyIndicaciones__c     	   	= eParams.PT_INSTRUCCIONES_DE_PACIENTE;
        PT.cc_pp_Especialidad_Clinica__c	= eParams.PT_ESPECIALIDAD_CLINICA;
        PT.Tipo_de_ingreso__c    			= eParams.PT_TIPO_DE_INGRESO;
        PT.cc_pp_Patologia__c     			= eParams.PT_PATOLOGIA;
        PT.cc_pp_NoCiclos__c     			= eParams.PT_NUMERO_DE_CICLOS;
        PT.cc_pp_esquema__c     			= eParams.PT_ESQUEMA;
        PT.cc_pp_Cateter__c     			= eParams.PT_CATETER;
        PT.cc_pp_Plan_Expira__c    			= eParams.PT_CPLAN_EXPIRA_PLAN == null ? null : eParams.PT_CPLAN_EXPIRA_PLAN.date();
        PT.cc_pp_Candidato_a_pago__c		= eParams.PT_CPLAN_CANDIDATO_A_PAGO;
        PT.cc_pp_Fecha_anular__c   			= eParams.PT_CPLAN_FECHA_ANULAR;
        PT.FALP_Sucursal__c     			= eParams.EC_SUCURSAL;
        PT.cc_pp_Numero_de_Sesiones__c		= eParams.PT_NUMERO_DE_SESIONES;
        PT.cc_pp_Vigencia__c     			= eParams.PT_VIGENCIA;
        PT.EncounterId                 		= EncounterId;
        PT.FALP_Pres_Id_Externo__c			= eParams.PT_CPLAN_ID != null ? String.valueOf(eParams.PT_CPLAN_ID) : 'Q' + String.valueOf(eParams.PT_CPQD_ID);
        PT.FALP_Prevision__c				= eParams.PT_PREVISION;
        
        return PT;
	}
    

	//-----------------------------------------------------------------------------------------------------------------------------            
    private static FALP_RelacionPlanProcedimiento__c addProcedimiento(string PlanDeTratamientoId, string procedimientoId, String idLlaveExterna) {
        FALP_RelacionPlanProcedimiento__c tRpp = new FALP_RelacionPlanProcedimiento__c();
        
        tRpp.FALP_PlanTratamiento__c = PlanDeTratamientoId;
        tRpp.FALP_Procedimiento__c = procedimientoId;
        tRpp.FALP_Id_R_Plan_Procedimiento__c = idLlaveExterna;
        
        return tRpp;
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------
    //private static PatientMedicalProcedure addProcedimientoMedico(E_Parameters eParams, string ClinicalEncounterId, String caseId, String PM_MOTIVO_DE_ESTADO_IDSF, String PM_CODIGOSF) {
    private static PatientMedicalProcedure addProcedimientoMedico(E_Parameters eParams, string ClinicalEncounterId, String caseId, String PM_MOTIVO_DE_ESTADO_IDSF, String PM_CODIGOSF) {
		PatientMedicalProcedure PMP = new PatientMedicalProcedure();
        
        PMP.PatientId           		= eParams.PT_PACIENTE_ID;
        PMP.Status              		= eParams.PM_ESTADO;
        PMP.ReasonCodeId        		= PM_MOTIVO_DE_ESTADO_IDSF;
        PMP.CodeId              		= PM_CODIGOSF;
        //PMP.FALP_Id_Codigo_Externo__c = eParams.PM_CODIGO+'-'+eParams.PM_MOTIVO_DE_ESTADO_ID;
        PMP.FALP_Id_Codigo_Externo__c 	= String.valueOf(eParams.PT_CPLAN_ID) + '-' + eParams.PM_MOTIVO_DE_ESTADO_ID; //No se pregunta por PT_CPQD_ID porque no se ingresan PMP parta quimio
        PMP.ClinicalEncounterId 		= ClinicalEncounterId;
        PMP.FALP_CaseId__c      		= caseId;
        
        return PMP;
    }
}