import { LightningElement, wire, track } from 'lwc';
import getCasesForUserGroups from '@salesforce/apex/CasosListController.getCasesForUserGroups';
import USER_ID from '@salesforce/user/Id';

const COLUMNS = [
    {
        label: 'Número de Caso',
        fieldName: 'caseUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_self' }
    },
    { label: 'Asunto', fieldName: 'Subject' },
    { label: 'Estado', fieldName: 'cc_ap_Estados__c' },
    { label: 'Nombre Paciente', fieldName: 'Nombre_Completo_Chile__c' },
    { label: 'Tipo de Gestion', fieldName: 'cc_ap_Tipo_de_Gestion__c' },
    { label: 'Alta Complejidad?', fieldName: 'cc_ap_AC__c' },
    { label: 'Fecha de Inicio', fieldName: 'CreatedDate' }
];

export default class CasosList extends LightningElement {
    @track cases;
    @track error;
    columns = COLUMNS;

    @wire(getCasesForUserGroups, { userId: USER_ID })
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data.map(caseRecord => ({
                ...caseRecord,
                caseUrl: `/sdap/s/detail/${caseRecord.Id}`
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.cases = undefined;
        }
    }
}