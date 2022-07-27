trigger SG_AccountTrigger on Account (after update)
{
    SG_RelationshipHelper.syncPersonAccount2(Trigger.operationType, Trigger.newMap);
}