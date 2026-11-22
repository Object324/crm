<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/



function DelImage($id)
{		
	global $adb;
	$query= "select ld_seattachmentsrel.attachmentsid from ld_seattachmentsrel inner join ld_crmentity on ld_crmentity.crmid=ld_seattachmentsrel.attachmentsid where ld_crmentity.setype='Contacts Image' and ld_seattachmentsrel.crmid=?";
	$result = $adb->pquery($query, array($id));
	$attachmentsid = $adb->query_result($result,$i,"attachmentsid");
	
	$rel_delquery='delete from ld_seattachmentsrel where crmid=?  and attachmentsid=?';
	$adb->pquery($rel_delquery, array($id, $attachmentsid));
	
	$crm_delquery="delete from ld_crmentity where crmid=?";
	$adb->pquery($crm_delquery, array($attachmentsid));

	$base_query="update ld_contactdetails set imagename='' where contactid=?";
	$adb->pquery($base_query, array($id));
}

function DelAttachment($id)
{
	global $adb;
	$selresult = $adb->pquery("select name,path from LD where attachmentsid=?", array($id));
	unlink($adb->query_result($selresult,0,'path').$id."_".$adb->query_result($selresult,0,'name'));
	$query="delete from ld_seattachmentsrel where attachmentsid=?";
	$adb->pquery($query, array($id));
	$query="delete from LD where attachmentsid=?";
	$adb->pquery($query, array($id));

}
$id = $_REQUEST["recordid"];
if(isset($_REQUEST["attachmodule"]) && $_REQUEST["attachmodule"]=='Emails')
{
	DelAttachment($id);
}
else
{
	DelImage($id);
}
echo 'SUCCESS';
?>