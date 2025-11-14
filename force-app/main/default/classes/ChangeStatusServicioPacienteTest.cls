@isTest
public with sharing class ChangeStatusServicioPacienteTest {
    @isTest
    static void testTrigger() {

        // Crear un caso con el RecordType especificado
        Case caso = new Case(RecordTypeId = '012al0000039qNRAAY' , Subject = 'Caso de prueba', Status = 'Elaboración de respuesta');
        insert caso;

        // Crear un FeedItem asociado al caso
        FeedItem feedItem = new FeedItem(ParentId = caso.Id, Type = 'TextPost', Body = 'Nuevo comentario');
        insert feedItem;
        FeedComment feedCom = new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Nuevo comentario');
        insert feedCom;

        // Verificar que el campo cc_ap_Estados__c se actualizó correctamente
        caso = [SELECT Status FROM Case WHERE Id = :caso.Id];
        System.assertEquals('Elaboración de respuesta', caso.Status);
    }
    }