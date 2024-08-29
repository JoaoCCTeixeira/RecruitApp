trigger EventTrigger on Event (before insert) {

    Set<Id> whoIds = new Set<Id>();
    
    for (Event e : Trigger.new) {
        if (e.WhoId != null) {
            whoIds.add(e.WhoId);
        }
    }

    Map<Id, Lead> leadMap = new Map<Id, Lead>([
        SELECT Id FROM Lead WHERE Id IN :whoIds
    ]);

    for (Event e : Trigger.new) {
        if (e.WhoId != null) {
            if (leadMap.containsKey(e.WhoId)) {
                e.addError('O evento deve ser associado apenas a contatos, não a leads.');
            }
        }
    }
}