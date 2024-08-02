public class VagasPageController {
    public List<Vacancy__c> vacancies { get; set; }
    public Id vacancyId { get; set; }
    public Boolean error { get; set; }

    public VagasPageController() {
        try {
            vacancies = [SELECT Id, Name, Description__c, Localization__c, Responsibilities__c,
                          Extra_Knowledge__c, Remote__c, Number_Vacancy_Available__c,
                          Working_Hours__c, Salary__c FROM Vacancy__c];
            error = false;
        } catch (Exception e) {
            error = true;
            vacancies = new List<Vacancy__c>();
        }
    }

    public PageReference applyToVacancy() {
        return null;
    }
}
