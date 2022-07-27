trigger SG_ContentVersionTrigger on ContentVersion (before insert, after insert)
{
    SG_FilesHelper.processFile_UpdateTitle(Trigger.operationType, Trigger.new);
    SG_FilesHelper.processFile_UpdateApplication(Trigger.operationType, Trigger.new);

}