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

    public void applyToVacancy() {
        if (vacancyId != null) {
            try {
                Vacancy__c selectedVacancy = [SELECT Id FROM Vacancy__c WHERE Id = :vacancyId LIMIT 1];
                System.debug(selectedVacancy.Id);

                LeadPageController controlador = new LeadPageController(selectedVacancy.id);
                
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Não foi possível encontrar a vaga.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ID da vaga não fornecido.'));
        }
    }
}