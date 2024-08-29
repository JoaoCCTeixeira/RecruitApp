public without sharing class SendEmail {

    @InvocableMethod(label='Send Email')
    public static void sendEmail(EmailRequest[] requests){
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id, EmailTemplate> emailTemplateById = new Map<Id, EmailTemplate>();
            
        for (EmailRequest request : requests) {
            emailTemplateById.put(request.emailTemplateId, null);
        }

        for (EmailTemplate emailTemplate : [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE Id IN :emailTemplateById.keySet()]) {
            emailTemplateById.put(emailTemplate.Id, emailTemplate);
        }

        for (EmailRequest request : requests) {

            if (emailTemplateById.get(request.emailTemplateId) == null) {
                System.debug('EmailTemplate not found: ' + request.emailTemplateId);
                continue;
            }

            EmailTemplate currentTemplate = emailTemplateById.get(request.emailTemplateId);
            
            String finalBody = currentTemplate.HtmlValue;
            finalBody = finalBody.replace('{Dia_Hora}', request.activityDateTime);
            finalBody = finalBody.replace('{Nome}', request.name);

            if(String.isNotBlank(request.vaga)){
                finalBody = finalBody.replace('{Vaga}', request.vaga);
            }
        
            List<String> toAddresses = new List<String>{request.emailRecepient};

            Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
            emailTobeSent.setTreatTargetObjectAsRecipient(false);
            emailTobeSent.setToAddresses(toAddresses);
            emailTobeSent.setSubject(currentTemplate.Subject);
            emailTobeSent.setHTMLBody(finalBody);
            emailTobeSent.saveAsActivity = true;
            //System.debug('emailTobeSent:: ' + emailTobeSent);

            emailList.add(emailTobeSent);
        }

        Messaging.SendEmailResult[] r1 = Messaging.sendEmail(emailList);

        for (Messaging.SendEmailResult result : r1) {
            for (Messaging.SendEmailError err : result.getErrors()) {
                System.debug('sendCaseEmail | Error: ' + err.getStatusCode() + ' ' + err.getMessage());
            }
        }
    
    }

    public class EmailRequest {

        @InvocableVariable
        public String activityDateTime;

        @InvocableVariable
        public String name;

        @InvocableVariable
        public String vaga;

        @InvocableVariable(required = true)
        public String emailRecepient;

        @InvocableVariable(required = true)
        public String emailTemplateId;
    }
    
}