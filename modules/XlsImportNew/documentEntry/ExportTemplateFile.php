<?php
//editor:gyq_162 reason:导出模板文件   2019/12/6 13:45
ob_get_clean();

global $adb, $current_user, $currentModule;
require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
if(isset($_REQUEST['frommodule'])){
    $currentModule = $_REQUEST['frommodule'];
}

$modulelabel = getTranstab($currentModule);
$moduleid = getTabid($currentModule);
if (file_exists('storage/' . $currentModule . '.xls')) {
    @unlink('storage/' . $currentModule . '.xls');
}
$exportTemplateValue = array('main' => array('subject' => '硬件服务', 'ware_stock_no' => 'RK1', 'wareid' => '总仓', 'quote_no' => 'QUO1', 'accountid' => '上海信息科技有限公司', 'signed_data' => '2016-11-29',
    'smownerid' => '系统管理员', 'contract_no' => 'SERCON1', 'currency_id' => '人民币'), 'Products' => array(array('product_no' => 'PRO1', 'productname' => '电话录音盒（一路)'),
    array('product_no' => 'PRO2', 'productname' => '电话录音盒（二路)')),
    'inventorydetail' => array(array('quantity' => 1, 'servicecontracts_start_date' => '2016-11-28', 'servicecontracts_end_date' => '2018-11-23', 'quantity' > 1,
        'taxprice' => 300, 'listprice' => 300, 'list_amount' => 0, 'tax_amount' => 300, 'tax_total' => 0), array('quantity' => 1, 'servicecontracts_start_date' => '2016-11-28', 'servicecontracts_end_date' => '2018-11-23', 'quantity' > 1,
        'taxprice' => 350, 'listprice' => 350, 'list_amount' => 0, 'tax_amount' => 350, 'tax_total' => 0)
    )

);

$details = array('products', 'inventoryproductrel', 'producttoolfield');//明细字段信息
$headers = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
$forheaders = array('', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
$i = 0;

if (($currentModule == 'Stock' || $currentModule == 'PurchaseOrder')) {//Liver 2016-12-06源单列被选中的情况下，源单类型一同导出
    array_push($text, "entitytype_ld_inventoryproductrel-producttoolfield");
}
/*产品名称字段
$sql = 'select ld_tranlabel.fieldlabel from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid
where languagetype=? and trantable=? and ld_tranlabel.tabid=14 and ( columnname=?)';
$proresult = $adb->pquery($sql, array($languageType, 'ld_field', 'product_no'));
*/
//产品工具自定义字段
//edit:can 41558: (http://171.221.206.240:88/crm/ [^] )管理员菜单>报价申请模块>新建单据界面：产品分录，点击导入单据分录“下载数据模块”导入模块中没有“产品代码”字段
$sql = "SELECT ld_tranlabel.fieldlabel,typeofdata,uitype,columnname,input_type,tablename FROM ld_producttoolfield
      LEFT JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_producttoolfield.producttoolfieldid
      WHERE
	  ld_producttoolfield.tabid = ? AND ld_tranlabel.trantable = ? AND columnname NOT in('adjustment','contractid','total','subtotal') and 
      ld_tranlabel.languagetype=? AND ld_producttoolfield.presence IN (0, 2) AND (ld_producttoolfield.savedatabase = 'yes' or  
      ld_producttoolfield.tablename='ld_products' or  ld_producttoolfield.tablename='ld_productcf' )
      GROUP BY ld_producttoolfield.producttoolfieldid
      ORDER BY ld_producttoolfield.sequence ASC";
$producttoolresult = $adb->pquery($sql, array(getTabid($currentModule), 'ld_producttoolfield', $languageType));

//0027800 合同订单导处模板勾选“产品名称”（导出后产品名称也不是必录项）
for ($i = 0; $i < $adb->num_rows($producttoolresult); $i++) {
    $typeofdata = $adb->query_result($producttoolresult, $i, 'typeofdata');
    $columnname = $adb->query_result($producttoolresult, $i, 'columnname');
    if ('productname' == $columnname) {
        $typedata = explode('~', $typeofdata);
        $productname_typeofdata = $typedata[1];
    }
}
$Salescolumname = array('discount_percent-' . $currentModule, 'discount_amount-' . $currentModule, 'adjustment-' . $currentModule, 'currency_id-' . $currentModule, 'subtotal-' . $currentModule, 'total-' . $currentModule);
//038949: 海格->报价单->产品分录导入问题(市场编码为产品编号字段)
/*$productcolumname = array('product_no-products', 'productid-products');

if ($productname_typeofdata == 'M') {
    $productdetail = array($adb->query_result($proresult, 0, 0) . '*' => 'M');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
} else {
    $productdetail = array($adb->query_result($proresult, 0, 0) => 'DEFAULT');//,   getFixedLabel('QUANTITY').'*'=>'M',getFixedLabel('LISTPRICE').'*'=>'M',getFixedLabel('DISCOUNTRATE')=>'O',getFixedLabel('DIRECTPRICE')=>'O');
}
*/
$exportarr = array();

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$modulelabel = getTranstab($currentModule);
$modulelabel = str_replace(' ', '_', $modulelabel);
$modulelabel = str_replace('/', '_', $modulelabel);
$modulelabel = str_replace('\\', '_', $modulelabel);
$modulelabel = str_replace('?', '_', $modulelabel);
$modulelabel = str_replace('[', '(', $modulelabel);
$modulelabel = str_replace(']', ')', $modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);
$kk = 0;
$dupfield_count = 0;
$addsheet = new PHPExcel_Worksheet($objPHPExcel, '导入示例');
$objPHPExcel->addSheet($addsheet, 1);
$objPHPExcel->setActiveSheetIndex(1);
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE);
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0) . '1', getTranstab($currentModule) . '有一个产品明细的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '7')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_BLUE);
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0) . '7', getTranstab($currentModule) . '有多个产品明细的导入示例');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '14')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0) . '14', '说明：多选框字段，录入格式为：张三 |##| 李四');
$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex(0) . '15')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0) . '15', '*注意：|##|两边都要有空格');
$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setWidth(35);
$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('E')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('F')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('G')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('H')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('I')->setWidth(15);
$objPHPExcel->getActiveSheet()->getColumnDimension('J')->setWidth(15);
$objPHPExcel->getActiveSheet()->SetTitle("导入示例");
//$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'1')->setWidth(100);  
//$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0).'7')->setWidth(100);  
$objPHPExcel->setActiveSheetIndex(0);
$activesheet = $objPHPExcel->getActiveSheet();
$dupfield_count = 0;

$objPHPExcel->setActiveSheetIndex(0);

$j = 0;


foreach ($productdetail as $fieldLabel => $typedata) {
    $columnname_tablename = $productcolumname[$j];
    if ($columnname_tablename == 'productid-products' && !in_array('productid-products', $text)) {
        //26494: 采购订单>导出模版：导出模版时不勾选产品名称，导出的模版还是有产品名称
        $j++;
        continue;
    }
    $export_product_columns = explode('-', $columnname_tablename);

    $columnname = $export_product_columns[0];

    //if(in_array($columnname_tablename,$text))
    // {
    /* if($columnname_tablename=='productid-products')
     {
         $objPHPExcel->setActiveSheetIndex(1);

        // $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
         //$objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
         $exporttemplatecolumn['Products'][]=$columnname;
         $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'2',$fieldLabel);
         $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count).'8',$fieldLabel);
         $dupfield_count++;
     }
    else*/
    if ($typedata == 'M') {
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $objPHPExcel->setActiveSheetIndex(1);
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $exporttemplatecolumn['Products'][] = $columnname;
        $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '2', $fieldLabel);
        $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '8', $fieldLabel);
        $dupfield_count++;
    }
    $objPHPExcel->setActiveSheetIndex(0);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk) . '1', $fieldLabel);
    $kk++;
    //}


    $j++;
}
for ($i = 0; $i < $adb->num_rows($producttoolresult); $i++) {
    $typeofdata = $adb->query_result($producttoolresult, $i, 'typeofdata');
    $columnname = $adb->query_result($producttoolresult, $i, 'columnname');
    $tablename = $adb->query_result($producttoolresult, $i, 'tablename');
    $fieldLabel = $adb->query_result($producttoolresult, $i, 'fieldlabel');
    $input_type = $adb->query_result($producttoolresult, $i, 'input_type');
    $typedata = explode('~', $typeofdata);
    $columnname_tablename = $columnname . '_' . $tablename;
    $uitype = $adb->query_result($producttoolresult, $i, 'uitype');
    //eidtor:gyq_20191218 reason:去除源单字段
    //editor:gyq_20191226 reason:去除ld_producttoolfield源单字段
    //0038956: （51mis.com/kfbcrm）销售发票>产品分录导入：导入数据模板中缺少“源单类型”字段
    if($uitype==200 || $uitype==201 || $uitype==202 || $uitype==204 )
        continue;
    //if(in_array($columnname_tablename.'-producttoolfield',$text))
    //{

    if ($typedata[1] == 'M' || $columnname_tablename == 'entitytype_ld_inventoryproductrel') {
        $fieldLabel .= '*';
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk) . '1')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $objPHPExcel->setActiveSheetIndex(1);
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '2')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $objPHPExcel->getActiveSheet()->getStyle(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '8')->getFont()->getColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
        $exporttemplatecolumn['inventorydetail'][] = $columnname;
        $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '2', $fieldLabel);
        $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '8', $fieldLabel);
        $dupfield_count++;
    }
    $objPHPExcel->setActiveSheetIndex(0);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($kk) . '1', $fieldLabel);
    // $activesheet->getColumnDimension($headers[$kk%26].$forheaders[$kk/26])->setWidth(20);
    if ($typedata[0] == 'D') {
        $objStyle = $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($kk));
        $objStyle->getNumberFormat()
            ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD2);
    }
    $kk++;
    // }


}

$objPHPExcel->setActiveSheetIndex(1);
$dupfield_count = 0;
foreach ($exporttemplatecolumn as $columntype => $columnnames) {
    foreach ($columnnames as $index => $columnname) {
        if ($columntype == 'Products') {

            if ($columnname == 'productid')
                $columnname = 'productname';
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '3', $exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '9', $exportTemplateValue['Products'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '10', $exportTemplateValue['Products'][1][$columnname]);
        } else if ($columntype == 'inventorydetail') {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '3', $exportTemplateValue['inventorydetail'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '9', $exportTemplateValue['inventorydetail'][0][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '10', $exportTemplateValue['inventorydetail'][1][$columnname]);

        } else {
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '3', $exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '9', $exportTemplateValue['main'][$columnname]);
            $objPHPExcel->getActiveSheet()->setCellValue(PHPExcel_Cell::stringFromColumnIndex($dupfield_count) . '10', $exportTemplateValue['main'][$columnname]);

        }
        $dupfield_count++;
    }


}
//exit();
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0) . '1')->setWidth(100);
$objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex(0) . '7')->setWidth(100);

$objPHPExcel->getActiveSheet()->getTabColor()->setARGB(PHPExcel_Style_Color::COLOR_RED);
$objPHPExcel->setActiveSheetIndex(0);
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($adb);

//$modulelabel = getTranstab($currentModule);
//editor:gyq_20191223 reason:文件名增加显示模块
$modulelabel = getTranstab($currentModule).getFixedLabel('DOCUMENTENTRY') . getFixedLabel('exporttemplate');

$modulelabel = str_replace(' ', '_', iconv('UTF-8', 'gbk', $modulelabel));

$objWriter->save('storage/' . $currentModule . '.xls');
//下载文件
$file_name = $currentModule . ".xls";
$file_dir = "storage/";
$file = fopen($file_dir . $file_name, "r");
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: " . filesize($file_dir . $file_name));

//$modulelabel=iconv('UTF-8','gb2312',$modulelabel);
Header("Content-Disposition: attachment; filename=" . $modulelabel . ".xls");
ob_get_clean();
ob_clean();
flush();
echo fread($file, filesize($file_dir . $file_name));
fclose($file);

?>