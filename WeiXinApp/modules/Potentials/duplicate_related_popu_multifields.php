<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//微信销售机会查重
$module = $_REQUEST['module'];
$mobj = cls_Instance::get_moduleAction_Instance($module,'ListView');
global $currentModule,$current_user;
//wym 240416 查重类文件结构优化
crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
$duplicate_obj=cls_DuplicateColumn::getInstance($module);
$newDetailValues = array();
if (!empty($_REQUEST['search_content'])) {
    $_REQUEST['duplicate_related_popu_multifields'] = true;
    $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
    if(isset($_REQUEST['search_content'])&&mb_strlen($_REQUEST['search_content'])<2){
        ConvertTojsonString(-1,array(),getFixedLabel('SearchByAtLeast2char'));
    }
    $_REQUEST['searchcontent'] = $_REQUEST['search_content'];
    //微信查重，查询方法改为继承PC端  
    $mobj = cls_Instance::get_moduleAction_Instance($module,'Duplicate');
    $result = $mobj->get_listdetail(null,null);
    $returnList['search_result']  = array('list1'=> $result['list1']);
}elseif(isset($_REQUEST['save_setting'])) {
    $duplicate_obj->saveDuplicateColumnDisplayFromFile($_REQUEST['save_setting']);
    $duplicate_obj->saveDuplicateColumnSearchFromFile($_REQUEST['search_save_setting']);
    $returnList = array();
    /*保存：saveDuplicateColumnDisplayFromFile($fields)
$fields参数格式：Accounts|ld_account|accountname,Accounts|ld_account|account_no*/
}else{
    $option_content = $duplicate_obj->getOptionContent();
    $option_selected = $duplicate_obj->getDuplicateColumnDisplaySetting(3);
    $search_option_content = $duplicate_obj->getOptionContent('search');
    $search_option_selected = $duplicate_obj->getDuplicateColumnSearchSetting(3);

    $output = array();
    $search_title_arr = array();
    $i = 0;
    $j = 0;
    //显示字段，已选字段
    foreach ($option_selected as $key=>$value){
        if($module=='Potentials'){//移动端显示界面太窄，去掉模块名，保留字段名
            $short_value = explode('_',$value);
            $value = $short_value[1];
        }
        $output[$i]['text'] = $value;
        $output[$i]['select'] = 'yes';
        $output[$i]['value'] = $key;
        $i++;
    }
    //查询字段，已选字段
    foreach ($search_option_selected as $key=>$value){
        if($module=='Potentials'){//移动端显示界面太窄，去掉模块名，保留字段名
            $short_value = explode('_',$value);
            $value = $short_value[1];
        }
        $search_output[$j]['text'] = $search_title_arr[$j] = $value;
        $search_output[$j]['select'] = 'yes';
        $search_output[$j]['value'] = $key;
        $j++;
    }
    $search_title = getFixedLabel('SEARCHNEW').' '.implode('、',$search_title_arr);
    //显示字段，可选字段
    foreach ($option_content as $key=>$value){
        if($module=='Potentials'){
            $short_value = explode('_',$value);
            $value = $short_value[1];
        }
        $output[$i]['text'] = $value;
        $output[$i]['select'] = 'no';
        $output[$i]['value'] = $key;
        $i++;
    }
    //查询字段，可选字段
    foreach ($search_option_content as $key=>$value){
        if($module=='Potentials'){
            $short_value = explode('_',$value);
            $value = $short_value[1];
        }
        $search_output[$j]['text'] = $value;
        $search_output[$j]['select'] = 'no';
        $search_output[$j]['value'] = $key;
        $j++;
    }
    $returnList['list']['fieldlabel'] = getFixedLabel('SETDUPFIELD');
    $returnList['list']['fieldname'] = 'repeat';
    $returnList['list']['option'] = $output;
    //xxy 2023-11-23 区分查重显示和查询字段
    $returnList['listSearch'][0]['fieldlabel'] = getFixedLabel('SetQueryFields');//查询字段list
    $returnList['listSearch'][0]['fieldname'] = 'searchfields';
    $returnList['listSearch'][0]['option'] = $search_output;
    $returnList['listSearch'][1]['fieldlabel'] = getFixedLabel('SetDisplayFieldsForDuplicate');//查重内容显示字段list
    $returnList['listSearch'][1]['fieldname'] = 'showfields';
    $returnList['listSearch'][1]['option'] = $output;
    $returnList['search_reminds'] = $search_title;
    $returnList['is_admin'] = $current_user->is_admin;
}

//duan 202221021 移动端增加翻译字符串返回
$label_arr=array(
    'FINDDUPLICATES',//查重
    'CANCEL',//取消
    'NOTMPDATA',//没有%s数据
    'NOMORETMPDATA',//没有更多%s数据
    'CONFIRMED',//确定
    'SEARCHNEW',//搜索
    'SETSEARCHFIELDS',//至少设置3个搜索字段
    'SETSEARCHFIELDSONE',//至少设置1个查询字段
    'SETRESULTFIELDS',//至少设置3个查重内容显示字段
    'PLEASEENTERKEYWORDRECHECKING',//请输入查重关键字
    'NOMOREDATA',//没有更多数据
    'nodata',//没有数据
);
$fixedlabel_arr = TransFieldlabel($label_arr,'no');
$fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%数据
$returnList['arrFixedLabel'] = $fixedlabel_arr;

$system_deploy=getSys_deploy(151);
$deployvalue=$system_deploy['deploy_value'];
if(!empty($deployvalue)){
    $returnList['pageTip'] = getmodulefixedlabel('NOTECHECKMODULES', $deployvalue);
}

ConvertTojsonString(1,$returnList,'success');
exit;
?>