<?php
global $adb,$current_user,$languageType;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty;
$mode=$_REQUEST['mode'];

crm_load_class_file('WorkBriefReportSetting','modules/Home');
$BriefReportSetting = new WorkBriefReportSetting();
$arr=[];
if ($mode == 'edit'){
    $moduleArr=$BriefReportSetting->getModuleArr();
    //获取所有简报数据
    $BriefReportSetting->getListArr();
    $allList=$BriefReportSetting->getAllList();
    $reportLabelList=$BriefReportSetting->getReportLabelList();
    $selectList=$BriefReportSetting->getSelectedList();
    $briefReportLayout=$BriefReportSetting->getBriefReportLayout();
    $custom_maxid=$BriefReportSetting->getMaxIDFromMainTab();
    $custom_count=$BriefReportSetting->getCustomCount();
    $smarty->assign('reportLabelList',$reportLabelList);
    $smarty->assign('SELECTEDLIST',array_chunk(array_values($selectList),$briefReportLayout['rowcount']));
    $smarty->assign('BRIEFREPORTLAYOUT',$briefReportLayout);
    $smarty->assign('custom_count',$custom_count);
    $showtype = getUsersettingByLabel('CooperativeWork',1,'WorkBriefReportShowType');
    $smarty->assign('showstyle',$showtype);
    $OperationTip = '1. ' . getFixedLabel('SaleskitTip') . '<br>' . '2. ' . getFixedLabel('SaleskitTip2') ;
    $smarty -> assign('OperationTip',$OperationTip);
    $content = $smarty->fetch('Home/WorkBriefReport.tpl');
    $arr['title']=getFixedLabel('BRIEFREPORTCUSTOMIZATION');
    $arr['content']=$content;
    $arr['select_list']=$selectList;
    $arr['moduleArr']=$moduleArr;
    $arr['all_list']=$allList;
    $arr['custom_maxid']=$custom_maxid;
    $arr['custom_count']=$custom_count;
    $arr['languageType']=$languageType;
    $arr['briefReportLayout']=$briefReportLayout;
    ConvertTojsonString(1,$arr,'success');
}
elseif ($mode == 'field'){//获取字段
    $module = $_REQUEST['count_module'];
    $arr['field']=$BriefReportSetting->getSalesKitModuleFields($module);
    ConvertTojsonString(1,$arr,'success');
}
elseif ($mode == 'content'){
    $fieldsel = $_REQUEST['fieldsel'];
    $content = $_REQUEST['content'];
    $tablabel = $tablabel=getTranstab($_REQUEST['count_module']);
    $smarty->assign('FIELDSEL',$fieldsel);
    $smarty->assign('TABLABEL',$tablabel);
    $smarty->assign('CONTENT',$content);
    $smarty->assign("type",'WorkBriefReport');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content'] = $smarty->fetch("ContentTemplates.tpl");
    ConvertTojsonString(1,$arr,'success');
}
elseif ($mode == 'save'){
    $select_list = json_decode($_REQUEST['select_list'],true);
    $create_list = json_decode($_REQUEST['create_list'],true);
    $delete_list = json_decode($_REQUEST['delete_list'],true);
    $showtype = $_REQUEST['showtype'];
    setUsersettingByLabel('CooperativeWork',1,'WorkBriefReportShowType',$showtype);
    foreach ($create_list as $name => $info){
        unset($info['label']);
        $keyString= implode(',',array_keys($info));
        $valueString=implode("','",array_values($info));
        $sql = 'insert into ld_workreport_briefreport_detail('.$keyString.')'." select '".$valueString."' from dual where not exists(select 1 from ld_workreport_briefreport_detail where name = ? )";
        $adb->pquery($sql,array($info['name']));
    }
    foreach ($select_list as $key => $info){
        $name = $info['name'];
        if (array_key_exists($name,$create_list)){
            $sql = 'update ld_workreport_briefreport_detail set sequence = ? , presence = ? where name = ?';
            $adb->pquery($sql,array($info['sequence'],$info['presence'],$info['name']));
        }else{
            unset($info['label']);
            unset($info['delete']);
            $dataArr = [];
            foreach ($info as $tmpkey => $tmpvalue){
                $dataArr[]= $tmpkey." = '".$tmpvalue."'";
            }
            $valueString=implode(",",array_values($dataArr));
            $sql = 'update ld_workreport_briefreport_detail set '.$valueString." where name = ?";
            $adb->pquery($sql,array($info['name']));
        }
    }
    foreach ($delete_list as $key => $name){
        $sql = 'update ld_workreport_briefreport_detail set `delete` = ? , presence = ? where name = ?';
        $adb->pquery($sql,array(1,'no',$name));
    }
    //刷新
    //获取已显示的简报组件的相关信息
    $sql= "select name,sequence,presence,label_zh,label_en,count_module,count_type,count_columnname from ld_workreport_briefreport_detail  where `delete`=0 and presence = 'yes' order by sequence asc;";
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    if($num_rows>0) {
        $component_arr=array();
        for($i = 0; $i < $num_rows; $i++){
            $name = $adb->query_result($result,$i,'name');
            $count_module = $adb->query_result($result,$i,'count_module');
            if (!vtlib_isModuleActive($count_module) || isPermitted($count_module,'index') == 'no'){
                continue;
            }
            $label_str = $languageType == 'zh'?'label_zh':'label_en';
            $label = $adb->query_result($result,$i,$label_str);
            $sequence = $adb->query_result($result,$i,'sequence');
            $array_bfcomponent=array();
            $array_bfcomponent['sequence']=$sequence;
            $array_bfcomponent['component_strtolower']=strtolower($name);
            //各个模块对应的组件名
            $array_bfcomponent['componentlabel']=$label;
            //收款金额、签到报表的计量单位不一样；
            $component_arr[$name]=$array_bfcomponent;
        }
    }
    $smarty->assign("BFCOMPONENT",$component_arr);
    $arr['content'] = $smarty->fetch('Home/Briefcomponent.tpl');
    ConvertTojsonString(1,$arr,'success');
}
elseif ($mode == 'advance_value'){
    if (!isset($_REQUEST['advance_demand']) && !isset($_REQUEST['advance_demand_groups'])) {//首次穿透
        $sendlog_dates = explode(' ~ ', $_REQUEST['search_date_custom_value']);
        $starttime = trim($sendlog_dates[0]);
        $endtime = empty($sendlog_dates[1]) ? $sendlog_dates[0] : $sendlog_dates[1];
        $chuantou_name = $_REQUEST['chuantou_name'];
        $sql = "select count_datarange,count_timerange,advft_criteria,advft_criteria_groups from ld_workreport_briefreport_detail where name=? and `delete` = 0 and presence = 'yes'";
        $result = $adb->pquery($sql, array($chuantou_name));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            $advft_criteria = ldcrm_json_decode(decode_html($adb->query_result($result, 0, 'advft_criteria')));
            $advft_criteria_groups = decode_html($adb->query_result($result, 0, 'advft_criteria_groups'));
            $count_datarange = $adb->query_result($result, 0, 'count_datarange');
            $count_timerange = $adb->query_result($result, 0, 'count_timerange');
            $userid=$_REQUEST['userid'];
            if (isKehu001ServerPc() == 'yes'){
                $last_name = getUserRealName($userid);
            }else{
                $last_name = getUserFullName($userid);
            }
            $_REQUEST['searchType'] = 'advance';
            //查询条件+查看范围+时间范围
            if (empty($advft_criteria)) {
                $tmp_advft_criteria = array(
                    ['groupid' => 1,
                        'columnname' => $count_datarange,
                        'comparator' => 'e',
                        'value' => $last_name,
                        'columncondition' => 'and'],
                    ['groupid' => 1,
                        'columnname' => $count_timerange,
                        'comparator' => 'bw',
                        'value' => $starttime . ' 00:00:00,' . $endtime . ' 23:59:59',
                        'columncondition' => '']
                );
                $advft_criteria_groups = '[null,{"groupcondition":""}]';
            } else {
                $tmp_advft_criteria = array(
                    ['groupid' => 1,
                        'columnname' => $count_datarange,
                        'comparator' => 'e',
                        'value' => $last_name,
                        'columncondition' => 'and'],
                    ['groupid' => 1,
                        'columnname' => $count_timerange,
                        'comparator' => 'bw',
                        'value' => $starttime . ' 00:00:00,' . $endtime . ' 23:59:59',
                        'columncondition' => 'and']
                );
                $tmp_advft_criteria = array_merge($tmp_advft_criteria, $advft_criteria);
            }
            $_REQUEST['advance_demand'] = ldcrm_json_encode($tmp_advft_criteria);
            $_REQUEST['advance_demand_groups'] = $advft_criteria_groups;
        }
    }
    $chuantou_module = $_REQUEST['chuantou_module'];
    if (!empty($chuantou_module)){
        $fieldobj = Field::getInstance($chuantou_module,$adb);
        $wholeModuleField = $fieldobj->getModuleWholeFields();
        $fieldobj->setModuleAllPreseneceFields($wholeModuleField);
    }
    crm_load_class_file('WorkBriefReportChuantou',"modules/lingdang/cls_Report");
    $obj = new WorkBriefReportChuantou();
    $obj->setParams($_REQUEST);
    $obj->getListView();

}




?>