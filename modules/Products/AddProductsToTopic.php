<?php
//ls 2021-10-26 【ID1001109】增加“小程序商城设置”(首页专题设置选择产品弹出层)

require_once('modules/Products/Products.php');
require_once('modules/lingdang/layout_utils.php');

global $list_max_entries_per_page_new,$theme,$current_user,$default_charset,$adb;
$currentModule="Products";
 $product_field_obj=Field::getInstance('Products',$adb);
$arrFieldLabel=$product_field_obj->getFieldLables();

//$deployarray_14=getSys_deploy(14);//相关信息的行数，也可以自己指定
//$list_max_entries_per_page_new = $deployarray_14['deploy_value'];
$currency_id = vtlib_purify($_REQUEST['currency_id']);

if ($currency_id == null){
	$currencyobj=Currency::getInstance($adb);
	$currency_id=$currencyobj->getCurrencyId();
}
$parenttab = getParentTab();



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

$customView = CustomView::getInstance($currentModule);
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
$viewid = $customView->getViewId($currentModule);
if ($viewid != "0") {
    $queryGenerator->initForCustomViewById($viewid);
} else {
    $queryGenerator->initForDefaultCustomView();
}


if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
    if($_REQUEST['searchtype']=='BasicSearch'){
        $SEATCH_INPUT=array('search_text'=>$_REQUEST['search_text']);
        
        $smarty->assign("SEATCH_INPUT",$SEATCH_INPUT);
        
    }
 }
//Retreive the list of Products

$page_list_query=$queryGenerator->getQuery("",1);

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
$page_list_query .= " ORDER BY productid desc";

//  TODO  最后需要加上条件 商品状态为已上架
$page_list_query = "SELECT tmpone.productid FROM ($page_list_query) AS tmpone INNER JOIN ld_shop_productproperty ON ld_shop_productproperty.productid = tmpone.productid WHERE ld_shop_productproperty.productstatus = '上架'";

//echo $page_list_query;exit;
//$list_query=$queryGenerator->getQuery("",2);
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
	ld_products.productname,
	ifnull(ld_products.imagename,'') AS imagename,
	ld_products.productsheet,
	ld_products.unit_price,
	ld_products.costprice,
	ld_products.smownerid 
FROM
	ld_products  inner join ( $page_list_query limit $limit_start_rec, $list_max_entries_per_page_new) as tmptwo 
        on tmptwo.productid=ld_products.productid " ;

//echo $list_query;exit;
$list_result = $adb->query($list_query);
$num_rows = $adb->num_rows($list_result);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'producthomepagetopic', $viewid);

$navigationOutput='<div class="PageDiv0" style="margin-top:0;"><div class="ld-flex-start" style="position: relative;">'.$navigationOutput.'</div>';
//BUG0068709 xxy 2023-7-26 商城设置->首页专题设置，选择产品界面“基本查找”显示样式不对，“高级查找”应该显示为按钮样式
$strsearch='<div class="marR10 ld-flex-start" id="basicSearchNewDiv" style="padding: 10px;">
                    <div id="basicsearchcolumns_real" style="width:100px;">
                        <select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth100" style="border-radius: 4px 0 0 4px;border-right:none;">
                        </select>
                    </div>
                    <div class="ld-listview-basicsearch">
                        <input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="fun_ProductTopic.getInstance().basicsearch_keyup(event)" name="search_text" value="" autocomplete="off" style="border-radius: 0 4px 4px 0;">
                        <b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="fun_ProductTopic.getInstance().clearPopupLayerSearch(this);"></b>
                        <b class="categorysear-search ld-listview-search" id="listview-search" name="listview-search" onclick="fun_ProductTopic.getInstance().basicsearch()"></b>
                    </div>
                </div><ul>
                <li tag="firstnode" id="categoryAdvsear" style="line-height:46px !important;padding-left:0px">
                <input class="saveauto" type="button" href="javascript:void(0);" name="advancesearchpop" value="'.getFixedLabel('CUSTOMIZESEARCH').'" onclick="fun_ProductTopic.getInstance().advancesearchpop(); fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))">
                </li> 
            </ul> ';
//Buttons Add To PriceBook and Cancel
$other_text = '
  <div class="Category" style="padding:0;">
	<table class="" width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td class="C" style="padding-left: 10px;display: inline-flex;">	
		<input name="idlist" type="hidden">
		<input name="viewname" type="hidden">
	';

	//we should not display the Add to PriceBook button if there is no products to associate
	if($num_rows != $num_prod_rows && $num_rows > 0)
	        $other_text .='<input class="saveauto" type="button" value="'.getFixedLabel('CONFIRMED').'" onclick="return addProductsToTopic()" style="float: left;margin: 10px 0;" />';


$other_text .='
			'.$strsearch.'</td>
      <td name="navigationoutput">'.$navigationOutput.'</div></td>
	  </tr>
	</table></div><div class="clear"></div>';

$smarty->assign("PRODUCTLISTHEADER", get_form_header(getFixedLabel('PRICEBOOKSLIST'), $other_text, false ));

//Retreive the List View Table Header

$list_header = '';
$list_header .= '<tr>';
$list_header .='<th><input type="checkbox" name="selectall" onClick=\'toggleSelect(this.checked,"selected_id");\'></th>';
$list_header .= '<th width="20%">'.$arrFieldLabel['productname'].'</th>';
$list_header .= '<th width="20%">'.$arrFieldLabel['imagename'].'</th>';
$list_header .= '<th width="20%">'.$arrFieldLabel['productsheet'].'</th>';//规格/型号
$list_header .= '<th width="20%">'.$arrFieldLabel['unit_price'].'</th>';//产品报价(RMB)
$list_header .= '<th width="20%">'.$arrFieldLabel['procostprice'].'</th>';//单价   即  参考成本价costprice
$list_header .= '</tr>';

$basicisearchcolumns=array('productname','productsheet','unit_price');
$basicsearchheaders=array();
foreach ($basicisearchcolumns as $tmpcolumn) {
    $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $tmpcolumn);
    if ($tmpfieldinfo && $tmpfieldinfo->getFieldName() != '') {
        //ld_account:accountname:accountname:Accounts_fieldlabel:V
        $tmptablename = $tmpfieldinfo->getTableName();
        $fieldname = $tmpfieldinfo->getFieldName();
        $typeofdata = $tmpfieldinfo->getTypeOfData();
        $typeofdatas = explode("~", $typeofdata);
        $basicsearchheaders[] = array("columnname" => $fieldname, 'fieldlabel' => $tmpfieldinfo->getFieldLabel());
    }
}
foreach ($focus->fieldobj->getBlockVisibleInfos() as $blockid => $blockinfo) {

    $arrBlockLabels[$blockid] = $blockinfo['blocklabel'];
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
//$field_name_array=array();
$entity_id_array =array();
for($i=0; $i<$num_rows; $i++)
{
	$entity_id = $adb->query_result($list_result,$i,"crmid");

	$new_prod_array[] = $entity_id;

	$entity_id_array[$entity_id] = $i;
}

crm_load_function_file('getPricesForProducts','include/utils','InventoryUtils');

$prod_price_list = getPricesForProducts($currency_id, $new_prod_array,'Products',1);

$list_body ='';


for($i=0; $i<count($new_prod_array); $i++)
{
    $entity_id = $new_prod_array[$i];
    if ($i%2 ==0) {
        $list_body.='<tr id="'.$entity_id.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
    }
    else{
        $list_body.='<tr id="'.$entity_id.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
    }
    $unit_price = $prod_price_list[$entity_id]['unit_price'];
    $costprice = $prod_price_list[$entity_id]['costprice'];
//    $field_name = $entity_id . "_listprice";
    $unit_price_array[] = $unit_price;
//    $field_name_array[] = $field_name;

    //弹框图片
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",'imagename');

    $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'Products',SHOW_POPUP);
    $showfieldvalueobj->setadbResult($result);
    $showfieldvalueobj->setLine_index($i);
    $showfieldvalueobj->setRecorId($entity_id);
    $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,'','');
    if (empty($showvalue['value'])) {
        $imagename = '';
    }else{
        $imagename = '<img src="'.$showvalue['value'].'" alt="'.$showvalue['value'].'" width="100px">';
    }


    $list_body .= '<td onclick="toggleSelectAll_parent_td(this)"><input type=checkbox NAME="selected_id" id="check_' . $entity_id . '" value= ' . $entity_id . ' billinfo= ' . $entity_id . ' onClick=\'toggleSelectAll(this.name,"selectall",' . $entity_id . ');\'></td>';
    $list_body .= '<td>' . $adb->query_result($list_result, $entity_id_array[$entity_id], "productname") . '</td>';
    $list_body .= '<td>' . $imagename . '</td>';
    $list_body .= '<td>' . $adb->query_result($list_result, $entity_id_array[$entity_id], "productsheet") . '</td>';
    // wym BUG0075857 【商城设置】首页专题设置->选择产品弹出层列表界面，搜索产品名称“产品”后，“灵当本地化部署产品”的“产品报价”字段的小数位数太多了，建议根据“产品报价”的小数位数显示
    $list_body .= '<td>' . number_format($unit_price,2) . '</td>';
    $list_body .= '<td>' . number_format($costprice,2) . '</td>';

    /*$list_body .= '<td>';

    $list_body .= '<input type="text" name="' . $field_name . '" style="visibility:hidden;" id="' . $field_name . '">';
    $list_body .= '</td>';*/
    $list_body .= '</tr>';

}

if (count($new_prod_array) <= 0) {
    $list_body = '<tr align="center">';
    $list_body .= '<td colspan="6" bgcolor="#FFFFFF" style="height:300px;">';
    $list_body .= '<div class="warningTableContent" style="top: calc(50% - 23px);">';
    $list_body .= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
    $list_body .= "<div class='wtc_content'>" . getFixedLabel('NOTFOUNDANYRECORD') . "</div>";
    $list_body .= "<div class='wtc_content'></div>";
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

if ($_REQUEST['popup'] == 'yes') {
    $_REQUEST['diony'] = 'diony';
    $arr['title'] = getTransTab($_REQUEST['selectmodule']);
    $arr['advancefieldnames'] = $shtml;
    $arr['basicsearchheaders'] = $basicsearchheaders;
    $arr['UNIT_PRICE_ARRAY'] = $unit_price_array;
//    $arr['FIELD_NAME_ARRAY']=$field_name_array;
    $arr['datetimestr'] = CommonView::stdFilterDateTimeStr();
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $controller = ListViewController::getInstance($currentModule);
    $arr['advanceFields'] = $controller->getAdvanceFields();
    $str = $smarty->fetch("AddProductsToPriceBook.tpl");
    $arr['content'] = $str;
    ConvertTojsonString(1, $arr, "success");
    exit();
} else if ($_REQUEST['ajax'] == 'yes') {

    $_REQUEST['diony'] = 'diony';
    $arr['navigationoutput'] = $navigationOutput;
    $arr['basicsearchheaders'] = $basicsearchheaders;
    $arr['content'] = $smarty->fetch("AddProductsToPriceBookContent.tpl");
    ConvertTojsonString(1, $arr, "success");
} else {
    $smarty->display("AddProductsToPriceBook.tpl");
}

?>