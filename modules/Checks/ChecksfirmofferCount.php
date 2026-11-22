<?php
/**
 * 更新操作
 * edit:can
 * date:20140103
 * reason:6648: 盘点编辑界面保存：编辑保存判断账面数量和库存数量不一致后，再重新选择产品使得账面数量和库存数量一致后保存无法保存，一直提示部分产品的库存数量已变更
 * */
    global $adb;
    $wareid=$_REQUEST['ware'];//库存数量
    $qtycount=0;
    $paperquantity=$_REQUEST['paperquantity'];//账面数量
    $productid=$_REQUEST['hdnProductId'];//产品id
	$tmpbatchtext = $_REQUEST['tmpbatchtext'];
    $profitloss=$_REQUEST['profitloss'];//盈亏数量
   /* $sql='select  ld_warehouse2products.productqty,ld_products.productname from ld_products 
         left join ld_warehouse2products on ld_products.productid=ld_warehouse2products.productid 
         where warehouseid=? and ld_products.productid=? ';
    $result=$adb->pquery($sql,array($wareid,$productid));
    if($adb->num_rows($result)>0)
    {
        $qtycount=$adb->query_result($result,0,'productqty');
        $productname=$adb->query_result($result,0,'productname');
    }*/
	crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
	$tmpproductqtys= getProductQtySaveOrCheck($productid,$wareid,$tmpbatchtext);
    $productname=$tmpproductqtys[$productid."_name"];
    $tmpproductqtys=$tmpproductqtys[$productid][$wareid];
    foreach($tmpproductqtys as $batchtext=>$tmpproductqty)
    {
        $qtycount+=$tmpproductqty;
        
    }
    $deploydecimal_length=getSys_deploy(49);//数量小数位数
    $lengthdecimaldigits=$deploydecimal_length['deploy_value'];
    $focus=CRMEntity::getInstance('Checks');
    
	$deployarray=getSys_deploy(48);
	//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
	if($deployarray['deploy_value'] == 1&&$_REQUEST['checksid']>0){
	   
        $sql='select paperquantity from '.$focus->Detail_table.' where id=? and productid=? ';
        $param[]=$_REQUEST['checksid'];
        $param[]=$productid;
        if(trim($tmpbatchtext)!='')
        {
            $sql.=" and batchtext=?";
            $param[]=$tmpbatchtext;
        }

        //不考虑同一个单据有多个相同产品
        $result=$adb->pquery($sql,$param);
        $databasepaperquantity=number_format($adb->query_result($result,0,'paperquantity'),$lengthdecimaldigits,".","");
		if((number_format($qtycount,$lengthdecimaldigits,".","")-number_format($profitloss,$lengthdecimaldigits,".","")!=number_format($paperquantity,$lengthdecimaldigits,".",""))
        ||($databasepaperquantity!=number_format($paperquantity,$lengthdecimaldigits,".","")))
		{
		  //因为产品"王灿5的账面数量（库存数量）5, 4,995.0000已变更为600",所以该单据不允许修改，如果要修改库存数量请新建盘点
			 
             $errorinfo='因为产品"'.$productname;
             if(trim($tmpbatchtext)!='')
             {
                $errorinfo.=',批次:'.$tmpbatchtext;
             }
             $errorinfo.='的账面数量（库存数量）'.setNumberFormat($paperquantity,$lengthdecimaldigits).'已变更为'.setNumberFormat($qtycount,$lengthdecimaldigits).'",所以该单据不允许修改。如果要修改库存数量请新建盘点单.';
             
			  /*$errorinfo="盘点单中部分产品的库存数量已变更,其中：\n".
			  $productname .setNumberFormat($paperquantity,$lengthdecimaldigits).'--->'.setNumberFormat($qtycount,$lengthdecimaldigits). "\n请重新选择上述产品,或者执行\"调入当前库存\"，操作后重新盘点";*/
              
              
			  echo '###ERROR###'.$errorinfo;        
			  exit();
		}
	}

 echo '###SUCCESS###';
 exit();
?>