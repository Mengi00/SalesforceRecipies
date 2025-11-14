public with sharing class fCL_CasesChartViewOnTime2 {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> obtenerDatosGrafico(
        String anio,
        List<String> meses, //array de meses
        String tipoRequerimiento,
        String estados,
        String unidad,
        String servicios,
        String gerencia) {

        // Validar y manejar el parámetro 'anio'
        Integer anioNum;
        // si se especifica anio converitr a entero, sino asignar el año actual
        anioNum = (anio != null && anio != '') ? Integer.valueOf(anio) : Date.today().year(); 

        System.debug('Parámetros recibidos:');
        System.debug('Año: ' + anio);
        System.debug('Meses: ' + meses);
        System.debug('Tipo de Requerimiento: ' + tipoRequerimiento);
        System.debug('Estados: ' + estados);
        System.debug('Servicios: ' + servicios);

        // validar meses, si es null o no se especifica meses entonces toma todos los meses (primeros 12 meses)
        List<Integer> mesesFiltrados = new List<Integer>();
        if (meses != null && !meses.isEmpty()) {
            // si meses no esta vacio ni es null entonces
            for (String mesStr : meses) {
                // recorre los meses recibidos y los convierte a Integer para filtrar y ordenarlos
                mesesFiltrados.add(Integer.valueOf(mesStr.trim())); // Se agrega el mes a la lista de Integer
            }
        } else {
        // si no recibe meses significa que se quieren todos los meses hasta el mes actual
        for (Integer i = 1; i <= Date.today().month(); i++) {
            mesesFiltrados.add(i);
        }
        }

        System.debug('Año filtrado: ' + anioNum);
        System.debug('Meses filtrados: ' + mesesFiltrados);

        Date startDate = Date.newInstance(anioNum, 1, 1);// primer día del año
        Date endDate = Date.today();// fecha actual

        // Obtener el ID del usuario actual
        Id currentUserId = UserInfo.getUserId();
        String eu = [SELECT Email FROM User WHERE Id = :currentUserId].Email;

        // Obtener los grupos de Chatter (CollaborationGroup) a los que pertenece el usuario
        List<CollaborationGroupMember> groupMemberships = [
            SELECT CollaborationGroup.Name 
            FROM CollaborationGroupMember 
            WHERE Member.Email = :eu
        ];

        // Extraer los nombres de grupo para filtrar
        List<String> collabGroupNames = new List<String>();
        for (CollaborationGroupMember gm : groupMemberships) {
            collabGroupNames.add(gm.CollaborationGroup.Name);
        }

        System.debug('Grupos de Chatter del usuario: ' + collabGroupNames);

        // Obtener las unidades asociadas a los servicios del usuario
        List<String> unidadesAsociadas = obtenerUnidadesPorServicios(collabGroupNames);
        System.debug('Unidades asociadas a los servicios del usuario: ' + unidadesAsociadas);

        // Obtener las gerencias asociadas a los servicios del usuario
        List<String> gerenciasAsociadas = obtenerGerenciasPorUsuario(unidadesAsociadas);
        System.debug('Gerencias asociadas a los servicios del usuario: ' + gerenciasAsociadas);

        // Obtener las subunidades asociadas a la unidad seleccionada y los servicios del usuario
        List<String> subunidadesAsociadas = obtenerSubunidadesPorUnidadYServicios(unidad, collabGroupNames);
        System.debug('Subunidades asociadas a la unidad seleccionada y servicios del usuario: ' + subunidadesAsociadas);

        // Obtener las unidades asociadas a la gerencia seleccionada si se especifica
        List<String> unidadesDeGerencia = new List<String>();
        if (gerencia != null || gerencia != '') {
            Map<String, List<String>> dependenciasGerenciaUnidad = PicklistDependencyHelper.obtenerDependenciasGerenciaUnidad();
            if (dependenciasGerenciaUnidad.containsKey(gerencia)) {
                unidadesDeGerencia = dependenciasGerenciaUnidad.get(gerencia);
                System.debug('Unidades asociadas a la gerencia seleccionada: ' + unidadesDeGerencia);
            }
        }

        // Filtrar los casos por el nombre del grupo de servicios
        List<Id> casoIdsFiltrados = new List<Id>();
        if (servicios == null || servicios == '') {// si no se especifica servicios entonces filtrar por los grupos de Chatter
            List<Servicios_en_Caso__c> serviciosFiltrados = [
                SELECT Caso__r.Id
                FROM Servicios_en_Caso__c
                WHERE Nombre_de_Grupo__c IN :collabGroupNames
            ];
        
            for (Servicios_en_Caso__c sc : serviciosFiltrados) {
                casoIdsFiltrados.add(sc.Caso__r.Id);
            }
        }

        // Construir consulta SOQL base para obtener los casos dentro del rango de fechas especificado
        String query = 'SELECT Id, cc_ap_AC__c, cc_ap_Tipo_de_Gestion__c, CaseNumber, Subject, Status, CreatedDate, Nombre_Completo_Chile__c, cc_ap_Sub_rea_del_Requerimiento__c, cc_ap_Origen_de_requerimiento__c, (SELECT Nombre_de_Grupo__c FROM Servicios_en_Caso__r) ' +
                       'FROM Case WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate AND cc_ap_Tipo_de_Gestion__c != null';
        // Filtros dinámicos: solo agregar condiciones si los valores no están vacíos
        if (anio != null && anio != '') {
            query += ' AND CALENDAR_YEAR(CreatedDate) = :anioNum';
        }
        if (!mesesFiltrados.isEmpty()) {
            query += ' AND CALENDAR_MONTH(CreatedDate) IN :mesesFiltrados';
        }
        if (tipoRequerimiento != null && tipoRequerimiento != '') {
            query += ' AND cc_ap_Tipo_de_Gestion__c = :tipoRequerimiento';
        }
        if (estados != null && estados != '') {
            query += ' AND Status = :estados';
        }
        if (unidad != null && unidad != '') {
            query += ' AND cc_ap_Origen_de_requerimiento__c = :unidad';
        }
        // Si hay unidades asociadas a la gerencia seleccionada, filtrar los casos por esas unidades
        if (!unidadesDeGerencia.isEmpty()) {
            query += ' AND cc_ap_Origen_de_requerimiento__c IN :unidadesDeGerencia';
        }
        if (!casoIdsFiltrados.isEmpty()) {// si se filtran casos por servicios
            query += ' AND Id IN :casoIdsFiltrados';// filtra los casos por el id de los servicios en caso
        }

        System.debug('Consulta SOQL generada: ' + query);
        System.debug('Meses como enteros: ' + mesesFiltrados);
        // Ejecutar consulta
        List<Case> casos = Database.query(query);// almacena los casos obtenidos

        System.debug('Casos obtenidos: ' + casos);

        // Verificar si se obtuvieron casos
        if (casos.isEmpty()) {
            System.debug('No se encontraron casos para los filtros aplicados.');
        }

        // Obtener días festivos
        Set<Date> diasFestivos = obtenerDiasFestivos(anioNum);

        // Initializar un mapa para almacenar los datos por tipo y estado
        Map<String, Map<String, Integer>> dataByTypeAndStatus = new Map<String, Map<String, Integer>>();

        for (Case c : casos) {
            String tipo = c.cc_ap_Tipo_de_Gestion__c;
            String status;

            // Determinar el estado del caso
            if (c.Status == 'Cerrado') {
                status = 'Resuelto';
            } else {
                Integer diasHabiles = calcularDiasHabiles(c.CreatedDate.date(), diasFestivos);
                status = diasHabiles <= 15 ? 'Pendiente' : 'Vencido';
            }

            // Initializa el mapa para el tipo si no existe
            if (!dataByTypeAndStatus.containsKey(tipo)) {
                dataByTypeAndStatus.put(tipo, new Map<String, Integer>{'Pendiente' => 0, 'Vencido' => 0, 'Resuelto' => 0});
            }

            // Incrementa el contador para el estado correspondiente
            dataByTypeAndStatus.get(tipo).put(status, dataByTypeAndStatus.get(tipo).get(status) + 1);
        }

        System.debug('Data by Type and Status: ' + dataByTypeAndStatus);

        // Preparar datos del gráfico
        List<Map<String, Object>> datos = new List<Map<String, Object>>();
        for (String tipo : dataByTypeAndStatus.keySet()) {
            Map<String, Integer> statusCounts = dataByTypeAndStatus.get(tipo);
            datos.add(new Map<String, Object>{
                'tipoRequerimiento' => tipo,
                'pendiente' => statusCounts.get('Pendiente'),
                'vencido' => statusCounts.get('Vencido'),
                'resuelto' => statusCounts.get('Resuelto')
            });
        }

        System.debug('Datos del gráfico preparados: ' + datos);

        // Retorna los datos del grafico y el total de casos
        Map<String, Object> resultado = new Map<String, Object>();
        resultado.put('datosGrafico', datos);
        resultado.put('totalCasos', casos.size());
        resultado.put('casosFiltrados', casos);
        resultado.put('unidadesAsociadas', unidadesAsociadas);
        resultado.put('subunidadesAsociadas', subunidadesAsociadas);
        resultado.put('gerenciasAsociadas', gerenciasAsociadas);

        System.debug('Resultado final: ' + resultado);

        return resultado;    
    }

    // Método para obtener los días festivos
    public static Set<Date> obtenerDiasFestivos(Integer anioSeleccionado) {
        // Obtener los días festivos desde el objeto Holiday
        Date inicioAnio = Date.newInstance(anioSeleccionado, 1, 1); // primer día del año
        Date finFeriados;

        // Si el año seleccionado es el actual, establecer la fecha de fin como hoy
        if(anioSeleccionado == Date.today().year()) {
            finFeriados = Date.today();
        } else {// de lo contrario, establecerla como el 31 de diciembre del año seleccionado
            finFeriados = Date.newInstance(anioSeleccionado, 12, 31);
        }
        Set<Date> diasFestivos = new Set<Date>();
        List<Holiday> feriados = [
            SELECT ActivityDate 
            FROM Holiday 
            WHERE ActivityDate >= :inicioAnio AND ActivityDate <= :finFeriados
        ];
        for (Holiday h : feriados) {
            diasFestivos.add(h.ActivityDate);
        }
        return diasFestivos;
    }

    // metodo para calcular los días hábiles entre dos fechas
    public static Integer calcularDiasHabiles(Date fechaCreacion, Set<Date> diasFestivos) {
        Integer diasHabiles = 0; // Contador de días hábiles
        Date fechaActual = Date.today();

        // Mientras la fecha de creación sea menor a la fecha actual
        while (fechaCreacion <= fechaActual) {
            // Calcular el día de la semana (0=domingo, 1=lunes, ..., 6=sábado)
            Integer diaSemana = fechaCreacion.toStartOfWeek().daysBetween(fechaCreacion);

            //si no es fin de semana y no es festivo cuenta como dia habil
            if (diaSemana >= 2 && diaSemana <= 6 && !diasFestivos.contains(fechaCreacion)) {
                diasHabiles++;
            }
            fechaCreacion = fechaCreacion.addDays(1);
        }
        // Retornar true si los días hábiles son menores o iguales a 15
        return diasHabiles;
    }

    // Clase interna para representar los datos del gráfico
    public class DatoGrafico {
        @AuraEnabled public String tipoGestion { get; set; }
        @AuraEnabled public Integer cantidad { get; set; }

        public DatoGrafico(String tipoGestion, Integer cantidad) {
            this.tipoGestion = tipoGestion;
            this.cantidad = cantidad;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTipoRequerimientoOptions(){
        Set<String> values = new Set<String>();
        for (Schema.PicklistEntry entry : Case.cc_ap_Tipo_de_Gestion__c.getDescribe().getPicklistValues()) {
            values.add(entry.getValue());
        }
        return new List<String>(values);
    }

    @AuraEnabled(cacheable=true)
  public static List<String> obtenerUnidadesPorServicios(List<String> serviciosUsuario) {
    // Obtener el mapa de dependencias entre unidades y servicios
    Map<String, List<String>> dependencias = PicklistDependencyHelper.obtenerDependenciasUnidadSubUnidad();
    List<String> unidadesFiltradas = new List<String>();

    // Iterar sobre las dependencias para encontrar las unidades que contienen los servicios del usuario
    for (String unidad : dependencias.keySet()) {
      List<String> serviciosDeUnidad = dependencias.get(unidad);
      for (String servicio : serviciosUsuario) {
        if (serviciosDeUnidad.contains(servicio)) {
          if (!unidadesFiltradas.contains(unidad)) {
            unidadesFiltradas.add(unidad);
          }
        }
      }
    }

    System.debug('Unidades filtradas por servicios del usuario: ' + unidadesFiltradas);
    return unidadesFiltradas;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> obtenerSubunidadesPorUnidadYServicios(String unidadSeleccionada, List<String> serviciosUsuario) {
    // Obtener el mapa de dependencias entre unidades y subunidades/servicios
    Map<String, List<String>> dependencias = PicklistDependencyHelper.obtenerDependenciasUnidadSubUnidad();
    List<String> subunidadesFiltradas = new List<String>();

    // Verificar si la unidad seleccionada tiene subunidades asociadas
    if (dependencias.containsKey(unidadSeleccionada)) {
      List<String> subunidadesDeUnidad = dependencias.get(unidadSeleccionada);

      // Filtrar las subunidades que también están asociadas a los servicios del usuario
      for (String subunidad : subunidadesDeUnidad) {
        if (serviciosUsuario.contains(subunidad)) {
          subunidadesFiltradas.add(subunidad);
        }
      }
    }

    System.debug('Subunidades filtradas para la unidad seleccionada y servicios del usuario: ' + subunidadesFiltradas);
    return subunidadesFiltradas;
  }

  @AuraEnabled(cacheable=true)
  public static List<String> obtenerGerenciasPorUsuario(List<String> unidadesUsuario) {
    // Obtener el mapa de dependencias entre gerencias y unidades
    Map<String, List<String>> dependencias = PicklistDependencyHelper.obtenerDependenciasGerenciaUnidad();
    List<String> gerenciasFiltradas = new List<String>();

    // Iterar sobre las dependencias para encontrar las gerencias que contienen las unidades asociadas a los servicios del usuario
    for (String gerencia : dependencias.keySet()) {
      List<String> unidadesDeGerencia = dependencias.get(gerencia);
      for (String unidad : unidadesUsuario) {
        if (unidadesDeGerencia.contains(unidad)) {
          if (!gerenciasFiltradas.contains(gerencia)) {
            gerenciasFiltradas.add(gerencia);
          }
        }
      }
    }

    System.debug('Gerencias filtradas por servicios del usuario: ' + gerenciasFiltradas);
    return gerenciasFiltradas;
  }

}