<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/9 16:01
set_time_limit(0);
global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony'] = 'yes';
$_SESSION['import_' . $currentModule . '_' . $current_user->id . "_data"] = array();
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_startdate'] = date("Y-m-d H:i:s");
$_REQUEST['startrow'] = 0;
//导入数据
$focus = CRMEntity::getInstance($currentModule);
$profocus = CRMEntity::getInstance('Products');

$detailtable = $focus->Detail_table;
$module_tablename = $focus->table_name;
$_REQUEST['product_importdupcheckfields'] = $_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition'] = $_REQUEST['detail_importdupfields_condition'];
$filename = $_REQUEST['filename'];
$filetype = pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名

if ($filetype == 'xlsx') {
    $inputFileType = 'Excel2007';
} else {
    $inputFileType = 'Excel5';
}

$inputFileName = 'storage/' . $filename;
require_once('PHPExcel/PHPExcel/IOFactory.php');
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objReader->setReadDataOnly(true);
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();
$highestRow = $objWorksheet->getHavaDataRow();//获取行号数组
if (sizeof($highestRow) < 2) {
    $error .= '模板文件中没有数据，导入失败！' . '<br>';

    ConvertTojsonString("-1", array(), $error);

}
$mapfields = json_decode($_REQUEST['mapped_fields']);//导入字段
$totalcolumns = sizeof($mapfields);//导入列数
if ($totalcolumns <= 0) {
    ConvertTojsonStringIndex("-1", array(), '导入字段不能为空');

}
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
$result = $_SESSION['mainfield_' . $currentModule . '_' . $current_user->id];//数组

//产品工具自定义字段
$import_module = $_REQUEST['importmodel'];
$producttoolresult = $_SESSION['detailfield_' . $currentModule . '_' . $current_user->id];//数组
$importcolumn = array();
$field_tables[$module_tablename] = array();//主表导入字段

crm_load_class_file('ProductToolFields', 'include/ProductDetails');
$detailfieldobj = ProductToolFields::getInstance($currentModule);

$inventory_tables[$detailtable] = array();//产品明细表导入字段
$producttoolfield_tables[$detailtablescf] = array();//产品明细自定义表导入字段
$nohaveerror = true;
$fieldcolIndex = 0;
$moduleImport['choose'] = $_REQUEST['choose'];
$moduleImport['select'] = $_REQUEST['select1'];
$module_detail_Import['select2'] = $_REQUEST['select2'];

$checkimportfield = implode(',', json_decode($_REQUEST['importdupcheckfields'], true));//查重字段
$is_checkimportfield = explode(',', $checkimportfield);//将选中的查重字段转为数组

$importdupfields_condition = json_decode($_REQUEST['importdupfields_condition'], true);//查重字段条件
$sql = 'delete from  ld_importcheckdupfields where entitytype=? ';
$adb->pquery($sql, array($currentModule));
$sql = 'insert into ld_importcheckdupfields(columns,entitytype,sequence,conditions)value(?,?,?,?)';
$conditionorlabel = getFixedLabel('OR');
$conditionandlabel = getFixedLabel('SEARCHAND');
for ($i = 0; $i < sizeof($is_checkimportfield); $i++) {
    $fieldlabel = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $is_checkimportfield[$i], 'fieldlabel');
    if ($importdupfields_condition[$i] == 'or')
        $conditionlabel = $conditionorlabel;
    else
        $conditionlabel = $conditionandlabel;
    if ($i == sizeof($is_checkimportfield) - 1) {
        $conditionlabel = '';
    }

    $adb->pquery($sql, array($is_checkimportfield[$i], $currentModule, $i, $importdupfields_condition[$i]));
}

$product_checkimportfield = implode(',', json_decode($_REQUEST['product_importdupcheckfields'], true));//查重字段
$product_is_checkimportfield = explode(',', $product_checkimportfield);//将选中的产品明细查重字段转为数组
$product_importdupfields_condition = json_decode($_REQUEST['product_importdupfields_condition'], true);//查重字段条件
for ($i = 0; $i < sizeof($product_is_checkimportfield); $i++) {
    $tmpcolumnname = $product_is_checkimportfield[$i];

    $fieldlabel = $profocus->fieldobj->getFieldInfoBykeyValue("columnname", $tmpcolumnname, 'fieldlabel');

    if (!in_array($tmpcolumnname . '-products', $mapfields)) {
        $error .= '导入文件中缺少查重\'' . $fieldlabel . '\'列<br>';
    }
    if ($product_importdupfields_condition[$i] == 'or')
        $conditionlabel = $conditionorlabel;
    else
        $conditionlabel = $conditionandlabel;
    $product_fieldlabel_dup_tip .= '"' . $fieldlabel . '"' . $conditionlabel;
    $adb->pquery($sql, array('ld_products:' . $product_is_checkimportfield[$i], $currentModule, $i, $product_importdupfields_condition[$i]));
}
for ($i = 0; $i < sizeof($result); $i++) {

    $uitype = $result[$i]['uitype'];
    $columnname = $result[$i]['columnname'];
    $tablename = $result[$i]['tablename'];
    $typeofdata = $result[$i]['typeofdata'];
    $fieldonly = $result[$i]['fieldonly'];//字段值是否唯一，1：唯一
    $fieldLabel = $result[$i]['fieldlabel'];
    $typedata = explode('~', $typeofdata);

    if ($typedata[1] == 'M' && $uitype != 4 && $columnname != 'currency_id') {

        if (!in_array($columnname . '-field', $mapfields)) {

            $error .= '导入文件中缺少\'' . $fieldLabel . '\'列<br>';
            //break;
        }
    }


}


//产品字段
$product_result = $_SESSION['productfield_' . $currentModule . '_' . $current_user->id];//数组

$product_tablename['ld_products'] = array();//产品表导入字段
//$productcf_tables['ld_productcf']=array();//产品自定义表导入字段

for ($i = 0; $i < sizeof($product_result); $i++) {
    $uitype = $product_result[$i]['uitype'];
    $columnname = $product_result[$i]['columnname'];
    $typeofdata = $product_result[$i]['typeofdata'];
    $fieldlabel = $product_result[$i]['fieldlabel'];
    $table_name = $product_result[$i]['tablename'];
    $typedata = explode('~', $typeofdata);

    if (in_array($columnname . '-products', $mapfields)) {
    } else {
        //if ($typedata[1] == 'M') {
            //28113: 创彩账套（192.168.3.5:85/crm,6.6.5SP3）合同订单>导入：当导入文件中没有必填项产品列的时候，结果导入成功了
            //$error .= '导入文件中缺少产品信息工具\'' . $fieldlabel . '\'列<br>';
       // }
    }

}


$productno_index = 0;//产品编号列索引(在产品明细中的索引)


for ($i = 0; $i < sizeof($producttoolresult); $i++) {

    $uitype = $producttoolresult[$i]['uitype'];
    $columnname = $producttoolresult[$i]['columnname'];
    $fieldlabel = $producttoolresult[$i]['fieldlabel'];
    $typeofdata = $producttoolresult[$i]['typeofdata'];
    $input_type = $producttoolresult[$i]['input_type'];
    $table_name = $producttoolresult[$i]['tablename'];


    $typedata = explode('~', $typeofdata);

    if ($typedata[1] == 'M' ) {

        if (!in_array($columnname . '-producttoolfield', $mapfields)) {
            $error .= '导入文件中缺少产品信息工具\'' . $fieldlabel . '\'列<br>';
            // break;
        }

        $fieldlabel .= '*';
    }


}
if (in_array('entitytypeid-producttoolfield', $mapfields) && !in_array('entitytype-producttoolfield', $mapfields)) {
    $error .= '导入文件中缺少产品信息工具\'源单类型\'列<br>';
}
if (!empty($error)) {

    ConvertTojsonString("-1", array(), $error);

}
$highestColumn = $objWorksheet->getHighestColumn();
$totalcolumns = sizeof($mapfields);
$maxrows = $objWorksheet->getHighestRow();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
while (true) {
    //获取excel中数据行数，防止有删除的空行也算入导入行数了
    for ($tmppk = 0; $tmppk < $totalcolumns; $tmppk++) {
        $tmp_str = trim((string)$objWorksheet->getCellByColumnAndRow($tmppk, $maxrows)->getValue());
        if ($tmp_str !== '') {
            break;
        }
    }
    if ($tmp_str != '') {
        break;
    }
    if ($maxrows <= 0) {
        break;
    }
    $maxrows--;


}
$xlsRowData = array();
$tmprow = 0;
$row = 2;

while (true) {

    if ($row > $maxrows)//如果超过xls文件行数则退出循环
    {
        break;
    }
    if (!array_key_exists($row, $highestRow)) {
        $row++;
        continue;
    }

    for ($excel_col_index = 0; $excel_col_index < $highestColumnIndex; $excel_col_index++) {
        $excel_value = $objWorksheet->getCellByColumnAndRow($excel_col_index, $row)->getValue();
        $excel_value = trim((string)$excel_value);

        $xlsRowData[$tmprow][] = $excel_value;
    }

    $row++;
    $tmprow++;
}

$_SESSION['import_' . $currentModule . '_' . $current_user->id . "_data"] = $xlsRowData;

$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_highestColumnIndex'] = $highestColumnIndex;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_maxrows'] = sizeof($xlsRowData);
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_highestrow'] = $highestRow;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_hangshu'] = 0;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'] = 0;  //总记录数
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'] = 0;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successrows'] = 0;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_updaterows'] = 0;
$_SESSION['import_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] = 0;//实际导入的单据数量，按主表计算
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] = 0;//导入成功的明细条数
$_SESSION['import_' . $currentModule . '_' . $current_user->id . '_failuredetailscount'] = 0;//失败导入的明细条数
$_SESSION['import_' . $currentModule . '_' . $current_user->id . "_error"] = '';


include(globalStatic::$root_directory . 'modules/XlsImportNew/documentEntry/ImportProgress.php');//进度条

$tmp['maxrows'] = $maxrows;
$tmp['timedescription'] = $time_description;
$tmp['cur_progress_step'] = $cur_progress_step;
ConvertTojsonString(1, $tmp, 'success');

?>