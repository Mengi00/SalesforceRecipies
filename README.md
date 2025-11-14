# Hola, dejo las recetas con todo el contenido desarrollado por WND para salesforce, todas las recetas y componentes refentes a stack de healthcare para uso libre, ¡buena caza!

# Documentación de Componentes - Salesforce

Este documento describe los componentes Lightning Web Components (LWC) y las clases Apex del proyecto Salesforce FALP.

---

## 📋 Índice

- [Lightning Web Components (LWC)](#lightning-web-components-lwc)
  - [Gestión de Casos](#gestión-de-casos)
  - [Solicitudes de Mejora](#solicitudes-de-mejora)
  - [Gestión de Productos y Dispositivos Médicos](#gestión-de-productos-y-dispositivos-médicos)
  - [Registro de Pacientes](#registro-de-pacientes)
  - [Evaluaciones de Salud Conductual](#evaluaciones-de-salud-conductual)
  - [Componentes de Interfaz](#componentes-de-interfaz)
- [Clases Apex](#clases-apex)
  - [Controladores de Casos](#controladores-de-casos)
  - [Servicios REST para Integración](#servicios-rest-para-integración)
  - [Gestión de Encuestas](#gestión-de-encuestas)
  - [Gestión de Productos Médicos](#gestión-de-productos-médicos)
  - [Utilidades y Helpers](#utilidades-y-helpers)

---

## Lightning Web Components (LWC)

### Gestión de Casos

#### **fCL_casesShowToGroup**
- **Ubicación:** `force-app/main/default/lwc/fCL_casesShowToGroup/`
- **Descripción:** Componente principal para visualizar casos derivados asignados a los grupos del usuario actual.
- **Funcionalidades:**
  - Muestra casos con estado "Derivado" asociados a los grupos del usuario
  - Filtros avanzados por: número de caso, asunto, subunidad, nombre del paciente, alta complejidad y fechas
  - Ordenamiento dinámico de columnas
  - Exportación a Excel con formato personalizado
  - Integración con librería SheetJS para exportación
- **Controlador Apex:** `FCL_CasesListController`

#### **fCL_AllCasesShowToGoup**
- **Ubicación:** `force-app/main/default/lwc/fCL_AllCasesShowToGoup/`
- **Descripción:** Similar a `fCL_casesShowToGroup` pero muestra todos los casos (no solo los derivados).
- **Funcionalidades:**
  - Visualización de todos los casos asociados a grupos del usuario
  - Mismas capacidades de filtrado y exportación

#### **casesShowToGroup**
- **Ubicación:** `force-app/main/default/lwc/casesShowToGroup/`
- **Descripción:** Versión alternativa del componente de visualización de casos.
- **Funcionalidades:**
  - Lista casos con estado "Derivación"
  - Filtros y exportación básica

#### **caseWarningModal**
- **Ubicación:** `force-app/main/default/lwc/caseWarningModal/`
- **Descripción:** Modal de advertencia para casos.
- **Funcionalidades:**
  - Muestra alertas y advertencias relacionadas con casos

#### **fcl_StadisticsCasesHomeSPComunitySite**
- **Ubicación:** `force-app/main/default/lwc/fcl_StadisticsCasesHomeSPComunitySite/`
- **Descripción:** Dashboard de estadísticas de casos para sitios de comunidad.
- **Funcionalidades:**
  - Muestra métricas de casos personales y del área
  - Integración con `fcl_CaseStatisticsController`

#### **fCL_ChartByGroupLWC**
- **Ubicación:** `force-app/main/default/lwc/fCL_ChartByGroupLWC/`
- **Descripción:** Componente de gráficos de casos por grupo.
- **Funcionalidades:**
  - Visualización gráfica de casos agrupados

#### **fCL_ChartByGroupOnTime**
- **Ubicación:** `force-app/main/default/lwc/fCL_ChartByGroupOnTime/`
- **Descripción:** Gráfico de casos según tiempo de resolución.
- **Funcionalidades:**
  - Muestra casos a tiempo vs fuera de tiempo

### Solicitudes de Mejora

#### **fCL_ListaSolicitudesDeMejora**
- **Ubicación:** `force-app/main/default/lwc/fCL_ListaSolicitudesDeMejora/`
- **Descripción:** Lista completa de solicitudes de mejora creadas por el usuario actual.
- **Funcionalidades:**
  - Visualización de solicitudes con número, asunto, categoría, estado y fecha
  - Filtros por: número de solicitud, asunto, categoría, estado y rango de fechas
  - Ordenamiento de columnas (texto, fecha, número)
  - Exportación a Excel con formato personalizado
  - Enlaces directos a detalles de solicitud
- **Controlador Apex:** `FCL_SolicitudesDeMejoraList`

#### **fCL_CreateSolicitudDeMejoraModal**
- **Ubicación:** `force-app/main/default/lwc/fCL_CreateSolicitudDeMejoraModal/`
- **Descripción:** Modal para crear nuevas solicitudes de mejora.
- **Funcionalidades:**
  - Formulario de creación con validaciones
  - Campos: Título, Tipo de Mejora, Descripción, Unidad Responsable
- **Controlador Apex:** `SolicitudDeMejoraController`

#### **fCL_ListRequerimientosMejora**
- **Ubicación:** `force-app/main/default/lwc/fCL_ListRequerimientosMejora/`
- **Descripción:** Lista de requerimientos de mejora asignados al usuario.
- **Funcionalidades:**
  - Muestra requerimientos donde el usuario es responsable
  - Filtros por estado "Derivado"
- **Controlador Apex:** `fCL_RequerimientosDeMejora`

#### **fCL_DetalleDelRequerimiento**
- **Ubicación:** `force-app/main/default/lwc/fCL_DetalleDelRequerimiento/`
- **Descripción:** Vista detallada de un requerimiento de mejora.
- **Funcionalidades:**
  - Muestra información completa del requerimiento
  - Marca requerimientos como visualizados
- **Controlador Apex:** `fCL_RequerimientosDeMejora`

#### **fCL_ListRequestCreatedByIdUser**
- **Ubicación:** `force-app/main/default/lwc/fCL_ListRequestCreatedByIdUser/`
- **Descripción:** Lista de solicitudes creadas por el usuario.
- **Funcionalidades:**
  - Visualización de solicitudes propias

### Gestión de Productos y Dispositivos Médicos

#### **markProductForOrder**
- **Ubicación:** `force-app/main/default/lwc/markProductForOrder/`
- **Descripción:** Componente de flujo para marcar productos para ordenar.
- **Funcionalidades:**
  - Creación de nuevas órdenes o selección de órdenes existentes
  - Búsqueda de órdenes con paginación
  - Selección de ubicación de cumplimiento
  - Búsqueda de contactos y cuentas con lookup
  - Filtros por fecha (desde/hasta)
  - Navegación de flujo (siguiente/anterior)
- **Controlador Apex:** `MarkForOrderController`

#### **markAsReturn**
- **Ubicación:** `force-app/main/default/lwc/markAsReturn/`
- **Descripción:** Marca productos como retornados.
- **Funcionalidades:**
  - Gestión de devoluciones de productos

#### **markForLost**
- **Ubicación:** `force-app/main/default/lwc/markForLost/`
- **Descripción:** Marca productos como perdidos.
- **Funcionalidades:**
  - Registro de productos extraviados

#### **markForOrderVisit**
- **Ubicación:** `force-app/main/default/lwc/markForOrderVisit/`
- **Descripción:** Marca productos para órdenes en visitas.
- **Funcionalidades:**
  - Asociación de productos con visitas

#### **markSerialNumbers**
- **Ubicación:** `force-app/main/default/lwc/markSerialNumbers/`
- **Descripción:** Gestión de números de serie de productos.
- **Funcionalidades:**
  - Marcado y seguimiento de números de serie

#### **requestHandOverProduct**
- **Ubicación:** `force-app/main/default/lwc/requestHandOverProduct/`
- **Descripción:** Solicitud de traspaso de productos.
- **Funcionalidades:**
  - Gestión de traspasos entre ubicaciones
- **Controlador Apex:** `HandOverController`

#### **captureProductKPIDetails**
- **Ubicación:** `force-app/main/default/lwc/captureProductKPIDetails/`
- **Descripción:** Captura de KPIs de productos.
- **Funcionalidades:**
  - Registro de métricas de productos

#### **captureRequestProductDetails**
- **Ubicación:** `force-app/main/default/lwc/captureRequestProductDetails/`
- **Descripción:** Captura de detalles de solicitud de productos.
- **Funcionalidades:**
  - Registro de información de solicitudes

#### **captureSummaryDetails**
- **Ubicación:** `force-app/main/default/lwc/captureSummaryDetails/`
- **Descripción:** Captura de resumen de detalles.
- **Funcionalidades:**
  - Consolidación de información

#### **requestedListViewsCmp**
- **Ubicación:** `force-app/main/default/lwc/requestedListViewsCmp/`
- **Descripción:** Vista de lista de solicitudes.
- **Funcionalidades:**
  - Visualización de solicitudes pendientes

#### **returnsListViewCmp**
- **Ubicación:** `force-app/main/default/lwc/returnsListViewCmp/`
- **Descripción:** Vista de lista de devoluciones.
- **Funcionalidades:**
  - Visualización de productos devueltos

### Registro de Pacientes

#### **patientRegistration**
- **Ubicación:** `force-app/main/default/lwc/patientRegistration/`
- **Descripción:** Componente de flujo para registro de pacientes.
- **Funcionalidades:**
  - Búsqueda de pacientes existentes o creación de nuevos
  - Búsqueda con paginación y delay (300ms)
  - Selección de tipo: "existing" o "new"
  - Formulario de registro con validación
  - Modal de confirmación antes de registrar
  - Navegación de flujo con botones siguiente/atrás
  - Integración con Person Accounts
- **Controlador Apex:** `PatientRegistrationController`

### Evaluaciones de Salud Conductual

Los siguientes componentes son formularios de evaluación de salud mental en inglés:

#### **alcoholAUDITCEnglish**
- **Descripción:** Cuestionario AUDIT-C para evaluación de consumo de alcohol.

#### **anxietyGAD7English**
- **Descripción:** Cuestionario GAD-7 para evaluación de ansiedad.

#### **depressionPHQ9English** / **depressionPHQ_9English**
- **Descripción:** Cuestionarios PHQ-9 para evaluación de depresión.

#### **behavioralHealthAUDITCEnglish**
- **Descripción:** AUDIT-C para salud conductual.

#### **behavioralHealthGAD7English**
- **Descripción:** GAD-7 para salud conductual.

#### **behavioralHealthPHQ9English**
- **Descripción:** PHQ-9 para salud conductual.

#### **behavioralHealthIntakeEnglish**
- **Descripción:** Formulario de admisión de salud conductual.

#### **behavioralHealthMentalStatusAssessmentEnglish**
- **Descripción:** Evaluación del estado mental.

#### **behavioralHealthImmediateRiskAssessmentEnglish**
- **Descripción:** Evaluación de riesgo inmediato.

#### **healthCloudCSCMImmediateRiskAssessmentEnglish**
- **Descripción:** Evaluación de riesgo inmediato para Health Cloud.

#### **healthCloudCSCMIntakeEnglish**
- **Descripción:** Admisión para Health Cloud.

#### **healthCloudCSCMMentalStatusAssessmentEnglish**
- **Descripción:** Evaluación de estado mental para Health Cloud.

### Componentes de Interfaz

#### **lookup**
- **Ubicación:** `force-app/main/default/lwc/lookup/`
- **Descripción:** Componente de búsqueda tipo lookup reutilizable.
- **Funcionalidades:**
  - Búsqueda de registros de cualquier objeto
  - Selección de registros

#### **customLookupSearchCmp** / **customLookupSearchChildCmp**
- **Ubicación:** `force-app/main/default/lwc/customLookupSearchCmp/`
- **Descripción:** Componentes de búsqueda personalizada.
- **Funcionalidades:**
  - Búsqueda avanzada con componentes padre-hijo

#### **multiSelectPickList**
- **Ubicación:** `force-app/main/default/lwc/multiSelectPickList/`
- **Descripción:** Lista de selección múltiple.
- **Funcionalidades:**
  - Selección de múltiples valores

#### **relatedPicklistOptions**
- **Ubicación:** `force-app/main/default/lwc/relatedPicklistOptions/`
- **Descripción:** Opciones de picklist dependientes.
- **Funcionalidades:**
  - Gestión de picklists relacionadas

#### **fieldVariabilityDisplay**
- **Ubicación:** `force-app/main/default/lwc/fieldVariabilityDisplay/`
- **Descripción:** Muestra variabilidad de campos.
- **Funcionalidades:**
  - Visualización de cambios en campos

#### **eSignature**
- **Ubicación:** `force-app/main/default/lwc/eSignature/`
- **Descripción:** Componente de firma electrónica.
- **Funcionalidades:**
  - Captura de firmas digitales
  - Soporte de etiquetas personalizadas
  - Observador de redimensionamiento

#### **emailMessageViewer**
- **Ubicación:** `force-app/main/default/lwc/emailMessageViewer/`
- **Descripción:** Visualizador de mensajes de email.
- **Funcionalidades:**
  - Renderizado de contenido de emails
- **Controlador Apex:** `EmailMessageRenderController`

#### **moreActions**
- **Ubicación:** `force-app/main/default/lwc/moreActions/`
- **Descripción:** Menú de acciones adicionales.
- **Funcionalidades:**
  - Menú desplegable de acciones

#### **opportunitiesListCMP**
- **Ubicación:** `force-app/main/default/lwc/opportunitiesListCMP/`
- **Descripción:** Lista de oportunidades.
- **Funcionalidades:**
  - Visualización de oportunidades

#### **fCL_supervisorCard**
- **Ubicación:** `force-app/main/default/lwc/fCL_supervisorCard/`
- **Descripción:** Tarjeta de información del supervisor.
- **Funcionalidades:**
  - Muestra información del supervisor

#### **fCL_UserWelcomeSP**
- **Ubicación:** `force-app/main/default/lwc/fCL_UserWelcomeSP/`
- **Descripción:** Mensaje de bienvenida para usuarios.
- **Funcionalidades:**
  - Pantalla de bienvenida personalizada

#### **fcl_HomeReportSP**
- **Ubicación:** `force-app/main/default/lwc/fcl_HomeReportSP/`
- **Descripción:** Reporte del home para Service Portal.
- **Funcionalidades:**
  - Dashboard de inicio

#### **fcl_BrigpatternRecord**
- **Ubicación:** `force-app/main/default/lwc/fcl_BrigpatternRecord/`
- **Descripción:** Componente de patrón de registro.
- **Funcionalidades:**
  - Gestión de patrones de registros
  - Incluye tests unitarios

### Componentes de Landing Pages

#### **inAppLanding** / **inAppLandingPage**
- **Descripción:** Páginas de aterrizaje in-app principales.

#### **inAppLandingChild** / **inAppLandingPageChild**
- **Descripción:** Componentes hijos para landing pages.

#### **inAppPrimaryFeature** / **inAppPrimaryFeatureChild**
- **Descripción:** Características primarias con componentes padre-hijo.

#### **inAppSecondaryFeature** / **inAppSecondaryFeatureChild**
- **Descripción:** Características secundarias.

#### **inAppTertiaryFeature**
- **Descripción:** Características terciarias.

#### **inAppQuaternaryFeature** / **inAppQuaternaryFeatureChild**
- **Descripción:** Características cuaternarias.

#### **featureChild**
- **Descripción:** Componente hijo genérico de características.

#### **landingRightPane**
- **Descripción:** Panel derecho de landing pages.

#### **cmpMedTechLandingRightPane**
- **Descripción:** Panel derecho para tecnología médica.

#### **cmpPharmaLandingRightPane**
- **Descripción:** Panel derecho para farmacia.

#### **cmpSectorLandingPages**
- **Descripción:** Landing pages por sector.

#### **learningHome** / **learningHomeChild**
- **Descripción:** Página de inicio de aprendizaje.

---

## Clases Apex

### Controladores de Casos

#### **CasosListController**
- **Ubicación:** `force-app/main/default/classes/CasosListController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Obtiene casos para grupos de usuarios (versión alternativa).
- **Métodos principales:**
  - `getCasesForUserGroups(Id userId)`: Retorna casos con estado "Derivación" asociados a grupos del usuario
- **Funcionalidades:**
  - Consulta grupos de colaboración del usuario por email
  - Filtra casos por servicios asociados a grupos
  - Solo muestra casos en estado "Derivación"

#### **FCL_CasesListController**
- **Ubicación:** `force-app/main/default/classes/FCL_CasesListController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Controlador principal para gestión de casos en LWC.
- **Métodos principales:**
  - `getCasesForUserGroups(Id userId)`: Retorna casos "Derivado" del usuario
  - `getAllCasesForUserGroups(Id userId)`: Retorna todos los casos del usuario
  - `getEstadoOptions()`: Obtiene estados de casos de tipo "Servicio Paciente"
  - `getSubUnidadesPorUsuario(Id userId)`: Obtiene subunidades (grupos) del usuario
- **Funcionalidades:**
  - Consulta por email del usuario
  - Obtiene membresías de grupos Chatter
  - Filtra casos por relación `Servicios_en_Caso__c`
  - Retorna información de grupos asociados

#### **fcl_CaseStatisticsController**
- **Ubicación:** `force-app/main/default/classes/fcl_CaseStatisticsController.cls`
- **Tipo:** Controlador de Estadísticas
- **Descripción:** Calcula estadísticas de casos para dashboards.
- **Métodos principales:**
  - `getCaseStatistics()`: Retorna mapa con conteo de casos personales y del área
- **Funcionalidades:**
  - Cuenta casos por usuario (basado en EmailMessage)
  - Cuenta casos por grupos del usuario
  - Evita duplicados en conteo
  - Solo considera casos en estado "Derivación"

#### **fCL_CasesChartView** / **fCL_CasesChartViewOnTime** / **fCL_CasesChartViewOnTime2**
- **Ubicación:** `force-app/main/default/classes/`
- **Tipo:** Controladores de Gráficos
- **Descripción:** Proveen datos para visualizaciones de casos.
- **Funcionalidades:**
  - Generación de datos para gráficos
  - Métricas de tiempo de resolución

### Solicitudes y Requerimientos de Mejora

#### **SolicitudDeMejoraController**
- **Ubicación:** `force-app/main/default/classes/SolicitudDeMejoraController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona la creación de solicitudes de mejora.
- **Métodos principales:**
  - `createSolicitudDeMejora(FormData formData)`: Crea nueva solicitud de mejora
- **Clase interna:**
  - `FormData`: Wrapper con campos Titulo, TipoMejora, Descripcion, UnidadR
- **Funcionalidades:**
  - Crea registro `Solicitud_de_Mejora__c`
  - Estado inicial: "Derivado"
  - Manejo de excepciones con AuraHandledException

#### **FCL_SolicitudesDeMejoraList**
- **Ubicación:** `force-app/main/default/classes/FCL_SolicitudesDeMejoraList.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Lista solicitudes de mejora del usuario actual.
- **Métodos principales:**
  - `getSolicitudesCreadasPorUsuarioActual()`: Retorna solicitudes del usuario
  - `getCategoriaOptions()`: Obtiene categorías disponibles
  - `getEstadoOptions()`: Obtiene estados disponibles
- **Funcionalidades:**
  - Filtra por creador (OwnerId)
  - Proporciona opciones para filtros de UI

#### **fCL_RequerimientosDeMejora**
- **Ubicación:** `force-app/main/default/classes/fCL_RequerimientosDeMejora.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona requerimientos de mejora asignados al usuario.
- **Métodos principales:**
  - `getRequerimientosByResponble()`: Retorna requerimientos donde el usuario es responsable
  - `markAsViewed(Id recordId)`: Marca requerimiento como visto (actualiza fecha primera visualización)
  - `getDetails(Id recordId)`: Obtiene detalles completos de un requerimiento
  - `getCategoriaOptions()`: Obtiene categorías de requerimientos
  - `getEstadoOptions()`: Obtiene estados de requerimientos
  - `getPrioridadOptions()`: Obtiene prioridades de requerimientos
- **Funcionalidades:**
  - Filtra por unidad responsable del usuario
  - Registra primera visualización (solo una vez)
  - Métodos cacheables para lectura, no-cacheables para escritura
  - Solo muestra requerimientos en estado "Derivado"

#### **SolicitudNotifier**
- **Ubicación:** `force-app/main/default/classes/SolicitudNotifier.cls`
- **Tipo:** Notificador
- **Descripción:** Envía notificaciones sobre solicitudes.
- **Funcionalidades:**
  - Sistema de notificaciones automáticas

### Servicios REST para Integración

#### **CL_AddFolios**
- **Ubicación:** `force-app/main/default/classes/CL_AddFolios.cls`
- **Tipo:** REST Service
- **URL Mapping:** `/CL_AddFolios`
- **Descripción:** Servicio REST para agregar folios desde sistema externo (Oracle).
- **Métodos HTTP:**
  - `@HttpPost addFolios(List<E_Parameters> nuevosFolios)`: Crea/actualiza folios
- **Clases internas:**
  - `E_Parameters`: Parámetros de entrada del folio
  - `E_Response`: Respuesta con resultado de operación
  - `E_FolioAgregado`: Detalle de folio procesado
- **Funcionalidades:**
  - Upsert de folios usando campo externo `Id_Externo__c`
  - Crea relaciones `FALP_RelacionPresupuestoFolio__c` entre folios y presupuestos
  - Actualiza casos relacionados: cambia estado de "Agendado, pendiente folio" a "Generado"
  - Manejo de errores detallado por registro
  - Retorna estado de transmisión (OK/NOK) por cada folio

#### **CL_AddPresupuestos**
- **Ubicación:** `force-app/main/default/classes/CL_AddPresupuestos.cls`
- **Tipo:** REST Service
- **URL Mapping:** `/CL_AddPresupuestos`
- **Descripción:** Servicio REST para agregar presupuestos desde sistema externo (Oracle).
- **Métodos HTTP:**
  - `@HttpPost addPresupuestos(List<E_Parameters> nuevosPresupuestos)`: Crea/actualiza presupuestos
- **Clases internas:**
  - `E_Parameters`: Parámetros de entrada del presupuesto
  - `E_Response`: Respuesta con resultado de operación
  - `E_PresupuestoAgregado`: Detalle de presupuesto procesado
- **Funcionalidades:**
  - Upsert de Opportunities usando campo `CC_PP_NPRESUPUESTO__c`
  - Maneja IDs externos: PRES_ID o CPRE_ID (con prefijo 'Q')
  - Asocia presupuestos con casos y planes de tratamiento
  - Manejo de errores por registro
  - Retorna estado OK/NOK con ID de Salesforce generado

#### **CL_AddPabellones**
- **Ubicación:** `force-app/main/default/classes/CL_AddPabellones.cls`
- **Tipo:** REST Service
- **URL Mapping:** `/CL_AddPabellones`
- **Descripción:** Servicio REST para agregar pabellones (quirófanos/salas).
- **Funcionalidades:**
  - Integración con sistema de gestión de pabellones
  - Sincronización de datos de cirugías/procedimientos

#### **CL_AddPlanesDeTratamientos**
- **Ubicación:** `force-app/main/default/classes/CL_AddPlanesDeTratamientos.cls`
- **Tipo:** REST Service
- **URL Mapping:** `/CL_AddPlanesDeTratamientos`
- **Descripción:** Servicio REST para agregar planes de tratamiento.
- **Funcionalidades:**
  - Sincronización de planes de tratamiento desde sistema externo
  - Integración con casos y presupuestos

#### **wsListPlus**
- **Ubicación:** `force-app/main/default/classes/wsListPlus.cls`
- **Tipo:** Web Service SOAP
- **Descripción:** Servicio web para listar información desde Salesforce.
- **Funcionalidades:**
  - Exposición de datos vía SOAP
  - Parser asociado: `wsListPlusParser`

#### **wsSaveDocumentListPlus**
- **Ubicación:** `force-app/main/default/classes/wsSaveDocumentListPlus.cls`
- **Tipo:** Web Service SOAP
- **Descripción:** Servicio para guardar documentos.
- **Funcionalidades:**
  - Recepción de documentos externos
  - Almacenamiento en Salesforce

### Gestión de Productos Médicos

#### **HandOverController**
- **Ubicación:** `force-app/main/default/classes/HandOverController.cls`
- **Tipo:** Invocable Method
- **Descripción:** Actualiza consumo de productos serializados en traspasos.
- **Métodos principales:**
  - `@InvocableMethod getRecordsForProductConsumption(List<Requests> rqstInputs)`: Actualiza productos serializados
- **Clases internas:**
  - `Requests`: Parámetros de entrada (ProductId, LocationId, Status, SerialNumbers)
  - `Response`: Lista de SerializedProducts actualizados
- **Funcionalidades:**
  - Actualiza `ProductItemId` y `Status` de productos serializados
  - Acepta números de serie o IDs de productos escaneados
  - Se invoca desde Flow
  - Retorna lista de productos listos para actualizar

#### **MedicalDeviceRequestController**
- **Ubicación:** `force-app/main/default/classes/MedicalDeviceRequestController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona solicitudes de dispositivos médicos.
- **Métodos principales:**
  - `getRelatedAccountLocations(String accId)`: Obtiene ubicaciones de inventario de una cuenta
  - `fetchSerilizedProductsforHandover(String productId, String locationId)`: Obtiene productos serializados disponibles
  - `getProductLocations(String accountId, String productId)`: Obtiene ubicaciones de producto
  - `fetchRelatedOpps(String accId, Integer limitSize, Integer offset)`: Obtiene oportunidades relacionadas
  - `fetchCaseRequests(String status, String type, Integer limitSize, Integer offset)`: Obtiene casos de solicitud
  - `fetchAllCaseRequests(String type)`: Cuenta casos por estado
- **Funcionalidades:**
  - Consulta `ProductFulfillmentLocation` para ubicaciones
  - Filtra productos serializados con estado "Available"
  - Paginación con limitSize y offset
  - Soporte para flujos de handover y solicitudes

#### **MarkForOrderController**
- **Ubicación:** `force-app/main/default/classes/MarkForOrderController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona marcado de productos para órdenes.
- **Métodos principales:**
  - `getRelatedFulfillmentLocations(String accId)`: Obtiene ubicaciones de cumplimiento
  - `getOrders(String queryTerm, Integer limitSize, Integer offset, String fromDate, String toDate)`: Busca órdenes con filtros
  - `getOrderById(String orderId)`: Obtiene orden específica
- **Funcionalidades:**
  - Búsqueda de órdenes con paginación
  - Filtros por fecha y texto
  - Soporte para flujos de orden

#### **MedicalDeviceReturnController**
- **Ubicación:** `force-app/main/default/classes/MedicalDeviceReturnController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona devoluciones de dispositivos médicos.
- **Funcionalidades:**
  - Procesamiento de retornos
  - Actualización de inventario

#### **MarkAsReturnController**
- **Ubicación:** `force-app/main/default/classes/MarkAsReturnController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Marca productos como devueltos.
- **Funcionalidades:**
  - Cambio de estado a "Returned"
  - Actualización de ubicaciones

#### **CycleCountController**
- **Ubicación:** `force-app/main/default/classes/CycleCountController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona conteo cíclico de inventario.
- **Funcionalidades:**
  - Conteo de productos
  - Reconciliación de inventario

#### **HandoverSerilizedProductCase**
- **Ubicación:** `force-app/main/default/classes/HandoverSerilizedProductCase.cls`
- **Tipo:** Helper Class
- **Descripción:** Gestiona casos de productos serializados en traspasos.
- **Funcionalidades:**
  - Lógica de negocio para traspasos

### Gestión de Encuestas

#### **SRV_InsertSurveyInvitations**
- **Ubicación:** `force-app/main/default/classes/SRV_InsertSurveyInvitations.cls`
- **Tipo:** Invocable Method
- **Descripción:** Inserta invitaciones de encuesta de forma masiva.
- **Métodos principales:**
  - `@InvocableMethod InsertSurveyInvitations(List<InputParams> inputs)`: Procesa invitaciones
- **Clase interna:**
  - `InputParams`: Wrapper con lista de SurveyInvitation
- **Funcionalidades:**
  - Valida invitaciones por CommunityId
  - Ejecuta batch `SRV_InsertSurveyInvitations_BACH` para crear invitaciones (lotes de 100)
  - Ejecuta batch `SRV_UpdParticipantesEncuesta_BACH` para actualizar participantes (lotes de 100)
  - Actualiza estado de `Participante_de_Encuesta__c` a "Enviado" o estado de error
  - Procesamiento asíncrono para grandes volúmenes

#### **SRV_InsertSurveyInvitations_BACH**
- **Ubicación:** `force-app/main/default/classes/SRV_InsertSurveyInvitations_BACH.cls`
- **Tipo:** Batch Apex
- **Descripción:** Batch para inserción masiva de invitaciones.
- **Funcionalidades:**
  - Procesa 100 invitaciones por lote
  - Inserta registros SurveyInvitation

#### **SRV_UpdParticipantesEncuesta_BACH**
- **Ubicación:** `force-app/main/default/classes/SRV_UpdParticipantesEncuesta_BACH.cls`
- **Tipo:** Batch Apex
- **Descripción:** Batch para actualizar estado de participantes.
- **Funcionalidades:**
  - Procesa 100 participantes por lote
  - Actualiza campo Estado__c

#### **insertSurveyParticipantsCustom**
- **Ubicación:** `force-app/main/default/classes/insertSurveyParticipantsCustom.cls`
- **Tipo:** Helper Class
- **Descripción:** Lógica personalizada para inserción de participantes.
- **Funcionalidades:**
  - Validaciones de negocio
  - Preparación de datos

### Controladores de Usuario y Autenticación

#### **UserInfoController**
- **Ubicación:** `force-app/main/default/classes/UserInfoController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Obtiene información del usuario actual.
- **Funcionalidades:**
  - Retorna datos del usuario logueado
  - Información de perfil y roles

#### **PatientRegistrationController**
- **Ubicación:** `force-app/main/default/classes/PatientRegistrationController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona búsqueda de pacientes (Contacts) para registro.
- **Métodos principales:**
  - `getContacts(String queryTerm, Integer limitSize, Integer offset)`: Busca contactos con paginación
- **Funcionalidades:**
  - Búsqueda por nombre u otros campos
  - Paginación con limitSize y offset
  - Retorna totalRecords y lista de contacts

#### **SoftphoneProviderController**
- **Ubicación:** `force-app/main/default/classes/SoftphoneProviderController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona funcionalidad de softphone.
- **Funcionalidades:**
  - Integración con sistemas de telefonía
  - Helper: `SoftphoneProviderHelper`

#### **SoftphoneContactSearchController**
- **Ubicación:** `force-app/main/default/classes/SoftphoneContactSearchController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Búsqueda de contactos para softphone.
- **Funcionalidades:**
  - Búsqueda rápida durante llamadas

#### **EnrolleeWorkStepController**
- **Ubicación:** `force-app/main/default/classes/EnrolleeWorkStepController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Gestiona pasos de trabajo de inscritos.
- **Funcionalidades:**
  - Flujo de inscripción
  - Seguimiento de pasos

### Controladores de Communities y Autenticación

Los siguientes controladores gestionan funcionalidades de autenticación y registro en Communities:

#### **LightningLoginFormController**
- **Descripción:** Login para Experience Cloud.
- **Funcionalidades:** Autenticación de usuarios.

#### **LightningSelfRegisterController**
- **Descripción:** Auto-registro de usuarios.
- **Funcionalidades:** Creación de cuentas de usuario.

#### **LightningForgotPasswordController**
- **Descripción:** Recuperación de contraseña.
- **Funcionalidades:** Reset de contraseña.

#### **CommunitiesLoginController**
- **Descripción:** Login para communities (legacy).
- **Funcionalidades:** Autenticación legacy.

#### **CommunitiesSelfRegController**
- **Descripción:** Auto-registro legacy.
- **Funcionalidades:** Registro de usuarios legacy.

#### **CommunitiesSelfRegConfirmController**
- **Descripción:** Confirmación de registro.
- **Funcionalidades:** Verificación de registro.

#### **CommunitiesLandingController**
- **Descripción:** Landing page de communities.
- **Funcionalidades:** Página de inicio.

#### **SiteLoginController** / **SiteRegisterController**
- **Descripción:** Login y registro para Sites.
- **Funcionalidades:** Autenticación en Sites.

#### **ChangePasswordController**
- **Descripción:** Cambio de contraseña.
- **Funcionalidades:** Actualización de credenciales.

#### **ForgotPasswordController**
- **Descripción:** Recuperación de contraseña (Sites).
- **Funcionalidades:** Reset en Sites.

#### **MyProfilePageController**
- **Descripción:** Gestión de perfil de usuario.
- **Funcionalidades:** Edición de perfil.

#### **MicrobatchSelfRegController**
- **Descripción:** Auto-registro con microbatches.
- **Funcionalidades:** Registro en lotes pequeños.

### Utilidades y Helpers

#### **CL_CalcularDigitoVerificacion**
- **Ubicación:** `force-app/main/default/classes/CL_CalcularDigitoVerificacion.cls`
- **Tipo:** Utility Class
- **Descripción:** Calcula dígito verificador (RUT chileno).
- **Funcionalidades:**
  - Validación de RUT
  - Cálculo de dígito verificador

#### **PicklistDependencyHelper**
- **Ubicación:** `force-app/main/default/classes/PicklistDependencyHelper.cls`
- **Tipo:** Helper Class
- **Descripción:** Gestiona dependencias entre picklists.
- **Funcionalidades:**
  - Obtiene valores dependientes
  - Lógica de picklists relacionadas

#### **MassiveStringUtilityClass**
- **Ubicación:** `force-app/main/default/classes/MassiveStringUtilityClass.cls`
- **Tipo:** Utility Class
- **Descripción:** Utilidades para manipulación de strings.
- **Funcionalidades:**
  - Operaciones masivas de strings
  - Formatos y conversiones

#### **LookupController**
- **Ubicación:** `force-app/main/default/classes/LookupController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Backend para componente lookup.
- **Funcionalidades:**
  - Búsqueda dinámica de registros
  - Retorna resultados formateados

#### **GetRecordId** / **getRecordIdForAura**
- **Ubicación:** `force-app/main/default/classes/`
- **Tipo:** Utility Classes
- **Descripción:** Obtienen IDs de registros.
- **Funcionalidades:**
  - Recuperación de IDs para componentes

#### **GetItems**
- **Ubicación:** `force-app/main/default/classes/GetItems.cls`
- **Tipo:** Utility Class
- **Descripción:** Obtiene ítems de listas.
- **Funcionalidades:**
  - Consultas genéricas

#### **CVSReaderInvocable**
- **Ubicación:** `force-app/main/default/classes/CVSReaderInvocable.cls`
- **Tipo:** Invocable Method
- **Descripción:** Lee archivos CSV desde Flow.
- **Funcionalidades:**
  - Parsing de CSV
  - Retorna datos estructurados

#### **SendEmailWithAttachments**
- **Ubicación:** `force-app/main/default/classes/SendEmailWithAttachments.cls`
- **Tipo:** Utility Class
- **Descripción:** Envía emails con adjuntos.
- **Funcionalidades:**
  - Construcción de emails
  - Adjuntar archivos

#### **EmailMessageRenderController**
- **Ubicación:** `force-app/main/default/classes/EmailMessageRenderController.cls`
- **Tipo:** Controlador Apex
- **Descripción:** Renderiza mensajes de email para visualización.
- **Funcionalidades:**
  - Formatea contenido HTML de emails
  - Prepara datos para componente `emailMessageViewer`

### Gestión de Chatter

#### **FCL_AddUsersToChatterGroup**
- **Ubicación:** `force-app/main/default/classes/FCL_AddUsersToChatterGroup.cls`
- **Tipo:** Utility Class
- **Descripción:** Agrega usuarios a grupos de Chatter.
- **Funcionalidades:**
  - Membresías de grupo
  - Asignación masiva

#### **FCL_RemoveUsersFromChatterGroup**
- **Ubicación:** `force-app/main/default/classes/FCL_RemoveUsersFromChatterGroup.cls`
- **Tipo:** Utility Class
- **Descripción:** Remueve usuarios de grupos de Chatter.
- **Funcionalidades:**
  - Eliminación de membresías
  - Gestión de accesos

#### **FeedItemNotificationHandler**
- **Ubicación:** `force-app/main/default/classes/FeedItemNotificationHandler.cls`
- **Tipo:** Handler Class
- **Descripción:** Maneja notificaciones de FeedItems.
- **Funcionalidades:**
  - Procesamiento de posts
  - Envío de notificaciones

### Handlers y Triggers

#### **FALP_CaseEmailHandler**
- **Ubicación:** `force-app/main/default/classes/FALP_CaseEmailHandler.cls`
- **Tipo:** Email Handler
- **Descripción:** Procesa emails entrantes para crear/actualizar casos.
- **Funcionalidades:**
  - Email-to-Case personalizado
  - Parsing de emails
  - Creación automática de casos

#### **fcl_servicio**
- **Ubicación:** `force-app/main/default/classes/fcl_servicio.cls`
- **Tipo:** Service Class
- **Descripción:** Lógica de negocio para servicios.
- **Funcionalidades:**
  - Operaciones sobre servicios
  - Validaciones de negocio

### Migración y Batch Jobs

#### **falp_migracionCase_CTRL**
- **Ubicación:** `force-app/main/default/classes/falp_migracionCase_CTRL.cls`
- **Tipo:** Controller
- **Descripción:** Controlador para migración de casos.
- **Funcionalidades:**
  - UI para migración
  - Configuración de parámetros

#### **falp_migracionCase_bch**
- **Ubicación:** `force-app/main/default/classes/falp_migracionCase_bch.cls`
- **Tipo:** Batch Apex
- **Descripción:** Batch para migración de casos.
- **Funcionalidades:**
  - Migración masiva de casos
  - Transformación de datos

#### **falp_migracionCase_sch**
- **Ubicación:** `force-app/main/default/classes/falp_migracionCase_sch.cls`
- **Tipo:** Schedulable
- **Descripción:** Scheduler para migración de casos.
- **Funcionalidades:**
  - Ejecución programada de migración
  - Automatización de proceso

### Mocks para Testing

#### **BenefitVerificationMockDataGenerator**
- **Descripción:** Genera datos mock para verificación de beneficios.

#### **BenefitsVerificationInterOpMock**
- **Descripción:** Mock para interoperabilidad de verificación de beneficios.

#### **wsListPLusMock_tst**
- **Descripción:** Mock para testing de wsListPlus.

### Benefit Verification

#### **ImportBVCodeSetController**
- **Descripción:** Importa conjuntos de códigos de verificación de beneficios.

#### **ImportBVRelatedDataController**
- **Descripción:** Importa datos relacionados de verificación de beneficios.

---

## Clases de Test

Cada clase Apex tiene su correspondiente clase de test con el sufijo `_Test` o `Test`:

- `CL_AddFolios_Test.cls`
- `CL_AddPresupuestos_Test.cls`
- `CasosListControllerTest.cls`
- `FCL_CasesListControllerTest.cls`
- `HandOverControllerTest.cls`
- `MedicalDeviceRequestControllerTest.cls`
- `SRV_InsertSurveyInvitationsTest.cls`
- `fcl_CaseStatisticsControllerTest.cls`
- etc.

Estas clases garantizan la cobertura de código y validan la funcionalidad de las clases principales.

---

## Estructura del Proyecto

```
force-app/main/default/
├── lwc/                          # Lightning Web Components
│   ├── fCL_casesShowToGroup/     # Gestión de casos
│   ├── fCL_ListaSolicitudesDeMejora/  # Solicitudes de mejora
│   ├── markProductForOrder/      # Gestión de productos
│   ├── patientRegistration/      # Registro de pacientes
│   ├── eSignature/               # Firma electrónica
│   └── ...
├── classes/                      # Clases Apex
│   ├── FCL_CasesListController.cls
│   ├── CL_AddFolios.cls         # REST Services
│   ├── SRV_InsertSurveyInvitations.cls
│   ├── HandOverController.cls
│   └── ...
└── triggers/                     # Triggers Apex
```

---

## Tecnologías Utilizadas

- **Salesforce Lightning Web Components (LWC):** Framework JavaScript moderno para UI
- **Apex:** Lenguaje de programación backend de Salesforce
- **REST Services:** Integración con sistemas externos (Oracle)
- **SOAP Web Services:** Servicios legacy
- **Batch Apex:** Procesamiento asíncrono masivo
- **Invocable Methods:** Integración con Flows
- **Health Cloud:** Funcionalidades específicas de salud
- **Experience Cloud (Communities):** Portales de usuario
- **SheetJS (xlsx):** Librería para exportación a Excel

---

## Patrones de Diseño

### Controladores Apex
- **Separation of Concerns:** Controladores separados por funcionalidad
- **Cacheable Methods:** Uso de `@AuraEnabled(cacheable=true)` para optimización
- **Error Handling:** Manejo de excepciones con `AuraHandledException`

### LWC
- **Wire Service:** Uso de `@wire` para data binding reactivo
- **Composición:** Componentes padre-hijo reutilizables
- **Track Properties:** Uso de `@track` para reactividad
- **Debouncing:** Implementación de delays en búsquedas (300ms)

### Integración
- **External IDs:** Uso de campos externos para upserts (evitar duplicados)
- **Bulk Processing:** Operaciones masivas con batch y upsert
- **Response Wrappers:** Clases internas para estructurar respuestas

---

## Convenciones de Nomenclatura

### Clases Apex
- **Controladores:** `*Controller` (ej. `CasosListController`)
- **REST Services:** `CL_Add*` (ej. `CL_AddFolios`)
- **Servicios:** `SRV_*` (ej. `SRV_InsertSurveyInvitations`)
- **Batch:** `*_BACH` (ej. `SRV_InsertSurveyInvitations_BACH`)
- **Utilidades:** `*Helper`, `*Utility` (ej. `PicklistDependencyHelper`)
- **Tests:** `*Test`, `*_Test` (ej. `CasosListControllerTest`)

### LWC
- **Prefijo:** Muchos componentes usan prefijo `fCL_` o `fcl_` (FALP Chile)
- **CamelCase:** Nombres descriptivos en camelCase
- **Sufijos funcionales:** `*Modal`, `*List`, `*Chart`, etc.

---

## Funcionalidades Principales del Sistema

### 1. Gestión de Casos Médicos
- Visualización de casos por grupos de trabajo
- Filtrado avanzado y exportación
- Estadísticas y métricas en tiempo real
- Sistema de derivación y seguimiento

### 2. Solicitudes y Requerimientos de Mejora
- Creación de solicitudes de mejora
- Asignación a unidades responsables
- Seguimiento de estados
- Sistema de notificaciones

### 3. Gestión de Presupuestos y Folios
- Integración con sistema Oracle
- Sincronización bidireccional
- Relación presupuestos-folios-casos
- Actualización automática de estados

### 4. Dispositivos y Productos Médicos
- Control de inventario
- Traspasos entre ubicaciones
- Productos serializados
- Solicitudes y devoluciones

### 5. Encuestas de Satisfacción
- Invitaciones masivas
- Seguimiento de participantes
- Procesamiento por lotes

### 6. Evaluaciones de Salud Mental
- Cuestionarios estandarizados (GAD-7, PHQ-9, AUDIT-C)
- Evaluaciones de riesgo
- Admisión de pacientes
- Integración con Health Cloud

---

## Dependencias Externas

### Static Resources
- **xlsxexport:** Librería SheetJS para exportación a Excel

### Objetos Personalizados
- `Solicitud_de_Mejora__c`
- `Requerimiento_de_Mejora__c`
- `Participante_de_Encuesta__c`
- `Servicios_en_Caso__c`
- `FALP_Folio__c`
- `FALP_RelacionPresupuestoFolio__c`

---

## Mejores Prácticas Implementadas

1. **Bulkification:** Todas las operaciones DML manejan listas
2. **Governor Limits:** Uso de paginación y batch para grandes volúmenes
3. **Testing:** Cobertura de test para todas las clases
4. **Security:** `with sharing` en controladores
5. **Caching:** Métodos cacheables para optimización
6. **Error Handling:** Manejo robusto de excepciones
7. **Separation of Concerns:** Lógica separada por capas

---

## Autor

Giorgio Meniconi y Teresa Moron 
Devs Fullstack Salesforce - Whynotdigital 2025

---

## Versión

Documento generado: Noviembre 2024
