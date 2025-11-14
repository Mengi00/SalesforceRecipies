public class insertSurveyParticipantsCustom {
  public class InputParams {
    @invocableVariable(label='Lista Rut' required=true)
    public list<contact> RutList;

    @invocableVariable(label='Id Cargaa encuesta' required=true)
    public String CargaId;
  }

  @InvocableMethod(label='Insertar Participantes de encuesta')
  public static void insertSurveyParticipants(List<InputParams> inputs) {
    
    List<Participante_de_Encuesta__c> p = new List<Participante_de_Encuesta__c>();
    Participante_de_Encuesta__c q = new Participante_de_Encuesta__c();
    List<Participante_de_Encuesta__c> subList = new List<Participante_de_Encuesta__c>();

    for (InputParams input : inputs) {
      for (Contact contacto : input.Rutlist) {
        q = new Participante_de_Encuesta__c();
        System.debug(contacto.RUT__C);
        q.Rut__c = string.valueOf(contacto.RUT__c);
        q.Carga_de_Participante_de_Encuesta_Id__c = input.CargaId;
        q.Tipo_De_Paciente__c = contacto.FirstName;
        System.debug(q);
        p.add(q);
      }
      System.debug(p);
      integer batchCount = 100;
      integer totalBatches = p.size();
      integer BatchNumber = (totalBatches + batchCount - 1) / batchCount;
      integer ini;
      integer fin;

      for (integer i = 0; i < BatchNumber; i++) {
        ini = i * batchCount;
        fin = math.min(ini + batchCount, totalBatches);
        System.debug(ini);
        System.debug(fin);
        System.debug(i);
        for (Integer o = ini; o < fin; o++) {
          System.debug('valor de 0 :' + o);
          subList.add(p[o]);
        }
        System.debug(subList);
        insert subList;
        subList.clear();
      }
    }
  }

 
}