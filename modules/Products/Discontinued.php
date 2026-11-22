<?php
global $adb,$current_user;
$error = 0;
$success = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s失败！原因：该单据已经%s!
//获取模块链接字段
$entityarray = getEntitynameInfo(getTabid('Products'));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$focus=CRMEntity::getInstance($currentModule);
$smcolumnname=$focus->getSmownerColumName();
$field_obj=$focus->fieldobj->getFieldInfoobjBykey('columnname',$smcolumnname);
$assigned=$field_obj->getFieldName();
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname','discontinued');
$fieldinfo_field=$fieldinfo->getfieldLabel();
if($_REQUEST['idstring'] && !empty($_REQUEST['idstring']))
{
    $_REQUEST['mass_batch_num_all']=$batch_num;
    $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
    $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
    $storearray=array_filter($storearray);
    foreach($storearray as $key => $id)
    {
		if($btach_num <= $key)break;
		if(empty($id) || $id <=0)continue;
		$query = "select $tabfieldname as subject,discontinued from ld_products where ld_products.productid = ?";
		$result = $adb->pquery($query,array($id));
		$subject = $adb->query_result($result,0,'subject');
        $discontinued = $adb->query_result($result,0,'discontinued');
        //zkt 0046611: （81mis.com/kfbcrm）产品管理-产品，当成员没有权限编辑其他成员产品单据时，列表界面选择产品单据后操作禁用，禁用提示窗错误；可以参考批量编辑失败弹窗修改
        if(isPermitted("Products",'EditView',$id)=='no')
        {
            //单据[%s]%s失败！原因：您没有权限%s其他成员的单据!
            $edit_err .=sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESS'),'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$fieldinfo_field,$fieldinfo_field).'<br>';
            $error++;
            continue;
        }
        if($discontinued == 0)
        {
            $sql="update ld_products set discontinued=1,modifiedtime=? where productid=? ";
            $adb->pquery($sql,array(date('Y-m-d H:i:s'),$id));
            //单据[%s]%s成功！
            $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$fieldinfo_field).'<br>';
            $success++;
        }
        elseif($discontinued!=0)
        {
            //单据[%s]%s失败，原因是已禁用。
            $edit_err .=sprintf($batcherrorlog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$fieldinfo_field,$fieldinfo_field).'<br>';
            $error++;
        }
		
    }
}
$storearray = array_filter($storearray);
$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');

$submitlog = sprintf($submitlog,count($storearray),$success,$error);

$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

$viewid = vtlib_purify($_REQUEST['viewname']);
if(isset($_SESSION['lvs']['Products']['viewname'])){
	$viewid = $_SESSION['lvs']['Products']['viewname'];
	$start = $_SESSION['lvs']['Products'][$viewid]['start'];
}
if(!$start) $start = 1;
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$entity['title']['value'] = $fieldinfo_field;//标题



$json = new Zend_Json();
$jsonentity = $json->encode($entity);

echo $jsonentity;die;
   

?>