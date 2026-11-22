<?php
/*
 * edit:duan
 * date:20230314
 * reason:销售指标操作按钮文件
 * */
global $currentModule, $current_user, $adb;
crm_load_class_file('SalesGoalOperation','modules/SalesGoal');
crm_load_class_file('cls_related_scope','include/utils');

$mode = $_REQUEST['mode'];
$targetid = $_REQUEST['targetid'];
$code = 1;
$msg = 'success';
$scopetype = 'TargetRange';
$arr = array();
$all_entitytype_arr = array();
$main_field_arr = array();
$detail_field_arr = array();

if($mode == 'getentityfield'){
    //获取分录的所有字段
    $entitytype = $_REQUEST['entitytype'];
    $frommodule = $_REQUEST['frommodule'];
    $returnfield_arr = SalesGoalOperation::getEntityField($frommodule,$entitytype);
    $main_field_arr[$entitytype] = $returnfield_arr['main'];
    $detail_field_arr[$entitytype] = $returnfield_arr['detail'];
    $arr['main_field_arr'] = $main_field_arr;
    $arr['detail_field_arr'] = $detail_field_arr;
}else if($mode == 'getRelatedModule'){
    //获取当前指标对象可关联的模块
    $entitytype_arr = array();
    $modulename = $_REQUEST['frommodule'];
    $all_entitytype_arr = SalesGoalOperation::getRelatedEntitytype($modulename);
    if(count($all_entitytype_arr)>0){
        $first_module = reset($all_entitytype_arr);
        $entitytype_arr[] = $first_module['name'];
    }
    foreach($entitytype_arr as $tmp_entitytype){
        $returnfield_arr = SalesGoalOperation::getEntityField($modulename,$tmp_entitytype);
        $main_field_arr[$tmp_entitytype] = $returnfield_arr['main'];
        $detail_field_arr[$tmp_entitytype] = $returnfield_arr['detail'];
    }
    $arr['all_entitytype_arr'] = $all_entitytype_arr;
    $arr['main_field_arr'] = $main_field_arr;
    $arr['detail_field_arr'] = $detail_field_arr;
}else if($mode == 'list'){
    //显示销售指标列表
    crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
    $modstatic = new SalesGoalNew();
    $SalesGoalListArr = $modstatic->getListSalesGoal();
    //edit: xll 2023/08/19 BUG0071385 管理指标弹出层中，“ 是否在看板显示 ”关闭最后一个指标时，弹出提示信息“至少保留一个指标名称”
    $ShowBoardNum = 0;
    foreach ($SalesGoalListArr as $SalesGoalInfo){
        $ShowtypeArr = explode(',',$SalesGoalInfo['showtype']);
        if(in_array('board',$ShowtypeArr))
            $ShowBoardNum+=1;
    }
    $languagetype = getLanguageType($current_user);
    $smarty = new lingdangCRM_Smarty();
    $permit_arr = $modstatic->getAllPermitArr();
    $smarty->assign('PERMITARR',$permit_arr);
    $smarty->assign('SalesGoalList',$SalesGoalListArr);
    $smarty->assign('ShowBoardNum',$ShowBoardNum);
    $smarty->assign('LANGUAGETYPE',$languagetype);
    $smarty->assign('isadmin',is_admin($current_user));
    $content = $smarty->fetch('modules/SalesGoal/SalesGoalList.tpl');
    $arr['content'] = $content;
    $arr['title'] = getFixedLabel('MANAGEINDICATORS');
    $arr['oktext'] = getFixedLabel('CLOSE');
}else if($mode == 'changestatus'){
    //修改启用状态
    //edit: xll 2023/08/10 $columnname_value 目标管理增加是否在看板显示参数
    $columnname = $_REQUEST['columnname'];
    $columnname_value = $_REQUEST[$columnname];
    $tag = $_REQUEST['tag'];
    if($tag == 'showboard'){
        $columnname_value = ($columnname_value == 'yes') ? 'board' : $columnname_value;
    }
    //edit: xll 2023/09/27 BUG0073321 管理指标-指标不启用时，“是否在看板显示”参数也应自动取消勾选
    $otherset = '';
    if($columnname == 'status' && $columnname_value == 'no'){
        $otherset = ",showtype = ''";
    }
    $sql = "UPDATE ld_salestarget_basic set `$columnname` = ? $otherset where targetid = ?;";
    $adb->pquery($sql,array($columnname_value,$targetid));
    //保存更新人
    SalesGoalOperation::SaveModifiedby($targetid,$current_user->id);
}else if($mode == 'move'){
    //edit: xll 2023/09/01 BUG0071424 目标管理改为托拽排序
    $SalesGoalSeqInfo = $_REQUEST['SalesGoalSeqInfo'];
    $SalesGoalSeqInfo = json_decode($SalesGoalSeqInfo,true);
    $update_sql = 'update ld_salestarget_basic set sequence = ? where targetid = ?';
    foreach ($SalesGoalSeqInfo as $targetid => $seq){
        $adb->pquery($update_sql,array($seq,$targetid));
    }
}else if($mode == 'delete'){
    //删除销售指标以及相关信息
    if(!empty($targetid)){
        //删除相关范围信息
        cls_related_scope::delete_related_scope($currentModule,$scopetype,$targetid);
        //删除共享信息
        $sql = "DELETE from ld_tabshare where crmid = ?;";
        $adb->pquery($sql,array($targetid));

        //删除分录信息
        $sql = "DELETE from ld_salestarget_detail where targetid = ?;";
        $adb->pquery($sql,array($targetid));

        //删除主表信息
        $sql = "DELETE from ld_salestarget_basic where targetid = ?;";
        $adb->pquery($sql,array($targetid));
    }
}else if($mode == 'Allocate'){
    //修改单据负责人
    $smownerid = $_REQUEST['smownerid'];
    $sql = "UPDATE ld_salestarget_basic set smownerid = ? where targetid = ?;";
    $adb->pquery($sql,array($smownerid,$targetid));
    //保存更新人
    SalesGoalOperation::SaveModifiedby($targetid,$current_user->id);
}else if($mode == 'Share'){
    //保存共享用户
    $shareuserids = trim($_REQUEST['shareuserids'],',');
    //删除原有共享用户
    $sql = "DELETE from ld_tabshare where crmid = ?;";
    $adb->pquery($sql,array($targetid));
    //添加新的共享用户
    if(!empty($shareuserids)){
        $insert_sql = "insert into ld_tabshare(crmid,viewuserid,Shareuserid) values";
        $share_userid_arr = explode(',',$shareuserids);
        $cur_userid = $current_user->id;
        $value_sql_arr = array();
        foreach ($share_userid_arr as $tmp_userid){
            $value_sql_arr[] = "($targetid,$cur_userid,$tmp_userid)";
        }
        if(sizeof($value_sql_arr) > 0){
            $combine_sql = $insert_sql.implode(',',$value_sql_arr);
            $adb->query($combine_sql);
        }
    }
}else if($mode == 'refreshpicklist'){
    $targetid = $_REQUEST['targetid'];
    $smarty = new lingdangCRM_Smarty();
    $default_arr = [];
    crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
    $modstatic = new SalesGoalNew();
    $PermitSalesgoalInfo = $modstatic->getPermitSalesGoal($targetid);
    $smarty->assign('PermitSalesgoalInfo',$PermitSalesgoalInfo);
    if(!empty($targetid)){
        foreach ($PermitSalesgoalInfo as $tmp_info){
            if($tmp_info['selected'] == 'yes'){
                $default_arr = $tmp_info;
                break;
            }
        }
    }
    if(sizeof($default_arr)==0){
        if(sizeof($PermitSalesgoalInfo)>0){
            $default_arr = reset($PermitSalesgoalInfo);
        }else{
            $default_arr = [];
        }
    }
    $smarty->assign('default_arr',$default_arr);
    $permit_arr = $modstatic->getAllPermitArr();
    $smarty->assign('PERMITARR',$permit_arr);

    $content = $smarty->fetch('modules/SalesGoal/SalesGoalPicklist.tpl');
    $arr['content'] = $content;
}else if($mode == 'getlinkfieldlabel'){
    $linkfieldname = getEntityName($_REQUEST['selectmodule'],explode(',',$_REQUEST['chooseentityid']));
    $arr['chooseentityname'] = implode(',',$linkfieldname);
}

ConvertTojsonString($code,$arr,$msg);
?>
