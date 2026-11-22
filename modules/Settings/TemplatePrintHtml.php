<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
require_once("Smarty_setup.php");
global $adb,$current_user;
if(!empty($_REQUEST['tabname'])){
	$tabid = getTabid($_REQUEST['tabname']);
	$module = $_REQUEST['tabname'];
}
$templatetype = isset($_REQUEST['templatetype'])?$_REQUEST['templatetype']:'';// 模板类型

//打印
if(!isset($_REQUEST['CreatePDF']) && !isset($_REQUEST['CreateDOC']) && !isset($_REQUEST['CreateExcel'])){
    if(!file_exists('include/TemplatePrint/TemplatePrint.php'))
    {
        copy("modules/Accounts/TemplatePrint.php",'include/TemplatePrint/TemplatePrint.php');
        
    }
	require_once('include/TemplatePrint/TemplatePrint.php');
	$template=new TemplatePrint($module,$tabid,$_REQUEST['printid'],$_REQUEST['record'],$adb);
    $smarty=new lingdangCRM_Smarty();
    
	$smarty->assign("Content",$template->createPrintHtml()) ;
	// $smarty->assign("fileUrl",'storage/output.docx') ;
	setWxSmarty($smarty);
    $smarty->display("TemplatePrintPage.tpl");
	exit();
}

if($_REQUEST['CreatePDF']==true || $_REQUEST['CreateDOC']==true || $_REQUEST['CreateExcel']==true)
{
	//获取doc名字
	$focus_obj = CRMEntity::getInstance($module);
	$columnname = $focus_obj->table_index;
	$tablename = $focus_obj->table_name;
    if($tabid==55){
        /*
        更新操作
        edit:can
        date:20131029
        reason:0005529: “联系记录”导出PDF时，程序报错，如图所示。
        */
        $columnname="contactrecordid";
        $tablename='ld_contactrecords';
    }
    elseif($_REQUEST['tabname']=='Checks'){
         $columnname="id";
        $tablename='ld_checks';
    }
    elseif($_REQUEST['tabname']=='BankAccountSet'){
        $columnname='accountname';
        $tablename='ld_bankaccountset';
    }
	if($tabid == 16)$tabid = 9;
    $entitynames=getEntitynameByTabId($tabid);
     
                  
    $tablekeyname=$entitynames['entityidfield'];
   
    $moduleFilename=$entitynames['fieldname'];//模块关键字    
    $linktablename=$entitynames['tablename'];

    if($linktablename==$focus_obj->table_name)
    {
        $sql='select '.$moduleFilename.' from '.$tablename.' where '.$tablename.'.'.$tablekeyname.'='.$_REQUEST['record'];
    }
    else
    {
         $tablescf=$focus_obj->customFieldTable[0];
    
         $sql="select $moduleFilename from $tablename  left join $tablescf on $tablename.$tablekeyname=$tablescf.$tablekeyname
                 where ".$tablename.'.'.$tablekeyname.'='.$_REQUEST['record'];
            
    }
    $result=$adb->pquery($sql,array());
   
    $col_value=$adb->query_result($result,0,0);
    $colvalue= mb_convert_encoding($col_value, 'gbk','utf-8');
    //window系统文件名称不支持的特殊字符
    $colvalue=str_replace("/","",$colvalue);
    $colvalue=str_replace("\\","",$colvalue);
    $colvalue=str_replace("|","",$colvalue);
    $colvalue=str_replace("?","",$colvalue);
    $colvalue=preg_replace('# #','',$colvalue);
	//htmlname
	$htmlname = $module .'_' . $colvalue . '_'.$current_user->id;
	//word doc name
	$modulename = getTranstab($module);
	$modulename=str_replace("/","",$modulename);
    $modulename=str_replace("\\","",$modulename);
    $modulename=str_replace("|","",$modulename);
    $modulename=str_replace("?","",$modulename);
	$modulename=str_replace("(","[",$modulename);
	$modulename=str_replace(")","]",$modulename);
	$wordfilename=mb_convert_encoding($modulename,'gbk','utf-8') .'_'.$colvalue;

    // XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
    if(!empty($templatetype)){
        crm_load_class_file('TemplatePrintFile', 'include/TemplatePrint');
        $templateprintobj = TemplatePrintFile::getInstance($templatetype,$module,$tabid,$_REQUEST['printid'],$_REQUEST['record']);
        
        // $wordfilename = mb_convert_encoding($modulename,'gbk','utf-8') .'_'.$_REQUEST['record'].'_'.$_REQUEST['printid'].'_'.$current_user->id;
        $wordfilename = $modulename .'_'.$_REQUEST['record'].'_'.$_REQUEST['printid'].'_'.$current_user->id.'_'.date('YmdHis');

        if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'print'){// 打印
            $outputFile = $templateprintobj->createFile($wordfilename,'part');
            $arr['fileobj'] = $templateprintobj->getFileobj($outputFile);
            ConvertTojsonString(1,$arr,"success");

        }else{
            $outputFile = $templateprintobj->createFile($wordfilename);
            if($_REQUEST['CreatePDF']==true){// 先转成PDF再下载导出
                $outputFile = globalStatic::$root_directory.$templateprintobj->convertToPDF($outputFile);
            }
            $templateprintobj->downloadFile($outputFile);// 下载导出
        }

    }else{
        if($_REQUEST['CreateDOC']==true){
            
            require_once(globalStatic::$root_directory.'include/PrintDoc.php');
        
            $wordfile = PrintDoc::CreateDoc($module,$_REQUEST['printid'],$_REQUEST['record'],$htmlname,$wordfilename);
            
            //if(isKehu001ServerPc()=='yes')
            // {
                //  header("Location:".$wordfile);
            // }
            // else                        
            downloads($wordfile);
            
        }else{
            CreatePdf($module,$_REQUEST['printid'],$_REQUEST['record'],$htmlname,$wordfilename);
        }
    }
	exit();
}
//下载
function downloads($name){

    $file_dir=str_replace('\\','/',dirname(dirname(dirname(__FILE__)))).'/dataCache/'; 
    if (file_exists($file_dir.$name)){
        $down_filesize = filesize($file_dir.$name);
        $file = fopen($file_dir.$name,"rb");

        header("Content-type: application/octet-stream");
        header("Accept-Ranges: bytes");
        header("Accept-Length: " . $down_filesize);
        header("Content-Disposition: attachment; filename=" . $name);
        ob_end_clean();
        echo fread($file, $down_filesize);
        fclose($file);
		@unlink ($file_dir.$name);
    }
    else 
    {
        echo "File not found!";
        exit;
    }
}

class word_doc
{ 
	function start()
	{
    	ob_start();
    	echo '<html xmlns:o="urn:schemas-microsoft-com:office:office"
    	xmlns:w="urn:schemas-microsoft-com:office:word"
    	xmlns="http://www.w3.org/TR/REC-html40">';
	}
	function save($path)
	{
	 
    
    	$data = ob_get_contents();
    	ob_end_clean();
    	 
    	$this->wirtefile ($path,$data);
	}
	 
	function wirtefile ($fn,$data)
	{
    	$fp=fopen($fn,"wb");
    	fwrite($fp,$data);
    	fclose($fp);
	}
}
?>
