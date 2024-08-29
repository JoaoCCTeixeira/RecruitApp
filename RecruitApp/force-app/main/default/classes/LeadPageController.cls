public class LeadPageController {
    public List<Vacancy__c> vacancies { get; set; }
    public Boolean error { get; set; }

    public String firstName { get; set; }
    public String lastName { get; set; }
    public Date birthDate { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String website { get; set; }
    public blob curriculo { get; set; }
    public String curriculoFileName { get; set; }
    public String foundUs { get; set; }
    public String other { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String country { get; set; }
    public Integer experienceYears { get; set; }
    public String reasonsToHire { get; set; }
    public Boolean serviceTerms { get; set; }
    public Boolean notifications { get; set; }

    public String selectedVacancyId { get; set; }
    public String selectedVacancyName { get; set; }
    public String vacancyId { get; set; }
    public String vacancyName { get; set; }
    public Boolean submissionSuccess { get; set; }

    public LeadPageController() {
        serviceTerms = false;
        notifications = false;
        submissionSuccess = false;
        selectedVacancyId = '';
        selectedVacancyName = '';

        try {
            vacancies = [
                SELECT
                    Id,
                    Name,
                    Description__c,
                    Traffic_Light__c,
                    Localization__c,
                    Responsibilities__c,
                    Extra_Knowledge__c,
                    Remote__c,
                    Number_Vacancy_Available__c,
                    Working_Hours__c,
                    Salary__c
                FROM Vacancy__c
                WHERE Disponivel__c = TRUE
            ];
            error = false;
            System.debug(vacancies);
        } catch (Exception e) {
            error = true;
            vacancies = new List<Vacancy__c>();
            System.debug('The following exception has occured:' + e.getMessage());
            System.debug('The following Line:' + e.getLineNumber());
        }
    }

    public void applyToVacancy() {
        System.debug('vacancyId: ' + vacancyId);
        if (vacancyId != null) {
            try {
                Vacancy__c selectedVacancy = [
                    SELECT Id, Name
                    FROM Vacancy__c
                    WHERE Id = :vacancyId
                    LIMIT 1
                ];

                selectedVacancyId = selectedVacancy.id;
                selectedVacancyName = selectedVacancy.Name;
                System.debug(selectedVacancyId);
                System.debug(selectedVacancyName);
            } catch (QueryException e) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Não foi possível encontrar a vaga.'
                    )
                );
                System.debug('The following exception has occured:' + e.getMessage());
                System.debug('The following Line:' + e.getLineNumber());
            }
        } else {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'ID da vaga não fornecido.'
                )
            );
        }
    }

    public void submitVacancy() {
        if (String.isEmpty(email)) {
            return;
        }

        System.debug(serviceTerms);
        System.debug(selectedVacancyId);

        Lead existingLead = null;
        try {
            existingLead = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];
        } catch (QueryException e) {
            existingLead = null;
        }

        if (existingLead != null) {
            List<Candidacy__c> existingCandidacies = [
                SELECT Id
                FROM Candidacy__c
                WHERE
                    Vacancy__c = :selectedVacancyId
                    AND Lead__c = :existingLead.Id
                LIMIT 1
            ];

            if (!existingCandidacies.isEmpty()) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Você já se candidatou a esta vaga com este e-mail.'
                    )
                );
                return;
            }

            if (String.isNotBlank(selectedVacancyId)) {
                createNewCandidacy(existingLead.Id);
            }
        } else {
            Lead newLead = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Website = website,
                Reasons_to_Hire__c = reasonsToHire,
                Date_of_Birth__c = birthDate,
                Where_did_you_find_us__c = foundUs,
                Other__c = other,
                Street = street,
                City = city,
                State = state,
                PostalCode = postalCode,
                Country = country,
                Years_of_Experience__c = experienceYears,
                Service_Terms__c = serviceTerms,
                Notifications__c = notifications
            );

            try {
                insert newLead;
                uploadCurriculo(newLead.Id);
                if (String.isNotBlank(selectedVacancyId)) {
                    createNewCandidacy(newLead.Id);
                }
            } catch (Exception e) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        e.getMessage()                  
                    )
                );
                System.debug('The following exception has occured:' + e.getMessage());
            System.debug('The following Line:' + e.getLineNumber());
            }
        }
    }

    private void uploadCurriculo(Id leadId) {
        if (curriculo != null) {

            ContentVersion cv = new ContentVersion();
            cv.Title = curriculoFileName;
            cv.PathOnClient = curriculoFileName;
            cv.VersionData = curriculo;
            cv.FirstPublishLocationId = leadId;

            try {
                insert cv;
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.INFO,
                        'Currículo enviado com sucesso.'
                    )
                );
            } catch (DMLException e) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Erro ao enviar o currículo: ' + e.getMessage()
                    )
                );
            }
        }
    }

    private void createNewCandidacy(Id leadId) {
        System.debug('leadId: ' + leadId);
        System.debug('selectedVacancyId: ' + selectedVacancyId);

        try {
            Candidacy__c newCandidacy = new Candidacy__c(
                Lead__c = leadId,
                Candidacy_State__c = 'Por Avaliar',
                Vacancy__c = selectedVacancyId
            );

            insert newCandidacy;

            submissionSuccess = true;
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' | ' + e.getLineNumber())
            );
        }
    }
}