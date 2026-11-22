<?php


//禁用产品不允许复制提醒
global $adb;
$frommodule = $_REQUEST['from_module'];
$record = $_REQUEST['record'];
$fromfocus = CRMEntity::getInstance($frommodule);
$deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
$whitproductdetail = 'no';
$selectsourceModule= '';
if($frommodule == 'CashBill'||$frommodule =='SendCashBill'){
    $fromfocus->id = $record;
    $selectsourceModule = $fromfocus->getSourceField('entitytype',$record);
    $sourceModuleinfoarr=getSourceModule($frommodule);
    foreach($sourceModuleinfoarr as $tmpindex=>$SourceInfo){
        $tmpSourceModulename = $SourceInfo['entitytype'];
        if($SourceInfo['entitytype'] ==$selectsourceModule){
            if($SourceInfo['withdetail']=='yes'){
                $whitproductdetail = 'yes';
            }
            break;
        }
    }
}

if($deployarray_82['deploy_value']=='0'&&(get_file_address($frommodule,"ProductDetails")||(($frommodule == 'CashBill'||$frommodule =='SendCashBill')&&$whitproductdetail=='yes'))){
    crm_load_class_file('ProductToolFields','include/ProductDetails');
    $detailobj = ProductToolFields::getInstance($frommodule);
    $detailobj->setsourceModulesqlwhere($selectsourceModule);
    $Detail_table = $fromfocus->Detail_table;
    $Detail_table_index  = $fromfocus->Detail_table_index;//明细表和主表关联ID
    $Detail_table_id = $fromfocus->Detail_table_id;//明细表主键
    $sql = "select $Detail_table.productid,ld_products.product_no,$Detail_table.sequence_no from $Detail_table INNER JOIN ld_products ON ld_products.productid = $Detail_table.productid
            WHERE
    	$Detail_table.$Detail_table_index = $record
    	and ld_products.discontinued != 0
    ORDER BY
    	$Detail_table.$Detail_table_id,
    	$Detail_table.sequence_no ASC";
     $result = $adb->pquery($sql,array());
     $rows = $adb->num_rows($result);
     if($rows>0){
        $warningmsg = '';
        for($i=0;$i<$rows;$i++)
        {
            if(empty($warningmsg)){
                $warningmsg = getFixedLabel('DISCONTINUEDPRODUCTSNOTBEBROUGHTIN');
            }
            $tmproductid = $adb->query_result($result,$i,"productid");
            $tmpwraningrow = ($i+1).'、'.getModuleHref('Products', $tmproductid);
            $productnoinfo = $detailobj->getFieldInfoobjBykey('columnname','product_no');
            if(!empty($productnoinfo)){
                $tmpproduct_no = $adb->query_result($result,$i,'product_no');
                if(!empty($tmpproduct_no)){
                    $tmpwraningrow .= '('.$tmpproduct_no.')';
                }
            }
            $tmpwraningrow .= ' '.getFixedLabel('WAREHOUSEDISABLED');
            if (empty($PlatformMC['type_mini'])) {
                //BUG0064620 zxm 20230412 kfbcrm 微信小程序---负责销售机会POT80---产品禁用提示信息中 多了（邱：小程序中将br去掉）
                $warningmsg .= '<br>';
            }
            $warningmsg .= $tmpwraningrow;
        }
        ConvertTojsonString('2', array(), $warningmsg);
     }
     else{
        ConvertTojsonString('1', array(), 'success');
     }
}
ConvertTojsonString('1', array(), 'success');

?>