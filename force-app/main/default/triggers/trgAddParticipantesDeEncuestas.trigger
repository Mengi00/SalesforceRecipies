trigger trgAddParticipantesDeEncuestas on Participante_de_Encuesta__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        // Collect all RUT__c values from the trigger records
        List<Integer> rutValues = new List<Integer>();
        for (Participante_de_Encuesta__c participante : Trigger.new) {
            if (participante.RUT__c != null) {
                rutValues.add( Integer.valueOf(participante.RUT__c));
            }
        }

        // Query all Contacts with matching RUT__c values
        Map<Decimal, Id> rutToContactIdMap = new Map<Decimal, Id>();
        for (Contact c : [SELECT RUT__c, Id FROM Contact WHERE RUT__c IN :rutValues]) {
            rutToContactIdMap.put(c.RUT__c, c.Id);
        }

        // Loop through the trigger records and assign ContactId__c or set Estado__c accordingly
        for (Participante_de_Encuesta__c participante : Trigger.new) {
            if (rutToContactIdMap.containsKey( Integer.valueOf(participante.RUT__c))) {
                participante.ContactId__c = rutToContactIdMap.get( Integer.valueOf(participante.RUT__c));
                participante.Estado__c = 'Encontrado';
            } else {
                participante.Estado__c = 'No Encontrado';
            }
        }
    }
}