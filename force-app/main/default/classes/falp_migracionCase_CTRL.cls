/**********************************************************************************************************************************************************************************
 * Nombre de la Clase Apex : falp_migracionCase_CTRL
 * Versión                 : 1.0
 * Fecha de Creación       : 07/01/2025
 * Funcionalidad           : Contiene metodos que ayudan a procesar y generar la estructura de objetos para casos migrados.
 * Clase de Prueba         : falp_migracionCase_test
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Isaías Osorio       07/01/2025       Versión inicial
 * 
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 **********************************************************************************************************************************************************************************/
public with sharing class falp_migracionCase_CTRL {
    /*public static void migrarCasosCerrados(){
        List<Case> listCase = [SELECT Id, AccountId, cc_pp_proc_prin__c, Sucursal__c, cc_pp_convenio__c, cc_pp_medicotratante__c, cc_pp_EPlan_sici__c,
        cc_pp_NPlandeTratamiento__c, cc_pp_Comando__c, cc_pp_FechaCPT__c, cc_pp_geriatria__c, cc_pp_Anestesista__c, cc_pp_STdT__c,
        cc_pp_CyIndicaciones__c, cc_pp_Especialidad_Clinica__c, cc_pp_ConvenioO__c, cc_pp_Riesgo_Clinico__c,
        Fecha_sugerida_de_cirug_a__c, Tipo_de_ingreso__c, cc_pp_EmisorPresupuesto__c, cc_pp_TdP__c,cc_pp_FRegistro_Remi__c,
        cc_pp_FdCP__c, cc_pp_NPresupuesto__c, cc_pp_honorarios__c, cc_pp_Valor_Presupuesto__c, F_cierre_Caso__c, cc_pp_nfolio__c,
        cc_pp_Inicio_Pabellon__c, cc_pp_termino_Pabellon__c, cc_pp_Fecha_Pabellon__c, cc_pp_ficha__c, Seguro_complementario__c,
        Abono__c, Monto_abono__c, Print_cta_bancaria_respaldo__c, Monto_motor__c, Cuotas_motor__c, Deudas_FALP__c, GSE__c, Nombre_2__c,
        Nombre_1__c, Parentesco_2__c, Parentesco_1__c, Renta_estimada_2__c, Profesi_n_o_lugar_de_trabajo_2__c,
        Renta_estimada_1__c, Profesi_n_o_lugar_de_trabajo_1__c 
        FROM Case 
        WHERE RecordType.DeveloperName =: 'ServiceRequest' AND FALP_Temp_por_Procesar__c =: true AND falp_Temp_Caso_Migrado__c =false];
        migrarCasos(listCase);
    }*/
    
    public static void migrarCasos(List<Case> listCase){
        //Traer la lista de casos no procesados
        Map<String, Case> mapCasos = new Map<String, Case>(listCase);
        //lista para almacenar los planes de tratamiento
        List<ClinicalServiceRequest> planesTratamiento = new List<ClinicalServiceRequest>();
        List<ClinicalEncounter> lsitEnClinicos = new List<ClinicalEncounter>();
        List<Opportunity> listPresupuesto = new List<Opportunity>();
        List<FALP_Folio__c> listFolios = new List<FALP_Folio__c>();
        List<PatientMedicalProcedure> listPmedicoPa = new List<PatientMedicalProcedure>();
        List<Account> ltsCuentas = new List<Account>();
        List<FALP_Evaluacion_Financiera__c> ltsEvaFinanciera = new List<FALP_Evaluacion_Financiera__c>();
        String idRTPresupuesto = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FALP_Presupuesto').getRecordTypeId();
        List<String> listPaqCodigos = new List<String>();
        //
        for(Case caso: mapCasos.values()){
            //sacar los codigos que se agregaran al plan de tratamiento relacionado
            if(String.isNotEmpty(caso.cc_pp_proc_prin__c)){
                listPaqCodigos.add(caso.cc_pp_proc_prin__c);
            }
            //planes de tratamiento
            planesTratamiento.add(crearPlanTratamiento(caso));
            //Encuentro clinico
            
            lsitEnClinicos.add(crearEncuentroClinico(caso));
            //presupuesto cargar solo si el caso.cc_pp_NPresupuesto__c != null
            if(caso.cc_pp_NPresupuesto__c != NULL){
                listPresupuesto.add(crearPresupuesto(caso, idRTPresupuesto));
            }
            //valores de folio
            if(caso.cc_pp_nfolio__c != null){
                listFolios.add(crearFolio(caso));
            }
            
            //valores procedimiento medico del paciente
            listPmedicoPa.add(crearProceMedicoPaciente(caso));
            //Datos para cuentas a actualizar, !En reunión se comenta que no se deben actualizar las cuentas!
            /*Account cuentaPaciente = new Account();
            cuentaPaciente.Id = caso.AccountId;
            cuentaPaciente.Ficha_Paciente__c = Decimal.valueOf(caso.cc_pp_ficha__c);//tem
            cuentaPaciente.FALP_Seguro_complementario__c = caso.Seguro_complementario__c;//tem
            ltsCuentas.add(cuentaPaciente);*/
            //Evaluación financiera
            FALP_Evaluacion_Financiera__c efinanciera = new FALP_Evaluacion_Financiera__c();
            //efinanciera.FAP_Caso__c = caso.Id;
            efinanciera.FALP_Abono__c = caso.Abono__c;//temp
            efinanciera.FALP_Monto_abono__c = caso.Monto_abono__c;//temp
            //efinanciera.FALP_Print_cta_bancaria_respaldo__c = caso.Print_cta_bancaria_respaldo__c;//temp
            efinanciera.FALP_Monto_motor__c = caso.Monto_motor__c;//temp
            efinanciera.FALP_Cuotas_motor__c = caso.Cuotas_motor__c;//temp
            //efinanciera.Deudas_FALP__c = caso.Deudas_FALP__c;//temp //guardar SI(¿donde se guarda el monto), NO
            //efinanciera.CC_PP_GSE__c = caso.GSE__c;//temp
            /* //por analisar
            efinanciera.FALP_Aval__c = caso.Nombre_2__c;//temp, Con el nombre buscar la cuenta personal o crearla
            efinanciera.FALP_Suscriptor__c = caso.Nombre_1__c//temp, Con el nombre buscar la cuenta personal o crearla
            efinanciera.FALP_Parentesco_Aval = caso.Parentesco_2__c;
            efinanciera.FALP_Parentesco_Suscriptor = caso.Parentesco_1__c;
            */
            caso.FALP_Temp_por_Procesar__c = false;
            caso.falp_Temp_Caso_Migrado__c = true;
        }
        Insert planesTratamiento;
        Insert lsitEnClinicos;
        Insert listPresupuesto;
        if(!listFolios.isEmpty()){
            Schema.SObjectField field_F = FALP_Folio__c.Fields.Id_Externo__c;
            Database.upsert(listFolios, field_F);
            //Upsert listFolios;
        }
        Insert listPmedicoPa;
        //Update ltsCuentas;
        System.debug('planesTratamiento::: '+planesTratamiento);
        System.debug('listPresupuesto::: '+listPresupuesto);
        System.debug('listFolios::: '+listFolios);
        System.debug('listPmedicoPa::: '+listPmedicoPa);
        //System.debug('ltsCuentas::: '+ltsCuentas);
        //Inicia "Relación Plan Procedimiento"
        List<FALP_RelacionPlanProcedimiento__c> listRPlanPro = new List<FALP_RelacionPlanProcedimiento__c>();
        //Consulta a los paquetes de codigo y plan de tratamiento
        List<CodeSetBundle> listPaqConjCods;
        if(!listPaqCodigos.isEmpty()){
            listPaqConjCods = [SELECT Id, CodeSet1.Name  FROM CodeSetBundle WHERE CodeSet1.Name =:listPaqCodigos];
        }
        for(ClinicalServiceRequest planTra : planesTratamiento){
            FALP_RelacionPlanProcedimiento__c rplanT =new FALP_RelacionPlanProcedimiento__c();
            if(listPaqConjCods != null && !listPaqConjCods.isEmpty()){
                for(CodeSetBundle paqcc : listPaqConjCods){
                    if(mapCasos.get(planTra.FALP_CaseId__c).cc_pp_proc_prin__c == paqcc.CodeSet1.Name){
                        rplanT.FALP_Procedimiento__c = paqcc.Id;
                    }
                }
            }
            for(ClinicalEncounter enClinico : lsitEnClinicos){
                if(enClinico.PatientId ==planTra.PatientId){
                    planTra.EncounterId = enClinico.Id;
                }
            }
            //agregando plan de tratamiento al presupuesto
            for(Opportunity presupuesto : listPresupuesto){
                if(presupuesto.CaseId__c == planTra.FALP_CaseId__c){
                    presupuesto.FALP_Plan_de_tratamiento__c= planTra.Id;
                }
            }
            rplanT.FALP_PlanTratamiento__c = planTra.Id;
            rplanT.FALP_Procedimiento_principal__c = true;//Valor de casilla true/false
            listRPlanPro.add(rplanT);
        }
        //Actualizamos los planes de tratamiento
        update planesTratamiento;
        update listPresupuesto;
        insert listRPlanPro;
        System.debug('listRPlanPro::: '+listRPlanPro);
        
        //Inicia "Relación de presupuesto Folio"
        List<FALP_RelacionPresupuestoFolio__c> listRpresuFolio = new List<FALP_RelacionPresupuestoFolio__c>();
        for(Case caso : mapCasos.values()){
            FALP_RelacionPresupuestoFolio__c rfolioPres =new FALP_RelacionPresupuestoFolio__c();
            //agregando el caso
            for(FALP_Folio__c folio : listFolios){
                if(String.valueOf(caso.cc_pp_nfolio__c) == folio.Name){
                    rfolioPres.CC_PP_Folio__c = folio.Id;
                    //rfolioPres.Folio_Id__c = String.valueOf(caso.cc_pp_nfolio__c);
                    rfolioPres.FALP_Caso__c= caso.Id;
                }
            }
            //Agregando el presupuesto(Oportunidad)
            for(Opportunity presupuesto : listPresupuesto){
                if(presupuesto.CaseId__c == caso.Id && caso.cc_pp_NPresupuesto__c != null){
                    rfolioPres.CC_PP_Presupuesto__c= presupuesto.Id;
                    rfolioPres.Name = presupuesto.Name+'-F'+caso.cc_pp_nfolio__c;
                }
            }
            if(rfolioPres.CC_PP_Folio__c != null && rfolioPres.CC_PP_Presupuesto__c != null){
                System.debug('rfolioPres::: '+rfolioPres);
                listRpresuFolio.add(rfolioPres);
            }
        }
        if(listRpresuFolio.Size() > 0){
            Insert listRpresuFolio;
        }
        System.debug('listRpresuFolio::: '+listRpresuFolio);
        update mapCasos.values();
    }
    public static ClinicalServiceRequest crearPlanTratamiento(Case caso){
        ClinicalServiceRequest planT = new ClinicalServiceRequest();
        planT.FALP_CaseId__c = caso.Id;
        planT.PatientId = caso.AccountId;
        planT.FALP_Sucursal__c = caso.Sucursal__c;//Campo vacio en la muestra
        planT.cc_pp_convenio__c = caso.cc_pp_convenio__c;
        planT.CC_PP_MEDICOTRATANTE__c = caso.cc_pp_medicotratante__c;
        planT.CC_PP_EPLAN_SICI__c = caso.cc_pp_EPlan_sici__c;
        planT.CC_PP_NPLANDETRATAMIENTO__c = caso.cc_pp_NPlandeTratamiento__c;
        planT.cc_pp_Comando__c = caso.cc_pp_Comando__c;
        planT.CC_PP_FECHACPT__c = caso.cc_pp_FechaCPT__c;
        planT.CC_PP_GERIATRIA__c = caso.cc_pp_geriatria__c;
        planT.cc_pp_Anestesista__c = caso.cc_pp_Anestesista__c;
        planT.CC_PP_TIPO_PLAN__c = caso.cc_pp_STdT__c == 'Quimioterapia' ? 'QUIMIO' : 'CLINICO';
        planT.cc_pp_CyIndicaciones__c = caso.cc_pp_CyIndicaciones__c;
        planT.cc_pp_Especialidad_Clinica__c = caso.cc_pp_Especialidad_Clinica__c;
        planT.cc_pp_ConvenioO__c = caso.cc_pp_ConvenioO__c;
        planT.CC_PP_RIESGO_CLINICO__c = caso.cc_pp_Riesgo_Clinico__c; 
        planT.CC_PP_TIPODEINGRESO__c = caso.Fecha_sugerida_de_cirug_a__c; //eParams.PT_PLAZO_DE_INGRESO;
        planT.CC_PP_PROC_PRIN__c = caso.cc_pp_proc_prin__c;
        planT.Tipo_de_ingreso__c = caso.Tipo_de_ingreso__c;
        planT.cc_pp_Plan_Expira__c = caso.cc_pp_Fecha_de_Vigencia__c;
        planT.Type = caso.cc_pp_STdT__c != null ? caso.cc_pp_STdT__c :'Quirurgico'; //se revisara a que campo hacer referencia
        //planT.PatientInstruction = caso.cc_pp_CyIndicaciones__c; //por evaluar con Karen
        planT.cc_pp_AI__c = caso.cc_pp_AI__c;
        //PT.CC_PP_CPLAN_ID_SICI__C         = //este campo no existe en el caso para el procesi de  migración revisar si esta pasando por la migracion de talend
        planT.CC_PP_FREGISTRO_REMI__c = caso.CC_PP_FREGISTRO_REMI__c;
        //PT.CC_PP_GSE__c // posiblemente se borrara este campo del plan de tratamiento
        planT.CC_PP_PAQUETIZADO__c = caso.cc_pp_paquetizado__c; //se debe agregar en el proceso de talend
        planT.Priority = caso.Priority;
        planT.CC_PP_TECNICA__c = caso.cc_ap_Descripci_n__c;
        planT.cc_pp_Patologia__c = caso.cc_pp_Patologia__c; //debe pasarlo por talend.
        planT.cc_pp_NoCiclos__c  = caso.cc_pp_NoCiclos__c;
        //cc_pp_IdCiclo__c debe revisar si lo agregara en el proceso de talend para pasarlo del caso(En el caso no existe el campo) al presupuesto.
        planT.cc_pp_esquema__c = caso.cc_pp_esquema__c; //falta agregarlo a talend
        planT.cc_pp_Cateter__c = caso.cc_pp_Cateter__c; //falta agregarlo a talend
        //PT.cc_pp_Numero_de_Sesiones__c		= eParams.PT_NUMERO_DE_SESIONES;//falta igual que CC_PP_CPLAN_ID_SICI__C *cc_pp_NoSesiones__c*
        planT.FALP_Prevision__c = caso.cc_pp_institucion__c;//PREVISION
        planT.CC_PP_CPLAN_ID_SICI__c = Decimal.valueOf(caso.SuppliedCompany);
        return planT;
    }
    public static ClinicalEncounter crearEncuentroClinico(Case caso){
        ClinicalEncounter enClinico = new ClinicalEncounter();
        enClinico.Category = 'Ambulatory';
        enClinico.Status = 'Finished';
        enClinico.StartDate = caso.cc_pp_FRegistro_Remi__c != null ?caso.cc_pp_FRegistro_Remi__c : Date.today();
        enClinico.EndDate = caso.cc_pp_FRegistro_Remi__c != null ?caso.cc_pp_FRegistro_Remi__c : Date.today();// agregado en startDate por ser el unico mostrado en el layout
        enClinico.PatientId = caso.AccountId;
        return enClinico;
    }
    public static Opportunity crearPresupuesto(Case caso, String idRTPresupuesto){
        Opportunity presupuesto = new Opportunity();
        presupuesto.CaseId__c = caso.Id;
        presupuesto.AccountId = caso.AccountId;
        presupuesto.Medico_Tratante__c = caso.cc_pp_medicotratante__c;
        presupuesto.CC_PP_EMISORPRESUPUESTO__c = caso.cc_pp_EmisorPresupuesto__c;
        presupuesto.CC_PP_TDP__c = caso.CC_PP_TDP__c;
        presupuesto.CloseDate = caso.cc_pp_FdCP__c;
        presupuesto.cc_pp_FdCP__c = caso.cc_pp_FdCP__c;
        presupuesto.CC_PP_NPRESUPUESTO__c = caso.cc_pp_NPresupuesto__c;
        presupuesto.CC_PP_HONORARIOS__c = caso.cc_pp_honorarios__c;
        presupuesto.Amount = caso.cc_pp_Valor_Presupuesto__c;
        presupuesto.Name =caso.cc_pp_NPresupuesto__c;
        presupuesto.RecordTypeId = idRTPresupuesto; //FALP_Presupuesto
        presupuesto.StageName = 'Nuevo';//Continua en analisis.
        presupuesto.CC_PP_ESTADO_PPTO_SICI__c = caso.cc_pp_Estado_Ppto_sici__c;
        presupuesto.cc_pp_IdCiclo__c = caso.cc_ap_numerodegestion__c != null ? Decimal.valueOf(caso.cc_ap_numerodegestion__c) : null;
        return presupuesto;
    }
    public static FALP_Folio__c crearFolio(Case caso){
        FALP_Folio__c folio = new FALP_Folio__c();
        folio.FALP_FechaFolio__c = caso.F_cierre_Caso__c;
        folio.Name = String.valueOf(caso.cc_pp_nfolio__c);
        folio.Id_Externo__c = caso.cc_pp_nfolio__c;
        return folio;
    }
    public static PatientMedicalProcedure crearProceMedicoPaciente(Case caso){
        PatientMedicalProcedure proMediPaci = new PatientMedicalProcedure();
        proMediPaci.FALP_CaseId__c = caso.Id;
        proMediPaci.PatientId = caso.AccountId;
        if(caso.cc_pp_Fecha_Pabellon__c != null){//Si no hay fecha no se agregan los valores
            proMediPaci.StartDate = DateTime.valueOf(caso.cc_pp_Fecha_Pabellon__c+ ' ' + (caso.cc_pp_Inicio_Pabellon__c != null ? caso.cc_pp_Inicio_Pabellon__c : '00:00:00'));//temp
            proMediPaci.EndDate = DateTime.valueOf(caso.cc_pp_Fecha_Pabellon__c+ ' ' + (caso.cc_pp_termino_Pabellon__c != null ? caso.cc_pp_termino_Pabellon__c : '00:00:00'));//temp
        }
        proMediPaci.Status = 'Completed';//
        return proMediPaci;
    }
}