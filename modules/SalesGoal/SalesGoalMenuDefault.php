<?php
//edit:can 20210128 销售目标功能优化，目标查看界面去掉目标为0的记录

global $adb;
$_REQUEST['diony']='yes';
$tradeInfo = getVersionTradeInfo();
if(isset($_REQUEST['save'])&&$_REQUEST['save']=='yes')
{
    //保存
    $sql='update ld_systems_deploy set deploy_value=? where deploy_type=269';
    $adb->pquery($sql,array($_REQUEST['deploy_value']));
    ConvertTojsonString(1,array(),'success');
    
    
}
else
{
  $sql="select * from ld_systems_deploy where deploy_type=269";
  $result=$adb->pquery($sql,array());
  $deploy_value=$adb->query_result($result,0,'deploy_value');

  $html.='<div class="pad10">'.getFixedLabel('SalesGoalMenuDefault').' <select name="salesgoalmenudefault" id="salesgoalmenudefault" class="salesgoaltimeselect btn-radius-system">
              <option value="paymentamount">'.getFixedLabel('THEAMOUNTOFBACK').'</option>
              <option value="contractamount" >'.getFixedLabel('CONTRACTAMOUNTS').'</option>
              <option value="accountsnumber">'.getFixedLabel('THECUSTOMERNUMER').'</option>';
              if(vtlib_isModuleActive("Invoice"))
          	
          		$html.='<option value="invoiceamount">'.getFixedLabel('Invoiceamount1').'</option> ';
                
             if(vtlib_isModuleActive("OutboundOrder"))
          	
          		$html.='<option value="outboundorderamount">'.getFixedLabel('outamount').'</option>';

                //zxm 2022-0317 应收单 应收额目标  上海庆科*
                if ($tradeInfo['account'] == 'sh_qingke'){
                    $html.='<option value="receivableamount">'.getFixedLabel('receivableamount').'</option>';
                }

            $html.=' </select></div>';
 
  $arr=[];
  $arr['deploy_value']=$deploy_value;
  $arr['oktext']=getFixedLabel("SAVE");
  $arr['canceltext']=getFixedLabel("CANCEL");
  $arr['title']=getFixedLabel('SetDefaultValue');
 
  $arr['content']=$html;
  ConvertTojsonString(1,$arr,'success');           
}
?>