import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SOLICITUDE_DE_MEJORA_OBJECT from "@salesforce/schema/Solicitud_de_Mejora__c";
import createSolicitud from "@salesforce/apex/FCL_SolicitudesDeMejoraList.createSolicitud";

export default class FCL_CreateSolicitudDeMejoraModal extends LightningElement {
  @track isModalOpen = false;
  isSaving = false;

  handleOpenModal() {
    this.isModalOpen = true;
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }

  // Este método contiene toda la lógica de guardado
  handleSubmit(event) {
    // Detenemos el comportamiento de guardado estándar del formulario
    event.preventDefault();

    // Deshabilitamos el botón para evitar dobles clics
    this.isSaving = true;

    // Recolectamos los datos que el usuario llenó en el formulario
    const fields = event.detail.fields;

    // Llamamos a nuestro método de Apex 'createSolicitud' con los datos del formulario
    createSolicitud({
      titulo: fields.Titulo__c,
      categoria: fields.Categoria_de_Mejora__c,
      descripcion: fields.Descripci_n__c,
      propuesta: fields.Propuesta_de_Mejora__c,
      unidadResponsablePropuesta: fields.Unidad_Responsable__c
    })
      .then((result) => {
        // Si Apex responde con éxito (then)
        // Mostramos el mensaje de éxito
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Éxito",
            message:
              "La solicitud de mejora ha sido creada correctamente. Recibirás una notificación por correo.",
            variant: "success"
          })
        );
        // Cerramos el modal
        this.handleCloseModal();
        // Disparamos un evento para que otras partes del portal se refresquen
        this.dispatchEvent(new CustomEvent("refreshdata"));
      })
      .catch((error) => {
        // Si Apex responde con un error (catch)
        // Mostramos un mensaje de error detallado
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error al crear la solicitud",
            message: error.body.message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        // Se ejecuta siempre (éxito o error) para volver a habilitar el botón
        this.isSaving = false;
      });
  }
}