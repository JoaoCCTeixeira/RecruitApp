trigger NumberVacancyAvailableUpdate on Candidacy__c(after update) {
    Set<Id> vacancyIdsToUpdate = new Set<Id>();

    for (Candidacy__c candidacy : Trigger.new) {
        Candidacy__c oldCandidacy = Trigger.oldMap.get(candidacy.Id);

        if (
            candidacy.Candidacy_State__c == 'Contratado' &&
            oldCandidacy.Candidacy_State__c != 'Contratado'
        ) {
            if (candidacy.Vacancy__c != null) {
                vacancyIdsToUpdate.add(candidacy.Vacancy__c);
            }
        }
    }

    if (vacancyIdsToUpdate.isEmpty()) {
        return;
    }

    List<Vacancy__c> vacanciesToUpdate = [
        SELECT Id, Number_Vacancy_Available__c
        FROM Vacancy__c
        WHERE Id IN :vacancyIdsToUpdate
    ];

    for (Vacancy__c vacancy : vacanciesToUpdate) {
        if (vacancy.Number_Vacancy_Available__c != null) {
            vacancy.Number_Vacancy_Available__c -= 1;
        }
    }
    update vacanciesToUpdate;
}