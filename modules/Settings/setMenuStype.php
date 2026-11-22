<?php
/****************************************************************
**edit:chj
**date:2021/3/24
**reason:菜单风格
****************************************************************/
global $adb;
$smarty=new lingdangCRM_Smarty;
$query = 'select menuback_color,menuhover_color,menustyle from ld_organizationdetails';
$result = $adb->pquery($query,array());
$menuback_color = $adb->query_result($result,0,'menuback_color');
$menuhover_color = $adb->query_result($result,0,'menuhover_color');
$menustyle = $adb->query_result($result,0,'menustyle');
if(empty($menuback_color) && empty($menuhover_color)){
	$file_path = "dataCache/tabdatas/skinset.css";
	if(file_exists($file_path)){
		$file_arr = file($file_path);
		for($i=0;$i<count($file_arr);$i++){//逐行读取文件内容
			if(strpos($file_arr[$i],'.btn1.choosed_color{background: ') !== false){
				$length = strlen('.btn1.choosed_color{background: ');
				$menuback = substr($file_arr[$i],$length,7);	//菜单背景色
				$smarty->assign('MENUBACK',$menuback);
			}
			if(strpos($file_arr[$i],'.btn2.choosed_color{background: ') !== false){
				$length = strlen('.btn2.choosed_color{background: ');
				$menuhover = substr($file_arr[$i],$length,7);	//选中色背景
				$smarty->assign('MENUHOVER',$menuhover);
			}
			fclose($file_arr);
		}
	}
	$smarty->assign('MENUSTYLE','lightcolour');
}else{
	$smarty->assign('MENUBACK',$menuback_color);
	$smarty->assign('MENUHOVER',$menuhover_color);
	$smarty->assign('MENUSTYLE',$menustyle);
}
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("menustyle");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/MenuStyle.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>