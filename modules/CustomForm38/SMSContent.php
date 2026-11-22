<?php
global $adb,$current_language,$app_strings,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$printtabid=$_REQUEST['printtabid'];

if($printtabid==9)
    $printtabid=16;

$sql="select name from ld_tab where tabid=?";

$result=$adb->pquery($sql,array($printtabid));
//require_once('modules/'.$adb->query_result($result,0,0).'/language/zh_cn.lang.php');

$sql='select block,tranfield.fieldlabel,fieldname,fieldid,tablename,tranblock.fieldlabel as blocklabel,ld_tab.name from ld_field 
    inner join ld_blocks on ld_blocks.blockid=ld_field.block inner join ld_tab on ld_tab.tabid=ld_field.tabid 
    inner join ld_tranlabel as tranfield on tranfield.relateid=ld_field.fieldid 
    inner join ld_tranlabel as tranblock on tranblock.relateid=ld_blocks.blockid
    where tranfield.languagetype=? and tranfield.trantable=?  and tranfield.tabid=? 
    and tranblock.languagetype=? and tranblock.trantable=?  and tranblock.tabid=? and  ld_field.presence in (0,2) ';
/**
 * 选择客户模块时，添加首要联系人区域的过滤条件�?
 * @reason 0008895 打印时选择客户首要联系人字段好报错
 * @author Tujt 2014-05-14
 */
if($printtabid == 6){
	$sql .= ' and ld_blocks.blocklabel != "LBL_ACCOUNT_PRIMARYCONTACT" ';
}
/**
 * 去掉选择源单字段
 * @reason 0009196 打印模版，无法打印源�?
 * @author Tujt 2014-05-29
 */
$sql .= ' and ld_field.fieldname != "" ';
$sql .= 'order by block ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$printtabid,$languageType,'ld_blocks',$printtabid));

$fieldsel="";
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
    $fieldname=$adb->query_result($result,$i,'fieldname');
    $tablename=$adb->query_result($result,$i,'tablename');
    $blockLabel=$adb->query_result($result,$i,'blocklabel');
    $tabname=$adb->query_result($result,$i,'name');
    if(strtolower($tabname)=='events')
    {
        $tabname='Calendar';
    }

   $printlabels=array();
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

$fieldsel='<select onchange="fieldSel(this)" name="SelectField">';
$fieldsel.='<option>--'.getFixedLabel('NONE').'--</option>';
foreach($printfields as $blockid=>$blockcontent)
{
    $i=0;
    foreach($blockcontent as $fieldname=>$fieldcontent)
    {
        $tablename=$fieldcontent["0"];
        $tablenames=explode("_",$tablename);
        $tablename=$tablenames[1];
        $blockLabel=$fieldcontent["2"];
        $tabname=$fieldcontent["3"];
         if($i==0)
             $fieldsel.='<optgroup class="select" style="border:none" label="'.$blockLabel.'">';
         $i++;
			if($prodtab_b){
				$tablename = 'productdetails';
				$tabname = 'Products';
			}
         $fieldsel.='<option value="'.$tablename.'_'.$fieldname.'_'.$tabname.'">'.$fieldcontent["1"].'</option>';
    }
    $fieldsel.='</optgroup>';
}

$fieldsel.='<optgroup class="select" style="border:none" label="'.'产品明细自定义字段'.'">';
if($prodtabid == 14)
{  
    $SqlField = "select ld_producttoolfield.producttoolfieldid,ld_producttoolfield.columnname,
                ld_tranlabel.fieldlabel,ld_producttoolfield.uitype 
                from ld_producttoolfield 
                left JOIN ld_tranlabel on ld_producttoolfield.producttoolfieldid = ld_tranlabel.relateid
                where presence = 0 
                and ld_tranlabel.languagetype = ? and ld_tranlabel.trantable = ? and ld_producttoolfield.tabid=? and ld_producttoolfield.tablename=?
                order by ld_producttoolfield.producttoolfieldid";
             
    $result = $adb->pquery($SqlField,array($languageType,'ld_producttoolfield',getTabid('CustomForm38'),'ld_inventoryproductrelscf'));
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $columnname = $adb->query_result($result,$i,'columnname');
        $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
        
        $fieldsel.='<option value="'.'productdetailssf_'.$columnname.'_Products'.'">'.$fieldlabel.'</option>';     
    }    
}

$fieldsel.='</optgroup>';

$fieldsel.='</select>';

echo "##SUCCESS##". $fieldsel;
exit();
?>