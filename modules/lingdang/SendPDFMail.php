<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
global $current_user,$adb;
$filenameid = $_REQUEST['record'];
$printId = $_REQUEST['printid'];
$module = $_REQUEST['module'];
$tabid = getTabid($module);


//获取模块的连接字段作为生成doc文件的名字
$cache_entityarray = getEntitynameInfo($tabid);
$sql = 'select '.$cache_entityarray['fieldname'].' from '.$cache_entityarray['tablename'].' where '.$cache_entityarray['tablename'].'.'.$cache_entityarray['entityidfield'].'='.$_REQUEST['record'].' LIMIT 1';
$result = $adb->pquery($sql,array());
$subject = $adb->query_result($result,0,0);
$subject=preg_replace('# #','',$subject);
//html  name
$htmlname = $module.'_'.$_REQUEST['record'].'_'.$current_user->id;
$rand_num = rand(1000,9999);
//doc name
if(strtolower(PHP_OS)!='freebsd'&&strtolower(PHP_OS)!='linux'&&strtolower(PHP_OS)!='unix'){
	$wordfilename = mb_convert_encoding(getTranstab($module), 'gbk','utf-8').'_'.mb_convert_encoding($subject, 'gbk','utf-8').'_'.$rand_num;
}else{
	$wordfilename = getTranstab($module).'_'.$subject.'_'.$rand_num;
}

if(isset($_REQUEST['templatetype']) && !empty($_REQUEST['templatetype'])){// XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
	crm_load_class_file('TemplatePrintFile', 'include/TemplatePrint');
	$templateprintobj = TemplatePrintFile::getInstance($_REQUEST['templatetype'],$module,$tabid,$printId,$_REQUEST['record']);
	$wordfilename = getTranstab($module) .'_'.$_REQUEST['record'].'_'.$_REQUEST['printid'].'_'.$current_user->id;
	$outputFile = $templateprintobj->createFile($wordfilename);
	if($_REQUEST['CreatePdf'] == true){// 转PDF
		$outputFile = $templateprintobj->convertToPDF($outputFile);
	}
	$filebasename = mb_substr($outputFile, mb_strrpos($outputFile, '/') + 1);
	copy($outputFile, 'dataCache/'.$filebasename);

	$pdffilename = $filebasename;

}else{
	//生成doc文件
	if($_REQUEST['CreatePdf'] == true){
		CreatePdf($_REQUEST['module'],$_REQUEST['printid'],$_REQUEST['record'],$htmlname,$wordfilename,'no');
		$pdffilename = getTranstab($module).'_'.$subject.'_'.$rand_num.'.pdf';
	}else{
		CreateDoc($_REQUEST['module'],$_REQUEST['printid'],$_REQUEST['record'],$htmlname,$wordfilename);
		$pdffilename = getTranstab($module).'_'.$subject.'_'.$rand_num.'.doc';
	}
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array("printid"=>$printId,'attachment'=>$pdffilename),'success');

//$page_addurl=urlencode("&printid=".$printId."&attachment=".$pdffilename."&fromid=".$_REQUEST['record']);
//$URL='index.php?pageto_module=Emails&pageto_action=EditView&page_addurl='.$page_addurl;
//
//echo "<script>window.location.href='$URL'</script>";
//exit();
?>