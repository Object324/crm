<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

if(!globalStatic::$root_directory)
{
    exit() ;
}
$module=$_REQUEST['module'];
$focus=CRMEntity::getInstance($module);
$viewid=$_REQUEST['viewid'];
$widths=$_REQUEST['listwidth'];

$widths=array_filter(explode(",",$widths));
$widths=implode(',',$widths);
$widths=explode(",",$widths);
$headernames=$_REQUEST['headername'];
$headermodules=$_REQUEST['headermodule'];
$frommodule=$_REQUEST['frommodule'];

$headernames=array_filter(explode(",",$headernames));
$headernames=implode(',',$headernames);
$headernames=explode(",",$headernames);//fieldname


$headermodules=array_filter(explode(",",$headermodules));
$headermodules=implode(',',$headermodules);
$headermodules=explode(",",$headermodules);
global $adb,$current_user;
//$fieldobj=Field::getInstance($module);

/*
* customview 模块序时簿列表
* related_customview 相关信息序时簿列表
* popup_customview 弹出层序时簿列表
*/
$type = $_REQUEST['type'] ?? '';
//列表拖拽记住宽度
//selectBatchPopup 选择批次列表 比较特殊 单独if判断
//$typeArr 包含以下界面
//customview：模块列表 related_customview：相关信息列表 popup_customview：选择源单/多选弹窗列表  mergduplicate_customview可能是合并列表 chuantou_customview可能是穿透列表
//duplicatePopup:查重列表 selectRelatedPopup：关联单选列表
$typeArr = ['customview','related_customview','popup_customview','mergduplicate_customview','chuantou_customview','duplicatePopup','selectRelatedPopup'];
if(is_array($typeArr) && in_array($type,$typeArr) )//数据分类
{
    
	if(get_file_address($module,'ProductDetails')||$module=='ServiceCharge'){
		crm_load_class_file("ProductDetails",'include/ProductDetails');
		$detailfieldobj=ProductDetails::getInstance($module,$adb);
		$detailfields=$detailfieldobj->getModuleFields();
	}else if(get_file_address($module,'ContactsDetails')){
		$fieldobj=Field::getInstance("Contacts",$adb);
		$detailfields=$fieldobj->getModuleFields();
	}else if(get_file_address($module,'VendorsDetails')){
		$fieldobj=Field::getInstance("VendorContact",$adb);
		$detailfields=$fieldobj->getModuleFields();
	}else if(get_file_address($module,$module.'DetailFieldsHtml')){
		crm_load_class_file("TabDetails",'include/TabDetailFields');
		$TabDetails=new TabDetails($module);
		$detailfields=$TabDetails->getModuleFields();
	}
	//选择源单：源单列特殊控制
	if($type == 'popup_customview'){
		require_once($root_directory."include/Popup/PopUpListView.php");
		$popuplistview=new PopUpListView();
		$popuplistview->getpopupquery($module,$current_user,$viewid);
		if(get_file_address($module,$module.'DetailFieldsHtml')){
			$detailfields=$popuplistview->queryGenerator->TabDetails->getModuleFields();
		}else  if(get_file_address($module,'ProductDetails')){
			$detailfields=$popuplistview->queryGenerator->productDetails->getModuleFields();
		}
	}
	$main_fieldobj=Field::getInstance($module,$adb);
	$cur_module=$module;
	if($module=='ServiceCharge')
	{
		$cur_module='Accounts';
	}
	for($i=0;$i<sizeof($headernames);$i++){
		$header_module=$headermodules[$i];
		$fieldname=$headernames[$i];
		if($header_module!=$cur_module&&$header_module!='ServiceCharge')
		{
			$detailfieldinfo = $detailfields[$fieldname];
			$tablename=$detailfieldinfo->getTableName();
			$columnname=$detailfieldinfo->getColumnName();
		}else{
			if($fieldname=='chkbox'){
				//带checkbox列表
				$tablename=$focus->table_name;
				$columnname='chkbox';
			}
            else if($type == 'related_customview'&&$fieldname=='campaignaccountrelstatus'&&$module=='Accounts')
            {
                //todo:先这样特殊判断吧，等将来业务扩展较大时才修改
                $tablename='ld_campaignaccountrel';
                $columnname='campaignaccountrelstatus';
                $header_module=$module;
            }
            else{
				$fieldInfo=$main_fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
				$tablename=$fieldInfo->getTableName();
				$columnname=$fieldInfo->getColumnName();
            }
		}
		$columninfos[]=$tablename.":".$columnname.":".$fieldname.":".$header_module;
	}
	$SQL='delete from ld_list_headerwidth where module=? and type=?  and userid=? and relateid=?';
	$adb->pquery($SQL,array($module,$type,$current_user->id,$viewid));
	$i=0;
     
	foreach($widths as $td_width){
		if($td_width>=0){
			$SQL='insert into ld_list_headerwidth(module,type,userid,header_width,columns,relateid)value(?,?,?,?,?,?)';
			$adb->pquery($SQL,array($module,$type,$current_user->id,$td_width,$columninfos[$i],$viewid));
		}
		$i++;
	}
}
else if ($type == 'selectBatchPopup'){
    crm_load_class_file('ModelBatch','modules/Products/batch');
    $module_obj = new ModelBatch();
    $listHeader = $module_obj->getListHeader();
    $columninfos = [];
    foreach ($headernames as $key => $headername){
        if ($headername == 'checkbox'){
            $columninfos[] = 'checkbox';
        }else{
            $columninfos[] = $listHeader[$headername];
        }
    }

    $SQL='delete from ld_list_headerwidth where module=? and type=?  and userid=? and relateid=?';
    $adb->pquery($SQL,array($module,$type,$current_user->id,$viewid));
    $i=0;
//    die;

    foreach($widths as $td_width){
        if($td_width>=0){
            $SQL='insert into ld_list_headerwidth(module,type,userid,header_width,columns,relateid)value(?,?,?,?,?,?)';
            $adb->pquery($SQL,array($module,$type,$current_user->id,$td_width,$columninfos[$i],$viewid));
        }
        $i++;
    }

}

?>