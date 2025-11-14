@isTest

private class FCL_AddUsersToChatterGroupTest {
@TestSetup
static voId CreateCollaborationGroup()  {    
    List<CollaborationGroup> listCg = new List<CollaborationGroup>();
    listCg.add(new CollaborationGroup(Name='FCL_Group_Test', CollaborationType='Public'));
    insert listCg;
}
    @isTest static voId TestAddUserToGroup() {
        String listCgId = [SELECT Id FROM CollaborationGroup WHERE Name = 'FCL_Group_Test'].id;
        String TestUserId = [select Id from User WHERE IsActive != false limit 1].id;
        
        System.debug(listCgId);
        System.debug(TestUserId);


        FCL_AddUsersToChatterGroup.Request req = new FCL_AddUsersToChatterGroup.Request();
        req.groupId = listCgId;
        req.userIds = new List<String>{TestUserId};
        List<FCL_AddUsersToChatterGroup.Request> Requests  = new List<FCL_AddUsersToChatterGroup.Request>{req};

     Test.startTest();
        if (listCgId != null && TestUserId != null) {
                List<FCL_AddUsersToChatterGroup.Result> resultados = FCL_AddUsersToChatterGroup.addMembers(requests);   
        }
        Test.stopTest();

        // devuelve el member list
        List<CollaborationGroupMember> MemberList = [select Id from CollaborationGroupMember where MemberId = :TestUserId AND CollaborationGroupId = :listCgId];
        System.debug(MemberList);
        System.Assert(MemberList.isEmpty(), 'No se agrego el usuario como miembro de la group');



    }

     //Prueba de elimiacion
     @isTest static void TestRemoveUSerFromGroup() {
        String listCgId = [SELECT Id FROM CollaborationGroup WHERE Name = 'FCL_Group_Test'].id;
        string TestUserId = [select MemberId from CollaborationGroupMember WHERE CollaborationGroupid  = :listCgId limit 1].MemberId;
        

        FCL_RemoveUsersFromChatterGroup.Request removereq = new FCL_RemoveUsersFromChatterGroup.Request();
        removereq.groupId = listCgId;
        removereq.userIds = new List<String>{TestUserId};

         List<FCL_RemoveUsersFromChatterGroup.Request> removeRequests  = new List<FCL_RemoveUsersFromChatterGroup.Request>{removereq};

        Test.startTest();
        if (listCgId != null && TestUserId != null) {
                List<FCL_RemoveUsersFromChatterGroup.Result> removeresultados = FCL_RemoveUsersFromChatterGroup.removeMembers(removerequests);   
        }
        Test.stopTest();

        List<CollaborationGroupMember> MemberList = [select Id from CollaborationGroupMember where MemberId = :TestUserId AND CollaborationGroupId = :listCgId];

        //Verifica que no devuelve null
        System.assert(!MemberList.isEmpty(), 'No se agrego el usuario como miembro de la group');

     }

}