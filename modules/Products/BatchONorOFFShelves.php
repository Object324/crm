<?php
global $adb,$current_user;
$module = $_REQUEST['frommodule'];
$mode = $_REQUEST['operate'];


$error = 0;
$success = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s失败！原因：该单据已经%s!
if($mode=='Batchon'){
    $batchoparte = getFixedLabel('putonshelf');//上架
}
elseif($mode=='Batchoff'){
    $batchoparte = getFixedLabel('pulloffshelf');//下架
}
//获取模块链接字段
$tabid = getTabid($module);
$entityarray = getEntitynameInfo($tabid);
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$focus=CRMEntity::getInstance($currentModule);
$smcolumnname=$focus->getSmownerColumName();
$field_obj=$focus->fieldobj->getFieldInfoobjBykey('columnname',$smcolumnname);
$assigned=$field_obj->getFieldName();

if($_REQUEST['idstring'] && !empty($_REQUEST['idstring']))
{
    $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
    $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
    $storearray=array_filter($storearray);
    
    foreach($storearray as $key => $id)
    {
		if($btach_num <= $key)break;
		if(empty($id) || $id <=0)continue;
		$query = "select $tabfieldname as subject from $tabname where $tabname.$tabindex = ?";
		$result = $adb->pquery($query,array($id));
		$subject = $adb->query_result($result,0,'subject');
        $statusquery = "select productstatus from ld_shop_productproperty where productid = ?";
        $statusresult = $adb->pquery($statusquery,array($id));
        $statusnum_rows = $adb->num_rows($statusresult);
        $savefocus=CRMEntity::getInstance($module);
        $savefocus->id = $id;
        $savefocus->retrieve_entity_info($id,$module);
        $savefocus->getModuleStatic('ModTracker');
		$savefocus->modstatic->init($savefocus,$module);
        if($statusnum_rows<=0){
            if($mode == 'Batchon'){
                $sql="insert into ld_shop_productproperty (productid,productstatus,putontime) values (?,?,?);";
                $adb->pquery($sql,array($id,PUTON_SHELF,date('Y-m-d H:i:s',time())));
                //单据[%s]%s成功！
                $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$batchoparte).'<br>';
                $success++;
            }
            else{
                $sql="insert into ld_shop_productproperty (productid,productstatus) values (?,?);";
                $adb->pquery($sql,array($id,PULLOFF_SHELF));
                //单据[%s]%s成功！
                $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$batchoparte).'<br>';
                $success++;
            }
        }
        else{
            $oldproductstatus = $adb->query_result($statusresult,0,'productstatus');
            //修改前后商品状态相同，提示修改失败
            if(($oldproductstatus == PUTON_SHELF&&$mode=='Batchon')||($oldproductstatus == PULLOFF_SHELF&&$mode=='Batchoff'))
            {
                //单据[%s]%s失败，原因是已%s。
                $edit_err .=sprintf($batcherrorlog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$batchoparte,$batchoparte).'<br>';
                $error++;
            }
            else
            {
                if($mode == 'Batchon'){
                    $sql="update ld_shop_productproperty set productstatus=?,putontime=? where productid = ?";
                    $adb->pquery($sql,array(PUTON_SHELF,date('Y-m-d H:i:s',time()),$id));
                    //单据[%s]%s成功！
                    $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$batchoparte).'<br>';
                    $success++;
                }
                else{
                    $sql="update ld_shop_productproperty set productstatus=? where productid = ?";
                    $adb->pquery($sql,array(PULLOFF_SHELF,$id));
                    //单据[%s]%s成功！
                    $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Products" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',$batchoparte).'<br>';
                    $success++;
                }
            }
        }
        //添加修改日志
        $savefocus->modstatic->triggerEvent($module);
        
    }
}
$storearray = array_filter($storearray);
$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');//共选择 %d 条记录，成功提交 %d 条，失败 %d 条。

$submitlog = sprintf($submitlog,count($storearray),$success,$error);

$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

$viewid = vtlib_purify($_REQUEST['viewname']);
if(isset($_SESSION['lvs'][$mdoule]['viewname'])){
	$viewid = $_SESSION['lvs'][$mdoule]['viewname'];
	$start = $_SESSION['lvs'][$mdoule][$viewid]['start'];
}
if(!$start) $start = 1;
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
if($mode == 'Batchon'){
    $entity['title']['value'] = getFixedLabel('Batchonshelves');//标题
}
else{
    $entity['title']['value'] = getFixedLabel('Batchoffshelves');//标题
}




$json = new Zend_Json();
$jsonentity = $json->encode($entity);

echo $jsonentity;die;
   



?>