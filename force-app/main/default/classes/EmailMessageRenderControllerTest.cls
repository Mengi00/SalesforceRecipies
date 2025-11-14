@isTest
public class EmailMessageRenderControllerTest {

    @isTest
    static void testWithValidEmailMessageId() {


        // Arrange: Crea un Email_Message__c de prueba
        Email_Message__c testEmail = new Email_Message__c(HtmlBody__c = '<p>Hola <img src="https://example.com/image.jpg"></p>');
        testEmail.CreatedDate__c = System.now();
        testEmail.Subject__c = 'Test';
        insert testEmail;

        // Simula el parámetro "id" en la página
        Test.setCurrentPageReference(new PageReference('/apex/dummy'));
        ApexPages.currentPage().getParameters().put('id', testEmail.Id);

        // Act
        EmailMessageRenderController controller = new EmailMessageRenderController();

        // Assert
        System.assertNotEquals(null, controller.html, 'El campo html no debe ser null');
        System.assert(controller.html.contains('data-original-src'), 'El HTML debería contener el atributo data-original-src');
    }

    @isTest
    static void testWithInvalidOrNoId() {
        // Simula un ID inválido (por ejemplo, de otro objeto)
        Test.setCurrentPageReference(new PageReference('/apex/dummy'));
        ApexPages.currentPage().getParameters().put('id', UserInfo.getUserId());

        EmailMessageRenderController controller = new EmailMessageRenderController();

        System.assert(controller.html.contains('Contenido no disponible'), 'Debe mostrar mensaje de error para ID inválido');
    }

    @isTest
    static void testWithBlankHtml() {
        // Email sin HTML
        Email_Message__c testEmail = new Email_Message__c(HtmlBody__c = '');
        insert testEmail;

        Test.setCurrentPageReference(new PageReference('/apex/dummy'));
        ApexPages.currentPage().getParameters().put('id', testEmail.Id);

        EmailMessageRenderController controller = new EmailMessageRenderController();

        System.assertEquals('', controller.html, 'Si el HTML está en blanco, debe retornar cadena vacía');
    }
}