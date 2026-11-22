<?php

global $adb,$current_user;

$languageType=getLanguageType($current_user);
$frommodule=$_REQUEST['frommodule'];

$sql='select * from ld_validatasavemain where module=? and isshowlist=? order by sequence desc,  id desc ';

$result=$adb->pquery($sql,array($frommodule,'yes'));
$rows=$adb->num_rows($result);
$tablehtml='<table name="table_pagevalidata" class="ControlTable1 listEntries fir-center listSettingData" width="100%" cellspacing="1" cellpadding="0" border="0"> <tr>';
$tablehtml.='<th>#</th>';
$tablehtml.='<th width="30%">'.getFixedLabel("RULENAME").'</th>';
$tablehtml.='<th width="15%">'.getFixedLabel("ApplicationScenarios").'</th>';
$tablehtml.='<th width="15%">'.getFixedLabel("BLOCKEDAFTERPROMPT").'</th>';
$tablehtml.='<th width="15%">'.getFixedLabel("ValidationArea").'</th>';
$tablehtml.='<th width="10%">'.getFixedLabel("ACTIVATE").'</th>';//wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”
// $tablehtml.='<th>'.getFixedLabel("TipMsgType").'</th>';
$tablehtml.='<th width="150px">'.getFixedLabel("OPERATING").'</th>';
$tablehtml.='</tr>';

$application_arr = array('create'=>getFixedLabel('NEW'),'edit'=>getFixedLabel('EDIT'),'delete'=>getFixedLabel('DELETE'),
'submit'=>getFixedLabel('SUBMITAPPROVAL'),'cancel'=>getFixedLabel('APPROVE_ANTIAPPROVAL'),'finish'=>getFixedLabel('APPROVALSUCCEEDED'));

for($i=0;$i<$rows;$i++)
{
    $id=$adb->query_result($result,$i,'id');
    if ($i%2 ==0) {
        $tablehtml.='<tr tagid="'.$id.'" id="setting_'.$i.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
    }
    else{
        $tablehtml.='<tr tagid="'.$id.'" id="setting_'.$i.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
    }
    $tablehtml.='<td>'.($i+1).'</td>';
    $rulename=$adb->query_result($result,$i,'rulename');
    //231107 wyn BUG0075078 页面设置-布局规则/验证规则，内容过长时显示不完全，增加浮显
    $tablehtml.='<td><span class="tip-items-lists" data-tip="'.$rulename.'" data-type="position" data-direction="top">'.$rulename."</span></td>";
    
    $validataapplication=$adb->query_result($result,$i,'validataapplication');
    $validataapplication_arr = explode(',',$validataapplication);
    
    $str_arr = array();
    foreach($validataapplication_arr as $tmp_application){
        $str_arr[] = $application_arr[$tmp_application];
    }
    $application_str = implode(',',$str_arr);
    $tablehtml.='<td title="'.$application_str.'" >'.$application_str.'</td>';
    
    $actionprevent=$adb->query_result($result,$i,'actionprevent');
    if($actionprevent=='yes'){
        $tablehtml.='<td>'.getFixedLabel("YES").'</td>';
    }
    else if($actionprevent=='no')
    {
        $tablehtml.='<td>'.getFixedLabel("NO").'</td>';
    }
    $relatedtable=$adb->query_result($result,$i,'relatedtable');
    if($relatedtable=='ld_field')
        $tablehtml.='<td>'.getFixedLabel("BillHeader").'</td>';
    else
        $tablehtml.='<td>'.getFixedLabel("BillDetail").'</td>';
    $status=$adb->query_result($result,$i,'status');
    if($status=='active')
    {
        $tablehtml.='<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'pagevalidata\')" class="second_switch" checked>'.'</td>';
    }
    else if($status=='inactive') {
        $tablehtml .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'pagevalidata\')" class="second_switch" >'.'</td>';
    }
    // if($languageType='zh')
    //  {
    //     $tipzh=$adb->query_result($result,$i,'tipzh');
    //     $tablehtml.='<td>'.$tipzh.'</td>';
    //  }
    //  else
    //  {
    //     $tipen=$adb->query_result($result,$i,'tipen');
    //     $tablehtml.='<td>'.$tipen.'</td>';
    //  }
     if($i==0)//第一行没有上移
        $tablehtml.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del">'.getFixedLabel("DELETE").'</a><a class="Anu3_a" href="javascript:void(0);" name="btn_down">'.getFixedLabel("MOVEDOWN").'</a></td>';
     else if($i==$rows-1)//最后一行没有下移
        $tablehtml.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del">'.getFixedLabel("DELETE").'</a><a class="Anu3_a" href="javascript:void(0);" name="btn_up">'.getFixedLabel("MOVEUP").'</a></td>';
     else
        $tablehtml.='<td><a class="Anu3_a" href="javascript:void(0);" name="btn_edit">'.getFixedLabel("EDIT").'</a><a class="Anu3_a redFont" href="javascript:void(0);" name="btn_del">'.getFixedLabel("DELETE").'</a><a class="Anu3_a" href="javascript:void(0);" name="btn_up">'.getFixedLabel("MOVEUP").'</a><a name="btn_down">'.getFixedLabel("MOVEDOWN").'</a></td>';

    $tablehtml.="</tr>";
    
}
$tablehtml.='</table>';
$arr=[];
$_REQUEST['diony']='yes';
$arr['content']=$tablehtml;
ConvertTojsonString(1,$arr,'success');

?>