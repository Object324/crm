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

$smarty = new lingdangCRM_Smarty;
require('user_privileges/user_privileges_'.$current_user->id.'.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$query = 'select profileid,profilename,description,profileseq from ld_profile order by profileseq';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
global $current_user;

$sql='SELECT * from ld_loginpolicy ORDER BY `priority`';

$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);
$tablehtml.='<script>LoginPolicy.movetable();tooltip(".sort-tip-items", {transition: true, time: 200});</script>';
$tablehtml.='<table name="table_loginpolicy" class="ControlTable1 listEntries fir-center listSettingData" width="100%" cellspacing="1" cellpadding="0" border="0"> <tr class="tbhead">';
$tablehtml.='<th>#</th>';
$tablehtml.='<th  style="width:17%;">'.getFixedLabel("RULENAME").'</th>';
$tablehtml.='<th style="width:10%;text-align:center;">'.getFixedLabel("Priority").'</th>';
$tablehtml.='<th>'.getFixedLabel("RULETYPE").'</th>';
$tablehtml.='<th>'.getFixedLabel("CONTROLMODE").'</th>';
$tablehtml.='<th style="width:25%">'.getFixedLabel("APPLICABLESCOPE").'</th>';
$tablehtml.='<th style="width:8%">'.getFixedLabel("STATUS").'</th>';
$tablehtml.='<th style="width:165px">'.getFixedLabel("OPERATING").'</th>';
$tablehtml.='</tr>';

$application_arr = array('create'=>getFixedLabel('NEW'),'edit'=>getFixedLabel('EDIT'),'delete'=>getFixedLabel('DELETE'),
'submit'=>getFixedLabel('SUBMITAPPROVAL'),'cancel'=>getFixedLabel('APPROVE_ANTIAPPROVAL'),'finish'=>getFixedLabel('APPROVALSUCCEEDED'));

function getAllocateUser($approceid,$approveallocatetype)
{
    global $adb;
    if($approveallocatetype=='all')
    {

        $allocatename = getFixedLabel('ALLTHEUSERS');
        $allocatetypeInfo[]=array
        (
            'allocatetypeidLink'=>'-1',
            'allocatetypenameLink'=>$allocatename
        );
        return $allocatetypeInfo;
    }
    if($approveallocatetype=='group')//部门
    {
        $query1 = "SELECT allocateid,allocatename,ruleid FROM(

                    SELECT
                         ld_groups.groupid    as allocateid,
                         ld_groups.groupname AS allocatename,
                         q2.ruleid AS ruleid
                    FROM
                        ld_loginpolicy_user q1
                    INNER JOIN ld_loginpolicy q2 ON q2.`ruleid`=q1.ruleid
                    INNER JOIN ld_groups  ON ld_groups.groupid = q1.`userid`
                    WHERE q2.applicablescope='group'

                )AS alldata
                WHERE alldata.ruleid=? order by ruleid desc;";
    }
    else if($approveallocatetype=='user')
    {
        $query1 = "SELECT allocateid,allocatename,ruleid FROM (

                    SELECT
                         ld_users.id as allocateid,
                         ld_users.`last_name` AS allocatename ,
                         ld_loginpolicy_user.ruleid
                    FROM
                        ld_loginpolicy_user
                    INNER JOIN ld_loginpolicy ON ld_loginpolicy.`ruleid`=ld_loginpolicy_user.ruleid
                    INNER JOIN ld_users ON ld_users.`id` = ld_loginpolicy_user.`userid`
                    WHERE ld_loginpolicy.applicablescope='user'
                )AS alldata
                WHERE alldata.ruleid=? order by ruleid desc;";
    }
    else if($approveallocatetype=='role')
    {
        $query1 = "SELECT allocateid,allocatename,ruleid FROM (
                    SELECT
                         ld_profile.profileid as allocateid,
                         ld_profile.profilename AS allocatename ,
                         ld_loginpolicy_user.ruleid
                    FROM
                        ld_loginpolicy_user
                    INNER JOIN ld_loginpolicy ON ld_loginpolicy.`ruleid`=ld_loginpolicy_user.ruleid
                    INNER JOIN ld_profile ON ld_profile.profileid = ld_loginpolicy_user.`userid`
                    WHERE ld_loginpolicy.applicablescope='role'
                )AS alldata
                WHERE alldata.ruleid=? order by ruleid desc;";
    }
    $result1=$adb->pquery($query1,array($approceid));
    $num_rows1=$adb->num_rows($result1);
    if($num_rows1 > 0){
        $userLink = '';
        for($i=0;$i<$num_rows1;$i++){
            $allocateid = $adb->query_result($result1,$i,'allocateid');
            $allocatename = $adb->query_result($result1,$i,'allocatename');
            if($allocatename=='AllUser')//所有用户。
            {
                $allocatename = getFixedLabel('ALLTHEUSERS');
            }
            $allocatetypeidLink .= $allocateid.',';
            $allocatetypenameLink .= $allocatename.',';
        }
        $allocatetypeidLink = trim($allocatetypeidLink,',');
        $allocatetypenameLink = trim($allocatetypenameLink,',');
        $allocatetypeInfo[]=array
        (
            'allocatetypeidLink'=>$allocatetypeidLink,
            'allocatetypenameLink'=>$allocatetypenameLink
        );
    }

    return  $allocatetypeInfo;
}


for($i=0;$i<$rows;$i++)
{
    $ruleid=$adb->query_result($result,$i,'ruleid');
    if ($i%2 ==0) {
        $tablehtml.='<tr id="setting_'.$i.'" ruleid="'.$ruleid.'" class="ld-category-draggable lvtColData"  onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
    }
    else{
        $tablehtml.='<tr id="setting_'.$i.'" ruleid="'.$ruleid.'" class="ld-category-draggable lvtColDataBj"  onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
    }
    $priority=$adb->query_result($result,$i,'priority');
    $tablehtml.='<td>'.$priority.'</td>';
    $rulename=$adb->query_result($result,$i,'rulename');
    $tablehtml.='<td name="rulename">'.$rulename.'</td>';
    //优先级
    $tablehtml.='<td style="text-align:center;" value="'.$priority.'" name="priority">'.$priority.'</td>';
    //规则类型
    $ruletype=$adb->query_result($result,$i,'ruletype');
    if($ruletype == 'WEB') {$tmpruletype = getFixedLabel("WEB");}
    else if($ruletype == 'Mobile') {$tmpruletype = getFixedLabel("MobileTerminal");}
    else if($ruletype == 'Geographicalregion') {$tmpruletype = getFixedLabel("LOCATEMAP");}
    else if($ruletype == 'IPaddress') {$tmpruletype = getFixedLabel("IPADDRESS");}
    // else if($ruletype == 'MACaddress') {$tmpruletype = getFixedLabel("WEB").'MAC地址映射';}
    // else if($ruletype == 'DeviceID') {$tmpruletype = getFixedLabel("IPADDRESS");}
    else {$tmpruletype = getFixedLabel("UNLIMITED2");}
    $tablehtml.='<td title="'.$tmpruletype.'" >'.$tmpruletype.'</td>';
    //控制方式
    $controlmode=$adb->query_result($result,$i,'controlmode');
    if($controlmode == 'disable'){
        $tmpcontrolmode = getFixedLabel("NOTALLOWEDLOGIN");
    }
    else{
        $tmpcontrolmode = getFixedLabel("ALLOWEDLOGIN");
    }
    $tablehtml.='<td title="'.$tmpcontrolmode.'" >'.$tmpcontrolmode.'</td>';
    //适用范围
    $applicablescope=$adb->query_result($result,$i,'applicablescope');
    $applicablescopeInfo=getAllocateUser($ruleid,$applicablescope);
    if($applicablescope == 'group') {$tmpapplicablescope = '1';}
    else if($applicablescope == 'user') {$tmpapplicablescope = '2';}
    else if($applicablescope == 'role') {$tmpapplicablescope = '3';}
    else {$tmpapplicablescope = '0';}
    // dump($tmpapplicablescope);
    $tablehtml.='<td title="" >'.$applicablescopeInfo[0]['allocatetypenameLink'].'</td>';
    //是否启用
    $status=$adb->query_result($result,$i,'enablestatus');
    if($status=='yes')
    {
        $tablehtml.='<td><input type="checkbox" value="yes" onclick="LoginPolicy.changeListBtn(this,'.$ruleid.')" class="second_switch" checked>'.'</td>';
    }
    else if($status=='no') {
        $tablehtml .= '<td><input type="checkbox" value="no" onclick="LoginPolicy.changeListBtn(this,'.$ruleid.')" class="second_switch" >'.'</td>';
    }
    //  if($i==0)//第一行没有上移
        $tablehtml.= '<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit" onclick="LoginPolicy.edit('.$ruleid.')">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del" onclick="LoginPolicy.delete('.$ruleid.')">'.getFixedLabel("DELETE").'</a>';
        $tablehtml.= '<a class="Anu3_a" href="javascript:void(0);" name="btn_allocate" onclick="LoginPolicy.allocate('.$ruleid.')">'.getFixedLabel("ALLOCATE").'</a>';
        $tablehtml.= '<a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="'.getFixedLabel('DRAGTOSORT').'"  data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:2px"></a>';
        $tablehtml.= '</td>';
        //  else if($i==$rows-1)//最后一行没有下移
    //     $tablehtml.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit" onclick="LoginPolicy.edit('.$ruleid.')">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del" onclick="LoginPolicy.delete('.$ruleid.')">'.getFixedLabel("DELETE").'</a></td>';
    // //  else
    //     $tablehtml.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit" onclick="LoginPolicy.edit('.$ruleid.')">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del" onclick="LoginPolicy.delete('.$ruleid.')">'.getFixedLabel("DELETE").'</a></td>';

    $tablehtml.="</tr>";
}
$tablehtml.='</table>';
$smarty->assign('ALLOCATEID',$allocateid);
$smarty->assign("LIST_ENTRIES",$templateList);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("TABLEINFO", $tablehtml);
$smarty->assign("num_rows_show",$num_rows);

$profile = new Profile();

if(isset($_REQUEST['directmode']) && $_REQUEST['directmode']=='ajax')
{
    $arr['content']= $smarty->fetch('LoginPolicy.tpl');
    ConvertTojsonString(1,$arr,"success");
}
else
{
    $arr['content']= $smarty->fetch('LoginPolicy.tpl');
    ConvertTojsonString(1,$arr,"success");
}

if($_REQUEST['ajax'] == 'true')
{
	$smarty->display("LoginPolicy.tpl");
}
else
{
    $_REQUEST['diony']='yes';
    $arr['content']=$smarty->fetch("LoginPolicy.tpl");
    ConvertTojsonString(1,$arr,'success');
	
}
?>