<?php
/**
 * @author andy
 * @copyright 20140808
 */
if(!isset($_REQUEST['SystemNumCheck'])){ echo '';die;}
global $adb;
if(1 == $_REQUEST['SystemNumCheck']){
    $tabid=getTabid($_REQUEST['mode']);
    $sql='SELECT columnname  from ld_field where tabid=? and uitype=4 ';
    $result=$adb->pquery($sql,array($tabid));
    if($adb->num_rows($result) > 0){
        $module_nun=$adb->query_result($result,0,'columnname');
        echo '###SUCCESS###' . $module_nun;
        exit();
    }
}elseif(2 == $_REQUEST['SystemNumCheck']){
    $module = $_REQUEST['mode'];
    $fld = $_REQUEST['module_nun'];
    $fldvalue = $_REQUEST['module_nun_value'];
    $record = $_REQUEST['record'];
    $tabid = getTabid($module);
    $entityarray = getEntitynameInfo($tabid);
    if(!isset($entityarray['tablename'])){
        switch($_REQUEST['mode']){
            case 'Documents':
                $tabname="ld_notes";
                $moduleid='notesid';
                break;
            case 'Accounts':
                $tabname="ld_account";
                $moduleid='accountid';
                break;
            case 'HelpDesk':
                $tabname='ld_troubletickets';
                $moduleid='ticketid';
                break;
            //日程管理，联系记录，销售机会新增审批流程
            case 'ContactRecords':
                $tabname='ld_contactrecords';
                $moduleid='contactrecordID';
                break;
            case 'Calendar':
                $tabname='ld_activity';
                $moduleid='activityid';
                break; 
            case 'Potentials':
                $tabname='ld_potential';
                $moduleid='potentialid';
                break; 
            case 'Commission':
                $tabname='ld_Commission';
                $moduleid='Commission_id';
                break;      
            default:
                $tabname="ld_".$_REQUEST['mode'];
                $moduleid = $_REQUEST['mode'].'id';
        } 
    }else{
        $tabname = $entityarray['tablename'];
        $moduleid = $entityarray['entityidfield'];
    }
    if($record>0)
    {
        $query = 'select '.$fld.' from '.$tabname.' where '.$fld.' = ? and '.$moduleid.' not in ('.$record.')';
        $param = array($fldvalue);
    }
    else
    {
        $query = 'select '.$fld.' from '.$tabname.' where '.$fld.' = ?';
        $param = array($fldvalue);
    }
    //echo $query.'---'. $fldvalue;die;
    $result=$adb->pquery($query,$param);
    if($adb->num_rows($result) > 0)
    {
        echo '###ERROR###';
    }
    else
    {
        echo '###SUCCESS###';
    }
    exit();
}
die;
?>