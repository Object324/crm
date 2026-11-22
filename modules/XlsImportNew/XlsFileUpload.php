<?php
$currentModule=$_REQUEST['frommodule'];
global $current_user;
$_REQUEST['diony']='yes';
//zkt 20231030 XUQIU1001341 SQL注入  -- 附件上传只判断部分参数
$filejudgepramkeyarr =['module','action','frommodule','filerand','filename'];
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeparamkeyarr($filejudgepramkeyarr);
$JudgeUrlstringbyarr = array_merge($_REQUEST,array('filename'=>$_FILES['ImportXlsFile']['name']));
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($JudgeUrlstringbyarr);
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//第二步,导入界面2字段映射
    foreach($_FILES['ImportXlsFile'] as $key1=>$value1){
        $filenamess=$_FILES['ImportXlsFile']['name'];//获取导入文件的名称
    }   
    
    FileFileterString($filenamess);//edit:can 20200824 文件特殊字符串过滤，安全性检测
    $filetype =pathinfo($filenamess, PATHINFO_EXTENSION);//获取导入文件的后缀名
    if(strtolower($filetype)!='xls'&&strtolower($filetype)!="xlsx")
    {
        ConvertTojsonString(-1,array(),'请上传excel文件');
    }
    $pathname="storage/".$current_user->id.'_'.$currentModule.".".$filetype;
    FileFileterString($current_user->id.'_'.$currentModule.".".$filetype);//edit:can 20200824 文件特殊字符串过滤，安全性检测
    
    if(isset($_FILES['ImportXlsFile'])){
             if($_FILES['ImportXlsFile']['error'] != UPLOAD_ERR_OK){
               ConvertTojsonString(-1,array(),'引入文件上传失败！');
               
             }else{
                if(file_exists("storage/".$current_user->id.'_'.$currentModule.".".$filetype)){
                    $result = @unlink ("storage/".$current_user->id.'_'.$currentModule.".".$filetype);
                        if($result==false){
                             
                             ConvertTojsonString(-1,array(),'删除文件失败！');
                        }
                    }
                  
                move_uploaded_file($_FILES['ImportXlsFile']['tmp_name'] , $pathname);
                $_SESSION[$currentModule][$current_user->id]['importlog']['filenamess'] = $filenamess;
                ConvertTojsonString(1,array('filename'=>$current_user->id.'_'.$currentModule.".".$filetype),'success');
            
            }  
    }

?>