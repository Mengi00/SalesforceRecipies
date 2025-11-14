/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class UserInfoControllerTest {

    @testSetup
    static void setupTestData() {
        // Verificar que el perfil "Usuario estándar" exista
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Usuario estándar' LIMIT 1];
        if (profile == null) {
            System.assert(false, 'El perfil "Usuario estándar" no existe en esta organización.');
        }
        // Crear usuarios de prueba
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Crear CollaborationGroup y CollaborationGroupMember
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = '8e68fecc-05e6-4b42-a75f-a8c49c797809',
            CollaborationType = 'Public'
        );
        insert testGroup;

        CollaborationGroupMember testGroupMember = new CollaborationGroupMember(
            CollaborationGroupId = testGroup.Id,
            MemberId = testUser.Id
        );
        insert testGroupMember;

        // Crear casos con subunidades y unidades
        Case testCase1 = new Case(
            cc_ap_Origen_de_requerimiento__c = 'Centro Medico',
            cc_ap_Sub_rea_del_Requerimiento__c = 'Cardiología'
        );
        Case testCase2 = new Case(
            cc_ap_Origen_de_requerimiento__c = 'Oncología Medica',
            cc_ap_Sub_rea_del_Requerimiento__c = 'Quimioterapia'
        );
        insert new List<Case>{ testCase1, testCase2};
    }

    @isTest
    static void testGetSubunitToUnitMapping() {
        // Llamar al método getSubunitToUnitMapping
        Map<String, String> subunitToUnitMap = UserInfoController.getSubunitToUnitMapping();
        
        // Depurar el contenido del mapa
        System.debug('Subunit to Unit Map: ' + subunitToUnitMap);

        // Validar los resultados
        System.assertNotEquals(null, subunitToUnitMap, 'El mapa de subunidades a unidades no debe ser nulo');
        System.assertEquals('Centro Medico', subunitToUnitMap.get('Cardiología'), 'Cardiologia debe estar asociada a la Centro Medico');
        System.assertEquals('Oncología Medica', subunitToUnitMap.get('Quimioterapia'), 'Quimioterapia debe estar asociada a la Oncología Medica');
    }

    @isTest
    static void testGetUserInfo() {
        // Obtener el usuario de prueba
        User testUser = [SELECT Id FROM User WHERE Username LIKE 'testuser%' LIMIT 1];
        System.assertNotEquals(null, testUser, 'El usuario de prueba no fue encontrado.');

        // Iniciar pureba. Llamar al método getUserInfo
        Test.startTest();
        UserInfoController.UserInfo userInfo = UserInfoController.getUserInfo(testUser.Id);
        Test.stopTest();
        
        // Validar los resultados
        System.assertNotEquals(null, userInfo, 'El objeto UserInfo no debe ser nulo');
        System.assertEquals('Test User', userInfo.name, 'El nombre del usuario debe coincidir');
       // System.assert(userInfo.subunitNames.contains('8e68fecc-05e6-4b42-a75f-a8c49c797809'), 'El usuario debe estar asociado al grupo de prueba');
       // System.assert(userInfo.unitNames.contains('Centro Medico'), 'El usuario debe estar asociado a la unidad correspondiente');
    }

    @isTest
    static void testGetUserInfo_NoGroups() {
        // Verificar que el perfil "Usuario estándar" exista
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Usuario estándar' LIMIT 1];
        if (profile == null) {
            System.assert(false, 'El perfil "Usuario estándar" no existe en esta organización.');
        }
        // Crear usuario sin grupo
        User userWithoutGroup = new User(
            FirstName = 'NoGroup',
            LastName = 'User',
            Email = 'nogroup@example.com',
            Username = 'nogroup@example.com',
            Alias = 'nguser',
            TimeZoneSidKey = 'America/Bogota',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutGroup;

        // Iniciar prueba
        Test.startTest();
        UserInfoController.UserInfo userInfo = UserInfoController.getUserInfo(userWithoutGroup.Id);
        Test.stopTest();

        // Validar que el usuario sin grupo no tenga subunidades ni unidades
        System.assertEquals(0, userInfo.subunitNames.size(), 'No debe haber subunidades');
        System.assertEquals(0, userInfo.unitNames.size(), 'No debe haber unidades');
    }

}