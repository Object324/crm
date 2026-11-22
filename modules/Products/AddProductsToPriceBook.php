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

require_once('modules/Products/Products.php');
require_once('modules/lingdang/layout_utils.php');

global $list_max_entries_per_page_new,$theme,$current_user,$default_charset,$adb;
$currentModule="Products";
 $product_field_obj=Field::getInstance('Products',$adb);
$arrFieldLabel=$product_field_obj->getFieldLables();
//$arrFieldLabel=$languagetransslate->getTranslatedFieldLabel();
$pricebook_id = vtlib_purify($_REQUEST['pricebook_id']);
$currency_id = vtlib_purify($_REQUEST['currency_id']);

if ($currency_id == null){
	$currencyobj=Currency::getInstance($adb);
	$currency_id=$currencyobj->getCurrencyId();
}
$parenttab = getParentTab();

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//require_once('modules/lingdang/layout_utils.php');
crm_load_function_file('getFieldVisibilityPermission','include/utils','UserInfoUtil');
if(getFieldVisibilityPermission('Products',$current_user->id,'unit_price') != '0'){
	ConvertTojsonString(-1,array(),getFixedLabel("NOUNITPRICEFIELDPERMISSION"));
}
$viewid="productspricebookrel";
//$pricebookname = getModuleHref('PriceBooks',$pricebook_id);

$smarty= new lingdangCRM_Smarty;
//$smarty->assign("MOD", $mod_strings);
//$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);

$focus = new Products();

if (isset($_REQUEST['order_by']))
	$order_by = $adb->sql_escape_string($_REQUEST['order_by']);

$url_string = ''; // assigning http url string
$sorder = 'ASC';  // Default sort order
if(isset($_REQUEST['sorder']) && $_REQUEST['sorder'] != '')
	$sorder = $adb->sql_escape_string($_REQUEST['sorder']);
crm_load_class_file("ProductPriceBooksCustomView",'modules/PriceBooks');
crm_load_class_file("ProductPriceBooksQuery",'modules/PriceBooks');
$customView = ProductPriceBooksCustomView::getInstance("Products");
$queryGenerator=new ProductPriceBooksQuery("Products", $current_user,$customView);
$queryGenerator->initForCustomViewById($viewid);
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
    if($_REQUEST['searchtype']=='BasicSearch'){
        $SEATCH_INPUT=array('search_text'=>$_REQUEST['search_text']);
        
        $smarty->assign("SEATCH_INPUT",$SEATCH_INPUT);
        
    }
 }
//Retreive the list of Products

//LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_products.productid
$deployarray=getSys_deploy(71);//选择产品是否判断审批
$deployarray_select=getSys_deploy(70);//产品模块审批是否开启
$deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
if($deployarray['deploy_value']==='0'&&$deployarray_select['deploy_value']=='0'){
        $page_list_query .= " and ld_products.approvestatus='".constant('D_A_S_APPROVED')."' ";
        
}
if($deployarray_82['deploy_value']==='0'){
	$page_list_query .= "  and ld_products.discontinued = 0";	//1禁用 0启用
    
}
$page_list_query=$queryGenerator->getQuery("",1);
$page_list_query="select distinct tmp.productid  from ($page_list_query) as tmp left join (select productid from ld_pricebookproductrel INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_pricebookproductrel.productid
		 WHERE ld_crmentity.setype='Products' AND pricebookid=$pricebook_id) as tmpone on tmp.productid=tmpone.productid
         where tmpone.productid is null  ";
  
$list_query=$queryGenerator->getQuery("",2);
$noofrows=$adb->num_rows($adb->pquery($page_list_query));

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
if($_REQUEST['page_popup']=='yes')
{
    $start =1;
}
else
    $start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$list_query= "SELECT
	ld_products.productid AS crmid,
	ld_products.productname,ld_products.product_no,ld_products.productsheet,
    productcode,
	ld_products.usageunit,
	ld_products.unit_price,
	ld_products.costprice,
	ld_products.qtyinstock,
	ld_products.smownerid
    
    
FROM
	ld_products  inner join ( $page_list_query limit $limit_start_rec, $list_max_entries_per_page_new) as tmptwo 
        on tmptwo.productid=ld_products.productid " ;


$list_result = $adb->query($list_query);
$num_rows = $adb->num_rows($list_result);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'productspricebookrel', $viewid);

$navigationOutput='<div class="PageDiv0" style="margin-top:0;"><div class="ld-flex-start">'.$navigationOutput.'</div>';

$list_header = '';
$list_header .= '<tr>';
$list_header .='<th><input type="checkbox" name="selectall" onClick=\'toggleSelect(this.checked,"selected_id");updateAllListPrice()\'></th>';

$basicisearchcolumns=array('productname','product_no','productsheet','productcode','unit_price');
$basicsearchheaders=array();
foreach($basicisearchcolumns as $tmpcolumn)
{
    $tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumn);
    if($tmpfieldinfo&&$tmpfieldinfo->getFieldName()!='')
    {
        //ld_account:accountname:accountname:Accounts_fieldlabel:V
        $tmptablename=$tmpfieldinfo->getTableName();
        $fieldname=$tmpfieldinfo->getFieldName();
        $list_header .= '<th width="16%">'.$arrFieldLabel[$fieldname].'</th>';
        $typeofdata=$tmpfieldinfo->getTypeOfData();
        $typeofdatas=explode("~",$typeofdata);
        $basicsearchheaders[]=array("columnname"=>$fieldname,'fieldlabel'=>$tmpfieldinfo->getFieldLabel());
        $optionhtml .="<option value='".$fieldname."'>".$tmpfieldinfo->getFieldLabel()."</option>";
    }
}
$list_header .= '<th width="20%">'.getFixedLabel('LISTPRICE').'</th>';
$list_header .= '</tr>';
//wym BUG0073276 价格表相关信息选择产品界面，“基本查找”显示效果优化
$strsearch='<ul>
                <li tag="firstnode" id="categorysear">
                <div id="basicSearchNewDiv" class="ld-flex-start">
				<div id="basicsearchcolumns_real" style="width:110px;padding-top: 1px;">
				<select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth100" style="border-radius: 4px 0 0 4px;border-right:none;">
				'.$optionhtml.'
				</select>
				</div>
				<div class="ld-listview-basicsearch">
				<input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="fun_setCrmPopupWindow.searchSubmit()" name="search_text" value="" autocomplete="off" style="border-radius: 0 4px 4px 0;border-top-width: 1px;border-bottom-width: 1px;">
				<b style="position: absolute;right:30px;top:4px;cursor: pointer" class="ld-icon-clearsearch" onclick="fun_setCrmPopupWindow.clearPopupLayerSearch(this);"></b>
				<b class="categorysear-search ld-listview-search" style="top: 4px;" id="listview-search" name="listview-search" onclick="fun_ProductPriceBooks.getInstance().basicsearch();"></b>
				</div>
				</div>
				</li>
                <li tag="firstnode" id="categoryAdvsear"><div>
                <a href="javascript:void(0);" name="advancesearchpop" onclick="fun_ProductPriceBooks.getInstance().advancesearchpop();">
                <b class="icon-categorybtn categoryAdvsear-search"></b></a></div></li> 
            </ul> ';
//Buttons Add To PriceBook and Cancel
$other_text = '
  <div class="Category" style="padding:0;">
	<table class="" width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
			<td class="C" style="padding-left: 10px;display: flex;align-items: center;">
				<input name="pricebook_id" type="hidden" value="'.$pricebook_id.'">
				<input name="idlist" type="hidden">
				<input name="viewname" type="hidden">
	';

	//we should not display the Add to PriceBook button if there is no products to associate
	if($num_rows != $num_prod_rows && $num_rows > 0){
        $btnText = '';
        global $current_user;
        $languageType=getLanguageType($current_user);
        if($languageType=='en'){
            $btnText = getFixedLabel('ADDTO').' '.getTranstab('PriceBooks');
        }
        else{
            $btnText = getFixedLabel('ADDTO').getTranstab('PriceBooks');
        }
        $other_text .='<input class="ld-button ld-button-primary" type="button" value="'.$btnText.'" onclick="return addtopricebook()" style="float: left;margin: 12px 0;" />';
    }

//价格表 相关信息选择产品，因为点击选择按钮，浏览器重新新建了一个窗口，所以点击返回按钮，是无法跳转到前一步的。 经过跟nancy讨论，隐藏此按钮
//$other_text .='&nbsp;<input title="'.getFixedLabel('CANCEL').'" class="cancelauto" onclick="window.history.back()" type="button" name="button" value="'.getFixedLabel('CANCEL').'">';

$other_text .='
			'.$strsearch.'</td>
      <td name="navigationoutput">'.$navigationOutput.'</div></td>
	  </tr>
	</table></div><div class="clear"></div>';

$smarty->assign("PRODUCTLISTHEADER", get_form_header(getFixedLabel('PRICEBOOKSLIST'), $other_text, false ));

//Retreive the List View Table Header


 foreach($focus->fieldobj->getBlockVisibleInfos() as $blockid=>$blockinfo)
 {
            
            $arrBlockLabels[$blockid]=$blockinfo['blocklabel'];
 }
        
        
$moduleFields=$focus->fieldobj->getListSearchFields();

foreach ($moduleFields as $tmpfieldinfo ) {
    $fieldName=$tmpfieldinfo->getFieldName();
    $blockName = $arrBlockLabels[$tmpfieldinfo->getBlockId()];
    $label = $tmpfieldinfo->getFieldLabelKey();
    $typeOfData = $tmpfieldinfo->getTypeOfData();
    $typeOfData = explode("~", $typeOfData);
    $typeOfData = $typeOfData[0];
    $optionvalue = $tmpfieldinfo->getTableName() . ":" . $tmpfieldinfo->getColumnName() . ":" . $fieldName . ":Products_" . $fieldLabelEscaped . ":" . $typeOfData;
    $OPTION_SET[$blockName][$fieldName] = "<option value=\'$optionvalue\' $selected>$label</option>";
}
foreach ($OPTION_SET as $key => $value) {
                $shtml .= "<optgroup label='$key' class='select' style='border:none'>";
                // sort array on field labels
                //	ksort($value, SORT_STRING);//028097: 序时簿列表，查找->高级查找，下拉选择框中字段顺序是乱的
                $shtml .= implode('', $value);
}

$smarty->assign("FIELDNAMES", $shtml);
$smarty->assign("LISTHEADER", $list_header);


//if the product is not associated already then we should display that products
$new_prod_array = array();
$unit_price_array=array();
$field_name_array=array();
$entity_id_array =array();
for($i=0; $i<$num_rows; $i++)
{
	$entity_id = $adb->query_result($list_result,$i,"crmid");
	if(!array_key_exists($entity_id, $new_prod_array))
	{
		$new_prod_array[] = $entity_id;
	}
	$entity_id_array[$entity_id] = $i;
}

crm_load_function_file('getPricesForProducts','include/utils','InventoryUtils');

$prod_price_list = getPricesForProducts($currency_id, $new_prod_array);

$list_body ='';
for($i=0; $i<count($new_prod_array); $i++)
{

	$entity_id = $new_prod_array[$i];

		
		$list_body .= '<tr id="'.$entity_id.'" class="lvtColData" onmouseover="this.className=\'lvtColDataHover\'" onmouseout="this.className=\'lvtColData\'" bgcolor="white">';
		$unit_price = $prod_price_list[$entity_id];
		$field_name = $entity_id."_listprice";
        //wym BUG0073277 价格表相关信息选择产品界面，“产品报价”和“单价”的小数位数太多了
		$unit_price_array[]=number_format($unit_price,2);
		$field_name_array[]=$field_name;

		$list_body .= '<td><INPUT type=checkbox NAME="selected_id" id="check_'.$entity_id.'" value= '.$entity_id.' onClick=\'toggleSelectAll(this.name,"selectall",'.$entity_id.');updateListPriceForField("'.$field_name.'",this)\'></td>';
		$tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'productname');
		if(!empty($tmpfieldinfo)){
			$list_body .= '<td>'.$adb->query_result($list_result,$entity_id_array[$entity_id],"productname").'</td>';
		}
		$tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'product_no');
		if(!empty($tmpfieldinfo)){
			$list_body .= '<td>'.$adb->query_result($list_result,$entity_id_array[$entity_id],"product_no").'</td>';
		}
		$tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'productsheet');
		if(!empty($tmpfieldinfo)){
			$list_body .= '<td>'.$adb->query_result($list_result,$entity_id_array[$entity_id],"productsheet").'</td>';
		}
        $tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'productcode');
        if(!empty($tmpfieldinfo)){
            $list_body .= '<td>'.$adb->query_result($list_result,$entity_id_array[$entity_id],"productcode").'</td>';
        }
		$tmpfieldinfo= $focus->fieldobj->getFieldInfoobjBykey("columnname",'unit_price');
		if(!empty($tmpfieldinfo)){
            //wym BUG0073277 价格表相关信息选择产品界面产品报价显示和列表保持一致
            $showfieldvalueobj = new ShowFieldValue($focus->fieldobj, $currentModule,SHOW_LISTVIEW);
            crm_load_class_file('ListViewfieldValue', 'include/ListView');
            $listviewFieldValue = new ListViewfieldValue($focus, $currentModule, $queryGenerator);
            $value = $listviewFieldValue->getListViewFieldValue($tmpfieldinfo, $showfieldvalueobj, $unit_price, html_entity_decode($unit_price, ENT_QUOTES, $default_charset));
			$list_body .= '<td>'.$value.'</td>';
		}


		$list_body .='<td>';

		$list_body .= '<input class="detailedViewTextBox" onfocus="this.className=\'commonDetailedTextBox bgcolordh\'" onblur="this.className=\'detailedViewTextBox\'" type="text" name="'.$field_name.'" style="visibility:hidden;" id="'.$field_name.'">';
		$list_body .= '</td></tr>';
	
}

if(count($new_prod_array)<=0)
{
    //38759: （51mis.com/kfbcrm）价格表模块明细界面>相关选择产品弹出层>基本查找弹出层：录入系统中不存在的产品名称进行查找，点击查找后界面应该显示“没有找到任何记录”。（高级查找也存在该问题）
    $list_body = '<tr align="center">';
    $list_body .= '<td colspan="7" bgcolor="#efefef" style="height:300px;">';
    $list_body .= '<div class="warningTableContent" style="z-index:600;">';
    $list_body.= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
    $list_body.="<div class='wtc_content'>".getFixedLabel('NOTFOUNDANYRECORD')."</div>";
    $list_body.="<div class='wtc_content'></div>";
    $list_body .= '</div>';
    $list_body .= '</td></tr>';
}

if($order_by !='')
	$url_string .="&order_by=".$order_by;
if($sorder !='')
	$url_string .="&sorder=".$sorder;

$smarty->assign("LISTENTITY", $list_body);
$smarty->assign("CATEGORY", $parenttab);
//相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");

if($_REQUEST['popup'] == 'yes'){
	$_REQUEST['diony']='diony';
	$arr['title']=getTransTab($_REQUEST['selectmodule']);
    $arr['advancefieldnames']=$shtml;
    $arr['basicsearchheaders']=$basicsearchheaders;
    $arr['UNIT_PRICE_ARRAY']=$unit_price_array;
    $arr['FIELD_NAME_ARRAY']=$field_name_array;
    $arr['datetimestr']=CommonView::stdFilterDateTimeStr();
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $controller = ListViewController::getInstance($currentModule);
    $arr['advanceFields'] = $controller->getAdvanceFields();
	$str=$smarty->fetch("AddProductsToPriceBook.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
}
else if($_REQUEST['ajax']=='yes')
{
   
    $_REQUEST['diony']='diony';
    $arr['navigationoutput']=$navigationOutput;
     $arr['basicsearchheaders']=$basicsearchheaders;
     //zkt 20220601 0052133价格表查看详情界面，相关信息->选择产品管理界面，翻到第二页，全选单据时，“单价”字段没有显示编辑框
     $arr['UNIT_PRICE_ARRAY']=$unit_price_array;
    $arr['FIELD_NAME_ARRAY']=$field_name_array;
    $arr['content']=$smarty->fetch("AddProductsToPriceBookContent.tpl");
    	ConvertTojsonString(1,$arr,"success");
}
else{
	$smarty->display("AddProductsToPriceBook.tpl");
}

?>