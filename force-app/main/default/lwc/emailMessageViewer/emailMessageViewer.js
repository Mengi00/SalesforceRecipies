import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import LOCALE from "@salesforce/i18n/locale";
import LANG from "@salesforce/i18n/lang";
import labelFrom from "@salesforce/label/c.From";
import labelTo from "@salesforce/label/c.to";


export default class EmailMessageViewer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api title = '';

    label = {
        labelFrom,
        labelTo,
    };

    @track record;
    @track isDialogOpen = false;
    error;
    renderMode = 'visualforce';


    staticFields = [
        'Email_Message__c.Subject__c',
        'Email_Message__c.FromName__c',
        'Email_Message__c.ToAddress__c',
        'Email_Message__c.TextBody__c',
        'Email_Message__c.HtmlBody__c',
        'Email_Message__c.FromAddress__c',
        'Email_Message__c.BccAddress__c',
        'Email_Message__c.CcAddress__c',
        'Email_Message__c.Status__c',
        'Email_Message__c.CreatedDate',
        'Email_Message__c.MessageDate__c',
        'Email_Message__c.ValidatedFromAddress__c',
        'Email_Message__c.LastOpenedDate__c'
    ];

    connectedCallback() {
        console.log('recordId:', this.recordId);
        console.log('staticFields:', this.staticFields);
        window.addEventListener('message', this.handleMessage);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage);
    }
 

    @wire(getRecord, { recordId: '$recordId', fields: '$staticFields' })
    wiredDataRecord({ error, data }){
        console.log('wire executed', { error, data });
        this.updateHtmlContent();
        if (data) {
            this.record = data;
            this.updateHtmlContent();
        } else if (error) {
            this.error = error;
            this.updateHtmlContent();
        }
        
    }
  
    updateHtmlContent() {
        const container = this.template.querySelector('.html-content');
        if (container) {
            container.innerHTML = 'Asignacion';
        }
        
        if (this.record) {
            const htmlField = this.record.fields.HtmlBody__c?.value;
            const textField = this.record.fields.TextBody__c?.value;
            const contentBody = htmlField || textField || 'No hay contenido para mostrar';
            if (container && contentBody) {
              console.log("Se envio contenido");

              container.innerHTML = contentBody;
            }
        }else{
            console.log("No hay contenido para mostrar");
            if(container){
                container.innerHTML = 'Ocurrió un error, hay contenido para mostrar';
            }
        }
    }

    handleMessage = (event) => {
        if (event.data?.type === 'correoHeight') {
            const iframe = this.template.querySelector('iframe');
            if (iframe) {
                iframe.style.height = event.data.height + 'px';
            }
        }
    };

    get taskDueDate(){
        return this.formatearFecha(this.record?.fields?.MessageDate__c?.value);//'9:12 AM | Apr 22';
    }

    formatearFecha(fec) {
        if (!fec) return '';

        console.log(fec);
        // Convertir la fecha de Salesforce (en formato ISO 8601) a un objeto Date de JavaScript
        const fecha = new Date(fec);
       
        console.log(
            `Fecha convertida a string: ${fecha.toString()}`
        );

        // Obtener la zona horaria local del usuario
        const options = {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true,
            month: 'short',
            day: '2-digit'
        };

        console.log( 'locale:', LOCALE);
        console.log( 'lang:', LANG);

        const formatter = new Intl.DateTimeFormat(LOCALE, options);

        // Usamos la zona horaria local del usuario
        const parts = formatter.formatToParts(fecha);

        const hora = parts.find(p => p.type === 'hour')?.value;
        const minuto = parts.find(p => p.type === 'minute')?.value;
        const ampm = parts.find(p => p.type === 'dayPeriod')?.value;
        const mes = parts.find(p => p.type === 'month')?.value;
        const dia = parts.find(p => p.type === 'day')?.value;
    
        return `${hora}:${minuto} ${this.upperAMPM(ampm)} | ${this.capitalizeFirst(mes)} ${dia}`;
    }

    upperAMPM(str) {
        if (!str) return '';
        return str.indexOf('.') !== -1? str : str.toUpperCase();
    }

    capitalizeFirst(str) {
        if (!str) return '';
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    }

    handleDialogOpen() {
        this.isDialogOpen = !this.isDialogOpen;
    }

    get visualforceUrl() {
        return `/apex/emailMessageRender?id=${this.recordId}`;
    }

    get isVisualforce() {
        return this.renderMode === 'visualforce';
    }

    get isLwc() {
        return this.renderMode === 'lwc';
    }

    get fromName() {
        return (this.record?.fields?.FromName__c?.value || '').split(';');
    }
    get fromAddress() {
        return (this.record?.fields?.FromAddress__c?.value || '').split(';');
    }

    get subject() {
        return this.record?.fields?.Subject__c?.value || '';
    }

    get toAddress() {
        return (this.record?.fields?.ToAddress__c?.value || '').split(';');
    }

    get ccAddress() {
        return (this.record?.fields?.CcAddress__c?.value || '').split(';');
    }

    get bccAddress() {
        return (this.record?.fields?.BccAddress__c?.value || '').split(';');
    }

    get fromInfo(){
        
        if(this.fromName.length>0 && this.fromAddress.length>0){
            return this.fromName.map((name, index) => {
                return {
                    name: name,
                    address: this.fromAddress[index] || '',
                    mailto: `mailto:${this.fromAddress[index] || ''}`,
                };
            });
        }else{
            
            return [];
        }

    }

    get fullToInfo(){
        return [...this.toAddress, ...this.ccAddress, ...this.bccAddress]
        .filter((address) => address !== '')
        .map(addr => ({
            address: addr,
            mailto: `mailto:${addr}`
        }));
    }
}