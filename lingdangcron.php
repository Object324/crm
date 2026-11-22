<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/


/**
 * Start the cron services configured.
 */
include_once 'vtlib/lingdang/Cron.php';
require_once 'config.inc.php';
if(PHP_SAPI === "cli" || (isset($_SESSION["authenticated_user_id"]) &&	isset($_SESSION["app_unique_key"]) && $_SESSION["app_unique_key"] == $application_unique_key)){

$cronTasks = false;
if (isset($_REQUEST['service'])) {
	// Run specific service
	$cronTasks = array(lingdang_Cron::getInstance($_REQUEST['service']));
}
else {
	// Run all service
	$cronTasks = lingdang_Cron::listAllActiveInstances();
}

foreach ($cronTasks as $cronTask) {
	try {
		$cronTask->setBulkMode(true);

		// Not ready to run yet?
		if (!$cronTask->isRunnable()) {
			echo sprintf("[INFO]: %s - not ready to run as the time to run again is not completed\n", $cronTask->getName());
			continue;
}

		// Timeout could happen if intermediate cron-tasks fails
		// and affect the next task. Which need to be handled in this cycle.				
		if ($cronTask->hadTimedout()) {
			echo sprintf("[INFO]: %s - cron task had timedout as it is not completed last time it run- restarting\n", $cronTask->getName());
}

		// Mark the status - running		
		$cronTask->markRunning();
		
		checkFileAccess($cronTask->getHandlerFile());		
		require_once $cronTask->getHandlerFile();
		
		// Mark the status - finished
		$cronTask->markFinished();
		
	} catch (Exception $e) {
		echo sprintf("[ERROR]: %s - cron task execution throwed exception.\n", $cronTask->getName());
		echo $e->getMessage();
		echo "\n";
	}		
}
}

else{
    echo("Access denied!");
}

?>