<?php
global $adb,$currentModule,$current_user;
$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony'] = 'yes';
$mode = $_REQUEST['mode'];
$smarty->assign('mode',$mode);
$arr=[];

if($mode == 'create' || $mode == 'edit'){
    $module = 'Calendar';
    Crm_load_class_file("CommonView","modules/CustomView");
    $customView = CustomView::getInstance('Calendar');
    $queryGenerator = new QueryGenerator('Calendar', $current_user,$customView);
    $controller = new ListViewController($adb, $current_user, $queryGenerator);
    $fieldnames = $controller->getAdvancedSearchOptionString();
    $arr['fieldnames'] = $fieldnames;
    crm_load_class_file('CommonView',"modules/CustomView");
    $comparatorArr = CommonView::getComparatorLabel();
    $comparatorArr['belong'] = getFixedLabel('BELONG');
    $comparatorArr['notbelong'] = getFixedLabel('NOTBELONG');
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $comparatorArr['new_belong'] = getFixedLabel('BELONG');
    $comparatorArr['new_notbelong'] = getFixedLabel('NOTBELONG');
    $advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
    $arr['advfilterhtml'] = $advfilterhtml;
    $arr['fLabels'] = $comparatorArr;

    $tip='<th><label style="font-size: 13px;">'.getFixedLabel('RuleValidityVondition').'</label>';
    $tip .='<label style="color: #9b9b9b;font-size: 13px;"> ( '.getFixedLabel('RuleValidityVonditionTooltips').' )</label></th>';
    if ($mode == 'create'){
        $arr['title']=getFixedLabel('CREATE');
    }elseif($mode == 'edit'){
        $arr['title']=getFixedLabel('EDIT');
        $ruleid=$_REQUEST['ruleid'];
        $sql='select id,name,status,backgroundcolor,textcolor,rulevalue from ld_calendar_colorrule where id=?';
        $result=$adb->pquery($sql,array($ruleid));
        $num_row=$adb->num_rows($result);
        if ($num_row >0){
            $ruleid=$adb->query_result($result,0,'id');
            $name=$adb->query_result($result,0,'name');
            $status=$adb->query_result($result,0,'status');
            $backgroundcolor=$adb->query_result($result,0,'backgroundcolor');
            $textcolor=$adb->query_result($result,0,'textcolor');
            $smarty->assign("ruleid",$ruleid);
            $smarty->assign("name",$name);
            $smarty->assign("status",$status=='yes'?'checked':'');
            $smarty->assign("backgroundcolor",$backgroundcolor);
            $smarty->assign("textcolor",$textcolor);
            $rulevalue_json = $adb->query_result($result,0,'rulevalue');
            $rulevalue = ldcrm_json_decode($rulevalue_json);
            $advft_criteria = $rulevalue['advft_criteria'];
            $advft_criteria_groups = $rulevalue['advft_criteria_groups'];
//            dump(array($advft_criteria,$advft_criteria_groups,$rulevalue));
            $advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule,$queryGenerator);
            $arr['criteria_groups'] = $advfilterlist;
        }
    }
    $arr['datetimestr']=CommonView::stdFilterDateTimeStr();
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $controller = ListViewController::getInstance($module);
    $arr['advanceFields'] = $controller->getAdvanceFields();
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['tipcontent']=$tip;
    $arr['content']=$smarty->fetch("modules/Calendar/CalenderColorRule.tpl");
    ConvertTojsonString(1,$arr,'success');
}elseif ($mode == 'delete'){
    $ruleid=$_REQUEST['ruleid'];
    $updatesql='delete from  ld_calendar_colorrule where id=?';
    $adb->pquery($updatesql,array($ruleid));
    $arr['content']=getRuleTableHtml();
    ConvertTojsonString(1,$arr,'success');
}elseif ($mode == 'changeColor'){
    $ruleid=$_REQUEST['ruleid'];
    $type=$_REQUEST['type'];
    $color=$_REQUEST['color'];
    $updatesql='update ld_calendar_colorrule set '.$type.'=? where id=?';
    $adb->pquery($updatesql,array($color,$ruleid));
    ConvertTojsonString(1,'','Change color successfully!!');
}elseif ($mode == 'changeStatus'){
    $ruleid=$_REQUEST['ruleid'];
    $status=$_REQUEST['status'];
    $updatesql='update ld_calendar_colorrule set status=? where id=?';
    $adb->pquery($updatesql,array($status,$ruleid));
    ConvertTojsonString(1,'','Change status successfully!!');
}elseif ($mode == 'changePriority'){
    $sort_arr=$_REQUEST['sort_arr'];
    $ruleid_sortarr=array_filter(explode(',',$sort_arr));
    foreach ($ruleid_sortarr as $index => $ruleid){
        $sequence=$index+1;
        $updatesql='update ld_calendar_colorrule set sequence = ? where id=?';
        $adb->pquery($updatesql,array($sequence,$ruleid));
    }
    $arr['content']=getRuleTableHtml();
    ConvertTojsonString(1,$arr,'success');

}elseif ($mode == 'save'){
    $option=$_REQUEST['option'];
    $advft_criteria = ldcrm_json_decode($_REQUEST['advft_criteria']);
    $advft_criteria_groups = ldcrm_json_decode($_REQUEST['advft_criteria_groups']);
    $rulevalue = array('advft_criteria'=>$advft_criteria,'advft_criteria_groups'=>$advft_criteria_groups);
    $rulevalue_json = ldcrm_json_encode($rulevalue); //以json格式保存查询条件
    $rulename=$_REQUEST['name'];
    $backgroundcolor=$_REQUEST['backgroundcolor'];
    $textcolor=$_REQUEST['textcolor'];
    $status=$_REQUEST['status'];
    if ($option == 'create'){
        $sequencesql='select max(sequence) as sequence from ld_calendar_colorrule';
        $sequenceresult=$adb->pquery($sequencesql,array());
        $sequence=$adb->query_result($sequenceresult,0,'sequence');
        $insertsql='insert into ld_calendar_colorrule(name,status,sequence,backgroundcolor,textcolor,rulevalue) values (?,?,?,?,?,?)';
        $adb->pquery($insertsql,array($rulename,$status,($sequence+1),$backgroundcolor,$textcolor,$rulevalue_json));
    }elseif ($option == 'edit'){
        $ruleid=$_REQUEST['ruleid'];
        $updatesql='update ld_calendar_colorrule set rulevalue=NULL where id=?';
        $adb->pquery($updatesql,array($ruleid));
        $updatesql='update ld_calendar_colorrule set name=?,status=?,backgroundcolor=?,textcolor=?,rulevalue=? where id=?';
        $adb->pquery($updatesql,array($rulename,$status,$backgroundcolor,$textcolor,$rulevalue_json,$ruleid));

    }
    $arr['content']=getRuleTableHtml();
    ConvertTojsonString(1,$arr,'Save successfully');
}

function getRuleTableHtml(){
    global $adb;
    $smarty = new lingdangCRM_Smarty();
    $arr=[];
    $sql='select id,name,status,backgroundcolor,textcolor from ld_calendar_colorrule order by sequence';
    $result=$adb->pquery($sql,array());
    $num_row=$adb->num_rows($result);
    for ($i=0;$i<$num_row;$i++){
        $ruleid=$adb->query_result($result,$i,'id');
        $name=$adb->query_result($result,$i,'name');
        $status=$adb->query_result($result,$i,'status');
        $backgroundcolor=$adb->query_result($result,$i,'backgroundcolor');
        $textcolor=$adb->query_result($result,$i,'textcolor');
        $arr[]=array('id'=>$ruleid,'name'=>$name,'status'=>$status,'sequence'=>($i+1),'backgroundcolor'=>$backgroundcolor,'textcolor'=>$textcolor);
    }
    $smarty->assign("rulesInfoarr",$arr);
    $html=$smarty->fetch('modules/Calendar/CalendarColorSetting_ListView.tpl');
    return $html;
}

?>