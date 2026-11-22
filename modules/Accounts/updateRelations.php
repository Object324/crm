<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/



global $singlepane_view, $currentModule;
$idlist = vtlib_purify($_REQUEST['idlist']);
$dest_mod = vtlib_purify($_REQUEST['destination_module']);
$parenttab = getParentTab();

$forCRMRecord = vtlib_purify($_REQUEST['parentid']);



if($singlepane_view == 'true')
	$action = "DetailView";
else
	$action = "CallRelatedList";

$storearray = array();
 if (!empty($_REQUEST['idlist'])) {
	// Split the string of ids
	$storearray = explode (";",trim($idlist,";"));
} else if(!empty($_REQUEST['entityid'])){
	$storearray = array($_REQUEST['entityid']);
}

$focus = CRMEntity::getInstance($currentModule);
if(!empty($storearray)) {
/**
* edit:chj
* date:2014-6-23
* reason:(教育行业) 学员更多信息 选择班级
*/
    if(getEduType('Edu') == true)
    {
        if($dest_mod == 'Project')
            $type = 1;
        else if($dest_mod == 'ServiceContracts')
            $type = 2;
        else if($dest_mod == 'ProjectMilestone')
            $type = 3;
        else
        {
            $type=4;
            relateEntities($focus, $currentModule, $forCRMRecord, $dest_mod, $storearray);
        }
        if($type!=4)
        for($i = 0; $i<count($storearray); $i++)
        {
            $sql = "insert into ld_lessionplanorg(accountid,otherid,type) values (?,?,?)";
            $adb->pquery($sql,array($forCRMRecord,$storearray[$i],$type));
        }
    }
   else
   {
 
        relateEntities($focus, $currentModule, $forCRMRecord, $dest_mod, $storearray);
   }
}

//header("Location: index.php?action=$action&module=$currentModule&record=".$forCRMRecord."&parenttab=".$parenttab);
//
?>