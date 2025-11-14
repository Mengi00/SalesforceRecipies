import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import obtenerDatosGrafico from '@salesforce/apex/fCL_CasesChartView.obtenerDatosGrafico';
import ChartJS from "@salesforce/resourceUrl/chartjs_v280";

export default class GraficoCasosPorTipoGestion extends LightningElement {
  chart;              // Referencia al gráfico Chart.js
    chartInitialized = false;

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
            // Librería cargada
            return obtenerDatosGrafico();
            
        })
        .then(result => {
            // Procesar los datos recibidos del Apex (resultado contiene 'datosGrafico' y 'totalCasos')
            const datos = result.datosGrafico;
            const labels = datos.map(item => item.tipoGestion);
            const values = datos.map(item => item.cantidad);
            // El total de casos está en result.totalCasos por si se quiere usar

            // Obtener el contexto del canvas y construir el gráfico
            const ctx = this.template.querySelector('canvas').getContext('2d');
            this.chart = new window.Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Casos',
                        data: values,
                        backgroundColor:[
                                "rgba(82, 183, 216, 1)",
                                "rgba(225, 96, 50, 1)",
                                "rgba(255, 176, 59, 1)",
                                "rgba(84, 167, 123, 1)",
                                "rgba(79, 210, 210, 1)",
                                "rgba(226, 135, 178, 1)"
                               ],
                        borderColor: [
                                "rgba(82, 183, 216, 1)",
                                "rgba(225, 96, 50, 1)",
                                "rgba(255, 176, 59, 1)",
                                "rgba(84, 167, 123, 1)",
                                "rgba(79, 210, 210, 1)",
                                "rgba(226, 135, 178, 1)"
                               ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Número de casos'
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'Tipo de gestión'
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true
                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('Error al cargar Chart.js o los datos del Apex', error);
        });
    }
}