/***************************************************
* Name:         SG_GenericBatchApex
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         29 Oct 2020
* ==================================================
* ==================================================
* Purpose:      ...
* USAGE:        SG_MyBatch.runMe( 'SG_MyBatch' );
*
*               // schedule it to run 10 min from now
*               SG_MyBatch.scheduleMe( 'My Job', 'SG_MyBatch', SG_MyBatch.getCronSchedTime( DateTime.now().addMinutes( 10 ) ) );
*
*               // schedule it to run everyday at 2:30am
*               SG_MyBatch.scheduleMe( 'My Job', 'SG_MyBatch', SG_MyBatch.getCronSchedTime( Time.newInstance( 2, 30, 0, 0 ) ) );
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       29 Oct 2020     FMF     Initial Development
*
****************************************************/

global virtual class SG_GenericBatchApex
		implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

	public static String jobName = 'SGI - Generic Batch Apex - Daily Run';
	public static Integer BatchSize = 1200;

	// Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
	public static final String DEFAULT_SCHEDULE = '0 30 2 15 * ?'; // every 15th at 2:30 am

	//global Integer BatchSize = 1200;
	global String theQuery;
	global ID batchID;

	global SG_GenericBatchApex() {
		system.debug( 'super class constructor' );
		initialize();
	}

	global virtual void initialize() {
		system.debug( 'super class initialize' );

		//theQuery = 'SELECT ID, Name, ETC__c '
		//        + ' FROM SomeObject__c '
		//        + ' WHERE Date__c >= ' + priorYr
		//        + ' AND Date__c <= ' + currDt
		//        + ' ORDER BY ETC__c, Date__c ';

		System.debug( 'theQuery= ' + theQuery );
	}

	global Database.QueryLocator start( Database.BatchableContext bc ) {
		system.debug( 'super class start' );
		return Database.getQueryLocator( theQuery );
	}

	global void execute( Database.BatchableContext bc, List<SObject> scope ) {
		system.debug( 'super class execute' );
		processRecords( scope );
	}

	global virtual void processRecords( List<SObject> scope ) {
		System.debug( 'super class processRecords - scope= ' + scope );
	}

	global virtual void finish( Database.BatchableContext bc ) {
		// start the next batch apex here
		System.debug( 'super class finish' );

	}

	global virtual void execute( SchedulableContext sc ) {
		System.debug( 'super class execute' );
		batchID = runMe( getClassName() );
	}

	global virtual String getClassName() {
		System.debug( 'super class getClassName' );
		return null;
	}

	global static ID runMe( String thisClassName ) {
		// TODO:  find a way to extract the class name from caller and not have to receive it as parameter
		// (can't get class name if caller is descendant and this method is static)
		system.debug( 'running immediately ' + thisClassName );

		Type classType = Type.forName( thisClassName );
		Database.Batchable<sObject> newObj = (Database.Batchable<sObject>) classType.newInstance();

		return Database.executeBatch( newObj, BatchSize );
	}

	global static void removeSchedule( String aJobName ) {
		// remove existing schedule
		System.debug( 'super class removeSchedule= ' + aJobName );
		String jobNameMask = aJobName + '%';
		List<CronTrigger> cL = [
				SELECT ID
				FROM CronTrigger
				WHERE CronJobDetail.Name LIKE :jobNameMask
		];

		for( CronTrigger aCronTrigger : cL ) {
			system.abortJob( aCronTrigger.ID );
		}
	}

	global static void scheduleMe( String jobNameParam, String thisClassName, String schedTime ) {
		// TODO:  find a way to extract the class name from caller and not have to receive it as parameter
		// (can't get class name if caller is descendant and this method is static)
		removeSchedule( jobNameParam );

		system.debug( 'scheduling ' + thisClassName + ' as ' + jobNameParam + ' to run at ' + schedTime );

		// every day at the specified hour and minute
		if( schedTime == null ) {
			schedTime = DEFAULT_SCHEDULE;
		}

		Type classType = Type.forName( thisClassName );
		Schedulable newObj = (Schedulable) classType.newInstance();

		System.schedule( jobNameParam, schedTime, newObj );
	}

	global static String getCronSchedTime( DateTime theDateTime ) {
		return theDateTime.second()
				+ ' ' + theDateTime.minute()
				+ ' ' + theDateTime.hour()
				+ ' ' + theDateTime.day()
				+ ' ' + theDateTime.month()
				+ ' ?';
	}

	global static String getCronSchedTime( Time theTime ) {
		// everyday at the specified time
		return theTime.second()
				+ ' ' + theTime.minute()
				+ ' ' + theTime.hour()
				+ ' * * ?';
	}

}