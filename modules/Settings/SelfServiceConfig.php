<?php
global $adb,$current_user,$PlatformMC;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
require(globalStatic::$root_directory.'weixinmp/include/cls_MP_CommonFun.php');
require(globalStatic::$root_directory.'modules/Settings/SelfServiceConfig/SelfServiceConfigModel.php');
require_once (globalStatic::$root_directory.'weixinmp/static_const_mp.php');
//editor:gyq_108 reason:订单小程序  2019/4/15 17:31  selftype=service order
$selftype = $_REQUEST['selftype'];
if(empty($selftype))
    $selftype = 'service';
//************服务、订单自助小程序界面翻译、参数区分*begin************
$interface_name = array('service'=>'weixinmp_bindtype','demo_service'=>'weixinmp_bindtype',
    'order'=>'ordermp_bindtype','demo_order'=>'ordermp_bindtype');
$interface_module = array('service'=>'HelpDesk,Equipment','order'=>'SalesOrder');
$interface_module_reverse = array('service'=>'SalesOrder','order'=>'HelpDesk,WorkSheet');
$CUSTOMERSELFSERVICECONFIG01 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG01'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG01ORDER'));
$CUSTOMERSELFSERVICECONFIGHOME06 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME06'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME06ORDER'));
$CUSTOMERSELFSERVICECONFIGHOME07 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME07'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME07ORDER'));
$CUSTOMERSELFSERVICECONFIGHOME08 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME08'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME08ORDER'));
$CUSTOMERSELFSERVICECONFIGHOME09 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIGHOME09'));
$CUSTOMERSELFSERVICECONFIG02 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG02'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG02ORDER'));
$CUSTOMERSELFSERVICECONFIG04 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG04'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG04ORDER'));
$CUSTOMERSELFSERVICECONFIG03 = array(
    'service'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG03'),
    'order'=>getFixedLabel('CUSTOMERSELFSERVICECONFIG03ORDER'));

//************服务、订单自助小程序界面翻译区分*end************
$smarty = new lingdangCRM_Smarty;
$model_selfconfig = new SelfServiceConfigModel();
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$smarty->assign("PlatForm",$platform);
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='true'){
    $type = $_REQUEST['type'];
    $from = $_REQUEST['from'];
    $module = $_REQUEST['frommodule'];
    if(!empty($module) && $module != 'undefined')
        $focus = CRMEntity::getInstance($module);
    //BUG0075330 后台设置--服务小程序设置--模块设置--服务小程序模块设置--排序方式修改为拖拽排序 20231117
    //保存模块设置
    if ($type == 'saveModuleSet') {
        if (!empty($_REQUEST['tagids'])) {
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_weixinmp_module set sequence = ? where id = ?', array($sequence, $id));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
    else if ($type == 'saveModuledetailSet') {
        if (!empty($_REQUEST['tagids'])) {
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_weixinmp_fields set sequence = ? where id = ?', array($sequence, $id));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
    //字段类型处理
    if($from=='field'){
        $fieldid = $_REQUEST['field_id'];
        if($type=='delete'){
            //删除通用字段时删除列表字段
            $model_selfconfig->field_action_delete($fieldid,$module);
            $ajaxhtml = 1;
        }elseif($type=='moveup'){
            $model_selfconfig->field_action_move_up($fieldid);
        }elseif($type=='movedown'){
            $model_selfconfig->field_action_move_down($fieldid);
        }elseif($type=='edit'){
            require_once( globalStatic::$root_directory.'modules/PickList/PickListUtils.php');

            $allFields = $model_selfconfig->field_action_edit($fieldid,$module);
            if(!empty($fieldid)){
                $tabid = getTabid($module);
                $allPresenceField = $focus->fieldobj->getModuleAllPreseneceFields();
                //liushuai 20230518 XUQIU1001398 服务小程序，增加英文版(后台模块设置/详情页设置)
                $query = 'select fieldname,tabletype,fieldlabel,fieldlabel_en,displaytype,typeofdata,defaultvalue from ld_weixinmp_fields where id=?';
                $result = $adb->pquery($query,array($fieldid));
                $mainfieldname = $adb->query_result($result,0,'fieldname');
                $fieldlabel = $adb->query_result($result,0,'fieldlabel');
                $fieldlabel_en = $adb->query_result($result,0,'fieldlabel_en');
                $displaytype = $adb->query_result($result,0,'displaytype');
                $tabletype = $adb->query_result($result,0,'tabletype');
                $typeofdata = $adb->query_result($result,0,'typeofdata');
                $defaultvalue = $adb->query_result($result,0,'defaultvalue');
                if($tabletype=='main'){
                    $fieldinfo = $allPresenceField[$mainfieldname];
                    $uitype = $fieldinfo->getUIType();
                    $bigtype = $fieldinfo->getBigType();
                    if($uitype==53||$fieldinfo->getDisplayType()==2||in_array($mainfieldname,array('quantity','productname','hdnGrandTotal'))) $editable = 'no';//看不懂干啥的,tpl也没有用上，改造一下，表示编辑时属性不可编辑
                    // 下拉框字段
                    $picklistvalues = array();
                    if($bigtype == 'picklist'){
                        $picklistvalues[''] = getFixedLabel('CAMCARDNONE');
                        //获取下拉框值
                        $picklistvalues = array_merge($picklistvalues,getAllPickListValues($mainfieldname));
                    }
                }
            }else{
                foreach ($allFields as $index => $infos) {
                    $picklistvalues = array();
                    if($infos['bigtype'] == 'picklist'){
                        $picklistvalues[''] = getFixedLabel('CAMCARDNONE');
                        //获取下拉框值
                        $picklistvalues = array_merge($picklistvalues,getAllPickListValues($infos['fieldname']));
                        $picklistvalues_arr[$infos['fieldname']] = $picklistvalues;
                    }
                }
                $arr['picklistvalues_arr'] = $picklistvalues_arr;
            }
            $smarty->assign('FIELDID',$fieldid);
            $smarty->assign('FIELDNAME',$mainfieldname);
            $smarty->assign('TABLETYPE',$tabletype);
            $smarty->assign('FIELDLABEL',$fieldlabel);
            $smarty->assign('FIELDLABELEN',$fieldlabel_en);
            $smarty->assign('DISPLAYTYPE',$displaytype);
            $smarty->assign('TYPEOFDATA',$typeofdata);
            $smarty->assign('DEFAULTVALUE',$defaultvalue);
            $smarty->assign('ALLFIELDS',$allFields);
            $smarty->assign('FROMMODULE',$module);
            $smarty->assign('FROM','field');
            $smarty->assign('UITYPE',$uitype);
            $smarty->assign('BIGTYPE',$bigtype);
            $smarty->assign('EDITABLE',$editable);
            $smarty->assign('PickListValues',$picklistvalues);
            $smarty->assign('CUSTOMERSELFSERVICECONFIG03',$CUSTOMERSELFSERVICECONFIG03[$selftype]);

            $arr['title'] = $CUSTOMERSELFSERVICECONFIG03[$selftype];
            $arr['oktext']=getFixedLabel("SAVE");
            $arr['canceltext']=getFixedLabel("CANCEL");
            $str=$smarty->fetch("Settings/SelfServiceConfig_create.tpl");
            $arr['content']=$str;
            ConvertTojsonString(1,$arr,"success");

            exit;
        }elseif($type=='save'){
            $sql = 'select 1 from ld_weixinmp_fields where fieldname=? and modulename=? ';
            if(!empty($fieldid)) $sql .= ' and id !='.$fieldid;
            $result = $adb->pquery($sql,array($_REQUEST['fieldname'],$module));
            if($adb->num_rows($result)){
                echo 'error';exit;
            }
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$_REQUEST['fieldname']);
            if(!empty($fieldinfo)){
                //只读字段控制新增界面不显示
                if($fieldinfo->getDisplaytype()==2) $_REQUEST['displaytype']='createno';
            }//BUG20240716-46 详情定制至少显示一个字段
            $sql = "select * from ld_weixinmp_fields where fieldname = ?";
            $result = $adb->pquery($sql,array($_REQUEST['fieldname']));
            if ($result->fields["displaytype"] == "all" && $_REQUEST["displaytype"] == "createno") {
                $sql = 'select 1 from ld_weixinmp_fields where modulename=? and displaytype <> "createno"';
                $result = $adb->pquery($sql, array($module));
                if ($adb->num_rows($result) < 2) {
                    ConvertTojsonString(-1, array(), "Display at least one field");
                }
            }
            if(!empty($fieldid)){
                $query = 'update ld_weixinmp_fields set fieldname=?,tabletype=?,fieldlabel=?,fieldlabel_en=?,displaytype=?,typeofdata=?,defaultvalue=? where id=?';
                $adb->pquery($query,array($_REQUEST['fieldname'],$_REQUEST['tabletype'],$_REQUEST['fieldlabel'],trim($_REQUEST['fieldlabel_en']),$_REQUEST['displaytype'],$_REQUEST['typeofdata'],$_REQUEST['defaultvalue'],$fieldid));
            }else{
                $sequence = $adb->query_result($adb->pquery('select max(sequence) from ld_weixinmp_fields where modulename=?',array($module)),0,0);
                $query = 'insert into ld_weixinmp_fields(modulename,fieldname,tabletype,fieldlabel,fieldlabel_en,displaytype,typeofdata,defaultvalue,sequence) values(?,?,?,?,?,?,?,?,?)';
                $adb->pquery($query,array($module,$_REQUEST['fieldname'],$_REQUEST['tabletype'],$_REQUEST['fieldlabel'],trim($_REQUEST['fieldlabel_en']),$_REQUEST['displaytype'],$_REQUEST['typeofdata'],$_REQUEST['defaultvalue'],$sequence+1));
            }
        }
        ResetSequence($module);
        $html = getMpFieldsHtml(getMpModuleFields($module));
    }elseif($from=='listfield'){//列表字段类型处理
        $listfieldid = $_REQUEST['listfield_id'];
        if($type=='delete'){
            $adb->pquery('delete from ld_weixinmp_listfields where id=?',array($listfieldid));
        }elseif($type=='edit'){
            if(!empty($listfieldid)){
                $query = 'select rownumber,listnumber,fieldname,presence,showtag from ld_weixinmp_listfields where id = ?';
                $result = $adb->pquery($query,array($listfieldid));
                $rownumber = $adb->query_result($result,0,'rownumber');
                $listnumber = $adb->query_result($result,0,'listnumber');
                $fieldname = $adb->query_result($result,0,'fieldname');
                $presence = $adb->query_result($result,0,'presence');
                $showtag = $adb->query_result($result,0,'showtag');
            }
            $allFields = $model_selfconfig->getModuleDisplayFields($module,$listfieldid,'ld_weixinmp_listfields');
            $smarty->assign('LISTFIELDID',$listfieldid);
            $smarty->assign('FIELDNAME',$fieldname);
            $smarty->assign('LINENUMBER',$rownumber);
            $smarty->assign('ROWNUMBER',$listnumber);
            $smarty->assign('PRESENCE',$presence);
            $smarty->assign('SHOWTAG',$showtag);
            $smarty->assign('ALLFIELDS',$allFields);
            $smarty->assign('FROMMODULE',$module);
            $smarty->assign('FROM','listfield');
            $smarty->assign('CUSTOMERSELFSERVICECONFIG04',$CUSTOMERSELFSERVICECONFIG04[$selftype]);
            $arr['title'] = $CUSTOMERSELFSERVICECONFIG04[$selftype];
            $arr['oktext']=getFixedLabel("SAVE");
            $arr['canceltext']=getFixedLabel("CANCEL");
            $str=$smarty->fetch("Settings/SelfServiceConfig_create.tpl");
            $arr['content']=$str;
            ConvertTojsonString(1,$arr,"success");

            exit;
        }elseif($type=='save'){
            $sql = 'select 1 from ld_weixinmp_listfields where modulename=? and rownumber=? and listnumber=? ';
            if(!empty($listfieldid)) $sql .= ' and id !='.$listfieldid;
            $result = $adb->pquery($sql,array($module,$_REQUEST['linenumber'],$_REQUEST['rownumber']));
            if($adb->num_rows($result)){
                echo 'error';exit;
            }
            //BUG20240716-46 wsh 2024-08-06 后台设置->服务小程序->列表定制，将所有字段设置为不显示，移动端服务小程序只显示一行空白（服务小程序中的“详情定制”也有这个问题，应改为至少一个字段的“是否显示”按钮为开启状态
            $sql = "select * from ld_weixinmp_listfields where fieldname = ?";
            $result = $adb->pquery($sql,array($_REQUEST['fieldname']));
            if ($result->fields["presence"] == 0 && $_REQUEST["presence"] == 1){
                $sql = 'SELECT 1 from ld_weixinmp_listfields where modulename = ? and presence <> 1';
                $result = $adb->pquery($sql,array($_REQUEST["frommodule"]));
                $num_rows = $adb->num_rows($result);
                if($num_rows < 2){
                    ConvertTojsonString(-1,array(),"Display at least one field");
                }
            }
            if(!empty($listfieldid)){
                $query = 'update ld_weixinmp_listfields set fieldname=?,rownumber=?,listnumber=?,presence=?,showtag=? where id=?';
                $adb->pquery($query,array($_REQUEST['fieldname'],$_REQUEST['linenumber'],$_REQUEST['rownumber'],$_REQUEST['presence'],$_REQUEST['showtag'],$listfieldid));
            }else{
                $query = 'insert into ld_weixinmp_listfields(modulename,rownumber,listnumber,fieldname,presence,showtag) values(?,?,?,?,?,?)';
                $adb->pquery($query,array($module,$_REQUEST['linenumber'],$_REQUEST['rownumber'],$_REQUEST['fieldname'],$_REQUEST['presence'],$_REQUEST['showtag']));
            }
        }
        $html = getMpListFieldsHtml(getMpModuleListFields($module));
    }elseif($from=='module'){//模块类型处理
        if($type=='save'){
            $jsonentity = $_REQUEST['jsonentity'];
            $mpmodules = json_decode($jsonentity,true);
            foreach($mpmodules as $key=>$val){
                $adb->pquery('update ld_weixinmp_module set mplabel=?,mplabel_en=?,sequence=? where id=?',array($val['value'],$val['en_value'],$key+1,$val['name']));
            }
            $_REQUEST['diony']='diony';
            ConvertTojsonString(1,array(),"success");
        }elseif($type=='active'){
            $moduleid = $_REQUEST['moduleid'];
            $adb->pquery('update ld_weixinmp_module set presence = !presence where id=?',array($moduleid));
            $presence = $adb->query_result($adb->pquery('select presence from ld_weixinmp_module where id=?',array($moduleid)),0,0);
            echo '##'.($presence?getFixedLabel('ACTIVATE'):getFixedLabel('INACTIVATE')).'##'.($presence?getFixedLabel('NO'):getFixedLabel('YES'));exit;
        }
    }elseif($from=='set'){//设置类型处理,允许查询绑定客户的所有服务记录
        // wsh 20240807 XUQIU20240725-02 服务小程序登录页设置--增加首页横幅图片设置
        $uploaddir = $root_directory ."/dataCache/test/logo/" ;
        $file = new SplFileInfo($_FILES["weiXinMp_banner_img"]["name"]);
        $weiXinMp_banner_img_url =  'banner_image' . '.' . $file->getExtension();
        $banner_img_url = "dataCache/test/logo/" . $weiXinMp_banner_img_url;
        move_uploaded_file($_FILES["weiXinMp_banner_img"]["tmp_name"], $uploaddir . $weiXinMp_banner_img_url);
        $viewall = $_REQUEST['viewall']=='yes'?'yes':'no';
        $query = 'update ld_weixinmp_set set viewall=? where modulename=?';
        $adb->pquery($query,array($viewall,$module));
        if($_REQUEST['weixinmp_switchtype'] == 'Register'){//初始化界面是注册界面时，手机字段和允许创建存为空
            $_REQUEST['phonefield'] = '';
            $_REQUEST['weixinmp_allowcreate'] = '';
        }
        $query_sel = 'select para_content from ld_wx_config where name=?';
        $result_sel = $adb->pquery($query_sel, array($interface_name[$selftype]));
        $para_content = $adb->query_result($result_sel, 0, 'para_content');
        $tmp_para_content = ldcrm_json_decode(html_entity_decode($para_content));
        $tmp_para_content['bindtype'] = $_REQUEST['weixinmp_bindtype'];
        $tmp_para_content['allowedtocreate'] = $_REQUEST['weixinmp_allowcreate'];
        $tmp_para_content['useverificationcode'] = $_REQUEST['weixinmp_usecode'];
        if ($_FILES["weiXinMp_banner_img"]["name"] != null){
            $tmp_para_content['banner_url'] = $banner_img_url;
        }
        $para_content = ldcrm_json_encode($tmp_para_content);
        $query = 'update ld_wx_config set switch=?,para_one=?,para_content=?,para_two=? where name=?';
        $adb->pquery($query,array($_REQUEST['weixinmp_switchtype'],$_REQUEST['phonefield'],$para_content,$_REQUEST['phonefield_frommodule'],$interface_name[$selftype]));

        if ($platform == 'aliyun') {
            $templateid=$_REQUEST['smstemplateid']??'';
            $adb->pquery("delete from ld_smsrelated where scene=?",array("weixinmp_bindtype_verifycode"));//不启用就删掉

            if (!empty($templateid)) {
                $smsdetail_arr = $cls_Send_MassSms->getSmsTemplateById($templateid);
                if (is_array($smsdetail_arr) && count($smsdetail_arr)>0) {
                    $templateparamconf = $smsdetail_arr['templateparaminfo'];

                    $cls_Send_MassSms->insertSmsRelated("ld_smstemplates", $templateid, '', $templateid, $templateparamconf, "weixinmp_bindtype_verifycode");
                }
            }

        }

        $_REQUEST['diony']='diony';
        ConvertTojsonString(1,array(),"success");
    }elseif($from=='bindtype'){//设置类型处理,允许查询绑定客户的所有服务记录
        $phonelistfield = cls_MP_CommonFun::getPhoneField('', $_REQUEST['bindtype']);
        $phonelisthtml = '';
        if($_REQUEST['bindtype'] == 'Accounts'){
            $bindtypefield = getTranstab('Accounts');
            foreach ($phonelistfield as $key=>$val){
                $phonelisthtml .= '<option value="'.$val['value'].'" fieldfrom="'.$_REQUEST['bindtype'].'"  '.$val['selected'].'>'.$bindtypefield.'-'.$val['label'].'</option>';
            }
            $_REQUEST['bindtype'] = 'Contacts';
            $phonelistfield = cls_MP_CommonFun::getPhoneField('', $_REQUEST['bindtype']);
            $bindtypefield = getTranstab('Contacts');
            foreach ($phonelistfield as $key=>$val){
                $phonelisthtml .= '<option value="'.$val['value'].'" fieldfrom="'.$_REQUEST['bindtype'].'" '.$val['selected'].'>'.$bindtypefield.'-'.$val['label'].'</option>';
            }
        }else{
            $bindtypefield = getTranstab('Contacts');
            foreach ($phonelistfield as $key=>$val){
                $phonelisthtml .= '<option value="'.$val['value'].'" fieldfrom="'.$_REQUEST['bindtype'].'" '.$val['selected'].'>'.$bindtypefield.'-'.$val['label'].'</option>';
            }
        }

        echo $phonelisthtml;
        exit;
    }
    if($from!='field'||$type!='delete'){
        echo $html;exit;
    }
}
$modulename_array = explode(',',$interface_module_reverse[$selftype]);
$modulename = "'" . implode("','",$modulename_array) . "'";
$sql = 'select DISTINCT modulename from ld_weixinmp_set where modulename not in ('.$modulename.')';
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
for($i=0;$i<$num_rows;$i++){
    $selectmodules[] = $adb->query_result($result,$i,'modulename');
}
$selectmodule = $selectmodules[0];
//切换模块或者删除字段时，要将三部分Html都返回
if($_REQUEST['type']=='changemodule'||($from=='field'&&$type=='delete')){
    $selectmodule = $_REQUEST['frommodule'];
    $ajaxhtml = 1;
}

$mpmodulefileds = getMpModuleFields($selectmodule);
$mpfieldshtml = getMpFieldsHtml($mpmodulefileds);
//列表定制
if ($_REQUEST['step']=='modulelist'){
    $selectmodule = $selectmodules[0];
}
$mpmodulelistfields = getMpModuleListFields($selectmodule,$mpmodulefileds);
$mplistfieldshtml = getMpListFieldsHtml($mpmodulelistfields);
$viewallhtml = getMpViewAllHtml($selectmodule);
if($ajaxhtml){
    echo $viewallhtml.'$$$##$$$'.$mpfieldshtml.'$$$##$$$'.$mplistfieldshtml;exit;
}
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
//editor:gyq_104 reason:小程序设置优化  2019/3/4 17:48 
$smarty->assign('SelfServiceConfig_Step', $_REQUEST['step']);
$smarty->assign('LANGUAGETYPE',$languageType);
/*****首页设置 begin*****/
//editor:gyq_108 reason:订单小程序  2019/4/15 15:37
//***************登陆设置******************
if($_REQUEST['step']=='login') {
    //editor:gyq_20190919
    //0038127: （51mis.com/kfbcrm）系统设置>服务小程序设置、订单小程序设置：当设置了小程序企业号后，截图红框处的提示应该不显示。
    //wyt_220719_XUQIU1000433  增加“服务小程序绑定微信公众号密钥”参数
    $sql = 'select switch,para_one,para_two,para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
    $result = $adb->pquery($sql, array());
    $para_three=$adb->query_result($result,0,'para_three');
    $usid=1;
    $wechat_keys = 'coid='.$adb->query_result($result,0,'para_three').'&usid=';//企业号主键ID
    $wechat_keys .=$usid;
    $wechat_keys=urlencode($wechat_keys);
    $smarty->assign('WECHAT_KEYS_OUT', $wechat_keys);

    $wechat_miniprogram_setting = '';
    if($adb->num_rows($result) > 0){
        $wechat_miniprogram_setting = $adb->query_result($result, 0, 'para_one');
    }
    $smarty->assign('MINIPROGRAM_SETTING', $wechat_miniprogram_setting);
    $sql = 'select switch,para_one,para_content from ld_wx_config where name=?';
    $result = $adb->pquery($sql, array($interface_name[$selftype]));

    $switchtype = $adb->query_result($result, 0, 'switch');
    $orign_bindfield = $adb->query_result($result, 0, 'para_one');
    $para_content = $adb->query_result($result, 0, 'para_content');
    $para_content = Zend_Json::decode($para_content);
    $bindtype = $para_content['bindtype'];
    $allowedtocreate = $para_content['allowedtocreate'];
    $useverificationcode = $para_content['useverificationcode'];
    // wsh 20240807 XUQIU20240725-02 服务小程序登录页设置--增加首页横幅图片设置
    $banner_url = $para_content['banner_url'];
    // 2024-10-25 增加默认图片，防止显示破裂图片
    if(empty($banner_url) || !file_exists($banner_url)){
        $banner_url = "dataCache/test/logo/banner_image_default.jpg";
    }
    $smarty->assign('BANNERIMAGEURL', $banner_url . '?a=' . uniqid());
    //editor:gyq_20190424 reason:旧设置数据兼容(未设置过的，数据表默认字段值是open)
    $default_bindtype = cls_MP_CommonFun::default_bindtype($switchtype,$orign_bindfield,$interface_name[$selftype]);
    $weixinmp_bindtype_switch = $default_bindtype['type'];
    $weixinmp_columname = $default_bindtype['field'];

    //小程序初始化首页设置
    $weixinmp_bindtype_arr = array(
        'Login' => array('value' => 'Login', 'label' =>
            getFixedLabel('LBL_TO_LOGIN') . getFixedLabel('INTERFACE'), 'selected' => ''),
        'Register' => array('value' => 'Register', 'label' =>
            getFixedLabel('CELLREGISTER') . getFixedLabel('INTERFACE'), 'selected' => ''),
    );
    foreach ($weixinmp_bindtype_arr as $key => $value) {
        if ($key == $weixinmp_bindtype_switch) {
            $weixinmp_bindtype_arr[$key]['selected'] = 'selected';
            // if($key == 0){
            //     $switchtype_validation = getFixedLabel('LBL_TO_LOGIN');
            // }else{
            //     $switchtype_validation = getFixedLabel('CELLREGISTER');
            // }
            // break;
        }
    }
    $bindtype_arr = array(
        'Accounts' => array('value' => 'Accounts', 'label' => getTranstab('Accounts'), 'selected' => ''),
        'Contacts' => array('value' => 'Contacts', 'label' => getTranstab('Contacts'), 'selected' => ''),
    );
    foreach ($bindtype_arr as $key => $value) {
        if ($key == $bindtype) {
            $bindtype_arr[$key]['selected'] = 'selected';
            if($key == "Accounts"){
                $bindtype_field[0] = getTranstab('Accounts');//BUG0071433 xxy 2023-8-22 当绑定对象为客户时，需要同时带出客户和联系人的电话手机字段
                $bindtype_field[1] = getTranstab('Contacts');
                $bindtype_field_frommodule[0] = 'Accounts';
                $bindtype_field_frommodule[1] = 'Contacts';
            }else{
                $bindtype_field[0] = getTranstab('Contacts');
                $bindtype_field_frommodule[0] = 'Contacts';
            }
            break;
        }
    }
    $smarty->assign('SWITCHTYPE', $switchtype);
    $smarty->assign('BINDTYPE', $bindtype);
    $smarty->assign('BINDTYPEARR', $bindtype_arr);
    // $smarty->assign('SWITCHTYPEVAILD', $switchtype_validation);
    $smarty->assign('BINDTYPEFIELD', $bindtype_field);
    $smarty->assign('BINDTYPEFIELDFROM', $bindtype_field_frommodule);
    $smarty->assign('ALLOWEDTOCREATE', $allowedtocreate);
    $smarty->assign('USECODE', $useverificationcode);
    $smarty->assign('MPBINDTYPEARR', $weixinmp_bindtype_arr);
    //登录手机号码绑定字段
    if ($bindtype == 'Accounts') {
        $phonelistfield[0] = cls_MP_CommonFun::getPhoneField($weixinmp_columname, $bindtype);
        $phonelistfield[1] = cls_MP_CommonFun::getPhoneField($weixinmp_columname, 'Contacts');
        $smarty->assign('MPBINDTYPEPHONEFIELD', $phonelistfield);
    }else if($bindtype == 'Contacts'){
        $phonelistfield[0] = cls_MP_CommonFun::getPhoneField($weixinmp_columname, $bindtype);
        $smarty->assign('MPBINDTYPEPHONEFIELD', $phonelistfield);
    }
    include globalStatic::$root_directory.'weixinmp/modules/Users/mini_get_qrcode.php';
    $smarty->assign('QRCODEIMAGE', $imgsrc);
    $smarty->assign('SELFTYPE', $selftype);
    $smarty->assign('CUSTOMERSELFSERVICECONFIGHOME09', $CUSTOMERSELFSERVICECONFIGHOME09[$selftype]);
    $smarty->assign('CUSTOMERSELFSERVICECONFIGHOME08', $CUSTOMERSELFSERVICECONFIGHOME08[$selftype]);
    $smarty->assign('CUSTOMERSELFSERVICECONFIGHOME07', $CUSTOMERSELFSERVICECONFIGHOME07[$selftype]);
    $smarty->assign('CUSTOMERSELFSERVICECONFIGHOME06', $CUSTOMERSELFSERVICECONFIGHOME06[$selftype]);
    $smarty->assign('CUSTOMERSELFSERVICECONFIG01', $CUSTOMERSELFSERVICECONFIG01[$selftype]);//系统设置 > 服务小程序登录首页设置

    $smsTemplate_arr = [];
    if ($platform == 'aliyun') {
        //获取是否已设置短信模板
        $smsdetail_arr = $cls_Send_MassSms->getSmsRelatedByScene($platform,"crmlogin_verifycode");
        $select_tempplateid = '';
        if(count($smsdetail_arr)>0){
            $select_tempplateid = $smsdetail_arr['templateid'];
        }

        $smsTemplate_arr = $cls_Send_MassSms->getSmsTemplatePresenceSingleVerifyCode($platform);
    }
    $smarty->assign("SmsTemplateList",$smsTemplate_arr);//启用的短信模板列表

    //获取帮助手册入口链接，为空则不显示
    //可能有多个帮助链接需要获取
    $helpHtmlArr = array();
    //服务小程序登录首页设置帮助
    $labels = array('SelfServiceConfigHome');
    foreach($labels as $label){
        $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
    }
    $smarty->assign("HelpHtml", $helpHtmlArr);

    $arr['content']= $smarty->fetch('Settings/wechat_miniprogram/SelfServiceConfig_Home.tpl');
    ConvertTojsonString(1,$arr,"success");
}elseif ($_REQUEST['step']=='module'){
    //************模块设置*************
    $modulename_array = explode(',',$interface_module[$selftype]);
    $modulename = "'" . implode("','",$modulename_array) . "'";
    $query = 'select id,modulename,type,mplabel,mplabel_en,presence from ld_weixinmp_module where modulename in ('.$modulename.') order by sequence';

    $result = $adb->pquery($query,array());
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $modulename = $adb->query_result($result,$i,'modulename');
        //editor:gyq_74 reason:0034768: （客户自助服务平台PC端登录）公众号表单和字段设置：模块名称设置弹出层界面应不显示“客户”模块 2018/7/27 11:11
        if($modulename=='Accounts') continue;
        $mptype = $adb->query_result($result,$i,'type');
        $crmmodulelabel = getTransTab($modulename).($mptype=='create'?'（'.getFixedLabel('NEW').'）':'（'.getFixedLabel('VIEW').'）');
        $entity[$i]['i'] = $i;
        if($i % 2 == 0){
            $class ="lvtColData";
        }else{
            $class = "lvtColDataBj";
        }
        $entity[$i]['class'] = $class;
        $entity[$i]['crmmodulelabel'] = $crmmodulelabel;
        $entity[$i]['id'] = $adb->query_result($result,$i,'id');
        $entity[$i]['mplabel'] = $adb->query_result($result,$i,'mplabel');
        $entity[$i]['mplabel_en'] = $adb->query_result($result,$i,'mplabel_en');
        $entity[$i]['presence'] = $adb->query_result($result,$i,'presence');
    }
    $smarty->assign('FROM','module');
    //editor:gyq_20191104 reason:初始化首尾按钮
    //0038389: （1.6）系统设置>服务小程序设置、订单小程序设置>模块设置>操作列：第一行的【上移】按钮应该去掉，第二行的【下移】按钮应该去掉。
    $smarty->assign('ENTITYNUMROWS',$num_rows);
    $smarty->assign('CUSTOMERSELFSERVICECONFIG02',$CUSTOMERSELFSERVICECONFIG02[$selftype]);
    $smarty->assign('ENTITY',$entity);

    $arr['content']= $smarty->fetch('Settings/wechat_miniprogram/SelfServiceConfig_Module.tpl');
    ConvertTojsonString(1,$arr,"success");
}elseif ($_REQUEST['step']=='moduledetail'){
    $smarty->assign('CUSTOMERSELFSERVICECONFIG03',$CUSTOMERSELFSERVICECONFIG03[$selftype]);
    $smarty->assign('SELECTMODULES',$selectmodules);
    $smarty->assign('MPMODULEFIELDSHTML',$mpfieldshtml);
    $smarty->assign('SELFTYPE', $selftype);

    $arr['content']= $smarty->fetch('Settings/wechat_miniprogram/SelfServiceConfig_Moduledetail.tpl');
    ConvertTojsonString(1,$arr,"success");
}elseif ($_REQUEST['step']=='modulelist'){
    //**************列表定制****************
    $smarty->assign('CUSTOMERSELFSERVICECONFIG04',$CUSTOMERSELFSERVICECONFIG04[$selftype]);
    $smarty->assign('VIEWALLHTML',$viewallhtml);
    $modulename_array = explode(',',$interface_module[$selftype]);
    $smarty->assign('SELECTMODULES',$modulename_array);
    $smarty->assign('MPMODULELISTFIELDSHTML',$mplistfieldshtml);
    $smarty->assign('SELFTYPE', $selftype);

    $arr['content']= $smarty->fetch('Settings/wechat_miniprogram/SelfServiceConfig_Modulelist.tpl');
    ConvertTojsonString(1,$arr,"success");
}
//获取模块字段信息
function getMpModuleFields($modulename){
    global $adb;
    $fieldobj=Field::getInstance($modulename,$adb);
    $moduleFields=$fieldobj->getModuleAllPreseneceFields();
    crm_load_class_file("ProductDetails",'include/ProductDetails');
    $productDetails=ProductDetails::getInstance($modulename);
    $productmoduleFields=$productDetails->getModuleAllPresenceFields();
    
    $sql = 'SELECT
                id,fieldname,tabletype,fieldlabel,fieldlabel_en,displaytype,typeofdata,defaultvalue
            FROM
                ld_weixinmp_fields
            WHERE
                modulename =? ORDER BY sequence';
    $result = $adb->pquery($sql,array($modulename));
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $fieldname = $adb->query_result($result,$i,'fieldname');
        $tabletype = $adb->query_result($result,$i,'tabletype');
        if($tabletype=='main'&&empty($moduleFields[$fieldname])) continue;
        //editor:gyq_20190422 reason:合同订单产品分录不允许设置
        if($tabletype=='detail'/*&&empty($productmoduleFields[$fieldname])*/) continue;
        $fieldarr[$i]['crmfieldlabel'] = $tabletype=='main'?$moduleFields[$fieldname]->getFieldLabel():getTransTab('Products').'_'.$productmoduleFields[$fieldname]->fieldLableKey;
        $fieldarr[$i]['mpfieldlabel'] = $adb->query_result($result,$i,'fieldlabel');
        $fieldarr[$i]['mpfieldlabel_en'] = $adb->query_result($result,$i,'fieldlabel_en');
        $fieldarr[$i]['displaytype'] = $adb->query_result($result,$i,'displaytype');
        $fieldarr[$i]['typeofdata'] = $adb->query_result($result,$i,'typeofdata');
        $fieldarr[$i]['defaultvalue'] = $adb->query_result($result,$i,'defaultvalue');
        $fieldarr[$i]['fieldid'] = $adb->query_result($result,$i,'id');
        $fieldarr[$i]['uitype'] = $tabletype=='main'?$moduleFields[$fieldname]->getUIType():$productmoduleFields[$fieldname]->uitype;
        $fieldarr[$i]['fieldname'] = $fieldname;
        
        //判断字段是否运行编辑启用状态
        if($tabletype == 'main'){
            $fieldinfoobj = $moduleFields[$fieldname]; 
            if(empty($fieldinfoobj))continue;
            $displaytype = $fieldinfoobj->getDisplaytype();
            if(($displaytype == 1 || $displaytype == 3) && ($fieldname!='account_id' && $fieldname!='contact_id') && $fieldarr[$i]['uitype'] != 53){
                $fieldarr[$i]['show_edit'] = 1;//显示单选项是否允许修改: 1表示允许修改
                $fieldarr[$i]['mandatory_edit'] = 1;//必录单选项是否允许修改:1表示允许修改
            }else{
                $fieldarr[$i]['show_edit'] = 0;//显示单选项是否允许修改: 0表示不允许修改
                $fieldarr[$i]['mandatory_edit'] = 0;//必录单选项是否允许修改:0表示不允许修改
            }
        }else{
            $fieldarr[$i]['show_edit'] = 1;//显示单选项是否允许修改: 1表示允许修改
            $fieldarr[$i]['mandatory_edit'] = 1;//必录单选项是否允许修改:1表示允许修改
        }
    }
    return $fieldarr;
}
//获取模块列表字段信息
function getMpModuleListFields($modulename){
    global $adb;
    $fieldobj=Field::getInstance($modulename,$adb);
    $moduleFields=$fieldobj->getModuleAllPreseneceFields();
    
    $sql = 'SELECT
                id,modulename,rownumber,listnumber,fieldname,presence,showtag
            FROM
                ld_weixinmp_listfields
            WHERE modulename =? ORDER BY rownumber,listnumber,id';
    $result = $adb->pquery($sql,array($modulename));
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $fieldname = $adb->query_result($result,$i,'fieldname');
        if(empty($moduleFields[$fieldname])) continue;
        $listfieldarr[$i]['fieldlabel'] = $moduleFields[$fieldname]->getFieldLabel();
        $listfieldarr[$i]['rownumber'] = $adb->query_result($result,$i,'rownumber');
        $listfieldarr[$i]['listnumber'] = $adb->query_result($result,$i,'listnumber');
        $listfieldarr[$i]['presence'] = $adb->query_result($result,$i,'presence');
        $listfieldarr[$i]['showtag'] = $adb->query_result($result,$i,'showtag');
        $listfieldarr[$i]['listfieldid'] = $adb->query_result($result,$i,'id');
    }
    return $listfieldarr;
}

//获取模块字段的html
function getMpFieldsHtml($fields){
    //editor:gyq 不显示删除按钮的字段
    $static_delete_permit_by_uitype = array(1=>53);
    //editor:gyq_20190930 reason:去除不能删除客户和联系人的控制
    //0037276: PC端：设置-系统设置-订单小程序设置-详情设置，增加“客户名称”后无法删除
    $static_delete_permit_by_fieldname = array(
        1=>'productname',2=>'quantity');
    $fields  = array_values($fields);
    $table = '<div class="ld-table-container ld-table-container-line ld-table-container-bgcolor">';
    $table .= '<table class="" name="selfServiceModuleConfig" width="100%" cellspacing="0" cellpadding="0">';
    $table .= '<thead><tr>';
    $table .= '<th align="left" style="width: auto !important;" title='.getFixedLabel('MPCRMFIELDS').'>'.getFixedLabel('MPCRMFIELDS').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('CNTAG').'>'.getFixedLabel('CNTAG').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('ENTAG').'>'.getFixedLabel('ENTAG').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('MPCREATEDISPLAY').'>'.getFixedLabel('MPCREATEDISPLAY').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('MPCREATEMFILLED').'>'.getFixedLabel('MPCREATEMFILLED').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('MPCREATEDEFAULT').'>'.getFixedLabel('MPCREATEDEFAULT').'</th>';
    $table .= '<th width="130" align="left">'.getFixedLabel('OPERATING').'</th>';
    $table .= '</tr></thead>';
    $table .= '<tbody>';
    for($i=0;$i<count($fields);$i++){
        if($i % 2 == 0){
            $table .= "<tr id='setting_{$i}' tagid='".$fields[$i]['fieldid']."' class='lvtColData ld-category-draggable' onmouseout=\"listOnMouseOut(ld(this),'on');\" onmouseover='listOnMouseOver(ld(this));'>";
        }else{
            $table .= "<tr id='setting_{$i}' tagid='".$fields[$i]['fieldid']."' class='lvtColDataBj ld-category-draggable' onmouseout=\"listOnMouseOut(ld(this),'On');\" onmouseover='listOnMouseOver(ld(this));'>";
        }
        $table .= '<td>'.$fields[$i]['crmfieldlabel'].'</td>';
        $table .= '<td>'.$fields[$i]['mpfieldlabel'].'</td>';
        $table .= '<td>'.$fields[$i]['mpfieldlabel_en'].'</td>';

        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$fields[$i]['fieldid'].',\'weixinmp_fields_displaytype\')" class="second_switch" ';
        if($fields[$i]['show_edit'] == 0){
            $table .= ' disabled ';
        }
        if($fields[$i]['displaytype']=='all'){
            $table .= ' checked /></td>';
        }else{
            $table .= ' /></td>';
        }
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$fields[$i]['fieldid'].',\'weixinmp_fields_typeofdata\')" class="second_switch" ';
        if($fields[$i]['mandatory_edit'] == 0){
            $table .= ' disabled ';
        }
        if($fields[$i]['typeofdata']=='m'){
            $table .= ' checked /></td>';
        }else{
            $table .= ' /></td>';
        }
        if($fields[$i]['uitype']==53){
            $table .= '<td>'.getUserFullName($fields[$i]['defaultvalue']).'</td>';
        }else{
            $table .= '<td>'.$fields[$i]['defaultvalue'].'</td>';
        }
        
        $table .= '<td>';
        $table .= '<a class="Anu3_a" onclick="fun_selfservice_config.getInstance('.$fields[$i]['fieldid'].').ssc_field_edit()">'.getFixedLabel('EDIT').'</a>';
        if(!array_search($fields[$i]['uitype'],$static_delete_permit_by_uitype)&&!array_search($fields[$i]['fieldname'],$static_delete_permit_by_fieldname)){
            $table .= '<a class="Anu3_a redFont" onclick="fun_selfservice_config.getInstance('.$fields[$i]['fieldid'].').ssc_field_delete()">'.getFixedLabel('DELETE').'</a>';
        }
        //BUG20240807-76  	后台设置--服务小程序详情界面定制--对字段编辑后，排序会变成上移下移按钮，应该还是拖动排序的样式
        $table .= '<a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{\'DRAGTOSORT\'|@getFixedLabel}"
                     data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:2px"></a>';


        $table .= '</td>';
        $table .= '</tr>';
    }
    $table .= '</tbody>';
    $table .= '</table>';
    $table .= '</div>';
    return $table;
}
//获取模块列表字段的html
function getMpListFieldsHtml($listfields){
    $table = '';
    $table .= '<table class="settingTable" width="100%" cellspacing="0" cellpadding="0">';
    $table .= '<tr>';
    $table .= '<th style="width: auto !important;" align="left" title='.getFixedLabel('linenumber').'>'.getFixedLabel('linenumber').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('rownumber').'>'.getFixedLabel('rownumber').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('LISTFIELDS').'>'.getFixedLabel('LISTFIELDS').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('WHETHERTODISPLAY').'>'.getFixedLabel('WHETHERTODISPLAY').'</th>';
    $table .= '<th align="left" title='.getFixedLabel('MOBILELISTSHOWFIELDNAME').'>'.getFixedLabel('MOBILELISTSHOWFIELDNAME').'</th>';
    $table .= '<th width="100" align="left">'.getFixedLabel('OPERATING').'</th>';
    $table .= '</tr>';
    //editor:gyq_20190308 reason:for($i=0;$i<count($listfields);$i++){ 这种一旦key有断续，则会出问题
    $listfields = array_merge($listfields);
    for($i=0;$i<count($listfields);$i++){
        if($i % 2 == 0){
            $table .= "<tr id='setting_{$i}' class='lvtColData' onmouseout=\"listOnMouseOut(ld(this),'on');\" onmouseover='listOnMouseOver(ld(this));'>";
        }else{
            $table .= "<tr id='setting_{$i}' class='lvtColDataBj' onmouseout=\"listOnMouseOut(ld(this),'On');\" onmouseover='listOnMouseOver(ld(this));'>";
        }
        $table .= '<td>'.$listfields[$i]['rownumber'].'</td>';
        $table .= '<td>'.$listfields[$i]['listnumber'].'</td>';
        $table .= '<td>'.$listfields[$i]['fieldlabel'].'</td>';
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$listfields[$i]['listfieldid'].',\'weixinmp_listfields_presence\')" class="second_switch" ';
        if($listfields[$i]['presence']!='' && $listfields[$i]['presence']=='0'){
            $table .= ' checked /></td>';
        }else{
            $table .= ' /></td>';
        }
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$listfields[$i]['listfieldid'].',\'weixinmp_listfields_showtag\')" class="second_switch" ';
        if($listfields[$i]['showtag']!='' && $listfields[$i]['showtag']=='0'){
            $table .= ' checked /></td>';
        }else{
            $table .= ' /></td>';
        }
        $table .= '<td>';
        $table .= '<a class="Anu3_a" onclick="fun_selfservice_config.getInstance('.$listfields[$i]['listfieldid'].').ssc_listfield_edit()">'.getFixedLabel('EDIT').'</a>';
        $table .= '<a class="Anu3_a redFont" onclick="fun_selfservice_config.getInstance('.$listfields[$i]['listfieldid'].').ssc_listfield_delete()">'.getFixedLabel('DELETE').'</a>';
        $table .= '</td>';
        $table .= '</tr>';
    }
    $table .= '</table>';
    return $table;
}
//重置模块字段sequence
function ResetSequence($module){
    global $adb;
    $sql = 'select id from ld_weixinmp_fields where modulename=? order by sequence';
    $result = $adb->pquery($sql,array($module));
    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $id = $adb->query_result($result,$i,'id');
        $adb->pquery('update ld_weixinmp_fields set sequence=? where id=?',array($i+1,$id));
    }
}
//获取设置范围参数的html
function getMpViewAllHtml($module){
    $html = '';
    // editor:gyq_74 reason:自助服务平台_客户注册 20180802 17:18  0034825: （xiaoshou360.com/kfbcrm客户自助服务平台PC端登录）公众号表单和字段设置：“合同订单”和“客户”模块应不显示允许查询绑定客户的所有服务记录
    /*if($module=='HelpDesk'){
        $viewall = cls_MP_CommonFun::getMpModuleViewBol($module);
        $check = $viewall=='yes'?'checked':'';
        $html = '<input type="checkbox" id="viewall" name="viewall" '.$check.' value=""/>&nbsp;';
        $html .= '<span>'.getFixedLabel('ALLOWSEARCHALLRECORDS').'</span>';
    }*/
    return $html; 
}


?>