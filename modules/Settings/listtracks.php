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
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty = new lingdangCRM_Smarty;


global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$query =  'select ld_trackpostion.* ,ld_users.id as userid,ld_users.wx_userid,ld_users.last_name from ld_trackpostion 
left join ld_users on ld_users.trackgroupid=ld_trackpostion.trackpostion_id ORDER BY trackpostion_id desc  ';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
$list_entries ='';
/*th原是固定长度，改为百分比以适配不同分辨率的屏幕*/
$list_entries.="<table class='listEntries fir-center' border=0 cellspacing=1 cellpadding=0 width=100%>
			<th width='4%'>#</th>
			<th align='left' style='width:15%;' title='".getFixedLabel('TRACKGROUPNAME')."'>".getFixedLabel('TRACKGROUPNAME')."
			</th>
			<th align='left' width='7%' title='". getFixedLabel("STARTTIME")."'>". getFixedLabel("STARTTIME")."</th>
			<th align='left' width='7%' title='". getFixedLabel("EndTime")."'>". getFixedLabel("EndTime")."</th>
			 
			<th align='left'   title='". getFixedLabel("APPLICABLESCOPE")."'>". getFixedLabel("APPLICABLESCOPE")."</th>
			<th align='left' width='7%' title='".getFixedLabel('TRACKPERIOD')."'>".getFixedLabel('TRACKPERIOD')."
			</th>
			<th align='left'  width='5%' title='". getFixedLabel("LocationFrequency")."'>". getFixedLabel("LocationFrequency")."</th>";



    $list_entries.="<th width='180'>".getFIxedlabel('OPERATING')." 
               </th>";               

$userobj=new Users();
if($num_rows > 0) {
    $rowindex=0;
    $prevtrackpositionid=0;
	for($i = 0; $i<$num_rows; $i++) {
        $def_workday=array();//每次清空定位周期的值；
        $trackpostion_id = $adb->query_result($result,$i,'trackpostion_id');
        $trackpostionids[]=$trackpostion_id;
        $trackpostion = $adb->query_result($result,$i,'trackpostion');  
        $selected_userid= $adb->query_result($result,$i,'userid');
        $starttime = $adb->query_result($result,$i,'starttime');
        $stoptime = $adb->query_result($result,$i,'stoptime');
        $cycle=$adb->query_result($result,$i,'cycle');//定位周期
        $frequency=$adb->query_result($result,$i,'frequency');//定位频率

        $prevtrackpositionid= $trackpostion_id;
        $last_name_arr=[];
        $userid_arr = [];
        while($i<$num_rows) {
            $trackpostion_id = $adb->query_result($result,$i,'trackpostion_id');
            if($prevtrackpositionid!=$trackpostion_id) {
                break;
            }
            $selected_userid= $adb->query_result($result,$i,'userid');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            $last_name=$adb->query_result($result,$i,'last_name');
            $userobj=new Users();
            $userobj->id=$selected_userid;
            $userobj->last_name=$last_name;
            $userobj->wx_userid=$wx_userid;
            $userid_arr[] = $selected_userid;
            $last_name_arr[]=getUserlastName($userobj);

            $i++;
        }
        $i--;
        $all_userid = implode(',',$userid_arr);
        if ($$rowindex%2 ==0) {
            $list_entries.='<tr id="setting_'.$rowindex.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
        }
        else{
            $list_entries.='<tr id="setting_'.$rowindex.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
        }
        if($cycle == 'workday'){
            $cycle_label = getFixedLabel('WorkdDay');
        }
        else{
            $cycle_label = getFixedLabel('NOLIMITS');
        }
        if($frequency >= 60){
            $frequency_label = ($frequency/60).getFixedLabel('HOUR');
        }
        else{
            $frequency_label = $frequency.getFixedLabel('MINUTE');
        }
        $list_entries.="<td>".++$rowindex."</td>";
        $list_entries.="<td title=".$trackpostion.">".$trackpostion."</td>";
        $list_entries.="<td title=".$starttime.">".$starttime."</td>";
        $list_entries.="<td title=".$stoptime.">".$stoptime."</td>";
        $list_entries.="<td>".implode("、",$last_name_arr)."</td>";
        $list_entries.="<td>".$cycle_label."</td>";
        $list_entries.="<td>".$frequency_label."</td>";
        $list_entries.="<td><a class='Anu3_a' href='javascript:void(0);' onclick='CreateTracks($prevtrackpositionid,\"edit\")' >".getFixedLabel('EDIT')."</a>";//编辑
        $list_entries.="<a class='Anu3_a' href='javascript:void(0);' onclick='AllocateTrackGroup(this,$prevtrackpositionid,\"$all_userid\")' >".getFixedLabel('SETMEMBERS')."</a>";//分配
        $list_entries.="<a class='Anu3_a redFont' href='javascript:void(0);' onclick='DeleteTrackPostionBefore(this,$prevtrackpositionid)'>".getFixedLabel('DELETE')."</a>";//删除
        $list_entries.="</td>";
        $list_entries.="</tr>";
	}
}
$list_entries.="</table>";

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("TRACKTREE", $list_entries);
$smarty->assign("num_rows_show",$num_rows);
$arr['content'] = $smarty->fetch("TrackTree.tpl");
ConvertTojsonString(1,$arr,"success");
?>