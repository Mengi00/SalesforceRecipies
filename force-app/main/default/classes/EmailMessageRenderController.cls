public with sharing class EmailMessageRenderController {
    public String html { get; private set; }

    public EmailMessageRenderController() {
        Id recordId = ApexPages.currentPage().getParameters().get('id');

        if (recordId != null && recordId.getSObjectType() == Email_Message__c.SObjectType) {
            Email_Message__c email = [
                SELECT HtmlBody__c FROM Email_Message__c WHERE Id = :recordId
                LIMIT 1
            ];
            html = sanitizeHtml(email.HtmlBody__c);
        } else {
            html = '<p style="color:red;">Contenido no disponible o ID inválido.</p>';
        }
    }

    private String sanitizeHtml(String rawHtml) {
        if (String.isBlank(rawHtml)) return '';

        // Neutraliza las imágenes externas manteniendo su estructura
        rawHtml = rawHtml.replaceAll(
            '(?i)<img([^>]*?)\\s+src=["\']([^"\']+)["\']',
            '<img$1 src="" data-original-src="$2"'
        );

        return rawHtml;
    }
}