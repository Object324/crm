<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

global $adb,$current_user;

$module = $_REQUEST['modulename'];
$fieldname = $_REQUEST['fieldname'];
$mode = $_REQUEST['mode'];
$selectsourcetype = $_REQUEST['selectsourcetype'];

$focus = CRMEntity::getInstance($module);
if(get_file_address($module,$module."DetailFieldsHtml")){
	crm_load_class_file('TabDetails','include/TabDetailFields');
	$productDetails=new TabDetails($module);
	if(!empty($selectsourcetype) && ($module == 'CashBill' || $module == 'SendCashBill')){
		$productDetails->setsourceModulesqlwhere($selectsourcetype);
	}
	$productFields = $productDetails->getModuleFields();
	$fieldinfo = $productFields[$fieldname];
    if(empty($fieldinfo))
    {
        //这就是我们的代码
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    }
}else if(get_file_address($module,'ProductDetails') && $module!='ServiceCharge'){
    //ls 2022-05-18 0051700,服务收费管理模块的列头字段产品类别，编辑下拉框显示的是产品管理的产品类别
	crm_load_class_file('ProductDetails','include/ProductDetails');
	$productDetails=ProductDetails::getInstance($module);
    if(!empty($selectsourcetype) && ($module == 'CashBill' || $module == 'SendCashBill')){
        $productDetails->setsourceModulesqlwhere($selectsourcetype);
    }
	$productFields = $productDetails->getModuleFields();
	$fieldinfo = $productFields[$fieldname];
    //8858: （51mis.com/kfbcrm）销售管理>合同订单>新建单据界面：点击“订单状态”下拉框“齿轮”设置按钮，弹出窗左上角“编辑下拉框>”应显示设置字段名称（截图红框所示）
    if(empty($fieldinfo))
    {
        //这就是我们的代码
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    }
}else{
    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
}
if(!empty($fieldinfo)){
	$fieldlabel = $fieldinfo->getFieldLabel();
	$uitype = $fieldinfo->getUIType();
    $bigtype = $fieldinfo->getBigType();
}
if($uitype==33){//多选框
    $comboxtype = getFixedLabel('SELECT_COMBO');
    $deletedesk = getFixedLabel('DELETEMULTIPICKLISTVALUE');
}else{//下拉框
    $comboxtype = getFixedLabel("PickList");
    $deletedesk = getFixedLabel('DELETEPICKLISTVALUE');
}
//Eidtor:gyq_64 Reason:获取编辑下拉框内容 Date:2018/3/7 0007 下午 4:43
$pickarr = array();
$objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());

//旧代码001 见文末
if($_REQUEST['parentdependfieldname']&&$_REQUEST['parentfieldvalue'])
{
    //crm_load_function_file('getPickListDependency','modules/PickList','PickListDepencySetup');
    if($_REQUEST['selectvalues']!='')
    {
        $pickdepencyarr=json_decode($_REQUEST['selectvalues'],true);
    }
    else
    {
        require(globalStatic::$root_directory."modules/PickList/lingdang_DependencyPicklist.php");

        $pickdepencyarr=lingdang_DependencyPicklist::getPicklistDependencyDatasourceByParentFieldvalue($module,$_REQUEST['parentdependfieldname'],$fieldname,$_REQUEST['parentfieldvalue']);
    }
    
   
}
global $global_picklist_colors;
global $global_picklist_winrate;
global $global_picklist_mapmodule;
if(!empty($pickdepencyarr)) {
   $pickarr = $objPickList->getPickListBySourceValue($fieldname,$pickdepencyarr);
}
else {
     $pickarr = $objPickList->getPickListValues($fieldname,$fieldinfo,array(),'id');
}

//zxm  2021-0617 下拉框颜色值设置
if($mode == 'combox'){
    //bishowChangedComboxLayergtype不是picklist 的都隐藏颜色设置
    $style = '';
    if(empty($fieldinfo) || $fieldinfo->getBigType()!='picklist'){
        $style="display:none;";
    }
    $default_value_arr = [];
    //银行账户字段不能设置默认值
    if($uitype==251||$uitype==252 || empty($fieldinfo)){
        $set_default_style = "display:none;";//隐藏按钮
    }else{
        if(!empty($fieldinfo)){
            $default_value = $fieldinfo->getDefaultvalue()??'';
            $default_value_arr =  explode(' |##| ', $default_value);//让默认值字符串变成数组
            
        }
    }
    
    
    
    $headtitle = getFixedLabel("EDITCONTENTPICKLISTVALUE");
    $table .= '<div class="ld-pop-container ld-table-container ld-table-container-lines">';
    $table .= '<div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">';
    $table .= '<table class="" border="0" cellpadding="0" cellspacing="0" width="100%">';
    $table .= '<thead>';
    $table .= '<tr>';
    $table .= '<th>'.getFixedLabel('MAILNAME').'</th>';
    if($fieldname=="sales_stage"){
        $table .= '<th style="width: 20%;">'.getFixedLabel('WinRate').'</th>';
    }
    if($fieldname=="status" && $module=='Leads'){  //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        $table .= '<th style="width: 20%;">'.getFixedLabel('MAPMODULE').'</th>';
    }
    $table .= '<th style="'.$style.'width: 20%;">'.getFixedLabel('DisplayColor').'</th>';
    $table .= '<th style="'.$set_default_style.'width: 20%;">'.getFixedLabel('Set_Default').'</th>';
    $table .= '<th style="width: 20%;">'.getFixedLabel('OPERATING').'</th>';
    $table .= '</tr>';
    $table .= '</thead>';
    $table .= '<tbody>';
    // 增加下拉框字段是否允许编辑的判断
    $picklist_allowedit = $objPickList->checkPicklistAllowedit($fieldname);
    $picklist_allowdelete = $objPickList->checkPicklistDelete($fieldname);
    $picklist_mapmodule=[];
    foreach($pickarr as $key=>$val){
        //edit: xll 2023/03/31 BUG0062888 “客户”模块，编辑标签，保存无效（邱：不知道是不是最上面特殊字符问题）
        $val = htmlentities($val);
        $pick_color = $global_picklist_colors[$key];
        if($pick_color == ''){
            $pick_color = '#3B4859';
        }
        $win_rate = $global_picklist_winrate[$key];
        $mapmodule_str = $global_picklist_mapmodule[$fieldname][$val]??'';
        $mapmodule_arr = explode(':', $mapmodule_str);
        $table .= '<tr class="ld-edit-combobox ld-category-draggable" rowindex="'.$key.'">';
        if($picklist_allowedit=="yes"){ //不允许编辑则不允许修改
            $table .= '<td><input ';
        }else{
            $table .= '<td><input readonly="readonly" ';
        }
        $table .='tag="combox" class="ld-input-inner" color="'.$pick_color.'" oldvalue="'.$val.'" name="'.$key.'" value="'.$val.'" type="text"></td>';
        if($fieldname=="sales_stage") {
            $table .= '<td><input class="ld-input-inner" style="width: 30px;text-align:center;padding:0px 2px;" name="set_winrate" tag="' . $key . '" value="' . $win_rate . '"> %</td>';
        }
        if($fieldname=="status" && $module=='Leads'){  //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段 目前只有客户和商机两模块
            if(in_array('close',$mapmodule_arr)){
                $table.='<td><div>
                        <select MULTIPLE name="set_mapmodule" tag="' . $key . '" class="ld-input-inner select2 select2-offscreen" style="width:100%;display: none">
                            <option value="close" selected >'.getTranstab('CLOSE').'</option>
                        </select>
                    </div></td>';
            }else{
                $table.='<td><div>
                        <select MULTIPLE  name="set_mapmodule" tag="' . $key . '" class="ld-input-inner select2 select2-offscreen" style="width:100%;">';
                $update_modules = ['Accounts','Potentials'];
                foreach ($update_modules as $index => $upmodule) {
                    if(vtlib_isModuleActive($upmodule)){
                        $table .= '<option value="'.$upmodule.'" '.wheatherMapmoduleSelected($mapmodule_arr,$upmodule).'>'.getTranstab($upmodule).'</option>';
                    }
                }
                $table.='</select>
                    </div></td>';
            }
        }
        $table .= '<td style="'.$style.'" align="center">
			<div name="color_div" style="width: 21px;
    height: 21px;
    border-radius: 100%;
    cursor: pointer;
    border: 1px solid #dbdbdb;background: '.$pick_color.';left:0;top:0;" color="'.$pick_color.'" onclick="ComboxPopup.popupobj.chooseColor(this);"></div>
		</td>';
        //$res = in_array('oldvalue',$default_value_arr);
        if(in_array($val,$default_value_arr)){
            $checked_str = 'checked';
        }else{
            $checked_str = '';
        }
        
        $table .= '<td style="'.$set_default_style.'"><input type="checkbox"  onclick="set_picklist_default(this)" name="set_default" id="set_default" tag="'.$key.'" '.$checked_str.' uitype="'.$uitype.'" class="second_switch" ></td>';
        $table .= '<td class="sort_td dragings">';
        $table .= '<div class="displayflex flexcenter">';
        //不允许删除,$picklist_allowdelete为no时不允许删除
        if($picklist_allowdelete != 'no' && !in_array('close',$mapmodule_arr)){//关闭不允许删除
            $table .= '<i class="ld-fonticon ld-fonticon-del" title="'.getFixedLabel('DELETE').'" onclick="ComboxPopup.popupobj.delVal(this);" ></i>';
        }
        //wym 240109 下拉框-设置-操作列 拖动按钮居中
        $table .= '<a class="ld-category-icon ld-category-drag drag-handle" title="'.getFixedLabel('drag').'" style="cursor: move;margin-top: 2px;"></a>';
        $table .= '</div>';
        $table .= '</td>';
        $table .= '</tr>';
    }
    $table .= '</tbody>';
    $table .= '</table>';
    $table .= '</div>';
    $table .= '<div class="padT16">';
    //不允许编辑则不允许新增
    if($picklist_allowedit=="yes"){
        //zkt 20220826 BUG0055603市场活动（名称：111）相关信息->客户列表界面，操作列点击“状态”按钮，点击“设置”图标按钮点不动
        //此处不能直接使用getbigtype，因为部分字段没有fieldinfo信息，如：市场活动》客户列表》状态字段
        //wym BUG0072693 kfbcrm-费用报销单-新增-费用类别下拉框新增没有颜色设置
        $table .= '<a href="javascript:void(0);" uitype="'.$uitype.'" data-bigtype="'.$bigtype.'" onclick="ComboxPopup.popupobj.addCombox(this)">'.getFixedLabel('NEWPICKLIST').'</a>';
        $table .= '<a href="javascript:void(0);" style="margin-left: 20px;'.$style.'" onclick="ComboxPopup.popupobj.recoveryDefaultColor()">'.getFixedLabel('RestoreDefaultColors').'</a>';
    }else{
        $table .= '<a href="javascript:void(0);" style="'.$style.'" onclick="ComboxPopup.popupobj.recoveryDefaultColor()">'.getFixedLabel('RestoreDefaultColors').'</a>';
    }
    $table .= '</div>';
    $table .= '</div>';
}elseif($mode == 'delete'){
    $headtitle = $deletedesk;
    $smarty = new lingdangCRM_Smarty;
    $pickvalue = $_REQUEST['pickvalue'];
    $smarty->assign("PICKVAL",$pickarr);
    $smarty->assign("SELECTVAL",$pickvalue);
   	$table = $smarty->fetch("modules/PickList/DeletePickList.tpl");
}elseif($mode == 'showpicklist'){
    foreach($pickarr as $key=>$val){
		$table[] = array('value'=>$val,'name'=>$key);
	}
}

$_REQUEST['diony']='diony';
$arr['title']=sprintf($headtitle,$fieldlabel);
//设置账户字段下拉框弹出层的标题
if($uitype==251||$uitype==252){
    $headtitle = getFixedLabel("ACCOUNTSSORTING");
    $arr['title']=$headtitle;
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$table;
$arr['picklist_mapmodule']=$picklist_mapmodule;
ConvertTojsonString(1,$arr,"success");

function wheatherMapmoduleSelected($pcikarr,$module){
    if(in_array($module,$pcikarr)){
        return 'selected';
    }else{
        return '';
    }
}
/* 旧代码001 $sql = "select * from ld_$fieldname order by picklist_valueid";
$result = $adb->pquery($sql,array());
$noofrows = $adb->num_rows($result);
if($noofrows>0){
    for($i=0;$i<$noofrows;$i++){
        $content = $adb->query_result($result,$i,$fieldname);
        $id = $adb->query_result($result,$i,0);
        $pickarr[$id] = $content;
    }
}*/

?>

