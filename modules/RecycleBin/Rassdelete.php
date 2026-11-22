<?php

/**
 * @author ANDY
 * @copyright 2014 0103
 * @reason 6517 刘总建议：因为回收站序时簿界面无法单独删除一条或者2条数据，建议把清空回收站按钮功能更改为删除按钮功能
 */
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    require_once('RecycleBinUtils.php');
    require_once('modules/Accounts/Accounts.php');
    
	//获取批量处理数
	$deployarray=getSys_deploy(67);
	$btach_num =  $deployarray['deploy_value'];
	$correct = 0;
	$error = 0;
    $idlist=vtlib_purify($_REQUEST['idlist']);
    $excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
    $selected_module = vtlib_purify($_REQUEST['selectmodule']);
    $idlists = getSelectedRecordIds($_REQUEST,$selected_module,$idlist,$excludedRecords);
    
    $focus = CRMEntity::getInstance($selected_module);
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
	$batchtype = getFixedLabel('DELETE');
	$entityarray = getEntitynameInfo(getTabid($selected_module));
	$tabname = $entityarray['tablename'];
	$tabindex = $entityarray['entityidfield'];
	$tabfieldname = $entityarray['fieldname'];
	foreach($idlists as $key => $id){
		if(!empty($id) && $key < $btach_num){
			$idArr[] = $id;
		}
	}

	$query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.implode(',',$idArr).')';
	$result = $adb->pquery($query);
	$num_rows = $adb->num_rows($result);
	for($i = 0; $i<$num_rows; $i++){
		$crmid = $adb->query_result($result,$i,$tabindex);
		$subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
	}
    //记录要彻底删除的单据信息 xxy 2024-2-23 系统操作日志用
    crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
    cls_OperationLogs::saveDeletedRecordInfo($selected_module,$idArr);
   /**
    * edit:andy
    * date:2013-01-03
    * reason:删除回收站选中单据,暂时先修改ld_crmentity中deleted，不删除，确定需求后再具体实施
    */ 
    /**
    * edit:andrew
    * date:2014-03-31
    * reason:删除回收站选中单据,改成直接删除
    */ 
    //echo "<pre>";
    //var_dump($idlists);exit;
	/**
	 * 用 array_pop 处理后，会删除最后一个元素，导致全部删除数据时，会保留一条不能删除，所以暂时去掉该处理
	 * @reason 0011375 回收站界面：当序列表中右多页单据时，全选所有单据批量删除，结果只能删除一页单据
	 * @author Tujt 2014-09-17
	 */
    //array_pop($idlists);
	/**
	 * 单个删除，数组中有空元素，所以删除报错，
	 * 用array_filter方法删除数组空元素
	 * @reason 0011535 回收站界面：序列表中的单据无法删除
	 * @author Tujt 2014-09-19
	 */
	$idlists = array_filter($idlists);
    $idlists=implode(',',$idlists);

/**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
    $entityname=getEntitynameByModulename($selected_module);
    $talbername = $entityname['tablename'];
    $entityidfield = $entityname['entityidfield'];
    
    $checkdeletesql="select $entityidfield from $talbername where $entityidfield in($idlists) ";
    //echo $checkdeletesql;die();
    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    $array=explode(',',$idlists); 
    $checkcount = count($array);
    if($dnum_rows==0){
		header("Location: index.php?module=RecycleBin&action=RecycleBinAjax&file=index&parenttab=$parenttab&mode=ajax&selected_module=$selected_module");
    }elseif($dnum_rows<$checkcount){
        for ($i = 0; $i < $dnum_rows; $i++) {      
            $roleid[$i] = $adb->query_result($dresult, $i, $entityidfield);
        }
         $idlists = implode(',',$roleid);
    }  
    $newArr = explode(',',$idlists); 
    /**
     * 金融行业合同订单删除生成产品交易历史记录
     * ------------------------begin-----------------------------
     **/
     $trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
     $tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。      
     if(!empty($tradename)&&file_exists('include/trade/'.$tradename.'/'.$tradename."_$selected_module.php"))
     {
        require_once('include/trade/'.$tradename.'/'.$tradename."_$selected_module.php");
        $trade_class_name=$tradename.'_'.$selected_module;   
        if(class_exists($trade_class_name))     
        {
            $trade_focus=new $trade_class_name($focus);  
            if(method_exists($trade_focus,"Delete"))          
                $trade_focus->Delete($newArr,'RecycleBin');//合同订单删除时，生成产品购买交易记录。(金融/基金行业)        
        }   
     }
    /**
     * --------------------end----------------------------------
     **/   
	for($i = 0; $i<count($newArr); $i++){
		if($btach_num <= $i)break;
		$edit_err .= sprintf($batchsuccesslog,'<a href="index.php?module='.$selected_module.'&action=DetailView&record='.$newArr[$i].'"  target="_black" >'.$subject[$newArr[$i]]['subject'].'</a>',$batchtype).'<br>';
		$correct++;
	}
    if($error == 0){
		$error = count($newArr) - $correct;
	}
    if($selected_module == 'Calendar'){
		require_once('./modules/Calendar/Activity.php');
		$delobj = new Activity();
	}else{
		require_once('./modules/'.$selected_module.'/'.$selected_module.'.php');
		$delobj = new $selected_module();
        $delobj->moduleName = $selected_module;
	}
    
    //edit:duan date:2021-9-30 删除单据时删除对应的附件记录和文件
    foreach($idArr as $key => $record){
        $delobj->delete_related_attachment($record);
    }
    
    $ccs = $delobj->tab_name_index;

    foreach($delobj->tab_name as $key=>$arr){
        $sql='delete from '.$arr.' where '.$ccs[$arr].' in ('.implode(',',$idArr).')';
         $result = $adb->query($sql);
    }

    
    
   if($delobj->Detail_table!='')
    {
        $detail_table=$delobj->Detail_table;
        $detail_tablename_scf=$delobj->Detail_table_scf ;
        $Detail_table_index=$delobj->Detail_table_index;//明细表和主表关联的字段
        $Detail_table_id=$delobj->Detail_table_id;
        
        $sql="delete from $detail_tablename_scf where $Detail_table_id in(select $Detail_table_id from  $detail_table where $Detail_table_index in(".implode(',',$idArr) .") ) ";
        
        $result = $adb->query($sql);
        $sql="delete from   $detail_table where $Detail_table_index in(".implode(',',$idArr).")" ;
        $result = $adb->query($sql);
    }
    if($selected_module=='DividendOrder')
    {
           //Liver 删除派息单明细,因为派息单没有进回收站，所以这里根据参数批量删除的条数控制，在这里就不改了
            $sql="delete from ld_dividendorderdetail where dividendorderid in($idlists)";
            $adb->pquery($sql,array());
    }

    if(get_file_address($selected_module,"ProductDetails"))
    {
        $select_focus=CRMEntity::getInstance($selected_module);

        $sql="delete from $select_focus->Detail_table where id in($idlists)";
        $adb->pquery($sql,array());
    }
	if($selected_module == 'Expense'){
		$query = "select expensedetailid from ld_expensedetail where expenseid in ($idlists)";
		$result = $adb->pquery($query);
		$num_rows = $adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$expensedetailid = $adb->query_result($result,$i,'expensedetailid');
			$sql='delete from ld_expensedetailscf where expensedetailid=?';
			$adb->pquery($sql,array($expensedetailid));
		}
		$sql="delete from ld_expensedetail where expenseid in ($idlists)";
		$adb->pquery($sql);
	}
    //wym 240513 XUQIU1002193 销售线索、客户，即将回收和回收消息提醒内容单据查看详情界面，客户名称增加显示超链接，可点击查看客户单据详情内容（徐东）
    if($selected_module == 'Reminds'){
        $remindsql="delete from ld_reminds where parentid in ($idlists) AND remindstype in ('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND')";
        $adb->pquery($remindsql);
    }
    // 设备模块，彻底删除时，删除二维码条形码图片
    if($selected_module == 'Equipment'){
        foreach ($newArr as $index => $tmpid) {
            $filepath = globalStatic::$root_directory.'storage/'.strtolower($selected_module).'/'.$tmpid;
            if (is_dir($filepath)){
                $del_files = glob($filepath . '/*');
                foreach ($del_files as $file) {
                    if (!is_dir($file)) {
                        @unlink($file);
                    }
                }
                @rmdir($filepath);
            }
        }
    }
    // 系统操作日志
    $logcontent["deletetype"] = "rassdelete";
    cls_OperationLogs::saveLogs($selected_module,'Delete',$idArr,$logcontent);
    // 删除单据后，删除ld_attachments_history表中对应附件图片历史日志
    if(empty($focus->modstatic)){
        $focus->getModuleStatic('ModTracker');
    }
    $focus->modstatic->deleteAttachmentImgLogs($idArr);

	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,count($newArr),$correct,$error);
	$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
    $edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
	$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
	$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
	$entity['title']['value'] = getFixedLabel('DELETE');// 删除
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($entity);
	echo $jsonentity;die;

    $parenttab = getParentTab();

    header("Location: index.php?module=RecycleBin&action=RecycleBinAjax&file=index&parenttab=$parenttab&mode=ajax&selected_module=$selected_module");
?>
