<?php

global $adb,$current_language,$app_strings,$current_user;
$languageType= getLanguageType($current_user);
$printtabid=$_REQUEST['printtabid'];
$mode = vtlib_purify($_REQUEST['mode']);
if($printtabid==9)
    $printtabid=16;

$sql="select name from ld_tab where tabid=?";

$result=$adb->pquery($sql,array($printtabid));
$tabname=getTabname($printtabid);
//$cmod=return_module_language($current_language,$adb->query_result($result,0,0));

$sql='select ld_field.uitype,ld_field.bigtype,block,tranfield.fieldlabel,fieldname,fieldid,tablename,tranblock.fieldlabel as blocklabel,ld_tab.name from ld_field 
    inner join ld_blocks on ld_blocks.blockid=ld_field.block inner join ld_tab on ld_tab.tabid=ld_field.tabid 
    inner join ld_tranlabel as tranfield on tranfield.relateid=ld_field.fieldid 
    inner join ld_tranlabel as tranblock on tranblock.relateid=ld_blocks.blockid
    where tranfield.languagetype=? and tranfield.trantable=?  and tranfield.tabid=? 
    and tranblock.languagetype=? and tranblock.trantable=?  and tranblock.tabid=? and  
    ld_field.presence in (0,2) and ld_field.savedatabase="yes"  and ld_field.uitype<>1109 ';
   
if(get_file_address($tabname,'ProductDetails'))
{
   //16946: 控制面板>打印模板,关于打印模板中多出字段的问题
// ls 2022-05-23 0051838（https://www.51mis.com/hy/2022511/）（通用账套）报价单打印模板选不到整单折扣字段
//    $sql .=" and ld_field.columnname not in('discount_percent','discount_amount','s_h_amount')";
}
/**
 * 选择客户模块时，添加首要联系人区域的过滤条件。
 * @reason 0008895 打印时选择客户首要联系人字段好报错
 * @author Tujt 2014-05-14
 */
if($printtabid == 6){
	$sql .= ' and ld_blocks.blocklabel != "LBL_ACCOUNT_PRIMARYCONTACT" ';
}
/**
 * 去掉选择源单字段
 * @reason 0009196 打印模版，无法打印源单
 * @author Tujt 2014-05-29
 */
 ////16551: 客户>序时簿,关于批量操作的说明信息有误的问题,edit:can count-1变为count
//$sql .= ' and ld_field.fieldname != "" ';
$sql .= 'order by block,ld_field.sequence ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$printtabid,$languageType,'ld_blocks',$printtabid));
ob_clean();
ob_flush();
$fieldsel="";
$curtab_name=getTabname($printtabid);
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
    $fieldname=$adb->query_result($result,$i,'fieldname');
    $tablename=$adb->query_result($result,$i,'tablename');
    $blockLabel=$adb->query_result($result,$i,'blocklabel');
    $tabname=$adb->query_result($result,$i,'name');
    $uitype=$adb->query_result($result,$i,'uitype');
    $bigtype=$adb->query_result($result,$i,'bigtype');
    $fieldid=$adb->query_result($result,$i,'fieldid');
    if(strtolower($tabname)=='events')
    {
        $tabname='Calendar';
    }

   $printlabels=array();
    ////16551: 客户>序时簿,关于批量操作的说明信息有误的问题,edit:can count-1变为count
    if(($uitype==200||$uitype==202||$uitype==201))
   {//wym 240227 BUG20240204-23 收付款单打印模板 显示选择源单字段
    if(get_file_address($tabname,'ProductDetails') || get_file_address($tabname,$tabname."DetailFieldsHtml") || ($tabname == 'Singin' && $mode == 'WorkReportContent'))
       {
           // $fieldname='originbill';
        //   $tablename='ld_'.strtolower($curtab_name);
          // $tabname=$curtab_name;
       }
       else
       {
        continue;
       }
   }
    //XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅）
    if ($mode=='CalendarDisplayContent' ){
        //图片附件签到二维码 开始时间结束时间 多选字段目前无法直接显示到日历上
        if (in_array($uitype,array(1109,69,306,1500,301,230)) || $fieldname == 'date_start' || $fieldname == 'due_date' || $bigtype == 'multireference'){
            continue;
        }
    }else if ($mode == 'WorkReportContent' || $mode == 'FileWaterMark'){
        if (in_array($uitype,array(1109,69,306,1500,301,230))){
            continue;
        }
    }

   $printlabels=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$blockLabel,"3"=>$tabname);
  
   $printfields[$adb->query_result($result,$i,"block")][$fieldname]=$printlabels;
   
    
    
}

//echo "##SUCCESS##".print_r($cmod);
//exit();
$prodtabid = getTabid('Products');
$prodtab_b = false;
if($_REQUEST['tabid'] != $prodtabid && $printtabid == $prodtabid){
	$prodtab_b = true;
}

$fieldsel='<select onchange="fieldSel(this)" name="SelectField" class="ld-select-inner">';
$fieldsel.='<option>--'.getFixedLabel('NONE').'--</option>';
foreach($printfields as $blockid=>$blockcontent)
{
    $i=0;
    foreach($blockcontent as $fieldname=>$fieldcontent)
    {
        $tablename=$fieldcontent["0"];
        $tablenames=explode("_",$tablename);
        switch($tablename){
            case 'ld_fund_management':
                $tablename=$tablenames[1].'_'.$tablenames[2];
                break;
            case 'ld_fund_management_commission':
                 $tablename=$tablenames[1].'_'.$tablenames[2].'_'.$tablenames[3];
                break;
                default:
                  $tablename=$tablenames[1];
        }
        $blockLabel=$fieldcontent["2"];
        $tabname=$fieldcontent["3"];
         if($i==0)
             $fieldsel.='<optgroup class="select" style="border:none" label="'.$blockLabel.'">';
         $i++;
         if($printtabid == $prodtabid)
         {
            //edit:can 2020-12-23 043901: （61mis.com/kfbcrm）系统设置-参数设置-自动提醒设置（需要补丁）；设置产品模块的更新提醒，*提醒内容中设置了产品名称的变量，但收到的提醒消息中，没有显示产品名
         }
         
		else if($prodtab_b){
			$tablename = 'productdetails';
			$tabname = 'products';
		}

         $fieldsel.='<option value="'.$tablename.'_'.$fieldname.'_'.$tabname.'">'.$fieldcontent["1"].'</option>';
    }
    $fieldsel.='</optgroup>';
}
$fieldsel.='</select>';
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array('fieldsel'=>$fieldsel),"success");
?>