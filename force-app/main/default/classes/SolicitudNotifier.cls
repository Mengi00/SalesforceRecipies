@RestResource(urlMapping='/api/SolicitudNotifier')
global with sharing class SolicitudNotifier {
    
    public static final Map<String, Map<String, String>> PROCESOS_Y_ESTADOS = new Map<String, Map<String, String>>{
        'Beneficencia' => new Map<String, String>{
            '1' => 'En Proceso',//Solo actualiza
            '2' => 'Aprobado',//avanza
            '3' => 'Rechazado',//devuelve a EF
            '4' => 'Reagendado',//solo actualiza caso
            '5' => 'Caso no Presentado',//devuelve a EF
            '6' => 'Anulado'//devuelve a EF
            },
        'Contraloría' => new Map<String, String>{
            'ESTINGRE' => 'Ingresado',
            'ESTPENDI' => 'Pendiente',
            'ESTNOASO' => 'No Asociado', 
            'ASOCIADO TERMINAL' => 'Asociado Parcial',
            'ASOCIADO PARCIAL' => 'Asociado Terminal'    
            },
        'Comite' => new Map<String, String>{
            'Agendado a comité' => 'Agendado a comité',
            'Anulada' => 'Anulada',
            'Con resolución de comité' => 'Con resolución de comité'
            },
        'Pabellon' => new Map<String, String>{
            '1' => 'Reservada',
            '2' => 'Aprobada',
            '3' => 'Rechazada',
            '4' => 'Confirmada',
            '5' => 'No Confirmada',
            '6' => 'Suspendida',
            '7' => 'Reprogramada',
            '8' => 'Anulada'
            }
    };
        
    public static final Map<String, Map<String, String>> PLANTILLAS_DESCRIPCION = new Map<String, Map<String, String>>{
        'Beneficencia' => new Map<String, String>{
            '1' => 'En Proceso',
            '2' => 'Aprobado',
            '3' => 'Rechazado',
            '4' => 'Reagendado',
            '5' => 'Caso no Presentado',
            '6' => 'Anulado'
            },
        'Contraloría' => new Map<String, String>{
            'ESTINGRE' => 'Con fecha {0}, el usuario {1} reporta esta ingresado por contraloría médica ',
            'ESTPENDI' => 'Con fecha {0}, el usuario {1} reporta esta pendiente por contraloría médica.',
            'ESTNOASO' => 'Con fecha {0}, el usuario {1} reporta no esta asociada por contraloría médica.',         
            'ASOCIADO TERMINAL' => 'Con fecha {0} , el usuario {1} reporta esta asociado terminal por contraloría médica.',
            'ASOCIADO PARCIAL' => 'Con fecha {0} , el usuario {1} reporta esta asociado parcialmente por contraloría médica.'    
            },
            'Comite' => new Map<String, String>{
                'Agendado a comité' => 'Con fecha {0} es {1} el comité {2} cuyo diagnóstico es {3} para el día {4}',
                'Anulada' => 'Con fecha {0} es {1} el comité {2} cuyo diagnóstico {3}',
                'Con resolución de comité' => 'Con fecha {0} se deja el caso {1} , el comité {2} cuyo diagnóstico es {3}'
                },
                'Pabellon' => new Map<String, String>{
                    '1' => 'Reservada',
                    '2' => 'Aprobada',
                    '3' => 'Rechazada',
                    '4' => 'Confirmada',
                    '5' => 'No Confirmada',
                    '6' => 'Suspendida',
                    '7' => 'Reprogramada',
                    '8' => 'Anulada'
                }
    }; 
            
    public static final Map<String, Map<String, List<String>>> PARAMS_MAP = new Map<String, Map<String, List<String>>>{
        'Beneficencia' => new Map<String, List<String>>{
            '1' => new List<String>{'UsuarioNotificador', 'FechaMovimiento'},
            '2' => new List<String>{'UsuarioNotificador', 'FechaMovimiento'}
        },
        'Comite' => new Map<String, List<String>>{
            'Agendado a comité' => new List<String>{'FechaMovimiento', 'EstadoMovimiento', 'BloqueAgendado', 'CodigoDiagnostico', 'FechaAgendamiento'},
            'Anulada' => new List<String>{'FechaMovimiento', 'EstadoMovimiento', 'BloqueAgendado', 'CodigoDiagnostico'},
            'Con resolución de comité' => new List<String>{'FechaResolucion', 'EstadoMovimiento', 'BloqueAgendado', 'CodigoDiagnostico'}
        },
        'Pabellon' => new Map<String, List<String>>{
            '1' => new List<String>{''},
            '2' => new List<String>{''},
            '3' => new List<String>{''},
            '4' => new List<String>{''},
            '5' => new List<String>{''},
            '6' => new List<String>{''},
            '7' => new List<String>{''},
            '8' => new List<String>{''}
            },'Contraloría' => new Map<String, List<String>>{
                'ESTINGRE' => new List<String>{'FechaMovimiento','UsuarioNotificador'},
                'ESTPENDI' => new List<String>{'FechaMovimiento','UsuarioNotificador'},
                'ESTNOASO' => new List<String>{'FechaMovimiento','UsuarioNotificador'},  
                'ASOCIADO TERMINAL' => new List<String>{'FechaMovimiento','UsuarioNotificador'},
                'ASOCIADO PARCIAL' => new List<String>{'FechaMovimiento','UsuarioNotificador'}  
            }
    };
    public class DatosDocumento {
        public String ProcesoOrigen { get; set; }
        public String CasoNumberSalesforce { get; set; }
        public Decimal  CasoNumberOrigen { get; set; }
        public String EstadoMovimiento { get; set; }
        public String UsuarioNotificador { get; set; }
        public String EsEstadoTerminal { get; set; }
        public String FechaMovimiento { get; set; }
        public String RutPaciente { get; set; }
        public String NumPresupuesto { get; set; }
        public String NumPlanTratamiento { get; set; }
        public String Observacion { get; set; }
        public String FechaSolicitud { get; set; }
        public String FechaAgendamiento { get; set; }
        public String BloqueAgendado { get; set; }
        public String CodigoDiagnostico { get; set; }
        public String FechaResolucion { get; set; }
        public List<Documento> Documentos { get; set; }
    }
    
    public class Documento {
        public String Codificacion { get; set; }
        public String UrlCorta { get; set; }
        public String TipoArchivo { get; set; }
        public String NombreArchivo { get; set; }
        public String Formato { get; set; }
        public String UrlDescarga { get; set; }
        public String CodigoBase64 { get; set; }
    }
    
    public class ResultadoProcesamiento {
        public String idArchivo;
        public String nombre;
        public String mensajeError;
        
        public ResultadoProcesamiento(String idArchivo, String nombre, String mensajeError) {
            this.idArchivo = idArchivo;
            this.nombre = nombre;
            this.mensajeError = mensajeError;
        }
    }
    public class DocumentosRequestException extends Exception{
        public String message;
    }
    public class DocumentosProcesadosResponse  {
        public String message;
        public String idCaso;
        public List<ResultadoProcesamiento> resultados;
        
        public DocumentosProcesadosResponse(String message, String idCaso, List<ResultadoProcesamiento> resultados) {
            
            this.message = message;
            this.idCaso = idCaso;
            this.resultados = resultados;
        }
    }
    
    public static ResultadoProcesamiento insertarDocumento(String nombreArchivo, String contenidoBase64, Id idEvento, String formato, String url) {
        try {
            ContentVersion version;
            if (formato == 'URL') {
                
                // Si el formato es URL, asignar la URL al ContentVersion
                
                version = new ContentVersion(
                    Title = nombreArchivo,  
                    ContentUrl = url,
                    VersionData = null // Debe ser nulo si el archivo no se está cargando directamente
                    
                );
            } else {
                // Si no es URL, usar el contenido Base64
                version = new ContentVersion(
                    Title = nombreArchivo,
                    VersionData = EncodingUtil.base64Decode(contenidoBase64),
                    PathOnClient = nombreArchivo + '.pdf' // Agregar extensión según el tipo de archivo
                );
            }
            
            // Insertar el ContentVersion y obtener su ID
            insert version;
            String idVersion = version.Id;
            
            // Crear un nuevo ContentDocumentLink para relacionar el documento con un registro
            ContentDocumentLink link = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :idVersion].ContentDocumentId,
                LinkedEntityId = idEvento
            );
            
            // Insertar el ContentDocumentLink
            insert link;
            
            
            return new ResultadoProcesamiento(idVersion, nombreArchivo, 'Documento registrado correctamente');
        } catch (Exception e) {
            
            String mensajeError = 'Error al insertar el documento: ' + e.getMessage();
            return new ResultadoProcesamiento(null, nombreArchivo, mensajeError);
        }
    }
    public static Id  crearEvento(String nombreEvento, Datetime fechaHoraInicio,
                                  Datetime fechaHoraFin, String descripcion, Id idCaso, Id contacto) {
        //Case caso = [SELECT ContactId FROM Case WHERE Id = :idCaso LIMIT 1];
        
        Event nuevoEvento = new Event();
        nuevoEvento.Subject = nombreEvento;
        nuevoEvento.StartDateTime = fechaHoraInicio;
        nuevoEvento.EndDateTime = fechaHoraFin;
        nuevoEvento.Description = descripcion;
        //nuevoEvento.ActivityDate = fechaHoraInicio.date();
        nuevoEvento.IsAllDayEvent = true;
        nuevoEvento.WhatId = idCaso; // Relacionar el evento con el caso
        //if (caso.ContactId != null) {
        nuevoEvento.WhoId = contacto;
        //}                                       
        
        try {
            insert nuevoEvento;
            return nuevoEvento.Id;
            
        } catch (Exception e) {
            System.debug('Error al insertar el evento: ' + e.getMessage());
            
            return null; // Devolver null si hubo un error
        }
        
        
    }
    public static Id obtenerIdCaso(String rutPaciente, String numPlanTratamiento,String salesforceId, String proceso) {
        System.debug('Entrando a obtenerIdCaso::: ');
        if (proceso == 'Beneficencia' || proceso == 'Contraloría'){
            List<Case> casos = [SELECT Id FROM Case WHERE Id = :salesforceId  LIMIT 1];
            return !casos.isEmpty() ? casos[0].Id : null;
        }else{
            if (numPlanTratamiento != null && numPlanTratamiento != '') {
                // Convierte el número del plan de tratamiento a Decimal
                // 
                
                
                // Realiza la consulta para obtener el ID del caso
                //List<Case> casos = [SELECT Id FROM Case WHERE Rut__c = :rutPaciente AND Numero_Plan_de_Tratamiento__c = :numPlanTratamientoDecimal LIMIT 1];
                List<Case> casos = [SELECT Id FROM Case WHERE Rut__c = :rutPaciente And cc_pp_NPlandeTratamiento__c= :numPlanTratamiento ORDER BY CaseNumber DESC LIMIT 1];
                // Verifica si se encontró un caso y devuelve su ID, o devuelve null si no se encontró ninguno
                return !casos.isEmpty() ? casos[0].Id : null;  
            }else{
                return null;
            }
        }             
    }
    
    public static void actualizarCampo(String idCaso, String nuevoEstado) {
        // Crea un nuevo objeto Case con el ID del caso que deseas actualizar
        Case caso = new Case(Id = idCaso);
        
        // Establece el nuevo valor para el campo personalizado Estado_Beneficencia__c
        //caso.Estado_Beneficencia__c = nuevoEstado;
        
        // Utiliza DML para actualizar el caso
        try {
            update caso;
            System.debug('Campo Estado_Beneficencia__c actualizado con éxito en el caso con ID: ' + idCaso);
        } catch (Exception e) {
            System.debug('Error al actualizar el campo Estado_Beneficencia__c: ' + e.getMessage());
        }
    }
    
    public static String obtenerDescripcionEstado(Map<String, Map<String, String>> procesosYEstados, String proceso, String estado) {
        if (!procesosYEstados.containsKey(proceso)) {
            return 'Error: No se encontró el proceso "' + proceso + '".';
        }
        
        Map<String, String> estadosDelProceso = procesosYEstados.get(proceso);
        System.debug('estadosDelProceso::: '+estadosDelProceso);
        if (estadosDelProceso.containsKey(estado)) {
            return '';
        } else {
            return 'Error: No se encontró el estado "' + estado + '" para el proceso "' + proceso + '".';
        }
    }
    public static String obtenerEstado(Map<String, Map<String, String>> procesosYEstados, String proceso, String codigoEstado) {
        // Verificar si el proceso existe en el mapa
        if (procesosYEstados.containsKey(proceso)) {
            // Obtener el mapa de estados del proceso
            Map<String, String> estadosProceso = procesosYEstados.get(proceso);
            
            // Verificar si el código de estado existe en el mapa de estados
            if (estadosProceso.containsKey(codigoEstado)) {
                // Obtener el valor del estado correspondiente al código
                return estadosProceso.get(codigoEstado);
            }
        }
        // Retornar un mensaje de error si no se encuentra el estado
        return 'Estado no encontrado';
    }
    
    public static String modificarDescripcionEstado(String proceso, String estado, List<String> parametros) {
        // Verifica si existe una plantilla para el proceso
        if (PLANTILLAS_DESCRIPCION.containsKey(proceso)) {
            // Obtiene las plantillas del proceso
            Map<String, String> plantillasEstado = PLANTILLAS_DESCRIPCION.get(proceso);
            // Obtiene la plantilla específica del estado
            String plantillaDescripcion = plantillasEstado.get(estado);
            
            // Si no hay una plantilla específica, se utiliza una plantilla estándar
            if (plantillaDescripcion == null) {
                plantillaDescripcion = '';
                
            }
            
            // Reemplaza los marcadores en la plantilla con los parámetros
            for (Integer i = 0; i < parametros.size(); i++) {
                plantillaDescripcion = plantillaDescripcion.replace('{' + i + '}', (parametros[i] != null) ? parametros[i] : '');
            }
            return plantillaDescripcion;
            
            
        } else {
            return '';
        }
    }
    
    public static DocumentosRequestException procesarMovimiento(DatosDocumento obj, Id idCaso) {
        // Definir un mapa para mapear procesos de origen a campos obligatorios
        Map<String, Set<String>> camposObligatoriosPorProceso = new Map<String, Set<String>>{
            'Beneficencia' => new Set<String>{'ProcesoOrigen', 'CasoNumberSalesforce', 'EstadoMovimiento', 'UsuarioNotificador', 'FechaMovimiento'},
            'Contraloría' => new Set<String>{'ProcesoOrigen', 'CasoNumberSalesforce', 'EstadoMovimiento'},
            'Comite' => new Set<String>{'ProcesoOrigen', 'RutPaciente','EstadoMovimiento', 'NumPresupuesto', 'NumPlanTratamiento'},
            'Pabellon' => new Set<String>{'ProcesoOrigen', 'CasoNumberSalesforce','EstadoMovimiento', 'UsuarioNotificador', 'FechaMovimiento'}
        };
            
            String procesoOrigen = obj.ProcesoOrigen;
        DocumentosRequestException mensajeError = new  DocumentosRequestException();
        // Verificar si el proceso de origen es válido
        if (!camposObligatoriosPorProceso.containsKey(procesoOrigen)) {
            mensajeError.message='Error: Proceso de origen no válido.';
            return mensajeError;
        }
        
        // Obtener los campos obligatorios para el proceso de origen actual
        Set<String> camposObligatorios = camposObligatoriosPorProceso.get(procesoOrigen);
        // Crear un mapa para mapear los nombres de los campos a sus valores
        Map<String, Object> valoresDeCampos = new Map<String, Object>{
            'ProcesoOrigen' => obj.ProcesoOrigen,
            'CasoNumberSalesforce' => obj.CasoNumberSalesforce,
            'CasoNumberOrigen' => obj.CasoNumberOrigen,
            'EstadoMovimiento' => obj.EstadoMovimiento,
            'UsuarioNotificador' => obj.UsuarioNotificador,
            'EsEstadoTerminal' => obj.EsEstadoTerminal,
            'FechaMovimiento' => obj.FechaMovimiento,   
            'RutPaciente' => obj.RutPaciente,
            'NumPresupuesto' => obj.NumPresupuesto,
            'NumPlanTratamiento' => obj.NumPlanTratamiento,
            'Observacion' => obj.Observacion
        };
                    
        // Verificar campos obligatorios
        for (String campo : camposObligatorios) {
            // Obtener el valor del campo del mapa
            
            
            // Verificar si el valor es nulo
            if ( valoresDeCampos.get(campo) == null) {
                mensajeError.message='Error: Uno o más campos obligatorios están ausentes para el proceso ' + procesoOrigen;
                return mensajeError;
                
            }
        }
        
        String proceso = obj.ProcesoOrigen;
        String estado = obj.EstadoMovimiento;
        
        // try {
        String estadosProceso = obtenerDescripcionEstado(PROCESOS_Y_ESTADOS, proceso, estado);
        System.debug('obtenerDescripcionEstado'+' '+estadosProceso);
        if (estadosProceso != '' && estadosProceso != null){
            System.debug('obtenerDescripcionEstado1'+' '+estadosProceso);
            mensajeError.message=estadosProceso;
            return mensajeError;
        }
        // } catch (DocumentosRequestException e) {
        //     System.debug(e.getMessage());
        // }
        System.debug('obtenerDescripcionEstado2 ' );
        //String estadoDescripcion = obtenerEstado(PROCESOS_Y_ESTADOS ,  obj.ProcesoOrigen, obj.EstadoMovimiento);
        //obj.EstadoMovimiento = (obj.ProcesoOrigen == 'Contraloría') ? obj.EstadoMovimiento : estadoDescripcion;
        
        mensajeError.message='';
        return mensajeError;
        
    }
    
    public static List<String> obtenerParametrosString(DatosDocumento datosDoc) {
        String proceso = datosDoc.ProcesoOrigen;
        String estado = datosDoc.EstadoMovimiento;
        
        // Verifica si el proceso y el estado están mapeados en PARAMS_MAP
        if (PARAMS_MAP.containsKey(proceso) && PARAMS_MAP.get(proceso).containsKey(estado)) {
            // Obtiene la lista de nombres de los campos correspondientes al estado actual
            List<String> campos = PARAMS_MAP.get(proceso).get(estado);
            
            // Crea una lista para almacenar los valores de los campos
            List<String> valoresCampos = new List<String>();
            
            // Mapea los nombres de los campos a los valores correspondientes en el objeto DatosDocumento
            Map<String, String> camposValores = new Map<String, String>{
                'FechaMovimiento' => datosDoc.FechaMovimiento,
                'EstadoMovimiento' => datosDoc.EstadoMovimiento,
                'BloqueAgendado' => datosDoc.BloqueAgendado,
                'CodigoDiagnostico' => datosDoc.CodigoDiagnostico,
                'FechaAgendamiento' => datosDoc.FechaAgendamiento,
                'FechaResolucion'  =>   datosDoc.FechaResolucion,
                'UsuarioNotificador'  =>   datosDoc.UsuarioNotificador
                // Agrega más campos y valores según sea necesario
            };
                    
            // Itera sobre los nombres de los campos y obtén sus valores del mapa
            for (String campo : campos) {
                // Agrega el valor del campo a la lista de valores de campos
                valoresCampos.add(camposValores.get(campo));
            }
            
            return valoresCampos;
        }
        
        // Devuelve una lista vacía si no se encuentra el proceso o el estado
        return new List<String>();
    }
    public static boolean actualizarRegistro(Id recordId, String valor ) {
        
        // Crea un nuevo objeto con los valores actualizados
        Case objetoActualizado = new Case(
            Id = recordId,  // Establece el ID del registro que deseas actualizar
            Beneficencia__c = valor  // Actualiza el campo Beneficencia__c con el valor proporcionado,
        );
        /*Case objetoActualizado = new Case(
            Id = recordId,  // Establece el ID del registro que deseas actualizar
            Beneficencia__c = valor,  // Actualiza el campo Beneficencia__c con el valor proporcionado,
            cc_pp_ELE__c = flujo // actualiza el flujo
        );*/
        
        
        // Realiza la actualización utilizando DML (Data Manipulation Language)
        try {
            
            update objetoActualizado;
            System.debug('Registro actualizado correctamente.');
            return true;
        } catch (DmlException e) {
            System.debug('paso 5.'+valor);
            System.debug('paso 6.'+e.getMessage());
            System.debug('Ocurrió un error al actualizar el registro: ' + e.getMessage());
            return false;
        }
    }
    public static boolean actualizarRegistroContraloria(Id recordId, String valor ) {
        
        // Crea un nuevo objeto con los valores actualizados
        Case objetoActualizado = new Case(
            Id = recordId,  // Establece el ID del registro que deseas actualizar
            cc_pp_CoberturaConvenio__c = valor  // Actualiza el campo cc_pp_CoberturaConvenio__c con el valor proporcionado,
            
        );
        
        // Realiza la actualización utilizando DML (Data Manipulation Language)
        try {
            update objetoActualizado;
            return true;
        } catch (DmlException e) {
            System.debug('Ocurrió un error al actualizar el registro: ' + e.getMessage());
            return false;
        }
    }
    
    // Método que procesa el objeto DatosDocumento y devuelve una respuesta JSON
    public static String procesarDatosDocumento(DatosDocumento obj) {
        // Obtener el ID del caso
        Id idCaso = obtenerIdCaso(obj.RutPaciente, obj.NumPlanTratamiento, obj.CasoNumberSalesforce, obj.ProcesoOrigen);
        List<String> dateParts = obj.FechaMovimiento.split('-');
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        
        Date myDate = Date.newInstance(year, month, day);
        // Procesar movimiento y validar campos obligatorios
        String validacion = procesarMovimiento(obj, idCaso).message;
        
        if (!String.isEmpty(validacion)) {
            // Si hay validación fallida, retornar un mensaje de error
            DocumentosProcesadosResponse response = new DocumentosProcesadosResponse(validacion, '', null);
            return JSON.serialize(response);
        }
        
        if (idCaso == null) {
            // Si no se encuentra el caso en Salesforce, retornar un mensaje de error
            DocumentosProcesadosResponse response = new DocumentosProcesadosResponse('Caso no registrado en Salesforce', '', null);
            return JSON.serialize(response);
        }
        
        // Procesar lista de documentos
        List<ResultadoProcesamiento> resultados = new List<ResultadoProcesamiento>();
        List<String> parametrosComiteAgendado = obtenerParametrosString(obj);
        System.debug('obj.ProcesoOrigen'+obj.ProcesoOrigen);
        System.debug('obj.EstadoMovimiento'+obj.EstadoMovimiento);
        
        String descripcionProceso = modificarDescripcionEstado(obj.ProcesoOrigen, obj.EstadoMovimiento, parametrosComiteAgendado);
        System.debug('descripcionProceso: ' + descripcionProceso);
        Case caso = [SELECT ContactId FROM Case WHERE Id = :idCaso LIMIT 1];
        String estadoDescripcion = obtenerEstado(PROCESOS_Y_ESTADOS ,  obj.ProcesoOrigen, obj.EstadoMovimiento);
        Id evento= crearEvento(obj.ProcesoOrigen + ' ' + estadoDescripcion, myDate, myDate, descripcionProceso, idCaso, caso.ContactId);
        System.debug('paso 1 bien.');
        
        if(obj.ProcesoOrigen =='Beneficencia' ){
            if(obj.EstadoMovimiento.equals('1')){
                actualizarRegistro(idCaso,'En Proceso');						//Solo actualiza
            }           
            if(obj.EstadoMovimiento.equals('2')){
                actualizarRegistro(idCaso,'Aprobado');							//avanza
            }
            if(obj.EstadoMovimiento.equals('3')){//--> Antes era Denegado
                actualizarRegistro(idCaso,'Rechazado');							//devuelve a EF
            }
            if(obj.EstadoMovimiento.equals('4')){
                actualizarRegistro(idCaso,'Reagendado');						//solo actualiza caso
            }            
            if(obj.EstadoMovimiento.equals('5')){
                actualizarRegistro(idCaso,'Caso no Presentado');				//devuelve a EF
            }
            if(obj.EstadoMovimiento.equals('6')){
                actualizarRegistro(idCaso,'Anulado');							//devuelve a EF
            }           
        }
        if (obj.ProcesoOrigen =='Contraloria'){
            actualizarRegistroContraloria (idCaso, descripcionProceso.toUpperCase());
        }
        if (obj.Documentos != null && !obj.Documentos.isEmpty()) {
            for (Documento doc : obj.Documentos) {
                if (!String.isEmpty(doc.NombreArchivo)) {
                    ResultadoProcesamiento resultado = insertarDocumento(doc.NombreArchivo, doc.CodigoBase64, evento, doc.Codificacion, doc.UrlCorta);
                    resultados.add(resultado);
                }
            }
        }
        
        // Obtener descripción del proceso y crear evento
        
        
        // Construir y retornar la respuesta final exitosa
        DocumentosProcesadosResponse response = new DocumentosProcesadosResponse('Documentos procesados exitosamente.', idCaso != null ? idCaso : '', resultados);
        return JSON.serialize(response);
    }  
    
    
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        System.debug('req Inicio: ' + req);
        String requestBody = req.requestBody.toString();
        System.debug('Request body1: ' + requestBody);
        
        DatosDocumento obj = (DatosDocumento) JSON.deserialize(requestBody, DatosDocumento.class);
        // Procesar movimiento y validar campos obligatorios
        
        return procesarDatosDocumento(obj);
    }
}