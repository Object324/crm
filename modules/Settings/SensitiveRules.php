<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231018 XUQIU1001341 SQL注入
// $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
// $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Users/Profile.class.php');
include('ActionLabel.php');
global $current_user, $currentModule;
global $adb;
global $theme;

$smarty = new lingdangCRM_Smarty;

$mode = $_REQUEST['mode'];
$fieldid = $_REQUEST['fieldid'];
$ruleid = $_REQUEST['ruleid'];
$datatype = $_REQUEST['datatype'];
$frommodule = $_REQUEST['frommodule'];

$focus=CRMEntity::getInstance($frommodule);
$tabid = getTabid($frommodule);
crm_load_class_file("cls_SensitiveRules",'modules/Settings');

//规则详情操作
if($datatype == 'detail'){
    //保存
    if($mode == 'save'){
        $saved_ruleid = cls_SensitiveRules::saveRuleInfo($tabid,$fieldid,$ruleid,$_REQUEST);
        $arr['saved_ruleid'] = $saved_ruleid;
        ConvertTojsonString(1, $arr, "success");
    }
    //创建
    if($mode == 'create'){
        $smarty->assign('started',0);
        $smarty->assign('end',0);
    }
    //编辑
    if($mode == 'edit'){
        $rule_data = cls_SensitiveRules::getRuleInfo($fieldid,$ruleid);
        $smarty->assign('sensitivename',$rule_data['sensitivename']);
        $smarty->assign('rulestatus',$rule_data['rulestatus']);
        $smarty->assign('ruletype',$rule_data['ruletype']);

        $encryptyinfo = Zend_Json::decode($rule_data['encryptyinfo']);
        $smarty->assign('encryptyway',$encryptyinfo['encryptyway']);
        $smarty->assign('started',$encryptyinfo['started']);
        $smarty->assign('end',$encryptyinfo['end']);
        // dump($encryptyinfo);
        $smarty->assign('effectivemethod',$rule_data['effectivemethod']);
        $disabledscene = $rule_data['disabledscene'];
        $arr['disabledscene'] = $disabledscene;
    }
    
    $encryptycontent = [
        "all" => getFixedLabel('AllEncrypted'),
        "left" => getFixedLabel('EncryptLeftPart'),
        "right" => getFixedLabel('EncryptRightPart'),
        "part" => getFixedLabel('EncryptSpecifiedPart'),
    ];
    $smarty->assign('encryptycontent',$encryptycontent);
    $effectivemethod_content = [
        "meetcontidion" => getFixedLabel('EffectWhenMet'),
        "notmeetcondition" => getFixedLabel('EffectWhenNotMet'),
    ];

    $smarty->assign('effectivemethod_content',$effectivemethod_content);
    $str = $smarty->fetch("Settings/SensitiveRulesPop.tpl");

    $arr['relatedtable'] = $rule_data['relatedtable'];

    $arr['nonelabel']=getFixedLabel('NONE');
    $arr['function_arr']=array("number"=>array("sum"=>getFixedLabel('SUM'),'SQL'=>"SQL"),'date'=>array('SQL'=>'SQL'));

    //$arr['comparatortype_arr']=array('n'=>getFixedLabel("NEQ"), 'e'=>getFixedLabel('EQ'),'l'=>getFixedLabel('LT'),'g'=>getFixedLabel('GT'),'m'=>getFixedLabel("LE"),'h'=>getFixedLabel("GE"));
    $arr['comparatortype_arr'] = array('none'=>getFixedLabel('NONE'));

    //选择字段类型
    $selecttype_arr = array('fields'=>getFixedLabel('DOCUMENTFIELDS'),
        'text'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('Text')),
        'number'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('NUMERICALVALUE')),
        'date'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('DATE')),
        'datetime'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('DateTime')),
        'sql'=>getFixedLabel('SQLQUERY'));
    $arr['selecttype_arr']=$selecttype_arr;

    $arr['functionlabel']=getFixedLabel('Function');
    $tmp_arr=[];
    $modulefields_arr=$focus->fieldobj->getModuleFields();

    foreach($focus->fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getSaveDataBase()!='yes')
            continue;
        if($fieldinfo->getBigType() == 'fileattachment'){
            continue;
        }
        
        $tablename = $fieldinfo->getTableName();
        
        if($tablename == $focus->table_name || $tablename == $focus->customFieldTable[0]){
            $tmp_arr[]=$fieldinfo;
        }
    }
    $arr['fields']=$tmp_arr;
    $arr['detailfields']=[];
    if($focus->detailfieldobj)
    {
        $tmp_arr=[];
        if(get_file_address($frommodule,'ProductDetails'))
        {
            foreach($focus->detailfieldobj->getModuleFields() as $fieldname=>$fieldinfo)
            {
                if($fieldinfo->getSaveDataBase()!='yes')
                    continue;
                if($fieldinfo->getTableName()!=$focus->Detail_table&&$fieldinfo->getTableName()!=$focus->Detail_table_scf)
                    continue;
                if($fieldinfo->getBigType() == 'image'){
                    continue;
                }
                    
                if($fieldinfo->istotalFldMoneyField())
                    $fieldinfo->setBigType('currency');
                else if($fieldinfo->istotalFldNumField())
                    $fieldinfo->setBigType('number');
                else
                    $fieldinfo->setBigType("date");
                $fieldinfo->setFieldName($fieldname);    
                $tmp_arr[]=$fieldinfo;
            }
        }
        else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml'))
        {
            foreach($focus->detailfieldobj->getModuleFields() as $fieldname=>$fieldinfo)
            {
                if($fieldinfo->getPresence()==1)
                    continue;
                if($fieldinfo->getSaveDataBase()!='yes')
                    continue;
                
                if($fieldinfo->getTableName()!=$focus->Detail_table&&$fieldinfo->getTableName()!=$focus->Detail_table_scf)
                    continue;
                if($fieldinfo->istotalFldMoneyField())
                        $fieldinfo->setBigType('currency');
                    else if($fieldinfo->istotalFldNumField())
                        $fieldinfo->setBigType('number');
                    else
                        $fieldinfo->setBigType("date");
                //if($fieldinfo->istotalFldMoneyField()||$fieldinfo->istotalFldNumField()||$fieldinfo->getFieldType()=='Date_Ymd')
                //{
                    $tmp_arr[]=$fieldinfo;
                    
                //}
            }
        }
        $arr['detailfields']=$tmp_arr;
    }

    $arr['advft_criteria'] = $rule_data['advft_criteria'];
    $arr['advft_criteria_groups'] = $rule_data['advft_criteria_groups'];
    $arr['content'] = $str;
    $arr['title'] = getFixedLabel('SensitiveRules');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    // dump($encryptyinfo);

    ConvertTojsonString(1, $arr, "success");
}
//列表操作
if($datatype == 'list'){
    if($mode == 'changerulestatus'){//改变规则启用状态
        $rulestatus = $_REQUEST['rulestatus'];
        $update_sql='UPDATE ld_sensitiverules set rulestatus=? where relatedfieldid = ? and sensitiveid = ?';
        $adb->pquery($update_sql,array($rulestatus,$fieldid,$ruleid));

        ConvertTojsonString(1, $arr, "success");
    }
    else if($mode == 'refresh'){//刷新
        $sensitiverules_listdata = cls_SensitiveRules::getRulesListByField($fieldid);
        $smarty->assign('sensitiverules',$sensitiverules_listdata);//规则内容
        $smarty->assign('FIELDID',$fieldid);//传回fieldid
        $smarty->assign('MODULE',$frommodule);//传回模块名
        $arr['content']=$smarty->fetch('Settings/SensitiveRulesList.tpl');

        ConvertTojsonString(1, $arr, "success");
    }
    else if($mode == 'delete'){//删除
        $delete_sql1='DELETE from ld_sensitiverules where sensitiveid = ?';
        $adb->pquery($delete_sql1,array($ruleid));
        $delete_sql2='DELETE from ld_sensitiveruleconditions where sensitiveid = ?';
        $adb->pquery($delete_sql2,array($ruleid));
        $arr['msg'] = getFixedLabel('SuccessDeleted');
        ConvertTojsonString(1, $arr, "success");
    }
    else if($mode == 'show'){//新增字段时,已新增规则显示
        $ruleids_str = $_REQUEST['ruleids_str'];
        $sensitiverules_listdata = cls_SensitiveRules::getRulesListByRules($ruleids_str);
        // dump($sensitiverules_listdata);
        $smarty->assign('FIELDID',0);//传回fieldid,还是为0
        $smarty->assign('MODULE',$frommodule);//传回模块名
        $smarty->assign('sensitiverules',$sensitiverules_listdata);//规则内容
        $arr['content']=$smarty->fetch('Settings/SensitiveRulesList.tpl');
        ConvertTojsonString(1, $arr, "success");
    }
    ConvertTojsonString(-1, $arr, "error");
}
exit();
?>