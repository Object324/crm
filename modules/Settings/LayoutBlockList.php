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

require_once('include/CustomFieldUtil.php');
require_once 'modules/PickList/PickListUtils.php';
global $mod_strings,$app_strings,$theme,$adb,$languageType,$current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
require_once('modules/lingdang/layout_utils.php');
$smarty=new lingdangCRM_Smarty;

$subMode = $_REQUEST['sub_mode'];

$smarty->assign("THEME", $theme);
//修改模块相关模块显示顺序以及显示状态

//wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
if($subMode=='SetDisplayFields' && $_REQUEST['ajax'] == 'true'){
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $otherlanguage='zh';
    if($languageType=='zh')
    {
        $otherlanguage='en';
    }
    $tabid=getTabid($_REQUEST['modulename']);
    $focus_fieldobj=Field::getInstance($_REQUEST['modulename'],$adb);


    $sql="select distinct ld_tranlabel.fieldlabel, othertable.otherlabel,ld_field.fieldid,
                columnname,defaultvalue ,block,uitype,fieldonly,presence,fieldname,
                displaytype ,allowhide,keywords,keyword_sseq
                from  ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                 inner join (select ld_tranlabel.fieldlabel as otherlabel,relateid from ld_tranlabel inner
                  join ld_field on ld_field.fieldid=ld_tranlabel.relateid where languagetype=? 
                  and trantable=? and ld_tranlabel.tabid=? and ld_field.tabid=? order by sequence,fieldid asc ) as othertable 
                             on othertable.relateid=ld_tranlabel.relateid
                     where presence<>1 and languagetype=? and trantable=? and ld_field.tabid = ? and ld_tranlabel.tabid=? and ld_field.tabid=?  and ld_field.displaytype IN (1,2,3,4) order by keyword_sseq,fieldid asc ";
    $sql_field_params = array($otherlanguage,'ld_field',$tabid,$tabid,
        $languageType,'ld_field',$tabid,$tabid,$tabid,);

    $result_field = $adb->pquery($sql,$sql_field_params);
    $nums=$adb->num_rows($result_field);
    $display_field_selected=array();
    $Noshowfields = [];
    if($_REQUEST['modulename']=='Users'){
        $tmp_focus=CRMEntity::getInstance($_REQUEST['modulename']);
        $Noshowfields=$tmp_focus->getSearchNoshowfields();
    }

    for($i=0;$i<$nums;$i++)
    {
        $fieldid = $adb->query_result($result_field,$i,'fieldid');
        $presence = $adb->query_result($result_field,$i,'presence');
        $fieldlabel = $adb->query_result($result_field,$i,'fieldlabel');
        $keywords = $adb->query_result($result_field,$i,'keywords');
        $keyword_sseq = $adb->query_result($result_field,$i,'keyword_sseq');
        $fieldname = $adb->query_result($result_field,$i,'fieldname');

        if($keywords=='yes') {
            $key = 1;
        }else{
            $key = 0;
        }
        //wyt 221213 BUG0059888 kfbcrm 成员管理---关键信息栏---应该设置密码字段不能选择到  230116 BUG0060732 kfbcrm 裂变文章---关键信息栏---无法显示标签字段
        if(is_array($Noshowfields) && !in_array($fieldname,$Noshowfields) && $fieldname!='currency_id' && $fieldname!='tag'){
            $display_field_selected[$key][$fieldid]=$fieldlabel;
        }
    }

    $smarty->assign('related_modules',$display_field_selected[0]);
    $smarty->assign('related_module_selected',$display_field_selected[1]);
    $smarty->assign('tabid',$tabid);
    $smarty->assign('modulename',$_REQUEST['modulename']);

    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['title']=getFixedLabel('SETDISPLAYFIELDS');
    $str=$smarty->fetch('Settings/SetDisplayFields.tpl');

    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
}

if($subMode=='SetRelatedlists' && $_REQUEST['ajax'] == 'true')
{
    $tabid=getTabid($_REQUEST['modulename']);
    if($tabid==16){ //Liver 2016/05/20,bug:0022523: 日程管理“页面设置”<相关信息设置>弹出层：没有“共享人”
        $tabid=9;
    }
    $regop=RegOp::getInstance();
    $versioninfo=getVersionInfo();
    $version=$versioninfo['trade'];
    $focus_fieldobj=Field::getInstance($_REQUEST['modulename'],$adb);
    $sql="SELECT relation_id,related_tabid,label,name,presence,type  from ld_relatedlists where tabid=? ORDER BY sequence";
    $result=$adb->pquery($sql,array($tabid));
    $nums=$adb->num_rows($result);
    $related_module_selected=array();
    for($i=0;$i<$nums;$i++)
    {
        $related_tabid = $adb->query_result($result,$i,'related_tabid');
        $relation_id = $adb->query_result($result,$i,'relation_id');
        $name = $adb->query_result($result,$i,'name');
        $related_label = $adb->query_result($result,$i,'label');
        $presence = $adb->query_result($result,$i,'presence');
        $type=$adb->query_result($result,$i,'type');

        if($_REQUEST['modulename'] == 'SalesOrder' && $related_tabid == $tabid){
            $field=$focus_fieldobj->getFieldInfoobjBykey('columnname','parentid');
            if(empty($field)){
                continue;
            }
        }
        //通话记录：判断电话管家是否显示
        if($name == 'get_CallButler'){

               if( get_callLinkDisplay() =='no'){
                   if($regop->getCall_Record()=='1')
                   {

                   }
                   else{
                       crm_load_class_file('cls_CallRecord','modules/Settings');
                       $callrecordobj = new cls_CallRecord($_REQUEST['modulename']);
                       if($callrecordobj->getModuleCallRecordStatus() == 'no'){
                           continue;
                       }
                   }
             }

        }

        //已购产品
        if($related_label == 'BoughtProduct' && $version!='finance'){
            continue;
        }
        $key = $relation_id. '_'.$name;

        if($related_tabid>0&&vtlib_isModuleActive(getTabname($related_tabid)))
        {
            if(strtolower($type)=='datacategory_template_js'||strtolower($type)=='datacategory_templatelink'||strtolower($type)=='datacategory_template_url')
            {
                $related_module_selected[$presence][$key] = $related_label;
            }
            else if($related_label == 'BalanceOfAccount'){
                $related_module_selected[$presence][$key] = getFixedLabel('BALANCEOFACCOUNT');
            }else if($related_label == 'DividendOrder'){

                if($version == 'finance')
                    $related_module_selected[$presence][$key] = getTranstab(getTabname($related_tabid));

            }else{
                if(getTabname($related_tabid)=='Home'){
                    $related_module_selected[$presence][$key]=getTranstab('CooperativeWork');
                }else{
                    $related_module_selected[$presence][$key]=getTranstab(getTabname($related_tabid));
                }
            }
        }
        else if($name == 'get_qiqireport'){

            $related_module_selected[$presence][$key] =getTranstab('QIQIReport');
        }else if($name == 'get_gjpbalanceofsalesorder'){

            $related_module_selected[$presence][$key] =getTranstab('GuanJiaPoReport');
        }
        else if($name == 'get_WorkReport'){

            $related_module_selected[$presence][$key] =getTranstab('CooperativeWork');
        }
        else if($name == 'get_SocialPromotionReport'){	//44179: 表单推广->相关信息设置：没有显示“统计报表”

            $related_module_selected[$presence][$key] =getTranstab('SocialPromotionReport');
        }
        else if($name == 'get_QuestionnaireReport'){
            $related_module_selected[$presence][$key] =getTranstab('SocialPromotionReport'); //统计报表
        }
        else if($name == 'get_redemption'){
            $related_module_selected[$presence][$key] =getFixedLabel('REDEMPTION');
        }
        //项目 - 项目摘要
        else if($related_label == 'ProjectAbstract'){
            $related_module_selected[$presence][$key] = getFixedLabel('ProjectAbstract');
        }
        else if($related_label == 'buyProductQuantity' && $version=='jijin'){
            $related_module_selected[$presence][$key] = getFixedLabel('BUYPRODUCTQUANTITY');
        }
        else  if($related_label == 'BoughtProduct' && $version=='finance'){
            $related_module_selected[$presence][$key] = getFixedLabel('BOUGHTPRODUCT');
        }
        else if($related_label == 'Singin'){// Liver 2016/09/07 0024289: 客户>页面设置>客户：相关信息设置弹出层可用项目中没有【签到记录】
            $related_module_selected[$presence][$key] = getFixedLabel('Singin');
        }

        else if($related_label == 'Kingdeeorders')//客户-金蝶订单
        {
            if(getDatainterface('soft_factory')=='金蝶')//表示软件厂商为金蝶
            {
                if(getDatainterface('soft_version')==1)//soft_verdon==1表示选择到了K3系统。
                {
                    if(getDatainterface('using_order_read')==1)//表示启用订单读取接口
                    {
                        $related_module_selected[$presence][$key] = getFixedLabel('KINGDEEORDERS');
                    }
                }
            }
        }
        else if($related_label == 'Kingdeequotes')//客户-金蝶报价单
        {
            if(getDatainterface('soft_factory')=='金蝶')//表示软件厂商为金蝶
            {
                if(getDatainterface('soft_version')==1)//soft_verdon==1表示选择到了K3系统。
                {
                    if(getDatainterface('using_quote_read')==1)//表示启用报价单读取接口
                    {
                        $related_module_selected[$presence][$key] = getFixedLabel('KINGDEEQUOTES');
                    }
                }
            }
        }
        else  if($related_label == 'Digiwinorders')
        {
            if(getDatainterface('soft_factory')=='鼎捷')//表示软件厂商为鼎捷
            {
                if(getDatainterface('soft_version')==201)//soft_verdon==1表示选择到了易助7.0系统。
                {
                    if(getDatainterface('using_order_read')==1)//表示已启用订单读取接口
                    {
                        $related_module_selected[$presence][$key] = getFixedLabel('DIGIWINORDERS');
                    }
                }
            }
        }
        else if($related_label == 'Digiwintickets')
        {
            if(getDatainterface('soft_factory')=='鼎捷')//表示软件厂商为鼎捷
            {
                if(getDatainterface('soft_version')==201)//soft_verdon==1表示选择到了易助7.0系统。
                {
                    if(getDatainterface('using_ticket_read')==1)//表示已启用订单读取接口
                    {
                        $related_module_selected[$presence][$key] = getFixedLabel('DIGIWINTICKETS');
                    }
                }
            }
        }

        else if($related_label == 'SharedUsers'){

            $related_module_selected[$presence][$key] = getFixedLabel('ShareUsers');
        }
        else if($related_label == 'Redemption' && $version=='jijin'){
            $related_module_selected[$presence][$key] = getFixedLabel('REDEMPTION');
        }
        else if($related_label == 'CallButler'){
            $related_module_selected[$presence][$key] = getFixedLabel('CallButler');
        }
        else if($related_label == 'Print'){
            $related_module_selected[$presence][$key] = getFixedLabel('TOOLS');
        }
        else if($related_label == 'RECEIVABLESFORECAST'){
            $related_module_selected[$presence][$key] = getFixedLabel('RECEIVABLESFORECAST');
        }
        else if($related_label == 'SalesOrder'&&vtlib_isModuleActive('SalesOrder')){
            if($_REQUEST['modulename']=='SalesOrder'){
                if($version=='jijin'){
                    $related_module_selected[$presence][$key] = getFixedLabel('SUPERADDTION');
                }else{
                    $related_module_selected[$presence][$key] = getFixedLabel('CHANGEORDER');
                }

            }
            else{
                $related_module_selected[$presence][$key] = getTranstab($related_label);
            }

        }
        //date:2017-10-16 reason:关联创建转移到相关信息字段  xxs
        else if($related_label == 'ViewHistory'){
            $related_module_selected[$presence][$key] = getFixedLabel('View History');
        }
        else if($related_label == 'publicaccount_log'){	//公海操作记录
            if ($_REQUEST['modulename'] == 'Accounts') {
                crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
                $cls_PublicAccounts = new cls_PublicAccounts($_REQUEST['modulename']);
            }else{
                crm_load_class_file('cls_PublicLeads', 'modules/Leads');
                $cls_PublicAccounts = new cls_PublicLeads($_REQUEST['modulename']);
            }
            $public_account = $cls_PublicAccounts->getPublicAccount();
            if($public_account['status'] != 'yes')continue;
            $related_module_selected[$presence][$key] = getFixedLabel('RECORDSOFOPERATION');
        }
        else if($related_label == 'ChangeView'){
            $smownertraslate = GetSpecialActionTranlation(-10,$tabid);
            $related_module_selected[$presence][$key] = $smownertraslate;
        }
        else if($related_label == 'OperationLogs'){
            $related_module_selected[$presence][$key] = getFixedLabel('OperationLogs');
        }
        else if($related_label == 'ContactsHierarchy'){
            $focus = CRMEntity::getInstance('Contacts');
            if(isset($focus->column_fields['contact_id'])){
                $related_module_selected[$presence][$key] = getFixedLabel('VIEW').getFixedLabel('THELOWLEVELCONTRACTS');
            }
        }
        else if($related_label == 'AccountHierarchy'){
            $focus = CRMEntity::getInstance('Accounts');
            if(isset($focus->column_fields['account_id'])){
                $related_module_selected[$presence][$key] = getFixedLabel('LBL_SHOW_ACCOUNT_HIERARCHY');
            }
        }
        else if($related_label == 'ReadRecord'){ //@edit:liushuai,2021-04-16,reason:【ID1001520】公告增加阅读数和阅读记录（相关信息设置）
            $related_module_selected[$presence][$key] = getFixedLabel('ReadingRecord');
        }else if($related_label == 'trends'){
            $module_arr = array('Accounts','ServiceCharge','WorkSheet');
            if(in_array($_REQUEST['modulename'],$module_arr)){
                $related_module_selected[$presence][$key] =getFixedLabel($related_label);
            }
        }
        else if($related_label == 'ContactsMap' && vtlib_isModuleActive('Contacts') ==1){//联系人模块未激活联系人图谱不出现在相关信息
            //@edit:ljj,2023-07-28,reason:XUQIU1001536 单据查看详情界面，相关信息联系人列表的“联系人图谱”修改为相关信息“联系人图谱”模块
            $related_module_selected[$presence][$key] = getFixedLabel('ContactsMap');
        }
        else if($name == 'get_relationshipChart'){//ljj 20240905 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛）
            if ($related_label == 'Accounts_relationshipChart'){
                $related_module_selected[$presence][$key] = getFixedLabel('AccountsRelationshipChart');
            }
        }
        // @edit:dong @date:2020/7/13 @reason: 社交推广 -明细-》自定义相关系  社交推广显示为表单映射模块
        if($related_label=='SocialPromotionForm'&&$_REQUEST['modulename']=='SocialPromotion'){
            $related_module_selected[$presence][$key] = getFixedLabel('SocialPromotionForm');
        }
        //34853: 合同订单->明细->相关信息设置：“合同订单”应该显示为“变更单（子合同）”
        if($related_label=='SalesOrder'&&$_REQUEST['modulename']=='SalesOrder')
        {
            $related_module_selected[$presence][$key] =getFixedLabel('CHANGEORDER');

        }
    }
    //xxy 2023-11-24 XUQIU1002162 相关信息设置弹出层中，增加“相关模块显示“打开新页签”按钮”参数，可自定义相关模块打开新页签图标按钮是否显示
    $opennewpage_presence = getUsersettingByLabel($_REQUEST['modulename'],1,'OpenNewPage');
    //jby 2024/12/16 XUQIU20241127-04 相关信息设置弹出层中，增加"设置客户相关信息可以看见下级单据的数据"参数
    if($_REQUEST['modulename']=='Accounts' || $_REQUEST['modulename']=='ServiceCharge'){
        $superior_account_see = getUsersettingByLabel($_REQUEST['modulename'],1,'SuperiorAccountSee');
        $smarty->assign('superior_account_see',$superior_account_see);
    }

    $smarty->assign('related_modules',$related_module_selected[1]);
    $smarty->assign('related_module_selected',$related_module_selected[0]);
    $smarty->assign('tabid',$tabid);
    $smarty->assign('modulename',$_REQUEST['modulename']);
    $smarty->assign('opennewpage_presence',$opennewpage_presence);
    $_REQUEST['diony']='diony';
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['title']=getFixedLabel('PROJECTSETTINGS');
    $str=$smarty->fetch('Settings/SetRelatedlists.tpl');
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
}

// 2024-9-29 xxy XUQIU20240829-12 增加自定义按钮，并支持绑定工作流，通用按钮排序
if($subMode=='SortDetailButtons' && $_REQUEST['ajax'] == 'true')
{
    $modulename = $_REQUEST['modulename'];
    $tabid = getTabid($modulename);
    // if ($tabid == 16) { //Liver 2016/05/20,bug:0022523: 日程管理“页面设置”<相关信息设置>弹出层：没有“共享人”
    //     $tabid = 9;
    // }
    if($_REQUEST['mode'] == 'set'){
        $focus = CRMEntity::getInstance($modulename);
        $focus->id = $_REQUEST['record'];
        $focus->getModuleLogic($modulename);
        $focus->logic->getDetailViewButton();
        $all_detailbtn_arr = $focus->logic->getAllDetailButtons();
        // dump($all_detailbtn_arr);

        $btninfo_arr = [];
        foreach ($all_detailbtn_arr as $key => $value) {
            $btninfo_arr[] = ['value' => $key, 'text' => $value['label']];
        }
        $arr['btninfo_arr'] = $btninfo_arr;
        $arr['oktext'] = getFixedLabel("SAVE");
        $arr['canceltext'] = getFixedLabel("CANCEL");
        $arr['title'] = getFixedLabel('Generalbuttonsorting');
        // dump($btninfo_arr);
        ConvertTojsonString(1,$arr,"success");
    }else if($_REQUEST['mode'] == 'save'){
        $btnseq_arr = ldcrm_json_decode($_REQUEST['btnseq_str']);
        $delete_sql = 'DELETE from ld_btnset where tabid = ? and btn_type = "detailbtn";';
        $adb->pquery($delete_sql,array($tabid));
        foreach ($btnseq_arr as $seq => $btninfo)
        {
            $insert_sql = 'INSERT into ld_btnset(tabid,buttonlabel,btn_type,`sequence`,btnkey,is_active) values (?,?,?,?,?,?);';
            $adb->pquery($insert_sql,array($tabid,$btninfo['text'],'detailbtn',$seq,$btninfo['value'],'yes'));
        }
        ConvertTojsonString(1,[],"success");
    }
}
//$smarty->assign("JS_DATEFORMAT",parse_calendardate('yyyy-mm-dd'));
$version=getVersionTradeInfo();//获取数据库行业版本
$version=$version['trade'];
global $global_regop;
if(!isset($global_regop))
    $global_regop=RegOp::getInstance();
global $handleWriteSign_interface;
if($global_regop->gethandleWriteSign_interface()==0)
{
    $handleWriteSign_interface=0;
    $smarty->assign("HandlWRITESIGNPROFILE",0);
}
else
{
    $handleWriteSign_interface=1;
    $smarty->assign("HandlWRITESIGNPROFILE",1);
}

if ($subMode == 'updateFieldProperties')
    updateFieldProperties();
elseif($subMode == 'deleteCustomField')
    deleteCustomField();
elseif($subMode == 'changeOrder')
    changeFieldOrder();
elseif($subMode == 'addBlock')
    $duplicate = addblock();
elseif($subMode == 'deleteCustomBlock')
    deleteBlock();
elseif($subMode=='findLabels_Exists')
    find_fieldLabels_Exists();
elseif($subMode == 'addCustomField')
    $duplicate = addCustomField();
elseif($subMode == 'movehiddenfields' || $subMode == 'showhiddenfields')
    show_move_hiddenfields($subMode);
elseif($subMode == 'changeRelatedInfoOrder')
    changeRelatedListOrder();
elseif($subMode == 'changeRelatedPersence')
    changeRelatedListPersence();
elseif($subMode == 'updateTabDuplicate')
    updateTabDuplicate();
elseif($subMode == 'updateBlockSequence')	//更新区块的顺序
    updateBlockSequence();
elseif($subMode == 'updateColumnSequence')	//单个区块移动字段
    updateColumnSequence();
elseif($subMode == 'updateColumnSequence_Block')	//跨区块移动字段
    updateColumnSequence_Block();
/**
 * 修改区块中英文名称
 * andy
 * date 20140617
 * others；none
 */
elseif($subMode == 'relatedlist_blocknameSave')
    $duplicate= changeBlockName();
/**
 * 修改修改相关模块显示属性及顺序
 * andy
 * date 20140617
 * verson v5.32
 * others；none
 */
elseif($subMode == 'SetRelatedlistsSave'){

    $formodule = $_REQUEST['formodule'];
    $cachekey = 'cache_ispresentrelated_'.$formodule;
    unsetCache($cachekey);
    unsetCache('cache_mobileispresentrelated');
    unsetCache("cache_ispresentrelated");

    setRelatedLists(1);

    setUsersettingByLabel($formodule,1,"OpenNewPage",$_REQUEST['OpenNewPage']);
    if(isset($_REQUEST['SuperiorAccountSee'])){
        setUsersettingByLabel($formodule,1,"SuperiorAccountSee",$_REQUEST['SuperiorAccountSee']);
    }


    /**
     * 快捷操作设置
     * andy
     * date 20140618
     * verson v5.32
     * others；none
     */
}elseif($subMode == 'QuicksetactionsSave'){
    setRelatedLists(2);
}elseif($subMode == 'saveLayoutBlockAdvance'){
    saveLayoutBlockAdvance();
}elseif($subMode == 'getFormualFields'){
    $arr = getFormualFields();
    ConvertTojsonString(1,$arr,"success");
}elseif($subMode == 'getFormualFieldsSql'){
    $arr = getFormualFieldsSql();
    ConvertTojsonString(1,$arr,"success");
}elseif($subMode == 'SetDisplayFieldsSave'){
    SetDisplayFieldsSave();
}elseif($subMode == 'ViewDisplayFields'){
    ViewDisplayFields();
    ConvertTojsonString(1,'',"success");
}
//$module_array=getCustomFieldSupportedModules();
$cfimagecombo = Array(
    $image_path."text.gif",
    $image_path."number.gif",
    $image_path."percent.gif",
    $image_path."currency.gif",
    $image_path."date.gif",
    $image_path."email.png",
    $image_path."phone.gif",
    $image_path."picklist.gif",
    $image_path."url.gif",
    $image_path."checkbox.gif",
    $image_path."text.gif",
    $image_path."picklist.gif",
    $image_path."time.PNG",
    $image_path."datetime.gif",
    $image_path."sendmsg.png",
    $image_path."rfax.gif",
    $image_path."QQ.gif"
);

$cftextcombo = Array(
    $mod_strings['Text'],
    $mod_strings['Number'],
    $mod_strings['Percent'],
    $mod_strings['Currency'],
    $mod_strings['Date'],
    $mod_strings['Email'],
    $mod_strings['Phone'],
    $mod_strings['PickList'],
    $mod_strings['LBL_URL'],
    $mod_strings['LBL_CHECK_BOX'],
    $mod_strings['LBL_TEXT_AREA'],
    $mod_strings['LBL_MULTISELECT_COMBO'],
    $mod_strings['Time'],
    $mod_strings['DateTime'],
    $mod_strings['mobilephone'],
    $mod_strings['rfax'],
    $mod_strings['QQ']
);


//$smarty->assign("MODULES",$module_array);
$smarty->assign("CFTEXTCOMBO",$cftextcombo);
$smarty->assign("CFIMAGECOMBO",$cfimagecombo);

if($_REQUEST['formodule'] !='')
    $fld_module = vtlib_purify($_REQUEST['formodule']);
elseif($_REQUEST['fld_module'] != '') {
    $fld_module = vtlib_purify($_REQUEST['fld_module']);
}else
    $fld_module = 'Accounts';

$smarty->assign('ISDUPLICATE',getTabDuplicate($fld_module));
if($fld_module=='Calendar')
{
    $fld_module='Events';
}

//ls 2021-10-18 【1002087】带分录的表单，页面设置中去掉“快速创建”页签
$display_quickly_create = 'yes';
$no_quickly_create_modules = ['Users','Reminds'];// 不需要“快速创建”页签的模块
if (get_file_address($fld_module,'ProductDetails') || get_file_address($fld_module,$fld_module."DetailFieldsHtml") || in_array($fld_module,$no_quickly_create_modules)) {
    $display_quickly_create = 'no';
}
//duan 20221209 拜访签到模块不显示验证规则和自动化进度
$display_validata_rule = 'yes';
$display_advance = 'yes';
$display_keywork_block = 'yes';
if ($fld_module == 'Singin') {
    $display_validata_rule = 'no';
    $display_advance = 'no';
    $display_quickly_create = 'no';
    $display_keywork_block = 'no';
}
$smarty->assign("display_quickly_create",$display_quickly_create);
$smarty->assign("display_validata_rule",$display_validata_rule);
$smarty->assign("display_advance",$display_advance);
$smarty->assign("display_keywork_block",$display_keywork_block);

$smarty->assign("MODULE",$fld_module);

//wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
$fieldz = getFieldListEntries($fld_module);
$keyword_sseq_arr = getFieldListEntriesForKeywords($fld_module);
$view_keywords=0;
$sql_keywords="SELECT visible from ld_blocks where tabid=? and blocklabel='LBL_KEYWORDS'";
$keywords_result=$adb->pquery($sql_keywords,array(getTabid($fld_module)));
$keywords_nums=$adb->num_rows($keywords_result);

if($keywords_nums>0){
    $view_keywords=$adb->query_result($keywords_result,0,'visible');
}
//echo '<pre>';
//print_r($fieldz);
//echo '</pre>';

$smarty->assign("BACKACTION",$_REQUEST['backaction']);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign("CFENTRIES",$fieldz);//字段信息
$smarty->assign("CFENTRIESKEYWORDS",$keyword_sseq_arr);//字段信息
$smarty->assign("VIEWKEYWORDS",$view_keywords);//字段信息

if($subMode == 'getRelaInfoOrder' || $subMode == 'changeRelatedPersence')
{
    $smarty->assign("RELATEDLIST",getRelatedOrder());
}
else
{
    //dump('wwww');
    // $smarty->assign("RELATEDLIST",getRelatedListInfo($fld_module));//更多信息
}

if(isset($_REQUEST["duplicate"]) && $_REQUEST["duplicate"] == "yes" || $duplicate == 'yes') {
    if($subMode == 'addBlock'||$subMode=='relatedlist_blocknameSave')
    {

        echo getFixedLabel('BlockName').getFixedLabel('REPEAT').'#error#';
    }
    else
        echo  getFixedLabel('DUPFIELDNAME');
    exit;
}
if($duplicate == 'LENGTH_ERROR') {
    echo getFixedLabel('FIELDLENERROR');
    exit;
}
if($_REQUEST['mode'] !='')
    $mode = vtlib_purify($_REQUEST['mode']);

$smarty->assign("MODE", $mode);
//chj 2021/6/21 46481: （https://81mis.com/kfbcrm/ [^]）请假单->页面设置，“引用字段”字段类型“引用对象”中去掉“成员管理”
//zkt 20230404 BUG0064027 客户详情界面相关信息栏里要添加付款单，需要在付款单界面关联选择到客户。但是付款单后台新增字段的时候，关联选择字段，选择不到客户。并且后台的所有的隐藏字段都打开看了的，没有关联过客户的。
//报价变更单“关联选择单据”类型的“关联选择对象”不应该再有“报价单”模块，已经预置的有（预置的displaytype为2，故需要去掉displaytype=1的条件）
//wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（苏宁）
//wym BUG0076362 加入引用成员管理字段后,name可能会重复,修改了sql,presence也放到了sql中判断;如果有问题,改回原来sql,但要注意组装html时name不要重复
$sql='select DISTINCT ld_ws_referencetype.type as name from ld_ws_fieldtype
inner join ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
inner join ld_field on ld_field.uitype=ld_ws_fieldtype.uitype
inner join ld_tab on ld_field.tabid=ld_tab.tabid 
where  ld_tab.tabid=? and ld_field.savedatabase="yes" and ld_field.relatedmodulefield <>"yes" 
and ld_field.uitype<>202  and ld_field.uitype <> 77 
and (ld_field.presence = 0 OR ld_field.presence = 2) 
group by ld_field.uitype
order by ld_field.sequence asc   ';
$result=$adb->pquery($sql,array(getTabid($fld_module)));
$rows=$adb->num_rows($result);
$reltedmodulehtml='';
$referencemodules=array();
$RELATEMODULESCOUNT=0;
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');

    $referencemodules[]=$name;//获取所有的选择单据的模块，无论改字段是否开启

    $label=getTranstab($adb->query_result($result,$i,'name'));
    $reltedmodulehtml.="<option value='".$name."'>".$label."</option>";
    $RELATEMODULESCOUNT++;
}
//wym 多选关联字段 查询出多选关联字段
$sql='SELECT ld_ws_multireferencetype.type AS NAME,ld_field.presence FROM ld_ws_fieldtype
INNER JOIN ld_ws_multireferencetype ON ld_ws_multireferencetype.fieldtypeid = ld_ws_fieldtype.fieldtypeid
INNER JOIN ld_field ON ld_ws_fieldtype.uitype = ld_field.uitype
INNER JOIN ld_tab ON ld_field.tabid = ld_tab.tabid
WHERE ld_tab.tabid = ? AND ld_field.savedatabase = "yes" AND ld_field.relatedmodulefield <> "yes" AND ld_field.uitype <> 202 AND ld_field.uitype <> 53 AND ld_field.uitype <> 77
GROUP BY ld_field.uitype ORDER BY ld_field.sequence ASC';
$result=$adb->pquery($sql,array(getTabid($fld_module)));
$rows=$adb->num_rows($result);
$referencemodules_multi=array();
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');
    $presence=$adb->query_result($result,$i,'presence');
    $referencemodules_multi[]=$name;
}

//edit:can 20211013 048275: （81mis.com/kfbcrm）系统设置-页面设置-入库单，新建引用字段，无法引用采购订单字段内容
$sql='select ld_ws_referencetype.type as name,ld_field.presence from ld_ws_fieldtype
inner join ld_ws_referencetype
on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
inner join ld_field on ld_field.uitype=ld_ws_fieldtype.uitype
inner join ld_tab on ld_field.tabid=ld_tab.tabid 
where  ld_tab.tabid=? and ld_field.savedatabase="yes" and ld_field.displaytype=1
and ld_field.uitype<>202 and ld_field.uitype <> 53 and ld_field.uitype <> 77
and ld_field.presence in(0,2) group by ld_field.uitype
 order by ld_field.sequence asc   ';

$result=$adb->pquery($sql,array(getTabid($fld_module)));
$rows=$adb->num_rows($result);
$displayreferencemodules = [];
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');
    $presence=$adb->query_result($result,$i,'presence');

    $displayreferencemodules[]=$name;//获取所有的选择单据的模块，无论改字段是否开启


}

//0045063: （61mis.com/kfbcrm）系统设置-页面设置-自定义表单11为例，当选择源单和客户名字字段都不启用时，新增字段应不显示“引用字段”类型
$sql = "SELECT * from ld_field where tabid=? and bigtype = 'selectsource' and presence in(0,2)"; //带产品分录的模块有预置 选择源单 字段，需要单独判断。
$result = $adb->pquery($sql,array(getTabid($fld_module)));
if ($adb->num_rows($result) >= 1) {
    $RELATEMODULESCOUNT++;
}

$focus=CRMEntity::getInstance($fld_module);
$sourcefieldinfo=$focus->fieldobj->getFieldInfoobjBykey("bigtype",'selectsource');
if($sourcefieldinfo&&$sourcefieldinfo->getFieldName()!="")
{

    //引用字段添加源单
    crm_load_class_file('cls_OptionModule','include/OptionModule');
    $optionmoduleobj=cls_OptionModule::getInstance($fld_module);
    $options=$optionmoduleobj->getcurModule_Option();

    foreach( $options as $sourcemoduleinfo)
    {
        if(in_array($sourcemoduleinfo['value'],$displayreferencemodules))
        {
            //edit:can 20210818 47486: (https://81mis.com/kfbcrm [^]) 【页面设置】-【项目立项】-【新建字段】-【引用字段】 出现两个合同订单
            continue;
        }
        $reltedmodulehtml.="<option value='".$sourcemoduleinfo['value']."'>".$sourcemoduleinfo['text']."</option>";
    }
    $options_module = $optionmoduleobj->getAllOptionModule();

}
$smarty->assign("RELATEDMODULE",$reltedmodulehtml);
//37461: （1.6）客户模块没有可以选择的“引用对象”时，页面设置新增字段类型中应该不显示“引用对象”字段类型
$smarty->assign("RELATEMODULESCOUNT",$RELATEMODULESCOUNT);
//xxy 2023-10-13 地图视图按钮显示
$smarty->assign("isShowMap",$focus->isShowMap);
$sql='select ld_tab.name,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab inner join ld_field  on ld_field.tabid=ld_tab.tabid 

inner join ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid 
 where ld_tab.presence in(0,2) and ld_tranlabel.trantable="ld_tab" and languagetype=?  and ld_field.columnname="smownerid" group by ld_tab.tabid   order by tabsequence asc ';

$result=$adb->pquery($sql,array($languageType));
$rows=$adb->num_rows($result);
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');
    if($fld_module==$name)
    {
        continue;
    }
    if(is_array($options_module) && in_array($name,$options_module)){
        continue;
    }
    if($fld_module=='Project'&&in_array($name,array('SalesOrder','ServiceContracts')))
    {
        //edit:can 2021-03-01 044703: （本地8.3.8）系统设置-页面设置-项目立项；先操作关闭合同订单模块，再项目立项中新增引用字段，引用对象有2个合同订单选项
        continue;
    }
    if($name=='Emails')
    {
        //wym 230808 BUG0070543 页面设置，关联选择单据（单选）字段，关联选择对象去掉“邮件管理”模块
        continue;
    }
    if(!in_array($name,$referencemodules))
    {
        $canselectmodules[]=array('name'=>$name,'label'=>$adb->query_result($result,$i,'fieldlabel'));
    }
    if(!in_array($name,$referencemodules_multi))
    {
        $canselectmodules_multi[]=array('name'=>$name,'label'=>$adb->query_result($result,$i,'fieldlabel'));
    }
}

//关联选择单据
$smarty->assign("CANSELECTMODULES",$canselectmodules);
$smarty->assign("CANSELECTMODULESMULTI",$canselectmodules_multi);
$smarty->assign('LANGUAGETYPE',$languageType);
//require_once('SetmenuControl.php');

//ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）(成员所属部门 选择成员字段)
//$selectmembers_arr = get_user_array(FALSE, "Active", "");
$selectmembers_arr = [];
//检查字段是否启用（字段对象存在就表示启用）
$tmp_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
if ($tmp_fieldinfo  && $tmp_fieldinfo->getDisplaytype()!= 2 ) {
    $selectmembers_arr[$tmp_fieldinfo->getColumnName()] = $tmp_fieldinfo->getFieldLabel();
}
$tmp_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getCreateColumnName());
if ($tmp_fieldinfo  && $tmp_fieldinfo->getDisplaytype()!= 2  ) {
    $selectmembers_arr[$tmp_fieldinfo->getColumnName()] = $tmp_fieldinfo->getFieldLabel();
}
//所有单选用户类型的字段
$fieldModules = $focus->fieldobj->getModuleFields();
foreach ($fieldModules as $temp_fieldname => $temp_fieldinfo) {
    //wym XUQIU1000290 displaytype=2 的字段不显示

    if ($temp_fieldinfo->getColumnName() != '' && (strtolower($temp_fieldinfo->getBigType()??'') == 'selectoneuser' || strtolower($temp_fieldinfo->getBigType()??'') == 'users') && $temp_fieldinfo->getDisplaytype()!= 2 ) {//153
        $selectmembers_arr[$temp_fieldinfo->getColumnName()] = $temp_fieldinfo->getFieldLabel();
    }
}

unset($tmp_fieldinfo);
$smarty->assign("SELECTMEMBERS",$selectmembers_arr);

//ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
$isEntryModule = 'no';//是否为分录模块
if (get_file_address($fld_module, 'ProductDetails') || get_file_address($fld_module, $fld_module . "DetailFieldsHtml")) {
    $isEntryModule = 'yes';
    if (get_file_address($fld_module, $fld_module . 'DetailFieldsHtml')) {
        crm_load_class_file('TabDetailFields', 'include/TabDetailFields');
        $ProductToolFields = TabDetailFields::getInstance($fld_module);
        $ProductToolFieldsInfo = $ProductToolFields->getTabDetailFields();
    } else {
        crm_load_class_file('ProductToolFields', 'include/ProductDetails');
        $ProductToolFields = ProductToolFields::getInstance($fld_module);
        $tabid = getTabid($fld_module);
        $languageType = getLanguageType($current_user);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid, $languageType);
    }
    $detailtable = $focus->Detail_table;
    $detailtablescf = $focus->Detail_table_scf;
    foreach ($ProductToolFieldsInfo as $tmpindex => $productfieldinfo) {
        $tablename = $productfieldinfo->getTableName();
        //ls 20220907 BUG0056188 合同订单新增字段，选择分录函数无法选择分录的引用的数字字段（路总要引用字段放开,引用字段的$tablename 为引用字段所在表）
//        if ($tablename == $detailtable || $tablename == $detailtablescf) {
        //根据分录函数显示不同类型的字段
        if ($productfieldinfo->isFldNumOrMoney() || $productfieldinfo->isTaxPercentField()) {
            $EntryFuncfieldarr['numamount'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
        } elseif (in_array($productfieldinfo->getUIType(), array("5", "51", "256", "23", "14", "86", "70"))) {//date：5、51、256、23 time：14 datetime：86、70
            $EntryFuncfieldarr['date'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
        } elseif (!in_array($productfieldinfo->getUIType(), array("69"))){
            $EntryFuncfieldarr['string'][$productfieldinfo->getColumnName()] = $productfieldinfo->getfieldLabel();
        }
//        }
    }

    // 数字金额类型；数字金额日期类型（maxdate、mindate合并到了max、min）；其他类型，显示全部字段
    $smarty->assign('EntryFunction', array("Avg"=>getFixedLabel("Avg"), "Count"=>getFixedLabel("COUNT"), "CountDistinct"=>getFixedLabel("CountDistinct"), "First"=>getFixedLabel("FirstLine"), "Last"=>getFixedLabel("LastLine"), "Max"=>getFixedLabel("Max"), "Min"=>getFixedLabel("Min"), "Sum"=>getFixedLabel("Summation")));//分录函数
    $smarty->assign('EntryFuncfieldarr', $EntryFuncfieldarr);//分录函数-参数字段
}
$smarty->assign('isEntryModule',$isEntryModule);//是否为分录模块

//ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型【已存在的模块新增字段时不显示“快递查询组件”】
//不能使用 $focus->fieldobj->getFieldInfoobjBykey("bigtype", 'express') 判断，有缺点，新增字段保存后对象里取不到新增字段。
$result = $adb->pquery("SELECT 1 from ld_field where tabid = ? and bigtype = ?",array(getTabid($fld_module),'express'));
if ($adb->num_rows($result) >= 1) {
    $isExistExpress = 'yes';
}else
    $isExistExpress = 'no';
$smarty->assign('isExistExpress',$isExistExpress);//当前模块是否已存在“快递查询组件”字段类型

$_REQUEST['diony']='yes';
//XUQIU1001765 xxy 2023-8-11 页面设置/单据分录定制，“日期”和“日期时间”字段默认值下拉选项增加显示n天前选项
$afterdayNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];
$afterdayinfo_arr = array();
foreach ($afterdayNums as $dayNum) {
    $afterdayinfo_arr[] = array(
        'value' => "afterday" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("AFTERDAY")
    );
}
$daysagoNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];
$daysagoinfo_arr = array();
foreach ($daysagoNums as $dayNum) {
    $daysagoinfo_arr[] = array(
        'value' => "daysago" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("DAYSAGO")
    );
}
$smarty->assign('AfterDayInfo',$afterdayinfo_arr);
$smarty->assign('DaysAgoInfo',$daysagoinfo_arr);

//跟编辑逻辑保持一致
crm_load_class_file("StaticConst",'WeiXinApp/WeiXin_common');
//判断当前模块是开启了源单定位
$isOpenSignIn = 'no';
$classname = 'cls_' . $fld_module . '_DetailViewWX';
if(file_exists(globalStatic::$root_directory.'WeiXinApp/modules/' . $fld_module . '/cls_' . $fld_module.'/'.$classname.'.php')){
    crm_load_class_file('cls_Instance','WeiXinApp/WeiXin_common');
    $detialViewWx = cls_Instance::get_moduleAction_Instance($fld_module,'DetailView');
    if($detialViewWx->isOpenSignIn($fld_module,'boolean'))
        $isOpenSignIn = 'yes';
}
$smarty->assign('isOpenSignIn',$isOpenSignIn);

//edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
crm_load_class_file('FieldSet', 'modules/Settings/FieldSet');
$timeFormatArr = FieldSet::getTimeFormatInfo();
$smarty->assign('timeFormatArr', json_encode($timeFormatArr));

if($_REQUEST['ajax'] != 'true') {

    $arr['content']=$smarty->fetch('Settings/LayoutBlockListNew.tpl');
    ConvertTojsonString(1,$arr,'success');


}
elseif(($subMode=='getRelatedInfoOrder' || $subMode == 'changeRelatedInfoOrder') &&  $_REQUEST['ajax'] == 'true')
{
    $smarty->display('Settings/OrderRelatedList.tpl');
}
elseif(($subMode=='getParametersInfoOrder' || $subMode == 'changeParametersInfoOrder') && $_REQUEST['ajax'] == 'true')
{
    $smarty->display('Settings/ParamentersList.tpl');
}
elseif(($subMode=='getRelaInfoOrder' || $subMode == 'changeRelatedPersence') && $_REQUEST['ajax'] == 'true')
{
    $smarty->display('Settings/RelatedOrder.tpl');
}
//andy 修改区块中英文名称
elseif($subMode=='relatedlistdiv_blockname' && $_REQUEST['ajax'] == 'true')
{
    $blockid_zh=gettranslabelblocks($_REQUEST['tabid'],$_REQUEST['blockid'],'zh');
    $blockid_en=gettranslabelblocks($_REQUEST['tabid'],$_REQUEST['blockid'],'en');
    $smarty->assign('fildlable_zh',$blockid_zh);
    $smarty->assign('fildlable_en',$blockid_en);
    $smarty->assign('tabid',$_REQUEST['tabid']);
    $smarty->assign('modulename',getTabname($_REQUEST['tabid']));
    $smarty->assign('blockid',$_REQUEST['blockid']);

    $arr['title'] = getFixedLabel('EDITPROPERTIES');
//BUG0066295: 模块管理>页面设置>编辑属性弹出框可以进行拖拽  余俊  2023/5/15
     $arr['oktext']=getFixedLabel("SAVE");
     $arr['canceltext']=getFixedLabel("CANCEL");
     $str=$smarty->fetch("Settings/relatedlistdiv_blockname.tpl");
     $arr['content']=$str;
     ConvertTojsonString(1,$arr,"success");
}

//右边操作列快捷设置
elseif($subMode=='QuickSetActions' && $_REQUEST['ajax'] == 'true')
{
    if($_REQUEST['modulename'] != 'Events' )
        $tabid=getTabid($_REQUEST['modulename']);
    else
        $tabid=16;
    $actions_arr=GetRelatedList_action($tabid);
    $actions_arr_userd=GetRelatedList_action_userd($tabid);
    //print_r($actions_arr_userd);
    $smarty->assign('tabid',$tabid);
    $smarty->assign('actions_arr',$actions_arr);
    $smarty->assign('actions_arr_userd',$actions_arr_userd);
    $smarty->assign('modulename',$_REQUEST['modulename']);
    echo '###SUCCESS###';
    $smarty->display('Settings/Quicksetactions.tpl');
}
else {

    $smarty->display('Settings/LayoutBlockEntriesNew.tpl');
}


/**
 * Function to get customfield entries
 * @param string $module - Module name
 * return array  $cflist - customfield entries
 */
/**
 * getFieldListEntries()
 *
 * @return
 */
function getFieldListEntries($module) {
    global $handleWriteSign_interface;
    if($module=='Events')
    {
        $tabid =16;
    }
    else
    {
        $tabid = getTabid($module);
    }
    global $adb, $smarty,$current_user;
    global $theme;
    $theme_path="themes/".$theme."/";
    $image_path="themes/images/";

    require('user_privileges/user_language_'.$current_user->id.'.php');
    $otherlanguage='zh';
    if($languageType=='zh')
    {
        $otherlanguage='en';
    }
    $notShowModulecolumns['Users']=array('time_zone','date_format','activity_view','lead_view','language','theme','email2','reports_to_id','currency_id','email2','secondaryemail','phone_other','level','hour_format','start_hour');
    $dbQuery = "select distinct ld_tranlabel.fieldlabel as blocklabel,ld_blocks.blockid,display_status,0 as tabpresence ,ld_blocks.sequence,iscustom,ld_blocks.blocklabel as block_label 
                    from ld_blocks inner join ld_tranlabel on ld_tranlabel.relateid=ld_blocks.blockid
                    " .
        " where languagetype=? and trantable=? and    ld_tranlabel.tabid=? and ld_blocks.tabid=? and   visible=0 and blocklabel<>'LBL_PUBLICACCOUNT_LOG'  ";
    if($module == 'Users'){
        $dbQuery .="and blocklabel<>'LBL_CURRENCY_CONFIGURATION' and blocklabel<>'LBL_MORE_INFORMATION'";
    }
    $dbQuery .=' order by ld_blocks.sequence,ld_blocks.blockid asc ';
    $result = $adb->pquery($dbQuery, array($languageType,'ld_blocks',$tabid,$tabid));
    $row = $adb->fetch_array($result);

    $focus = CRMEntity::getInstance($module);

    $nonEditableUiTypes = array('70','117');//chj:不能编辑，必须启用uitype类型,//edit:can uitype=4的删除掉 ,bug:13349: 项目任务模块的某些字段的权限有问题
    $fieldobj=Field::getInstance($module,$adb);
    $referenceFieldNames = array_keys($fieldobj->getReferenceFieldDetails());

    $cflist=Array();
    $i=0;
    if($row!='') {
        do {
            if($row["blocklabel"] == 'LBL_CUSTOM_INFORMATION' ) {
                $smarty->assign("CUSTOMSECTIONID",$row["blockid"]);
            }
            if($row["blocklabel"] == 'LBL_RELATED_PRODUCTS' ) {
                $smarty->assign("RELPRODUCTSECTIONID",$row["blockid"]);
            }
            if($row["blocklabel"] == 'LBL_COMMENTS' || $row['blocklabel'] == 'LBL_COMMENT_INFORMATION' ) {
                $smarty->assign("COMMENTSECTIONID",$row["blockid"]);
            }

            if($row['blocklabel'] == '') {
                continue;
            }
            $cflist[$i]['tabpresence']= $row['tabpresence'];
            $cflist[$i]['module'] = $module;
            $cflist[$i]['blocklabel']=($row["blocklabel"]);
            $cflist[$i]['block_label'] = $row['block_label'];
            $cflist[$i]['blockid']=$row["blockid"];
            $cflist[$i]['display_status']=$row["display_status"];
            $cflist[$i]['tabid']=$tabid;
            $cflist[$i]['blockselect']=$row["blockid"];
            $cflist[$i]['sequence'] = $row["sequence"];
            $cflist[$i]['iscustom'] = $row["iscustom"];
            /**
             * edit:chj
             * date:2014-8-26
             * reason:在sql语句中加入tabid的条件
             * description:服务收费跟客户的ld_field信息一样，如不加tabid判断，会导致页面信息中所有区块信息重复
             * */
            //approve_demand不知道干嘛的  还是没提供脚本
            if($module!='Invoices' && $module!='Quotes' && $module!='SalesOrder' && $module!='Invoice') {
                $sql_field="select distinct ld_tranlabel.fieldlabel, othertable.otherlabel,ld_field.fieldid,
                columnname,defaultvalue ,block,uitype,fieldonly,presence,fieldname,quickcreate,masseditable,typeofdata,
                displaytype ,approve_demand,advance_demand,advance_demand_groups,allowhide,isenablepresence
                from  ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                 inner join (select ld_tranlabel.fieldlabel as otherlabel,relateid from ld_tranlabel inner
                  join ld_field on ld_field.fieldid=ld_tranlabel.relateid where languagetype=? 
                  and trantable=? and block=?  and ld_tranlabel.tabid=? and ld_field.tabid=? order by sequence,fieldid asc ) as othertable 
                             on othertable.relateid=ld_tranlabel.relateid
                     where languagetype=? and trantable=? and ld_field.tabid = ? and  block=? and ld_tranlabel.tabid=? and ld_field.tabid=?  and ld_field.displaytype IN (1,2,4) order by sequence,fieldid asc ";
                $sql_field_params = array($otherlanguage,'ld_field',$row["blockid"],$tabid,$tabid,
                    $languageType,'ld_field',$tabid,$row["blockid"],$tabid,$tabid,);



            }else {
                $sql_field="select distinct ld_tranlabel.fieldlabel, othertable.otherlabel,ld_field.fieldid,columnname
                        ,defaultvalue ,block,uitype,fieldonly,presence,fieldname,quickcreate,masseditable,typeofdata 
                        ,displaytype,approve_demand,advance_demand,advance_demand_groups,allowhide,isenablepresence
                            from  ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
                             inner join (select ld_tranlabel.fieldlabel as otherlabel,relateid from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid where languagetype=? and trantable=? and block=?  and ld_tranlabel.tabid=? order by sequence,fieldid asc ) as othertable 
                             on othertable.relateid=ld_tranlabel.relateid
                     where languagetype=? and trantable=? and ld_field.tabid = ? and   block=? and  ld_tranlabel.tabid=? and (ld_field.fieldlabel!='Total' and ld_field.fieldlabel!='Sub Total' and ld_field.fieldlabel!='Tax') and ld_field.displaytype IN (1,2,4) order by sequence,fieldid asc  ";

                $sql_field_params = array($otherlanguage,'ld_field',$row["blockid"],$tabid,$languageType,'ld_field',$tabid,$row["blockid"],$tabid);
            }

            $result_field = $adb->pquery($sql_field,$sql_field_params);
            $row_field= $adb->fetch_array($result_field);
//            $nums_forkeywords=$adb->num_rows($result_field);

            if($row_field!='') {
                $cf_element=Array();
                $cf_hidden_element=Array();
                $count=0;
                $hiddencount=0;

                do {
                    $fieldid = $row_field['fieldid'];
                    $presence = $row_field['presence'];
                    $fieldname = $row_field['fieldname'];
                    $customfieldflag=InStrCount($row_field['fieldname'],'cf_',true);
                    $quickcreate = $row_field['quickcreate'];
                    $massedit = $row_field['masseditable'];
                    $typeofdata = $row_field['typeofdata'];
                    $displaytype = $row_field['displaytype'];
                    $uitype = $row_field['uitype'];
                    $isenablepresence = $row_field['isenablepresence'];

                    if($isenablepresence == 'no'){
                        continue;
                    }
                    if($uitype==222&&$handleWriteSign_interface==0)
                    {
                        continue;
                    }
                    $fieldonly=$row_field['fieldonly'];

                    $fld_type_name = getCustomFieldTypeName($row_field['uitype']);
                    $defaultValue = $row_field['defaultvalue'];
                    $approve_demand=$row_field['approve_demand'];
                    $advance_demand=$row_field['advance_demand'];
                    $advance_demand_groups=$row_field['advance_demand_groups'];
                    $allowhide=$row_field['allowhide'];

                    if(!empty($defaultValue) && ($uitype == '5' || $uitype == '6' || $uitype == '23' || $uitype == '86')) {
                        //21558: 控制面板>页面设置>销售机会：编辑字段“预计成交日期”，设置默认值为明天，保存后，查看该字段属性，还是显示为“今天”
                        //$defaultValue = date("Y-m-d",strtotime($defaultValue));
                    }
                    if(is_array($notShowModulecolumns[$module])&&in_array($row_field['columnname'],$notShowModulecolumns[$module]))
                    {
                        continue;
                    }

                    //费用报销币种已迁移到了明细里，在这里因为考虑到其他报表使用了币种计算费用金额，所以不直接deleted永久隐藏处理
                    if($module == 'Expense' && $row_field['columnname'] == 'currency_id'){
                        continue;
                    }
                    $fieldlabel = getTranFieldForModuleLabel($row_field['fieldlabel']);
                    $otherlabel=($row_field['otherlabel']);

                    $defaultPermitted = true;
                    $strictlyMandatory = false;
                    if(isset($focus->mandatory_fields) && (!empty($focus->mandatory_fields)) && in_array($fieldname, $focus->mandatory_fields)) {
                        $strictlyMandatory = true;
                        $defaultPermitted = false;
                    } elseif (in_array($uitype, $nonEditableUiTypes) || $displaytype == 2) {
                        $strictlyMandatory = true;
                        $defaultPermitted = false;
                    }
                    if(in_array($fieldname, $referenceFieldNames)) {
                        $defaultPermitted = false;
                    }
                    $visibility = getFieldInfo($fieldname,$typeofdata,$quickcreate,$massedit,$presence,$strictlyMandatory,$customfieldflag,$displaytype,$uitype);
                    if($module == 'Users'){
                        if(in_array($fieldname,array('user_name','user_password','confirm_password','last_name','profileid'))){
                            $visibility['mandatory'] = 4;
                        }
                    }
                    //if($visibility)
                    $allValues = array();
                    if(in_array($uitype, array('15','16','33'))) {

                        if($fieldname == 'approvestatus' && $module=='Users'){
                            $allValues = array(getFixedLabel('ACTIVATE'),getFixedLabel('INACTIVATE'));
                        }
                        else
                        {

                            //$allValues = getAllPickListValues($fieldname);
                        }

                    }

                    if(in_array($uitype,array('251','252')))
                    {

                        crm_load_class_file("BankAccountSet","modules/BankAccountSet");
                        $bankresult=BankAccountSet::getBackAccount(1);

                        for($tmpi=0;$tmpi<$adb->num_rows($bankresult);$tmpi++)
                        {
                            $allValues[$adb->query_result($bankresult,$tmpi,'bankaccountsetid')]=$adb->query_result($bankresult,$tmpi,'accountname');

                        }


                    }

                    if ($presence == 0 || $presence == 2) {
                        $cf_element[$count]['fieldselect']=$fieldid;
                        $cf_element[$count]['blockid']=$row['blockid'];
                        $cf_element[$count]['tabid']=$tabid;
                        $cf_element[$count]['no']=$count;
                        $cf_element[$count]['label']=$fieldlabel;
                        $cf_element[$count]['otherlabel'] =$otherlabel;
                        $cf_element[$count]['fieldlabel'] = $row_field['fieldlabel'];
                        $cf_element[$count]['type']=$fld_type_name;
                        $cf_element[$count]['typeofdata']=$typeofdata;
                        $cf_element[$count]['uitype']=$uitype;
                        $cf_element[$count]['columnname']=$row_field['columnname'];

                        $cf_element[$count]['defaultvalue']= array('permitted' => $defaultPermitted, 'value' => $defaultValue, '_allvalues' => $allValues);
                        $cf_element[$count] = array_merge($cf_element[$count], $visibility);
                        $cf_element[$count]['fieldonly']=$row_field['fieldonly'];
                        $cf_element[$count]['displaytype']=$displaytype;
                        $cf_element[$count]['approve_demand']=$approve_demand;
                        $cf_element[$count]['advance_demand']=$advance_demand;
                        $cf_element[$count]['advance_demand_groups']=$advance_demand_groups;
                        $cf_element[$count]['allowhide']=$allowhide;

                        $count++;
                    } else {
                        $cf_hidden_element[$hiddencount]['fieldselect']=$fieldid;
                        $cf_hidden_element[$hiddencount]['blockid']=$row['blockid'];
                        $cf_hidden_element[$hiddencount]['tabid']=$tabid;
                        $cf_hidden_element[$hiddencount]['no']=$hiddencount;
                        $cf_hidden_element[$hiddencount]['label']=$fieldlabel;
                        $cf_hidden_element[$hiddencount]['otherlabel'] = $otherlabel;
                        $cf_hidden_element[$hiddencount]['fieldlabel'] = $row_field['fieldlabel'];
                        $cf_hidden_element[$hiddencount]['type']=$fld_type_name;
                        $cf_hidden_element[$hiddencount]['typeofdata']=$typeofdata;
                        $cf_hidden_element[$hiddencount]['uitype']=$uitype;
                        $cf_hidden_element[$hiddencount]['columnname']=$row_field['columnname'];

                        $cf_hidden_element[$hiddencount]['defaultvalue']= array('permitted' => $defaultPermitted, 'value' => $defaultValue, '_allvalues' => $allValues);
                        $cf_hidden_element[$hiddencount] = array_merge($cf_hidden_element[$hiddencount], $visibility);
                        $cf_hidden_element[$hiddencount]['fieldonly']=$row_field['fieldonly'];
                        $cf_hidden_element[$hiddencount]['approve_demand']=$row_field['approve_demand'];
                        $cf_hidden_element[$hiddencount]['advance_demand']=$row_field['advance_demand'];
                        $cf_hidden_element[$hiddencount]['advance_demand_groups']=$row_field['advance_demand_groups'];
                        $hiddencount++;
                    }
                } while($row_field = $adb->fetch_array($result_field));

                $cflist[$i]['no']=$count;
                $cflist[$i]['hidden_count'] = $hiddencount;
            }
            else {
                $cflist[$i]['no']= 0;
            }
            //edit:can reason:13342: 控制面板>>页面设置：点击【移动字段】按钮，希望“移动字段”弹出框中，已隐藏的字段不要显示。
            if($module=='Faq')
            {
                $query_fields_not_in_block ='select fieldid,ld_tranlabel.fieldlabel,block,allowhide from ld_field ' .
                    'inner join ld_blocks on ld_field.block=ld_blocks.blockid inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid ' .
                    'where languagetype=? and trantable=? and ld_field.block != ? and ld_blocks.blocklabel not in ("LBL_COMMENTS") ' .
                    'AND ld_field.tabid = ? and  ld_tranlabel.tabid=? and ld_field.displaytype IN (1,2,4) and ld_field.presence in(0,2) order by ld_field.sequence';
            }
            else
            {
                $query_fields_not_in_block ='select fieldid,ld_tranlabel.fieldlabel,block,allowhide from ld_field ' .
                    'inner join ld_blocks on ld_field.block=ld_blocks.blockid inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid ' .
                    'where languagetype=? and trantable=? and ld_field.block != ? and ld_blocks.blocklabel not in ("LBL_COMMENTS","LBL_COMMENT_INFORMATION") ' .
                    'AND ld_field.tabid = ? and  ld_tranlabel.tabid=? and ld_field.displaytype IN (1,2,4) and ld_field.presence in(0,2) order by ld_field.sequence';
            }


            $params =array($languageType,'ld_field',$row['blockid'],$tabid,$tabid);

            $fields = $adb->pquery($query_fields_not_in_block,$params);
            $row_field= $adb->fetch_array($fields);

            if($row_field != '') {
                $movefields = array();
                $movefieldcount = 0;
                do {
                    $movefields[$movefieldcount]['fieldid'] =  $row_field['fieldid'];
                    $movefields[$movefieldcount]['fieldlabel'] =  ($row_field['fieldlabel']);
                    $movefieldcount++;
                }while($row_field = $adb->fetch_array($fields));
                $cflist[$i]['movefieldcount'] = $movefieldcount;
            }
            else {
                $cflist[$i]['movefieldcount'] = 0 ;
            }

            $cflist[$i]['field']= $cf_element;
            $cflist[$i]['hiddenfield']= $cf_hidden_element;
            $cflist[$i]['movefield'] = $movefields;

            $cflist[$i]['hascustomtable'] = $focus->customFieldTable;
            if($cflist[$i]['block_label'] == 'LBL_ACCOUNT_PRIMARYCONTACT'){
                $cflist[$i]['hascustomtable'] = '';
            }

            unset($cf_element);
            unset($cf_hidden_element);
            unset($movefields);
            $i++;
        } while($row = $adb->fetch_array($result));
    }

    return $cflist;
//    return ['cflist' =>$cflist,'keyword_sseq_arr'=> $keyword_sseq_arr];
}

//wyt 221214 BUG0059887 kfbcrm 合同订单---合计，调整，整单折扣字段----在页面设置，关键信息栏当中选不到  BUG0060476 成员管理->页面设置，关键信息栏设置显示字段保存后，关键信息栏区块的显示字段显示的不对，仍是上次设置的显示字段
function getFieldListEntriesForKeywords($module){
    global $adb;
    $fieldobj=new Field($module,$adb);

    $keyword_sseq_arr1 = $fieldobj->getFieldInfoobjBykey_arr('keywords','yes');
    $keyword_sseq_arr  = json_decode(json_encode($keyword_sseq_arr1),true);
    $sortarr = _array_column($keyword_sseq_arr,'keyword_sseq');
    array_multisort($sortarr,SORT_ASC,$keyword_sseq_arr);//给字段重新排序
    return $keyword_sseq_arr;
}
/* function to get the modules supports Custom Fields
*/
/**
 * getCustomFieldSupportedModules()
 *
 * @return
 */
function getCustomFieldSupportedModules() {
    global $adb;
    $sql="select distinct ld_field.tabid,name from ld_field inner join ld_tab on ld_field.tabid=ld_tab.tabid where ld_field.tabid not in(9,10,16,15,8,29)";
    $result = $adb->query($sql);
    while($moduleinfo=$adb->fetch_array($result)) {
        $modulelist[$moduleinfo['name']] = $moduleinfo['name'];
    }
    return $modulelist;
}

/**
 *
 */
/**
 * changeFieldOrder()
 *
 * @return
 */
function changeFieldOrder() {
    global $adb,$smarty;
    if(!empty($_REQUEST['what_to_do'])) {
        if($_REQUEST['what_to_do']=='block_down'||$_REQUEST['what_to_do']=='block_up')
        {
            //17320: 控制面板>页面设置,关于移动区块的问题
            $sql='select sequence ,blockid from ld_blocks where tabid=? order by  sequence, blockid asc';
            $blockresult=$adb->pquery($sql,array($_REQUEST['tabid']));
            $add_sequence=0;//必须一行一行更新sequence

            for($k=0;$k<$adb->num_rows($blockresult);$k++)
            {
                $add_sequence++;
                $addblockid=$adb->query_result($blockresult,$k,'blockid');
                $sqladd='update ld_blocks set sequence=? where blockid=? ';
                $adb->pquery($sqladd,array($add_sequence,$addblockid));
                // echo $add_sequence."<br>";
            }

        }

        if($_REQUEST['what_to_do']=='block_down') {
            $sql="select sequence from ld_blocks where blockid=?";
            $result = $adb->pquery($sql, array($_REQUEST['blockid']));
            $row= $adb->fetch_array($result);
            $current_sequence=$row['sequence'];

            $sql_next="select * from ld_blocks where sequence > ? and tabid=? ORDER BY sequence asc limit 0,1";
            $result_next = $adb->pquery($sql_next, array($current_sequence,$_REQUEST['tabid']));
            $row_next= $adb->fetch_array($result_next);
            $next_sequence=$row_next['sequence'];
            $next_id=$row_next['blockid'];


            $sql_up_current="update ld_blocks  set sequence=? where blockid=?";
            $result_up_current = $adb->pquery($sql_up_current, array($next_sequence,$_REQUEST['blockid']));


            $sql_up_next="update ld_blocks  set sequence=? where blockid=?";
            $result_up_next = $adb->pquery($sql_up_next, array($current_sequence,$next_id));
        }

        if($_REQUEST['what_to_do']=='block_up') {
            $sql="select * from ld_blocks where blockid=?";
            $result = $adb->pquery($sql, array($_REQUEST['blockid']));
            $row= $adb->fetch_array($result);
            $current_sequence=$row['sequence'];

            $sql_previous="select * from ld_blocks where sequence < ? and tabid=?  order by sequence desc limit 0,1";
            $result_previous = $adb->pquery($sql_previous, array($current_sequence,$_REQUEST['tabid']));
            $row_previous= $adb->fetch_array($result_previous);
            $previous_sequence=$row_previous['sequence'];
            $previous_id=$row_previous['blockid'];


            $sql_up_current="update ld_blocks  set sequence=? where blockid=?";
            $result_up_current = $adb->pquery($sql_up_current, array($previous_sequence,$_REQUEST['blockid']));


            $sql_up_previous="update ld_blocks  set sequence=? where blockid=?";
            $result_up_previous = $adb->pquery($sql_up_previous, array($current_sequence,$previous_id));
        }
        //下，右开始
        if($_REQUEST['what_to_do']=='down' || $_REQUEST['what_to_do']=='Right')
        {
            //edit :can reason:9030: 控制面板->页面设置，调整字段顺序按钮有时无法移动字段的位置。
            $sql='select sequence ,fieldid from ld_field where  block=? and presence in(0,2) order by  sequence, fieldid asc';
            $fieldresult=$adb->pquery($sql,array($_REQUEST['blockid']));
            $add_sequence=0;//必须一行一行更新sequence
            for($k=0;$k<$adb->num_rows($fieldresult);$k++)//所有数据重新排序(因为null,例如有5行seq为null，然后null的下一行为小于5的数据)
            {
                $add_sequence++;
                $addfieldid=$adb->query_result($fieldresult,$k,'fieldid');
                $sqladd='update ld_field set sequence=? where fieldid=? and block=?';
                $adb->pquery($sqladd,array($add_sequence,$addfieldid,$_REQUEST['blockid']));
            }
            $sql="select sequence from ld_field where fieldid=? and ld_field.presence in (0,2)";
            $result = $adb->pquery($sql, array($_REQUEST['fieldid']));
            $row= $adb->fetch_array($result);
            $current_sequence=$row['sequence'];

            if($_REQUEST['what_to_do']=='down') {
                $sql_next="select sequence,fieldid from ld_field where sequence > ? and block = ? and ld_field.presence in (0,2) order by sequence,fieldid asc limit 1,1";
                $sql_next_params = array($current_sequence, $_REQUEST['blockid']);
            }else {
                $sql_next="select sequence,fieldid from ld_field where sequence > ? and block = ? and ld_field.presence in (0,2) order by sequence,fieldid asc limit 0,1";
                $sql_next_params = array($current_sequence, $_REQUEST['blockid']);
            }

            if(empty($current_sequence))
            {
                $current_sequence=1;
            }
            $result_next = $adb->pquery($sql_next,$sql_next_params);

            if($adb->num_rows($result_next)<=0)  //如果没有查询到数据，说明排序的两个字段 是按照fieldid asc
            {
                //edit :can reason:9030: 控制面板->页面设置，调整字段顺序按钮有时无法移动字段的位置。
                $sql='select sequence ,fieldid from ld_field where block=? and presence in(0,2) order by fieldid asc';
                $fieldresult=$adb->pquery($sql,array($_REQUEST['blockid']));
                $add_sequence=$current_sequence;//必须一行一行更新sequence
                for($k=0;$k<$adb->num_rows($fieldresult);$k++)
                {
                    $add_sequence++;
                    $addfieldid=$adb->query_result($fieldresult,$k,'fieldid');
                    $sqladd='update ld_field set sequence=? where fieldid=? and block=?';
                    $adb->pquery($sqladd,array($add_sequence,$addfieldid,$_REQUEST['blockid']));
                }

                if($_REQUEST['what_to_do']=='down') {
                    $sql_next="select sequence,fieldid from ld_field where sequence > ? and block = ? and ld_field.presence in (0,2) order by sequence,fieldid asc limit 1,1";
                    $sql_next_params = array($current_sequence, $_REQUEST['blockid']);
                }else {
                    $sql_next="select sequence,fieldid from ld_field where sequence > ? and block = ? and ld_field.presence in (0,2) order by sequence,fieldid asc limit 0,1";
                    $sql_next_params = array($current_sequence, $_REQUEST['blockid']);
                }
                $result_next = $adb->pquery($sql_next,$sql_next_params);
            }


            $row_next= $adb->fetch_array($result_next);
            $next_sequence=$row_next['sequence'];
            $next_id=$row_next['fieldid'];
            if(empty($current_sequence)&&!empty($next_sequence))
            {
                $current_sequence=$next_sequence-1;
            }
            if(empty($next_sequence)&&!empty($current_sequence))
            {
                $next_sequence=$current_sequence+1;
            }

            $sql_up_current="update ld_field  set sequence=? where fieldid=?";
            $result_up_current = $adb->pquery($sql_up_current, array($next_sequence,$_REQUEST['fieldid']));

            $sql_up_next="update ld_field  set sequence=? where fieldid=?";
            $result_up_next = $adb->pquery($sql_up_next, array($current_sequence,$next_id));

            $smarty->assign("COLORID",vtlib_purify($_REQUEST['fieldid']));
        }
        //下，右结束
        //上左开始
        if($_REQUEST['what_to_do']=='up' || $_REQUEST['what_to_do']=='Left') {
            $sql='select sequence ,fieldid from ld_field where block=? and presence in(0,2) order by sequence, fieldid asc';
            $fieldresult=$adb->pquery($sql,array($_REQUEST['blockid']));
            $add_sequence=0;//必须一行一行更新sequence
            for($k=0;$k<$adb->num_rows($fieldresult);$k++)
            {
                $add_sequence++;
                $addfieldid=$adb->query_result($fieldresult,$k,'fieldid');
                $sqladd='update ld_field set sequence=? where fieldid=? and block=?';
                $adb->pquery($sqladd,array($add_sequence,$addfieldid,$_REQUEST['blockid']));
            }
            $sql="select * from ld_field where fieldid=? and ld_field.presence in (0,2)";
            $result = $adb->pquery($sql, array($_REQUEST['fieldid']));
            $row= $adb->fetch_array($result);
            $current_sequence=$row['sequence'];

            if($_REQUEST['what_to_do']=='up') {
                $sql_previous="select * from ld_field where sequence < ? and block=? and ld_field.presence in (0,2) order by sequence desc limit 1,1";
                $sql_prev_params = array($current_sequence,$_REQUEST['blockid']);
            }else {
                $sql_previous="select * from ld_field where sequence < ? and block=? and ld_field.presence in (0,2) order by sequence desc limit 0,1";
                $sql_prev_params = array($current_sequence,$_REQUEST['blockid']);
            }

            $result_previous = $adb->pquery($sql_previous,$sql_prev_params);
            $row_previous= $adb->fetch_array($result_previous);
            if($adb->num_rows($result_previous)<=0)
            {
                //edit :can reason:9030: 控制面板->页面设置，调整字段顺序按钮有时无法移动字段的位置。
                $sql='select sequence ,fieldid from ld_field where  block=? and presence in(0,2) order by  sequence, fieldid asc';
                $fieldresult=$adb->pquery($sql,array($_REQUEST['blockid']));
                $add_sequence=0;//必须一行一行更新sequence
                for($k=0;$k<$adb->num_rows($fieldresult);$k++)//所有数据重新排序(因为null,例如有5行seq为null，然后null的下一行为小于5的数据)
                {
                    $add_sequence++;
                    $addfieldid=$adb->query_result($fieldresult,$k,'fieldid');
                    $sqladd='update ld_field set sequence=? where fieldid=? and block=?';
                    $adb->pquery($sqladd,array($add_sequence,$addfieldid,$_REQUEST['blockid']));
                }
                if($_REQUEST['what_to_do']=='up') {
                    $sql_previous="select sequence,fieldid from ld_field where sequence < ? and block=? and ld_field.presence in (0,2) order by sequence desc limit 1,1";
                    $sql_prev_params = array($current_sequence,$_REQUEST['blockid']);
                }else {
                    $sql_previous="select sequence,fieldid from ld_field where sequence < ? and block=? and ld_field.presence in (0,2) order by sequence desc limit 0,1";
                    $sql_prev_params = array($current_sequence,$_REQUEST['blockid']);
                }
                $result_previous = $adb->pquery($sql_previous,$sql_prev_params);
                $row_previous= $adb->fetch_array($result_previous);
            }


            $previous_sequence=$row_previous['sequence'];

            $previous_id=$row_previous['fieldid'];

            $sql_up_current="update ld_field  set sequence=? where fieldid=?";
            $result_up_current = $adb->pquery($sql_up_current, array($previous_sequence,$_REQUEST['fieldid']));

            $sql_up_previous="update ld_field  set sequence=? where fieldid=?";
            $result_up_previous = $adb->pquery($sql_up_previous, array($current_sequence,$previous_id));
            $smarty->assign("COLORID",vtlib_purify($_REQUEST['fieldid']));
        }
        //上左结束
        if($_REQUEST['what_to_do']=='show') {
            $sql_up_display="update ld_blocks  set display_status='1' where blockid=?";
            $result_up_display = $adb->pquery($sql_up_display, array($_REQUEST['blockid']));
        }

        if($_REQUEST['what_to_do']=='hide') {
            $sql_up_display="update ld_blocks  set display_status='0' where blockid=?";
            $result_up_display = $adb->pquery($sql_up_display, array($_REQUEST['blockid']));
        }

        //隐藏
        if($_REQUEST['what_to_do']=='none') {
            $sql_up_display="update ld_blocks  set display_status='2' where blockid=?";
            $result_up_display = $adb->pquery($sql_up_display, array($_REQUEST['blockid']));
        }
//        230413 BUG0062118 wyt 页面设置，标签区块名称前面去掉“开启”选项（展开和收起已经默认有开启功能了），另外“展开”标签修改为“开启-展开”，“收起”标签修改为“开启-收起”
//        //开启
//        if($_REQUEST['what_to_do']=='open') {
//            $sql_up_display="update ld_blocks  set display_status='3' where blockid=?";
//            $result_up_display = $adb->pquery($sql_up_display, array($_REQUEST['blockid']));
//       }
    }
    unsetCacheDirectory("fields");


}

/**
 * updateFieldProperties()
 *
 * @return
 */
function updateFieldProperties() {
    global $adb,$smarty,$current_user;
    $fieldid = $_REQUEST['fieldid'];
    $ColorTypeArr = vtlib_purify($_REQUEST['ColorTypeArr']);
    $memberrangetype=($_REQUEST['memberrangetype']);
    $memberrange=($_REQUEST['memberrange']);
    //project :	PROT387  edit:cyb date:2016-08-04 reason:更新ld_field中审批要求字段approve_demand；
    $approve_demand=$_REQUEST['approve_demand'];
    // @edit:liushuai,2020-09-15,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮(增加组合条件后又删除需要处理数据去掉null)
    $advance_demand=json_decode(trim($_REQUEST['advance_demand']??''));
    if (!empty($advance_demand)) {
        $index = 1;
        $tmp_advance_demand = [];
        foreach ($advance_demand as $advft_criteria_obj){
            if (empty($advft_criteria_obj)) continue;
            // $advft_criteria_obj->groupid = $index;
            $tmp_advance_demand[] = $advft_criteria_obj;
            // $index++;
        }

        $advance_demand = json_encode($tmp_advance_demand);
    }


    $advance_demand_groups = json_decode(trim($_REQUEST['advance_demand_groups']??''));
    if (!empty($advance_demand_groups)) {
        $index = 1;
        $tmp_advance_demand_groups = [];
        foreach ($advance_demand_groups as $advft_criteria_groups_obj){

            $tmp_advance_demand_groups[] = $advft_criteria_groups_obj;
            $index++;
        }
        $advance_demand_groups = json_encode($tmp_advance_demand_groups);
    }

    if(is_array($advance_demand))
    {
        $advance_demand=json_encode($advance_demand);
    }
    if(is_array($advance_demand_groups))
    {
        $advance_demand_groups=json_encode($advance_demand_groups);

    }

    if($approve_demand==0||$approve_demand==1){
        $update_approve_demand_sql='update ld_field set approve_demand=?,advance_demand=?,advance_demand_groups=? where fieldid=?';
        //   echo $update_approve_demand_sql;
        // dump(array($approve_demand,$advance_demand,$advance_demand_groups,$fieldid));
        $adb->pquery($update_approve_demand_sql,array($approve_demand,$advance_demand,$advance_demand_groups,$fieldid));

        //dump(array($approve_demand,$advance_demand,$advance_demand_groups,$fieldid));
    }
    /**
     * 称谓之前是跟名称放在一起，现在分开来访，需要能修改称谓的翻译
     * @reason 0012903: 联系人页面设置界面：更改“称谓”中文名称无法更改
     * @author Tujt 2014-12-12
     */
    //and fieldname not in('salutationtype')
    $req_sql = "select typeofdata,tabid,fieldname,uitype,fieldlabel,tablename,quickcreate,masseditable,presence,
    fieldonly,columnname,bigtype,relatedmodulefield,allowedit from ld_field where fieldid = ? and ld_field.presence in (0,2)";
    $req_result = $adb->pquery($req_sql, array($fieldid));

    $typeofdata = $adb->query_result($req_result,0,'typeofdata');
    $tabid = $adb->query_result($req_result,0,'tabid');

    $fieldname = $adb->query_result($req_result,0,'fieldname');
    $uitype = $adb->query_result($req_result,0,'uitype');
    $oldfieldlabel = $adb->query_result($req_result,0,'fieldlabel');
    $tablename = $adb->query_result($req_result,0,'tablename');
    $columnname = $adb->query_result($req_result,0,'columnname');
    $oldquickcreate = $adb->query_result($req_result,0,'quickcreate');
    $oldmassedit = $adb->query_result($req_result,0,'masseditable');
    $oldpresence = $adb->query_result($req_result,0,'presence');
    $bigtype=$adb->query_result($req_result,0,'bigtype');
    $relatedmodulefield=$adb->query_result($req_result,0,'relatedmodulefield');
//wyt 220927 BUG0057114 自用系统-图中这里选不到其他人
    if($bigtype=='selectoneuser'||$bigtype=='selectmultiuser'||$bigtype=='users'||($bigtype=='text' && $uitype=='154')){
        if(!empty($memberrangetype)){
            if(!empty($memberrange)){
                $update_memberrangetype_sql='update ld_field set advance_demand=?,advance_demand_groups=? where fieldid=?';
                $adb->pquery($update_memberrangetype_sql,array($memberrange,$memberrangetype,$fieldid));
            }else{
                $update_memberrangetype_sql='update ld_field set advance_demand=?,advance_demand_groups=? where fieldid=?';
                $adb->pquery($update_memberrangetype_sql,array('',$memberrangetype,$fieldid));
            }
        }
    }

    if($tabid==6)//客户
    {
        $servicecharge_tabid=getTabid('ServiceCharge');
        $req_sql = "select fieldid from ld_field where columnname = ? and tabid=?  and ld_field.presence in (0,2)";

        $service_charge_req_result = $adb->pquery($req_sql, array($columnname,$servicecharge_tabid));
        if($adb->num_rows($service_charge_req_result))
        {
            $service_charge_id=$adb->query_result($service_charge_req_result,0,0);
        }

    }
    if(!empty($_REQUEST['fld_module'])) {
        $fld_module = vtlib_purify($_REQUEST['fld_module']);//Account

    }else {
        $fld_module = getTabModuleName($tabid);
    }

    $focus = CRMEntity::getInstance($fld_module);

    $fieldtype =  explode("~",$typeofdata);
    $mandatory_checked= $_REQUEST['ismandatory'];
    $quickcreate_checked = $_REQUEST['quickcreate'];
    $presence_check = $_REQUEST['isPresent'];
    $massedit_check = $_REQUEST['massedit'];
    $fieldonly_check = $_REQUEST['fieldonly'];
    $allowedit=$_REQUEST['allowedit'];
    $fieldvaluecolor=$_REQUEST['fieldvaluecolor'];//zxm 2021-1230 字段颜色 字段说明
    if(isset($_REQUEST['labelvaluecolor']) && !empty($_REQUEST['labelvaluecolor'])){
        $label_style = array('color' => $_REQUEST['labelvaluecolor']);//wsh 20240815 标签颜色
        $label_style_str = json_encode($label_style);
    }else{
        $label_style_str = '';
    }
    $fieldplaceholder=$_REQUEST['fieldplaceholder'];
    $inputModeType = vtlib_purify($_REQUEST['inputModeType']);//录入方式 0 手动录入 1 分录函数  2公式计算 3通过sql。1和2存为formula
//   编辑字段、放开"允许编辑"属性(路总要求，灿哥确认)
    /*if ($relatedmodulefield != 'yes' && $inputModeType != 1) {//该字段如果不是引用字段，就不能修改allowedit，设置了分录函数的字段可以修改属性“允许编辑”
        //@edit:hzx,2023-08-08,reason: BUG0070777 新增字段设置为“通过SQL查询”，字段设置反选“允许编辑”不生效，保存后再次查看还是勾选了“允许编辑”
        if($inputModeType != 3){
            $allowedit = $_REQUEST['allowedit'] = $adb->query_result($req_result,0,'allowedit');
        }
    }*/
    $fieldlabel=trim($_REQUEST['fieldlabel']);
    $fieldlabels=trim($_REQUEST['fieldlabels']);
    $defaultvalue = vtlib_purify($_REQUEST['defaultvalue']);

    $formulastring = vtlib_purify($_REQUEST['formulacontent']);
    $formulavar = vtlib_purify($_REQUEST['formulavar']);
    $formulacolumn = vtlib_purify($_REQUEST['formulacolumn']);
    $functiontype = vtlib_purify($_REQUEST['functiontype']);
    $functioncolumn = vtlib_purify($_REQUEST['functioncolumn']);


    //签到字段
    $auto_signin = vtlib_purify($_REQUEST['auto_signin']);
    $no_signin = vtlib_purify($_REQUEST['no_signin']);
    $allowable_distance = vtlib_purify($_REQUEST['allowable_distance']);
    $editview_signin = vtlib_purify($_REQUEST['editview_signin']);
    $editview_resignin = vtlib_purify($_REQUEST['editview_resignin']);
    //将销售负责人的默认值保存为一个引用字段
    if(($columnname == 'smownerid'||$columnname == 'servicecasher')&&$uitype == 53){
        if($defaultvalue!='cur_user'&&$defaultvalue!=""){
            $valuearr = explode('##',$defaultvalue);
            if(count($valuearr)<=1){
                //获取默认值并进行处理
                $valuearr = explode('_',$defaultvalue);
            }

            $relatemodule=$valuearr[0];
            //获取关联字段id

            if($relatemodule=='Accounts'&&($fld_module=='Accounts'||$fld_module=='ServiceCharge')){
                $sqltrigger="select  fieldid ,columnname from ld_field where uitype=51";
                $result=$adb->pquery($sqltrigger,array());
            }else{
                $sqltrigger="select  fieldid ,columnname from ld_field where uitype in(
                        select ld_ws_fieldtype.uitype from ld_ws_fieldtype INNER JOIN
                         ld_ws_referencetype on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid
                        where ld_ws_referencetype.type=?) and presence in(0,2)
                        and tabid=?";
                $result=$adb->pquery($sqltrigger,array($relatemodule,$tabid));
            }
            $trigger_fieldid=$adb->query_result($result,0,'fieldid');
            if(empty($trigger_fieldid)){
                $sourcefieldinfo=$focus->fieldobj->getFieldInfoobjBykey("bigtype",'selectsource');
                if($sourcefieldinfo){
                    $trigger_fieldid=$sourcefieldinfo->getFieldid();
                }
            }
            if($relatemodule=='ServiceCharge'){
                $trigger_columnname = 'servicecasher';
            }else{
                $trigger_columnname = 'smownerid';
            }
            if(strpos($defaultvalue,'##') !== false){
                $trigger_columnname = $valuearr[1];
            }
            //判断需要新增还是更新
            $select_sql = "select * from ld_related_field where effect_fieldid = ? ";
            $tmpresult = $adb->pquery($select_sql,array($fieldid));

            if($adb->num_rows($tmpresult)>0){
                $update_sql = 'update ld_related_field set frommodule = ?,trigger_fieldid=?,fromvalue_info=? where effect_fieldid = ? ';
                $adb->pquery($update_sql,array($relatemodule,$trigger_fieldid,$trigger_columnname,$fieldid));
            }else{
                $insert_sql = 'insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,
                                fromvalue_type,fromvalue_info,frommodule) values(?,?,?,?,?,?,?);';
                $adb->pquery($insert_sql,array('main',$trigger_fieldid,$fieldid,$columnname,'column',$trigger_columnname,$relatemodule));
            }
        }else{
            //选择当前用户时去掉关联字段
            $delete_sql = 'delete from ld_related_field where effect_fieldid = ? ';
            $adb->pquery($delete_sql,array($fieldid));
        }
        $defaultvalue = '';
    }

    $fldallow_rewriting = vtlib_purify($_REQUEST['fldallow_rewriting']);
    $take_photo_only = vtlib_purify($_REQUEST['take_photo_only']);
    $maxrowsshow=$_REQUEST['maxrowsshow'];//选择模块的字段列表最多显示行数
    $datarang=$_REQUEST['datarang'];//选择模块的字段列表查询范围
    if(($fld_module=='CashBill'&&$columnname=='cashtype')||($fld_module=='Leads'&&$columnname=='status'))
    {
        //edit:can 4268: （xiaoshou360.com/xs/hzhengqi）财务管理-收款单；单据编号GR891；在页面设置中，将“收款类型”字段，勾选批量编辑后，该字段在单据详情可以编辑了，实际业务应该是不可编辑的
        //edit:can 2021-03-01 44791: （https://61mis.com/kfbcrm [^]）客户问题（李潮辉），销售线索“商机状态”字段应该修改为不可编辑字段，涉及位置如下：
        $allowedit='no';
    }
    if($uitype==33)
    {

        if (is_array($defaultvalue)) {

            $field_list = implode(' |##| ', $defaultvalue);
        }
        else if(strpos($defaultvalue,'########')!=false)
        {
            //列表界面ajax保存
            $field_list = implode(' |##| ', explode("########",$defaultvalue));
        }
        else {

            $field_list = $defaultvalue;


        }

        $defaultvalue = $field_list;
    }
    if(!empty($defaultvalue) && ($defaultvalue == 1 || $defaultvalue== 2 || $defaultvalue == 3)&&(strtolower($fieldtype[0])=='d'||strtolower($fieldtype[0])=='dt')){
        switch($defaultvalue){
            case 1:
                $defaultvalue = "thistoday";
                break;
            case 2:
                $defaultvalue = "thistomorrow";
                break;
            case 3:
                $defaultvalue = "thisextmonth";
                break;
        }
    }
    //duan 20230227 拜访签到的时间字段默认值为当前时间
    if($fld_module == 'Singin' && $columnname == 'createdtime'){
        $defaultvalue = "thistoday";
    }



    if(isset($focus->mandatory_fields) && (!empty($focus->mandatory_fields)) && in_array($fieldname, $focus->mandatory_fields)) {
        $fieldtype[1] = 'M';
    } elseif($mandatory_checked == 'true' || $mandatory_checked == '') {
        $fieldtype[1] = 'M';
    } else {
        $fieldtype[1] = 'O';
    }
    //页面设置-编辑文本类型 选择字符长度
    if($uitype == 1 && $bigtype == 'text' && isset($_REQUEST['fldlength']))
    {
        $fldlength = $_REQUEST['fldlength'];
        if($fieldtype[2]=='LE')
        {
            if($fldlength != $fieldtype[3])
            {
                $fieldtype[3] = $fldlength;
                //zkt 20241112 BUG20241111-49 华企：销售订单数据库字段长度问题报错
                if((int)$fldlength<=255){
                    $adb->pquery("alter table $tablename modify column $columnname varchar($fldlength)",array());
                }
                else{
                    $adb->pquery("alter table $tablename modify column $columnname text",array());
                }
            }
        }
        else
        {
            if($fldlength != $fieldtype[2])
            {
                $fieldtype[2] = $fldlength;
                $adb->pquery("alter table $tablename modify column $columnname varchar($fldlength)",array());
            }
        }
    }
    //页面设置-编辑数字类型 选择小数位数
    if($uitype == 7 && $bigtype == 'number' && isset($_REQUEST['fldDecimal']))
    {
        $fldDecimal = $_REQUEST['fldDecimal'];
        $tmpdecimalarr = explode(',',$fieldtype[2]);
        if($tmpdecimalarr[1]!=$fldDecimal)
        {
            //对应table中字段修改修改
            $tmpfldllength = $tmpdecimalarr[0];
            //if($fldDecimal>8)
//            {
//                $fldDecimal=8;
//            }
            $dbfldlength = $tmpfldllength + $fldDecimal + 1;

            if($dbfldlength>34)
            {
                $dbfldlength=25;
            }

            if($fldDecimal>=$dbfldlength)
            {
                $dbfldlength=$fldDecimal+10+1;
                $tmpfldllength=$dbfldlength;
            }
            $adb->pquery("alter table $tablename modify column $columnname decimal(".$dbfldlength.",".$fldDecimal.")",array());

            //ld_field中typeofdata修改
            $tmpdecimalarr[1] = $fldDecimal;
            $tmpdecimalarr[0] = $tmpfldllength;
            $fieldtype[2] = implode(',',$tmpdecimalarr);

        }
    }
    $datatype = implode('~', $fieldtype);
    $maxseq = '';
    if($oldpresence != 3) {
        if($presence_check == 'true' || $presence_check == '') {
            $presence = 2;
        }else {
            $presence = 1;
        }
    }else {
        $presence =1;
    }
    if($bigtype=='mobile')
    {
        if($presence==1||$_REQUEST['regexp']==0)
        {
            $sql='delete from ld_validatasavedetail where relateid in(select id from ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?)';
            $adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));

            $sql=' delete from  ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?';
            $adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));
        }
        else
        {
            $sql='select id from ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?';
            $tmpresult=$adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));
            if($adb->num_rows($tmpresult)<=0)
            {
                $sql='insert into  ld_validatasave(module,relatedtable,fieldname,comparator,formulavalue,comparatordescription,validatasavetype,isshowlist)
                            value(?,?,?,?,?,?,?,?)';
                $adb->pquery($sql,array($fld_module,'ld_field',$fieldname,'regexp','','正则表达式','js','no'));
                $tmp_relateid=$adb->getLastInsertID();
                $sql='insert into  ld_validatasavedetail(relateid,relateformulavalue,sequence)value(?,?,?)';
                $adb->pquery($sql,array($tmp_relateid,"^1\\d{10}$",1));
            }
        }

    }
    //0033023: 联系人模块改了字段名，客户首要联系人区块下的那些字段也同步修改；
    $tabmodulename = getTabModuleName($tabid);
    if($tabid==4 || ($tabmodulename == 'Accounts' && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')) || ($tabmodulename == 'ServiceCharge' && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')))//联系人	、客户 、服务收费管理
    {
        $servicechargetabid=getTabid('ServiceCharge');
        if($tabid == 4){
            $update_tabid = array(6,$servicechargetabid);
        }else if($tabmodulename == 'Accounts'){
            $update_tabid = array($servicechargetabid);
        }else{
            $update_tabid = array(6);
        }
        $colname=$columnname;
        foreach($update_tabid as $stabid){
            //$sql="update ld_field set typeofdata=?,presence=?,fieldonly=? where columnname=? and tabid=?";
            //$adb->pquery($sql,array($datatype,$presence,$fieldonly_check,$colname,$stabid));
            $sql="update ld_tranlabel set  fieldlabel=?  where languagetype=? and trantable=? and relateid in (select fieldid  from ld_field where columnname=?  and tablename=? and tabid=?)";
            $adb->pquery($sql,array($fieldlabel,'zh','ld_field',$colname,$tablename,$stabid));
            $sql="update ld_tranlabel set  fieldlabel=?  where languagetype=? and trantable=? and relateid in (select fieldid  from ld_field where columnname=?  and tablename=? and tabid=?)";
            $adb->pquery($sql,array($fieldlabels,'en','ld_field',$colname,$tablename,$stabid));
            //更换中文文本标签，ld_field里的fieldlabel也同步更新
            $sql="update ld_field set fieldlabel =?  where columnname=? and tablename=? and tabid=? "	;
            $adb->pquery($sql,array($fieldlabel,$columnname,$tablename,$stabid));
            $sql="update ld_field set presence =?  where columnname=? and tablename=? and tabid=? "	;
            $adb->pquery($sql,array($presence,$columnname,$tablename,$stabid));
        }
        $cachekey = 'cache_productdetails_setModuleFields_'.$tabmodulename.'_setModuleFields_'.$current_user->profileid;
        unsetCache($cachekey);
    }

    if($bigtype == 'signin'){
        $sql="update ld_field set auto_signin=?,no_signin=?,allowable_distance=?,editview_signin=?,editview_resignin=? where fieldid=?";
        $adb->pquery($sql,array($auto_signin,$no_signin,$allowable_distance,$editview_signin,$editview_resignin,$fieldid));

    }

    if(!empty($service_charge_id))
    {
        $colname=$columnname;
        $sql="update ld_field set typeofdata=?,presence=?,fieldonly=? where fieldid=?";
        $adb->pquery($sql,array($datatype,$presence,$fieldonly_check,$service_charge_id));
    }

    if($presence_check=='false')//是否启用
    {
        $sql=' update ld_field set presence=1 where fieldid=? ';
        $adb->pquery($sql,array($fieldid));
        $fld_module = $_REQUEST["fld_module"];
        if(!empty($service_charge_id))
        {
            $sql='update ld_field set presence=1 where fieldid=?';
            $adb->pquery($sql,array($service_charge_id));
        }
        //字段不启用时，判断字段是否被用在移动端列表设置，若有，不启用时删除在ld_cvcolumnlist_wx的行
        $query = "select columnname,id from ld_cvcolumnlist_wx  where  modulename = ? ";
        $result=$adb->pquery($query,array($fld_module));
        $num_rows = $adb->num_rows($result);
        if($num_rows>=1){
            for($i = 0; $i < $num_rows; $i++){
                $mobile_colname = $adb->query_result($result,$i,'columnname');
                $mobile_id = $adb->query_result($result,$i,'id');
                $col_array = explode(':',$mobile_colname);
                if($col_array[1]==$columnname){
                    $query = "delete from ld_cvcolumnlist_wx where id = ?";
                    $adb->pquery($query,array($mobile_id));
                }
            }
        }
    }

    //0033363: 合同订单：关闭“上级合同”字段后，合同相关信息不应该显示【变更单（子合同）】
    if(getTabModuleName($tabid) == 'SalesOrder' && $colname == 'parentid'){	//客户
        $related_module = getTabModuleName($tabid);
        $query = 'update ld_relatedlists set presence = ? where tabid = ? and related_tabid = ? and `name` = \'get_salesorder\' and label = ?';
        $adb->pquery($query,array($presence,$tabid,$tabid,$related_module));
    }

    if($oldmassedit != 3) {
        if((rtrim((string)$massedit_check) == 'true' || $massedit_check == '')) {
            $massedit = 1;
        }else {
            $massedit = 2;
        }
    }else {
        $massedit=1;
    }

    if(isset($focus->mandatory_fields) && (!empty($focus->mandatory_fields))) {
        $fieldname_list = implode(',',$focus->mandatory_fields);
    }else {
        $fieldname_list = '';
    }

    if(!empty($fieldname_list)){
        $mandatory_query = "update ld_field set typeofdata=? ,fieldonly=? ,allowedit=? where fieldid=? and fieldname not in (?) AND displaytype != 2";
        $mandatory_params = array($datatype,$fieldonly_check,$allowedit,$fieldid,$fieldname_list);
    }else{
        $mandatory_query = "update ld_field set typeofdata=? ,fieldonly=?,allowedit=? where fieldid=? AND displaytype != 2";
        $mandatory_params = array($datatype,$fieldonly_check,$allowedit,$fieldid);
    }
    //签到字段特殊处理
    if($uitype == 306){
        $mandatory_query = "update ld_field set typeofdata=? ,fieldonly=?,allowedit=? where fieldid=? ";
        $mandatory_params = array($datatype,$fieldonly_check,$allowedit,$fieldid);
    }

    $adb->pquery($mandatory_query, $mandatory_params);
    if(!empty($service_charge_id))
    {
        $mandatory_query = "update ld_field set typeofdata=? ,fieldonly=? where fieldid=? and fieldname not in (?) AND displaytype != 2";
        $mandatory_params = array($datatype,$fieldonly_check,$service_charge_id,$fieldname_list);
        $adb->pquery($mandatory_query, $mandatory_params);
    }
    if($_REQUEST['quickcreate']&&$oldquickcreate != 3)
    {
        if($_REQUEST['quickcreate']=='false')
        {
            $qcdata=1;
        }
        else
        {
            $qcdata=0;
        }
        //edit:can reason:10454: 控制面板->页面设置，编辑字段，勾选“快速创建”，然后保存，结果保存后的字段“快速创建”勾选状态无法取消。
        $quickcreate_query = "update ld_field set quickcreate = ? where fieldid = ? and quickcreate not in (3) AND displaytype != 2";
        $quickcreate_params = array($qcdata,$fieldid);
        $adb->pquery($quickcreate_query,$quickcreate_params);

    }
    if(empty($take_photo_only))$take_photo_only = 0;
    if(empty($fldallow_rewriting))$fldallow_rewriting = 0;
    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
    $ShowHyperlinks = empty($_REQUEST['ShowHyperlinks'])?'yes':$_REQUEST['ShowHyperlinks'];//显示超链接 no 不显示 yes 显示
    //edit: hzx 是否小计
    $subtotal_attr = $_REQUEST['subtotal_attr'];
    // ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
    $disallowed_copy_check = $_REQUEST['disallowed_copy'];
    //zkt 20231108 XUQIU1001871 分配与查看范围，分配时可见成员根据数据范围显示，不显示全部成员
    $showallgroupstructure_check = empty($_REQUEST['showallgroupstructure'])?'yes':$_REQUEST['showallgroupstructure'];
    // xxy 2023-11-15 XUQIU1001176 页面设置/单据分录定制，增加“内容过多自动换行”字段属性
    $auto_wordwrap = $_REQUEST['auto_wordwrap'];
    // 2024-06-05 xxy XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊）
    $helptips = $_REQUEST['helptips'];

    // edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
    $valueFormat = '';
    $formatTypeArr = ['date', 'datetime', 'time'];
    if(in_array($bigtype, $formatTypeArr)) {
        $valueFormat = vtlib_purify($_REQUEST['value_format'] ?? '');
    }
    
    $updateSql = ' update ld_field set take_photo_only = ?,maxrowsshow=?,datarang=?,fldallow_rewriting = ?,showhyperlinks=?,subtotal_attr=?,disallowed_copy=?, showallgroupstructure=?,
                     autowordwrap=?,helptips=?, value_format=? where fieldid=?';
    $updateParam = [ $take_photo_only,$maxrowsshow,$datarang,$fldallow_rewriting,$ShowHyperlinks,$subtotal_attr,$disallowed_copy_check, $showallgroupstructure_check,
        $auto_wordwrap, $helptips, $valueFormat, $fieldid ];
    $adb->pquery($updateSql, $updateParam );


    $presence_query = "update ld_field set presence = ?,fieldonly=? where fieldid = ? and presence not in (0,3) and quickcreate != 0";
    $quickcreate_params = array($presence,$fieldonly_check,$fieldid);
    $adb->pquery($presence_query,$quickcreate_params);

    $massedit_query = "update ld_field set masseditable = ? ,fieldonly=? where fieldid = ? and masseditable not in (0,3) AND displaytype != 2";
    $massedit_params = array($massedit,$fieldonly_check,$fieldid);

    $adb->pquery($massedit_query,$massedit_params);

    $defaultvalue_query = "update ld_field set defaultvalue=? where fieldid = ? and fieldname not in (?) AND displaytype != 2";
    $defaultvalue_params = array($defaultvalue,$fieldid,$fieldname_list);

    $adb->pquery($defaultvalue_query, $defaultvalue_params);

    if(!empty($service_charge_id))//服务收费管理
    {
        $defaultvalue_query = "update ld_field set defaultvalue=? where fieldid = ? and fieldname not in (?) AND displaytype != 2";
        $defaultvalue_params = array($defaultvalue,$service_charge_id,$fieldname_list);
        $adb->pquery($defaultvalue_query, $defaultvalue_params);
    }
    $sql=' update ld_tranlabel set fieldlabel=? where languagetype=? and trantable=? and tabid=? and relateid=?';
    $pqaram=array($fieldlabel,'zh','ld_field',$tabid,$fieldid);
    $pqaramz=array($fieldlabels,'en','ld_field',$tabid,$fieldid);
    $adb->pquery($sql, $pqaram);
    $adb->pquery($sql, $pqaramz);
    //更新字段标签，ld_field表里的fieldlabel也同步更新
    $sql='update ld_field set fieldlabel =? where tabid=? and fieldid=?';
    $adb->pquery($sql,array($fieldlabel,$tabid,$fieldid));
    //跟新字段标签，自定义字段操作日志的中英文标签也同步更换
    $sql='update ld_cfoperationlog set fieldlabel_zh =? where tabid=? and fieldid=?';
    $adb->pquery($sql,array($fieldlabel,$tabid,$fieldid));
    $sql='update ld_cfoperationlog set fieldlabel_en =? where tabid=? and fieldid=?';
    $adb->pquery($sql,array($fieldlabels,$tabid,$fieldid));
    if(!empty($service_charge_id))//服务收费管理（客户修改后，服务收费管理也要修改）
    {
        $sql=' update ld_tranlabel set fieldlabel=? where languagetype=? and trantable=? and tabid=? and relateid=?';
        $pqaram=array($fieldlabel,'zh','ld_field',$servicecharge_tabid,$service_charge_id);
        $pqaramz=array($fieldlabels,'en','ld_field',$servicecharge_tabid,$service_charge_id);
        $adb->pquery($sql, $pqaram);
        $adb->pquery($sql, $pqaramz);
        //更新字段标签，ld_field表里的fieldlabel也同步更新
        $sql='update ld_field set fieldlabel =? where tabid=? and fieldid=?';
        $adb->pquery($sql,array($fieldlabel,$servicecharge_tabid,$service_charge_id));
        //跟新字段标签，自定义字段操作日志的中英文标签也同步更换
        $sql='update ld_cfoperationlog set fieldlabel_zh =? where tabid=? and fieldid=?';
        $adb->pquery($sql,array($fieldlabel,$servicecharge_tabid,$service_charge_id));
        $sql='update ld_cfoperationlog set fieldlabel_en =? where tabid=? and fieldid=?';
        $adb->pquery($sql,array($fieldlabels,$servicecharge_tabid,$service_charge_id));
    }
    //zxm2021-0408 二维码字段类型 修改二维码类型
    $fdcodetype_value = $_REQUEST['fdcodetype_value'];
    if(!empty($fdcodetype_value)){
        $sql=' update ld_field set uitype=? where fieldid=?';
        $adb->pquery($sql, [$fdcodetype_value,$fieldid]);
    }
    //zxm 2021-1230 Text、textarea、longtextarea三个类型字段 需要修改字段颜色和字段说明
    $colortypearr = explode(',',$ColorTypeArr);
    if(in_array($bigtype,$colortypearr) || $bigtype == 'url')
    {

        $sql=' update ld_field set label_style=?,fieldvaluecolor=?,fieldplaceholder=? where fieldid=?';
        $adb->pquery($sql, [$label_style_str, $fieldvaluecolor, $fieldplaceholder, $fieldid]);
    }
    //wsh 修改标签颜色
    $sql = ' update ld_field set label_style=? where fieldid=?';
    $adb->pquery($sql, [$label_style_str, $fieldid]);
    $qrcodetemplateid = $_REQUEST['qrcodetemplateid'];
    if(!empty($qrcodetemplateid)){
        $sql=' update ld_qrcode_template set fieldid=? where qrcodetemplateid=?';
        $adb->pquery($sql, [$fieldid,$qrcodetemplateid]);
    }

    //@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）
    $uploadwatermark = vtlib_purify($_REQUEST['uploadwatermark']);
    if (!empty($uploadwatermark)) {
        $sql = 'update ld_field set uploadwatermark=? where fieldid=?';
        $adb->pquery($sql, array($uploadwatermark, $fieldid));
    }
    //注：录入方式可以修改
    if ($inputModeType == 2 || $inputModeType == 3) {//公式 或者sql
        $vars = array_filter(explode(',', $formulavar));
        $columns = array_filter(explode(',', $formulacolumn));

        $columnstring = "{formulavar:[";
        for ($i = 0; $i < sizeof($vars); $i++) {
            $columnstring .= "{'lettervar':'" . $vars[$i] . "','column':'" . $columns[$i] . "'}";
            if ($i != sizeof($vars) - 1) {
                $columnstring .= ",";
            }
        }
        $columnstring .= ']}';

        if (!empty($formulastring)) {
            //替换错误的括号
            $formulastring = str_replace('（','(',$formulastring);
            $formulastring = str_replace('）',')',$formulastring);

            $input_type = 'formula';
        } else {
            //沒有设置字段公式的改为手动录入
            $input_type = '';
            $inputModeType = 0;
        }

        if($inputModeType == 3) {
            $functiontype = 'sql';

            //检查sql合理性
            $checksql = parserSql($formulastring);
            if ($checksql['code'] != 1) {
                echo 'CHECKSQLERROR';
                exit;
            }
        }

    }
    else if ($inputModeType == 1) {
        $columnstring = trim($functioncolumn);//分录函数选择的函数
        $input_type = 'formula';
//        $allowedit = 'no';
        $savedatabase = 'yes';
    } else {//$inputModeType == 0 手动录入
        $input_type = '';
    }

    $sql = 'delete from ld_field_formula where fieldid=?  ';
    $adb->pquery($sql, array($fieldid));
    if ($input_type == 'formula') {
        if (!empty($columnstring)) {
            $sql = 'insert ld_field_formula(formulastring,columnstring,fieldid,functiontype) value(?,?,?,?)';
            $param = array($formulastring, $columnstring, $fieldid, $functiontype);
            $adb->pquery($sql, $param);
        }
    }
    $sql = "update ld_field set input_type=?,allowedit=? where fieldid=?";
    $adb->pquery($sql, array($input_type, $allowedit, $fieldid));
    // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
    $word_watermark = vtlib_purify($_REQUEST['word_watermark']);
    $excel_watermark = vtlib_purify($_REQUEST['excel_watermark']);
    if($uitype == 1109 || $uitype == 1108 || $uitype == 28){
        $sql = "update ld_field set word_watermark=?,excel_watermark=? where fieldid=?";
        $adb->pquery($sql, array($word_watermark, $excel_watermark, $fieldid));
    }

    //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
    if($bigtype === 'fileattachment') {
        getFileAllowedFromUrl($advance_demand,$advance_demand_groups);
        $sql = "update ld_field set advance_demand=?,advance_demand_groups=? where fieldid=?";
        $adb->pquery($sql, array($advance_demand, $advance_demand_groups, $fieldid));
    }



    //xxy 2023-11-8 敏感规则编辑保存启用状态
    if($_REQUEST['sensitivepresence'] != ""){
        $sensitivepresence = $_REQUEST['sensitivepresence'];
        crm_load_class_file("cls_SensitiveRules",'modules/Settings');
        cls_SensitiveRules::updateFieldSensitiveStatus($fieldid,$sensitivepresence);
    }

    //25912: 客户列表：设置列表上“N天未联系”字段不显示，在返回到列表查看时，界面会显示一块灰色区域
    unsetCacheDirectory('customview');
    unsetCacheDirectory('Cache');
    clearCacheFiles();//删除数据缓存
    unsetCacheDirectory('fields');
    //zkt 20230817 收付款单增加分录字段清除缓存
    if($fld_module == 'CashBill'||$fld_module=='SendCashBill'){
        unsetCacheDirectory('productfields');
    }
    @unlink('include/language/zh.php');
    @unlink('include/language/en.php');
}



/**
 * deleteCustomField()
 *
 * @return
 */
function deleteCustomField() {
    global $adb,$current_user;
    $fld_module = $_REQUEST["fld_module"];
    $tabid=getTabid($fld_module);
    $servicecharge_tabid=getTabid('ServiceCharge');

    $id = $_REQUEST["fld_id"];
    $colName = $_REQUEST["colName"];
    $uitype = $_REQUEST["uitype"];

    $fieldquery = 'select * from ld_field where fieldid = ?';
    $res = $adb->pquery($fieldquery,array($id));

    $typeofdata = $adb->query_result($res,0,'typeofdata');
    $fieldname = $adb->query_result($res,0,'fieldname');
    $oldfieldlabel = $adb->query_result($res,0,'fieldlabel');
    $tablename = $adb->query_result($res,0,'tablename');
    $columnname = $adb->query_result($res,0,'columnname');
    $fieldtype =  explode("~",$typeofdata);
    $input_type = $adb->query_result($res,0,'input_type');
    $allowdelete=$adb->query_result($res,0,'allowdelete');

    //删除字段时判断字段allowdelete
    if($allowdelete != 'yes'){
        //前端有判断，这里用作后台判断。
        return;
    }
    //删除字段时，自定义操作字段表，更新删除操作者与删除时间
    $query ="select tabid from ld_cfoperationlog where fieldid = ?";
    $cfresult = $adb->pquery($query,array($id));
    $num_rows = $adb->num_rows($cfresult);
    //判断历史自定义字段在不在表里，若没有插入相关数据进ld_cfoperationlog
    if($num_rows<1){
        $sql=" insert into ld_cfoperationlog(`tabid`,`fieldid`,`uitype`,`bigtype`,`relatedmodulefield`,`fieldlabel_zh`,`createdtime`) 
                select `tabid`,`fieldid`,`uitype`,`bigtype`,`relatedmodulefield`,`fieldlabel`,`createdtime` from ld_field where `fieldid` =?";
        $adb->pquery($sql,array($id));
    }
    $sql="update ld_cfoperationlog set delete_operator =? ,modifiedtime=?,deletedtime =? where fieldid = ? and tabid=? ";
    $adb->pquery($sql,array($current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),$id,$tabid));



    //Deleting the CustomField from the Custom Field Table
    //删除字段时，判断字段是否被用在移动端列表设置，若有，同时删除在ld_cvcolumnlist_wx的行
    $query = "select columnname,id from ld_cvcolumnlist_wx  where  modulename = ? ";
    $result=$adb->pquery($query,array($fld_module));
    $num_rows = $adb->num_rows($result);
    if($num_rows>=1){
        for($i = 0; $i < $num_rows; $i++){
            $mobile_columnname = $adb->query_result($result,$i,'columnname');
            $mobile_id = $adb->query_result($result,$i,'id');
            $col_arr = explode(':',$mobile_columnname);
            if($col_arr[1]==$columnname){
                $query = "delete from ld_cvcolumnlist_wx where id = ?";
                $adb->pquery($query,array($mobile_id));
            }
        }
    }

    $query='delete from ld_field where fieldid = ? and ld_field.presence in (0,2)';
    $adb->pquery($query, array($id));

    //Deleting from ld_profile2field table
    $query='delete from ld_profile2field where fieldid=?';
    $adb->pquery($query, array($id));

    //Deleting from ld_def_org_field table
    $query='delete from ld_def_org_field where fieldid=?';
    $adb->pquery($query, array($id));

    $focus = CRMEntity::getInstance($fld_module);

    $deletecolumnname =$tablename .":". $columnname .":".$fieldname.":".$fld_module. "_" .str_replace(" ","_",$oldfieldlabel).":".$fieldtype[0];
    /**
     *Liver 20160413
     * bug0021562删除自定义字段后，列表数据无法显示出来
     * 为防止错误，我重新定义了一个$newdeletecolumnname，原来的$deletecolumnname不正确
     */
    $newdeletecolumnname =$tablename .":". $columnname .":".$fieldname;
    $column_cvstdfilter = 	$tablename .":". $columnname .":".$fieldname.":".$fld_module. "_" .str_replace(" ","_",$oldfieldlabel);
    $select_columnname = $tablename.":".$columnname .":".$fld_module. "_" . str_replace(" ","_",$oldfieldlabel).":".$fieldname.":".$fieldtype[0];
    $reportsummary_column = $tablename.":".$columnname.":".str_replace(" ","_",$oldfieldlabel);

    //zkt 20220617 BUG0052923客户问题（普阳会计），客户（联系人）（重庆棒三商贸有限公司）单据列表界面，“客户来源”字段使用小编辑保存数据后不生效，界面没有显示内容
    $sql  = "select * from ld_field where columnname=? and tablename =?";
    $result = $adb->pquery($sql,array($columnname,$tablename));
    if($adb->num_rows($result)<=0)
    {
        $dbquery = 'alter table '. $adb->sql_escape_string($focus->customFieldTable[0]).' drop column '. $adb->sql_escape_string($colName);
        $adb->pquery($dbquery, array());
    }

    //To remove customfield entry from ld_field table
    $dbquery = 'delete from ld_field where columnname= ? and fieldid=? and ld_field.presence in (0,2)';
    $adb->pquery($dbquery, array($colName, $id));
    //we have to remove the entries in customview and report related tables which have this field ($colName)

    $adb->pquery("delete from ld_cvcolumnlist where columnname like ?", array('%'.$newdeletecolumnname.'%'));
    $adb->pquery("delete from ld_cvstdfilter where columnname = ?", array($column_cvstdfilter));
    $adb->pquery("delete from ld_cvadvfilter where columnname = ?", array($deletecolumnname));
    $adb->pquery("delete from ld_selectcolumn where columnname = ?", array($select_columnname));
    $adb->pquery("delete from ld_relcriteria where columnname = ?", array($select_columnname));
//    $adb->pquery("delete from ld_reportsortcol where columnname = ?", array($select_columnname));
//    $adb->pquery("delete from ld_reportdatefilter where datecolumnname = ?", array($column_cvstdfilter));
//    $adb->pquery("delete from ld_reportsummary where columnname like ?", array('%'.$reportsummary_column.'%'));
    $adb->pquery("delete from ld_picklist_dependency where targetfield = ? and tabid = ?", array($columnname,$tabid));

    $adb->pquery("delete from ld_tranlabel where trantable='ld_field' and  relateid=$id");
    $adb->pquery("delete from ld_related_field where fieldtype='main' and trigger_fieldid=$id");
    $adb->pquery("delete from ld_related_field where fieldtype='main' and effect_fieldid=$id");

    //删除字段公式或者分录函数
    if ($input_type == 'formula') {
        $adb->pquery("delete from ld_field_formula where fieldid=?",array($id));
    }
    /**
     * @edit:chj
     * @date:2014-9-24
     * @reason:删除客户自定义字段  同时删除服务收费的相同自定义字段，和字段的权限
     * @description:0011667: 客户页面设置中，删除自定义字段，结果该删除的字段仍然在“服务收费”模块客户资料中显示。
     */
    /*
    if($tabid==6)
    {//$servicecharge_tabid
        $query='delete from ld_profile2field where fieldid=(select fieldid from ld_field where columnname = ? and tabid = ?)';
    	$adb->pquery($query, array($colName,$servicecharge_tabid));

    	//Deleting from ld_def_org_field table
    	$query='delete from ld_def_org_field where fieldid=(select fieldid from ld_field where columnname = ? and tabid = ?)';
    	$adb->pquery($query, array($colName,$servicecharge_tabid));

        $adb->pquery("delete from ld_tranlabel where trantable='ld_field' and relateid in (select fieldid from ld_field where columnname='$colName' and tabid= $servicecharge_tabid)");
        $adb->pquery("delete from ld_field where columnname = ? and tabid = ?",array($colName,$servicecharge_tabid));

        if ($uitype == 1600)
            $adb->pquery("delete from ld_related_field where fieldtype='main' and curmodule_columninfo=?",array($colName));//成员所属部门的类型，删除时应该删除俩模块新增的关联数据(从客户模块删除字段可以删除服务收费管理的字段，反之不能)
    }
    */

    //Deleting from convert lead mapping lingdang_table- Jaguar
    if($fld_module=="Leads") {
//        $deletequery = 'delete from ld_convertleadmapping where leadfid=?';
//        $adb->pquery($deletequery, array($id));
    }elseif($fld_module=="Accounts" || $fld_module=="Contacts" || $fld_module=="Potentials") {
        $map_del_id = array("Accounts"=>"accountfid","Contacts"=>"contactfid","Potentials"=>"potentialfid");
        //ld_convertleadmapping 该表在V7.3.1的脚本中被删除 
        /*$map_del_q = "update ld_convertleadmapping set ".$map_del_id[$fld_module]."=0 where ".$map_del_id[$fld_module]."=?";
        $adb->pquery($map_del_q, array($id));*/
        //duan 20230221 联系人模块删除字段后，需要将添加到客户模块的字段同步删除
        if($fld_module == 'Contacts'){
            $select_sql = "select columnname,fieldid from ld_field where columnname = ? and tabid = ?";
            $select_result =  $adb->pquery($select_sql, array($colName,getTabid('Accounts')));
            if($adb->num_rows($select_result)>0){
                $tmp_fieldid = $adb->query_result($select_result,0,'fieldid');
                $tmp_columnname = $adb->query_result($select_result,0,'columnname');
                $query='delete from ld_field where fieldid = ? and ld_field.presence in (0,2)';
                $adb->pquery($query, array($tmp_fieldid));
                $query='delete from ld_tranlabel where trantable=? and relateid=?';
                $adb->pquery($query, array('ld_field',$tmp_fieldid));
            }
        }
    }else if($fld_module == 'Singin'){
        //拜访签到模块删除字段时，需要将签到统计表的字段列表设置同步删除
        $sql = "SELECT ld_usereport.usereportid,MAX(ld_usereportcolumns.Sequence) from ld_usereport
                INNER JOIN ld_usereportcolumns on ld_usereportcolumns.Usereportid = ld_usereport.usereportid
                where ld_usereport.`name` = 'SIGNINSTATISTICS';";
        $tmp_result = $adb->pquery($sql);
        if($adb->num_rows($tmp_result)>0){
            $usereportid = $adb->query_result($tmp_result,0,'usereportid');
            $deletesql = 'DELETE from ld_usereportcolumns where LOCATE(?,`columns`)>0 AND Usereportid = ?;';
            $adb->pquery($deletesql,array($columnname,$usereportid));
        }
    }

    //HANDLE HERE - we have to remove the table for other picklist type values which are text area and multiselect combo box
    if($uitype == 15) {
        //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 下午 3:04
        $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
        $objPickList->delPickField($colName,'ld_field');
    }
    unsetCacheDirectory('fields');
    /**
     * Liver 2016/04/13 操作页面设置后，清除缓存
     *
     */
    clearCacheFiles();
    clearMinifyFiles();
   // clearSmartyFiles();
    clearDefaultFile();
}


/**
 * addblock()
 *
 * @return
 */
function addblock() {

    global $mod_strings,$adb;
    $fldmodule=$_REQUEST['fld_module'];
    $mode=$_REQUEST['mode'];

    $newblocklabel = trim($_REQUEST['blocklabel']);
    $newblocklabel2 = trim($_REQUEST['blocklabel2']);
    $after_block = $_REQUEST['after_blockid'];

    $tabid = getTabid($fldmodule);
    if($tabid==6)
    {
        $servicecharge_tabid=getTabid('ServiceCharge');

    }
    else if($tabid==getTabid('ServiceCharge'))
    {
        //37688: （1.6）客户页面设置中新增区块与字段时，服务收费管理页面设置中也同时新增，但服务收费管理页面设置中新增区块与字段时，客户页面设置中没有同时新增。预期结果：服务收费管理页面设置中新增区块与字段时，客户页面设置中也应该同时新增区块与字段
        $servicecharge_tabid=getTabid('Accounts');
    }
    $flag = 0;
    /*$dup_check_query = $adb->pquery("SELECT blocklabel from ld_blocks WHERE tabid = ?",array($tabid));
    $norows = $adb->num_rows($dup_check_query);
    for($i=0;$i<$norows;$i++) {
        $blklbl = $adb->query_result($dup_check_query,$i,'blocklabel');
        $blklbltran = getTranslatedString($blklbl,$fldmodule);
        if(strtolower($blklbltran) == strtolower($newblocklabel)) {
            $flag = 1;
            $duplicate='yes';
            return $duplicate;
        }
    }*/
    $dup_check_query="select ld_tranlabel.fieldlabel,languagetype from ld_tranlabel INNER JOIN ld_blocks
        on ld_tranlabel.Relateid=ld_blocks.blockid and ld_tranlabel.trantable='ld_blocks'
        where ld_tranlabel.tabid=? and ld_blocks.tabid=?  ";

    $tmpresult=$adb->pquery($dup_check_query,array($tabid,$tabid));
    $norows=$adb->num_rows($tmpresult);
    for($i=0;$i<$norows;$i++) {
        $blklbl = $adb->query_result($tmpresult,$i,'fieldlabel');

        if(strtolower($blklbl) == strtolower($newblocklabel)) {
            $flag = 1;
            $duplicate='yes';
            return $duplicate;
        }
    }
    $length = mb_strlen($newblocklabel);
    if($length > 50) {
        $flag = 1;
        $duplicate='LENGTH_ERROR';
        return $duplicate;
    }

    if($flag!=1)
    {
        $sql_seq="select sequence from ld_blocks where blockid=?";
        $res_seq= $adb->pquery($sql_seq, array($after_block));
        $row_seq=$adb->fetch_array($res_seq);
        $block_sequence=$row_seq['sequence'];
        $newblock_sequence=$block_sequence+1;

        $sql_up="update ld_blocks set sequence=sequence+1 where tabid=? and sequence > ?";
        $adb->pquery($sql_up, array($tabid,$block_sequence));

        $max_blockid=$adb->getUniqueID('ld_blocks');
        if(!empty($servicecharge_tabid))
        {
            $servicecharge_max_blockid=$adb->getUniqueID('ld_blocks');

            $sql_up="update ld_blocks set sequence=sequence+1 where tabid=? and sequence > ?";
            $adb->pquery($sql_up, array($servicecharge_tabid,$block_sequence));

        }
        $iscustom = 1;
        $sql="INSERT INTO ld_blocks (tabid, blockid, sequence, blocklabel,iscustom) values (?,?,?,?,?)";
        $params = array($tabid,$max_blockid,$newblock_sequence,$newblocklabel,$iscustom);
        $adb->pquery($sql,$params);
        if(!empty($servicecharge_tabid))
        {
            $sql="INSERT INTO ld_blocks (tabid, blockid, sequence, blocklabel,iscustom) values (?,?,?,?,?)";
            $params = array($servicecharge_tabid,$servicecharge_max_blockid,$newblock_sequence,$newblocklabel,$iscustom);
            $adb->pquery($sql,$params);
        }
        $sqls='insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)';
        $params2 = array('zh','ld_blocks',$tabid,$max_blockid,$newblocklabel);
        $params = array('en','ld_blocks',$tabid,$max_blockid,$newblocklabel2);
        $adb->pquery($sqls,$params);
        $adb->pquery($sqls,$params2);
        if(!empty($servicecharge_tabid))
        {
            $sqls='insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)';
            $params2 = array('zh','ld_blocks',$servicecharge_tabid,$servicecharge_max_blockid,$newblocklabel);
            $params = array('en','ld_blocks',$servicecharge_tabid,$servicecharge_max_blockid,$newblocklabel2);
            $adb->pquery($sqls,$params);
            $adb->pquery($sqls,$params2);
        }
        $cachekey = 'cache_moduleblock_trantableinfozh_detail_view_'.$tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfoen_detail_view_'.$tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfozh_edit_view_'.$tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfoen_edit_view_'.$tabid;
        $cachemoduleblock = unsetCache($cachekey);
        if(!empty($servicecharge_tabid))
        {
            $cachekey = 'cache_moduleblock_trantableinfozh_detail_view_'.$servicecharge_tabid;
            $cachemoduleblock = unsetCache($cachekey);
            $cachekey = 'cache_moduleblock_trantableinfoen_detail_view_'.$servicecharge_tabid;
            $cachemoduleblock = unsetCache($cachekey);
            $cachekey = 'cache_moduleblock_trantableinfozh_edit_view_'.$servicecharge_tabid;
            $cachemoduleblock = unsetCache($cachekey);
            $cachekey = 'cache_moduleblock_trantableinfoen_edit_view_'.$servicecharge_tabid;
        }


    }

}

/**
 * deleteBlock()
 *
 * @return
 */
function deleteBlock() {
    global $adb;
    $blockid = $_REQUEST['blockid'];
    if(isset($_REQUEST['notip'])&&$_REQUEST['notip']=='no')
    {
        $sql='select 1 from ld_field  where block=? limit 1';
        if($adb->num_rows($adb->pquery($sql,array($blockid)))>0){
            echo 'error##errror'.getFixedLabel('IsDeleteBlockTip');
            exit();
        }
    }
    $sql='select tabid from ld_blocks where blockid=?';
    $result=$adb->pquery($sql,array($blockid));
    $tabid=$adb->query_result($result,0,0);

    $deleteblock = 'delete from ld_blocks where blockid = ? and iscustom = 1';
    $res = $adb->pquery($deleteblock,array($blockid));
    $deleteblock = 'delete from ld_tranlabel where relateid = ?  and tabid=?';
    $res = $adb->pquery($deleteblock,array($blockid,$tabid));
}
/**
 * 判断字段标签是否重复
 * 17172: 新增自定义字段时，基本信息里面没有传真 但添加传真总是提示字段名称重复
 * */
function find_fieldLabels_Exists()
{
    global $current_user,$adb;
    $fldmodule= isset($_REQUEST['fld_module']) ? vtlib_purify($_REQUEST['fld_module']) : '';
    $fldlabel['zh'] = isset($_REQUEST['label']) ? vtlib_purify(trim($_REQUEST['label'])) : '';
    $fldlabel['en'] = isset($_REQUEST['fldLabel']) ? vtlib_purify(trim($_REQUEST['fldLabel'])) : '';
    $type  = isset($_REQUEST['type']) ? vtlib_purify(trim($_REQUEST['type'])) : '';
    $memberselect_type  = isset($_REQUEST['memberselect_type']) ? vtlib_purify(trim($_REQUEST['memberselect_type'])) : '';

    if($fldmodule=='Calendar'){
        $fldmodule='Events';
    }
    $tabid = getTabid($fldmodule);
    $json_array['code']='1';
    foreach($fldlabel as $languagetype => $label){
        if(function_exists("get_magic_quotes_gpc") && get_magic_quotes_gpc() == 1) {
            $label = stripslashes($label);
        }
        $dup_check_tab_id = $tabid;
        $checkquery="select ld_tranlabel.languagetype from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid 
		where ld_field.tabid in (". generateQuestionMarks($dup_check_tab_id) .")  
		and (ld_tranlabel.languagetype=? and ld_tranlabel.fieldlabel=?)
        and ld_tranlabel.trantable='ld_field'";

        $params=array($dup_check_tab_id,$languagetype,$label);


        $checkresult=$adb->pquery($checkquery,$params);
        if($adb->num_rows($checkresult) > 0 ) {
            $json_array['code']='-1';
            $languagetype=$adb->query_result($checkresult,0,0);
            $json_array['label']=getFixedLabel(strtoupper($languagetype).'_LABELEXISTS');
            break;
        }
    }
    //签到类型字段， 一个模块只允许有一个签到字段
    if($type == 'signin'){
        $query = "select 1 from ld_field where tabid = ? and bigtype = 'signin'";
        $result = $adb->pquery($query,array(getTabid($fldmodule)));
        if($adb->num_rows($result) >= 1){
            $json_array['code']='-2';
            $json_array['label'] = getFixedLabel('Labeltypefieldalreadyexistsinmodule');
        }
    }
    @ob_clean();
    echo json_encode($json_array);
    exit();
    //25170: 联系人列表：页面设置中，增加系统中存在的手机字段，且录入的名称相同，新增保存时没有提示字段名称不能重复

}
/**
 * addCustomField()
 *
 * @return
 */
function addCustomField() {

    global $current_user,$adb;
    $objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
    $fldmodule=vtlib_purify($_REQUEST['fld_module']);
    $fldlabel=vtlib_purify(trim($_REQUEST['fldLabel']));
    $fldlabels=vtlib_purify(trim($_REQUEST['fldLabels']));
    $fldType= vtlib_purify($_REQUEST['fieldType']);
    $parenttab=vtlib_purify($_REQUEST['parenttab']);
    $mode=vtlib_purify($_REQUEST['mode']);
    $blockid = vtlib_purify($_REQUEST['blockid']);
    $fldallow_rewriting = vtlib_purify($_REQUEST['fldallow_rewriting']);
    $defaultvalue=vtlib_purify($_REQUEST['defaultvalue']);
    $approvedemand=$_REQUEST['approvedemand'];
    $inputModeType = vtlib_purify($_REQUEST['inputModeType']);//录入方式 0 手动录入 1 分录函数  2公式计算 3SQL计算； 1和2和3存为formula
    $formulastring = vtlib_purify($_REQUEST['formulacontent']);
    $formulavar = vtlib_purify($_REQUEST['formulavar']);
    $formulacolumn = vtlib_purify($_REQUEST['formulacolumn']);
    $functiontype = vtlib_purify($_REQUEST['functiontype']);
    $functioncolumn = vtlib_purify($_REQUEST['functioncolumn']);
    $auto_signin = vtlib_purify($_REQUEST['auto_signin']);  //自动签到
    $no_signin = vtlib_purify($_REQUEST['no_signin']);  //不允许签到
    $allowable_distance = vtlib_purify($_REQUEST['allowable_distance']);    //允许误差
    $editview_signin = vtlib_purify($_REQUEST['editview_signin']);  //不允许签到
    $editview_resignin = vtlib_purify($_REQUEST['editview_resignin']);    //允许误差
    $ColorTypeArr = vtlib_purify($_REQUEST['ColorTypeArr']);//hjz 需要改颜色的数组
    $advancedemandgroups = vtlib_purify($_REQUEST['advancedemandgroups']);//wyt 负责人、单选用户、多选用户、团队成员选择用户范围
    $memberrange_type=vtlib_purify($_REQUEST['memberrange_type']);
    $sensitive_ruleid_arr=vtlib_purify($_REQUEST['sensitive_ruleid_arr']);//敏感规则
    $sensitivepresence=vtlib_purify($_REQUEST['sensitivepresence']);

    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
    $ShowHyperlinks = vtlib_purify($_REQUEST['ShowHyperlinks']); //no不显示，yes显示，默认不显示
    // ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
    $disallowed_copy = vtlib_purify($_REQUEST['disallowed_copy']); 
    // @edit:liushuai,2020-09-15,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮(增加组合条件后又删除需要处理数据去掉null)
    //wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
    $advance_demand = ldcrm_json_decode(trim($_REQUEST['advancedemand']));
    //edit: hzx 2023/11/06 是否小计
    $subtotal_attr = vtlib_purify($_REQUEST['subtotal_attr']); //no不计算，yes计算
    //zkt 20231108 XUQIU1001871 分配与查看范围，分配时可见成员根据数据范围显示，不显示全部成员
    $showallgroupstructure = empty($_REQUEST['showallgroupstructure'])?'yes':vtlib_purify($_REQUEST['showallgroupstructure']);
    //xxy 2023-11-15 XUQIU1001176 页面设置/单据分录定制，增加“内容过多自动换行”字段属性
    $auto_wordwrap = $_REQUEST['auto_wordwrap'];
    // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
    $word_watermark = vtlib_purify($_REQUEST['word_watermark']);
    $excel_watermark = vtlib_purify($_REQUEST['excel_watermark']);
    $word_watermark_settingid = vtlib_purify($_REQUEST['word_watermark_settingid']);
    $excel_watermark_settingid = vtlib_purify($_REQUEST['excel_watermark_settingid']);
    // 2024-06-05 xxy XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊）
    $helptips = $_REQUEST['helptips'];

    // edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
    $valueFormat = '';
    $formatTypeArr = ['date', 'datetime', 'time'];
    if(in_array($fldType, $formatTypeArr)) {
        $valueFormat = vtlib_purify($_REQUEST['value_format'] ?? '');
    }

    if($memberrange_type =='All'||$memberrange_type=='Module'||$memberrange_type=='Person'||$memberrange_type=='Roles'||$memberrange_type=='Departments'||$memberrange_type=='Position'){
        $advancedemand = vtlib_purify($_REQUEST['advancedemand']);//如果是选用户（负责人、单选用户、多选用户、团队成员）字段控制，数据不做处理
    }else{
        if (!empty($advance_demand)) {
            $index = 1;
            $tmp_advance_demand = [];
            foreach ($advance_demand as $advft_criteria_obj){
                if (empty($advft_criteria_obj)) continue;
                $advft_criteria_obj->groupid = $index;
                $tmp_advance_demand[] = $advft_criteria_obj;
                $index++;
            }
            $advancedemand = ldcrm_json_encode($tmp_advance_demand);
        }


        $advance_demand_groups = ldcrm_json_decode(trim($_REQUEST['advancedemandgroups']));
        if (!empty($advance_demand_groups)) {
            $index = 1;
            $tmp_advance_demand_groups = [];
            foreach ($advance_demand_groups as $advft_criteria_groups_obj){
                if (empty($advft_criteria_groups_obj)) continue;
                $tmp_advance_demand_groups[] = $advft_criteria_groups_obj;
                $index++;
            }
            $advancedemandgroups = ldcrm_json_encode($tmp_advance_demand_groups);
        }
    }

    $presence=$_REQUEST['presence'];
    $savedatabase=$_REQUEST['savedatabase'];
    $allowedit=$_REQUEST['allowedit'];
    $fieldonly=$_REQUEST['fieldonly'];

    $maxrowsshow=$_REQUEST['maxrowsshow'];
    $datarang=$_REQUEST['datarang'];
    $referencemodule=$_REQUEST['referencemodule'];

    $requiredfield=strtoupper($_REQUEST['requiredfield']);
    $take_photo_only = $_REQUEST['take_photo_only_check'];
    if(empty($take_photo_only))$take_photo_only = 0;
    $uploadwatermark = $_REQUEST['uploadwatermark'];
    if(empty($uploadwatermark)) $uploadwatermark = 'no';

    $selectmemberfield = vtlib_purify($_REQUEST['selectmemberfield']);

    if($requiredfield=='')
    {
        $requiredfield='O';
    }

    $masseditable= $_REQUEST['massedit'];
    if($fldmodule=='Calendar'){
        $fldmodule='Events';
    }
    $focus=CRMEntity::getInstance($fldmodule);

    $tabid = getTabid($fldmodule);
    /*if ($fldmodule == 'Calendar' && isset($_REQUEST['activity_type'])) {
        $activitytype = $_REQUEST['activity_type'];
        if ($activitytype == 'E') $tabid = '16';
        if ($activitytype == 'T') $tabid = '9';
    }*/
    if(function_exists("get_magic_quotes_gpc") && get_magic_quotes_gpc() == 1) {
        $fldlabel = stripslashes($fldlabel);
    }

    $dup_check_tab_id = $tabid;


    if(1<0 ) {
        $duplicate = 'yes';
        return $duplicate ;
    }
    else {
        $max_fieldid = getMaxFieldid();
        $columnName = 'cf_'.$max_fieldid;
        $fieldname=$columnName;
        $custfld_fieldid = $max_fieldid;
        //Assigning the lingdang_table Name
        if($fldmodule != '') {
            $focus = CRMEntity::getInstance($fldmodule);
            if (isset($focus->customFieldTable)) {
                $tableName=$focus->customFieldTable[0];
            } else {
                $tableName= 'ld_'.strtolower($fldmodule).'cf';
            }
        }
        //Assigning the uitype
        $fldlength=$_REQUEST['fldLength'];
        $uitype='';
        $fldPickList='';
        if(isset($_REQUEST['fldDecimal']) && $_REQUEST['fldDecimal'] != '') {
            $decimal=$_REQUEST['fldDecimal'];
        }else {
            $decimal=0;
        }
        $type='';
        $uichekdata='';
        //$masseditable = 1;
        $displaytype = 1;

        $editpage = '';
        $isrelatedmodulefield = 'no';


         if(!is_numeric($fldlength)||$fldlength<=0||empty($fldlength)||$fldlength>1000)
          {
            $fldlength=255;
        }
        if(!is_numeric($decimal)||$decimal<0||$decimal=='')
        {
            $decimal=2;
          }
          $fldType=strtolower($fldType);
          $savefldType=$fldType;
          $colortypearr = explode(',',$ColorTypeArr);//hjz 把从js传过来的字符串转换成数组
        if(in_array($fldType,$colortypearr))
        {
            $fieldvaluecolor=$_REQUEST['fieldvaluecolor'];//zxm2021-1230 新增字段  字段颜色 字段说明--只有Text、textarea、longtextarea三个类型字段需要
            $fieldplaceholder=$_REQUEST['fieldplaceholder'];
        }else if($fldType == 'url'){
            $fieldplaceholder=$_REQUEST['fieldplaceholder'];
        }else{
            $fieldvaluecolor='';
            $fieldplaceholder='';
        }
        if(isset($_REQUEST['labelvaluecolor']) && !empty($_REQUEST['labelvaluecolor'])){
            $label_style = array('color' => $_REQUEST['labelvaluecolor']);
            $label_style_str = json_encode($label_style);
        }else{
            $label_style_str = '';
        }
        if($fldType == 'text') {

            $uichekdata='V~'.$requiredfield.'~LE~'.$fldlength;
            $uitype = 1;
            $editpage = 'listview';
            if((int)$fldlength<=255){
                $type = "C(".$fldlength.") default ()"; // adodb type
            }
            else{
                $type = "X"; // adodb type
            }
        }else if($fldType == 'signin') {

            $uichekdata='V~'.$requiredfield;
            $uitype = 306;
            $editpage = '';
            $type = "C(5) default ()"; // adodb type
            $displaytype = 2;
        }else if($fldType == 'handwriting') {
            $uichekdata='V~'.$requiredfield.'~LE~'.$fldlength;
            $uitype = 222;
            $editpage = '';
            $type = "C(".$fldlength.") default ()"; // adodb type
            $masseditable = 0;
            $displaytype = 2;
        }
        elseif($fldType == 'number') {
            $uitype = 7;
            //if($decimal>8)
//            {
//                $decimal=8;
//            }
            //this may sound ridiculous passing decimal but that is the way adodb wants
            $dbfldlength = $fldlength + $decimal + 1;

            if($dbfldlength>34)
            {

                $dbfldlength=25;

            }

            if($decimal>=$dbfldlength)
            {
                $dbfldlength=$decimal+10+1;
                $fldlength=$dbfldlength;
            }
            $editpage = 'listview';
            $type="N(".$dbfldlength.".".$decimal.")";	// adodb type
            // Fix for http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/6363
            $uichekdata='NN~'.$requiredfield.'~'.$fldlength .','.$decimal;
        }elseif($fldType == 'percent') {
            $uitype = 9;
            $editpage = 'listview';
            //36835: （1.6）模块页面设置>新增字段>百分比类型字段：取消该字段的百分比上限控制，目前该字段所填写的值不能超过100
            $type="N(20.2)"; //adodb type
            $uichekdata='N~'.$requiredfield.'~15,2';
        }elseif($fldType == 'currency') {
            $uitype = 71;
            $fldlength = 22;
            //单据头中货币字段小数位数。
            $sysdeploy_351 = getSys_deploy(351);
            $decimal = $sysdeploy_351['deploy_value'];
            if(!is_numeric($decimal)){
                $decimal = 2;
            }

            $dbfldlength = $fldlength + $decimal + 1;
            if($dbfldlength>25)
            {
                $dbfldlength=25;
            }
            $editpage = 'listview';
            $type="N(".$dbfldlength.".8)"; //adodb type
            $uichekdata='N~O~'.$fldlength .','.$decimal;	//'~'.$fldlength .','.$decimal
        }
        elseif($fldType == 'date') {
            $uichekdata='D~'.$requiredfield;
            $uitype = 5;
            $editpage = 'listview';
            $type = "D"; // adodb type
        }elseif($fldType == 'email') {
            $uitype = 13;
            $editpage = 'listview';
            $type = "C(50) default () "; //adodb type
            $uichekdata='E~'.$requiredfield;
        }
        elseif($fldType == 'time') {
            $uitype = 14;
            $editpage = 'listview';
            $type = "TIME";
            $uichekdata='T~'.$requiredfield;
        }elseif($fldType == 'phone') {
            $uitype = 11;
            $editpage = 'listview';
            $type = "C(30) default () "; //adodb type
            $uichekdata='V~'.$requiredfield;
            /**
            更新操作
            edit:cdw
            date:20131114
            reason:销售通详细需求-自定义设置及短信邮件群发改进
             **/
        }
        elseif($fldType == 'mobile') {
            $uitype = 1101;
            $editpage = 'listview';
            $type = "C(30) default () ";
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'fileattachment') {
            $fldlength = 1;
            $uitype = 1109;
            $editpage = 'listview';
            $type = "C(".$fldlength.") default ()"; // adodb type
            $uichekdata='V~'.$requiredfield;
            $tableName='ld_attachments';
            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
            getFileAllowedFromUrl($advance_demand,$advance_demand_groups);
            $advancedemand = $advance_demand;
            $advancedemandgroups = $advance_demand_groups;
        }
        elseif($fldType == 'rfax') {
            $uitype = 1102;
            $editpage = 'listview';
            $type = "C(30) default () ";
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'qq') {
            $uitype = 1103;
            $editpage = 'listview';
            $type = "C(30) default () ";
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'picklist') {
            $uitype = 15;
            $editpage = 'listview';
            //zkt 20220621 BUG0053061页面设置/单据分录定制，添加的下拉框和文本字段默认长度改为100,不要给255
            $type = "C(100) default () "; //adodb type
            $uichekdata='V~'.$requiredfield;
        }
        elseif(strtolower($fldType) == 'url') {
            $uitype = 17;
            $editpage = 'listview';
            $type = "C(255) default () "; //adodb type
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'checkbox') {
            $uitype = 56;
            $editpage = 'listview';
            $type = "C(3) default 0"; //adodb type
            $uichekdata='C~O';
            $savefldType='boolean';//对应ld_ws_field
        }
        elseif($fldType == 'textarea') {
            $uitype = 21;
            $editpage = 'listview';
            $type = "X"; //adodb type
            $uichekdata='V~'.$requiredfield;
        }
        elseif(strtolower($fldType) == 'multipicklist') {//对应ld_ws_field
            $uitype = 33;
            $editpage = 'listview';
            $type = "X"; //adodb type
            $uichekdata='V~'.$requiredfield;

            $defaultvalue=setsaveMutliPickListValue($defaultvalue);


        }
        elseif($fldType == 'skype') {
            $uitype = 85;
            $editpage = 'listview';
            $type = "C(255) default () "; //adodb type
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType=='datetime'){
            $uitype=86;
            $editpage = 'listview';
            $type='DateTime';
            $uichekdata='DT~'.$requiredfield;
        }
        else if($fldType=='relatedmodulefield')
        {
            $isrelatedmodulefield = 'yes';
            //引用字段
            if ($savedatabase == 'yes' && $allowedit == 'yes') {
                $editpage = 'listview';
            }
            $relatemodulefield=$_REQUEST['relatemodulefield'];
            $relatemodule=$_REQUEST['relatemodule'];
            $relatefocus=CRMEntity::getInstance($relatemodule);

            $relatefieldinfo=$relatefocus->fieldobj->getFieldInfoobjBykey('fieldname',$relatemodulefield);


            $relatecolumnname=$relatefieldinfo->getColumnName();
            if($relatemodule=='Accounts'&&($fldmodule=='Accounts'||$fldmodule=='ServiceCharge'))
            {
                $sqltrigger="select  fieldid ,columnname,tablename,bigtype from ld_field where uitype=51";
                $result=$adb->pquery($sqltrigger,array());
            }
            else
            {
                $sqltrigger="select  fieldid ,columnname,tablename,bigtype from ld_field where uitype in(
                        select ld_ws_fieldtype.uitype from ld_ws_fieldtype INNER JOIN
                         ld_ws_referencetype on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid
                        where ld_ws_referencetype.type=?) and presence in(0,2)
                        and tabid=?";
                $result=$adb->pquery($sqltrigger,array($relatemodule,$tabid));
            }


            $trigger_fieldid=$adb->query_result($result,0,'fieldid');
            $trigger_columnname=$adb->query_result($result,0,'columnname');//当前模块的字段
            $trigger_tablename=$adb->query_result($result,0,'tablename');
            $trigger_bigtype=$adb->query_result($result,0,'bigtype');
            $savefldType = $trigger_bigtype;//引用字段bigtype初值取，被引用字段bigtype
            if($adb->num_rows($result)>0)
            {
                $bigtype=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$trigger_columnname,'bigtype');
                if($bigtype=='selectsource')
                {
                    $sourcemodules=getSourceModule($fldmodule);
                    $isbol=false;
                    foreach($sourcemodules as $sourceinfo)
                    {
                        if($relatemodule==$sourceinfo['entitytype'])
                        {
                            $isbol=true;
                            break;
                        }
                    }
                    if(!$isbol)
                    {
                        $trigger_fieldid=$adb->query_result($result,1,'fieldid');
                        $trigger_columnname=$adb->query_result($result,1,'columnname');//当前模块的字段
                        $trigger_tablename=$adb->query_result($result,1,'tablename');
                    }

                }
            }
            if(empty($trigger_fieldid))
            {
                $sourcefieldinfo=$focus->fieldobj->getFieldInfoobjBykey("bigtype",'selectsource');
                if($sourcefieldinfo)
                {
                    $trigger_fieldid=$sourcefieldinfo->getFieldid();
                    $trigger_columnname=$sourcefieldinfo->getColumnName();
                    $trigger_tablename=$sourcefieldinfo->getTableName();

                }
            }
            $parentbigtype=$relatefieldinfo->getBigType();
            $subtotal_attr= $relatefieldinfo->getsubtotal_attr();
            $parentuitype = $relatefieldinfo->getUIType();

            if($parentuitype==33||$parentuitype==15||$parentuitype==4|| $parentuitype==34||$relatefieldinfo->getBigType()=='translatefield')
            {
                $uitype=1;
                $type = "C(255) default () "; //adodb type
                $uichekdata='V~'.$requiredfield;
                $savefldType = 'text';
            }
            else if(Field::user_fields($parentuitype))
            {
                $uitype=153; //引用单选用户
                $savefldType = 'selectoneuser';
                $type='I(19) default 0';
                $uichekdata='V~'.$requiredfield;
            }
            else if(Field::user_multi_fields($parentuitype))
            {
                $uitype=154; //引用多选用户
                $savefldType = 'selectmultiuser';
                $type='X';
                $uichekdata='V~'.$requiredfield;
            }
            else if($parentuitype==230)
            {
                $type = "X"; //adodb type
                $uichekdata='V~'.$requiredfield;
                $uitype=230;
                $savefldType = $relatefieldinfo->getBigType();
            }
            else if($parentuitype==180)
            {//wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（苏宁）
                $uitype=1600;
                $savefldType = 'memberdepartment';
                $editpage = '';
                $uichekdata='V~O';
            }
            else
            {
                $uitype=$parentuitype;
                $savefldType = $relatefieldinfo->getBigType();
                $tmptypeofdatas=explode('~',$relatefieldinfo->getTypeOfData());

                $uichekdata=$tmptypeofdatas[0].'~'.$requiredfield;
                
                if(sizeof($tmptypeofdatas)>2)
                {
 
                    //数字带小数位数
                    $uichekdata=trim($uichekdata,'~').'~'.trim($tmptypeofdatas[2],'~');
 
                }
                
            }
          
            if($savedatabase=='yes')
            {
                if($relatefieldinfo->getFieldDataType()=='double')
                {
                 
                  $tmp_arr=explode(",",$tmptypeofdatas[2]);
                  if($tmp_arr[0]>25)
                  {
                    $tmp_arr[0]=25;
                  }
                  if(trim($tmp_arr[1])=='')
                  {
                    $tmp_arr[1]=0;
                  }
                    //edit:can bug76661 引用字段引用时有多位数字显示时正常，保存后会进位到整数格式 
                    //数字带小数位数
                    $type="N(".$tmp_arr[0].'.'.$tmp_arr[1].")";
                }
                else if(Field::user_fields($parentuitype))
                {
                    //为了兼容kehu001 只能存id了
                    //edit:can 20231103 74803 跟进记录--导出时，引用字段“客户创建人姓名”字段导出显示为乱码，该字段引用的为客户模块的创建人
                    $type="I(19) default 0";//整型

                }
                else if(Field::user_multi_fields($parentuitype))
                {
                    //为了兼容kehu001 只能存id了
                    //edit:can 20231103 74803 跟进记录--导出时，引用字段“客户创建人姓名”字段导出显示为乱码，该字段引用的为客户模块的创建人
                    $type="X";//整型

                }
                else if($relatefieldinfo->getFieldDataType()=='currency')
                {
                    //edit:can 20200824 42487: （61mis.com/kfbcrm）（客户问题）自定义表单12新建界面>选择编号为“SO253”的合同订单：基本信息中的“合计”字段小数位显示不对，保存后小数位是正常的。（需要补丁）
                    $type="N(25.8)";
                }
                else if($relatefieldinfo->getFieldDataType()=='date')
                {
                    $type="D";
                }
                else if($relatefieldinfo->getFieldDataType()=='datetime')
                {
                    $type='DateTime';
                }
                else if($relatefieldinfo->getFieldDataType()=='mobile'||$relatefieldinfo->getFieldDataType()=='email')
                {
                    $type = "C(50) default () ";
                }
                else if($relatefieldinfo->getFieldDataType()=='boolean')
                {
                    $type = "C(30) default 0 ";
                }
                else if($parentuitype==230)
                {
                    $type='X';
                }
                else if($parentuitype==19||$parentuitype==21)
                {
                    $type='X';
                }
                else
                {
                    $type = "C(255) default () ";
                }
            }
            if($fldmodule == 'Singin' && $relatemodule == 'Signout'){
                $displaytype = 2;
            }

            // edit: xll 2024/10/12 引用时间字段的处理
            $relateFieldBigType = $relatefieldinfo->getBigType();
            if(in_array($relateFieldBigType, $formatTypeArr)) {
                $valueFormat = $relatefieldinfo->getValueFormat();
            }

        }
        elseif($fldType=='selectoneuser')
        {
            //edit:can 20200825 单选用户
            $uitype=153;
            $decimal=0;
            $editpage = 'listview';
            $type="I(19) default 0";//整型
            $uichekdata='V~'.$requiredfield;
        }
        else if($fldType=='selectmultiuser')
        {
            //edit:can 多选用户;
            $uitype=154;
            $editpage = 'listview';
            $type='X';
            $uichekdata='V~O';
        }
        elseif($fldType=='reference')
        {
            $editpage = '';
            //引用单据
            $tableName=$focus->table_name;
            crm_load_class_file('cls_module_uitype','include/fields');
            unsetCache('fields_getAllFieldTypeInfo');//清空uitype的缓存
            $uitypes= cls_module_uitype::getModuleUitype($focus->module_name,$referencemodule);
            $uitype=$uitypes['uitype'];

            if(empty($uitype))
            {
                $uitype=cls_module_uitype::addNewUitype($referencemodule,$fldType);

            }
            $columnName=strtolower($referencemodule)."_id";
            $fieldname=$columnName;

            //edit:duan 2022-4-18 如果模块同时有联系人和供应商联系人，则columnname会重复，导致有一个字段显示不出来
            if($uitype<2000&&$referencemodule!='VendorContact')
            {

                //引用的历史单据
                $sql='select columnname,fieldname from ld_field where uitype=? limit 1 ';
                $result=$adb->pquery($sql,array($uitype));

                if($adb->num_rows($result)>0)
                {
                    $columnName=$adb->query_result($result,0,'columnname');
                    $fieldname=$adb->query_result($result,0,'fieldname');
                }
            }

            //ls 20220714 BUG0053824 客户管理>客户与经销商模块，序时簿列表的【经销商销售】列显示的值与单据详细信息的值不符。(需要修改columnname，客户模块原来就有关联联系人，客户又新建关联联系人，contactid就冲突了)
            if (in_array($focus->module_name,array('Accounts','ServiceCharge')) && in_array($referencemodule,array('Contacts')) && $columnName == 'contactid') {
                $columnName = 'crm'.$columnName;
            }

            $decimal=0;
            $type="I(19) default 0";//整型
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType=='multireference') {
			//wym 多选关联字段 新增字段
            $editpage = '';
            $tableName=$focus->table_name;
            crm_load_class_file('cls_module_uitype','include/fields');
            unsetCache('fields_getAllFieldTypeInfo');//清空uitype的缓存
            $uitypes= cls_module_uitype::getModuleUitype_multi($focus->module_name,$referencemodule);
            $uitype=$uitypes['uitype'];

            if(empty($uitype)) {
                $uitype=cls_module_uitype::addNewUitype($referencemodule,$fldType);
            }
            $columnName=strtolower($referencemodule)."_id_multi";
            $fieldname=$columnName;
            if($uitype<2000&&$focus->module_name!='WorkReportList') {
                //引用的历史单据
                $sql='select columnname,fieldname from ld_field where uitype=? limit 1 ';
                $result=$adb->pquery($sql,array($uitype));
                if($adb->num_rows($result)>0) {
                    $columnName=$adb->query_result($result,0,'columnname');
                    $fieldname=$adb->query_result($result,0,'fieldname');
                }
            }
            $decimal=0;
            $type = "C(255) default ()";
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'longtextarea'){
            $uitype=19;
            $editpage = 'listview';
            $type='X';
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'qrcode'){
            //zxm 2021-0412 二维码字段类型
            $uitype=1500;
            $uichekdata='V~O';
            $editpage = '';
            $type = "C(10) default ()"; // adodb type
            $masseditable = 2;
            $displaytype = 2;
        }
        elseif($fldType == 'memberdepartment'){
            $uitype=1600;
            $editpage = '';
            $uichekdata='V~O';
            $type = "C(255) default ()";
            if ($focus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'uitype') == 52) {//创建人为2 负责人和单选用户为1
                $displaytype = 2;
            }
        }
        elseif($fldType == 'richtext'){
            //ls 2021-10-22 【ID1002124】页面设置，字段类型增加“富文本框”选项
            $uitype=230;
            $uichekdata='V~O';
            //zkt 20220428 （https://81mis.com/kfbcrm/index.php）（列表编辑字段）客户列表》编辑富文本框，只有操作调用文档模板才可以保存，手动输入内容保存不了
            $editpage = '';
            $type = "X";
        }
        elseif($fldType == 'picture') {
            //ls 2022-04-06 【1002543】页面设置，增加“图片”字段类型【页面设置】
            $fldlength = 5;
            $uitype = 69;
            $fldType = 'fileattachment';
            $savefldType = 'fileattachment';
            $editpage = '';
            $type = "C(".$fldlength.") default ()";
            $uichekdata='V~'.$requiredfield;
        }
        elseif($fldType == 'express') {
            //ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型
            $tableName = $focus->table_name;//主表
            $columnName = 'express_no';
            $fieldname = $columnName;

            $fldlength = 255;
            $uitype = 1;
            $fldType = 'express';
            $editpage = '';
            $type = "C(".$fldlength.") default ()";
            $uichekdata='V~'.$requiredfield;
        }


        $input_type = '';
        //zkt 20221012 XUQIU1000246  页面设置中单据头字段，数据库 ld_field 增加 allowdelete 控制是否允许删除
        $allowdelete = 'no';
        if(InStrCount($columnName,'cf_',true)){
            //暂时先根据columnname判断
            $allowdelete = 'yes';
        }
           
        if(is_numeric($blockid)) {
            if($_REQUEST['fieldid'] == '') {
                //ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
                //录入方式
                if ($inputModeType == 2 || $inputModeType == 3) {//公式 或者 sql
                    $vars = array_filter(explode(',', $formulavar));
                    $columns = array_filter(explode(',', $formulacolumn));

                    $columnstring = "{formulavar:[";
                    for ($i = 0; $i < sizeof($vars); $i++) {
                        $columnstring .= "{'lettervar':'" . $vars[$i] . "','column':'" . $columns[$i] . "'}";
                        if ($i != sizeof($vars) - 1) {
                            $columnstring .= ",";
                        }
                    }
                    $columnstring .= ']}';

                    if (!empty($formulastring)) {
                        //替换错误的括号
                        $formulastring = str_replace('（','(',$formulastring);
                        $formulastring = str_replace('）',')',$formulastring);
                        $input_type = 'formula';
                        //有字段公式的字段 设置不允许编辑 应该是savedatabase='yes'
                        $savedatabase = 'yes';
                    }else{
                        //沒有设置字段公式的改为手动录入
                        $input_type = '';
                        $inputModeType = 0;
                    }

                    if($inputModeType == 3){
                        $functiontype = 'sql';

                        $checksql = parserSql($formulastring);
                        if ($checksql['code'] != 1) {
                            echo 'CHECKSQLERROR';
                            exit;
                        }
                    }


                } else if ($inputModeType == 1) {
                    $productfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$functioncolumn);

//                    $tableName = $productfieldinfo->getTableName();
//                    $uitype = $productfieldinfo->getUIType();//分录字段的uitype和主表的uitype不一致，比如服务到期日分录为51，主表为5，因此不能使用分录的uitype。
//                    $fldType = $productfieldinfo->getBigType();//新增字段时不能取分录字段的bigtype，不一致，比如分录数字为num，表头数字为number

                    $columnstring=trim($functioncolumn);//分录函数选择的字段
                    $input_type = 'formula';
                    $allowedit = 'no';//默认不允许编辑
                    $defaultvalue = '';
                    $savedatabase = 'yes';
                }

                $max_fieldsequence = "select max(sequence) as maxsequence from ld_field where block = ? ";
                $res = $adb->pquery($max_fieldsequence,array($blockid));
                $max_seq = $adb->query_result($res,0,'maxsequence');
                if($fldmodule == 'Quotes' || $fldmodule == 'PurchaseOrder' || $fldmodule == 'SalesOrder' || $fldmodule == 'Invoice' || $fldmodule=='ServiceReturn') {
                    $quickcreate = 3;
                }else {
                    $quickcreate=$_REQUEST['quickcreate'];
                    if(empty($quickcreate))$quickcreate = 0;
                }
                $sql='select max(quickcreatesequence) from ld_field where tabid=?';
                $result=$adb->pquery($sql,array(getTabid($fldmodule)));
                $quickcreatesequence=$adb->query_result($result,0,0)+1;
                //$fieldvaluecolor
                //$fieldplaceholder zxm20211230 字段颜色 字段说明
                $query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname ,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                              sequence,block ,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable ,approve_demand,advance_demand,advance_demand_groups,
                              fldallow_rewriting,savedatabase,allowedit,allowdelete,bigtype,fieldonly,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder,
                              editpage,input_type,auto_signin,no_signin,allowable_distance,relatedmodulefield,editview_signin,editview_resignin,ShowHyperlinks,disallowed_copy,
                              subtotal_attr, showallgroupstructure,autowordwrap,word_watermark,excel_watermark,helptips,value_format,label_style) 
                              values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

				$qparams = array($tabid,$custfld_fieldid,$columnName,$tableName,2,$uitype ,$fieldname,$fldlabel,0,$presence,$defaultvalue,100,
                    $max_seq+1,$blockid,$displaytype,$uichekdata,$quickcreate,$quickcreatesequence,'BAS',$masseditable,$approvedemand,$advancedemand,$advancedemandgroups,
                    $fldallow_rewriting,$savedatabase,$allowedit,$allowdelete,$savefldType,$fieldonly,$datarang,$maxrowsshow,$take_photo_only,$uploadwatermark,$fieldvaluecolor,
                    $fieldplaceholder,$editpage,$input_type,$auto_signin,$no_signin,$allowable_distance,$isrelatedmodulefield,$editview_signin,$editview_resignin,$ShowHyperlinks,$disallowed_copy,
                    $subtotal_attr, $showallgroupstructure,$auto_wordwrap,$word_watermark,$excel_watermark,$helptips, $valueFormat,$label_style_str);
				$adb->pquery($query, $qparams);
                //新建自定义字段，更新相关表
                $sql="insert into ld_cfoperationlog(tabid,fieldid,uitype,bigtype,relatedmodulefield,fieldlabel_zh,fieldlabel_en,create_operator,modifiedtime,createdtime) 
                values(?,?,?,?,?,?,?,?,?,?)";
                $adb->pquery($sql,array($tabid,$custfld_fieldid,$uitype,$savefldType,$isrelatedmodulefield,$fldlabel,$fldlabels,$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s')));

                if($input_type == 'formula'){
                    $sql='insert ld_field_formula(formulastring,columnstring,fieldid,functiontype) value(?,?,?,?)';

                    $param=array($formulastring,$columnstring,$custfld_fieldid,$functiontype);

                    $adb->pquery($sql,$param);
                }

                if($isrelatedmodulefield=='yes')
                {
                    if($uitype==69||$uitype==1109){
                        $fromvalue_type='attachment';
                    }else{
                        $fromvalue_type='column';
                    }
                    if($relatemodule=='Users'){//wym XUQIU1000290 引用成员管理字段的trigger_field不是关联字段
                        $trigger_fieldid = $focus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'fieldid');
                    }
                    $sql='insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
                                                  value  (?,?,?,?,?,?,?)';
                    $result=$adb->pquery($sql,array('main',$trigger_fieldid,$custfld_fieldid,$columnName,$fromvalue_type,$relatecolumnname,$relatemodule));
                    $sql='update ld_field set parentbigtype=? where fieldid=?';
                    $adb->pquery($sql,array($parentbigtype,$custfld_fieldid));
                    unsetCache("all_getRelatedFieldInfo");//清除redis
                    unsetCacheDirectory('relatedfield');//清除文件缓存
                }
                //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）
                if ($fldType=='memberdepartment') {//新增编辑复制需要关联带出所属部门值
//                    $trigger_fieldname = $focus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'fieldname');
                    $trigger_fieldid = $focus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'fieldid');

                    if(!empty($trigger_fieldid))
                    {
                        $sql='insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
                              value  (?,?,?,?,?,?,?)';
                        $adb->pquery($sql,array('main',$trigger_fieldid,$custfld_fieldid,$columnName,'column','groupid','Users'));//getTabname($tabid)
                        unsetCache("all_getRelatedFieldInfo");//清除redis
                        unsetCacheDirectory('relatedfield');//清除文件缓存
                    }
                }

                //ls 2022-01-22 页面设置添加“货币”字段时，如果没有币种、货币符号、货币汇率，则添加之
                if($fldType == 'currency') {
                    $currency_result = $adb->pquery("select * from information_schema.columns where TABLE_SCHEMA = DATABASE() and table_name = ? and column_name = 'currency_id'",array($focus->table_name));
                    if ($adb->num_rows($currency_result) < 1) {
                        $adb->pquery("ALTER TABLE $focus->table_name ADD COLUMN currency_id INT(19) DEFAULT 1;",array());
                    }
                    $rate_result = $adb->pquery("select * from information_schema.columns where TABLE_SCHEMA = DATABASE() and table_name = ? and column_name = 'conversion_rate'",array($focus->table_name));
                    if ($adb->num_rows($rate_result) < 1) {
                        $adb->pquery("ALTER TABLE $focus->table_name ADD COLUMN conversion_rate decimal(25,6) DEFAULT '1.000000';",array());
                    }
                    $symbol_result = $adb->pquery("select * from information_schema.columns where TABLE_SCHEMA = DATABASE() and table_name = ? and column_name = 'currency_symbol'",array($focus->table_name));
                    if ($adb->num_rows($symbol_result) < 1) {
                        $adb->pquery("ALTER TABLE $focus->table_name ADD COLUMN currency_symbol VARCHAR(30) DEFAULT '¥';",array());
                    }

                }
                /*
                andrew
                2014-03-18 14:27:19
                新建时候添加英文名
                */
                addTranlabel($tabid,$custfld_fieldid,$fldlabel,$fldlabels);
                //添加字段
                // 2024-11-18 xxy 提前判断是否已有字段，防止报错，有些关联模块的字段在模块主表里已经预置了但ld_field里没有，导致再创建对应关联单选字段就报错了
                $columnname_arr = $adb->getColumnNames($tableName);
                if(!in_array($columnName,$columnname_arr)){
                    $adb->alterTable($tableName, $columnName." ".$type, "Add_Column");
                }
                //duan 20240611 增加判断增加字段是否成功.不成功的话再次调用添加字段方法
                $columnname_arr = $adb->getColumnNames($tableName);
                if(!in_array($columnName,$columnname_arr)){
                    //添加日志文件记录
                    file_put_contents(globalStatic::$root_directory . 'modules/Settings/a_main_field_error.txt', json_encode([$tableName, $columnName." ".$type, "Add_Column"]) . date("Y-m-d H:i:s") . "\r\n", FILE_APPEND);
                    $adb->alterTable($tableName, $columnName." ".$type, "Add_Column");
                }

                //ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型【同时新增“物流单号”和“物流公司”字段】
                if ($fldType == 'express') {//给当前模块新增“物流公司”字段
                    $express_company_fieldid = getMaxFieldid();
                    $query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname
                                                ,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block
                                                ,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable
                                                ,approve_demand,advance_demand,advance_demand_groups,fldallow_rewriting,savedatabase,allowedit,allowdelete,bigtype,fieldonly
                                                ,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder,editpage,input_type,auto_signin,no_signin,allowable_distance) 
                                                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                    $qparams = array($tabid,$express_company_fieldid,'express_company',$tableName,2,15,'express_company',
                        '物流公司',0,$presence,'',100,$max_seq+2,$blockid
                    ,$displaytype,$uichekdata,$quickcreate,$quickcreatesequence+1,'BAS',$masseditable
                    ,$approvedemand,$advancedemand,$advancedemandgroups,$fldallow_rewriting,$savedatabase,$allowedit,$allowdelete,'picklist',0,$datarang,$maxrowsshow,$take_photo_only,$uploadwatermark,$fieldvaluecolor,
                        $fieldplaceholder,$editpage,$input_type,$auto_signin,$no_signin,$allowable_distance);
                    $adb->pquery($query, $qparams);

                    //新建自定义字段，更新日志相关表
                    $sql="insert into ld_cfoperationlog(tabid,fieldid,uitype,bigtype,fieldlabel_zh,fieldlabel_en,create_operator,modifiedtime,createdtime) 
                            values(?,?,?,?,?,?,?,?,?)";
                    $adb->pquery($sql,array($tabid,$express_company_fieldid,15,'picklist','物流公司','Logistics Company',$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s')));

                    //添加翻译
                    addTranlabel($tabid,$express_company_fieldid,'物流公司','Logistics Company');
                    //添加字段
                    $adb->alterTable($tableName, "express_company ".$type, "Add_Column");
                }

                if($tabid==6)
                {
                    $servicechargetabid=getTabid('ServiceCharge');
                    $servicecharge_max_fieldid = getMaxFieldid();

                }
                else if($tabid==getTabid('ServiceCharge'))
                {
                    $servicechargetabid=getTabid('Accounts');
                    $servicecharge_max_fieldid = getMaxFieldid();
                }
                if(!empty($servicechargetabid))
                {

                    $servicechargefocus = CRMEntity::getInstance(getTabModuleName($servicechargetabid));
                    $queryblockid = "select blockid from ld_blocks where blocklabel = (select blocklabel from ld_blocks where blockid = ?) and tabid = ?";
                    $tmpresult=$adb->pquery($queryblockid,array($blockid,$servicechargetabid));
                    if($adb->num_rows($tmpresult)<=0)
                    {
                        //edit:can 20230111 60714 在客户模块新增字段后，服务收费管理模块不显示（前台和页面设置里都不显示），新增同名字段时会提示重复。
                        $sql='select blockid from ld_blocks  where tabid=? and visible=0 and blocklabel!=?  order by sequence asc limit 1 ';
                        $tmpresult=$adb->pquery($sql,array($servicechargetabid,'LBL_LABEL'));

                    }
                    $servicecharge_blockid = $adb->query_result($tmpresult,0,0);
                    $query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname
                                                    ,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block
                                                    ,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable
                                                    ,approve_demand,advance_demand,advance_demand_groups,fldallow_rewriting,savedatabase,allowedit,allowdelete
                                                    ,bigtype,fieldonly,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder
                                                    ,editpage,input_type,auto_signin,no_signin,allowable_distance,relatedmodulefield,subtotal_attr,showallgroupstructure,autowordwrap) 
                                                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    				$qparams = array($servicechargetabid,$servicecharge_max_fieldid,$columnName,$tableName,2,$uitype
                                    ,$fieldname,$fldlabel,0,2,'',100,$max_seq+1,$servicecharge_blockid
                                    ,$displaytype,$uichekdata,$quickcreate,0,'BAS',$masseditable
                                    ,$approvedemand,$advancedemand,$advancedemandgroups,$fldallow_rewriting,$savedatabase,$allowedit,$allowdelete,$savefldType,$fieldonly,$datarang,$maxrowsshow,$take_photo_only,$uploadwatermark,$fieldvaluecolor,
                                    $fieldplaceholder,$editpage,$input_type,$auto_signin,$no_signin,$allowable_distance,$isrelatedmodulefield,$subtotal_attr,$showallgroupstructure,$auto_wordwrap);
    				$adb->pquery($query, $qparams);
                    //新建字段时，自定义字段操作日志的表也要更新
                    $sql="insert into ld_cfoperationlog(tabid,fieldid,uitype,bigtype,relatedmodulefield,fieldlabel_zh,fieldlabel_en,create_operator,modifiedtime,createdtime) 
                            values(?,?,?,?,?,?,?,?,?,?)";
                    $adb->pquery($sql,array($servicechargetabid,$servicecharge_max_fieldid,$uitype,$savefldType,$isrelatedmodulefield,$fldlabel,$fldlabels,$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s')));

                    addTranlabel($servicechargetabid,$servicecharge_max_fieldid,$fldlabel,$fldlabels);

                    if ($fldType == 'express') {
                        $servicecharge_express_company_fieldid = getMaxFieldid();
                        $query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname
                                                ,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block
                                                ,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable
                                                ,approve_demand,advance_demand,advance_demand_groups,fldallow_rewriting,savedatabase,allowedit,allowdelete,bigtype,fieldonly,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder,editpage,input_type,auto_signin,no_signin,allowable_distance) 
                                                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                        $qparams = array($servicechargetabid,$servicecharge_express_company_fieldid,'express_company',$tableName,2,15,'express_company',
                            '物流公司',0,$presence,'',100,$max_seq+2,$servicecharge_blockid
                        ,$displaytype,$uichekdata,$quickcreate,$quickcreatesequence+1,'BAS',$masseditable
                        ,$approvedemand,$advancedemand,$advancedemandgroups,$fldallow_rewriting,$savedatabase,$allowedit,$allowdelete,'picklist',1,$datarang,$maxrowsshow,$take_photo_only,$uploadwatermark,$fieldvaluecolor,
                            $fieldplaceholder,$editpage,$input_type,$auto_signin,$no_signin,$allowable_distance);
                        $adb->pquery($query, $qparams);

                        addTranlabel($servicechargetabid,$servicecharge_express_company_fieldid,'物流公司','Logistics Company');
                        //新建字段时，自定义字段操作日志的表也要更新
                        $sql="insert into ld_cfoperationlog(tabid,fieldid,uitype,bigtype,fieldlabel_zh,fieldlabel_en,create_operator,modifiedtime,createdtime) 
                                values(?,?,?,?,?,?,?,?,?)";
                        $adb->pquery($sql,array($servicechargetabid,$servicecharge_express_company_fieldid,15,'picklist','物流公司','Logistics Company',$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s')));

                    }

                    //ls 2021-08-09 0047338: 服务收费管理模块，更改创建人，没有更改客户的“创建人所属部门”
                    if ($fldType=='memberdepartment') {
                        //zkt 20220726 BUG0054276客户模块，销售组别字段（字段类型：成员所属部门），偶尔出现单据保存后值为空的情况。
                        $servicechargetrigger_fieldid = $servicechargefocus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'fieldid');
                        if(!empty($servicechargetrigger_fieldid))
                        {
                            $sql='insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
                              value  (?,?,?,?,?,?,?)';
                            $adb->pquery($sql,array('main',$servicechargetrigger_fieldid,$servicecharge_max_fieldid,$columnName,'column','groupid','Users'));
                            unsetCache("all_getRelatedFieldInfo");//清除redis
                            unsetCacheDirectory('relatedfield');//清除文件缓存
                        }
                    }
                }


                if ($fldType=='memberdepartment') {
                    //更新新增字段的值
                    $trigger_tablename = $focus->fieldobj->getFieldInfoBykeyValue('columnname', $selectmemberfield, 'tablename');//获取选择的触发字段的表
                    $table_name=$focus->table_name;
                    $tablescf=$focus->customFieldTable[0];
                    $tablescfindex=$focus->customFieldTable[1];
                    $tableindex=$focus->table_index;
                    if($trigger_tablename==$focus->table_name)
                    {
                        $sql=" update  $tableName  inner join $table_name  on $tableName.$tablescfindex=$table_name.$tableindex ";
                    }
                    else
                        $sql=" update  $tableName ";

                    //获取用户列表所对应的部门id
                    $group_sql = "SELECT
        userid,
		GROUP_CONCAT(ld_groups.groupid ORDER BY ld_groups.groupid) AS groupid
	FROM
		ld_users2group
	INNER JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
	INNER JOIN ld_users ON ld_users.id = ld_users2group.userid
	GROUP BY
		ld_users2group.userid";
                    $group_sql_result = $adb->pquery($group_sql, array());
                    $sql.= " set $tableName.$columnName = ? where $selectmemberfield = ?";
                    for($j = 0; $j < $adb->num_rows($group_sql_result); $j++){
                        $adb->pquery($sql,array($adb->query_result($group_sql_result,$j,"groupid"), $adb->query_result($group_sql_result,$j,"userid")));
                    }

                }

                if($isrelatedmodulefield=='yes'&&$savedatabase=='yes')
                {

                    //更新新增字段的值
                    $sql=" select $trigger_columnname from $trigger_tablename ";
                    $relatetablename=$relatefocus->table_name;
                    $relatetableindex=$relatefocus->table_index;


                    $table_name=$focus->table_name;
                    $tablescf=$focus->customFieldTable[0];
                    $tablescfindex=$focus->customFieldTable[1];
                    $tableindex=$focus->table_index;
                    $tmpsql="
                    insert into $tablescf ($tablescfindex) select $tableindex from $table_name
                    where $tableindex not in(select $tablescfindex from $tablescf)";

                    $adb->pquery($tmpsql,array());
                    if($trigger_tablename==$focus->table_name)
                    {
                        $sql=" update  $tableName  inner join $table_name  on $tableName.$tablescfindex=$table_name.$tableindex ";

                    }
                    else
                        $sql=" update  $tableName  ";

                    $sql.=" inner join $relatetablename on $trigger_tablename.$trigger_columnname=$relatetablename.$relatetableindex ";
                    if($relatefieldinfo->getTableName()!=$relatetablename)
                    {
                        $relatetablescf=$relatefocus->customFieldTable[0];
                        $relatetablescfindex=$relatefocus->customFieldTable[1];
                        $sql.=" inner join $relatetablescf on $relatetablescf.$relatetablescfindex=$relatetablename.$relatetableindex";

                    }
                    //chj 2021/1/28 44458: （https://61mis.com/kfbcrm [^]）（苏州优乐蜂）新增引用字段，引用字段选择负责人，字段内容显示数字。比如说合同订单中新建了一个引用字段（字段名称： 测试引用字段负责人，引用对象：客户的销售负责人），创建完之后没有显示销售负责人的姓名
                    if(!empty($relatecolumnname) && !empty($relatemodule)){
                        $relatemodule_focus = CRMEntity::getInstance($relatemodule);
                        $fieldinfo = $relatemodule_focus->fieldobj->getFieldInfoobjBykey("columnname", $relatecolumnname);
                        if(!empty($fieldinfo)){
                            //文本类型时客户名要转化为姓名而非id,目前应该都是id 20241029 BUG20241029-10 出库单模块，，对应的“归属人”字段是引用合同模块的“归属人”过来的，引用过来没有值，麻烦帮忙处理一下，谢谢。
                            if($fieldinfo->getFieldDataType() == 'owner'&&$uitype == 1){
                                $sql .= " left join ld_users on ld_users.id = $relatetablename.$relatecolumnname";
                                require_once(globalStatic::$root_directory."appCommon/appCommon.php");

                                if(isKehu001ServerPc()=='yes')
                                {
                                    $str=' concat(\'<ww-open-data type="userName" name="wxopendata" openid="\',ld_users.wx_userid,\'"></ww-open-data>\')';
                                    $sql.=" set $tableName.$columnName=".$str;
                                }
                                else
                                    $sql.=" set $tableName.$columnName=ld_users.last_name";
                            }
                            //引用 translatefield 类型字段，历史数据更新使用翻译后的值
                            else if($fieldinfo->getBigType() == 'translatefield'){
                                $tmptranslatefieldvalues= getTranslateDbValueNew($relatemodule,$relatecolumnname);
                                $tmpsql = '';
                                if(!empty($tmptranslatefieldvalues)){
                                    $tmprelatecolumnnamesql = $relatefieldinfo->getTableName().'.'.$relatecolumnname;
                                    foreach($tmptranslatefieldvalues as $column_dbvalue=>$tmp_arr)
                                    {
                                        $labebol = $tmp_arr['labelbol'];
                                        $tmplablebo = "'".getFixedLabel($labebol)."'";
                                        $tmpsql .= " when $tmprelatecolumnnamesql = '$column_dbvalue' then $tmplablebo ";
                                        unset($tmplablebo,$labebol);
                                    }
                                    if(empty($tmpsql)){
                                        $tmpsql = " WHEN 1=2 THEN  ".$relatefieldinfo->getTableName().'.'.$relatecolumnname."  ";
                                    }
                                    $tmpsql = " set $tableName.$columnName= (CASE ".$tmpsql." ELSE ".$relatefieldinfo->getTableName().'.'.$relatecolumnname." END) ";
                                }
                                else{
                                    $tmpsql =" set $tableName.$columnName=".$relatefieldinfo->getTableName().'.'.$relatecolumnname;
                                }
                                $sql.= $tmpsql;
                                unset($tmpsql,$tmptranslatefieldvalues);
                            }
                            else{
                                $sql.=" set $tableName.$columnName=".$relatefieldinfo->getTableName().'.'.$relatecolumnname;
                            }
                        }else{
                            $sql.=" set $tableName.$columnName=".$relatefieldinfo->getTableName().'.'.$relatecolumnname;
                        }
                    }else{
                        $sql.=" set $tableName.$columnName=".$relatefieldinfo->getTableName().'.'.$relatecolumnname;
                    }
                    $adb->pquery($sql,array());


                }
                // wym 多选关联字段先不做相关信息列 以后要做可以再加上
                if($fldType=='reference')
                {
                    $tmpid=$adb->getUniqueID('ld_relatedlists');
                    $params=array();
                    //  $relate_tabid=getTabid($referencemodule);
                    $params[]=$tmpid;
                    if($referencemodule=='Calendar')
                    {
                        $params[]=9;
                    }
                    else
                    {
                        $params[]=getTabid($referencemodule);
                    }

                    if(strtolower($fldmodule)=='events')
                    {
                        $params[]=9;
                        $params[]='get_'.strtolower('Calendar');
                        $params[]=10000;
                        $params[]='Calendar';
                    }else if(strtolower($fldmodule)=='singin'){
                        //duan 20231103 拜访签到关联选择字段关联处理
                        $params[]=getTabid($fldmodule);
                        $params[]='get_'.strtolower($fldmodule).'_list';
                        $params[]=10000;
                        $params[]=$fldmodule;
                    }
                    else
                    {
                        $params[]=getTabid($fldmodule);
                        $params[]='get_'.strtolower($fldmodule);
                        $params[]=10000;
                        $params[]=$fldmodule;
                    }

                    $params[]=1;
                    $params[]='add';
                    $params[]='datacategory_sql';
                    $tmptablename=trim(strtolower($tableName));
                    $tmptablename=substr($tmptablename,3);
                    $params[]=$tmptablename.'.'.$columnName;
                    $params[]=1;
                    $params[]=10000;
                    $params[]='[{"columnname":"'.$tmptablename.'.'.$columnName.'","comparator":"e","columncondition":""}]';//wym 240124 XUQIU1002043 单据相关信息显示数据的查询规则可定义(插入默认值,否则相关信息栏-高级设置不会生效)
                    
                    if(strtolower($fldmodule)=='singin' || strtolower($fldmodule)=='signout'){// buttonstatus
                        $params[] = 'no';
                    }else{
                        $params[] = 'yes';
                    }
                    $sql=' insert into ld_relatedlists(relation_id,tabid,related_tabid,name,
                                        sequence,label,presence,actions,type,related_coltable,wx_presence,wx_sequence,related_advanceset,buttonstatus)
                                value(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';

                    $adb->pquery($sql,$params);


                    $referencefocus=CRMEntity::getInstance($referencemodule);
                    $hrefcolumn=$referencefocus->list_link_field;
                    $no_fieldname=$referencefocus->fieldobj->getFieldInfoBykeyValue('uitype',4,'fieldname');
                    $smownercolumnname=$referencefocus->getSmownerColumName();
                    //设置查询列表的列头
                    $sql='update ld_field set searchfieldtype=0 where tabid=? and (fieldname=? or fieldname=? or columnname=?) ';
                    $adb->pquery($sql,array(getTabid($referencemodule),$hrefcolumn,$no_fieldname,$smownercolumnname));
                    unsetCache('fields_getAllFieldTypeInfo');//清空uitype的缓存
                    unsetCache("cache_getrelatedlistinfobyid_relationid_".$params[1]);
                    unsetCache('cache_getrelatedlistinfobytabid');


                }
                if($fldType=='mobile'&&$_REQUEST['regexp']==1)
                {
                    //edit:can 20210804 47203: （https://81mis.com/kfbcrm [^]） 报表-自定义表单99-单据编号ZDYBD99-2 页面设置 手机字段 勾选了 严格11位手机号码格式 但是乱输入时 可以保存成功 并未提示请输入正确的手机号码
                    $sql='insert into  ld_validatasave(module,relatedtable,fieldname,comparator,formulavalue,comparatordescription,validatasavetype)
                            value(?,?,?,?,?,?,?)';
                    $adb->pquery($sql,array($fldmodule,'ld_field',$fieldname,'regexp','','正则表达式','js'));
                    $tmp_relateid=$adb->getLastInsertID();
                    $sql='insert into  ld_validatasavedetail(relateid,relateformulavalue,sequence)value(?,?,?)';
                    $adb->pquery($sql,array($tmp_relateid,"^1\\d{10}$",1));

                }
                //duan 20221212 拜访签到模块增加自定义字段时，需要在签到统计表中同步增加可设置字段
                if($fldmodule == 'Singin'){
                    //暂时只允许选择一部分字段类型，其他的太复杂就不做了，时间来不及，以后再补充
                    $bigtype_arr = array('text','textarea','longtextarea','picklist','multipicklist','date','time','datetime','number');
                    if(in_array($fldType,$bigtype_arr)){
                        $com_columnname_zh = $tableName.':'.$columnName.':'.$fieldname.':OftenUseReport_'.$fldlabel.':V';
                        $com_columnname_en = $tableName.':'.$columnName.':'.$fieldname.':OftenUseReport_'.$fldlabels.':V';
                        $sql = "SELECT ld_usereport.usereportid,MAX(ld_usereportcolumns.Sequence) from ld_usereport
                                INNER JOIN ld_usereportcolumns on ld_usereportcolumns.Usereportid = ld_usereport.usereportid
                                where ld_usereport.`name` = 'SIGNINSTATISTICS';";
                        $tmp_result = $adb->pquery($sql);
                        if($adb->num_rows($tmp_result)>0){
                            $usereportid = $adb->query_result($tmp_result,0,'usereportid');
                            $Sequence = (int)$adb->query_result($tmp_result,0,'Sequence');
                            $insertsql = 'insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns,is_advanced) values(?,?,?,?,?,?,?)';
                            $adb->pquery($insertsql,array($usereportid,$com_columnname_zh,$Sequence+1,0,$com_columnname_zh,$com_columnname_en,0));
                        }
                    }
                }
                //Inserting values into ld_profile2field lingdang_tables
                $sql1 = "select * from ld_profile";
                $sql1_result = $adb->pquery($sql1, array());
                $sql1_num = $adb->num_rows($sql1_result);
                for($i=0; $i<$sql1_num; $i++) {
                    $profileid = $adb->query_result($sql1_result,$i,"profileid");
                    $sql2 = "insert into ld_profile2field values(?,?,?,?,?,?)";
                    $adb->pquery($sql2, array($profileid, $tabid, $custfld_fieldid, 0, 0, 0));
                    if ($fldType == 'express') {//给当前模块添加字段权限
                        $adb->pquery($sql2, array($profileid, $tabid, $express_company_fieldid, 0, 0, 0));
                    }
                    if (!empty($servicechargetabid)) {
                        $adb->pquery($sql2, array($profileid, $servicechargetabid, $servicecharge_max_fieldid, 0, 0, 0));
                        if ($fldType == 'express') {//给其它模块添加字段权限
                            $adb->pquery($sql2, array($profileid, $servicechargetabid, $servicecharge_express_company_fieldid, 0, 0, 0));
                        }
                    }

                }

                //Inserting values into def_org lingdang_tables
                $sql_def = "insert into ld_def_org_field values(?,?,?,?)";
                $adb->pquery($sql_def, array($tabid, $custfld_fieldid, 0, 0));
                if ($fldType == 'express') {
                    $adb->pquery($sql_def, array($tabid, $express_company_fieldid, 0, 0));
                }
                if (!empty($servicechargetabid)) {
                    $adb->pquery($sql_def, array($servicechargetabid, $servicecharge_max_fieldid, 0, 0));
                    if ($fldType == 'express') {
                        $adb->pquery($sql_def, array($servicechargetabid, $servicecharge_express_company_fieldid, 0, 0));
                    }
                }

                if($fldType == 'picklist' || $fldType == 'multipicklist') {
                    $columnName = $adb->sql_escape_string($columnName);
                    $picklist=$_REQUEST['fldPickList'];
                    if($_REQUEST['fieldid'] == ''&&trim(trim($picklist,"##,,##"))!='') {
                        //Eidtor:gyq_64 Reason:下拉框改进为统一下拉表 Date:2018/3/7 0007 下午 2:04

                        $picklist=implode("\n",explode("##,,##",$_REQUEST['fldPickList']));
                        $objPickList->addPickField($picklist,$columnName,'ld_field');
                    }
                    //旧代码001 Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/7 0007 上午 10:40
                }

                if ($fldType == 'fileattachment'){
                    $updatesql = 'update ld_attachments_watermark_setting set fieldname=? where id=?';
                    if ($word_watermark_settingid != 'empty'){
                        $adb->pquery($updatesql,array($fieldname,$word_watermark_settingid));
                    }
                    if ($excel_watermark_settingid != 'empty'){
                        $adb->pquery($updatesql,array($fieldname,$excel_watermark_settingid));
                    }
                }

            }
        }
    }
    //zxm2021-0408 二维码字段类型 修改二维码类型
    $fdcodetype_value = $_REQUEST['fdcodetype_value'];
    if(!empty($fdcodetype_value)){
        $sql=' update ld_field set uitype=? where fieldid=?';
        $adb->pquery($sql, [$fdcodetype_value,$custfld_fieldid]);
    }
    $qrcodetemplateid = $_REQUEST['qrcodetemplateid'];
    if(!empty($qrcodetemplateid)){
        $sql=' update ld_qrcode_template set fieldid=? where qrcodetemplateid=?';
        $adb->pquery($sql, [$custfld_fieldid,$qrcodetemplateid]);
    }
    //xxy 2023-11-8 新增字段敏感规则保存
    if($sensitive_ruleid_arr != "" && $sensitivepresence != ""){
        crm_load_class_file("cls_SensitiveRules",'modules/Settings');
        cls_SensitiveRules::updateRulesFieldid($custfld_fieldid,$sensitive_ruleid_arr);
        cls_SensitiveRules::updateFieldSensitiveStatus($custfld_fieldid,$sensitivepresence);
    }
    $cachekey = 'cache_getmodfldcolumninfotabid_'.$tabid;
    unsetCache($cachekey);
    $cachekey = 'cache_dbvalidationdatainfozh_'.$tabid;
    unsetCache($cachekey);
    $cachekey = 'cache_dbvalidationdatainfoen_'.$tabid;
    unsetCache($cachekey);
    if(!empty($servicechargetabid))
    {
        $cachekey = 'cache_getmodfldcolumninfotabid_'.$servicechargetabid;
        unsetCache($cachekey);
        $cachekey = 'cache_dbvalidationdatainfozh_'.$servicechargetabid;
        unsetCache($cachekey);
        $cachekey = 'cache_dbvalidationdatainfoen_'.$servicechargetabid;
        unsetCache($cachekey);
    }
    unsetCacheDirectory('fields');
    if($fldmodule == 'CashBill'||$fldmodule=='SendCashBill'){
        unsetCacheDirectory('productfields');
    }

}

/**
 * show_move_hiddenfields()
 *
 * @return
 */
function show_move_hiddenfields($submode) {
    global $adb;
    $selected_fields = $_REQUEST['selected'];
    $selected = trim($selected_fields,":");
    $sel_arr = array();
    $sel_arr = explode(":",$selected);
    $sequence = $adb->pquery('select max(sequence) as maxseq from ld_field where block = ?  and tabid = ?',array($_REQUEST['blockid'],$_REQUEST['tabid']));
    $max = $adb->query_result($sequence,0,'maxseq');
    if($_REQUEST['fld_module']=='Accounts')
    {
        $servicecharge_tabid=getTabid("ServiceCharge");
    }


    if($submode == 'showhiddenfields') {
        for($i=0; $i< count($sel_arr);$i++) {
            $res = $adb->pquery('update ld_field set presence = 2,sequence = ? where block = ? and fieldid = ?', array($max+1,$_REQUEST['blockid'],$sel_arr[$i]));

            if($_REQUEST['fld_module']=='Contacts')//联系人
            {
                /**
                 * 更新操作
                 * edit:can
                 * date:20131031
                 * reason:5561: 当联系人相关字段设置为不启用，或者不允许重复时，客户首要联系人字段应该对应设置
                 * */
                $sql='select columnname from ld_field where block = ? and fieldid = ?';
                $colresult=$adb->pquery($sql, array($_REQUEST['blockid'],$sel_arr[$i]));
                $colname=$adb->query_result($colresult,0,0);
                $sql="update ld_field set presence=2 where columnname=? and tabid=?";
                $adb->pquery($sql,array($colname,6));

                $sql="update ld_field set presence=2 where columnname=? and tabid=(select tabid from ld_tab where name=?)";
                $adb->pquery($sql,array($colname,"ServiceCharge"));

            }
            if(!empty($servicecharge_tabid))
            {
                $sql='select columnname from ld_field where block = ? and fieldid = ?';
                $colresult=$adb->pquery($sql, array($_REQUEST['blockid'],$sel_arr[$i]));
                $colname=$adb->query_result($colresult,0,0);
                $sql="update ld_field set presence=2 where columnname=? and tabid=?";
                $adb->pquery($sql,array($colname,$servicecharge_tabid));
            }
            $max++;
        }
    }
    else {
        for($i=0; $i< count($sel_arr);$i++) {
            $res = $adb->pquery('update ld_field set sequence = ? , block = ? where fieldid = ?', array($max+1,$_REQUEST['blockid'],$sel_arr[$i]));
            $max++;
        }
    }
    unsetCacheDirectory('fields');
}
/*
chj
2013-9-16
更多信息字段
*/
/**
 * getRelatedOrder()
 *
 * @return
 */
function getRelatedOrder()
{
    global $adb;
    $tabid = $_REQUEST['tabid'];
    global $current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $query = " select ld_relatedlists_lable.id,ld_field.fieldid,ld_tranlabel.fieldlabel,ld_field.tablename 
    from ld_relatedlists_lable 
    inner join ld_field on ld_field.fieldid = ld_relatedlists_lable.fieldid 
    inner join ld_tranlabel  on ld_field.fieldid = ld_tranlabel.relateid 
    where ld_tranlabel.languagetype=? and trantable=? and ld_relatedlists_lable.tabid=? 
    order by ld_field.sequence asc";

    /*$query = "select ld_relatedlists_lable.id,ld_field.fieldid,ld_tranlabel.fieldlabel,ld_field.tablename
     from ld_relatedlists_lable where tabid = '".$tabid.
    "' and presence = 1 order by sequence asc";*/
    $parinfo = $adb->pquery($query,array($languageType,'ld_field',$tabid));
    $noofrows = $adb->num_rows($parinfo);
    for($i=0;$i<$noofrows;$i++) {
        $res[$i]['name'] = $adb->query_result($parinfo,$i,'fieldid');
        $res[$i]['label'] = $adb->query_result($parinfo,$i,'fieldlabel');
        $res[$i]['id'] = $adb->query_result($parinfo,$i,'id');
        $res[$i]['tabid'] = $tabid;
    }
    return $res;
}
/**
 * getFieldlabel()
 *
 * @return
 */
function getFieldlabel($fieldid)
{
    global $adb;
    $sql2="select fieldlabel from ld_field where fieldid = ? ";
    $result2 = $adb->pquery($sql2, array($fieldid));
    return  $adb->query_result($result2,0,'fieldlabel');
}
/**
 * getfieldName()
 *
 * @return
 */
function getfieldName($fieldname)
{
    // $language_strings = return_module_language($current_language,'Settings');
    if($language_strings[$fieldname] != null)
    {
        return $language_strings[$fieldname];
    }
    else
    {
        return $fieldname;
    }
}
/**
 * getRelatedListInfo()
 *
 * @return
 */
function getRelatedListInfo($module) {
    global $adb;
    $tabid = getTabid($module);

    $related_query = 'select * from ld_relatedlists ' .
        'inner join ld_tab on ld_relatedlists.related_tabid = ld_tab.tabid and ld_tab.presence = 0 where ld_relatedlists.tabid = ? order by sequence';
    $relinfo = $adb->pquery($related_query,array($tabid));
    $noofrows = $adb->num_rows($relinfo);
    for($i=0;$i<$noofrows;$i++) {
        $res[$i]['name'] = $adb->query_result($relinfo,$i,'name');
        $res[$i]['sequence'] = $adb->query_result($relinfo,$i,'sequence');
        $label = $adb->query_result($relinfo,$i,'label');
        $relatedModule = getTabname($adb->query_result($relinfo,$i,'related_tabid'));
        if($label != 'BalanceOfAccount')
            $res[$i]['label'] = getTranstab($label);
        else
            $res[$i]['label'] = getFixedLabel('BALANCEOFACCOUNT');
        $res[$i]['presence'] = $adb->query_result($relinfo,$i,'presence');
        $res[$i]['tabid'] = $tabid;
        $res[$i]['id'] = $adb->query_result($relinfo,$i,'relation_id');
    }
    return $res;
}
/*
edit:chj
date:20131024
reason:修改更多信息中模块字段排序
*/
/**
 * changeRelatedListPersence()
 *
 * @return
 */
function changeRelatedListPersence()
{
    global $adb;
    $id = $_REQUEST['id'];
    $tabid = $_REQUEST['tabid'];
    $what_todo = $_REQUEST['what_to_do'];
    if(!empty($_REQUEST['what_to_do'])) {
        $getOrder = $adb->pquery('select sequence from ld_relatedlists_lable where tabid = '. $tabid .' and id = ' . $id);
        $NowOrder = $adb->query_result($getOrder,0,'sequence');
        if($_REQUEST['what_to_do'] == 'move_up')
        {
            $NextOrder = $NowOrder - 1;
            $getId = $adb->pquery('select id from ld_relatedlists_lable where sequence < ? and tabid = '. $tabid .'  order by sequence desc limit 0,1 ',array($NowOrder));

        }
        elseif($_REQUEST['what_to_do'] == 'move_down')
        {
            $NextOrder = $NowOrder + 1;
            $getId = $adb->pquery('select id from ld_relatedlists_lable where sequence > ? and tabid = '. $tabid .' order by sequence asc limit 0,1 ',array($NowOrder));
        }
        $NextId = $adb->query_result($getId,0,'id');
        if($NowOrder >= 2)
        {
            $adb->pquery('update ld_relatedlists_lable set sequence = ? where tabid = '. $tabid .' and id = ?',array($NowOrder,$NextId));
            $adb->pquery('update ld_relatedlists_lable set sequence = ? where tabid = '. $tabid .' and  id = ?',array($NextOrder,$id));

        }
    }
}
//快速创建设置
function updateTabDuplicate(){
    if(!empty($_REQUEST['modulename']) && !empty($_REQUEST['isduplicate'])){
        global $adb;
        $query = 'update ld_tab set isduplicate = ? where `name` = ?';
        $adb->pquery($query,array($_REQUEST['isduplicate'],$_REQUEST['modulename']));
        $cachekey = 'cache_gettabduplicate';
        unsetCache($cachekey);
        exit();
    }
}
//更新区块的顺序
function updateBlockSequence(){
    global $adb;
    if(!empty($_REQUEST['new_blockid_sequence']) && !empty($_REQUEST['fld_module'])){
        $blockids = explode(',',$_REQUEST['new_blockid_sequence']);
        $tabid = getTabid($_REQUEST['fld_module']);
        $sequence = 1;
        foreach($blockids as $blockid){
            $query = "update ld_blocks set sequence = ? where blockid = ? and tabid = ?";
            $adb->pquery($query,array($sequence,$blockid,$tabid));
            $sequence++;
        }
        //unsetCacheDirectory("fields");
    }
    exit();
}
//单个区块移动字段
function updateColumnSequence(){
    global $adb;
    //wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
    //wyt 221213 BUG0059846 kfbcrm 页面设置---关键信息栏---拖动字段顺序，刷新页面后就变回去了
    if(!empty($_REQUEST['new_columnname_sequence']) && !empty($_REQUEST['fld_module']) && !empty($_REQUEST['blockid'])){
        $columns = explode(',',$_REQUEST['new_columnname_sequence']);
        $tabid = getTabid($_REQUEST['fld_module']);
        $sequence = 1;
        $blockid = $_REQUEST['blockid'];
        foreach($columns as $columnname){
            if($blockid=='keyword'){
                $query = "update ld_field set keyword_sseq = ? where  tabid = ? and columnname = ?";
                $adb->pquery($query,array($sequence,$tabid,$columnname));
            }else{
                $query = "update ld_field set sequence = ? where block = ? and tabid = ? and columnname = ?";
                $adb->pquery($query,array($sequence,$blockid,$tabid,$columnname));
            }
            $sequence++;
        }
    }
    unsetCacheDirectory("fields");
    exit();
}

//跨区块移动字段
function updateColumnSequence_Block(){
    global $adb;
    if(!empty($_REQUEST['second_columnname_sequence']) && !empty($_REQUEST['fld_module']) && !empty($_REQUEST['second_blockid'])){
        $columns = explode(',',$_REQUEST['second_columnname_sequence']);
        $tabid = getTabid($_REQUEST['fld_module']);
        $sequence = 1;
        $blockid = $_REQUEST['second_blockid'];
        foreach($columns as $columnname){
            $query = "update ld_field set sequence = ?,block=? where tabid = ? and columnname = ?";
            $adb->pquery($query,array($sequence,$blockid,$tabid,$columnname));
            $sequence++;
        }
        //unsetCacheDirectory("fields");
    }
    if(!empty($_REQUEST['first_columnname_sequence']) && !empty($_REQUEST['fld_module']) && !empty($_REQUEST['first_blockid'])){
        $columns = explode(',',$_REQUEST['first_columnname_sequence']);
        $tabid = getTabid($_REQUEST['fld_module']);
        $sequence = 1;
        $blockid = $_REQUEST['first_blockid'];
        foreach($columns as $columnname){
            $query = "update ld_field set sequence = ?,block=? where tabid = ? and columnname = ?";
            $adb->pquery($query,array($sequence,$blockid,$tabid,$columnname));
            $sequence++;
        }
        //unsetCacheDirectory("fields");
    }
    unsetCacheDirectory("fields");
    exit();
}
/*
edit:can
date:20131024
*/
/**
 * changeRelatedListOrder()
 *
 * @return
 */
function changeRelatedListOrder()
{
    global $adb;
    $tabid = $_REQUEST['tabid'];
    $what_todo = $_REQUEST['what_to_do'];
    if(!empty($_REQUEST['what_to_do'])) {
        if($_REQUEST['what_to_do'] == 'move_up') {
            $currentsequence = $_REQUEST['sequence'];

            $previous_relation = $adb->pquery('select relation_id,sequence from ld_relatedlists where sequence < ? and tabid = ? order by sequence desc limit 0,1',array($currentsequence,$tabid));
            $previous_sequence = $adb->query_result($previous_relation,0,'sequence');
            $previous_relationid = $adb->query_result($previous_relation,0,'relation_id');

            $adb->pquery('update ld_relatedlists set sequence = ? where relation_id = ? and tabid = ?',array($previous_sequence,$_REQUEST['id'],$tabid));
            $adb->pquery('update ld_relatedlists set sequence = ? where tabid = ? and relation_id = ?',array($currentsequence,$tabid,$previous_relationid));
        }elseif($_REQUEST['what_to_do'] == 'move_down') {

            $currentsequence = $_REQUEST['sequence'];

            $next_relation = $adb->pquery('select relation_id,sequence from ld_relatedlists where sequence > ? and tabid = ? order by sequence limit 0,1',array($currentsequence,$tabid));
            $next_sequence = $adb->query_result($next_relation,0,'sequence');
            $next_relationid = $adb->query_result($next_relation,0,'relation_id');

            $adb->pquery('update ld_relatedlists set sequence = ? where relation_id = ? and tabid = ?',array($next_sequence,$_REQUEST['id'],$tabid));
            $adb->pquery('update ld_relatedlists set sequence = ? where tabid = ? and relation_id = ?',array($currentsequence,$tabid,$next_relationid));

        }
    }
}
/**
 * edit andy
 * reason 修改区块名称
 * date 20140617
 * verson v5.32
 */
function changeBlockName()
{
    global $adb;
    $tabid = vtlib_purify($_REQUEST['tabid']);
    $blockid = vtlib_purify($_REQUEST['blockid']);
    if($tabid==6||getTabid('ServiceCharge')==$tabid)
    {
        //37688: （1.6）客户页面设置中新增区块与字段时，服务收费管理页面设置中也同时新增，但服务收费管理页面设置中新增区块与字段时，客户页面设置中没有同时新增。预期结果：服务收费管理页面设置中新增区块与字段时，客户页面设置中也应该同时新增区块与字段
        if($tabid==6)
            $servicecharge_tabid=getTabid('ServiceCharge');
        else
            $servicecharge_tabid=getTabid('Accounts');
        $blocksql='select blockid from ld_blocks where blocklabel=(select blocklabel from ld_blocks where blockid=?) and tabid=?';
        $blockresult=$adb->pquery($blocksql,array($blockid,$servicecharge_tabid));
        if($adb->num_rows($blockresult)>0)
        {
            $servicecharge_blockid=$adb->query_result($blockresult,0,0);

        }

    }
    //0050541: （https://81mis.com/kfbcrm/index.php [^]）系统设置》页面设置，客户页面设置，新建区块名称为“123”，改区块名为“基本信息”，没给提示重复，会导致区块收起展开问题
    $fildlable_zh= $_REQUEST['fildlable_zh'];
    $fildlable_en= $_REQUEST['fildlable_en'];
    $dup_check_query="select ld_tranlabel.fieldlabel,languagetype from ld_tranlabel INNER JOIN ld_blocks
        on ld_tranlabel.Relateid=ld_blocks.blockid and ld_tranlabel.trantable='ld_blocks'
        where ld_tranlabel.tabid=? and ld_blocks.tabid=? and ld_blocks.blockid<>".$blockid;

    $tmpresult=$adb->pquery($dup_check_query,array($tabid,$tabid));
    $norows=$adb->num_rows($tmpresult);
    for($i=0;$i<$norows;$i++) {
        $blklbl = $adb->query_result($tmpresult,$i,'fieldlabel');
        if(strtolower($blklbl)==strtolower($fildlable_en))
        {
            $duplicate='yes';
            return $duplicate;
        }
        if(strtolower($blklbl) == strtolower($fildlable_zh)) {
            $flag = 1;
            $duplicate='yes';
            return $duplicate;
        }
    }
    if(isset($_REQUEST['fildlable_zh_old']) && $_REQUEST['fildlable_zh_old'] != $_REQUEST['fildlable_zh']){
        $sql="update ld_tranlabel set fieldlabel=? where tabid=? 
      and relateid=? and trantable='ld_blocks' and languagetype='zh'";
        $params=array($_REQUEST['fildlable_zh'],$tabid,$blockid,);
        $adb->pquery($sql,$params);
        if(!empty($servicecharge_blockid))
        {
            $sql="update ld_tranlabel set fieldlabel=? where tabid=? 
          and relateid=? and trantable='ld_blocks' and languagetype='zh'";
            $params=array($_REQUEST['fildlable_zh'],$servicecharge_tabid,$servicecharge_blockid,);
            $adb->pquery($sql,$params);
        }
    }
    if(isset($_REQUEST['fildlable_en_old']) && $_REQUEST['fildlable_en_old'] != $_REQUEST['fildlable_en']){
        $sql="update ld_tranlabel set fieldlabel=? where tabid=? 
      and relateid=? and trantable='ld_blocks' and languagetype='en'";
        $params=array($_REQUEST['fildlable_en'],$tabid,$blockid,);
        $adb->pquery($sql,$params);
        if(!empty($servicecharge_blockid))
        {
            $sql="update ld_tranlabel set fieldlabel=? where tabid=? 
              and relateid=? and trantable='ld_blocks' and languagetype='en'";
            $params=array($_REQUEST['fildlable_en'],$servicecharge_tabid,$servicecharge_blockid,);
            $adb->pquery($sql,$params);
        }
    }

    $cachekey = 'cache_moduleblock_trantableinfozh_detail_view_'.$tabid;
    $cachemoduleblock = unsetCache($cachekey);
    $cachekey = 'cache_moduleblock_trantableinfoen_detail_view_'.$tabid;
    $cachemoduleblock = unsetCache($cachekey);
    $cachekey = 'cache_moduleblock_trantableinfozh_edit_view_'.$tabid;
    $cachemoduleblock = unsetCache($cachekey);
    $cachekey = 'cache_moduleblock_trantableinfoen_edit_view_'.$tabid;
    $cachemoduleblock = unsetCache($cachekey);
    if(!empty($servicecharge_blockid))
    {
        $cachekey = 'cache_moduleblock_trantableinfozh_detail_view_'.$servicecharge_tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfoen_detail_view_'.$servicecharge_tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfozh_edit_view_'.$servicecharge_tabid;
        $cachemoduleblock = unsetCache($cachekey);
        $cachekey = 'cache_moduleblock_trantableinfoen_edit_view_'.$servicecharge_tabid;
        $cachemoduleblock = unsetCache($cachekey);
    }
}
//进度跟踪设置保存
function saveLayoutBlockAdvance(){
    global $adb;
    $frommodule = $_REQUEST['frommodule'];
    if($frommodule == 'Events'){
        $frommodule = 'Calendar';
    }
    //zxm 20230403 kfbcrm-自定义表单-页面设置-自动化进度设置-勾选“pc端启用进度跟踪”“移动端启用进度跟踪” 页面一直加载转圈
    if(empty($_REQUEST['module_field'])||$_REQUEST['module_field']=="null"){
        ConvertTojsonString(-1,array(),getFixedLabel('Selecttrackingfield').getFixedLabel('APPCANNOTBEEMPTY'));
    }
    if(!empty($frommodule)){
        $tabid = getTabid($frommodule);
        $query = 'select method,module_field,module_period_start_field,module_period_end_field from ld_settings_advance where tabid = ? limit 1';
        $result = $adb->pquery($query,array($tabid));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $method = $adb->query_result($result,0,'method');
            $before_module_field = $adb->query_result($result,0,'module_field');
            $before_module_period_start_field = $adb->query_result($result,0,'module_period_start_field');
            $before_module_period_end_field = $adb->query_result($result,0,'module_period_end_field');
            $update = 'update ld_settings_advance set module = ?,enable = ?,method = ?,module_field = ?,module_period_start_field = ?,module_period_end_field = ?,
			showadvancelog = ?,showadvancemobile = ?,pushback = ?,operatestyle = ?,logshowstyle = ? where tabid = ?';
            $adb->pquery($update,array($_REQUEST['frommodule'],$_REQUEST['enable'],$_REQUEST['method'],$_REQUEST['module_field'],
                $_REQUEST['module_period_start_date_field'],$_REQUEST['module_period_end_date_field'],$_REQUEST['showadvancelog'],
                $_REQUEST['showadvancemobile'],$_REQUEST['pushback'],$_REQUEST['operatestyle'],$_REQUEST['logshowstyle'],$tabid));
        }else{
            $query = 'insert into ld_settings_advance(tabid,module,enable,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile,pushback,operatestyle,logshowstyle) values (?,?,?,?,?,?,?,?,?,?,?,?)';
            $adb->pquery($query,array($tabid,$_REQUEST['frommodule'],$_REQUEST['enable'],$_REQUEST['method'],$_REQUEST['module_field'],
                $_REQUEST['module_period_start_date_field'],$_REQUEST['module_period_end_date_field'],$_REQUEST['showadvancelog'],
                $_REQUEST['showadvancemobile'],$_REQUEST['pushback'],$_REQUEST['operatestyle'],$_REQUEST['logshowstyle']));
        }
        //指定字段
        if($_REQUEST['method'] == 'field'){
            $update = "update ld_field set presence = 1 where tabid = ? and fieldname in('advance_stage')";
            $adb->pquery($update,array($tabid,));
        }else{
            $update = "update ld_field set presence = 0 where tabid = ? and fieldname = 'advance_stage'";
            $adb->pquery($update,array($tabid,));
        }
        //zkt 20221122 BUG0058831启用进度推进，设置按“指定字段”并选择“跟踪字段”后，跟踪字段是不允许直接编辑的，但是在列表仍可编辑
        $editpage = '';
        if($_REQUEST['enable']!='yes'&&$_REQUEST['showadvancemobile']!='yes'){
            $editpage = 'listview';
        }
        if(!empty($before_module_field)&&$before_module_field != $_REQUEST['module_field']){
            $update = "update ld_field set editpage = 'listview' where tabid = ? and fieldname = ?";
            $adb->pquery($update,array($tabid,$before_module_field));
        }
        $update = "update ld_field set editpage = ? where tabid = ? and fieldname = ?";
        $adb->pquery($update,array($editpage,$tabid,$_REQUEST['module_field']));
        //duan 2022-2-7 切换进度追踪字段后，对应的推进阶段字段值没有更新，导致进度漏斗显示值为0
        if($_REQUEST['method'] == 'field' && $_REQUEST['module_field'] != $before_module_field ){
            update_advancestage_value($frommodule,$_REQUEST['module_field'],$_REQUEST['method']);
        }

        unsetCacheDirectory('fields');
        unsetCache('ld_settigs_module_advance'.$tabid);
    }

    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,array(),"success");
}
/**
 * edit andy
 * reason 修改相关模块显示及顺序
 * date 20140617
 * verson v5.32
 */
function setRelatedLists($type)
{
    global $adb;
    //zkt 20230922 相关信息显示的数据tabid和name相同时也应该可以显示设置
    $action_table_columnname = 'related_tabid';
    if ($type == 1) {
        $action_table_name = 'ld_relatedlists';
        $action_table_columnname = 'relation_id';
    }
    else
        $action_table_name='ld_quickactions';
    $tabid = vtlib_purify($_REQUEST['tabid']);
    $cachekey = 'cache_getQuickActionsInfo'.$tabid;
    unsetCache($cachekey);
    if($type==1)
    {
        $to_beselect_module_str = $_REQUEST['AssmablyColumnsString'];
        $be_beselected_module_str = $_REQUEST['selectedAssmablyColumnsString'];
    }
    else
    {
        $to_beselect_module_str = $_REQUEST['tobeselecte_module_String'];
        $be_beselected_module_str = $_REQUEST['beselected_module_String'];
    }
    $be_beselected_module_str = trim($be_beselected_module_str,';');
    $to_beselect_module_str=trim($to_beselect_module_str,';');
    $to_beselect_module_arr = explode(';',$to_beselect_module_str) ;
    foreach($to_beselect_module_arr as $beselect_module){
        $beselect_module_array = explode('_',$beselect_module);
        $beselect_array[] = $beselect_module_array[0];
    }
    $be_beselected_module_arr = explode(';',$be_beselected_module_str) ;
    foreach($be_beselected_module_arr as $beselect_module){
        $beselected_module_array = explode('_',$beselect_module);
        $beselected_array[] = $beselected_module_array[0];
    }

    //修改选择模块排序,按照新的排序规则

    foreach($beselected_array as $k => $val)
    {
        if($val != ''){
            $sql = 'update ' . $action_table_name . ' set sequence = ?,presence=0 where tabid=? and '.$action_table_columnname.' =?';
            $adb->pquery($sql, array($k, $tabid, $val));
        }
    }
    /**
     * 同步修改一下其他的关联创建
     * @reason 0013094: 采购>>采购退货单名明细界面，设置关联创建后，关联创建字段显示出错，没有在一个区，有一个在工具区下面
     * @author Tujt 2014-12-23
     */
    $sql = 'update '.$action_table_name.' set sequence = ? where tabid = ? and sequence < ? and '.$action_table_columnname.' not in ('.join(',',$beselected_array).') ';
    $adb->pquery($sql,array($k+1,$tabid,$k+1));
    //修改未选模块不不显示
    //  $intersection_no=array_diff($to_beselect_module_arr,$be_beselected_module_arr);
    //非全部相关模块选中执行以下操作
    // print_r($to_beselect_module_arr);

    if(count($to_beselect_module_arr) >0 ){
        foreach($to_beselect_module_arr as $key => $val)
        {
            $label_arr = explode('_',$val);
            $strlen = strlen($label_arr[0]) + 1;
            if(sizeof($label_arr)>=2&&$label_arr[2]!='')
            {
                $name=$label_arr[1].'_'.$label_arr[2];
                if(sizeof($label_arr)>3)
                {
                    $name.='_'.$label_arr[3];
                }
            }
            else
            {
                $name=$label_arr[1];
            }
            //24289: 客户>页面设置>客户：相关信息设置弹出层可用项目中没有【签到记录】
            //客户中有两个related_tabid等于零
            //0024511: 客户列表：相关信息设置，“工作协同”字段移动到可用项目中保存后，“工作协同”字段还是显示在 显示的项目及顺序中
            if($type == 2){
                $sql_no='UPDATE '.$action_table_name.' set presence=1 where tabid = ? and related_tabid = "'.$label_arr[0].'"';
                $adb->pquery($sql_no,array($tabid));
            }else{
                $sql_no='UPDATE '.$action_table_name.' set presence=1 where tabid = ?  and name=?   and '.$action_table_columnname.' = "'.$label_arr[0].'"';

                $adb->pquery($sql_no,array($tabid,$name));
            }

        }
    }

    if(isset($_REQUEST['backaction']) && $_REQUEST['backaction'] == 'ModuleSettings')
    {
        //echo $_REQUEST['backaction'];
        header("Location:index.php?module=Settings&action=".$_REQUEST['backaction']."&parenttab=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
    }

}
//wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）
//页面设置->设置显示字段->保存新设置的显示字段
function SetDisplayFieldsSave(){
    global $adb;

    $tabid = vtlib_purify($_REQUEST['tabid']);

    $display_field=$_REQUEST['AssmablyColumnsString'];
    $display_field_selected=$_REQUEST['selectedAssmablyColumnsString'];

    $display_field = trim($display_field,';');
    $display_field_selected=trim($display_field_selected,';');
    $display_field_arr = explode(';',$display_field) ;
    $display_field_selected_arr = explode(';',$display_field_selected) ;

    foreach($display_field_selected_arr as $seq => $val)
    {
        if($val != ''){
            $sql="update ld_field set keyword_sseq = ?,keywords='yes' where fieldid=?";
            $adb->pquery($sql,array($seq+1,$val));
        }
    }

    foreach($display_field_arr as $k => $val)
    {
        if($val != ''){
            $sql="update ld_field set keyword_sseq = null ,keywords= null where fieldid=?";
            $adb->pquery($sql,array($val));
        }
    }

    unsetCacheDirectory('customview');
    unsetCacheDirectory('Cache');
    clearCacheFiles();//删除数据缓存
    unsetCacheDirectory('fields');
    @unlink('include/language/zh.php');
    @unlink('include/language/en.php');
}

//是否开启关键信息区块
function ViewDisplayFields(){
    global $adb;
    $fld_module= $_REQUEST['modulename'];

    $sql_keywords="SELECT visible from ld_blocks where tabid=? and blocklabel='LBL_KEYWORDS'";
    $keywords_result=$adb->pquery($sql_keywords,array(getTabid($fld_module)));
    $keywords_nums=$adb->num_rows($keywords_result);

    if($keywords_nums==0){
        $max_blockid=$adb->getUniqueID('ld_blocks');//从ld_blocks_seq表里获取
        $sql="INSERT INTO ld_blocks (tabid, blockid, sequence, blocklabel,visible) values (?,?,?,?,?)";
        $params = array(getTabid($fld_module),$max_blockid,null,'LBL_KEYWORDS',1);
        $adb->pquery($sql,$params);
    }
    elseif($keywords_nums>0){
        $view_keywords=$adb->query_result($keywords_result,0,'visible');
        if($view_keywords==0){
            $sql="UPDATE ld_blocks SET visible=1 WHERE blocklabel='LBL_KEYWORDS' and tabid=?";
            $result=$adb->pquery($sql,array(getTabid($fld_module)));
        }elseif($view_keywords==1){
            $sql="UPDATE ld_blocks SET visible=0 WHERE blocklabel='LBL_KEYWORDS' and tabid=?";
            $result=$adb->pquery($sql,array(getTabid($fld_module)));
        }
    }
}

//获取左边操作列-供选
function GetRelatedList_action($tabid)
{
    global $adb;

    $sql='SELECT * FROM ld_quickactions where tabid =? and presence=1 ORDER BY sequence';
    $result=$adb->pquery($sql,array($tabid));
    $nums=$adb->num_rows($result);
    $related_action=array();
    $arr_special=array('-1','-2','-3','-4','-5','-6','-7','-8','-9','-10','-11');
    for($i=0;$i<$nums;$i++)
    {
        if(!in_array($adb->query_result($result,$i,'related_tabid'),$arr_special)){
            if(vtlib_isModuleActive(getTabname($adb->query_result($result,$i,'related_tabid'))))
            {
                $related_action[$adb->query_result($result,$i,'related_tabid')]=getTranstab(getTabname($adb->query_result($result,$i,'related_tabid')));
            }
        }
        else
        {
            if($adb->query_result($result,$i,'related_tabid')=='-5')//打印工具
            {
                $query='select printtabid from ld_tab where tabid=? and printtabid=1';
                $printresult=$adb->pquery($query,array($tabid));
                if($adb->num_rows($printresult)<=0)
                    continue;
            }
            $related_action[$adb->query_result($result,$i,'related_tabid')]=GetSpecialActionTranlation($adb->query_result($result,$i,'related_tabid'),$tabid);
        }
    }

    return $related_action;
}
//获取特殊操作的翻译
function GetSpecialActionTranlation($id,$tabid='')
{
    global $adb;

    switch($id){
        case '-1':
            $fieldlabel="View History";//修改历史
            break;
        case '-2':
            $fieldlabel="THELOWCONTACT";//下级联系人
            break;
        case '-3':
            $fieldlabel="THELOWLEVELCONTRACTS";//上下级联系人
            break;
        case '-4':
            $fieldlabel="LBL_SHOW_ACCOUNT_HIERARCHY";//查看上下级客户
            break;
        case '-5':
            $fieldlabel="PRINTTOOL";//打印工具
            break;
        case '-6':
            $fieldlabel="DOWNLOADFILE";//下载附件
            break;
        case '-7':
            $fieldlabel="CHECKATTACHMENTINTEGRITY";//检查附件完整性
            break;
        case '-8':
            $fieldlabel="SENTEMAILATTACHMENTS";//把附件作为电子邮件附件发送
            break;
        case '-9':
            $fieldlabel="Send_SMS";//把附件作为电子邮件附件发送
            break;
        case '-10':
            $fieldlabel="Change_assigned_user";//负责人变更
            break;
        case '-11':
            $fieldlabel='VIEWADDJOBBILLHISTORY';//考勤统计
            break;
    }
    if($id=='-10'){
        global $current_user,$adb;
        include('user_privileges/user_language_'.$current_user->id.'.php');
        $getlanguage = "SELECT ld_tranlabel.fieldlabel as languageheader FROM ld_field 
            LEFT JOIN ld_tranlabel ON ld_tranlabel.tabid=ld_field.tabid AND ld_field.fieldid=Relateid
            where  columnname='smownerid' AND ld_field.tabid=? AND ld_tranlabel.tabid=? AND ld_tranlabel.trantable = ?
            AND languagetype=?;";
        if($tabid==9) $tabid=16;
        $headerresult = $adb->pquery($getlanguage,array($tabid,$tabid,'ld_field',$languageType));
        $languageheader=$adb->query_result($headerresult,0,'languageheader');
        return $languageheader.getFixedLabel('ChangeView');
    }else{
        return getFixedLabel($fieldlabel);
    }

}
//获取右边操作列-现用
function GetRelatedList_action_userd($tabid)
{
    global $adb;
    $sql='SELECT * FROM ld_quickactions where tabid =? and presence=0 ORDER BY sequence';
    $result=$adb->pquery($sql,array($tabid));
    $nums=$adb->num_rows($result);
    $related_action=array();
    $arr_special=array('-1','-2','-3','-4','-5','-6','-7','-8','-9','-10','-11');
    for($i=0;$i<$nums;$i++)
    {
        if(!in_array($adb->query_result($result,$i,'related_tabid'),$arr_special)){
            if(vtlib_isModuleActive(getTabname($adb->query_result($result,$i,'related_tabid'))))
            {
                $related_action[$adb->query_result($result,$i,'related_tabid')]=getTranstab(getTabname($adb->query_result($result,$i,'related_tabid')));
            }
        }
        else
        {
            if($adb->query_result($result,$i,'related_tabid')=='-5')//打印工具
            {
                $query='select printtabid from ld_tab where tabid=? and printtabid=1';
                $printresult=$adb->pquery($query,array($tabid));
                if($adb->num_rows($printresult)<=0)
                    continue;
            }
            $related_action[$adb->query_result($result,$i,'related_tabid')]=GetSpecialActionTranlation($adb->query_result($result,$i,'related_tabid'),$tabid);
        }
    }
    return $related_action;
}

/**
 * @edit andy
 * @data 20140616
 * @reason 得到区块翻译
 * @others NONE
 */
function gettranslabelblocks ($tabid,$blockid,$lantype='')
{
    global $current_user,$adb;

    $sql="select ld_tranlabel.fieldlabel from ld_blocks 
        inner join ld_tranlabel 
        on ld_blocks.blockid = ld_tranlabel.relateid 
        inner join ld_tab 
        on ld_tab.tabid = ld_blocks.tabid 
        where ld_blocks.blockid = ? and ld_tab.tabid = ? 
        and ld_tranlabel.languagetype = ? and trantable='ld_blocks'
        limit 1";
    if(empty($lantype)){
        include('user_privileges/user_language_'.$current_user->id.'.php');
        $lantype=$languageType;
    }
    //echo $sql.'<br>';
    $params=array($blockid,$tabid,$lantype);
    //print_r($params);
    $result = $adb->pquery($sql,$params);
    $fieldlabel = $adb->query_result($result,0,'fieldlabel');

    if(!empty($fieldlabel))
        return $fieldlabel;
    return '';
}
//获取ld_field表fieldid的最大值  同时更新ld_field_seq
function getMaxFieldid(){
    global $adb;
    $query  = 'select max(fieldid) as fieldid from ld_field limit 1';
    $result = $adb->pquery($query,array());
    $fieldid = $adb->query_result($result,0,0);
    $fieldid=$fieldid+1;
    //字段删除有bug,所以此处获取两者的最大值
    $tmpfieldid=$adb->getUniqueID('ld_field');
    $maxfieldid=max($tmpfieldid,$fieldid);
    if($maxfieldid>$tmpfieldid){
        $adb->pquery('update ld_field_seq set id = ?',array($maxfieldid));
    }
    return $maxfieldid;
}
//duan 2022-2-7 切换进度追踪字段后，同步更新单据中的推进阶段字段值
function update_advancestage_value($module,$fieldname,$method){
    //duan 2022-2-7 解决按指定字段追踪的问题,按日期追踪是否需要修改有待进一步讨论
    if($method == 'field'){
        global $adb;
        $focus = CRMEntity::getInstance($module);
        $tablename = $focus->table_name;
        $table_index = $focus->table_index;
        $customFieldTable = $focus->customFieldTable;
        $fieldinfoobj = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
        $columnname = $fieldinfoobj->getColumnName();
        $field_tablename = $fieldinfoobj->getTableName();
        //duan 20230427 因为可能存在数据量过大的情况,禁用触发器
        $trigger_query = "set @disable_triggers = 'aaa';";
        $adb->pquery($trigger_query,array());
        if($field_tablename == $tablename){
            $query = "update $tablename set advance_stage = $columnname ";
            $adb->pquery($query,array());
        }if($field_tablename == $customFieldTable[0]){
            $query = "update $tablename left join $customFieldTable[0] on $customFieldTable[0].$customFieldTable[1] = $tablename.$table_index set advance_stage = $customFieldTable[0].$columnname ";
            $adb->pquery($query,array());
        }
    }
}

//通过公式计算（字段公式下拉框）
function getFormualFields(){
    global $adb;
    $fld_module = vtlib_purify($_REQUEST['fld_module']);
    $fieldobj = Field::getInstance($fld_module, $adb);
    $modulefields = $fieldobj->getModuleFields();

    $formualFields[] = array('columnname' => 'none', 'fieldlabel' => '');
    foreach ($modulefields as $fieldinfo) {
        $uitype = $fieldinfo->getUIType();
        $bigtype = $fieldinfo->getBigType();
        $columnname = $fieldinfo->getColumnName();
        $fieldlabel = $fieldinfo->getFieldLabel();
        //ls 2022-06-14 displaytype为3的去掉，灿哥要求
        /*if ($fieldinfo->getDisplaytype() == 3) {
            continue;
        }*/
        //duan 20230418 去掉displaytype为2的字段
        if ($fieldinfo->getDisplaytype() == 2) {
            continue;
        }

        //销售机会启用产品分录时，不允许选择amount字段用于计算字段公式
        if($fld_module == 'Potentials' && get_file_address($fld_module,"ProductDetails")){
            if($columnname == 'amount'){
                continue;
            }
        }
        //字段布局中的所有数字num,数量number和货币类型的字段可参与运算
        if (in_array($bigtype, array('number', 'currency')) && $columnname != 'currency_id') {
            $formualFields[] = array('columnname' => $columnname, 'fieldlabel' => $fieldlabel);
        }

    }

    $arr['formula'] = $formualFields;//字段公式下拉框
    return $arr;
}
//新增字段时，添加翻译
function addTranlabel($tabid, $custfld_fieldid, $fldlabel_zh, $fldlabel_en)
{
    global $adb;
    $sql = 'delete from ld_tranlabel where trantable=? and tabid=? and relateid=?';
    $adb->pquery($sql, array('ld_field', $tabid, $custfld_fieldid));
    $sqls = "insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) values(?,?,?,?,?)";
    $qparam = array('zh', 'ld_field', $tabid, $custfld_fieldid, $fldlabel_zh);
    $qparamz = array('en', 'ld_field', $tabid, $custfld_fieldid, $fldlabel_en);
    $adb->pquery($sqls, $qparam);
    $adb->pquery($sqls, $qparamz);
}


//通过Sql查询计算（字段下拉框）
function getFormualFieldsSql(){
    global $adb;
    $fld_module = vtlib_purify($_REQUEST['fld_module']);
    $fieldobj = Field::getInstance($fld_module, $adb);
    $modulefields = $fieldobj->getModuleFields();

    $formualFields[] = array('columnname' => 'none', 'fieldlabel' => '');
    foreach ($modulefields as $fieldinfo) {
//        $uitype = $fieldinfo->getUIType();
//        $bigtype = $fieldinfo->getBigType();
        $columnname = $fieldinfo->getColumnName();
        $fieldlabel = $fieldinfo->getFieldLabel();
        //去掉引用字段
        if ($fieldinfo->isRelatedModuleField() && $fieldinfo->getSaveDataBase()=='no') {
            continue;
        }

        $formualFields[] = array('columnname' => $columnname, 'fieldlabel' => $fieldlabel);

    }

    $arr['formula'] = $formualFields;
    return $arr;
}

//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
function getFileAllowedFromUrl(&$advance_demand ,&$advance_demand_groups ) {
    $keyArr = ['Download','Preview'];
    $advance_demand = [];
    $advance_demand_groups = [];
    foreach ($keyArr as $key) {
        if($_REQUEST[$key.'Allowed'] === 'yes') {
            //dump([$_REQUEST[$key.'Allowed_advance_demand'],$_REQUEST[$key.'Allowed_advance_demand_groups']]);
            $advance_demand[$key] = json_decode($_REQUEST[$key.'Allowed_advance_demand'],true);
            $advance_demand_groups[$key] = json_decode($_REQUEST[$key.'Allowed_advance_demand_groups'],true);
        }
    }
    $advance_demand = json_encode($advance_demand);
    $advance_demand_groups = json_encode($advance_demand_groups);
}

?>