<?php
	global $adb;
	
	//同步CRM的客户和联系人信息到帮我吧
	if(!empty($_REQUEST['operate']) && $_REQUEST['operate'] == 'import'){
		crm_load_class_file('cls_Bangwoba', 'modules/Users');
		$cls_Bangwoba = new cls_Bangwoba();
		$cls_Bangwoba->SyncAccountsAndContacts();
		$_REQUEST['diony']='yes';
		ConvertTojsonString(1,array(),"success");
		
	}

?>