<?php
global $adb;
//zkt 20231030 XUQIU1001341 SQL注入  -- 附件上传只判断部分参数
$filejudgepramkeyarr =['module','action','frommodule','filerand','filename'];
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeparamkeyarr($filejudgepramkeyarr);
$array_filename=array('backgroundbg','logoname','minilogoname');
$tmpfilename = '';
foreach($array_filename as $key=>$tmp_value ){
    if(isset($_FILES[$tmp_value]))
    {
        $tmpfilename .= $_FILES[$tmp_value]['name'];
    }
}
$JudgeUrlstringbyarr = array_merge($_REQUEST,array('filename'=>$tmpfilename));
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($JudgeUrlstringbyarr);
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

if(isset($_REQUEST['loginui']) && $_REQUEST['loginui'] == 'new'){
    setUsersettingByLabel('Settings',1,'historyloginui','new','');
}else{
    $historylogin = getUsersettingByLabel('Settings',1,'historyloginui');
    if($historylogin == 'old'){
        ConvertTojsonString(2,array(),"success");
    }
}

require_once(globalstatic::$root_directory."dataCache/Login/LoginSettingsInfo.php");
if(!isset($global_logininfo['copyrightinfo']['content']) || $global_logininfo['copyrightinfo']['content']=='' || empty($global_logininfo['copyrightinfo']['content'])){
    $global_logininfo['copyrightinfo'] = array('zh'=>'版权所有','en'=>'Copyright','isshow'=>'yes','isedit'=>'no','content'=>'上海灵当信息科技有限公司');
}else{
  $global_logininfo['copyrightinfo']['isedit']='no';
}
global $current_user;
$languageType= getLanguageType($current_user);
global $versions;
require_once(globalStatic::$root_directory."Register/RegOp.php");
if(file_exists(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
    require_once(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php");
}else{
    require_once(globalStatic::$root_directory."include/language/zh_cn_version.lang.php");
}

$reg=RegOp::getInstance();
$VersionNo=$reg->GetVersionNo();

if($_REQUEST['chk_browse_title_show'])
{
    $versions[$VersionNo]['titleisshow']='yes';
}
else
{
    $versions[$VersionNo]['titleisshow']='no';
}

if($languageType=='zh')
{
    $versions[$VersionNo]['after_zh_title']=$_REQUEST['txt_browse_title'];
    
}
else
{
    $versions[$VersionNo]['after_en_title']=$_REQUEST['txt_browse_title'];
}
$strtitle='<?php'.PHP_EOL;
$strtitle.='require_once(globalStatic::$root_directory."ProductInfo.php");'.PHP_EOL;
 $strtitle.=' $versions=array(';
foreach($versions as $tmpno=>$content)
{
   $strtitle.=$tmpno.'=>array("lblversion"=>"'.$content['lblversion'].'",'.PHP_EOL;
   $strtitle.='"LBL_BROWSER_TITLE"=>"'.$content['LBL_BROWSER_TITLE'].'",'.PHP_EOL;
   $strtitle.='"EN_LBL_BROWSER_TITLE"=>"'.$content['EN_LBL_BROWSER_TITLE'].'",'.PHP_EOL;
   $strtitle.='"Version"=>"'.$content['Version'].'",'.PHP_EOL;
   if($tmpno==$VersionNo)
   {
     $strtitle.='"titleisshow"=>"'.$versions[$VersionNo]['titleisshow'].'",'.PHP_EOL;
     
     $strtitle.='"after_zh_title"=>"'.$versions[$VersionNo]['after_zh_title'].'",'.PHP_EOL;
     $strtitle.='"after_en_title"=>"'.$versions[$VersionNo]['after_en_title'].'",'.PHP_EOL;
     
   }
   $strtitle.="),".PHP_EOL;
}
$strtitle.=PHP_EOL;

$strtitle.=");".PHP_EOL;
$strtitle.="?>";

file_put_contents(globalStatic::$root_directory.'dataCache/Login/zh_cn_version_new.lang.php',$strtitle);
//edit:duan reason:49432：网站标题更改不生效
if(function_exists("opcache_reset"))
    opcache_invalidate(globalStatic::$root_directory.'dataCache/Login/zh_cn_version_new.lang.php',true);

	$uploaddir = $root_directory ."/dataCache/test/logo/" ;// set this to wherever
	$saveflag="true";
	$nologo_specified="true";
	$error_flag ="";
	$nologo_specified="false";
    $array_filename=array('backgroundbg','logoname','minilogoname');
    foreach($array_filename as $key=>$tmp_value ){
        if(isset($_FILES[$tmp_value]))
        {	      
            $binFile = $_FILES[$tmp_value]['name'];
            if(empty($binFile))
            {
                $binFile=$_REQUEST[$tmp_value.'_hidden'];
            }
            $filename = ltrim(basename(" ".$binFile));
        	
        	$filetype= $_FILES[$tmp_value]['type'];
        	$ffilesize = $_FILES[$tmp_value]['size'];
        	
        	$filetype_array=explode("/",$filetype); 
        
        	$file_type_val=strtolower($filetype_array[1]);
        
        	if($ffilesize != 0)
        	{
        		if (($file_type_val == "jpeg" ) || ($file_type_val == "png") || ($file_type_val == "jpg" ) ||  ($file_type_val == "gif" ) || ($file_type_val == "bmp")|| ($file_type_val == "ico") ) //Checking whether the file is an image or not
        		{
        			
        			if($result!=false)
        			{
        				$savelogo="true";
        			}
        		}
        		else
        		{
        			$savelogo="false";
        			$error_flag ="1";
        		}
        		
        	}
        	else
        	{
        		$savelogo="false";
        		if($filename != "") 
        			$error_flag ="2";
        	}
        		
        	$errorCode =  $_FILES[$tmp_value]['error'];
        	if($errorCode == 4)
        	{
        	  	$savelogo="false";	    	
        		$errorcode="";
        		$error_flag="5";
        		$nologo_specified="true";
        	}
        	else if($errorCode == 2)
        	{
        	   	$error_flag ="3";
        	   	$savelogo="false";	    	
        		$nologo_specified="false";
        	}
        	else if($errorCode == 3 )
        	{
        		$error_flag ="4";
          		$savelogo="false";
        		$nologo_specified="false";
        	}
            $file_name=$_FILES["binFile"]["name"];
              $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
              $encode=mb_detect_encoding($file_name, $arr); 
              
            
              if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
              {
                //获取系统类型，如果是非windows系统则不用修改编码格式
                
              }
             else if($encode=='UTF-8')
              {
                $file_name=iconv('UTF-8','gb2312',$file_name);
              }
            
        	if($savelogo=="true")
        	{	
        		move_uploaded_file($_FILES[$tmp_value]["tmp_name"],$uploaddir.$filename); 
        	}
            
            if ($tmp_value == 'logoname')
            {
                $logoname = $filename;      
                //读取公司id	
                $sql = 'select * from ld_organizationdetails';
                $result = $adb->pquery($sql, array());
                $organization_id = $adb->query_result($result,0,'organization_id');
                //自定义logo时，数据库里更新的文件名
                $sql = 'update ld_organizationdetails set logoname = ? where organization_id = ?';
                $adb->pquery($sql, array($logoname,$organization_id));
            }
            elseif ($tmp_value== 'minilogoname')
            {
                $minilogoname = $filename; 
                //读取公司id	
                $sql = 'select * from ld_organizationdetails';
                $result = $adb->pquery($sql, array());
                $organization_id = $adb->query_result($result,0,'organization_id');
                //自定义小logo时，数据库里更新的文件名
                $sql = 'update ld_organizationdetails set small_logoname = ? where organization_id = ?';
                $adb->pquery($sql, array($minilogoname,$organization_id)); 
            }
            elseif ($tmp_value == 'backgroundbg')
            {
                $background_filename = $filename;
            }
        }	
    }

	if($saveflag=="true")
	{
	   
	       
           $str=" <?php \n";
           $str.=' $global_logininfo=array( ';
	       foreach($global_logininfo as $key=>$item)
           {
                  $str.="  '$key'=>array('zh'=>'".$item['zh'].'\','."'en'=>'".$item['en']."'";
                  
                 if(array_key_exists("isshow",$item))
                 {
                    $str.=",'isshow'=>";
                    
                    if($key=='autheninfo'&&$reg->getauthenshow()=='no')
                    {
                        $str.="'yes'";
                    }else if(!array_key_exists('chk_'.$key,$_REQUEST)){
                        $str.="'".$item['isshow']."'";
                    }
                    else if($_REQUEST['chk_'.$key])
                    {
                        $str.="'yes'";
                    }
                    else
                    {
                         $str.="'no'";
                    }
                 }
                 
                 if(array_key_exists("isedit",$item)&&$item['isedit']=='yes')
                 {
                    $str.=",'isedit'=>'".$item['isedit']."'";
                    if($key=='backgroundbg')
                    {
                        $file = $item['content'];
                        if(isset($_FILES['backgroundbg']))
                                $str.=",'content'=>'dataCache/test/logo/".$background_filename."'";
                        else{
                            if(strpos($file,'test/logo')==0&&strpos($file,'dataCache/test/logo')!=0){
                                $file = str_replace('test/logo','dataCache/test/logo',$file);
                            }
                            $str.=",'content'=>'".$file."'";
                        }
                                
                    }
                    else
                    {
                        $content=$_REQUEST['txt_'.$key];
                        if($key=='weixin'){
                            //duan '安装企业微信'不在设置中显示，所以获取修改前的值
                            $content = $item['content'];
                        }
                        $str.=",'content'=>'".$content."'";
                    }
                 }
                else  if($key=='backgroundbg')
                    {
                        //背景图片永远可以编辑
                         $str.=",'isedit'=>'".$item['isedit']."'";
                      
                        $file = $item['content'];
                        if(isset($_FILES['backgroundbg']))
                                $str.=",'content'=>'dataCache/test/logo/".$background_filename."'";
                        else{
                            if(strpos($file,'test/logo')==0&&strpos($file,'dataCache/test/logo')!=0){
                                $file = str_replace('test/logo','dataCache/test/logo',$file);
                            }
                            $str.=",'content'=>'".$file."'";
                        }
                                
                }
                 else
                 {
                    $str.=",'content'=>'".$item['content']."'";
                 }
                 $str.="),\n\n";
                 
           }
           if(!array_key_exists('upgradeexplain',$global_logininfo))
           {
                $str.="  'upgradeexplain'=>array('zh'=>'发版说明','en'=>'发版说明','isshow'=>";
                if($_REQUEST['chk_upgradeexplain'])
                {
                        $str.="'yes'";
                }
                else
                {
                         $str.="'no'";
                }
                $str.=",'content'=>'".$_REQUEST['txt_upgradeexplain']."'";
                $str.=",'issedit'=>'yes'";
                 $str.="),\n\n";
           }
           if(!array_key_exists('resolution',$global_logininfo))
           {    //duan PC端登录效果优化，增加浏览器分辨率建议    
                $str.="  'resolution'=>array('zh'=>'建议浏览器分辨率1280*1024以上',";
                $str.="'en'=>'It is recommended that the browser resolution be above 1280*1024','isshow'=>";
                $str.="'yes'";
                $str.=",'content'=>''";
                $str.=",'issedit'=>'yes'";
                 $str.="),\n\n";
           }
           $str.=");\n\n";
    
    
	}	
    $str.=PHP_EOL;
    foreach($global_loginpage_url as $index=>$content)
    {
        $str.=' $global_loginpage_url['.$index.']=array("zh"=>"'.$content['zh'].'","en"=>"'.$content['en'].'"';
        $str.=",'isshow'=>";
                    if($_REQUEST['pageurl_chk_isshow_'.$index])
                    {
                        $str.="'yes'";
                    }
                    else
                    {
                         $str.="'no'";
                    }
                 
               
         $str.=",'isedit'=>'".$content['isedit']."'";
                   
        $str.=",'content'=>'".$_REQUEST['pageurl_txt_content_'.$index]."'";
        $str.=",'url'=>'".$_REQUEST['pageurl_txt_url_'.$index]."'";         
                 $str.=");".PHP_EOL;
    }
    $str.=PHP_EOL;
    $str.='   $global_welcome=array("zh"=>"'.$global_welcome['zh']
                    .'","en"=>"'.$global_welcome['en'] ;
                    
   if($languageType=='zh')
   {
        $str.='","after_zh_content"=>"'.$_REQUEST['txt_login_welcome'];
        
        if(array_key_exists('after_en_content',$global_welcome))
            $str.='","after_en_content"=>"'.$global_welcome['after_en_content'];
        else
            $str.='","after_en_content"=>"'.$global_welcome['en'];
   }
   else
   {
        $str.='","after_en_content"=>"'.$_REQUEST['txt_login_welcome'];
        if(array_key_exists('after_zh_content',$global_welcome))
            $str.='","after_zh_content"=>"'.$global_welcome['after_zh_content'];
        else
            $str.='","after_zh_content"=>"'.$global_welcome['zh'];
   }
   $str.='","updateexplain"=>"'.$global_welcome['updateexplain']
                    .'","showloginweixinbtn"=>"'.$global_welcome['showloginweixinbtn']
                    .'","beginyear"=>"'.$global_welcome['beginyear'].'");';
                    
    $str.=PHP_EOL;
    $str.='$global_login_wxbtn=array("zh"=>"企业微信登录","en"=>"WeChat login",';
    if($_REQUEST['chk_login_wxbtn_show'])
        $str.='"isshow"=>"yes",';
    else
        $str.='"isshow"=>"no",';
    
    if($languageType=='zh')
    {
        $str.='"after_zh_content"=>"'.$_REQUEST['txt_login_wxbtn'].'",';
        if($global_login_wxbtn['after_en_content']!='')
        {
            $str.='"after_en_content"=>"'.$global_login_wxbtn['after_en_content'].'"';
        }
    }
    else
    {
        $str.='"after_en_content"=>"'.$_REQUEST['txt_login_wxbtn'].'",';
        if($global_login_wxbtn['after_zh_content']!='')
        {
            $str.='"after_zh_content"=>"'.$global_login_wxbtn['after_zh_content'].'"';
        }
    }
    $str.=");".PHP_EOL;
    $str.="\n\n?>";
    

file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',$str);
$_REQUEST['diony']='yes';
if(function_exists('opcache_invalidate'))//edit:can 20210427 45681: （http://175.27.243.52:85/crm [^]）客户问题（刘傲），系统设置->登陆界面自定义设置，编辑参数保存后，需要刷新多保存几遍界面才生效
        opcache_invalidate(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',true);
ConvertTojsonString(1,array(),'success');

//header("Location:index.php?module=Settings&action=LoginSettings&parenttab=Settings&blockidsetting=6&fieldidsetting=72")
?>