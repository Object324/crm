<?php

$frommodule=$_REQUEST['frommodule'];

global $adb;
/*ls 2021-09-18 0047994: （https://81mis.com/kfbcrm/ [^]）通用问题，“选择源单”字段进行新增时，只能选择到自定义表单11-20，选不到36-45，无论开没开启该模块
$arrmodules=array(
    'CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20',
    'CustomForm36','CustomForm37','CustomForm38','CustomForm39','CustomForm40','CustomForm41','CustomForm42','CustomForm43','CustomForm44','CustomForm45'
);*/
//edit:can 20211230 	0049457: 【通用问题】 PC端+移动端 「选择源单-源单类型定制 」
if($frommodule == 'Singin'){
    $sql = "SELECT DISTINCT ld_tab.tabid ,ld_tab.name from ld_tab INNER JOIN ld_field ON ld_tab.tabid = ld_field.tabid where ld_tab.isentitytype = 1 and ld_tab.presence in (0,2) 
                and ld_tab.tabid not IN (SELECT tabid from ld_tab where name in 
                    ('Reminds','ChinaMap','CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis','ChannelCode',
                    'Questionnaire','SocialPromotion','BankCash','Shopping','ShopSettings','WechatSession','Signout')) 
                and ld_field.columnname = 'smownerid' and ld_tab.tabid not IN (SELECT tabid from ld_relatedlists WHERE related_tabid = ? AND label = ? )
            ";
    $result=$adb->pquery($sql,array(getTabid($frommodule),$frommodule));
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++){
        $name=$adb->query_result($result,$i,'name');
        $arrmodules[]=$name;
    }
}else{
    $sql='SELECT
        ld_tab.name
    FROM
        ld_tab INNER JOIN ld_producttoolfield ON ld_tab.tabid = ld_producttoolfield.tabid
    WHERE 
        ld_tab.tabid not IN (SELECT tabid from ld_relatedlists WHERE related_tabid = ? AND label = ? )
    GROUP BY
        ld_tab.tabid  ';
    $result=$adb->pquery($sql,array(getTabid($frommodule),$frommodule));
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
        $name=$adb->query_result($result,$i,'name');
        if(vtlib_isModuleActive($name))
        {
            if($name=='Potentials'&&!file_exists(globalStatic::$root_directory.'modules/Potentials/ProductDetails.php'))
            {
                continue;
            }
            //duan 20221202 产品分录中源单类型定制，不能选择收款单和付款单
            if($name=='SendCashBill' || $name =='CashBill' || $name =='Productbom'){
                continue;
            }
            $arrmodules[]=$name;
        }
    }
}
$sql='select group_concat(option_tabid)  from ld_option_module  where tabid=?';
$result=$adb->pquery($sql,array(getTabid($frommodule)));
$hadselectedtabid=$adb->query_result($result,0,0);
$hadselectedtabids=explode(',',$hadselectedtabid);
$hadselectedtabids[]=getTabid($frommodule);
$waitingselectmodules=array();
foreach($arrmodules as $tmpmodulename)
{
    $tmptabid=getTabid($tmpmodulename);
    if(!in_array($tmptabid,$hadselectedtabids))
    {
        $waitingselectmodules[]=array("tabid"=>$tmpmodulename,'label'=>getTranstab($tmpmodulename));
    }
    
}

$_REQUEST['diony']='yes';
$smarty->assign("waitingselectmodules",$waitingselectmodules);

$smarty->assign("productDetailModule",'no');
$strictsourcebillcolum_arr=[];
$smarty->assign("frommodule",$frommodule);

if(get_file_address($frommodule,'ProductDetails')||($frommodule=='CashBill'||$frommodule=='SendCashBill'))
{
   
    $smarty->assign("productDetailModule",'yes');
    $system_deploy_arr=getSys_deploy(279);

    $deploy_inputvalue_arr=ldcrm_json_decode(html_entity_decode($system_deploy_arr['inputvalue']));
    $focus=CRMEntity::getInstance($frommodule);
    $productfieldinfo= $focus->detailfieldobj->getFieldInfoobjBykey("columnname",'productname');
    
    
    foreach($deploy_inputvalue_arr as $inputvalueinfo){
        $columnname=$inputvalueinfo['value'];
          if($columnname=='')
          {
                continue;
          }
        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
        //zkt 20220413 0050974（http://82.156.43.185:85）（客户问题：东方报警）在 系统设置》界面设置》页面设置》发货申请中基础信息的“选择源单”字段点开编辑，点击“新增”后，就一直转圈加载不出来。
        if(empty($fieldinfo))
        {
            continue;
        }
       
        $text=$inputvalueinfo['text'];
       
        $columnlabel=str_replace("{columnname}",$fieldinfo->getfieldLabel(),getFixedLabel($text));
         //特殊控制吧
        if($frommodule=='CashBill')
            $columnlabel=getFixedLabel('curcashbillstrictcontrol');
        else  if($frommodule=='SendCashBill')
            $columnlabel=getFixedLabel('cursendcashbillstrictcontrol');;
        $tip=getFixedLabel('LineTipStrictSourceBillColumn');
        $tip=str_replace('{productnamelabel}',$productfieldinfo->getFieldLabel(),$tip);
        $tip=str_replace('{columnname}',$fieldinfo->getFieldLabel(),$tip);
        $tip=str_replace('{productnamelabel}',$productfieldinfo->getFieldLabel(),$tip);
        $selected='no'; 
        $strictsourcebillcolum_arr[]=array('label'=>$columnlabel,"columnname"=>$columnname, 'selected'=>$selected,'tip'=>$tip);
        
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
         if($fieldinfo)
         {
            $balanceColumn_arr[]=array("columnname"=>$columnname,'fieldlabel'=>$fieldinfo->getFieldLabel());
            
         }
       
    }
    $smarty->assign("BalacenColumn_arr",$balanceColumn_arr);
    
}

$smarty->assign("StrictSourceBillColumn_arr",$strictsourcebillcolum_arr);
$arr['content']=$smarty->fetch("Settings/selectsourcemodulepopup.tpl");
$arr['title']=getFixedLabel('LBL_Optionalmodule_Customization').'-'.getFixedLabel('NEW');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');

?>