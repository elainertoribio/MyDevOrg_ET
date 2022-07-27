/**********************************************************************
* Name:     SG_RelationshipHelper_Scheduleable
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:     JAN 2021
* ======================================================
* ======================================================
* Purpose: 	Creates/Updates contact on relationship
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       JAN 2021        GO          Initial Development
*
***********************************************************************/
global with sharing class SG_RelationshipHelper_Scheduleable implements Schedulable
{
    global void execute(SchedulableContext schedulableContext)
    {
        SG_RelationshipHelper_Batch batch = new SG_RelationshipHelper_Batch();
        Database.executeBatch(batch, 200);
    }

}