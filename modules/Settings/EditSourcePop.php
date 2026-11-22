<?php

$frommodule=$_REQUEST['frommodule'];
$selectmodule=$_REQUEST['selectmodule'];
global $adb;

$tabid=getTabid($frommodule);
$option_tabid=getTabid($selectmodule);
if($option_tabid == 16){
    $option_tabid = 9;
}

if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'setSigninMappingFields'){
    $leftfields_arr = [];
    $rightfields_arr = [];
    $focus=CRMEntity::getInstance($selectmodule);
    if(!empty($focus->fieldobj)){
        $fieldinfos = $focus->fieldobj->getModuleFields();
        $tmp_i = 0;
        foreach ($fieldinfos as $fieldname => $fieldinfo){
            if(Field::isAddressMappingField($fieldinfo->getBigType())){
                $leftfields_arr[$tmp_i]['value'] = $fieldinfo->getColumnName();
                $leftfields_arr[$tmp_i]['text'] = $fieldinfo->getFieldLabelKey();
                $tmp_i++;
            }
        }
    }
    // dump($leftfields_arr);
    $_REQUEST['diony']='yes';
    $arr['leftfields_arr']=$leftfields_arr;
    $arr['rightfields_arr']=$rightfields_arr;
    $arr['title']=getFixedLabel('VisitingAddressMappingFields');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    ConvertTojsonString(1,$arr,'success');
}

$sql='select * from ld_option_module where tabid=? and option_tabid=?';

$result=$adb->pquery($sql,array($tabid,$option_tabid));

$presence=$adb->query_result($result,0,'presence');
$optionvalues['presence']=$presence;
$default=$adb->query_result($result,0,'default');
$optionvalues['default']=$default;
$optionvalues['approve_demand']=$adb->query_result($result,0,'approve_demand');
$optionvalues['datarang']=$adb->query_result($result,0,'datarang');
$optionvalues['maxrowsshow']=$adb->query_result($result,0,'maxrowsshow');

$optionvalues['withdetail']=$adb->query_result($result,0,'withdetail');//是否带出明细,yes:带出明细 
$optionvalues['strictsourcebillcolums']=$adb->query_result($result,0,'strictsourcebillcolums');//严格参照原单字段
$optionvalues['autobalancevalue']=$adb->query_result($result,0,'autobalancevalue');//自动带出源单剩余数量或金额
//@edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出(“数量” 动态显示)
$optionvalues['withbalanceqtycondition']=$adb->query_result($result,0,'withbalanceqtycondition');//剩余数量为0时不带出
//duan 签到模块设置源单时增加签到相关判断
$optionvalues['uploadwatermark'] = $adb->query_result($result,$i,'uploadwatermark');
$optionvalues['no_signin'] = $adb->query_result($result,$i,'no_signin');
$optionvalues['allowable_distance'] = $adb->query_result($result,$i,'allowable_distance');
$optionvalues['nosignout_cantsignin'] = $adb->query_result($result,$i,'nosignout_cantsignin');// 当天有未签退的外勤时，不允许继续签到 
$optionvalues['allowsupsignout'] = $adb->query_result($result,$i,'allowsupsignout');// 签退是否允许补签
$optionvalues['unallowrepeat'] = $adb->query_result($result,$i,'unallowrepeat');// 签退是否允许补签

//edit: xll 2023/05/08 XUQIU1001203 选择源单 增加“显示超链接”字段属性
$optionvalues['ShowHyperlinks'] = $adb->query_result($result,$i,'showhyperlinks');//no: 不显示  yes: 显示
// 2024-4-11 xxy 签到-拜访对象-拜访地址映射规则
if($frommodule == 'Singin'){
    $signinmappingrule = $adb->query_result($result,$i,'signinmappingrule');// 拜访地址映射规则
    $signinmappingcontent = $adb->query_result($result,$i,'signinmappingcontent');// 拜访地址映射内容
    $optionvalues['signinmappingrule'] = $signinmappingrule;
    if($signinmappingrule == 'field'){// 拜访地址映射字段
        $arr['signmappingfields'] = [];
        if(!empty($signinmappingcontent)){
            $signinmappingfields = explode(',',$signinmappingcontent);
            $signinmappingcontent = [];
            $focus = CRMEntity::getInstance($selectmodule);
            $tmp_i = 0;
            foreach($signinmappingfields as $index => $columnname){
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                if($fieldinfo){
                    $signinmappingcontent[$tmp_i] = $arr['signmappingfields'][$tmp_i]['text'] = $fieldinfo->getFieldLabelKey();
                    $signmappingfieldsvalue[$tmp_i] = $arr['signmappingfields'][$tmp_i]['value'] = $columnname;
                    $tmp_i++;
                }
            }
            $signinmappingcontent = implode(',',$signinmappingcontent);
            $arr['signmappingfieldsvalue'] = implode(',',$signmappingfieldsvalue);
        }
        
    }
    $optionvalues['signinmappingcontent'] = $signinmappingcontent;
}

$effectivecondition = $adb->query_result($result,0,'effectivecondition');
if(!empty($effectivecondition)){
    //将页面上的特殊标识转义为字符
    $effectivecondition = html_entity_decode($effectivecondition);
    $effectivecondition_arr = json_decode($effectivecondition,true);
    foreach($effectivecondition_arr as $key => $value){
        foreach($value as $tmp_key=>$tmp_value){
            //将特殊符号转义用于页面上显示
            $effectivecondition_arr[$key][$tmp_key] = htmlentities($tmp_value);
        }
    }
}else{
    $effectivecondition_arr = array();
}
$tmp_strictsourcebillcolum_arr=explode(',',$optionvalues['strictsourcebillcolums']);
$smarty=new lingdangCRM_Smarty();
$smarty->assign("productDetailModule",'no');

if (in_array($frommodule,array('OutboundOrder','Invoice','Stock','PurchaseInvoice'))) {
    $repalce_lable = '';
    if ($frommodule == 'OutboundOrder' && in_array($selectmodule,array('SalesOrder','ServiceContracts')))  //出库单 未出库数量
        $repalce_lable = getFixedLabel('NOTOUTSTOREQUAN');
    elseif ($frommodule == 'Invoice' && in_array($selectmodule,array('SalesOrder','ServiceContracts'))) //销售发票  未开票数量
        $repalce_lable = getFixedLabel('BALANCEINVOICECOUNT');
    elseif ($frommodule == 'Stock' && in_array($selectmodule,array('PurchaseOrder'))) //入库单  未入库数量
        $repalce_lable = getFixedLabel('NOTSTOCKQUAN');
    elseif ($frommodule == 'PurchaseInvoice' && in_array($selectmodule,array('PurchaseOrder'))) //采购发票  未开票数量
        $repalce_lable = getFixedLabel('BALANCEINVOICECOUNT');

    if ($repalce_lable != '') {
        $withbalanceqtycondition_lable = getFixedLabel('WithBalanceQtyCondition');
        $withbalanceqtycondition_lable = str_replace('{quantity}',$repalce_lable,$withbalanceqtycondition_lable);//动态替换为源单产品分录的“数量”
        $smarty->assign("WithBalanceQtyCondition",$withbalanceqtycondition_lable);
    }
}

if(get_file_address($frommodule,'ProductDetails')||(($frommodule=='CashBill'||$frommodule=='SendCashBill')&&get_file_address($selectmodule,'ProductDetails')))
{
   
    $smarty->assign("productDetailModule",'yes');
    $system_deploy_arr=getSys_deploy(279);
      
    $deploy_inputvalue_arr=ldcrm_json_decode(html_entity_decode($system_deploy_arr['inputvalue']));
    $focus=CRMEntity::getInstance($frommodule);
    $productfieldinfo= $focus->detailfieldobj->getFieldInfoobjBykey("columnname",'productname');
    $strictsourcebillcolum_arr=[];
   
    foreach($deploy_inputvalue_arr as $inputvalueinfo){
        $columnname=$inputvalueinfo['value'];
          if($columnname=='')
          {
                continue;
          }
         
        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
       if(!$fieldinfo)
            continue;
        $text=$inputvalueinfo['text'];
       
        $columnlabel=str_replace("{columnname}",$fieldinfo->getfieldLabel(),getFixedLabel($text));
        $tip=getFixedLabel('LineTipStrictSourceBillColumn');
        $tip=str_replace('{productnamelabel}',$productfieldinfo->getFieldLabel(),$tip);
        $tip=str_replace('{columnname}',$fieldinfo->getFieldLabel(),$tip);
        $tip=str_replace('{productnamelabel}',$productfieldinfo->getFieldLabel(),$tip);
        $selected='no';
        if(in_array($columnname,$tmp_strictsourcebillcolum_arr))
            $selected='yes';
        //特殊控制吧
        if($frommodule=='CashBill')
            $columnlabel=getFixedLabel('curcashbillstrictcontrol');
        else  if($frommodule=='SendCashBill')
            $columnlabel=getFixedLabel('cursendcashbillstrictcontrol');;
        $tmp_arr = array('label'=>$columnlabel,"columnname"=>$columnname, 'selected'=>$selected,'tip'=>$tip);
        if(isset($effectivecondition_arr[$columnname])){
            $tmp_arr['search_info'] = $effectivecondition_arr[$columnname];
        }
        $strictsourcebillcolum_arr[]=$tmp_arr;
        
    }
    
    $system_deploy_arr=getSys_deploy(321);
    $deploy_inputvalue_arr=ldcrm_json_decode(html_entity_decode($system_deploy_arr['inputvalue']));
    $balanceColumn_arr=[];
    foreach($deploy_inputvalue_arr as $inputvalueinfo){
         $columnname=$inputvalueinfo['value'];
          if($columnname=='')
          {
                continue;
          }
         
          
         $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
         $selected='no';
         if($columnname==$optionvalues['autobalancevalue'])
         {
            $selected='yes';
         }
         if($fieldinfo)
         {
            $balanceColumn_arr[]=array("columnname"=>$columnname,'fieldlabel'=>$fieldinfo->getFieldLabel(),'selected'=>$selected);
            
         }
       
    }
    $smarty->assign("BalacenColumn_arr",$balanceColumn_arr);
}

 

$smarty->assign("StrictSourceBillColumn_arr",$strictsourcebillcolum_arr);
$smarty->assign("optionvalues",$optionvalues);
$smarty->assign("SELECTMODULE",$selectmodule);
$smarty->assign("FORMMODULE",$frommodule);
$smarty->assign('effectivecondition_arr',$effectivecondition_arr);
$_REQUEST['diony']='yes';
$arr['content']=$smarty->fetch("Settings/editsource.tpl");
$arr['title']=getFixedLabel('LBL_Optionalmodule_Customization').'-'.getFixedLabel('EDITPROPERTIES');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');

?>