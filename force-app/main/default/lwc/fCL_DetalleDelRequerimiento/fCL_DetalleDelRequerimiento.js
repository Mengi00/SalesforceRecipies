import { LightningElement, api, wire } from "lwc";
// Importamos los dos métodos que creamos en Apex
import getDetails from "@salesforce/apex/fCL_RequerimientosDeMejora.getDetails";
import markAsViewed from "@salesforce/apex/fCL_RequerimientosDeMejora.markAsViewed";

export default class FCL_DetalleDelRequerimiento extends LightningElement {
  // La propiedad 'recordId' recibirá automáticamente el ID del registro desde la página del portal
  @api recordId;

  // Nueva propiedad para mostrar errores
  errorMsg;

  // -- LÓGICA PARA MARCAR COMO VISTO --
  // connectedCallback se ejecuta automáticamente cuando el componente se carga en la página
  connectedCallback() {
    if (this.recordId) {
      console.log("Record ID:", this.recordId);
      // Llamamos al método de Apex para registrar la vista
      markAsViewed({ recordId: this.recordId }).catch((error) => {
        // Manejo de errores en caso de que la actualización falle
        console.error("Error al marcar como visto:", error);
      });
    }
  }

  // -- LÓGICA PARA OBTENER Y MOSTRAR LOS DATOS --
  // El decorador @wire llama automáticamente al método de Apex y guarda el resultado
  @wire(getDetails, { recordId: "$recordId" })
  requerimiento; // El resultado (data o error) se guarda en esta propiedad

  // Observa los cambios en el wire para capturar errores
  renderedCallback() {
    if (this.requerimiento && this.requerimiento.error) {
      this.errorMsg = this.requerimiento.error.body
        ? this.requerimiento.error.body.message
        : "Error desconocido al cargar los detalles.";
    }
  }

  // Getter para mostrar el error en pantalla
  get showError() {
    return this.errorMsg ? true : false;
  }

  // Usamos 'getters' para acceder de forma segura a los datos de objetos relacionados
  get unidadResponsableName() {
    // retorna el nombre de la unidad responsable si los datos están disponibles
    return this.requerimiento.data
      ? this.requerimiento.data.Unidad_Responsable__r
          .Nombre_Collaboration_Group__c
      : "";
  }

  get solicitudName() {
    return this.requerimiento.data
      ? this.requerimiento.data.Solicitud_de_Mejora__r.Name
      : "";
  }
}