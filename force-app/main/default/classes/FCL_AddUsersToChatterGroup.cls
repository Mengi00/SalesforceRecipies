public without sharing class FCL_AddUsersToChatterGroup {

    public class Request {
        @InvocableVariable(label = 'Group Id')
        public Id groupId;

        @InvocableVariable(label = 'User Ids'  )
        public List<Id> userIds;
    }
  
    public class Result {
        @InvocableVariable public Id   userId;
        @InvocableVariable public Id   groupId;
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

   
    @InvocableMethod( label = 'Añadir usuarios a Chatter Group'  )
    public static List<Result> addMembers( List<Request> requests ) {

      
        Map<Id, Set<Id>> mapGrp2Usr = new Map<Id, Set<Id>>();
        for (Request r : requests) {
            if (r == null || r.groupId == null || r.userIds == null) continue;
            if (!mapGrp2Usr.containsKey(r.groupId))
                mapGrp2Usr.put(r.groupId, new Set<Id>());
            mapGrp2Usr.get(r.groupId).addAll(r.userIds);
        }

        
        List<Id> allGroups = new List<Id>(mapGrp2Usr.keySet());
        List<Id> allUsers  = new List<Id>();
        for (Set<Id> s : mapGrp2Usr.values()) allUsers.addAll(s);

        Map<String, Boolean> existing = new Map<String, Boolean>();
        for (CollaborationGroupMember m :
            [SELECT CollaborationGroupId, MemberId
               FROM CollaborationGroupMember
              WHERE CollaborationGroupId IN :allGroups
                AND MemberId            IN :allUsers]) {
            existing.put(m.CollaborationGroupId + ':' + m.MemberId, true);
        }

       
        List<CollaborationGroupMember> toInsert = new List<CollaborationGroupMember>();
        for (Id gId : mapGrp2Usr.keySet()) {
            for (Id uId : mapGrp2Usr.get(gId)) {
                if (!existing.containsKey(gId + ':' + uId)) {
                    toInsert.add(new CollaborationGroupMember(
                                     CollaborationGroupId = gId,
                                     MemberId             = uId));
                }
            }
        }

        
        List<Result> output = new List<Result>();
        if (!toInsert.isEmpty()) {
            Database.SaveResult[] srs = Database.insert(toInsert, /*allOrNone*/ false);
            Integer idx = 0;
            for (CollaborationGroupMember rec : toInsert) {
                Database.SaveResult sr = srs[idx++];
                Result res            = new Result();
                res.userId  = rec.MemberId;
                res.groupId = rec.CollaborationGroupId;
                res.success = sr.isSuccess();
                res.message = sr.isSuccess() ? 'OK'
                           : sr.getErrors()[0].getMessage();
                output.add(res);
            }
        }
        return output;
    }
}