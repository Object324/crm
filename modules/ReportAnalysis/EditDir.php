<?php
global $adb,$languageType,$smarty,$current_user;

$smarty = new lingdangCRM_Smarty();
$mode = $_REQUEST['mode'];
$_REQUEST['diony']='yes';

$analysisfolder_id = $_REQUEST['analysisfolder_id'];//文件夹id
$parent_id = $_REQUEST['parent_id'];//父级文件夹id

//新建文件夹 //编辑文件夹
if($mode=='edit'){
    //中文名称
    //英文名称
    //描述

    if($analysisfolder_id>0){
        //编辑
        $analysisfolder_sql = "select analysisfolder_id,folderlabel_zh,folderlabel_en,description,parent_id from ld_report_analysis_folder where analysisfolder_id=?";
        $analysisfolder_res = $adb->pquery($analysisfolder_sql,array($analysisfolder_id));
        $analysisfolder_nums = $adb->num_rows($analysisfolder_res);
        if($analysisfolder_nums>0){
            $analysisfolder_info = $adb->query_result_rowdata($analysisfolder_res);
            $smarty->assign('analysisfolder_info',$analysisfolder_info);
            $arr['content'] = $smarty->fetch("ReportAnalysis/EditDir.tpl");

            $arr['title'] = getFixedLabel('EDIT').getFixedLabel('MAILFOLDER');
            $arr['oktext'] = getFixedLabel('SAVE');
            $arr['cancel'] = getFixedLabel('CANCEL');
            ConvertTojsonString(1,$arr, 'success');
        }else{
            //没有查到数据
            ConvertTojsonString(-1, [], '');
        }
    }else{
        $analysisfolder_info['parent_id'] = $parent_id;
        $smarty->assign('analysisfolder_info',$analysisfolder_info);
        $arr['content'] = $smarty->fetch("ReportAnalysis/EditDir.tpl");
        $arr['title'] = getFixedLabel('CREATE').getFixedLabel('MAILFOLDER');
        $arr['oktext'] = getFixedLabel('SAVE');
        $arr['cancel'] = getFixedLabel('CANCEL');
        ConvertTojsonString(1,$arr, 'success');
    }
}
//保存文件夹
if($mode=='save'){
    require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
    $ReportAnalysisActionsObj = new ReportAnalysisActions();
    if($analysisfolder_id>0){
        //编辑
        $update_sql = "update ld_report_analysis_folder set folderlabel_zh=?,`name`=?,folderlabel_en=?,description=? where analysisfolder_id=? ";
        $adb->pquery($update_sql,array(
            $_REQUEST['folderlabel_zh'],
            $_REQUEST['folderlabel_zh'],
            $_REQUEST['folderlabel_en'],
            $_REQUEST['description'],
            $analysisfolder_id
        ));
        $folderinfo = $ReportAnalysisActionsObj->getFolderInfo($analysisfolder_id,'folder');
        ConvertTojsonString(1,['folderinfo'=>$folderinfo[0],'savetype'=>'edit'], 'success');
    }

    if(empty($analysisfolder_id)){
        $sequence = 1;
        $depth = 1;
        //查询sequence
        $select_sql = "select max(`sequence`) as sequence from ld_report_analysis_folder where parent_id=?";
        $select_res = $adb->pquery($select_sql,array($parent_id));
        $select_nums = $adb->num_rows($select_res);
        if($select_nums>0){
            $sequence = $adb->query_result($select_res,0,'sequence');

            $sequence = $sequence+1;
        }
        //查询depth
        $select_sql = "select `depth` from ld_report_analysis_folder where analysisfolder_id=?";
        $select_res = $adb->pquery($select_sql,array($parent_id));
        $select_nums = $adb->num_rows($select_res);
        if($select_nums>0){
            $depth = $adb->query_result($select_res,0,'depth');
            $depth = $depth+1;
        }
        //新增
        $insert_sql = "insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,smcreatorid,parent_id,description,`sequence`,visible,`depth`) values(?,?,?,?,?,?,?,?,?)";
        $adb->pquery($insert_sql,array(
            $_REQUEST['folderlabel_zh'],
            $_REQUEST['folderlabel_zh'],
            $_REQUEST['folderlabel_en'],$current_user->id,
            $parent_id,
            $_REQUEST['description'],
            $sequence,
            'yes',
            $depth,
        ));
        $analysisfolder_id = $adb->getLastInsertID();
        $folderinfo = $ReportAnalysisActionsObj->getFolderInfo($analysisfolder_id,'folder');
        ConvertTojsonString(1,['folderinfo'=>$folderinfo[0],'savetype'=>'create'], 'success');
    }
}