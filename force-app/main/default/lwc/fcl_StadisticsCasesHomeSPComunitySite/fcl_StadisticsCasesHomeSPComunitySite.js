import { LightningElement, wire, track, api } from 'lwc';
import getCaseStatistics from '@salesforce/apex/fcl_CaseStatisticsController.getCaseStatistics';
import { refreshApex } from '@salesforce/apex';

export default class CaseStatistics extends LightningElement {
    @api myCases = 0;
    @api areaCases = 0;
    @api error;
    @track isLoading = true;
    
    wiredStatisticsResult;
    
    @wire(getCaseStatistics)
    wiredStatistics(result) {
        this.wiredStatisticsResult = result;
        this.isLoading = true;
        
        if (result.data) {
            this.myCases = result.data.myCases;
            this.areaCases = result.data.AreaCases;
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.myCases = 0;
            this.areaCases = 0;
            this.isLoading = false;
        }
    }
    
    refreshData() {
        refreshApex(this.wiredStatisticsResult);
    }
    
    connectedCallback() {
        // Set up refresh interval (every 5 minutes)
        this.intervalId = setInterval(() => {
            this.refreshData();
        }, 300000); // 5 minutes in milliseconds
    }
    
    disconnectedCallback() {
        // Clear the interval when component is removed
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }
}