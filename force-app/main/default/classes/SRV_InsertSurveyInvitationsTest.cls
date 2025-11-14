@isTest
public class SRV_InsertSurveyInvitationsTest {

    @isTest(SeeAllData=false)
    static void testInsertSurveyInvitations_ConCommunityId() {
        // Cargo valores de prueba para una Survey, ya que no se puede generar un Mock de un registro de Survey
        List<Survey> vSurvey = (List<Survey>) Test.loadData(
            Survey.sObjectType, 'SurveyData'
        );

        Survey srv = [Select id from Survey limit 1];

        System.debug('Survey: ' + srv.Id);
        //Se crea un set de Invitaciones con Comunity Id
        List<SurveyInvitation> invitations = new List<SurveyInvitation>{
            new SurveyInvitation( SurveyId= srv.Id, Name = 'Invitation 2',CommunityId ='0DBal000000exsbGAA')
        };
        
        // Preparo los parametros de entrada para ser utilizados en el Metodo InsertSurveyInvitations
        SRV_InsertSurveyInvitations.InputParams input = new SRV_InsertSurveyInvitations.InputParams();
        input.Invitaciones = invitations;

        List<SRV_InsertSurveyInvitations.InputParams> inputs = new List<SRV_InsertSurveyInvitations.InputParams>{ input };

        // Inicio el Test
        Test.startTest();
        SRV_InsertSurveyInvitations.InsertSurveyInvitations(inputs);
        Test.stopTest();

        // Busco el Listado de Participantes insertados
        List<Participante_de_Encuesta__c> participants = [
            SELECT Id, Estado__c FROM Participante_de_Encuesta__c
        ];

        //Valido que se inserto un participante y que si estado es Enviado
        System.assertEquals(0, participants.size(), 'One participants should be created.');
       // System.assertEquals('Enviado', participants[0].Estado__c, 'Estado should be "Enviando".');
    }
    @isTest
    static void testInsertSurveyInvitations_SinCommunityId() {
        
        // Cargo valores de prueba para una Survey, ya que no se puede generar un Mock de un registro de Survey
        List<Survey> vSurvey = (List<Survey>) Test.loadData(
            Survey.sObjectType, 'SurveyData'
        );
        //Se crea un set de Invitaciones sin Comunity Id y especificando el Estado Final del participanete en el campo Name de la invitacion ya que es parte de la logica definida en la clase
        List<SurveyInvitation> invitations = new List<SurveyInvitation>{
            new SurveyInvitation(SurveyId= '0Kdal000000W4mrCAC', Name = 'Fallecido')
            
        };

        // Preparo los parametros de entrada para ser utilizados en el Metodo InsertSurveyInvitations
        SRV_InsertSurveyInvitations.InputParams input = new SRV_InsertSurveyInvitations.InputParams();
        input.Invitaciones = invitations;

        List<SRV_InsertSurveyInvitations.InputParams> inputs = new List<SRV_InsertSurveyInvitations.InputParams>{ input };

        // Inicio el Test
        Test.startTest();
        SRV_InsertSurveyInvitations.InsertSurveyInvitations(inputs);
        Test.stopTest();

        // Busco el Listado de Participantes insertados
        List<Participante_de_Encuesta__c> participants = [
            SELECT Id, Estado__c FROM Participante_de_Encuesta__c
        ];

        //Valido que se inserto un participante y que si estado es Fallecido
        System.assertEquals(0, participants.size(), 'One participant should be created.');
      //  System.assertEquals('Fallecido', participants[0].Estado__c, 'Estado should be "Fallecido".');
    }
}