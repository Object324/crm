<?php
//zkt 20231024 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
// header('Content-Type:text/html;charset=UTF-8');
global $current_user,$adb;
$mode = '';
$recordid = '';
// 翻译
$label_arr = array(
    "selectusers" => "",
    "shareoldsmowner" => [],
    // "sharerelatedinfo" => [],
    "datascopeforelinfo" => [],
    "relmodulescope" => [],
);
//获取共享人信息
if(isset($_REQUEST['mode']) && !empty($_REQUEST['mode']))
    $mode = $_REQUEST['mode'];
if(isset($_REQUEST['frommodule']) && !empty($_REQUEST['frommodule']))
    $module = $_REQUEST['frommodule'];
if(isset($_REQUEST['recordid']) && !empty($_REQUEST['recordid']))
    $recordid = $_REQUEST['recordid'];

$focus = CRMEntity::getInstance($module);

$smowner = $focus->getSmownerColumName();
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$smowner);
$smownerlabel = $fieldinfo->getFieldLabelKey();// 负责人字段翻译
$arr['userfullnames'] = '';

if($mode == 'seniorShare'){// 共享
    $parent_mode = 'Share';
    $share_type_onlyadd = 'no';
    // 获取单据已选用户
    if(!empty($recordid)){
        crm_load_class_file('cls_share','include/Functions/Share');
        $objShare = new cls_share();
        $selected_user =  $objShare->getSelectedUser($recordid)['userid'];
        // 获取用户姓名
        $userids_arr = explode(',',$selected_user);
        $fullnames = '';
        foreach($userids_arr as $index => $userid){
            if($index > 0){
                $fullnames .= ',';
            }
            $fullnames .= getUserFullName($userid);
        }
        $arr['selected_user'] = $selected_user;
        $arr['userfullnames'] = $fullnames;

        // 如果单据负责人不是当前用户且也不是管理员，不能做取消共享和替换共享人
        $focus->retrieve_entity_info($recordid,$module);
        $col_fields = $focus->column_fields;
        $smownerfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname",$smowner);
        if($smownerfieldinfo) {
            $smownerfieldname = $smownerfieldinfo->getFieldName();
        }
        $smownerid = $col_fields[$smownerfieldname];// 被删除数据的负责人id
        if($smownerid != $current_user_id && $current_user->is_admin == 'off'){
            $share_type_onlyadd = 'yes';
        }
    }

    $label_arr['relmodulescope']['label'] = getFixedLabel('RelevantInfoModulesShared');// 共享的相关信息模块为
    // $label_arr['sharerelatedinfo']['label'] = getVarFixedLabel('SimultaneouslyVarRelinfo',getFixedLabel('SHARE'));// 同时共享相关信息
    $datascopeforelinfo_options[] = array('value' => 'all','label' => getFixedLabel('ChangeAllData'),'selected' => "");// 全部
    // $datascopeforelinfo_options[] = array('value' => 'none','label' => getFixedLabel('DonotProcessRelinfo'),'selected' => "");// 不分配/共享相关信息

    $arr['title'] = getFixedLabel('SHARE');
    $arr['share_type_onlyadd'] = $share_type_onlyadd;

}else{// 分配
    $parent_mode = 'Allocate';
    $label_arr['selectusers'] = getVarFixedLabel('ReplaceVarWith',$smownerlabel);
    $label_arr['relmodulescope']['label'] = getFixedLabel('RelevantInfoModulesAllocated');// 分配的相关信息模块为
    $label_arr['shareoldsmowner']['label'] = getVarFixedLabel('LetOriginalVar',$smownerlabel);// 将原销售负责人
    $shareoldsmowner_options[] = array('value' => 'setshare','label' => getFixedLabel('SetAsSharer'),'selected' => "");
    $shareoldsmowner_options[] = array('value' => 'removeshare','label' => getFixedLabel('RemoveFromSharers'),'selected' => "");// 选项
    $label_arr['shareoldsmowner']['option'] = $shareoldsmowner_options;
    $label_arr['shareoldsmowner']['optionlabel'] = $shareoldsmowner_options[0]['label'];
    $label_arr['shareoldsmowner']['optionvalue'] = $shareoldsmowner_options[0]['value'];

    // $label_arr['sharerelatedinfo']['label'] = getVarFixedLabel('SimultaneouslyVarRelinfo',getFixedLabel('ALLOCATE'));// 同时分配相关信息
    $datascopeforelinfo_options[] = array('value' => 'all','label' => getFixedLabel('ChangeAllData'),'selected' => "");// 全部
    $tmp_option_label = getVarFixedLabel('OnlyChangeSameVarData',$smownerlabel);
    $tmp_option_label = str_replace('{Module}',getTranstab($module),$tmp_option_label);
    $datascopeforelinfo_options[] = array('value' => 'samesmowner','label' => $tmp_option_label,'selected' => "");// 仅变更与客户同销售负责人的数据
    // $datascopeforelinfo_options[] = array('value' => 'none','label' => getVarFixedLabel('DonotVarRelinfo',getFixedLabel(strtoupper($parent_mode))),'selected' => "");// 不分配/共享相关信息

    // 数据范围选项
    $label_arr['datascopeforelinfo']['label'] = getFixedLabel('DataScopeforAllocateRelinfo');// 分配/共享以下相关信息
    $label_arr['datascopeforelinfo']['option'] = $datascopeforelinfo_options;
    $label_arr['datascopeforelinfo']['optionlabel'] = $datascopeforelinfo_options[0]['label'];
    $label_arr['datascopeforelinfo']['optionvalue'] = $datascopeforelinfo_options[0]['value'];

    if($mode == 'seniorAverageAllocate')
        $arr['title'] = getFixedLabel('AVERAGEDISTRIBUTION');
    else if($mode == 'seniorHigndistribution')// 公海分配
        $arr['title'] = getFixedLabel('LBL_DISTRIBUT_HIGHSEAS');
    else if($mode == 'seniorAverageHigndistribution')
        $arr['title'] = getFixedLabel('LBL_AVGDISTRIBUT_HIGHSEAS');
    else
        $arr['title'] = getFixedLabel('ALLOCATE');
    
}

// $label_arr['sharerelatedinfo']['checked'] = '';
$label_arr['relmodulescope']['part']['checked'] = '';

// 获取相关信息模块
$modulelist = getRelatedModulesWithAllocateShare($module,$parent_mode);
// $tmp_tabids = [];
$tmp_modulelabels = [];
$dragtransfer_modulelist = ['available' => array(),'selected' => array()];// 穿梭框用
foreach ($modulelist as $tmptabid => $modulelist_info) {
    // $tmp_modulenames[] = $modulelist_info['name'];
    // $tmp_tabids[] = $tmptabid;
    $tmp_modulelabels[] = $modulelist_info['label'];
    $dragtransfer_modulelist['available'][] = array('value' => $tmptabid,'text' => $modulelist_info['label']);

}
$label_arr['relmodulescope']['names'] = 'all';// 这三个参数移动端使用
$label_arr['relmodulescope']['tabids'] = 'all';
$label_arr['relmodulescope']['labels'] = implode(',',$tmp_modulelabels);

// 当前用户之前一次的选择
$pre_settings = getUsersettingByLabel($module,$current_user->id,$mode);
$pre_settings = ldcrm_json_decode(html_entity_decode($pre_settings));
if(!empty($pre_settings)){
    // $label_arr['sharerelatedinfo']['checked'] = $pre_settings['sharerelatedinfo']=='yes'?'checked':'';
    if(isset($pre_settings['shareoldsmowner']) && !empty($pre_settings['shareoldsmowner'])){// 将原销售负责人
        foreach ($label_arr['shareoldsmowner']['option'] as $key => &$value_info) {
            if($value_info['value'] == $pre_settings['shareoldsmowner']){
                $value_info['selected'] = 'selected';
                $label_arr['shareoldsmowner']['optionlabel'] = $value_info['label'];
                $label_arr['shareoldsmowner']['optionvalue'] = $value_info['value'];
                break;
            }
        }
    }
    if($pre_settings['relmodule_scope'] == 'part'){
        $pre_selectedtabid_arr = explode(',',$pre_settings['relmodule_selectedtabid_str']);
        $pre_selectedmodule_arr = [];
        $pre_selectedmodulelabel_arr = [];
        foreach ($pre_selectedtabid_arr as $index => $selectedtabid) {
            $selectedmodule = getTabname($selectedtabid);
            if(vtlib_isModuleActive($selectedmodule) && !empty($modulelist[$selectedtabid]['name'])){
                $modulelist[$selectedtabid]['selected'] = 'selected';
                $pre_selectedmodule_arr[] = $modulelist[$selectedtabid]['name'];
                $pre_selectedmodulelabel_arr[] = $modulelist[$selectedtabid]['label'];
                $dragtransfer_modulelist['selected'][] = array('value' => $selectedtabid,'text' => $modulelist[$selectedtabid]['label']);
            }
        }
        $label_arr['relmodulescope']['part']['checked'] = 'checked';

        $label_arr['relmodulescope']['names'] = implode(',',$pre_selectedmodule_arr);// 这三个参数移动端使用
        $label_arr['relmodulescope']['tabids'] = $pre_settings['relmodule_selectedtabid_str'];
        $label_arr['relmodulescope']['labels'] = implode(',',$pre_selectedmodulelabel_arr);
    }
    if(isset($pre_settings['reldata_scope']) && !empty($pre_settings['reldata_scope'])){// 分配相关信息的数据范围
        if($pre_settings['sharerelatedinfo'] == 'no'){// 兼容旧数据(第二版优化)
            $pre_settings['reldata_scope'] = 'none';
        }
        if($pre_settings['reldata_scope'] == 'none'){// 兼容旧数据(第三版优化)
            $pre_settings['reldata_scope'] = 'all';
        }
        foreach ($label_arr['datascopeforelinfo']['option'] as $key => &$option_info) {
            if($option_info['value'] == $pre_settings['reldata_scope']){
                $option_info['selected'] = 'selected';
                $label_arr['datascopeforelinfo']['optionlabel'] = $option_info['label'];
                $label_arr['datascopeforelinfo']['optionvalue'] = $option_info['value'];
                break;
            }
        }
    }
}else{
    if($mode != 'seniorShare'){
        $label_arr['shareoldsmowner']['option'][0]['selected'] = 'selected';
        $label_arr['datascopeforelinfo']['option'][1]['selected'] = 'selected';
    }
}

$modulelist = array_values($modulelist);

// dump($dragtransfer_modulelist);

$arr['label_arr'] = $label_arr;
$arr['modulelist'] = $modulelist;
$arr['dragtransfer_modulelist'] = $dragtransfer_modulelist;

// 其他一些翻译
$otherlabel = [];
$otherlabel['headblock']['smownersettings'] = getFixedLabel('SmownerSettings');
$otherlabel['headblock']['chooserelinfo'] = getVarFixedLabel('SimultaneouslyVarRelinfo',getFixedLabel(strtoupper($parent_mode)));
$otherlabel['headblock']['sharesettings'] = getFixedLabel('ShareSettings');
$arr['otherlabel'] = $otherlabel;

$arr['allocateVersion'] = 'third';// 优化版本过多，加个version移动端好做兼容

$arr['oktext'] = getFixedLabel("CONFIRMED");
$arr['canceltext'] = getFixedLabel("CANCEL");
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");
?>