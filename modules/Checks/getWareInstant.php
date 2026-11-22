<?php
global $adb;
if(!empty($_REQUEST['wareid'])){
		$wareid = $_REQUEST['wareid'];
		$wareProducts = array();//仓库下的所有产品
		$productInfo = array();//产品详细信息
      // $tmpproductqtys= getProductQtySaveOrCheck("",$wareid,"");
        
		//获取仓库下的所有产品
		$deploy_values=getSys_deploy(49);
        $lengthdecimaldigits=$deploy_values['deploy_value'];
        $ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/Checks/ProductDetails",array('Checks'));
        $fields=$ProductDetailsData->moduleProductToolField;;
        $havebatchcolumnname='no';
        
        foreach($fields as $index=>$info)
        {
            if($info['columnname']=='batchtext')
            {
                $havebatchcolumnname='yes';
                break;
            }
        }
		crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
        if(!isset($_REQUEST['totalrows'])||$_REQUEST['totalrows']==0)
         {
            $sqlcount=getProductQtySaveOrCheckSql('',$wareid,'',array(),' group by productid,wareid ');
            $result=$adb->pquery($sqlcount,array());
            $totalrows=$adb->num_rows($result);
         }
         else{
            $totalrows=$_REQUEST['totalrows'];
            
         }
         $startpage=$_REQUEST['startpage'];
         $eachpage=$_REQUEST['eachpage'];
         //zkt 0049507: （https://81mis.com/kfbtest/index.php [^]）库存管理》盘点单，新建“其他仓”的盘点，产品rx580 有2个批次，盘点单分录只显示了1个批次
		$tmpproductqtys= getProductQtySaveOrCheck('',$wareid,'',$startpage,$eachpage,' group by productid,wareid,ifnull(batchtext, "") ');
		foreach($tmpproductqtys as $productid => $pro_arr){
			foreach($pro_arr[$wareid] as $batchtext => $productqty){
				if($havebatchcolumnname=='no' || $batchtext == DEFAULTBATCHTEXT)
                {
                    $batchtext='';
                }
				$wareProducts[$productid][$batchtext] = number_format($productqty,$lengthdecimaldigits,".","");;
			}
		}
		 
		
		if(count($wareProducts) > 0){
			foreach($wareProducts as $productid => $qty){
			     crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
				$productInfo[$productid] = setProductsInfo($_REQUEST['module'],$productid,'',$wareid,1,1);
			}
		}
	   
      foreach($productInfo as $tmpproductid => $info)
      {
        //批次数组，前段有判断
         foreach($wareProducts[$tmpproductid] as $batchtext=>$tmpqantity)
         {
            $info['paperquantity']=number_format($tmpqantity,$lengthdecimaldigits,".","");;;
            $info['batchtext']=$batchtext;
            
            $tmps['list'][$tmpproductid][]=$info;
         }
      }
      $tmps['totalrows']=$totalrows;
      
      $tmps['title']=getFixedLabel('intheinstankinventory');
      
     
		$prod_arr = Zend_Json::encode($tmps);
		//$prod_arr = htmlspecialchars($prod_arr);
		echo $prod_arr;exit();
	}
?>

