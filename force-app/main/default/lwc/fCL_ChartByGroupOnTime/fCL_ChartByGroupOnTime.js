import { LightningElement, track, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import obtenerDatosGrafico from "@salesforce/apex/fCL_CasesChartViewOnTime.obtenerDatosGrafico";
import ChartJS from "@salesforce/resourceUrl/chartjs_v280";
import getEstadoOptions from "@salesforce/apex/FCL_CasesListController.getEstadoOptions";
import getTipoRequerimientoOptions from "@salesforce/apex/fCL_CasesChartViewOnTime.getTipoRequerimientoOptions";
import SHEETJS from "@salesforce/resourceUrl/xlsxexport";

const COLUMNS = [
    { label: 'Número de Caso', fieldName: 'caseUrl', type: 'url', typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_self' }, sortable: true },
    { label: 'Asunto', fieldName: 'Subject', sortable: true },
    { label: 'Estado', fieldName: 'Status', sortable: true },
    { label: 'Unidad', fieldName: 'cc_ap_Origen_de_requerimiento__c', sortable: true},
    { label: 'Servicios', fieldName: 'groupNames', type: 'text', sortable: true },
    { label: 'Nombre Paciente', fieldName: 'Nombre_Completo_Chile__c', sortable: true},
    { label: 'Tipo de Requerimiento', fieldName: 'cc_ap_Tipo_de_Gestion__c', sortable: true },
    { label: 'Alta Complejidad?', fieldName: 'cc_ap_AC__c' ,type: 'boolean', sortable: true},
    { label: 'Fecha de Creación', fieldName: 'CreatedDate', type:'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false }, sortable: true }, //Se agrega el atributo typeAttributes para mostrar la fecha en formato dd/mm/yyyy hh:mm
    { label: 'Fecha de Cierre', fieldName: 'ClosedDate', type:'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false }, sortable: true },
];

export default class FCL_ChartByGroupOnTime extends LightningElement {
  @track filters = {
    anio: new Date().getFullYear(), //  se inicializa con el año actual
    meses: Array.from({ length: new Date().getMonth() + 1 }, (_, i) =>String(i + 1)), // <-- se incializa array de strings con los meses desde enero hasta el mes actual
    tipoRequerimiento: null, // se inicializa como null para que no se aplique filtro
    estado: null,
    servicio: null,
    unidad: null,
    gerencia: null
  };

  @track error;
  @track columns = COLUMNS;
  @track cases = [];
  @track displayedCases = [];

  //array para almacenar las opciones de los filtros
  @track tipoRequerimientoOptions = [];
  @track estadoOptions = [];
  @track servicioOptions = [];
  @track unidadOptions = [];
  @track gerenciaOptions = [];

  chart; // Referencia al gráfico Chart.js
  chartInitialized = false;

  connectedCallback() {
    if (!this.sheetJsInitialized) {
      loadScript(this, SHEETJS)
        .then(() => {
          this.sheetJsInitialized = true;
          console.log("SheetJS loaded");
        })
        .catch((error) => {
          console.error("Error loading SheetJS", error);
        });
    }
  }

  // Opciones para filtros
  get yearsOptions() {
    const currentYear = new Date().getFullYear();
    return [
      { label: `${currentYear}`, value: `${currentYear}` },
      { label: `${currentYear - 1}`, value: `${currentYear - 1}` },
      { label: `${currentYear - 2}`, value: `${currentYear - 2}` },
      { label: `${currentYear - 3}`, value: `${currentYear - 3}` },
      { label: `${currentYear - 4}`, value: `${currentYear - 4}` },
      { label: `${currentYear - 5}`, value: `${currentYear - 5}` }
    ];
  }

  get monthsOptions() {
    return [
      { label: "Enero", value: "1" },
      { label: "Febrero", value: "2" },
      { label: "Marzo", value: "3" },
      { label: "Abril", value: "4" },
      { label: "Mayo", value: "5" },
      { label: "Junio", value: "6" },
      { label: "Julio", value: "7" },
      { label: "Agosto", value: "8" },
      { label: "Septiembre", value: "9" },
      { label: "Octubre", value: "10" },
      { label: "Noviembre", value: "11" },
      { label: "Diciembre", value: "12" }
    ];
  }

  //se recupera la lista de casos desde el apex
  @wire(obtenerDatosGrafico, {
    anio: "$filters.anio",
    meses: "$filters.meses",
    tipoRequerimiento: "$filters.tipoRequerimiento",
    estados: "$filters.estado",
    unidad: '$filters.unidad', servicios: "$filters.servicio", gerencia: "$filters.gerencia"
  })
  wiredCases({ error, data }) {
    if (data) {
      this.cases = data.casosFiltrados.map((caseRecord) => ({
        ...caseRecord,
        caseUrl: `/case/${caseRecord.Id}`,
        groupNames: caseRecord.Servicios_en_Caso__r ? caseRecord.Servicios_en_Caso__r.map( (servicios) => servicios.Nombre_de_Grupo__c).join(", ") : "", // Extrae los nombres de los grupos
        gerenciaNames: caseRecord.Servicios_en_Caso__r ? caseRecord.Servicios_en_Caso__r.map( (servicios) => servicios.Gerencia__c).join(", ") : "", // Extrae los nombres de las gerencias
}));
      this.displayedCases = this.cases.slice(0,100); // Limitar a 100 casos para la tabla
      console.log('Casos procesados:', this.cases);
      this.error = undefined; // Limpiar errores previos
    } else if (error) {
      console.error("Error al cargar los casos:", error);
      this.error = error;
      this.cases = undefined;
    }
  }

  //se recupera la lista de opciones de unidad desde el apex
  @wire(obtenerDatosGrafico, {
    anio: "$filters.anio", meses: "$filters.meses", tipoRequerimiento: "$filters.tipoRequerimiento", estados: "$filters.estado", unidad: '$filters.unidad', servicios: "$filters.servicio", gerencia: "$filters.gerencia"
  })
  wiredUnidads({ error, data }) {
    if (data) {
      this.unidadOptions = [
        { label: "", value: null, disabled: true },
        ...data.unidadesAsociadas.map((u) => ({ label: u, value: u }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de unidad: ", error);
    }
  }

  //se recupera la lista de opciones de servicio desde el apex
  @wire(obtenerDatosGrafico, {
    anio: "$filters.anio", meses: "$filters.meses", tipoRequerimiento: "$filters.tipoRequerimiento", estados: "$filters.estado", unidad: '$filters.unidad', servicios: "$filters.servicio", gerencia: "$filters.gerencia"
  })
  wiredServicios({ error, data }) {
    if (data) {
      this.servicioOptions = [
        { label: "", value: null, disabled: true },
        ...data.subunidadesAsociadas.map((s) => ({ label: s, value: s }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de servicio: ", error);
    }
  }

  //se recupera la lista de opciones de gerencia desde el apex
  @wire(obtenerDatosGrafico, {
    anio: "$filters.anio", meses: "$filters.meses", tipoRequerimiento: "$filters.tipoRequerimiento", estados: "$filters.estado", unidad: '$filters.unidad', servicios: "$filters.servicio", gerencia: '$filters.gerencia'
  })
  wiredGerencias({ error, data }) {
    if (data) {
      this.gerenciaOptions = [
        { label: "", value: null, disabled: true },
        ...data.gerenciasAsociadas.map((g) => ({ label: g, value: g }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de gerencia: ", error);
    }
  }

  //se recupera la lista de opciones de tipo de requerimiento desde el apex
  @wire(getTipoRequerimientoOptions)
  wiredRequerimientos({ error, data }) {
    if (data) {
      this.tipoRequerimientoOptions = [
        { label: "", value: null, disabled: true },
        ...data.map((tr) => ({ label: tr, value: tr }))
      ];
    } else if (error) {
      console.error(
        "Error al obtener las opciones de tipo de requerimiento: ",
        error
      );
    }
  }

  // se recupera la lista de opciones de estados desde el apex
  @wire(getEstadoOptions)
  wiredEstados({ error, data }) {
    if (data) {
      this.estadoOptions = [
        { label: "", value: null, disabled: true },
        ...data.map((e) => ({ label: e, value: e }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de estado: ", error);
    }
  }


  renderedCallback() {
    // Evitar inicializar el gráfico más de una vez
    if (this.chartInitialized) {
      return;
    }
    this.chartInitialized = true;

    // Cargar la librería Chart.js desde el Static Resource y luego obtener datos Apex
    Promise.all([
      loadScript(this, ChartJS)
    ])
    .then(() => {
      this.loadChartData();
    })
    .catch((error) => {
      console.error("Error al cargar Chart.js: ", error);
    });
  }
  // Manejo de eventos de cambio de filtro
  handleFilterChange(event) {
    const filterName = event.target.dataset.filter; // Nombre del filtro
    let filterValue = event.detail.value; // Valor del filtro

    // Actualizar el valor del filtro en el objeto filters
    this.filters = {
      ...this.filters,
      [filterName]: filterValue
    };
    this.loadChartData(); // Recarga el grafico con lo nuevos filtros
  }
  handleMonthSelection(event) {
    const mesesSeleccionados = event.detail; // Aquí llega el array con los meses seleccionados

    // Actualizar el filtro de meses en el objeto filters
    this.filters.meses =
      mesesSeleccionados.length > 0
        ? mesesSeleccionados
        : Array.from({ length: new Date().getMonth() + 1 }, (_, i) =>
            String(i + 1)
          ); // Si no hay meses seleccionados, se asigna el array por defecto

    //this.filters.meses = mesesSeleccionados;
    this.loadChartData(); // o lo que uses para aplicar el filtro
  }
  loadChartData() {
    const anioo = String(this.filters.anio);
    const mesesArray = this.filters.meses;

    obtenerDatosGrafico({
      anio: anioo,
      meses: mesesArray,
      tipoRequerimiento: this.filters.tipoRequerimiento,
      estados: this.filters.estado,
      unidad: this.filters.unidad,
      servicio: this.filters.servicio,
      gerencia: this.filters.gerencia
    })
      .then((result) => {
        console.log("Datos del gráfico:", result);

        const datos = result.datosGrafico; // Acceder directamente al array de datos
        const labels = datos.map((item) => this.getNombreMes(item.mes));
        const enPlazo = datos.map((item) => item.porcentajeEnPlazo);
        const fueraDePlazo = datos.map((item) => item.porcentajeFueraPlazo);

        // Obtener el contexto del canvas y construir el gráfico
        const ctx = this.template.querySelector("canvas").getContext("2d");

        if (this.chart) {
          this.chart.destroy(); // Destruir el gráfico existente antes de crear uno nuevo
        }
        // Crear el gráfico
        this.chart = new window.Chart(ctx, {
          type: "bar",
          data: {
            labels: labels,
            datasets: [
              {
                label: "% En Plazo",
                data: enPlazo,
                backgroundColor: "rgb(44, 187, 235)",
                stack: "Stack 1"
              },
              {
                label: "% Fuera de Plazo",
                data: fueraDePlazo,
                backgroundColor: "rgb(225, 56, 50)",
                stack: "Stack 1"
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: true,
                position: "top"
              },
              tooltip: {
                callbacks: {
                  label: function (context) {
                    return `${context.dataset.label}: ${context.raw.toFixed(1)}%`; // Mostrar el valor con un decimal
                  }
                }
              }
            },
            scales: {
              y: {
                stacked: true,
                min: 0,
                max: 100,
                ticks: {
                  callback: function (value) {
                    return `${value}%`; // Mostrar valores como porcentaje
                  }
                }
              },
              yAxes: [
                { stacked: true,
                  scaleLabel: {
                    display: true,
                    labelString: "% Casos"
                  }
                }
              ],
              x: {
                stacked: true
              },
              xAxes: [
                { stacked: true,
                  scaleLabel: {
                    display: true,
                    labelString: "Meses"
                  }
                }
              ]
            }
          }
        });
      })
      .catch((error) => {
        console.error("Error al cargar los datos del Apex:", error);
      });
  }

  //función para obtener el nombre del mes a partir de su número
  getNombreMes(numero) {
    const nombreMeses = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
    return nombreMeses[parseInt(numero, 10) - 1];
  }

  //funcion para ordenar los datos al hacer clic en el encabezado de la columna
  handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  //funcion que ordena los datos segun el tipo (texto, numero, fecha)
  sortData(fieldName, direction) {
    let sortedData = [...this.displayedCases]; // Copia de los datos a ordenar

    // Ordena los datos
    sortedData.sort((a, b) => {
      let valueA =
        a[fieldName] !== undefined && a[fieldName] !== null ? a[fieldName] : "";
      let valueB =
        b[fieldName] !== undefined && b[fieldName] !== null ? b[fieldName] : "";

      // detecta el tipo de dato de la columna (texto, número, fecha)
      let isDate = valueA instanceof Date && valueB instanceof Date;
      let isNumeric = typeof valueA === "number" && typeof valueB === "number";
      let isText = typeof valueA === "string" && typeof valueB === "string";

      //si el formato de fecha es de tipo string valida que estos representen una fecha
      if (
        !isDate &&
        typeof valueA === "string" &&
        typeof valueB === "string" &&
        fieldName.toLowerCase().includes("date")
      ) {
        valueA = new Date(valueA);
        valueB = new Date(valueB);
        isDate = true;
      }

      // si es numerico se convierte a número antes de ordenar
      if (isNumeric) {
        valueA = Number(valueA);
        valueB = Number(valueB);
      } else if (isDate) {
        // si es fecha se convierte a fecha (Date)
        valueA = new Date(valueA);
        valueB = new Date(valueB);
      } else if (isText) {
        valueA = valueA.toLowerCase();
        valueB = valueB.toLowerCase();
      }
      // Ordena los datos
      return direction === "asc"
        ? valueA > valueB
          ? 1
          : -1
        : valueA < valueB
          ? 1
          : -1;
    });
    // Asigna los datos ordenados a la propiedad cases
    this.displayedCases = sortedData;
  }

  //Funcion que restablece todos los filtros y muestra la lista completa de casos
  clearFilters() {
    this.filters.anio= new Date().getFullYear(), // año actual
    this.filters.meses= Array.from({ length: new Date().getMonth() + 1 }, (_, i) =>String(i + 1)), // <-- se incializa array de strings con los meses desde enero hasta el mes actual
    this.filters.tipoRequerimiento= null, // se inicializa como null para que no se aplique filtro
    this.filters.estado= null,
    this.filters.servicio= null,
    this.filters.unidad= null,
    this.filters.gerencia= null
    this.cases=[...this.displayedCases];

    // Llamar a loadChartData para recargar el gráfico con los valores predeterminados
    this.loadChartData();
  }

  handleExport() {
    // Crear un mapa de fieldName => label
    const fieldMap = {};
    this.columns.forEach(col => {
        fieldMap[col.fieldName] = col.label;
    });

    // Transformar los datos con los labels como claves
    const exportData = this.cases.map(item => {
        const row = {};
        this.columns.forEach(col => {
            let value = col.fieldName === 'caseUrl' ? item.CaseNumber : item[col.fieldName];
            // Si es fecha, convertir a string legible
            if (col.type === 'date' && value) {
                value = new Date(value).toLocaleString('es-CL');
            }
            //Si es el campo Alta Complejidad, convertir  true/false a Sí/No
            if(col.fieldName === 'cc_ap_AC__c') {
                console.log(value);
                value = value === true ? 'Sí' : 'No';
            }
            row[col.label] = value;
        });
        return row;
    });

    // Convertir a hoja Excel
    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = { Sheets: { 'Casos': ws }, SheetNames: ['Casos'] };
    const fecha = new Date().toISOString().slice(0, 10); // formato YYYY-MM-DD
    XLSX.writeFile(wb, `CasosExportados_${fecha}.xlsx`);
}


}