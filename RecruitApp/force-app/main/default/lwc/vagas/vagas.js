import { LightningElement, track } from 'lwc';
import getAllVacancies from '@salesforce/apex/VagasPageController.getAllVacancies';

export default class Vagas extends LightningElement {
    @track vacancies;
    @track vacancyId;
    @track error;

    connectedCallback() {
        this.loadVacancies();
    }

    loadVacancies() {
        getAllVacancies()
            .then(result => {

                console.log(result);

                this.error = undefined;
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

                console.log(result);
                console.log(result.length);

                this.error = error;
                this.vacancies = undefined;
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
    }
}