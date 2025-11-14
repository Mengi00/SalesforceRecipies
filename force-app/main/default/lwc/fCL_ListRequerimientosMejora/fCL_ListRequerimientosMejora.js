import { LightningElement, track, wire } from "lwc";
import getRequerimientosByResponble from "@salesforce/apex/fCL_RequerimientosDeMejora.getRequerimientosByResponble";
import getCategoriaOptions from "@salesforce/apex/fCL_RequerimientosDeMejora.getCategoriaOptions";
import getEstadoOptions from "@salesforce/apex/fCL_RequerimientosDeMejora.getEstadoOptions";
import getPrioridadOptions from "@salesforce/apex/fCL_RequerimientosDeMejora.getPrioridadOptions";

const COLUMNS = [
  {
    label: "Número de solicitud",
    fieldName: "solicitudUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "Name" }, target: "_self" },
    sortable: true
  },
  { label: "Asunto", fieldName: "Titulo__c", sortable: true },
  { label: "Prioridad", fieldName: "Prioridad__c", sortable: true },
  { label: "Categoria", fieldName: "Categoria_de_Mejora__c", sortable: true },
  { label: "Estado", fieldName: "Estado__c", sortable: true },
  {
    label: "Fecha de Derivación",
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

export default class FCL_ListRequerimientosMejora extends LightningElement {
  @track requerimientos = [];
  @track error;
  @track columns = COLUMNS;

  @track filteredRequerimientos = [];
  @track showNoRequerimientosMessage = false;

  @track CategoriaOptions = [];
  @track EstadoOptions = [];
  @track PrioridadOptions = [];

  selectedNumeroRequerimiento = "";
  selectedAsunto = "";
  selectedCategoria = "";
  selectedEstado = "";
  selectedFechadeDerivacionDesde = "";
  selectedFechadeDerivacionHasta = "";
  selectedPrioridad = "";

  sortBy;
  sortDirection;

  @wire(getRequerimientosByResponble)
  wiredSolicitudes({ error, data }) {
    if (data) {
      // Mapeamos los datos para incluir el enlace a la URL del caso
      console.log("Requisitos recibidos: ", data);
      this.requerimientos = data.map((requerimientoItem) => ({
        ...requerimientoItem,
        // URL para redirigir al detalle
        solicitudUrl: `/requerimiento-de-mejora/${requerimientoItem.Id}${requerimientoItem.Name ? "/" + encodeURIComponent(requerimientoItem.Name) : ""}`
      }));
      this.filteredRequerimientos = [...this.requerimientos];
      this.showNoRequerimientosMessage =
        this.filteredRequerimientos.length === 0;
      this.error = undefined;
    } else if (error) {
      console.error("Error al obtener las solicitudes: ", error);
      this.error = error;
      this.requerimientos = undefined;
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

  //se obtiene las opciones de prioridad
  @wire(getPrioridadOptions)
  wiredPrioridadOptions({ error, data }) {
    if (data) {
      this.PrioridadOptions = [
        { label: "", value: "", disabled: true },
        ...data.map((p) => ({ label: p, value: p }))
      ];
    } else if (error) {
      console.error("Error al obtener las opciones de Prioridad: ", error);
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
    this.filteredRequerimientos = this.requerimientos.filter((item) => {
      return (
        (!this.selectedNumeroRequerimiento ||
          (item.Name &&
            item.Name.includes(this.selectedNumeroRequerimiento))) &&
        (!this.selectedAsunto ||
          (item.Titulo__c && item.Titulo__c.includes(this.selectedAsunto))) &&
        (!this.selectedCategoria ||
          (item.Categoria_de_Mejora__c &&
            item.Categoria_de_Mejora__c.includes(this.selectedCategoria))) &&
        (!this.selectedEstado ||
          (item.Estado__c && item.Estado__c.includes(this.selectedEstado))) &&
        (!this.selectedFechadeDerivacionDesde ||
          (item.CreatedDate &&
            new Date(item.CreatedDate) >=
              new Date(this.selectedFechadeDerivacionDesde))) &&
        (!this.selectedFechadeDerivacionHasta ||
          (item.CreatedDate &&
            new Date(item.CreatedDate) <=
              new Date(this.selectedFechadeDerivacionHasta))) &&
        (!this.selectedPrioridad ||
          (item.Prioridad__c &&
            item.Prioridad__c.includes(this.selectedPrioridad)))
      );
    });
    this.showNoRequerimientosMessage = this.filteredRequerimientos.length === 0;
  }

  //funcion para ordenar los datos al hacer clic en el encabezado de la columna
  handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  //funcion para ordenar los datos
  sortData(fieldName, direction) {
    let sortedData = [...this.filteredRequerimientos];

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
    this.filteredRequerimientos = sortedData;
  }

  // Función para limpiar los filtros
  clearFilters() {
    this.selectedNumeroRequerimiento = "";
    this.selectedAsunto = "";
    this.selectedPrioridad = "";
    this.selectedCategoria = "";
    this.selectedEstado = "";
    this.selectedFechadeDerivacionDesde = "";
    this.selectedFechadeDerivacionHasta = "";
    this.applyFilters(); // Aplicar los filtros para actualizar la lista de datos
  }
}