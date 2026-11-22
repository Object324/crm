<?php
/********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
* 
 ********************************************************************************/


global $adb;
include(globalStatic::$root_directory."include/mail/MailDb.php");

include(globalStatic::$root_directory."include/mail/MailRead.php");
include(globalStatic::$root_directory."include/mail/MailInfo.php");


$mailrecorid = $_REQUEST['mailrecordid'];
$filename = $_REQUEST['filename'];
$mailreadobj=new MailRead();
$MailDbobj=new MailDb('');
$mailInfo=$MailDbobj->getMailContentInfo($mailrecorid);

if($mailInfo->mailtype=='pop')
{
        $emlpath=MailRead::getemlAttachmentpath($mailInfo->mailaccountname);
        $attachpath=MailRead::getAttachmentpath($mailInfo->mailaccountname);
      
       foreach($mailInfo->attachments as $tmpfilecontent)
       {
        if($tmpfilecontent['filename']==$filename)
         {
             if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
            	
                            $tmpfilename=$filename;
           		}
             else
                $tmpfilename=mb_convert_encoding($filename,'GBK','auto');
             
             if(file_exists($tmpfilecontent['path'].$tmpfilename))
             {
                
                $fileContent=file_get_contents($tmpfilecontent['path'].$tmpfilename);
                break;
             }
         }
       }
       global    $global_forbiddenext;;
    if(empty($fileContent))
    {
        $mailInfo=$mailreadobj->getMailInfoObj($mailInfo,'yes');
     
         foreach($mailInfo->attachments as $tmpfilecontent)
           {
            if($tmpfilecontent['filename']==$filename)
             {
                
                  if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
            	
                            $tmpfilename=$filename;
           		}
                else
                $tmpfilename=mb_convert_encoding($filename,'GBK','auto');
                 
                  if($tmpfilecontent['encoding']=='quoted-printable')
                  {
                    $fileContent=quoted_printable_decode($tmpfilecontent['text']);
                  }
                  else
                  {
                    $fileContent=base64_decode($tmpfilecontent['text']);
                  }
                   if(!file_exists($attachpath.'/'.$mailrecorid))
                    {
                        mkdir($attachpath.'/'.$mailrecorid,0777);
                        chmod($attachpath.'/'.$mailrecorid,0777);
                     }
                     if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
            	
                            $tmpfilename=$filename;
                   		}
                     else
                        $tmpfilename=mb_convert_encoding($filename,'GBK','auto');
                     $extension=strtolower((string)pathinfo($tmpfilename));

                 if(in_array($extension,$global_forbiddenext))
                 {
                     $tmpfilename.='.lingdang';

                 }
                 $str_arr=['\\','/',':','*','?','"','<>','|','.','<','>'];
                 foreach($global_forbiddenext as $forbidext)
                 {

                     foreach($str_arr as $tmpstr)
                     {
                         if(stripos(  $extension ,$forbidext.$tmpstr)!==false)
                         {

                             $tmpfilename.='.lingdang';
                         }
                     }
                 }
                  file_put_contents($attachpath.'/'.$mailrecorid.'/'.$tmpfilename,$fileContent);
               
                  break;
             }
           }
    }
    
    $name=$filename;
    

}
else
{
    $sql='select * from ld_mailmanager_mailattachments where mailrecordid=?  and aname=?';
    $result=$adb->pquery($sql,array($_REQUEST['mailrecordid'],$filename));
    if($adb->num_rows($result)>0)
    {
        $aname=$adb->query_result($result,0,'aname');
        $name=$aname;
      
       
             if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
            	
                    $tmpfilename=$filename;
      		}
            else
                $tmpfilename=mb_convert_encoding($filename,'GBK','auto');
            $path=$adb->query_result($result,0,'path');
           
            $filePath=$path.$tmpfilename;
            $fileContent=file_get_contents($filePath);
           
        
        
    }
    
}

		header("Content-type: $fileType");
		header("Pragma: public");
		header("Cache-Control: private");
        /*
        EDIT:cAN
        DATE:20130426
        REASON;解决中文文件名称乱码
        */
        //iconv("UTF-8",'gb2312',$name)

        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'||strtolower(PHP_OS)=='macos'){
            header("Content-Disposition: attachment; filename=".$name);
        }else{
			header("Content-Disposition: attachment; filename=".mb_convert_encoding($name,'GB2312','UTF-8'));
		}
		//header("Content-Disposition: attachment; filename=\"".$name."\"");
		header("Content-Description: PHP Generated Data");
		header('Content-Encoding: none');       
		header("Content-Transfer-Encoding: binary" );
          //**********************************        
          /*
          edit:can
          date:20130424
          reason:0003461: "知识管理"上传word作为附件后，再下载，下载完成后，无法打开，希望修改。
          */
          ob_clean();   
            flush(); 
          //********************************* 
		echo $fileContent;
    

?>