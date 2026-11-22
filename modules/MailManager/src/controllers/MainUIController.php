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

/**
 * Class which controls the MailManager User Interface
 */
class MailManager_MainUIController extends MailManager_Controller {

    /**
     * Process the request for displaying UI
     * @global String $currentModule
     * @param MailManager_Request $request
     * @return MailManager_Response
     */
	function process(MailManager_Request $request) {
		global $currentModule;
		$response = new MailManager_Response(true);
		$viewer = $this->getViewer();
		if($request->getOperationArg() == "_quicklinks") {
			$content = $viewer->fetch($this->getModuleTpl('Mainui.QuickLinks.tpl'));
			$response->setResult( array('ui' => $content));
			return $response;
		} else {
			if ($this->hasMailboxModel()) {
				$connector = $this->getConnector();

				if ($connector->hasError()) {
					$viewer->assign('ERROR', $connector->lastError());
				} else {
					$folders = $connector->folders();
					$connector->updateFolders();
                    
					$viewer->assign('FOLDERS', $folders);
				}
				$this->closeConnector();
			}
			$viewer->assign('MODULE', $currentModule);
			$content = $viewer->fetch($this->getModuleTpl('Mainui.tpl'));
			$response->setResult( array('mailbox' => $this->hasMailboxModel(), 'ui' => $content));
			return $response;
		}
	}
}
?>