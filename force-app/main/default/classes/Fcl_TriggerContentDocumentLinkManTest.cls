@isTest
public class Fcl_TriggerContentDocumentLinkManTest {

    @isTest
    static void testTriggerUpdateVisibilityAndShareType() {
        // Asegurar que existe un RecordType para el caso
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Casos Clínica Servicio Paciente' LIMIT 1];

        // Crear caso de prueba
        Case testCase = new Case(
            RecordTypeId = rt.Id,
            Subject = 'Caso de prueba',
            Status = 'Nuevo',
            Origin = 'Web'
        );
        insert testCase;

        // Crear un ContentVersion (esto crea automáticamente un ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'Prueba PDF',
            PathOnClient = 'prueba.pdf',
            VersionData = Blob.valueOf('Contenido de prueba')
        );
        insert cv;

        // Obtener el ContentDocumentId generado
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id 
            LIMIT 1
        ];

        // Crear ContentDocumentLink con valores que deben ser modificados por el trigger
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'InternalUsers'
        );
        insert cdl;

        // Verificar los cambios hechos por el trigger
        ContentDocumentLink updated = [
            SELECT Id, ShareType, Visibility 
            FROM ContentDocumentLink 
            WHERE Id = :cdl.Id
        ];

        System.assertEquals('I', updated.ShareType, 'El ShareType debe haberse actualizado a "I"');
        System.assertEquals('AllUsers', updated.Visibility, 'El Visibility debe haberse actualizado a "AllUsers"');
    }
}