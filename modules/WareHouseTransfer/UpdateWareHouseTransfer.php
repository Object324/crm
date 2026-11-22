<?php
require_once ('include/Stock/CommonStock.php');
global $adb,$current_user,$currentModule;
$is_admin=is_admin($current_user);
if(isset($_REQUEST['submittransfer']) || $_REQUEST['type'] == 'approvecheck')
{
    if(isset($_REQUEST['record']))
    {
        //单据ID
        $recordid = $_REQUEST['record'];
        //调入仓库ID
        $inwarehouse = $_REQUEST['inwarehouse'];
        //调出仓库ID
        $outwarehouse = $_REQUEST['outwarehouse'];
        if (empty($inwarehouse) || empty($outwarehouse)) {
            //ls 20221201 XUQIU1000685  增加审批功能(调拨单审批成功前置条件检查)
            $focus = CRMEntity::getInstance('WareHouseTransfer');
            $focus->retrieve_entity_info($recordid,"WareHouseTransfer");
            $inwarehouse = $focus->column_fields['inwarehouse'];
            $outwarehouse = $focus->column_fields['outwarehouse'];
        }
        if($inwarehouse == $outwarehouse)
        {
            //调入和调出仓库不能一致
            echo '###error###1';
            exit;
        }
        if($is_admin == false && getUserWarehouseStatus($inwarehouse) == false && getUserWarehouseStatus($outwarehouse) ==false)
        {
            echo '###error###2';
            exit;
        }
        //group by productid 累计相同产品的数量
         $system_deploy_arr= getSys_deploy(48);
         if($_REQUEST['submittransfer'] == 'Confirm'&&$system_deploy_arr['deploy_value']==0)
            {  
             require_once(globalStatic::$root_directory.'include/Stock/CommonStock.php');
             $tmps= getMinZero_Batchtext_whenApprove('WareHouseTransfer',$_REQUEST['record']);
            
              if(is_array($tmps)&&sizeof($tmps)>0)
              {
                 foreach($tmps as $index=>$content)
                 {
                     $productname=$content['productname'];
                     $errorinfo.=str_replace('{productname}','"'.$productname.'"',getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH'))."\n";
                 }  
                  ConvertTojsonString(-3,array(),$errorinfo);
              }
          }
        if ($_REQUEST['type'] == 'approvecheck') {
            ConvertTojsonString(1,array(),'success');
        }
          
        $query = 'select sum(ifnull(quantity,0)) as quantity,productid,ifnull(batchtext,"") as batchtext
         from ld_warehousetransferdetail where id = ? group by productid,ifnull(batchtext,"")';
        $result = $adb->pquery($query,array($recordid));
        $num_rows = $adb->num_rows($result);
       
         //更改审批状态和审批人
        if($_REQUEST['submittransfer'] == 'Confirm')
        {
            $transferstatus = '已审核';
            $transfersmownerid = $current_user->id;
        }
        else
        {
            $transferstatus = '未审核';
            $transfersmownerid = 0;
        }
        
        $adb->pquery('update ld_warehousetransfer set transferstatus = ?,transfersmownerid = ? where warehousetransferid = ?',array($transferstatus,$transfersmownerid,$recordid));
        for($i = 0; $i<$num_rows; $i++)
        {
            $productid = $adb->query_result($result,$i,'productid');
            $quantity = $adb->query_result($result,$i,'quantity');
            //$infirstqty = getWareProductNum($inwarehouse,$productid);
            //$outfirstqty = getWareProductNum($outwarehouse,$productid);
            $batchtext=$adb->query_result($result,$i,'batchtext');
            /*
            * $recordid:单据ID
            * $inwarehouse：仓库ID
            * $infirstqty：操作前库存数量
            * $inputqty：入库数
            * $outputqty：出库数
            * $lastqty：操作后库存数量
            * $model：当前模块名
            * $userid：当前用户ID
            */
			crm_load_function_file('insertProductQty','include/Stock','CommonStock');
		///	insertProductQty($productid,0,'');//调拨单不需要更新产品总库数量
            /*if($_REQUEST['submittransfer'] == 'Confirm')
            {   
               
                //审核
                insertCon($recordid,'调入仓库',$inwarehouse,$productid,$infirstqty,$quantity,0,$infirstqty + $quantity,$currentModule,$current_user->id);
                updateWarehouseProduct($batchtext,$inwarehouse,$productid,$infirstqty + $quantity);
                insertCon($recordid,'调出仓库',$outwarehouse,$productid,$outfirstqty,0,$quantity,$outfirstqty - $quantity,$currentModule,$current_user->id);
                updateWarehouseProduct($batchtext,$outwarehouse,$productid,$outfirstqty - $quantity);
            }
            else
            {
                //反审核
                insertCon($recordid,'撤销调入仓库',$inwarehouse,$productid,$infirstqty,0,$quantity,$infirstqty - $quantity,$currentModule,$current_user->id);
                updateWarehouseProduct($inwarehouse,$productid,$infirstqty - $quantity);
                insertCon($recordid,'撤销调出仓库',$outwarehouse,$productid,$outfirstqty,$quantity,0,$outfirstqty + $quantity,$currentModule,$current_user->id);
                updateWarehouseProduct($outwarehouse,$productid,$outfirstqty + $quantity);
            }   */
        }
       
      
       
    }
      @ob_clean();
       echo '$$success$$';exit();
}
?>