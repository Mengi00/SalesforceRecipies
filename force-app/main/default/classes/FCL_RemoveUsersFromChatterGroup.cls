public without sharing class FCL_RemoveUsersFromChatterGroup {

    public class Request {
        @InvocableVariable( label ='Id de Grupo') public Id        groupId;
        @InvocableVariable( label ='Id de Usuario') public List<Id>  userIds;
    }


    public class Result {
        @InvocableVariable public Id      groupId;
        @InvocableVariable public Id      userId;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String  message;
    }

    @InvocableMethod(label='Eliminar usuarios de Chatter Group')
    public static List<Result> removeMembers(List<Request> requests) {

        
        Map<Id, Set<Id>> grp2Usr = new Map<Id, Set<Id>>();
        for (Request r : requests) {
            if (r == null || r.groupId == null || r.userIds == null) continue;
            if (!grp2Usr.containsKey(r.groupId))
                grp2Usr.put(r.groupId, new Set<Id>());
            grp2Usr.get(r.groupId).addAll(r.userIds);
        }

       
        Set<Id> allUsers = new Set<Id>();
        for (Set<Id> setIds : grp2Usr.values()) allUsers.addAll(setIds);

        List<CollaborationGroupMember> toDelete = [
            SELECT Id, CollaborationGroupId, MemberId
              FROM CollaborationGroupMember
             WHERE CollaborationGroupId IN :grp2Usr.keySet()
               AND MemberId            IN :allUsers
        ];

        
        Database.DeleteResult[] drs = Database.delete(toDelete, false);

       
        List<Result> out = new List<Result>();
        Integer i = 0;
        for (CollaborationGroupMember rec : toDelete) {
            Result r  = new Result();
            r.groupId = rec.CollaborationGroupId;
            r.userId  = rec.MemberId;
            r.success = drs[i].isSuccess();
            r.message = r.success ? 'Eliminado'
                                   : drs[i].getErrors()[0].getMessage();
            out.add(r);
            i++;
        }
        return out;
    }
}