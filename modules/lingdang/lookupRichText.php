<?php
global $adb,$currentModule;
global $theme;
$sql='select * from ld_documenttemplates order by sequence, templateid DESC ';
$result=$adb->pquery($sql,array());
$smarty=new lingdangCRM_Smarty();
$trhtml='<tr class="lvtColData" bgcolor="white" onmouseout="this.className=\'lvtColData\'" onmouseover="this.className=\'lvtColDataHover\'">';
$tdhtml=' <td height="25"> ';
$lookuphtml='';
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $templatename=$adb->query_result($result,$i,'templatename');
    $description=$adb->query_result($result,$i,'description');
    $templateid=$adb->query_result($result,$i,'templateid');
    $lookuphtml.=$trhtml.$tdhtml.'<a href="javascript:submitRichText('.$templateid.",'".$currentModule.'\')">'.$templatename.'</a></td>';
    $lookuphtml.=$tdhtml.$description.'</td></tr>';
    
}
$smarty->assign('LOOKUPHTML',$lookuphtml);
$theme_path="themes/".$theme."/";
$smarty->assign('THEMEPATH',$theme_path);
if($_REQUEST['popup'] == 'yes'){
	$_REQUEST['diony']='diony';
	$arr['title']=getFixedLabel('CALLTEMPLATE');
	$str=$smarty->fetch("lookupRichText.tpl");	
	$arr['content']=$str;
    $arr['oktext']='';
    $arr['canceltext']='';
	ConvertTojsonString(1,$arr,"success");
	exit();
}else{
	$smarty->display('lookupRichText.tpl');
}
exit();
?>