import { LightningElement, track } from 'lwc';
import getAllVacancies from '@salesforce/apex/VacancyController.getAllVacancies';

export default class VacancyList extends LightningElement {
    @track vacancies;
    @track error;

    connectedCallback() {
        this.loadVacancies();
    }

    loadVacancies() {
        getAllVacancies()
            .then(result => {
                this.vacancies = result.map(vacancy => ({
                    ...vacancy,
                    descriptionText: this.stripHtml(vacancy.Description__c),
                    localizationText: this.stripHtml(vacancy.Localization__c),
                    responsibilitiesText: this.stripHtml(vacancy.Responsibilities__c),
                    extraKnowledgeText: this.stripHtml(vacancy.Extra_Knowledge__c),
                    remoteText: this.stripHtml(vacancy.Remote__c),
                    numberVacancyAvailableText: this.stripHtml(vacancy.Number_Vacancy_Available__c),
                    workingHoursText: this.stripHtml(vacancy.Working_Hours__c),
                    salaryText: this.stripHtml(vacancy.Salary__c),
                    
                }));
            })
            .catch(error => {
                this.error = error;
            });
    }

    stripHtml(html) {
        let tempDiv = document.createElement('div');
        tempDiv.innerHTML = html;
        return tempDiv.textContent || tempDiv.innerText || '';
    }

    handleApply(event) {
        const vacancyId = event.target.dataset.id;
        console.log(`Applying for vacancy: ${vacancyId}`);
        // Add your application logic here
    }
}
