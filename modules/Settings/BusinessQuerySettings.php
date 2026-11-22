<?php
global $adb;
global $current_user;
//zkt 20231102 XUQIU1001892 PC端高危优化-水平越权优化（文档中第三个问题）（王耀文）
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mode=$_REQUEST['mode'];
if(isset($_REQUEST['tabid']) && !empty($_REQUEST['tabid']))
    $tabid = $_REQUEST['tabid'];
$business_insterfacekey = 344;
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
if(isset($mode)&&$mode=='changebusinessqueryinterfacemethod'){
    $business_search_method = (int)($_REQUEST['business_search_method']);//工商查询接口方式
    if($business_search_method == 1){
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        cls_BusinessInformation::setBusinessIinsterfacekey($business_search_method,$cls_AESencryptionbykeyobj->getencryption(''));//设置对应查询方式
        ConvertTojsonString(1,array(),'success');
    }
    else{
        $business_insterfacekey_value = cls_BusinessInformation::getBinsterfaceinputvalue();
        //如果key没有值则需要出弹窗前往设置值
        if(empty($business_insterfacekey_value)){
            ConvertTojsonString(2,array(),'success');
        }
        cls_BusinessInformation::setBusinessIinsterfacekey($business_search_method);//设置对应查询方式
    }
    ConvertTojsonString(1,array(),'success');
}
else if(isset($mode)&&$mode=='getbusiness_insterfacekeypop'){
    //天眼查工商接口KEY 0:设置 1:未设置
    $business_insterfacekey_deploy_value = cls_BusinessInformation::getBinsterfacedeployvalue();
    $business_insterfacekey_value = '';
    if($business_insterfacekey_deploy_value==0){
        $business_insterfacekey_value = cls_BusinessInformation::getBinsterfaceinputvalue();
    }

    //zkt 20240311 XUQIU20240307-04 工商信息设置，当工商接口方式为：*天眼查工商接口KEY做密文，包括编辑弹窗内也需要密文加密（传输如果可以加密也加密）
    $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
    $sensitiveencryptvalue = $cls_AESencryptionbykeyobj->getencryption($business_insterfacekey_value);
    $business_insterfacekey_encryptkey = $cls_AESencryptionbykeyobj->getencryptkey();
    $havesensitivevalue = 'no';
    if(!empty($business_insterfacekey_value)){
        $havesensitivevalue = 'yes';
        $length = mb_strlen($business_insterfacekey_value)-4;
        $replacement = str_repeat("*", $length);
        $business_insterfacekey_value  = substr_replace($business_insterfacekey_value, $replacement, 0, $length);
    }

    $html='<div id="business_insterfacekey_setting">
                <table class="ld-public-content-paddingright padTB10" cellspacing="0" cellpadding="0" border="0" width="100%">
                    <tr>
                        <td class="ld-form-item-label">'.getFixedLabel('businessqueryinterfacemethod').'</td>
                        <td class="ld-form-item-content">
                            '.getFixedLabel('useselfpurchasedbusinessinterfacekey').'
                        </td>
                    </tr>
                    <tr>
                        <td class="ld-form-item-label">
                            <font color="red" name="business_insterfacekey_required">*</font>'.getFixedLabel('TIANYANCHABUSINESSINTERFACEKEY').'
                        </td>
                        <td class="ld-form-item-content">
                            <input id="business_insterfacekey" name="business_insterfacekey" type="text" class="ld-input-inner" value="'.$business_insterfacekey_value.'"/>
                        </td>
                    </tr>
                </table>
            </div>';
    $arr['content']=$html;
    $arr['havesensitivevalue']=$havesensitivevalue;
    $arr['sensitiveencryptvalue']=$sensitiveencryptvalue;
    $arr['business_insterfacekey_encryptkey']=$business_insterfacekey_encryptkey;
    $arr['title']=getFixedLabel("BUSINESSQUERYINTERFACESETTINGS");
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    ConvertTojsonString(1,$arr,'success');
}
else if(isset($mode)&&$mode=='savebusiness_insterfacekey'){
    $business_insterfacekey_value = $_REQUEST['business_insterfacekey_value'];//天眼查工商接口KEY
    $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
    $business_insterfacekey_dncryptvalue = $cls_AESencryptionbykeyobj->getdecryption($business_insterfacekey_value);
    //验证key的有效性
    crm_load_class_file('cls_TianYanCha', 'modules/Users');
    $cls_TianYanCha = new cls_TianYanCha('info','客户000');
    if($cls_TianYanCha->isUseToken($business_insterfacekey_value)){
        $returnmsg = getFixedLabel("INVALIDKEY");
        ConvertTojsonString(-1,array(),$returnmsg);
    }

    $return = $cls_TianYanCha->testKey($business_insterfacekey_dncryptvalue);
    if($return['error_code']!=0)
    {
        ConvertTojsonString(-1,array(),$return['reason']);
    }
    elseif (!is_array($return)){
        ConvertTojsonString(-1,array(),'查询超时');
    }
    cls_BusinessInformation::setBusinessIinsterfacekey(0,$business_insterfacekey_value);//设置对应key值
    if(!empty($business_insterfacekey_dncryptvalue)){
        $length = mb_strlen($business_insterfacekey_dncryptvalue)-4;
        $replacement = str_repeat("*", $length);
        $business_insterfacekey_dncryptvalue  = substr_replace($business_insterfacekey_dncryptvalue, $replacement, 0, $length);
    }
    ConvertTojsonString(1,array('newinterfacekey'=>$business_insterfacekey_dncryptvalue),'success');
}
else if(isset($mode)&&$mode=='savebusiness_fuzzyquery_count'){
    $fuzzyquerytosearchnum = $_REQUEST['fuzzyquerytosearchnum'];
    cls_BusinessInformation::setBusinessfuzzyquerytosearchnum($fuzzyquerytosearchnum);//设置对应key值
    ConvertTojsonString(1,array(),'success');
}
else if(isset($mode)&&$mode=='setinformationvalue'&&isset($_REQUEST['setmodule']))
{
    $module = $_REQUEST['setmodule'];
    $updatetype = $_REQUEST['settype'];
    $changevalue = $_REQUEST['changevalue'];
    $cls_BusinessInformationobj = cls_BusinessInformation::getInstance($module);
    $cls_BusinessInformationobj->setBusinessInformationbytype($updatetype,$changevalue);
    //如果设置的是 没有工商信息不允许保存：否
    if($updatetype == 'nobusinessnosave' && $changevalue == 'no'){
        $cls_BusinessInformationobj->setBusinessInformationbytype('nobusinessnoimport','no');
        $cls_BusinessInformationobj->setBusinessadvancedemand('[]','[]');
    }else if($updatetype == 'enablebusiness' && $changevalue == 'no'){
        $cls_BusinessInformationobj->setBusinessInformationbytype('nobusinessnosave','no');
        $cls_BusinessInformationobj->setBusinessInformationbytype('nobusinessnoimport','no');
        $cls_BusinessInformationobj->setBusinessInformationbytype('enablefuzzyquery','no');
        $cls_BusinessInformationobj->setBusinessInformationbytype('enablebatchbackfill','no');
        $cls_BusinessInformationobj->setBusinessadvancedemand('[]','[]');
    }
    ConvertTojsonString(1,array(),'success');
}
else if(isset($mode)&&$mode=='saveadvancedemand')
{
    $module = $_REQUEST['setmodule'];
    $advance_demand=trim($_REQUEST['advancesearch']);
    $advance_demand_groups = trim($_REQUEST['groupcondition']);
    $cls_BusinessInformationobj = cls_BusinessInformation::getInstance($module);
    $cls_BusinessInformationobj->setBusinessadvancedemand($advance_demand,$advance_demand_groups);
    ConvertTojsonString(1,array(),'success');
}
//新增工商查询模块
else if(isset($mode)&&$mode == 'createbusinessmodule'){

    $newmodule_arr = cls_BusinessInformation::createBusinessModule();
    $field_arr = cls_BusinessInformation::getAvailableFields($newmodule_arr['tabid']);
    $modulelist = cls_BusinessInformation::getAvailableModules($newmodule_arr['tabid']);
    // dump($modulelist);
    $arr['newmodule_arr'] = $newmodule_arr;//新增行模块
    $arr['field_arr'] = $field_arr;//模块中字段
    $arr['modulelist'] = $modulelist;//所有可选模块
}
//新增模块后修改模块
else if(isset($mode)&&$mode == 'changebusinessmodule'){
    
    $tmp_id = $_REQUEST['id'];
    cls_BusinessInformation::changeBusinessModule($tmp_id,$tabid);
    $field_arr = cls_BusinessInformation::getAvailableFields($tabid);
    $arr['field_arr'] = $field_arr;//模块中字段
    $arr['module'] = getTabModuleName($tabid);
}
//更改工商查询字段
else if(isset($mode)&&$mode == 'changebusinessqueryfield'){
    $fieldid = $_REQUEST['fieldid'];
    cls_BusinessInformation::changeBusinessQueryField($tabid,$fieldid);
}
//新增或切换模块时更新其他模块下拉框内容，防止选重复模块
else if(isset($mode)&&$mode == 'reloadavailablemodules'){

    $modulelist = cls_BusinessInformation::getAvailableModules();
    $arr['modulelist'] = $modulelist;
}
//删除工商查询模块
else if(isset($mode)&&$mode == 'deletebusinessmodule'){
    cls_BusinessInformation::deleteBusinessModule($tabid);
    $arr['msg'] = getFixedLabel('SuccessDeleted');
}
//工商模糊查询规则设置
else if(isset($mode)&&$mode == 'getfuzzycontrol'){
    $tabid = getTabid($_REQUEST['frommodule']);
    $fuzzycontrol=cls_BusinessInformation::getAllBusinessInformation()[$tabid]['fuzzyquerycontrol'];//从数据库读取模糊查询规则
    $fuzzycontrol_arr = cls_BusinessInformation::$fuzzycontrol_defaultarr;
    if(!is_null($fuzzycontrol)&&!empty($fuzzycontrol)){
        $fuzzycontrol_arr = $fuzzycontrol;
    }
    $html = '<table class="settingPopTable settingPopTableNoBot DetailContentTable">';
    $arr['title']= getFixedLabel('SetFuzzy');
    foreach($fuzzycontrol_arr as $idx=>$value){
        $controlname  =  getFixedLabel($idx);
        $controlvalue = $value =='yes'?'checked':'';
        $html.='<tr><td align="right" class="ld-form-item-label">
				<label>'.$controlname.'</label>	
			</td>
			<td align="left" class="ld-form-item-content">
				<input id="'.$idx.'" class="second_switch" type="checkbox"'.$controlvalue.'></td></tr>';
    }
    $arr['content'] = $html.'</table>';
}
ConvertTojsonString(1,$arr,"success");
die();
?>