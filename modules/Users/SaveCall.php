<?php

global $adb,$current_user,$currentModule;



if(isset($_REQUEST['callbutlername']) && $_REQUEST['callbutlername'] != '')
{
    $crmID = $_REQUEST['crmid'];
    $moduleName = $_REQUEST['modulename'];
    $callbutlername = $_REQUEST['callbutlername'];
    $callButlerRemarks = $_REQUEST['callButlerRemarks'];
    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
    
    $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
        
        if($moduleName=='Accounts')
        {
            $sqlUpdate = "update ld_callbutler set accountid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='Contacts')
        {
            $sqlUpdate = "update ld_callbutler set contactid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='ContactRecords')
        {
            $sqlUpdate = "update ld_callbutler set contactrecordsid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='HelpDesk')
        {
            $sqlUpdate = "update ld_callbutler set ticketid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='Vendors')
        {
            $sqlUpdate = "update ld_callbutler set vendorid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='VendorContact')
        {
            $sqlUpdate = "update ld_callbutler set vendorcontactid = ?,description = ? where id = ? ";    
        }
        elseif($moduleName=='VendorContactRecords')
        {
            $sqlUpdate = "update ld_callbutler set vendorcontactrecordsid = ?,description = ? where id = ? ";    
        }
        else
        {
            $sqlUpdate = "update ld_callbutler set accountid = ?,description = ? where id = ? ";    
        }
        $updateResult=$adb->pquery($sqlUpdate,array($crmID,$callButlerRemarks,$callButlerID));
        
        
    }
    else
    {
        //不存在
        $sqlInsert = "insert into ld_callbutler 
        (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
         accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
        values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ";
        $callbutlername = str_replace("\\\\","\\",$callbutlername);
        $insertresult=$adb->pquery($sqlInsert,array('','','接通',null,null,'',$callbutlername,$current_user->id,
        $crmID,0,0,0,0,0,0,$callButlerRemarks));
    }
    
}


?>