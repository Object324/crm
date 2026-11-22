<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/6 17:36
global $current_user;
global $currentModule;
global $adb;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_excelfieldlabel'] = array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist']=array();
require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
$currentModule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($currentModule);
$module_tablename = $focus->table_name;//单据主表
$module_tablename_scf = $focus->customFieldTable[0];//单据自定义表
$detailtable = $focus->Detail_table;
$detailtablescf = $focus->Detail_table_scf;
$profocus = CRMEntity::getInstance('Products');
$smarty = new lingdangCRM_Smarty();
$arr['modulelabel'] = gettranstab($frommodule);
$arr['dupfieldlabel'] = getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel'] = getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel'] = getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel'] = getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel'] = getFixedLabel('TEMPLATECOMPLETE');//完成
$smarty->assign("ARRLABEL", $arr);

$_REQUEST['diony'] = 'yes';
$tmp['title'] = getFixedLabel("IMPORTENTRY");
$tmp['canceltext'] = getFixedLabel("NEXT");
$tmp['oktext'] = getFixedLabel("ASTEP");
$filename = $_REQUEST['filename'];
$filetype = pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名

if ($filetype == 'xlsx') {
    $inputFileType = 'Excel2007';
} else {
    $inputFileType = 'Excel5';
}
$inputFileName = "storage/" . $filename;
$moduleid = getTabid($currentModule);

//产品名称字段
$sql = 'SELECT DISTINCT
	ld_producttoolfield.uitype AS uitype,
	ld_field.typeofdata,
	ld_producttoolfield.fieldlabel AS fieldlabel,
	ld_producttoolfield.columnname AS columnname,
	ld_producttoolfield.tablename AS tablename
    FROM
    	ld_producttoolfield
    inner join ld_field on ld_producttoolfield.tablename=ld_field.tablename and ld_producttoolfield.columnname=ld_field.columnname
    WHERE
    	(ld_field.tablename =? or ld_field.tablename=?)
    AND ld_producttoolfield.tabid =?
    AND ld_producttoolfield.presence <> 1 and ld_field.uitype not in(69,1109)  and ld_field .tabid=14';
$proresult = $adb->pquery($sql, array('ld_products', 'ld_productcf', $moduleid));
$proresult_nums = $adb->num_rows($proresult);

//产品工具自定义字段
$sql = "select ld_tranlabel.fieldlabel,typeofdata,uitype,columnname,input_type,ld_producttoolfield.tablename
    from ld_producttoolfield
    inner join ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
      where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2)and  ld_producttoolfield.tabid=? and (ld_producttoolfield.tablename=? or
       ld_producttoolfield.tablename=? )  AND ld_producttoolfield.savedatabase = 'yes' ORDER BY sequence ";
$producttoolresult = $adb->pquery($sql, array($languageType, 'ld_producttoolfield', $moduleid, $detailtable, $detailtablescf));
//$_SESSION['producttoolresult']=$producttoolresult;
//主表基本信息
$sql = 'select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,tablename ,fieldonly
      from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
    inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
    inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
    where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
    and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
     and presence in(0,2)   and ld_blocks.visible=0 and ld_field.uitype not in(69,1109)
    order by ld_blocks.sequence, ld_field.sequence ';
$result = $adb->pquery($sql, array($languageType, 'ld_field', $moduleid, $languageType, 'ld_blocks', $moduleid));
// $_SESSION['mainServiceContractsresult']=$result;

$WholeDiscountPercent = getFixedLabel('WHOLEDISCOUNTPERCENT');
$WholeDiscountDirect = getFixedLabel('WHOLEDIRECTPRICE');
$adjustment = getFixedLabel('Adjustment');
$Quantity = getFixedLabel('QUANTITY');
$listpricelabel = getFixedLabel('LISTPRICE');
$discountratelabel = getFixedLabel('DISCOUNTRATE');
$directpricelabel = getFixedLabel('DIRECTPRICE');


$defaultvalueHtml = '';
$importcolumn = array();
$drophtml = array();
$sessionMainfield = array();
$importcolumn[] = array(0, 'none-field', '--无--');
$kk = 0;
/*for ($i = 0; $i < $adb->num_rows($result); $i++) {
    $uitype = $adb->query_result($result, $i, 'uitype');
    $columnname = $adb->query_result($result, $i, 'columnname');
    $fieldLabel = ($adb->query_result($result, $i, 'fieldlabel'));
    $typeofdata = $adb->query_result($result, $i, 'typeofdata');
    $fieldonly = $adb->query_result($result, $i, 'fieldonly');
    $tablename = $adb->query_result($result, $i, 'tablename');
    if ($uitype == '208') {
        $sessionMainfield[$kk]['uitype'] = 1;
        $sessionMainfield[$kk]['columnname'] = 'entitytype';
        $sessionMainfield[$kk]['fieldlabel'] = getFixedLabel('CHOOSEENTITYTYPE');
        $sessionMainfield[$kk]['typeofdata'] = $typeofdata;
        $sessionMainfield[$kk]['fieldonly'] = $fieldonly;
        $sessionMainfield[$kk]['tablename'] = $tablename;
        $importcolumn[] = array($uitype, 'entitytype-field', getFixedLabel('CHOOSEENTITYTYPE'), $typeofdata);
        $kk++;
    }
    $sessionMainfield[$kk]['uitype'] = $uitype;
    $sessionMainfield[$kk]['columnname'] = $columnname;
    $sessionMainfield[$kk]['fieldlabel'] = $fieldLabel;
    $sessionMainfield[$kk]['typeofdata'] = $typeofdata;
    $sessionMainfield[$kk]['fieldonly'] = $fieldonly;
    $sessionMainfield[$kk]['tablename'] = $tablename;

    $typedata = explode('~', $typeofdata);
    if ($typedata[1] == 'M') {
        $fieldLabel .= '*';
    }
    if ($uitype == 15 || $uitype == 33) {
        $profileid = $current_user->profileid;

        crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');

        $picklistdrop = getAssignedPicklistValues($columnname, $profileid, $adb, array(), "");
        $drophtml[$columnname . '-field'] = $picklistdrop;
    }
    $importcolumn[] = array($uitype, $columnname . '-field', $fieldLabel, $typeofdata);
    $kk++;
}

$_SESSION['mainfield_' . $currentModule . '_' . $current_user->id] = $sessionMainfield;*/
unset( $_SESSION['mainfield_' . $currentModule . '_' . $current_user->id] );
$importcolumn[] = array(1, 'discount_percent-' . $currentModule, $WholeDiscountPercent);
$importcolumn[] = array(1, 'discount_amount-' . $currentModule, $WholeDiscountDirect);
$importcolumn[] = array(1, 'adjustment-' . $currentModule, $adjustment);
$importcolumn[] = array(1, 'listprice-inventoryproductrel', $listpricelabel . '*');
$importcolumn[] = array(1, 'discount_percent-inventoryproductrel', $discountratelabel);
$importcolumn[] = array(1, 'discount_amount-inventoryproductrel', $directpricelabel);
$exist_product_column = array();
if ($proresult_nums > 0) {
    $producttoolfield_arr = array();
    for ($i = 0; $i < $proresult_nums; $i++) {
        $product_uitype = $adb->query_result($proresult, $i, 'uitype');
        $product_columnname = $adb->query_result($proresult, $i, 'columnname');
        $product_fieldLabel = $adb->query_result($proresult, $i, 'fieldlabel');
        $product_tablename = $adb->query_result($proresult, $i, 'tablename');
        $product_typeofdata = $adb->query_result($proresult, $i, 'typeofdata');
        if (!in_array($product_columnname, $exist_product_column)) {
            $producttoolfield_arr[$i]['uitype'] = $product_uitype;
            $producttoolfield_arr[$i]['columnname'] = $product_columnname;
            $producttoolfield_arr[$i]['fieldlabel'] = $product_fieldLabel;
            $producttoolfield_arr[$i]['tablename'] = $product_tablename;
            $producttoolfield_arr[$i]['typeofdata'] = $product_typeofdata;
        }
        $exist_product_column[] = $product_columnname;

        if (stripos($product_typeofdata, '~M') !== false) {
            $importcolumn[] = array($product_uitype, $product_columnname . '-products', $product_fieldLabel . '*');//给产品编号加上必录项符号
        } else {
            $importcolumn[] = array($product_uitype, $product_columnname . '-products', $product_fieldLabel);
        }
    }
    //038949: 海格->报价单->产品分录导入问题
    /*if (empty($product_no)) {
        $prodctno_fieldinfo = $profocus->fieldobj->getFieldInfoobjBykey('columnname', 'product_no');

        $producttoolfield_arr[$i]['uitype'] = $prodctno_fieldinfo->getUIType();
        $producttoolfield_arr[$i]['columnname'] = 'product_no';
        $producttoolfield_arr[$i]['fieldlabel'] = $prodctno_fieldinfo->getFieldLabel();
        $producttoolfield_arr[$i]['tablename'] = $prodctno_fieldinfo->getTableName();
        $producttoolfield_arr[$i]['typeofdata'] = $prodctno_fieldinfo->getTypeOfData();
        if (stripos($prodctno_fieldinfo->getTypeOfData(), '~M') !== false) {
            $importcolumn[] = array($prodctno_fieldinfo->getUIType(), 'product_no-products', $prodctno_fieldinfo->getFieldLabel() . '*');
        } else
            $importcolumn[] = array($prodctno_fieldinfo->getUIType(), 'product_no-products', $prodctno_fieldinfo->getFieldLabel());

    }*/
    $_SESSION['productfield_' . $currentModule . '_' . $current_user->id] = $producttoolfield_arr;
}
$producttoolfieldarr = array();
for ($i = 0; $i < $adb->num_rows($producttoolresult); $i++) {
    $uitype = $adb->query_result($producttoolresult, $i, 'uitype');
    $columnname = $adb->query_result($producttoolresult, $i, 'columnname');
    $fieldLabel = $adb->query_result($producttoolresult, $i, 'fieldlabel');
    $typeofdata = $adb->query_result($producttoolresult, $i, 'typeofdata');
    $input_type = $adb->query_result($producttoolresult, $i, 'input_type');
    $tablename = $adb->query_result($producttoolresult, $i, 'tablename');
    $producttoolfieldarr[$i]['uitype'] = $uitype;
    $producttoolfieldarr[$i]['columnname'] = $columnname;
    $producttoolfieldarr[$i]['fieldlabel'] = $fieldLabel;
    $producttoolfieldarr[$i]['input_type'] = $input_type;
    $producttoolfieldarr[$i]['tablename'] = $tablename;
    //eidtor:gyq_20191218 reason:去除源单字段
    if($uitype==200 || $uitype==204){
        continue;
    }elseif ($columnname == 'productname')
        $producttoolfieldarr[$i]['typeofdata'] = 'V~O';
  /*  else if ($input_type == 2) {
        $typedata = explode('~', $typeofdata);
        $producttoolfieldarr[$i]['typeofdata'] = $typedata[0] . '~M';
        
    }*/ else
        $producttoolfieldarr[$i]['typeofdata'] = $typeofdata;
    $typedata = explode('~', $typeofdata);
    if ($typedata[1] == 'M'  || $columnname == 'entitytype') {
        $fieldLabel .= '*';
    }
    $importcolumn[] = array($uitype, $columnname . '-producttoolfield', $fieldLabel, $typeofdata);
}
//海格报价单界面产品分录信息

$VersionInfo = getVersionInfo();
if($frommodule == 'Quotes'&& $VersionInfo['account']=='haige' && isset($_REQUEST['haigedetails'])){
    unset($_SESSION['import_' . $currentModule . '_' . $current_user->id . '_haigenoeditrow']);
    unset($_SESSION['import_' . $currentModule . '_' . $current_user->id . 'haigedetails']);
    $haigeproductdetails  = ldcrm_json_decode($_REQUEST['haigedetails']);

    $haigedetails = array();
    $haigegroupnames_arr = array();
    $productdetails_arr = array();
    foreach($haigeproductdetails as $key=>$detailinfo){
        $productdetails_arr[$haigeproductdetails[$key]['hdnProductId']]=$detailinfo;
    }
    $haigedetails['productdetails'] = $productdetails_arr;
    if(isset($_REQUEST['quoteid'])&&!empty($_REQUEST['quoteid']))
    {
        $sql = 'select ld_products.productgroup_name as productgroup_name,ld_quotesdetail.discount_percent as discount_percent,
                ld_quotesdetail.agent_discount as agent_discount,
                ld_quotes.quote_version as quote_version from ld_quotesdetail 
                LEFT JOIN ld_products on ld_products.productid = ld_quotesdetail.productid
                LEFT JOIN ld_quotes on ld_quotes.quoteid = ld_quotesdetail.id
                 where ld_quotesdetail.id =?';
        $result = $adb->pquery($sql,array($_REQUEST['quoteid']));
        $rows_num = $adb->num_rows($result);
        if($rows_num >=1){
            $quote_version = $adb->query_result($result,0,'quote_version');
            if($quote_version != '1.0')
            {
                for($i = 0 ; $i<$rows_num; $i++)
                {
                    $productgroup_name = $adb->query_result($result,$i,'productgroup_name');
                    $discount_percent = $adb->query_result($result,$i,'discount_percent');
                    $agent_discount = $adb->query_result($result,$i,'agent_discount');
                    if(isset($haigegroupnames_arr[$productgroup_name]))
                    {
                        //更新折扣信息 -- 取折扣最小值
                        if($discount_percent<$haigegroupnames_arr[$productgroup_name]['discount_percent']){
                            $haigegroupnames_arr[$productgroup_name]['discount_percent']=$discount_percent;
                        }
                        if($agent_discount<$haigegroupnames_arr[$productgroup_name]['agent_discount']){
                            $haigegroupnames_arr[$productgroup_name]['agent_discount']=$agent_discount;
                        }
                    }
                    else{
                        $haigegroupnames_arr[$productgroup_name] = array('discount_percent'=>$discount_percent,
                                                                        'agent_discount'=>$agent_discount);
                    }
                    
                }
            }
        }
    }
    $haigedetails['groupnames_arr']=$haigegroupnames_arr;
    $_SESSION['import_' . $currentModule . '_' . $current_user->id . 'haigedetails'] =$haigedetails;
}
$_SESSION['detailfield_' . $currentModule . '_' . $current_user->id] = $producttoolfieldarr;
$selcolumnName = array();
include 'PHPExcel/PHPExcel/IOFactory.php';
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();//
$highestRow = $objWorksheet->getHavaDataRow();//获取行号数组
$highestColumn = $objWorksheet->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
//取第一行标题和第二行数据
for ($col = 0; $col < $highestColumnIndex; $col++) {
    $uitype = 0;
    $columnname = '';
    $objvalue0 = (string)$objWorksheet->getCellByColumnAndRow($col, $highestRow[1])->getValue();
    if ($objvalue0 == "") {
        break;
    }


    $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_excelfieldlabel'][] = $objvalue0;

    $objvalue1 = $objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue();

    foreach ($importcolumn as $ccols) {
        if (in_array($objvalue0, $ccols) || in_array($objvalue0 . '*', $ccols)) {
            $uitype = $ccols[0];
            $columnname = $ccols[1];
            $selcolumnName[$columnname] = '';
            $typeofdata = $ccols[3];
            $typedata = explode('~', $typeofdata);
        }
    }
    if ($uitype == 51 && !strstr($columnname, "-field") && $objvalue1 != '') {
        $objvalue1 = date('Y-m-d', PHPExcel_Shared_Date::ExcelToPHP($objvalue1));
    }

    $objstr[$col] = array($objvalue0, $objvalue1, $uitype, $columnname);
}

//获取合同主表查重字段
$modulefieldblocks = $focus->fieldobj->getBlockVisibleInfos();
foreach ($modulefieldblocks as $blockid => $blockinfo) {
    //删除没有字段的区块
    $blockfield = 'no';
    foreach ($focus->fieldobj->getModuleFields() as $index => $fieldinfo) {
        if ($fieldinfo->getBlockId() == $blockid) {
            $blockfield = 'yes';
            break;
        }
    }
    if ($blockfield == 'yes') {
        $blocks[] = $blockinfo;
    }
}
$smarty->assign("MODULEFIELDBLOCKS", $blocks);
$smarty->assign("JSONMODULEFIELDBLOCKS", json_encode($blocks));
$i = 0;

foreach ($focus->fieldobj->getModuleFields() as $index => $fieldinfo) {
    if ($fieldinfo->getfieldOnly() == 1) {
        $module_dupField[] = $fieldinfo->getColumnName();
    }
    $select[$i]['columnname'] = $fieldinfo->getColumnName();
    $select[$i]['fieldlabel'] = $fieldinfo->getFieldLabel();
    $select[$i]['blockid'] = $fieldinfo->getBlockId();
    $i++;
}

//获取合同产品明细查重字段
$i = 0;
foreach ($profocus->fieldobj->getModuleFields() as $index => $fieldinfo) {
    $productselect[$i]['columnname'] = $fieldinfo->getColumnName();
    $productselect[$i]['fieldlabel'] = $fieldinfo->getFieldLabel();
    $i++;

}


//获取文件缓存中的查重字段
$cache_columnname = explode(',', $moduleImport['select']);
$multi_dupfieldkeys = array_keys($mutli_main_importcheckdupfields);////根据数据库中查重字段排序有可能$select的排序方式和$mutli_importcheckdupfields排序不一样
//获取模块的关键字链接columnanme
//  $entitynames = getEntitynameByModulename($currentModule);

foreach ($select as $key => $selInfo) {
    $select[$key]['columnname'] = $selInfo['columnname'];
    if (sizeof($mutli_main_importcheckdupfields) > 0) {
        if (array_key_exists($selInfo['columnname'], $mutli_main_importcheckdupfields)) {

            $select_label[] = $selInfo['fieldlabel'];
            ////根据数据库中查重字段排序有可能$select的排序方式和$mutli_importcheckdupfields排序不一样
            $checkselect_column[array_search($selInfo['columnname'], $multi_dupfieldkeys)] = array('column' => $selInfo['columnname'], 'condition' => $mutli_main_importcheckdupfields[$selInfo['columnname']]['condition']);

        }
    } else if (!empty($module_dupField)) {
        if (in_array($selInfo['columnname'], $module_dupField)) {
            $checkselect_column[] = array('column' => $selInfo['columnname'], 'condition' => 'or');
            $select_label[] = $selInfo['fieldlabel'];
        }
    } else {
        if ($selInfo['columnname'] == $focus->table_code) {
            $checkselect_column[] = array('column' => $focus->table_code, 'condition' => 'or');
            $select_label[] = $selInfo['fieldlabel'];
        }
    }
}


if (sizeof($checkselect_column) <= 0) {
    $checkselect_column[] = array(0, 'none-field', '--无--');
}

if (!empty($moduleImport['select'])) {
    $hidden_select = $moduleImport['select'];
} else {
    $hidden_select = $focus->table_code;
}

//获取明细文件缓存中的查重字段
$cache_columnname_detail = explode(',', $module_detail_Import['select2']);
//获取模块的关键字链接columnanme
$productdetail_checkselect_column = array();
foreach ($productselect as $key => $selInfo2) {
    if (sizeof($mutli_product_importcheckdupfields) > 0) {

        if (array_key_exists($selInfo2['columnname'], $mutli_product_importcheckdupfields)) {
            $select_label[] = $selInfo2['fieldlabel'];
            $productdetail_checkselect_column[] = array('column' => $selInfo2['columnname'], 'condition' => $mutli_product_importcheckdupfields[$selInfo2['columnname']]['condition']);
        }

    } else if (!empty($module_detail_Import['select2'])) {
        if (in_array($selInfo2['columnname'], $cache_columnname_detail)) {

            $select_label2[] = $selInfo2['fieldlabel'];
            $productdetail_checkselect_column[] = array('column' => $selInfo2['columnname'], 'condition' => 'or');
        }
    } else {
        if ($selInfo2['columnname'] == $profocus->table_code) { //改为为空时，默认产品编号
            $productdetail_checkselect_column[] = array('column' => $profocus->table_code, 'condition' => 'or');
            $select_label2[] = $selInfo2['fieldlabel'];
        }
    }

}

if (!empty($module_detail_Import['select2'])) {
    $hidden_select_detail = $module_detail_Import['select2'];
} else {
    $hidden_select_detail = $profocus->table_code;
}

$is_ProductDetail = 2;


$smarty->assign('FILETYPE', $filetype); //将导入文件后缀传入tpl，方便后面获取
//29987: 单据>列表：选择重复时导入方式，不记住上次的选择，一直显示默认值“跳过”
$smarty->assign('IMPORTCHOOSE', 'Abort');


$smarty->assign('PRODUCTSELECT', $productselect);//产品明细下拉查重字段
$smarty->assign("PRODUCTCHECKEDCOLUMNS", $productdetail_checkselect_column);//选择的产品明细查重字段
$smarty->assign('MODULENAME', $currentModule);
$smarty->assign('IMPORTCOLUMN', $importcolumn);//所有字段数组
$smarty->assign('SELCOLUMN', $selcolumnName);//导入字段数组
$smarty->assign('PRODUCTIMPORTTYPE', $product_import_type);
$smarty->assign('DROPHTML', $drophtml);//下拉框数组
$smarty->assign('IMPORTDATA', $objstr);//Excel标题数组
$smarty->assign('MODULE', $currentModule);
$smarty->assign("STEPINDEX", $_REQUEST['stepindex']);
$tmp['excelcolumncount'] = $highestColumnIndex;
$tmp['content'] = $smarty->fetch("ImportXlsNew/secondImport.tpl");
ConvertTojsonString(1, $tmp, "success");


?>