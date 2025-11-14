import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import FECHA_REQ_FIELD from '@salesforce/schema/Case.FCL_Fecha_de_Requerimiento_Paciente__c';
import CREATED_DATE_FIELD from '@salesforce/schema/Case.CreatedDate';

const FIELDS = [FECHA_REQ_FIELD, CREATED_DATE_FIELD];

export default class CaseWarningModal extends LightningElement {
    @api recordId;
    @track fechaCrea2;
    @track fechaCrea1;
    modalVisible = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            const fechaReq = getFieldValue(data, FECHA_REQ_FIELD);
            const fechaCre = getFieldValue(data, CREATED_DATE_FIELD);
            if (fechaReq && fechaCre) {
                const fechaCreDate = new Date(fechaCre);
                const fechaReqDate = new Date(fechaReq);
                const fechaDiff =  fechaCreDate - fechaReqDate ;
                const difFechaToNumber = Math.floor(fechaDiff / (1000 * 60 * 60 * 24));
                difFechaToNumber >  5;
                if (difFechaToNumber >  5) {
                    const now = new Date();
                    const cincoMin = 5 * 60 * 1000;
                    const recienCreado = (now - fechaCreDate) < cincoMin;
                    const storageKey = `caseModalShown_${this.recordId}`;
                    const yaMostrado = window.sessionStorage.getItem(storageKey);
                    this.fechaCrea1 = yaMostrado;
                    if (recienCreado && yaMostrado == null) {
                        this.modalVisible = true;
                        window.sessionStorage.setItem(storageKey, 'true');
                    }
                }
            }
        }
    }
    cerrarModal() {
        this.modalVisible = false;
    }
//cancion de este sprint -> https://ilovesong.ai/work/5320893-2a18cf92-5a5c-430a-8c06-79dd626ab475 
}