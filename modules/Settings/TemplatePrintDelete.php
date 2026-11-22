<?php
//zkt 20231013 XUQIU1001341 SQL×¢Èë
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$printtabid=$_REQUEST['printtab'];
$printId=$_REQUEST['printid'];


if(isset($_REQUEST['Systemdefault'])&& $_REQUEST['Systemdefault']==1)
{
    $sql='select 1 from ld_templateprint where templateprintid=? and Systemdefault=1';
    $result=$adb->pquery($sql,array($printId));
    /*if($adb->num_rows($result)>0)
    {
        echo "##error##";
    }
    else 
    {
        echo "##SUCCESS##";
    }*/
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}

$sql='select printfilename,ld_tab.name from ld_templateprint  inner join ld_tab on ld_tab.tabid=ld_templateprint.tabid where ld_templateprint.templateprintid=?';
$result=$adb->pquery($sql,array($printId));
$printfilename=$adb->query_result($result,0,0);
if(file_exists('templateprintFile/'.$printfilename))
{
            
$result = @unlink ('templateprintFile/'.$printfilename);
if($result==false)
{
                //echo "É¾³ýÎÄ¼þÊ§°Ü";
}
            
}
$sql="delete from ld_templateprint where templateprintid=?";
$adb->pquery($sql,array($printId));
$sql="delete from ld_templateprint2user where templateprintid=?";
$adb->pquery($sql,array($printId));
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");


?>