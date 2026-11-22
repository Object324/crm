<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
  * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

include_once dirname(__FILE__) . '/RelationController.php';

/**
 * Class used to controll search operations
 */
class MailManager_SearchController extends MailManager_RelationController {

    /**
     * Processes the request for search Operation
     * @global <type> $current_user
     * @param MailManager_Request $request
     * @return boolean
     */
	function process(MailManager_Request $request) {
	
		$response = new MailManager_Response(true);
		$viewer = $this->getViewer();
		
		if ('popupui' == $request->getOperationArg()) {
			$viewer->display( $this->getModuleTpl('Search.Popupui.tpl') );
			$response = false;
			
		} else if ('email' == $request->getOperationArg()) {
			global $current_user;

			$searchTerm = $request->get('q');
			if (empty($searchTerm)) $searchTerm = '%@'; // To avoid empty value of email to be filtered.
			else $searchTerm = "%$searchTerm%";
			
			$filteredResult = MailManager::lookupMailInlingdang($searchTerm, $current_user);

			MailManager_Utils::emitJSON($filteredResult);
			$response = false;
		}
		return $response;
	}
}

?>