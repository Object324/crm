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

global $adb,$currentModule,$languageType,$current_user;
$smarty=new lingdangCRM_Smarty;
$customView = CustomView::getInstance($currentModule);
if($customView->isPermittedCustomView($_REQUEST['record'],"EditView",$currentModule) == 'yes'){
    require_once('modules/Settings/ProductListView.php');//带产品明细的视图
    $smarty->assign("edit_permit",'yes');
}else{
    $smarty->assign("edit_permit",'no');//获取已选择列头
}

// zl 230630 XUQIU1000536 列表按钮优化：显示列弹出层中增加“操作按钮设置”区块及相关功能
$is_set = 'no';
if(is_admin($current_user)){//只有管理员才会显示页面设置
    $is_set = 'yes';
}
//zl XUQIU1000536  获取模块tabid,查询数据库是否有保存的按钮信息
$tabid=getTabid($currentModule);
//if ($tabid == 16) $tabid = 9;
$result=$adb->pquery("select buttonlabel,btnkey,sequence,shownum from ld_btnset where btn_type = 'listbasicbtn' and tabid=$tabid order by sequence");
$noofrows=$adb->num_rows($result);
$listbtnarr = [];
for($i=0;$i<$noofrows;$i++)
{
    $buttonlabel=$adb->query_result($result,$i,'buttonlabel');
    $btnkey=$adb->query_result($result,$i,'btnkey');
    $listbtnarr[$btnkey]['label']=$buttonlabel;
}
//zl XUQIU1000536 如果数据库没有存值,则创建Logic类通过getListViewButtons()返回按钮数组
$focus = CRMEntity::getInstance($currentModule);
$modulelogic = $focus->getModuleLogic($currentModule);
$modulelogic->setlistbutton= 'yes';      //setlistbutton参数获取公海部分不同标签下的其他按钮
$testbtnarr=$modulelogic->getListViewButtons();
//zl 20230706 XUQIU1000536 取出更多中的按钮,组成模块所有按钮
foreach ($testbtnarr as $key => $arr) {
    if ($key == 'More') {
        $selist = $arr['list'];
        unset($testbtnarr['More']);
    }
    $showarr[][$key]=$arr;
}
$testbtnarr = array_merge($testbtnarr, $selist);
$listbtnarr = array_intersect_key($listbtnarr, $testbtnarr);//从数据库中将不存在的按钮功能去掉

//zl 20230706 XUQIU1000536 $shownum为操作按钮设置区块按钮显示个数:如果设置按数据库,如果没有就根据界面显示的值
$shownum = 2;
$shownum=$adb->query_result($result,0,'shownum');
if($shownum > 4){
    $shownum = 4;
}
if($shownum==''){
    $i=0;
    foreach ($showarr as $index =>$showarr2){
            foreach ($showarr2 as $showkey => $showarr3) {
               // dump($showarr2);数组中的permit为no的未显示,需要去掉
                if($showarr2[$showkey]['permit']=='no'){
                    $i++;
                }
                if ($showkey == 'More') {
                    $shownum = $index - $i;
                }
            }
    }
}
if(empty($shownum)){
    $shownum = 2;
}
//zl 20230706 XUQIU1000536 防止数据库缺少按钮信息时漏查,将缺少的按钮补在获取到的按钮列表后
if( sizeof($testbtnarr) > sizeof($listbtnarr)){
    $losebtn=array_diff_key($testbtnarr,$listbtnarr);
    $listbtnarr =array_merge($listbtnarr, $losebtn);
}
//zl 20230706 XUQIU1000536 如果数据库没有按钮信息,代表未设置过,返回原本的列表按钮
if($noofrows ==0 || $noofrows =='') {
    $listbtnarr= $testbtnarr;
}else{
    //duan 20230807 重新获取右侧按钮的显示label
    foreach ($listbtnarr as $tmp_key =>&$tmp_arr){
        if(isset($testbtnarr[$tmp_key]))
            $tmp_arr['label'] = $testbtnarr[$tmp_key]['label'];
        else
            $tmp_arr['label'] = $testbtnarr['More'][$tmp_key]['label'];
    }
}
//zl 20230703 XUQIU1000536 获取操作按钮设置-高级查找是否开启状态,默认开启
$highbtnstatus = getUsersettingByLabel($currentModule, 1, 'Highersearch');
$highbtnstatus=empty($highbtnstatus)?'yes':$highbtnstatus;

$smarty->assign('HIGBTNSTATUS',$highbtnstatus);
$smarty->assign("is_set",$is_set);
$listbtnself_arr = [];
$listbtnrely_arr = [];
$listviewbtntype_arr = $modulelogic->getListViewBtnType();

if(count($listviewbtntype_arr) > 0){
    foreach($listbtnarr as $btnname => $btnlabel){
        if($btnname == 's_mail' && !vtlib_isModuleActive('MassEmails')){
            continue;
        }
        if($btnname == 's_sms' && !vtlib_isModuleActive('MassSMS')){
            continue;
        }

        if($listviewbtntype_arr['rely'][$btnname]){
            $listbtnrely_arr[$btnname] = $btnlabel;
        }
        if($listviewbtntype_arr['self'][$btnname]){
            $listbtnself_arr[$btnname] = $btnlabel;
        }
    }
}
//$smarty->assign("LISTBTNARR",$listbtnarr);
//dump($listbtnself_arr);
$smarty->assign("LISTBTNSELFARR",$listbtnself_arr);
$smarty->assign("LISTBTNRELYARR",$listbtnrely_arr);
$smarty->assign("SHOWNUM",$shownum);

//如果是线索和客户模块则需要获取是否启用公海
if($currentModule == 'Accounts'){
    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
    $cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
    $public_account = $cls_PublicAccounts->getPublicAccountConfig();
    $focus->setaccountstatus($public_account['status']);
}
if($currentModule == 'Leads'){
    crm_load_class_file('cls_PublicLeads', 'modules/Leads');
    $cls_PublicLeadsObj = new cls_PublicLeads($currentModule);
    $public_account = $cls_PublicLeadsObj->getPublicAccountConfig();
    $focus->setaccountstatus($public_account['status']);
}

//获取列表操作按钮
$listviewlink = $modulelogic->getallListViewLink();
//获取列表s数据库操作按钮
$setting_listviewlink = $modulelogic->getsettinglistlinks();

//读取数据库中保存的操作列按钮
$haveactionlink = array();//开启的按钮
$actionlink = array();//未开启的按钮

foreach ($setting_listviewlink as $btnkey=>$btninfo)
{
    $is_active = $btninfo['is_active'];
    $buttonlabel = $btninfo['label'];
    //数据库中的某些操作列按钮需要删去，比如购物车关闭或者跟进记录关闭
    if(array_key_exists($btnkey,$listviewlink)){
        if($is_active == 'yes'){
            $haveactionlink[$btnkey]=$buttonlabel;
        }else{
            $actionlink[$btnkey]=$buttonlabel;
        }
    }
}

//不在数据库中的按钮追加到开启按钮后方
foreach($listviewlink as $btnkey=>$btninfo){
    if(!array_key_exists($btnkey,$setting_listviewlink)){
        $haveactionlink[$btnkey]=$btninfo['label'];
    }
}

// 获取自定义按钮
crm_load_class_file('cls_ButtonsCustomization','modules/Settings');
$buttoncustomizationObj = new cls_ButtonsCustomization($currentModule);
$custom_activebuttons_arr = $buttoncustomizationObj->getActiveButtons();
// 单独处理自定义按钮显示状态
foreach($custom_activebuttons_arr as $index => $btninfo){
    $btnposition_arr = explode(',',$btninfo['btnposition']);
    if(in_array('pc_listlink',$btnposition_arr)){
        $haveactionlink[$btninfo['btnkey']] = $btninfo['label'];
        unset($actionlink[$btninfo['btnkey']]);
    }else{
        $actionlink[$btninfo['btnkey']] = $btninfo['label'];
        unset($haveactionlink[$btninfo['btnkey']]);
    }
}

$smarty->assign("HAVEACTIONLINK",$haveactionlink);
$smarty->assign("ACTIONLINK",$actionlink);

//@edit:ljj,2023-08-11,reason:XUQIU1001663 单据序时簿列表界面，“操作按钮设置”区块，高级查找下方增加“平铺查找”开启、关闭参数
$tiledbtnstatus = getUsersettingByLabel($currentModule, 1, 'Tiledsearch');
$tiledbtnstatus=empty($tiledbtnstatus)?'no':$tiledbtnstatus;// ljj 2023-08-21 BUG0071321 初始账套功能模块中，默认显示“高级查找”功能，隐藏“平铺查找”功能
$smarty->assign('TILEDBTNSTATUS',$tiledbtnstatus);
//wym BUG0076164 客户管理--将标签查找也纳入可设置隐藏
$tagbtnstatus = getUsersettingByLabel($currentModule, 1, 'Tagsearch');
$tagbtnstatus=empty($tagbtnstatus)?'no':$tagbtnstatus;
$smarty->assign('TAGBTNSTATUS',$tagbtnstatus);
//wym BUG0076167 客户管理--地图和漏斗加入设置，可设置显示或隐藏
$mapbtnstatus = getUsersettingByLabel($currentModule, 1, 'Mapsearch');
$mapbtnstatus=empty($mapbtnstatus)?'no':$mapbtnstatus;
$smarty->assign('MAPBTNSTATUS',$mapbtnstatus);
$chartbtnstatus = getUsersettingByLabel($currentModule, 1, 'Chartsearch');
$chartbtnstatus=empty($chartbtnstatus)?'yes':$chartbtnstatus;
$smarty->assign('CHARTBTNSTATUS',$chartbtnstatus);

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

//lmq 230614 获取该模块表格行高
$TableLineHightSet=getUsersettingByLabel($currentModule,1,'TableLineHightSet');
$TableLineHightSet=empty($TableLineHightSet)?'comfortable':$TableLineHightSet;

if ($tabid == 16){
    $entity_tabid = 9;
}else{
    $entity_tabid = $tabid;
}
//@edit:ljj,2023-08-09,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块
$sql='select fieldname from ld_entityname where tabid=?';
$result=$adb->pquery($sql,array($entity_tabid));
$entity_fieldname=$adb->query_result($result,0,'fieldname');
$entitylist = array();
$module_fields = $focus->fieldobj->getModuleFields();
// ljj 20231102 BUG0074878 kfbcrm-价格表-模块超链接字段设置-不启用原超链接字段后，超链接字段应自动修改为下拉框中其他字段 
//foreach ($rightlist as $right_key =>$right_value){
//    $key_arr=explode(':',$right_key);
//    $right_key_array[]=$key_arr[0].':'.$key_arr[2];
//}

foreach ($module_fields as $fieldname => $fieldinfo) {
    //@edit:ljj,2023-08-11,reason:BUG0070901 模块超链接字段设置下拉选项中，单据编号字段应该始终显示，不需要判断必填时才显示
    //BUG0071346 kfbcrm-文本区域和整行文本区域字段，勾选必填后也需要可以设置显示为模块超链接字段
    //BUG20240821-21 模块超链接字段设置只做了文本、文本区域、整行文本区域、单据编号字段，需要增加：手机、电话、Email、QQ
    $tmp_uitype = $fieldinfo->getUitype();
    $tmp_bigtype = $fieldinfo->getBigType();
    $tmp_uitype_arr=[11,1101,13,1103];//手机 电话 邮箱 QQ
    $tmp_bigtype_arr=['text','textarea','longtextarea'];//文本、文本区域、整行文本区域
    if ($fieldinfo->getBigType() == 'moduleno' || (( in_array($tmp_bigtype,$tmp_bigtype_arr) || in_array($tmp_uitype,$tmp_uitype_arr) ) && explode('~', $fieldinfo->getTypeOfData())[1] == 'M')) {
        $fieldlabel = $fieldinfo->getFieldLabel();
        $tablename = $fieldinfo->getTableName();
        $tmp_entityinfo = [];
        if (!empty($fieldlabel)) {
            array_push($tmp_entityinfo, $fieldlabel);
            if ($fieldname == $entity_fieldname) {
                array_push($tmp_entityinfo, 'selected');
            }
            $entitylist[$tablename . ':' . $fieldname] = $tmp_entityinfo;
        }
    }
    //zkt 20230828 超链接字段为联系人姓名,编辑保存后没有流
    elseif($fieldname == $entity_fieldname){
        $fieldlabel = $fieldinfo->getFieldLabel();
        $tablename = $fieldinfo->getTableName();
        $tmp_entityinfo = [];
        array_push($tmp_entityinfo, $fieldlabel);
        if ($fieldname == $entity_fieldname) {
            array_push($tmp_entityinfo, 'selected');
        }
        $entitylist[$tablename . ':' . $fieldname] = $tmp_entityinfo;
    }
}
$smarty->assign("entitylist",$entitylist);

$smarty->assign("customview_record",$_REQUEST['record']);
$smarty->assign("languageType",$languageType);
$smarty->assign("moudlename",$currentModule);
//wym BUG0077306 没有统计报表按钮的模块不显示复选框，有销售漏斗的模块就有统计报表，以及以下的模块是看代码总结出来的补充模块
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance_obj =  cls_module_advance::getInstance($currentModule);
$chartsearch_display=$cls_module_advance_obj->is_Enable();
$arr_module = array('ContactRecords','Campaigns','Potentials','Accounts','Calendar','ServiceCharge');
if(in_array($currentModule,$arr_module)){
    $chartsearch_display='yes';
}
$smarty->assign('chartsearch_display',$chartsearch_display);
$str=$smarty->fetch("ListViewRightSetting.tpl");
$arr['content'] = $str;
$arr['listpagecount'] = $list_max_entries_per_page_new;
$arr['listpageheight'] = $TableLineHightSet;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

?>