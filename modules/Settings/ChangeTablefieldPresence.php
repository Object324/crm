<?php
/*
edit:duan
date:2022-2-16
reason:修改表中的字段是否开启状态
*/

global $adb,$languageType;

$presence = $_REQUEST['presence'];
$type = $_REQUEST['type'];
$_REQUEST['diony']='diony';
$index_value = $_REQUEST['index_value'];
//根据类型获取相关表信息
$table_info = getTablenameBytype($type);
if(sizeof($table_info)==0){
    ConvertTojsonString(-1,array(),'failed');
}
$tablename = $table_info['tablename'];
$table_index = $table_info['table_index'];
$columnname = $table_info['columnname'];
//根据获取值类型来得到需要保存的值
$value_type = $table_info['value_type'];
$type_arr = explode(',',$value_type);
$value = $type_arr[$presence];

$modulename = $_REQUEST['modulename'];
//登录自定义设置
if($type == 'loginsettings'){

    loginsetting_save($index_value,$value);
    ConvertTojsonString(1,$arr,'success');
}
//typeofdata特殊处理
if($type == 'producttoolfield_mandatory'||$type == 'tabdetailfield_mandatory'){
    $sql = "select $columnname,tabid from $tablename where $table_index=?";
    $result = $adb->pquery($sql,array($index_value));
    $num_rows = $adb->num_rows($result);
    if($num_rows > 0){
        $typeofdata = $adb->query_result($result,0,0);
        $tabid = $adb->query_result($result,0,'tabid');
        if($value == 'M'){
            $value = str_replace('O','M',$typeofdata);
        }else{
            $value = str_replace('M','O',$typeofdata);
        }
    }
}
elseif ($type == 'workreport_field_active') {
    //ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(工作汇报列表页 字段启用停用)
    $query = "UPDATE ld_field LEFT JOIN ld_workreport_field ON CASE WHEN ld_workreport_field.name in('signaddress','worksummary','workplan','workexperience') THEN CONCAT(ld_workreport_field.name,CASE WHEN ld_workreport_field.type=2 THEN '_week' WHEN ld_workreport_field.type=3 THEN '_month' ELSE '' END) ELSE ld_workreport_field.name END = ld_field.columnname SET ld_field.presence = ? where ld_workreport_field.id = ? AND ld_field.tabid = ?";
    $adb->pquery($query,array($presence,$index_value,getTabid('WorkReportList')));
    unsetCacheDirectory("fields");
    unsetCacheDirectory('customview');
    unsetCache('cache_getworkreportfieldentity');
    unsetCache('cache_getworkreportsignentity');
}
elseif ($type == 'workreport_field_is_mandatory') {
    //ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(工作汇报列表页 是否必填)
    $query = "UPDATE ld_field LEFT JOIN ld_workreport_field ON CASE WHEN ld_workreport_field.name in('signaddress','worksummary','workplan','workexperience') THEN CONCAT(ld_workreport_field.name,CASE WHEN ld_workreport_field.type=2 THEN '_week' WHEN ld_workreport_field.type=3 THEN '_month' ELSE '' END) ELSE ld_workreport_field.name END = ld_field.columnname SET ld_field.typeofdata = ? where ld_workreport_field.id = ? AND ld_field.tabid = ?";
    $presence = $presence=='1'?'V~O':'V~M';
    $adb->pquery($query,array($presence,$index_value,getTabid('WorkReportList')));
    unsetCacheDirectory("fields");
    unsetCacheDirectory('customview');
    unsetCache('cache_getworkreportfieldentity');
    unsetCache('cache_getworkreportsignentity');

}

//移动端模块列表定制，至少需要一行字段显示
if($type == 'cvcolumnlist_wx_presence'){
    if($presence == 1){
        //如果当前行关闭后，没有其他的字段显示，则不允许关闭
        $sql = "SELECT 1 from ld_cvcolumnlist_wx 
                INNER JOIN (SELECT modulename,rownumber,listnumber from ld_cvcolumnlist_wx where id = ?) as tmp 
                ON ld_cvcolumnlist_wx.modulename = tmp.modulename where (tmp.rownumber <> ld_cvcolumnlist_wx.rownumber 
                or tmp.listnumber <> ld_cvcolumnlist_wx.listnumber) AND presence = 0;";
        $result = $adb->pquery($sql,array($index_value));
        $num_rows = $adb->num_rows($result);
        if($num_rows < 1){
            ConvertTojsonString(-1,$arr,'success');
        }
    }
}
//移动端详情界面定制 开启数量不允许超过五行
elseif ($type == 'fieldwxmaininfo_presence') {
    if($presence != 1){
        $sql = 'select count(1) from ld_fieldwxmaininfo where tabid=? and presence=0';
        //if(!empty($index_value)) $sql.=' and id!='.$index_value;
        $result = $adb->pquery($sql,array(getTabid($modulename)));
        $count = $adb->query_result($result,0,0);
        if($count>=5){
            ConvertTojsonString(-1,array(),'error1');
        }
    }

}
//移动端模块列表定制 至少设置一个字段可用于查询
elseif ($type == 'cvcolumnlist_wx_isforsearch') {
    if($presence == 1){
        $sql = 'SELECT 1 from ld_cvcolumnlist_wx where modulename = (SELECT modulename from ld_cvcolumnlist_wx where id = ?) and isforsearch <> "no"';
        $result = $adb->pquery($sql,array($index_value));
        $num_rows = $adb->num_rows($result);
        if($num_rows < 2){
            ConvertTojsonString(-1,array(),'error2');
        }
    }
}
//BUG20240716-46 wsh 2024-08-06 后台设置->服务小程序->列表定制，将所有字段设置为不显示，移动端服务小程序只显示一行空白（服务小程序中的“详情定制”也有这个问题，应改为至少一个字段的“是否显示”按钮为开启状态
elseif ($type == 'weixinmp_listfields_presence') {
    if($presence == 1){
        $sql = 'SELECT 1 from ld_weixinmp_listfields where modulename = (SELECT modulename from ld_weixinmp_listfields where id = ?) and presence <> 1';
        $result = $adb->pquery($sql,array($index_value));
        $num_rows = $adb->num_rows($result);
        if($num_rows < 2){
            ConvertTojsonString(-1,array(),getFixedLabel("DISPALYATLEASTONE"));
        }
    }
}
//详情定制 至少显示一个字段
elseif ($type == 'weixinmp_fields_displaytype') {
    if($presence == 1){
        $sql = 'SELECT 1 from ld_weixinmp_fields where modulename = (SELECT modulename from ld_weixinmp_fields where id = ?) and displaytype <> "createno"';
        $result = $adb->pquery($sql,array($index_value));
        $num_rows = $adb->num_rows($result);
        if($num_rows < 2){
            ConvertTojsonString(-1,array(),getFixedLabel("DISPALYATLEASTONE"));
        }
    }
}
if($tablename !=''){
    //更新表中字段值
    $sql="update $tablename  set $columnname=? where $table_index=?";
    $adb->pquery($sql,array($value,$index_value));
}

//设置默认值,选中时去掉其他默认值
if(($type == 'option_module_default'||$type == 'templateprint_isdefault')&&$presence=='0'){
    $sql = "select tabid from $tablename where $table_index=?";
    $result = $adb->pquery($sql,array($index_value));
    $tabid = $adb->query_result($result,0,0);
    $sql = "update $tablename  set $columnname=? where $table_index<>? and tabid =?";
    $adb->pquery($sql,array($type_arr[1],$index_value,$tabid));
    $arr['tabid'] = $tabid;
}
//移动端模块列表定制-清除缓存
if(strpos($type,'cvcolumnlist_wx')>0||strpos($type,'cvcolumnlist_wx')===0){
    $sql = "select modulename from $tablename where $table_index=?";
    $result = $adb->pquery($sql,array($index_value));
    $modulename = $adb->query_result($result,0,0);
    $cachekey = 'cache_modulelist_getcvcolumnlist_' .$modulename. '_getcvcolumnlist_MC';
    unsetCacheDirOne('customview',$cachekey);
}
//工作汇报清除缓存
if(strpos($type,'workreport_field')>0||strpos($type,'workreport_field')===0){
    $cachekey = 'cache_getworkreportfieldentity';
    unsetCache($cachekey);
}
//网页端菜单定制清除缓存
if($type=='parenttab'){
    $cachekey = 'cache_getparenttabrelinfo';
    unsetCache($cachekey);
    create_tab_data_file();
    create_parenttab_data_file();
    create_parent_language();
}
//布局规则清除缓存
if($type=='fieldrule'){
    unsetCacheDirectory("fields");
}

//分录需要清除缓存
if(strpos($type,'producttoolfield')!==false){
    unsetCacheDirectory('productfields');
}else if(strpos($type,'tabdetailfield')!==false){
    unsetCacheDirectory('tabdetailfields');
}

if(!empty($presence)&&$type=='automaticreminds_status'){
    $sql='delete from ld_reminds where reminds_ruleid=? and status_rmd="未读"  ';
    $adb->pquery($sql,array($index_value));
    $sql='delete from ld_reminds_accepted where reminds_ruleid=? and status_rmd="未读"  ';
    $adb->pquery($sql,array($index_value));

}
// ljj 20240131 BUG20240130-68 kfbcrm-水印设置-修改水印显示内容后界面不会自动刷新 保存后获取数据
if ($type == 'watermark_presence'){
    if ($presence == 0){
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $watermark_txt = $MenuUtilsObj->getwatermark_setting();
        $arr['watermark_txt']=$watermark_txt;
    }else{
        $arr['watermark_txt']='';
    }
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,'success');

//根据类型获取表名、主键名、需要修改的字段名
function getTablenameBytype($type){
    //value_type, 默认是0为启用，1为不启用，可能使用yes、no，1、0相反。
    $value_type = '0,1';
    switch($type){
        case 'parenttab'://网页端菜单定制-是否启用
            $tablename = 'ld_parenttab';
            $table_index = 'parenttabid';
            $columnname = 'visible';
            break;
        case 'pagevalidata'://验证规则-是否启用
            $tablename = 'ld_validatasavemain';
            $table_index = 'id';
            $columnname = 'status';
            $value_type = 'active,inactive';
            break;
        case 'fieldrule'://布局规则-是否启用
            $tablename = 'ld_fieldrule';
            $table_index = 'id';
            $columnname = 'enablestatus';
            $value_type = 'yes,no';
            break;
        case 'appparenttab'://移动端功能菜单定制-是否启用
            $tablename = 'ld_appparenttab';
            $table_index = 'blockid';
            $columnname = 'presence';
            break;
        case 'mobile_report_parent_tab'://移动端报表菜单定制-是否启用
            $tablename = 'ld_mobile_report_parent_tab';
            $table_index = 'block_id';
            $columnname = 'presence';
            break;
        case 'watermark_presence': //水印设置是否启用
            $tablename = 'ld_watermark_setting';
            $table_index = 'id';
            $columnname = 'presence';
            $value_type = 'yes,no';
            break;
        case 'cvcolumnlist_wx_presence'://移动端模块列表定制-是否启用
            $tablename = 'ld_cvcolumnlist_wx';
            $table_index = 'id';
            $columnname = 'presence';
            break;
        case 'cvcolumnlist_wx_showtag'://移动端模块列表定制-是否显示字段名称
            $tablename = 'ld_cvcolumnlist_wx';
            $table_index = 'id';
            $columnname = 'showtag';
            $value_type = 'yes,no';
            break;
        case 'cvcolumnlist_wx_isforsearch'://移动端模块列表定制-是否根据此字段查询
            $tablename = 'ld_cvcolumnlist_wx';
            $table_index = 'id';
            $columnname = 'isforsearch';
            $value_type = 'yes,no';
            break;
        case 'fieldwxmaininfo_presence'://移动端详情界面定制定制-是否启用
            $tablename = 'ld_fieldwxmaininfo';
            $table_index = 'id';
            $columnname = 'presence';
            break;
        case 'fieldwxmaininfo_showtag'://移动端详情界面定制定制-是否显示字段名称
            $tablename = 'ld_fieldwxmaininfo';
            $table_index = 'id';
            $columnname = 'showtag';
            $value_type = 'yes,no';
            break;
        case 'option_module_presence'://签到源单类型定制-拜访签到启用
            $tablename = 'ld_option_module';
            $table_index = 'id';
            $columnname = 'presence';
            break;
        case 'option_module_default':
            $tablename = 'ld_option_module';
            $table_index = 'id';
            $columnname = '`default`';//源单类型定制-拜访签到设为默认
            $value_type = '1,0';
            break;
        case 'option_module_enablewhenadding'://源单类型定制-模块新增时启用
            $tablename = 'ld_option_module';
            $table_index = 'id';
            $columnname = 'enablewhenadding';
            $value_type = '1,0';
            break;
        case 'automaticreminds_status'://自动提醒设置-是否启用
            $tablename = 'ld_automaticreminds';
            $table_index = 'id';
            $columnname = '`status`';
            $value_type = '1,2';
            break;
        case 'templateprint_isdefault'://打印模板设置-是否启用
            $tablename = 'ld_templateprint';
            $table_index = 'templateprintid';
            $columnname = 'isdefault';
            $value_type = '1,0';
            break;
        case 'templateprint_approvedallowprint'://打印模板设置-是否审批通过后才允许打印
            $tablename = 'ld_templateprint';
            $table_index = 'templateprintid';
            $columnname = 'approvedallowprint';
            $value_type = 'yes,no';
            break;
        case 'workreport_field_active'://工作汇报模板设置-是否启用
            $tablename = 'ld_workreport_field';
            $table_index = 'id';
            $columnname = 'is_activate';
            break;
        case 'workreport_field_is_mandatory'://工作汇报模板设置-是否必填
            $tablename = 'ld_workreport_field';
            $table_index = 'id';
            $columnname = 'is_mandatory';
            break;
        case 'wx_config_switch'://企业微信客户联系设置-是否启用
            $tablename = 'ld_wx_config';
            $table_index = '`name`';
            $columnname = 'switch';
            $value_type = 'open,close';
            break;
        case 'weixinmp_listfields_presence'://服务小程序模块列表定制-是否启用
            $tablename = 'ld_weixinmp_listfields';
            $table_index = 'id';
            $columnname = 'presence';
            $value_type = '0,1';
            break;
        case 'weixinmp_listfields_showtag'://服务小程序模块列表定制-是否显示字段名称
            $tablename = 'ld_weixinmp_listfields';
            $table_index = 'id';
            $columnname = 'showtag';
            $value_type = '0,1';
            break;
        case 'weixinmp_fields_displaytype'://服务小程序详情界面定制-是否启用
            $tablename = 'ld_weixinmp_fields';
            $table_index = 'id';
            $columnname = 'displaytype';
            $value_type = 'all,createno';
            break;
        case 'weixinmp_fields_typeofdata'://服务小程序详情界面定制-是否显示字段名称
            $tablename = 'ld_weixinmp_fields';
            $table_index = 'id';
            $columnname = 'typeofdata';
            $value_type = 'm,o';
            break;
        case 'bangwo8_presence'://帮我吧接口设置-是否启用
            $tablename = 'ld_bangwo8';
            $table_index = 'id';
            $columnname = 'presence';
            break;
        case 'bangwo8_is_customer'://帮我吧接口设置-是否同步
            $tablename = 'ld_bangwo8';
            $table_index = 'id';
            $columnname = 'is_customer';
            break;
        case 'systems_smtp_ssl'://邮箱服务器设置-是否启用ssl
            $tablename = 'ld_systems';
            $table_index = 'server_type';
            $columnname = 'smtp_ssl';
            $value_type = 'yes,no';
            break;
        case 'systems_smtp_auth'://邮箱服务器设置-是否需要验证
            $tablename = 'ld_systems';
            $table_index = 'server_type';
            $columnname = 'smtp_auth';
            $value_type = 'true,false';
            break;
        case 'producttoolfield_presence'://单据分录定制-产品分录-是否启用
            $tablename = 'ld_producttoolfield';
            $table_index = 'producttoolfieldid';
            $columnname = 'presence';
            $value_type = '0,1';
            break;
        case 'producttoolfield_mandatory'://单据分录定制-产品分录-是否必填
            $tablename = 'ld_producttoolfield';
            $table_index = 'producttoolfieldid';
            $columnname = 'typeofdata';
            $value_type = 'M,O';
            break;
        case 'producttoolfield_edit_permission'://单据分录定制-产品分录-是否可编辑
            $tablename = 'ld_producttoolfield';
            $table_index = 'producttoolfieldid';
            $columnname = 'edit_permission';
            $value_type = '0,1';
            break;
        case 'producttoolfield_mobiledetailshow'://单据分录定制-产品分录-是否显示在移动端明细列表
            $tablename = 'ld_producttoolfield';
            $table_index = 'producttoolfieldid';
            $columnname = 'mobiledetailshow';
            $value_type = 'yes,no';
            break;
        case 'tabdetailfield_presence'://单据分录定制-普通分录-是否启用
            $tablename = 'ld_tabdetailfield';
            $table_index = 'tabdetailfieldid';
            $columnname = 'presence';
            $value_type = '0,1';
            break;
        case 'tabdetailfield_mandatory'://单据分录定制-普通分录-是否必填
            $tablename = 'ld_tabdetailfield';
            $table_index = 'tabdetailfieldid';
            $columnname = 'typeofdata';
            $value_type = 'M,O';
            break;
        case 'tabdetailfield_edit_permission'://单据分录定制-普通分录-是否可编辑
            $tablename = 'ld_tabdetailfield';
            $table_index = 'tabdetailfieldid';
            $columnname = 'edit_permission';
            $value_type = '0,1';
            break;
        case 'tabdetailfield_mobiledetailshow'://单据分录定制-普通分录-移动端明细是否显示
            $tablename = 'ld_tabdetailfield';
            $table_index = 'tabdetailfieldid';
            $columnname = 'mobiledetailshow';
            $value_type = 'yes,no';
            break;
        case 'loginsettings'://登录界面自定义设置
            $value_type = 'yes,no';
            break;
        case 'approvestep_alloweditbill': //审批步骤-是否允许编辑单据
            $tablename = 'ld_approvestep';
            $table_index = 'id';
            $columnname = 'alloweditbill';
            $value_type = 'yes,no';
            break;
        case 'approvestep_ended': //审批步骤-是否允许结束审批流程
            $tablename = 'ld_approvestep';
            $table_index = 'id';
            $columnname = 'ended';
            $value_type = '0,1';
            break;
        case 'approvestep_step': //审批步骤-是否允许指定审批步骤
            $tablename = 'ld_approvestep';
            $table_index = 'id';
            $columnname = 'step';
            $value_type = '0,1';
            break;
        case 'approvestep_augmentsinger': //审批步骤-是否允许加签
            $tablename = 'ld_approvestep';
            $table_index = 'id';
            $columnname = 'augmentsinger';
            $value_type = 'yes,';
            break;
        case 'approvestep_specifyapproverid': //审批步骤-是否允许编辑单据
            $tablename = 'ld_approvestep';
            $table_index = 'id';
            $columnname = 'specifyapproverid';
            $value_type = '0,1';
            break;
        case 'smstemplate_status': //短信模板-是否启用
            $tablename = 'ld_smstemplates';
            $table_index = 'templateid';
            $columnname = 'deleted';
            $value_type = '0,1';
            break;
        default:
            $value_type = 'none';
            break;

    }
    if($value_type == 'none'){
        return array();
    }else{
        return array('tablename'=>$tablename,'table_index'=>$table_index,'columnname'=>$columnname,'value_type'=>$value_type);
    }
}
//保存登录页面自定义设置是否开启
function loginsetting_save($index_name,$isshow){
    global $current_user;
    $languageType= getLanguageType($current_user);
    global $versions;
    require_once(globalStatic::$root_directory."Register/RegOp.php");
    if(file_exists(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
        require_once(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php");
    }else{
        require_once(globalStatic::$root_directory."include/language/zh_cn_version.lang.php");
    }
    require(globalstatic::$root_directory."dataCache/Login/LoginSettingsInfo.php");
    $reg=RegOp::getInstance();
    $VersionNo=$reg->GetVersionNo();
    //网站标题
    if($index_name == 'browse_title'){
        $versions[$VersionNo]['titleisshow'] = $isshow;
        //重新生成标题文件
        $strtitle='<?php'.PHP_EOL;
        $strtitle.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
        $strtitle.=' $versions=array(';
        foreach($versions as $tmpno=>$content)
        {
            $strtitle.=$tmpno.'=>array("lblversion"=>"'.$content['lblversion'].'",'.PHP_EOL;
            $strtitle.='"LBL_BROWSER_TITLE"=>"'.$content['LBL_BROWSER_TITLE'].'",'.PHP_EOL;
            $strtitle.='"EN_LBL_BROWSER_TITLE"=>"'.$content['EN_LBL_BROWSER_TITLE'].'",'.PHP_EOL;
            $strtitle.='"Version"=>"'.$content['Version'].'",'.PHP_EOL;
            if($tmpno==$VersionNo)
            {
                $strtitle.='"titleisshow"=>"'.$versions[$VersionNo]['titleisshow'].'",'.PHP_EOL;

                $strtitle.='"after_zh_title"=>"'.$versions[$VersionNo]['after_zh_title'].'",'.PHP_EOL;
                $strtitle.='"after_en_title"=>"'.$versions[$VersionNo]['after_en_title'].'",'.PHP_EOL;

            }
            $strtitle.="),".PHP_EOL;
        }
        $strtitle.=PHP_EOL;

        $strtitle.=");".PHP_EOL;
        $strtitle.="?>";

        file_put_contents(globalStatic::$root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$strtitle);
        //edit:duan reason:49432：网站标题更改不生效
        if(function_exists("opcache_reset"))
            opcache_invalidate(globalStatic::$root_directory.'dataCache/Login/zh_cn_version_new.lang.php',true);
        return ;
    }else if($index_name == 'login_wxbtn'){
        $global_login_wxbtn['isshow'] = $isshow;
    }else if(strpos($index_name,'loginpageurl')===0 || strpos($index_name,'loginpageurl')>0){
        $name_arr = explode('_',$index_name);
        $global_loginpage_url[$name_arr[1]]['isshow'] = $isshow;
    }else{
        $global_logininfo[$index_name]['isshow'] = $isshow;
    }

    $str=" <?php \n";
    $str.=' $global_logininfo=array( ';
    foreach($global_logininfo as $key=>$item)
    {
        $str.="  '$key'=>array('zh'=>'".$item['zh'].'\','."'en'=>'".$item['en']."'";

        if(array_key_exists("isshow",$item))
        {
            $str.=",'isshow'=>";
            if($item['isshow']=='yes')
            {
                $str.="'yes'";
            }
            else
            {
                $str.="'no'";
            }
        }
        if(array_key_exists("isedit",$item))
        {
            $str.=",'isedit'=>";
            if($item['isedit']=='yes')
            {
                $str.="'yes'";
            }
            else
            {
                $str.="'no'";
            }
        }
        $str.=",'content'=>'".$item['content']."'";
        $str.="),\n\n";

    }
    $str.=");\n\n";

    $str.=PHP_EOL;
    foreach($global_loginpage_url as $index=>$content)
    {
        $str.=' $global_loginpage_url['.$index.']=array("zh"=>"'.$content['zh'].'","en"=>"'.$content['en'].'"';
        $str.=",'isshow'=>";
        if($content['isshow']=='yes')
        {
            $str.="'yes'";
        }
        else
        {
            $str.="'no'";
        }
        $str.=",'isedit'=>'".$content['isedit']."'";
        $str.=",'content'=>'".$content['content']."'";
        $str.=",'url'=>'".$content['url']."'";
        $str.=");".PHP_EOL;
    }
    $str.=PHP_EOL;
    $str.='   $global_welcome=array("zh"=>"'.$global_welcome['zh']
        .'","en"=>"'.$global_welcome['en'] ;

    //zkt 20220525 52119（https://81mis.com/kfbtest/index.php）关闭企业微信登录后，登录欢迎语不显示了（需补丁）
    if(!isset($global_welcome['after_zh_content'])){
        $global_welcome['after_zh_content'] = $global_welcome['zh'];
    }
    $str.='","after_zh_content"=>"'.$global_welcome['after_zh_content'];

    if(array_key_exists('after_en_content',$global_welcome)){
        $str.='","after_en_content"=>"'.$global_welcome['after_en_content'];
    }
    else{
        $str.='","after_en_content"=>"'.$global_welcome['en'];
    }

    $str.='","updateexplain"=>"'.$global_welcome['updateexplain']
        .'","showloginweixinbtn"=>"'.$global_welcome['showloginweixinbtn']
        .'","beginyear"=>"'.$global_welcome['beginyear'].'");';

    $str.=PHP_EOL;
    $str.='$global_login_wxbtn=array("zh"=>"企业微信登录","en"=>"WeChat login",';
    if($global_login_wxbtn['isshow']=='yes')
        $str.='"isshow"=>"yes",';
    else
        $str.='"isshow"=>"no",';

    //zkt 20220525  52119（https://81mis.com/kfbtest/index.php）关闭企业微信登录后，登录欢迎语不显示了（需补丁）
    global $global_login_wxbtn;
    if(empty($global_login_wxbtn))
    {
        $global_login_wxbtn=array('zh'=>"企业微信登录",'en'=>"WeChat login",'isshow'=>'yes','after_en_content'=>"WeChat login","after_zh_content"=>"企业微信登录");
    }
    $str.='"after_zh_content"=>"'.$global_login_wxbtn['after_zh_content'].'",';
    if($global_login_wxbtn['after_en_content']!='')
    {
        $str.='"after_en_content"=>"'.$global_login_wxbtn['after_en_content'].'"';
    }
    $str.=");".PHP_EOL;
    $str.="\n\n?>";

    file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',$str);
    if(function_exists('opcache_invalidate'))
        opcache_invalidate(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',true);



}

?>