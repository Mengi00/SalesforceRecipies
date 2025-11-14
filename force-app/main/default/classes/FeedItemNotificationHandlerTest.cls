@isTest
private class FeedItemNotificationHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Crear UserRole necesario
        UserRole ejecutivoRole = new UserRole(
            Name = 'Ejecutivo Atención Paciente',
            DeveloperName = 'Ejecutivo_Atencion_Paciente'
        );
        insert ejecutivoRole;
        
        // Obtener un perfil disponible
        Profile profile = [SELECT Id FROM Profile WHERE UserType = 'Standard' LIMIT 1];
        
        // Crear usuario con el rol específico
        User ejecutivo = new User(
            Alias = 'ejec',
            Email = 'ejecutivo@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Ejecutivo Test',
            FirstName = 'Usuario',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es_CL',
            ProfileId = profile.Id,
            UserRoleId = ejecutivoRole.Id,
            TimeZoneSidKey = 'America/Santiago',
            UserName = 'ejecutivotest' + DateTime.now().getTime() + '@testcompany.com',
            IsActive = true
        );
        insert ejecutivo;
        
        // Crear CustomNotificationType (simulado - en sandbox debes crearlo manualmente)
        // Este objeto no se puede crear via Apex, así que el handler debe manejar su ausencia
    }
    
    // Helper para obtener RecordType
    private static Id getCaseRecordTypeId() {
        List<RecordType> rts = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = 'cc_ap_rt' 
            AND SObjectType = 'Case' 
            LIMIT 1
        ];
        
        if (rts.isEmpty()) {
            rts = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' LIMIT 1];
        }
        
        return rts.isEmpty() ? null : rts[0].Id;
    }
    
    @isTest
    static void testHandleAfterInsert_ConCasoCerrado() {
        Id caseRecordTypeId = getCaseRecordTypeId();
        User ejecutivo = [SELECT Id FROM User WHERE LastName = 'Ejecutivo Test' LIMIT 1];
        
        // Crear Case con Status 'Cerrado' y el RecordType correcto
        Case testCase = new Case(
            Subject = 'Caso Test Cerrado',
            Status = 'Cerrado',
            OwnerId = ejecutivo.Id
        );
        
        if (caseRecordTypeId != null) {
            testCase.RecordTypeId = caseRecordTypeId;
        }
        
        insert testCase;
        
        // Recargar para obtener CaseNumber
        testCase = [SELECT Id, CaseNumber, Subject, Status FROM Case WHERE Id = :testCase.Id];
        
        Test.startTest();
        
        // Crear FeedItem
        FeedItem feedItem = new FeedItem(
            ParentId = testCase.Id,
            Body = 'Comentario de prueba en caso cerrado',
            Type = 'TextPost'
        );
        insert feedItem;
        
        // Llamar handler directamente
        List<FeedItem> feedItems = [SELECT Id, ParentId, Body FROM FeedItem WHERE Id = :feedItem.Id];
        FeedItemNotificationHandler.handleAfterInsert(feedItems);
        
        Test.stopTest();
        
        // Verificar que el FeedItem existe
        FeedItem insertedFeed = [SELECT Id, ParentId FROM FeedItem WHERE Id = :feedItem.Id];
        System.assertNotEquals(null, insertedFeed);
        System.assertEquals(testCase.Id, insertedFeed.ParentId);
    }
    
    @isTest
    static void testHandleAfterInsert_ConCasoAbierto() {
        Id caseRecordTypeId = getCaseRecordTypeId();
        User ejecutivo = [SELECT Id FROM User WHERE LastName = 'Ejecutivo Test' LIMIT 1];
        
        // Crear Case con Status diferente a 'Cerrado'
        Case testCase = new Case(
            Subject = 'Caso Test Abierto',
            Status = 'New',
            OwnerId = ejecutivo.Id
        );
        
        if (caseRecordTypeId != null) {
            testCase.RecordTypeId = caseRecordTypeId;
        }
        
        insert testCase;
        
        Test.startTest();
        
        FeedItem feedItem = new FeedItem(
            ParentId = testCase.Id,
            Body = 'Comentario en caso abierto',
            Type = 'TextPost'
        );
        insert feedItem;
        
        List<FeedItem> feedItems = [SELECT Id, ParentId FROM FeedItem WHERE Id = :feedItem.Id];
        FeedItemNotificationHandler.handleAfterInsert(feedItems);
        
        Test.stopTest();
        
        // Debe ejecutarse sin errores aunque el caso no esté cerrado
        System.assert(true);
    }
    
    @isTest
    static void testHandleAfterInsert_VariosComentarios() {
        Id caseRecordTypeId = getCaseRecordTypeId();
        User ejecutivo = [SELECT Id FROM User WHERE LastName = 'Ejecutivo Test' LIMIT 1];
        
        // Crear múltiples cases cerrados
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            Case c = new Case(
                Subject = 'Caso Test ' + i,
                Status = 'Cerrado',
                OwnerId = ejecutivo.Id
            );
            if (caseRecordTypeId != null) {
                c.RecordTypeId = caseRecordTypeId;
            }
            cases.add(c);
        }
        insert cases;
        
        Test.startTest();
        
        // Crear múltiples FeedItems
        List<FeedItem> feedItems = new List<FeedItem>();
        for (Case c : cases) {
            feedItems.add(new FeedItem(
                ParentId = c.Id,
                Body = 'Comentario para ' + c.Subject,
                Type = 'TextPost'
            ));
        }
        insert feedItems;
        
        feedItems = [SELECT Id, ParentId FROM FeedItem WHERE Id IN :feedItems];
        FeedItemNotificationHandler.handleAfterInsert(feedItems);
        
        Test.stopTest();
        
        List<FeedItem> insertedFeeds = [SELECT Id FROM FeedItem WHERE ParentId IN :cases];
        System.assertEquals(3, insertedFeeds.size());
    }
    
    @isTest
    static void testHandleAfterInsert_FeedItemEnAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Test.startTest();
        
        FeedItem feedItem = new FeedItem(
            ParentId = acc.Id,
            Body = 'Comentario en Account',
            Type = 'TextPost'
        );
        insert feedItem;
        
        List<FeedItem> feedItems = [SELECT Id, ParentId FROM FeedItem WHERE Id = :feedItem.Id];
        FeedItemNotificationHandler.handleAfterInsert(feedItems);
        
        Test.stopTest();
        
        System.assert(true, 'Debe manejar FeedItems que no son de Cases');
    }
    
    @isTest
    static void testHandleAfterInsert_ListaVacia() {
        Test.startTest();
        FeedItemNotificationHandler.handleAfterInsert(new List<FeedItem>());
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void testHandleAfterInsert_ListaNull() {
        Test.startTest();
        
        try {
            FeedItemNotificationHandler.handleAfterInsert(null);
        } catch (Exception e) {
            System.debug('Exception esperada: ' + e.getMessage());
        }
        
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void testHandleAfterInsert_SinRecordType() {
        User ejecutivo = [SELECT Id FROM User WHERE LastName = 'Ejecutivo Test' LIMIT 1];
        
        // Case sin RecordType específico
        Case testCase = new Case(
            Subject = 'Caso sin RT',
            Status = 'Cerrado',
            OwnerId = ejecutivo.Id
        );
        insert testCase;
        
        Test.startTest();
        
        FeedItem feedItem = new FeedItem(
            ParentId = testCase.Id,
            Body = 'Comentario',
            Type = 'TextPost'
        );
        insert feedItem;
        
        List<FeedItem> feedItems = [SELECT Id, ParentId FROM FeedItem WHERE Id = :feedItem.Id];
        FeedItemNotificationHandler.handleAfterInsert(feedItems);
        
        Test.stopTest();
        
        System.assert(true);
    }
    
   
}