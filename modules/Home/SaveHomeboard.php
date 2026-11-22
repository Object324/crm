<?php
/****************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 **AUTHOR:BY hzx
 **DATE:20230307
 *DESCRIPTION:创建首页看板
 ****************************************************/

global $mod_strings,$app_strings,$adb,$current_user,$currentModule;
$_REQUEST['diony']='diony';
$from_module = $currentModule;
if(isset($_REQUEST['from_module'])&&!empty($_REQUEST['from_module'])){
    $from_module = $_REQUEST['from_module'];
}

//增加看板首页获取用户设置值功能
if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='change') {
    $boardid = $_REQUEST['boardid'];
    $Modulename='Home';
    //审批
    $content = '';
    $setting_label = '';
    if(isset($_REQUEST['ApproveStatusHistory'])&&!empty($_REQUEST['ApproveStatusHistory'])){
        $content=$_REQUEST['ApproveStatusHistory'];
        $setting_label = 'lastChangeApproveByUser';
        if(!empty($setting_label)){
            setUsersettingByLabel($Modulename,$current_user->id,$setting_label,$content,$boardid);
        }
    }
    if (isset($_REQUEST['chooseTime'])&&!empty($_REQUEST['chooseTime'])){
        $content=$_REQUEST['chooseTime'];
        $setting_label = 'lastChangeTimeByUser';
        if(!empty($setting_label)){
            setUsersettingByLabel($Modulename,$current_user->id,$setting_label,$content,$boardid);
        }
    }
    if (isset($_REQUEST['chooseSearchScope'])&&!empty($_REQUEST['chooseSearchScope'])){
        $content=$_REQUEST['chooseSearchScope'];
        $setting_label = 'lastChangeSearchScopeByUser';
        if(!empty($setting_label)){
            setUsersettingByLabel($Modulename,$current_user->id,$setting_label,$content,$boardid);
        }
    }
    ConvertTojsonString(1, [], "success");
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='showfieldsSet'){
    //zxm 20240815 获取组件的可选字段与显示字段--最近销售机会 最新合同订单类的组件有这个设置
    $boardid = $_REQUEST['boardid'];
    $boardtype = $_REQUEST['boardtype'];
    $stuffid = $_REQUEST['stuffid'];
    $showfields_json = $_REQUEST['showfields'];
    $selectedfieldsArr = Zend_Json::decode($showfields_json);//界面传过来的  选中的字段 这时候可能还未保存数据库

    crm_load_class_file("Homeboard", 'modules/Home');
    $homeboardObj = Homeboard::getInstance($boardid, $boardtype);
    $allstuffinfo = $homeboardObj->getAllStuffInfo();
    $stuffinfo = $allstuffinfo[$stuffid];
    $datarangemodule = $stuffinfo['datarangmodule'];
    if(empty($selectedfieldsArr)) {
        //按看板设置的字段
        $platesetting = $homeboardObj->getPlateSetting($boardid, $stuffid);

        $selectedfieldsJson = (isset($platesetting['showfields']) && !empty($platesetting['showfields'])) ? $platesetting['showfields'] : $stuffinfo['showfields'];
        $selectedfieldsArr = Zend_Json::decode(decode_html($selectedfieldsJson));
    }
    //获取所有可选字段
    $tmpfocus = CRMEntity::getInstance($datarangemodule);
    crm_load_class_file('CustomView','modules/CustomView');
    $oCustomView = new CustomView($datarangemodule);
    $allfields = $oCustomView->getModuleColumnsList($datarangemodule);;
    $leftfields_arr = [];
    $rightfields_arr = [];

    foreach($allfields[$datarangemodule] as $fieldgroup){
        foreach($fieldgroup as $fieldkey=>$fieldlabel){
            $fieldkey_arr = explode(':',$fieldkey);
            if($fieldkey_arr[0]!=$tmpfocus->table_name&&$fieldkey_arr[0]!=$tmpfocus->customFieldTable[0]){
                //zxm 20241030 只能选表头字段
                continue;
            }
            if(in_array($fieldkey,$selectedfieldsArr)){
                $sortkey = array_search($fieldkey,$selectedfieldsArr);
                $rightfields_arr[$sortkey] = ['value'=>$fieldkey,'text'=>$fieldlabel];
            }
            $leftfields_arr[] =  ['value'=>$fieldkey,'text'=>$fieldlabel];
        }
    }

    ksort($rightfields_arr);
    ConvertTojsonString(1, [
        'title'=>getFixedLabel('SETDISPLAYFIELDS'),
        'OPTIONALFIELD'=>getFixedLabel('OPTIONALFIELD'),
        'Selected_Fields'=>getFixedLabel('Selected_Fields'),
        'pleaseenterthecategoryyouarelookingforfield'=>getFixedLabel('pleaseenterthecategoryyouarelookingforfield'),
        'oktext'=>getFixedLabel('CONFIRMED'),
        'canceltext'=>getFixedLabel('CANCEL'),
        'rightfields_arr' => $rightfields_arr,
        'leftfields_arr' => $leftfields_arr],
        "success");die;
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='newRemindsModuleSet'){
    $boardid = $_REQUEST['boardid'];
    $stuffid = $_REQUEST['stuffid'];
    //查询设置 ld_homeboard_plate_setting
    $selectsql = "select setvalue from ld_homeboard_plate_setting where boardid=? and stuffid=? and type='new_reminds_modules' ";
    $selectres = $adb->pquery($selectsql,array($boardid,$stuffid));
    $selectnums = $adb->num_rows($selectres);
    $selectedModule = 'Accounts,ContactRecords,Potentials,SalesOrder,LBL_READEN';
    if($selectnums>0) {
        $selectedModule = $adb->query_result($selectres,0,0);
    }

    $rightfields_arr = [];
    if(!empty($selectedModule)){
        $selectedModule = trim($selectedModule,',');
        $selectedModule_arr = explode(',',$selectedModule);
        foreach($selectedModule_arr as $tmpmodule){
            $text = $tmpmodule=='LBL_READEN'?getFixedLabel($tmpmodule):getTranstab($tmpmodule);
            $rightfields_arr[] = ['value'=>$tmpmodule,'text'=>$text];
        }
    }

    crm_load_class_file('ModuleUtils','modules/lingdang');
    $ModuleUtilsObj = new ModuleUtils();
    $allmodules_arr = $ModuleUtilsObj->getAllModules();
    $allmodules_arr[] = 'LBL_READEN';
    $leftfields_arr = [];
    foreach($allmodules_arr as $tmodule){
        $text = $tmodule=='LBL_READEN'?getFixedLabel($tmodule):getTranstab($tmodule);
        $leftfields_arr[] = ['value'=>$tmodule,'text'=>$text];
    }
    ConvertTojsonString(1, [
        'title'=>getFixedLabel('SELECTMODULE'),
        'oktext'=>getFixedLabel('CONFIRMED'),
        'canceltext'=>getFixedLabel('CANCEL'),
        'rightfields_arr' => $rightfields_arr,
        'leftfields_arr' => $leftfields_arr],
        "success");die;
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='newRemindsModuleSetSave'){
    $boardid = $_REQUEST['boardid'];
    $stuffid = $_REQUEST['stuffid'];
    $selected_arr = Zend_Json::decode($_REQUEST['selected_arr']);
    $setvalue = implode(',',$selected_arr);

    //查询设置 ld_homeboard_plate_setting
    $selectsql = "select * from ld_homeboard_plate_setting where boardid=? and stuffid=? and type='new_reminds_modules' ";
    $selectres = $adb->pquery($selectsql,array($boardid,$stuffid));
    $selectnums = $adb->num_rows($selectres);
    if($selectnums>0){
        $updatesql = "update ld_homeboard_plate_setting set setvalue=? where boardid=? and stuffid=? and type=?";
        $adb->pquery($updatesql,array($setvalue,$boardid,$stuffid,'new_reminds_modules'));
    }else{
        $insertsql = "insert into ld_homeboard_plate_setting (setvalue,boardid,stuffid,type) values (?,?,?,?)";
        $adb->pquery($insertsql,array($setvalue,$boardid,$stuffid,'new_reminds_modules'));
    }
    ConvertTojsonString(1, [], "success");die;
}
else {
    $boardtype = $_REQUEST['boardtype'];
//首页组件拖动
    if (isset($_REQUEST['submode'])) {
        if ($_REQUEST['submode'] == 'HomeBoardsort') {
            $selectedfields = explode(',', $_REQUEST['selectedFieldStr']);
            for ($i = 0; $i < count($selectedfields); $i++) {
                if (!empty($selectedfields[$i])) {
                    $seqsql = "update ld_homeboard set sequence=? where boardid=? and boardtype=?";
                    $adb->pquery($seqsql, array($i + 1, $selectedfields[$i], $_REQUEST['boardtype']));
                }
            }
            ConvertTojsonString(1, '', "success");
        }
    }
    $boardid = $_REQUEST['boardid'];
    $homeboard_info = ldcrm_json_decode($_REQUEST['homeboard_json']);
    $datarange_set = Zend_Json::decode($_REQUEST['datarange_set'], true);//zxm 20230613 数据范围
//edit: xll 2023/11/20 组件其他信息
    $StuffOtherSet = Zend_Json::decode($_REQUEST['StuffOtherSet'], true);
    $createdtime = date('Y-m-d H:i:s');
    $boardname="";
    $description="";
    $boardlayout="";
    $timesearchdefault="";
    $approve_value="";
    $scope="";
    $scope_list=[];

    if(is_array($homeboard_info)) {
        $boardname = $homeboard_info['boardname'];
        $description = $homeboard_info['description'];
        $boardlayout = $homeboard_info['boardlayout'];
        $timesearchdefault = $homeboard_info['timesearchdefault'];
        $approve_value = $homeboard_info['approve_value'];
        $scope = $homeboard_info['scope'];
        $scope_list = explode(',', $homeboard_info['scope_list']);
    }
    $icon_path = (isset($_REQUEST['icon_path']) && !empty($_REQUEST['icon_path'])) ? $_REQUEST['icon_path'] : '';

    if ($boardid > 0) {//编辑
        //edit: xll BUG0069072 kfbcrm-首页-审批状态查询条件 没有记住上次选择
        if (isset($_REQUEST['ApproveStatusHistory'])) {
            $ApproveStatusHistory = $_REQUEST['ApproveStatusHistory'];
            $update_sql_Status = "update ld_homeboard set `approve_value` = ? where `boardid` = ?";
            $adb->pquery($update_sql_Status, array($ApproveStatusHistory, $boardid));
            ConvertTojsonString(1, '', "success");
        }
        //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块（收藏操作、记住列表展现类型）
        if (isset($_REQUEST['actiontype']) && !empty($_REQUEST['actiontype'])) {
            crm_load_class_file("VisualAnalysisBoard", 'modules/VisualAnalysis');
            $BoardObj = new VisualAnalysisBoard($boardid, $currentModule);
            $msg = $BoardObj->SaveBoardOperate();
            ConvertTojsonString(1, $msg, "success");
        }
        if ($boardname != '') {
            $update_sql = 'update ld_homeboard set `boardname`=?,`description`=?,`modifiedby`=?,`modifiedtime`=?,`boardlayout`=?,`timesearchdefault`=?,`approve_value`=?,`scope`=?,`icon_path`=? where `boardid` = ?';
            $adb->pquery($update_sql, array($boardname, $description, $current_user->id, $createdtime, $boardlayout, $timesearchdefault, $approve_value, $scope, $icon_path, $boardid));

        }
    } else {//新建

        $seq_sql = 'select IFNULL(max(sequence),0) from ld_homeboard where boardtype=?;';
        $seq_result = $adb->pquery($seq_sql, array($boardtype));
        $seq_num = $adb->query_result($seq_result, 0, 0);
        $insert_sql = 'INSERT INTO ld_homeboard(`boardname`,`description`,`smcreatorid`,`createdtime`,`modifiedby`,`modifiedtime`,`boardlayout`,`timesearchdefault`,`approve_value`,`scope`,`icon_path`,`boardtype`,`sequence`) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);';
        $result = $adb->pquery($insert_sql, array($boardname, $description, $current_user->id, $createdtime, $current_user->id,
            $createdtime, $boardlayout, $timesearchdefault, $approve_value, $scope, $icon_path, $boardtype, $seq_num + 1));

        $boardid = $adb->getLastInsertID();
    }
//保存适用范围
    if ($scope == 'all') {
        crm_load_class_file("cls_related_scope", 'include/utils');
        cls_related_scope::delete_related_scope($boardtype, 'Homeboard_scope', $boardid);
    } else {
        crm_load_class_file("cls_related_scope", 'include/utils');
        cls_related_scope::save_related_scope($boardtype, 'Homeboard_scope', $boardid, $scope_list);
    }

//zxm 20230613 ld_homeboard_plate_stuff有主键了  不做删除  有数据则更新 无数据则insert
//if($boardid > 0){
//    $delete_sql = 'delete from ld_homeboard_plate_stuff where boardid = ?';
//    $adb->pquery($delete_sql,array($boardid));
//}
    crm_load_class_file("Homeboard", 'modules/Home');
    $homeboardObj = Homeboard::getInstance($boardid, $boardtype);
    $homeboardObj->savePlateAndStuff($homeboard_info, $datarange_set);
    $homeboardObj->savePlateSetting($homeboard_info, $StuffOtherSet);
    ConvertTojsonString(1, ['saved_boardid' => $boardid, 'boardname' => $boardname], "success");
}

?>