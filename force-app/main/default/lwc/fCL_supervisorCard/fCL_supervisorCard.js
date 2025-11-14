import { LightningElement, api, wire } from "lwc";
//Importamos las herramientas nativas para obtener datos de un registro
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

// Importamos las referencias a los campos de forma segura
import SUPERVISOR_NAME_FIELD from "@salesforce/schema/Solicitud_de_Mejora__c.Supervisor_Asignado__r.Name";

const FIELDS = [SUPERVISOR_NAME_FIELD];

export default class FCL_supervisorCard extends LightningElement {
  // La propiedad 'recordId' recibe el ID del registro desde la página.
  @api recordId;

  // El decorador @wire
  // usa el método estándar 'getRecord'.
  // Automáticamente obtiene el valor del campo que le pedimos (SUPERVISOR_NAME_FIELD)
  // en cuanto el recordId está disponible.
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  solicitud; // El resultado se guarda aquí

  // se usa un 'getter' para mostrar el nombre de forma limpia en el HTML.
  get supervisorName() {
    // La función 'getFieldValue' extrae el dato de forma segura.
    // Si no hay supervisor asignado, devolverá 'No Asignado'.
    return (
      getFieldValue(this.solicitud.data, SUPERVISOR_NAME_FIELD) || "No Asignado"
    );
  }

  // Un getter para saber si estamos cargando y mostrar el spinner
  get isLoading() {
    return !this.solicitud.data && !this.solicitud.error;
  }
}