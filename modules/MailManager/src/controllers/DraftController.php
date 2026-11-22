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
include_once 'modules/MailManager/src/controllers/Controller.php';
include_once 'modules/MailManager/src/models/Draft.php';

/**
 * Class that handles Internal lingdang Drafts
 */
class MailManager_DraftController extends MailManager_Controller {

    /**
     * Function to process request, currently not used
     * @param MailManager_Request $request
     */
	function process(MailManager_Request $request) {
	}

    /**
     * Returns a List of search strings on the internal lingdang Drafts
     * @return Array of lingdang Email Fields
     */
	static function getSearchOptions(){
		$options = array('subject'=>'SUBJECT', 'saved_toid'=>'LBL_TO','description'=>'BODY','bccmail'=>'BCC','ccmail'=>'CC');
		return $options;
	}

    /**
     * Function which returns the Draft Model
     * @return MailManager_Model_DraftEmail
     */
	function connectorWithModel() {
		if ($this->mMailboxModel === false) {
			$this->mMailboxModel = MailManager_Model_DraftEmail::getInstance();
		}
		return $this->mMailboxModel;
	}
}
?>