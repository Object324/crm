<?php


global $adb;
$smarty=new lingdangCRM_Smarty;
$VersionInfo = getVersionInfo();
$trade=$VersionInfo['trade'];
if(empty($trade))
{
    $sql='select * from ld_industrydemo   order by sequence asc  ';
}
else
    $sql='select * from ld_industrydemo  where suit_crmversion="all" or   suit_crmversion="'.$trade.'" order by sequence asc  ';

$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);

$tablehtml='<table class="settingTable fir-center" id="modmgr_standard" width="100%" cellspacing="0" cellpadding="0" border="0">';
$tablehtml.="<tr>";
$tablehtml.="<th>#</th>";

$tablehtml.="<th >";
$tablehtml.=getFixedLabel('Industry');
$tablehtml.="</th>";
$tablehtml.="<th style='display:none'>";
$tablehtml.=getFixedLabel('IncludeDemoData');
$tablehtml.="</th>";

$tablehtml.="<th>";
$tablehtml.=getFixedLabel('WithoutDemoData');
$tablehtml.="</th>";
$tablehtml.="</tr>";

global $current_user;

$languageType=getLanguageType($current_user);

for($i=0;$i<$rows;$i++)
{
    $id=$adb->query_result($result,$i,'id');
    if($i%2 == 0){
        $tablehtml.="<tr tag='$id' id='setting_{$id}' class='lvtColData' onmouseout=\"listOnMouseOut(ld(this),'on');\" onmouseover='listOnMouseOver(ld(this));'>";
    }
    else{
        $tablehtml.="<tr tag='$id' id='setting_{$id}' class='lvtColDataBj' onmouseout=\"listOnMouseOut(ld(this),'On');\" onmouseover='listOnMouseOver(ld(this));'>";
    }
    $tablehtml.="<td>".($i+1).'</td>';
    $tablehtml.="<td>";
    if($languageType=='zh')
    {
        $tablehtml.=$adb->query_result($result,$i,'industry_zh');
    }
    else{
        $tablehtml.=$adb->query_result($result,$i,'industry_en');
    }
    $tablehtml.='</td>';
    $tablehtml.="<td style='display:none'><a tag='restoredata' type='includedemodata' href='#'>";
    $tablehtml.=getFixedLabel('RestoreDataBase');
    $tablehtml.="</a></td>";
    
    $tablehtml.="<td><a tag='restoredata' type='withoutdemodata' href='#'>";
    $tablehtml.=getFixedLabel('RestoreDataBase');
    $tablehtml.="</a></td>";
    $tablehtml.='</tr>';
    
}
$tablehtml.="</table>";

$smarty->assign("listhtml",$tablehtml);
$_REQUEST['diony']='yes';

$arr['content']= $smarty->fetch('Settings/RestoreDataBase.tpl');
ConvertTojsonString(1,$arr,"success");
?>