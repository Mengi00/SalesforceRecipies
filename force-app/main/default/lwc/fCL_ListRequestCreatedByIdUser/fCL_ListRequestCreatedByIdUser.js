import { LightningElement, track, wire } from "lwc";
import getSolicitudesCreadasPorUsuarioActual from "@salesforce/apex/FCL_SolicitudesDeMejoraList.getSolicitudesCreadasPorUsuarioActual";
import getCategoriaOptions from "@salesforce/apex/FCL_SolicitudesDeMejoraList.getCategoriaOptions";
import getEstadoOptions from "@salesforce/apex/FCL_SolicitudesDeMejoraList.getEstadoOptions";

const COLUMNS = [
  {
    label: "Número de solicitud",
    fieldName: "solicitudUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "Name" }, target: "_self" },
    sortable: true
  },
  { label: "Asunto", fieldName: "Titulo__c", sortable: true },
  { label: "Categoria", fieldName: "Categoria_de_Mejora__c", sortable: true },
  { label: "Estado", fieldName: "Estado__c", sortable: true },
  {
    label: "Fecha de Ingreso",
    fieldName: "CreatedDate",
    type: "date",
    typeAttributes: {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false
    },
    sortable: true
  } //Se agrega el atributo typeAttributes para mostrar la fecha en formato dd/mm/yyyy hh:mm
];

export default class FCL_ListRequestCreatedByIdUser extends LightningElement {
  @track solicitudes = [];
  @track error;
  @track columns = COLUMNS;

  @track filteredSolicitudes = [];
  @track showNoSolicitudesMessage = false;

  @track CategoriaOptions = [];
  @track EstadoOptions = [];

  selectedNumeroSolicitud = "";
  selectedAsunto = "";
  selectedCategoria = "";
  selectedEstado = "";
  selectedFechadeingresoDesde = "";
  selectedFechadeingresoHasta = "";

  sortBy;
  sortDirection;

  @wire(getSolicitudesCreadasPorUsuarioActual)
  wiredSolicitudes({ error, data }) {
    if (data) {
      // Mapeamos los datos para incluir el enlace a la URL del caso
      console.log("Solicitudes recibidas: ", data);
      this.solicitudes = data.map((solicitudItem) => ({
        ...solicitudItem,
        // URL para redirigir al detalle
        solicitudUrl: `/solicitud-de-mejora/${solicitudItem.Id}${solicitudItem.Name ? "/" + encodeURIComponent(solicitudItem.Name) : ""}`
      }));
      this.filteredSolicitudes = [...this.solicitudes];
      this.showNoSolicitudesMessage = this.filteredSolicitudes.length === 0;
      this.error = undefined;
    } else if (error) {
      console.error("Error al obtener las solicitudes: ", error);
      this.error = error;
      this.solicitudes = undefined;
    }
  }

  //Se obtiene las opciones de categoria
  @wire(getCategoriaOptions)
  wiredCategoriaOptions({ error, data }) {
    if (data) {
      this.CategoriaOptions = [
        { label: "", value: "", disabled: true },
        ...data.map((c) => ({ label: c, value: c }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de Categoria: ", error);
    }
  }

  //Se obtiene las opciones de estado
  @wire(getEstadoOptions)
  wiredEstadoOptions({ error, data }) {
    if (data) {
      this.EstadoOptions = [
        { label: "", value: "", disabled: true },
        ...data.map((e) => ({ label: e, value: e }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de Estado: ", error);
    }
  }

  // función para manejar los cambios en los filtros
  handleFilterChange(event) {
    const { name, value } = event.target;
    this[name] = value;

    this.applyFilters();
  }

  // función para aplicar los filtros a las solicitudes
  applyFilters() {
    this.filteredSolicitudes = this.solicitudes.filter((item) => {
      return (
        (!this.selectedNumeroSolicitud ||
          (item.Name && item.Name.includes(this.selectedNumeroSolicitud))) &&
        (!this.selectedAsunto ||
          (item.Titulo__c && item.Titulo__c.includes(this.selectedAsunto))) &&
        (!this.selectedCategoria ||
          (item.Categoria_de_Mejora__c &&
            item.Categoria_de_Mejora__c.includes(this.selectedCategoria))) &&
        (!this.selectedEstado ||
          (item.Estado__c && item.Estado__c.includes(this.selectedEstado))) &&
        (!this.selectedFechadeingresoDesde ||
          (item.CreatedDate &&
            new Date(item.CreatedDate) >=
              new Date(this.selectedFechadeingresoDesde))) &&
        (!this.selectedFechadeingresoHasta ||
          (item.CreatedDate &&
            new Date(item.CreatedDate) <=
              new Date(this.selectedFechadeingresoHasta)))
      );
    });
    this.showNoSolicitudesMessage = this.filteredSolicitudes.length === 0;
  }

  //funcion para ordenar los datos al hacer clic en el encabezado de la columna
  handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  //funcion para ordenar los datos
  sortData(fieldName, direction) {
    let sortedData = [...this.filteredSolicitudes];

    //Ordenar los datos
    sortedData.sort((a, b) => {
      let valueA =
        a[fieldName] !== undefined && a[fieldName] !== null
          ? a[fieldName].toString()
          : "";

      let valueB =
        b[fieldName] !== undefined && b[fieldName] !== null
          ? b[fieldName].toString()
          : "";

      //Detecta el tipo de dato para aplicar la comparación correcta (texto, fecha o número)
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
    // Actualiza los datos ordenados
    this.filteredSolicitudes = sortedData;
  }

  // Función para limpiar los filtros
  clearFilters() {
    this.selectedNumeroSolicitud = "";
    this.selectedAsunto = "";
    this.selectedCategoria = "";
    this.selectedEstado = "";
    this.selectedFechadeingresoDesde = "";
    this.selectedFechadeingresoHasta = "";
    this.applyFilters(); // Aplicar los filtros para actualizar la lista de datos
  }
}