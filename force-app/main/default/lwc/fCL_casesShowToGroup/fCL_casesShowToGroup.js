import { LightningElement, wire, track } from 'lwc';
import getCasesForUserGroups from '@salesforce/apex/FCL_CasesListController.getCasesForUserGroups';
import getSubUnidadesPorUsuario from '@salesforce/apex/FCL_CasesListController.getSubUnidadesPorUsuario';
import USER_ID from '@salesforce/user/Id';
import SHEETJS from '@salesforce/resourceUrl/xlsxexport';
import { loadScript } from 'lightning/platformResourceLoader';

const COLUMNS = [
    {label: 'Número de Caso', fieldName: 'caseUrl', type: 'url', typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_self' }, sortable: true },
    { label: 'Asunto', fieldName: 'Subject', sortable: true },
    { label: 'Estado', fieldName: 'Status', sortable: true },
    {label: 'Unidad', fieldName: 'cc_ap_Origen_de_requerimiento__c', sortable: true},
    { label: 'servicios', fieldName: 'groupNames', type: 'text', sortable: true },
    { label: 'Nombre Paciente', fieldName: 'Nombre_Completo_Chile__c', sortable: true},
    { label: 'Tipo de Requerimiento', fieldName: 'cc_ap_Tipo_de_Gestion__c', sortable: true },
    { label: 'Alta Complejidad?', fieldName: 'cc_ap_AC__c' ,type: 'boolean', sortable: true},
    { label: 'Dias Faltantes para Cerrar', fieldName: 'FCL_Dias_faltantes_Semaforo__c', type: 'text', sortable: true },
    { label: 'Fecha de Creación', fieldName: 'Fecha_de_Creacion_N__c', type:'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false }, sortable: true }, //Se agrega el atributo typeAttributes para mostrar la fecha en formato dd/mm/yyyy hh:mm
    { label: 'Fecha de Cierre', fieldName: 'ClosedDate', type:'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false }, sortable: true }, 
];


export default class CasosList extends LightningElement {
    @track cases = [];
    @track error;
    @track filteredCases = [];
    @track columns = COLUMNS;
    @track subUnidadOptions = [];
    @track altaComplejidadOptions = [
        { label: '', value: '', disabled: true },
        { label: 'Sí', value: 'true' },
        { label: 'No', value: 'false' }
    ];
    
    sortBy;
    sortDirection;

    selectedCaseNumber= '';
    selectedNombreTicket= '';
    selectedSubUnidad='';
    selectedNombrePaciente= '';
    selectedAltaComplejidad= '';
    selectedFechaInicioDesde= '';
    selectedFechaInicioHasta= '';
    sheetJsInitialized = false;

    connectedCallback() {
        if (!this.sheetJsInitialized) {
            loadScript(this, SHEETJS)
                .then(() => {
                    this.sheetJsInitialized = true;
                    console.log('SheetJS loaded');
                })
                .catch((error) => {
                    console.error('Error loading SheetJS', error);
                });
        }
    }

    //Se recupera la lista de casos asociados a los grupos del usuario
    @wire(getCasesForUserGroups, { userId: USER_ID })
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data.map(caseRecord => ({
                ...caseRecord,
                caseUrl: `/case/${caseRecord.Id}`,
                groupNames: caseRecord.Servicios_en_Caso__r ? caseRecord.Servicios_en_Caso__r.map(servicios => servicios.Nombre_de_Grupo__c).join(', ') : '', // Extrae los nombres de los grupos
            }));
            this.filteredCases = [...this.cases]; // Se inicia con los datos completos
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.cases = undefined;
        }
    }

        //Se recupera la lista de subunidades a las que esta asociado el usuario
        @wire(getSubUnidadesPorUsuario, { userId: USER_ID })
        wiredSubUnidades({ error, data }) {
            if (data) {
                console.log('Subunidades recibidas:', data);
                this.subUnidadOptions = [{label:'', value:'', disabled: true}, ...data.map(s => ({ label: s, value: s }))];
            } else if (error) {
                console.error('Error obteniendo subunidades:', error);
            }
        }
    
        //funcion para capturar los valores seleccionados en los filtros de busqueda
        handleFilterChange(event){
            const {name, value} = event.target;
            this[name] = value;

            this.applyFilters();
        }
    
        //Funcion para filtrar los casos con los valores seleccionados
        applyFilters(){
            this.filteredCases = this.cases.filter(item=>{
                return (
                    (!this.selectedCaseNumber || (item.CaseNumber && item.CaseNumber.includes(this.selectedCaseNumber))) &&
                    (!this.selectedNombreTicket || (item.Subject && item.Subject.toLowerCase().includes(this.selectedNombreTicket.toLowerCase()))) &&
                    (!this.selectedSubUnidad || (item.groupNames && item.groupNames.includes(this.selectedSubUnidad))) &&
                    (!this.selectedNombrePaciente || (item.Nombre_Completo_Chile__c && item.Nombre_Completo_Chile__c.toLowerCase().includes(this.selectedNombrePaciente.toLowerCase()))) &&
                    (!this.selectedAltaComplejidad || item.cc_ap_AC__c === (this.selectedAltaComplejidad === 'true')) &&
                    (!this.selectedFechaInicioDesde || new Date(item.Fecha_de_Creacion_N__c) >= new Date(this.selectedFechaInicioDesde)) &&
                    (!this.selectedFechaInicioHasta || new Date(item.Fecha_de_Creacion_N__c) <= new Date(this.selectedFechaInicioHasta))
                );
            });
        }
    

    //funcion para ordenar los datos al hacer clic en el encabezado de la columna
    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    //funcion que ordena los datos segun el tipo (texto, numero, fecha)
    sortData(fieldName, direction) {
        let sortedData = [...this.filteredCases];

        // Ordena los datos
        sortedData.sort((a, b) => {
            let valueA = a[fieldName] !== undefined && a[fieldName] !== null ? a[fieldName] : ''; 
            let valueB = b[fieldName] !== undefined && b[fieldName] !== null ? b[fieldName] : ''; 

            // detecta el tipo de dato de la columna (texto, número, fecha)
            let isDate = valueA instanceof Date && valueB instanceof Date;
            let isNumeric = typeof valueA === 'number' && typeof valueB === 'number';
            let isText = typeof valueA === 'string' && typeof valueB === 'string';

            //si el formato de fecha es de tipo string valida que estos representen una fecha
            if (!isDate && typeof valueA === 'string' && typeof valueB === 'string' && fieldName.toLowerCase().includes('date')) {
                valueA = new Date(valueA);
                valueB = new Date(valueB);
                isDate = true;
            }

            // si es numerico se convierte a número antes de ordenar
            if (isNumeric) {
                valueA = Number(valueA);
                valueB = Number(valueB);
            } else if (isDate) { // si es fecha se convierte a fecha (Date)
                valueA = new Date(valueA);
                valueB = new Date(valueB);
            } else if (isText){
                valueA = valueA.toLowerCase();
                valueB = valueB.toLowerCase();
            }
            // Ordena los datos
            return direction === 'asc' ? (valueA > valueB ? 1 : -1) : (valueA < valueB ? 1 : -1);
        });
        // Asigna los datos ordenados a la propiedad cases
        this.filteredCases = sortedData;
    }

    //Funcion que restablece todos los filtros y muestra la lista completa de casos
    clearFilters(){
        this.selectedCaseNumber= '';
        this.selectedNombreTicket =  '';
        this.selectedSubUnidad = '';
        this.selectedNombrePaciente = '';
        this.selectedAltaComplejidad = '';
        this.selectedFechaInicioDesde = '';
        this.selectedFechaInicioHasta = '';
        this.filteredCases = [...this.cases];
    }
    // Funcion de Exportacion
    handleExport() {
        // Crear un mapa de fieldName => label
        const fieldMap = {};
        this.columns.forEach(col => {
            fieldMap[col.fieldName] = col.label;
        });
    
        // Transformar los datos con los labels como claves
        const exportData = this.filteredCases.map(item => {
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