<?php

global $adb,$current_user;
if($_REQUEST['printid'])
{
    $id=$_REQUEST['printid'];
}

$templateprintname=$_REQUEST['templatename'];
$printtabid=$_REQUEST['printtabid'];
$replacespacevalue=$_REQUEST['replacespacevalue'];
$approvedallowprint=$_REQUEST['approvedallowprint']?:'no';//ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印
if(empty($replacespacevalue)) $replacespacevalue="&nbsp;";//Liver 2017-02-13 客户那边替换为空情况下，表格显示合并了
if($_REQUEST['isDuplicate'])//判断模板名称是否重复
{
    
    $sql="select templateprintid from ld_templateprint where tabid=? and templateprintname=?";
    $result=$adb->pquery($sql,array($printtabid,$templateprintname));
	$_REQUEST['diony']='diony';
    if(isset($id)&&$adb->num_rows($result)>1)
    {
		ConvertTojsonString(-1,array(),"模板名称重复！");
    }
    if(!isset($id)&&$adb->num_rows($result)>0)
    {
		ConvertTojsonString(-1,array(),"模板名称重复！");
    }
   
    ConvertTojsonString(1,array(),"success");
}


$isDefault=$_REQUEST['isDefault'];
$tabname = getTabModuleName($printtabid); 

$file_extension = 'html';
$templatetype = '';
if($_REQUEST['templatetype'] && !empty($_REQUEST['templatetype'])){
    $templatetype = $_REQUEST['templatetype'];
    if($templatetype == 'Word')
        $file_extension = 'docx';
    else if($templatetype == 'Excel')
        $file_extension = 'xlsx';
}

if($isDefault==1)
{
    //如果设为默认,则把该模块下的其它默认值取消
     $sql="update ld_templateprint set isDefault=0 where tabid=? and isDefault=1  ";
     $adb->pquery($sql,array($printtabid));
}
if($_REQUEST['mode']=="create")//创建
{
    $sql='insert into ld_templateprint(templateprintname,Tabid,isdefault,replacespacevalue,allocatetype,approvedallowprint,modifiedby,modifiedtime)values(?,?,?,?,?,?,?,?)';
    $adb->pquery($sql,array($templateprintname,$printtabid,$isDefault,$replacespacevalue,0,$approvedallowprint,$current_user->id,date("Y-m-d H:i:s")));
    $id=$adb->getLastInsertID();
    
    $printfilename="$tabname".$id.".".$file_extension;
    $sql="update ld_templateprint set printfilename=? where templateprintid=?";
    $adb->pquery($sql,array($printfilename,$id));
    $sql=' insert into ld_templateprint2user(templateprintid,userid)value(?,?)';
    $adb->pquery($sql,array($id,"-1"));

   
}
else
{
    //$printfilename="$tabname".$id.".html";
    $sql='select printfilename from ld_templateprint where templateprintid=?';
    $result=$adb->pquery($sql,array($id));
    if($adb->num_rows($result)>0)
        $printfilename=$adb->query_result($result,0,0);
    else
    {
		ConvertTojsonString(-1,array(),"模板已被删除！");
    }
        
    
    $sql="update ld_templateprint set templatePrintname=? ,isdefault=?,replacespacevalue=?,approvedallowprint=?,modifiedby=?,modifiedtime=? where templateprintid=?";
    $adb->pquery($sql,array($templateprintname,$isDefault,$replacespacevalue,$approvedallowprint,$current_user->id,date("Y-m-d H:i:s"),$id));
}
/**创建html文件**/
//14389: 乐瑞固： 合同订单模块和出差报告模块(日程管理)导出doc模板时，显示的是乱码，但是打印显示是正常的。
$TemplatePrintHtml=$_POST['CKTemplatePrint'];

// XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
if(!empty($templatetype)){
    if($_REQUEST['templatefile-file_num'] && $_REQUEST['templatefile-file_num'] > 0){
        $file_num = $_REQUEST['templatefile-file_num'];
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $templatefile_file_path = $cls_MyCRMcrypt->decode($_REQUEST['templatefile-file_path_'.$file_num]);// 文件解密
        $templatefile_file_name = $_REQUEST['templatefile-file_name_'.$file_num];// 用户上传的文件名
        $extension = pathinfo($templatefile_file_name, PATHINFO_EXTENSION);
        $allowedextensions = ['doc','docx','xls','xlsx'];// 允许的文件格式
        if(!in_array($extension,$allowedextensions)){
            ConvertTojsonString(-1,array(),"上传的模板文件格式错误！");
        }
        $templatefile_newfile_name = $cls_MyCRMcrypt->decode($_REQUEST['templatefile-newfile_name_'.$file_num]);
        $tmp_templatefile = $templatefile_file_path.$templatefile_newfile_name;// 临时文件全路径
        $saved_templatefile = 'templatePrintFile/'.$printfilename;

        if(file_exists($tmp_templatefile)){
            $update_sql="update ld_templateprint set originalfilename=? where templateprintid=?";// 更新用户上传的文件名
            $adb->pquery($update_sql,array($templatefile_file_name,$id));

            $fileContent = file_get_contents($tmp_templatefile); // 获取文件内容
            if ($fileContent) {
                file_put_contents($saved_templatefile, $fileContent); // 保存到指定路径
                @unlink($tmp_templatefile);
            }else{
                ConvertTojsonString(-1,array(),getFixedLabel('TEMPLATEFILEISMISSING'));
            }
        }else{
            ConvertTojsonString(-1,array(),getFixedLabel('TEMPLATEFILEISMISSING'));
        }
            
    }
}else{


    if(file_exists("templatePrintFile/".$printfilename))
    {
        $result = @unlink ("templatePrintFile/".$printfilename);
        if($result==false)
        {
            $_REQUEST['diony']='diony';
            ConvertTojsonString(-1,array(),"删除文件".$printfilename.'失败!');
        }
    }
    $f=fopen("templatePrintFile/".$printfilename,"w");
    if ( !is_writable("templatePrintFile/".$printfilename) ){
        $_REQUEST['diony']='diony';
        ConvertTojsonString(-1,array(),"文件:" .$printfilename. "不可写，请检查！");
    }
    $startHtml='<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head></head><body>';
    fwrite($f, $startHtml);
    if(!isset($_REQUEST['printid']))
    {
        fwrite($f, '<span>&nbsp;&nbsp;</span>');
    }
    if(htmlspecialchars($TemplatePrintHtml)!='')
    {
        $TemplatePrintHtml= htmlspecialchars($TemplatePrintHtml);
        $printhtmls=explode(htmlspecialchars("</p>"),$TemplatePrintHtml);
    
        $TemplatePrintHtml="\n";
    
        if(sizeof($printhtmls)>0)
        {
        
            for($i=0;$i<sizeof($printhtmls);$i++)
            {
                $trhtmls=explode(htmlspecialchars("</tr>"),$printhtmls[$i]);
            
                if(is_array($trhtmls)&&strpos($printhtmls[$i],htmlspecialchars("</tr>"))!=false)
                {
                
                    for($j=0;$j<sizeof($trhtmls);$j++)
                    {
                        $tdhtmls=explode(htmlspecialchars("</td>"),$trhtmls[$j]);
                    
                        for($k=0;$k<sizeof($tdhtmls);$k++)
                        {
                            $trtdhtmls=explode("<td",$tdhtmls[$k]);
                        
                                
                            for($h=0;$h<sizeof($trtdhtmls);$h++)
                            {
                                $TemplatePrintHtml.="\n";
                                $TemplatePrintHtml.=$trtdhtmls[$h];
                                
                                if($h==0&&$h!=sizeof($trtdhtmls)-1)
                                $TemplatePrintHtml.="<td";
                                
                            }
                        
                            if($k!=sizeof($tdhtmls)-1)
                                $TemplatePrintHtml.="</td>";
                            $TemplatePrintHtml.="\n";
                        }
                        if($j!=sizeof($trhtmls)-1)
                            $TemplatePrintHtml.="</tr>";
                        $TemplatePrintHtml.="\n";
                    
                    }
                    
                }
                else if(trim($printhtmls[$i])!="<p>"&&trim($printhtmls[$i])!="<p><br/>"&&trim($printhtmls[$i])!="<p><span style=\"font-size: 24px;\"></span>&nbsp;")
                { 
                    $TemplatePrintHtml.=$printhtmls[$i]."</p>"."\n";
                }
                
            }
        }
        else
        {
            $trhtmls=explode(htmlspecialchars("</tr>"),$TemplatePrintHtml);
            
                if(is_array($trhtmls))
                {
                
                    for($j=0;$j<sizeof($trhtmls);$j++)
                    {
                        $tdhtmls=explode(htmlspecialchars("</td>"),$trhtmls[$j]);
                    
                        for($k=0;$k<sizeof($tdhtmls);$k++)
                        {
                            $trtdhtmls=explode("<td",$tdhtmls[$k]);
                        
                                
                            for($h=0;$h<sizeof($trtdhtmls);$h++)
                            {
                                $TemplatePrintHtml.="\n";
                                $TemplatePrintHtml.=$trtdhtmls[$h];
                                
                                if($h==0&&$h!=sizeof($trtdhtmls)-1)
                                $TemplatePrintHtml.="<td";
                                
                            }
                        
                            if($k!=sizeof($tdhtmls)-1)
                                $TemplatePrintHtml.="</td>";
                            $TemplatePrintHtml.="\n";
                        }
                        if($j!=sizeof($trhtmls)-1)
                            $TemplatePrintHtml.="</tr>";
                        $TemplatePrintHtml.="\n";
                    
                    }
                    
                }
        }
    }

    $endHtml='</body></html>';
    
    $TemplatePrintHtml=htmlspecialchars_decode($TemplatePrintHtml);
    fwrite($f,$TemplatePrintHtml);
    fwrite($f,$endHtml);
    fclose($f);
}
 // $sql="select max(printtabid) from ld_templateprint where tabid=?";
  
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>