<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);

require_once(globalStatic::$root_directory."SessionInfo.php");




//左右结构展开和收缩后点击菜单
if(isset($_REQUEST['bodywidth']))
    $_SESSION['bodywidth']=$_REQUEST['bodywidth'];

//if(file_exists(globalStatic::$root_directory.'LoginSettingsInfo_OEM.php'))
//{
//    
//    require_once(globalStatic::$root_directory."LoginSettingsInfo_OEM.php");
//    createLoginParam();        
//
//}


if(file_exists(globalStatic::$root_directory."ProductInfo_OEM.php"))
{
    require_once(globalStatic::$root_directory."ProductInfo_OEM.php");
  
    
    require_once(globalStatic::$root_directory."ProductInfo.php");
       $companyshort=iconv('gbk','utf-8',$oem_product_info['companyshort']);//替换productinfo.php中"灵当软件"
        $productname=iconv('gbk','utf-8',$oem_product_info['productname']);//替换zh_cn_version.lang.php“灵当CRM""
        $softslogan=iconv('gbk','utf-8',$oem_product_info['softslogan']);//替换zh_cn_version.lang.php“客户关系管理专家""
         $productinfostr="  <?php \n";
         $productinfostr.=' $common_version=array('."\n";
         $productinfostr.= "'lblversion'=>'".$common_version['lblversion']."',\n";
         $productinfostr.="'appabout'=>'".str_replace("灵当软件",$companyshort,$common_version['appabout'])."'\n);" ;
          
        $productinfostr.="?>";
        
        if(file_exists(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
            $tmplanguages=file_get_contents(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php");
        }else{
            $tmplanguages=file_get_contents(globalStatic::$root_directory."include/language/zh_cn_version.lang.php");
        }
        
       // $tmplanguages=iconv('gbk','utf-8',$tmplanguages);
        
        $tmplanguages=str_replace("灵当CRM",$productname,$tmplanguages);
        $tmplanguages=str_replace("客户关系管理专家",$softslogan,$tmplanguages);
       
        file_put_contents(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php",$tmplanguages);
        
       file_put_contents(globalStatic::$root_directory."ProductInfo.php",$productinfostr);
       @unlink(globalStatic::$root_directory."ProductInfo_OEM.php");
    
}

 function createLoginParam($isconvert='yes')
{
    global $global_logininfo;
    global $global_welcome;
    global $global_loginpage_url;
    //duan 2022-4-20 从云之家单点登录时，全局变量为空，需要重新获取
 
    if(empty($global_logininfo)||empty($global_loginpage_url)||empty($global_welcome)){
		require(globalStatic::$root_directory."dataCache/Login/LoginSettingsInfo.php");
	}
    if(stripos($global_welcome['updateexplain'],'http://www.51mis.com/other/up')!==false)
    {
        $global_welcome['updateexplain']='http://71mis.com/download/update/';
    }
    $str=" <?php \n";
    if($isconvert=='yes')
    {
        
    
                   $str.=' $global_logininfo=array( ';
        	       foreach($global_logininfo as $key=>$item)
                   {
                          $str.="  '$key'=>array('zh'=>'".iconv('gbk','utf-8',$item['zh']).'\','."'en'=>'".iconv('gbk','utf-8',$item['en'])."'";
                          
                          if(array_key_exists('isshow',$item))
                           {
                             $str.=",'isshow'=>";
                          
                                 $str.="'".$item['isshow']."'";
                            
                           }
                         
                        if(array_key_exists('isedit',$item))
                           {
                             $str.=",'isedit'=>";
                          
                                 $str.="'".$item['isedit']."'";
                            
                           }
                            $str.=",'content'=>'".iconv('gbk','utf-8',$item['content'])."'";
                         
                           $str.="),\n\n";
                         
                   }
                   $str.=");\n\n";
        
        		
             $str.='   $global_welcome=array("zh"=>"'.iconv('gbk','utf-8',$global_welcome['zh'])
                        .'","en"=>"'.iconv('gbk','utf-8',$global_welcome['en'])
                        .'","updateexplain"=>"'.$global_welcome['updateexplain']
                        .'","showloginweixinbtn"=>"'.$global_welcome['showloginweixinbtn']
                        .'","beginyear"=>"'.$global_welcome['beginyear'].'");';
             if(!is_array($global_loginpage_url))
             {
                require_once("globalConfig/LoginPageSetURL.php");
                
             }
             $str.=PHP_EOL;
             foreach($global_loginpage_url as $index=>$content)
             {
                $str.=' $global_loginpage_url['.$index.']=array("zh"=>"'.iconv('gbk','utf-8',$content['zh']).'","en"=>"'.iconv('gbk','utf-8',$content['en'])
                                .'","isshow"=>"'.$content['isshow'].'","isedit"=>"'.$content['isedit'].'","url"=>"'.$content['url'].'","content"=>"'.iconv('gbk','utf-8',$content['content']).'");'.PHP_EOL;
                                
             }
        }
        else
        {
                 $str.=' $global_logininfo=array( ';
            	       foreach($global_logininfo as $key=>$item)
                       {
                              $str.="  '$key'=>array('zh'=>'".$item['zh'].'\','."'en'=>'".$item['en']."'";
                              
                              if(array_key_exists('isshow',$item))
                               {
                                 $str.=",'isshow'=>";
                              
                                     $str.="'".$item['isshow']."'";
                                
                               }
                             
                            if(array_key_exists('isedit',$item))
                               {
                                 $str.=",'isedit'=>";
                              
                                     $str.="'".$item['isedit']."'";
                                
                               }
                                $str.=",'content'=>'".$item['content']."'";
                             
                               $str.="),\n\n";
                             
                       }
                       $str.=");\n\n";
            
            		
                 $str.='   $global_welcome=array("zh"=>"'.$global_welcome['zh']
                            .'","en"=>"'.$global_welcome['en'];
                            
                 if(array_key_exists('after_zh_content',$global_welcome))
                    $str.='","after_zh_content"=>"'.$global_welcome['after_zh_content'];
                 else
                    $str.='","after_zh_content"=>"'.$global_welcome['zh'];
                    
                 if(array_key_exists('after_en_content',$global_welcome))
                    $str.='","after_en_content"=>"'.$global_welcome['after_en_content'];
                 else
                    $str.='","after_en_content"=>"'.$global_welcome['zh'];
                            
                  $str .='","updateexplain"=>"'.$global_welcome['updateexplain']
                            .'","showloginweixinbtn"=>"'.$global_welcome['showloginweixinbtn']
                            .'","beginyear"=>"'.$global_welcome['beginyear'].'");';
                  
                 $str.=PHP_EOL;
                 $str.='$global_login_wxbtn=array("zh"=>"企业微信登录","en"=>"WeChat login",';
                 $str.='"isshow"=>"'.$global_login_wxbtn['isshow'];
                 
                 if(array_key_exists('after_zh_content',$global_login_wxbtn))
                    $str.='","after_zh_content"=>"'.$global_login_wxbtn['after_zh_content'];
                 else
                    $str.='","after_zh_content"=>"'.$global_login_wxbtn['zh'];
                    
                 if(array_key_exists('after_en_content',$global_login_wxbtn))
                    $str.='","after_en_content"=>"'.$global_login_wxbtn['after_en_content'];
                 else
                    $str.='","after_en_content"=>"'.$global_login_wxbtn['zh'];
                 $str .= '");';
                 
                 if(!is_array($global_loginpage_url))
                 {
                    require_once("globalConfig/LoginPageSetURL.php");
                    
                 }
                 $str.=PHP_EOL;
                 foreach($global_loginpage_url as $index=>$content)
                 {
                    $str.=' $global_loginpage_url['.$index.']=array("zh"=>"'.$content['zh'].'","en"=>"'.$content['en']
                                    .'","isshow"=>"'.$content['isshow'].'","isedit"=>"'.$content['isedit'].'","url"=>"'.$content['url'].'","content"=>"'.$content['content'].'");'.PHP_EOL;
                                    
                 }
            
        }
        $str.="\n\n?>";
        file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',$str);
        @unlink(globalStatic::$root_directory."LoginSettingsInfo_OEM.php");
}
function isLoginCrm()
{
    global $root_directory,$application_unique_key;
    
   
        if($_REQUEST['module']!='Users'&&$_REQUEST['file']!='CheckPwd')
       {
            
             if($_SESSION['USERPMLogin']=='yes')
            {
                //37132:PC端：设置密码严格管理，当密码不符合严格管理要求，提示页面点击浏览器的返回按钮“<-”就可以登录进入系统
              //37144:开启“登录时启用手机短信验证”参数，用户登录时点击登录跳转页面不对(不是这个导致，是跳转到登录界面后，会提示升级，升级后跳转不正确)
                return 'no';
                
            }
       }


    if(issetSession("authenticated_user_id") && (issetSession("app_unique_key") && getSession("app_unique_key") == $application_unique_key))
    {
    
    //edit:can 13229: 同一个apache虚拟目录发布的CRM，用户登录后，只要知道其他用户的虚拟目录，就能够绕过密码，进入其他用户的CRM系统中。
       if(getSession($root_directory)=='lingdang')
       {
            if($_REQUEST['pc_puyoung_loginajax']=='yes')
            {
                return 'no';
                
            }
            return "yes";

       }
   }
   return "no";
   
}

function setGLobalURLSmarty($smarty)
{
    global $lingdang_cdn_version;
    global $global_minversin;
    if(!isset($smarty))
    {
        return ;
    }
    if(!file_exists("FrontMinVersion.php"))
    {
        file_put_contents("FrontMinVersion.php","<?php ".PHP_EOL.' $global_minversin="1";'.PHP_EOL."?>");
    }
    require_once(globalStatic::$root_directory."FrontMinVersion.php");
     $smarty->assign("GLOBALMINVERSION",$global_minversin);
    if(file_exists(globalStatic::$root_directory."globalConfig/global_crm_server_url.php"))
    {
        global $global_js_url;
        global $global_image_url;//zxm @date:2024/11/5 @reason: 系统图片（非用户上传图片访问cdn地址）
        global $global_crm_url;
        global $global_commonurl;
        global $global_css_url;
        require_once(globalStatic::$root_directory."globalConfig/global_crm_server_url.php");
        //zxm @date:2024/11/5 @reason: 系统图片（非用户上传图片访问cdn地址）imageurl
        $smarty->assign("IMAGEURL", getGlobalImageUrl());

        if(empty($global_js_url)||!isset($global_js_url))
        {
            $smarty->assign("JSURL","");
            $smarty->assign("CSSURL","");
            
        }
        else
        {
            if(substr($global_js_url,"-1")!="/")
            {
                $global_js_url.="/";
            }
            if(strtolower(substr($global_js_url,"0",7))!="http://"&&strtolower(substr($global_js_url,"0",8))!="https://")
            {
                $global_js_url="http://".$global_js_url;
            }
            $tmpglobal_js_url=$global_js_url.$lingdang_cdn_version.'/';
            if(empty($global_css_url))
            {
                $global_css_url="http://71mis.cn/crm/";
            }
            global $currentModule;
          
            if(substr($global_css_url,"-1")!="/")
            {
                $global_css_url.="/";
            }
            if(strtolower(substr($global_css_url,"0",7))!="http://"&&strtolower(substr($global_css_url,"0",8))!="https://")
            {
                $global_css_url="http://".$global_css_url;
            }
            $tmpglobal_css_url=$global_css_url.$lingdang_cdn_version.'/';
           
            if(substr($global_crm_url,"-1")!="/")
            {
                $global_crm_url.="/";
            }
            
            
            if(substr($global_commonurl,"-1")!="/")
            {
                 $global_commonurl.="/";
            }
             if(strtolower(substr($global_commonurl,"0",7))!="http://"&&strtolower(substr($global_commonurl,"0",8))!="https://")
            {
                $global_commonurl="http://".$global_commonurl;
            }
            if($smarty)
            {
                 $smarty->assign("JSURL",$tmpglobal_js_url);
                 $smarty->assign("CSSURL",$tmpglobal_css_url);
                 $smarty->assign("CRMCOMMONURL",$global_commonurl);
            }
        }
    }
    return array('jsurl'=>$jsurl,'crmcommonurl'=>$global_commonurl);
}
//获取对应参数
function getCommonVersion($method){
	/*include($root_directory.'include/language/zh_cn_version.lang.php');
	return $common_version[$method];*/
    //38705: 系统设置>登录界面自定义设置>版权所有：当版权所有中没有“上海灵当”字样的情况下，“帮助”按钮
    // BUG0054262  隐藏“版权所有”时，也应该增加此控制
	include(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php');
	if($global_logininfo['copyrightinfo']['isshow'] == 'yes' && strpos($global_logininfo['copyrightinfo']['content'],'上海灵当') !== false){
		return 'no';
	}else{
		return 'yes';
	}
}
function convert_req(&$req)
{
    foreach($req as $k=>$v)
    {
        if(is_array($v))
        {
            convert_req($req[$k]);
        }
        else
        {
            if(!is_string($v))continue;
            $req[$k]= trim($v); //$s为需要过滤的参数
            //31495: 创建跟进记录时，内容中有“<”符号，后面的内容填了后保存后全没了
            // $req[$k]= strip_tags($req[$k],""); //清除HTML如等代码
            // $req[$k]= str_replace("\n", "", str_replace(" ", "", $req[$k]));//去掉空格和换行
            $v  = str_replace("\t","",$v); //去掉制表符号

            $v= str_replace("../","",$v); //去掉"../"
            if($k=='pageto_module'||$k=='pageto_action'||$k=='pageto_record'||$k=='frommodule'||$k=='pageto_menufile')
            {
                $v= strip_tags($v,""); //清除HTML如等代码
                $v=addslashes($v);
            }
            $req[$k]= trim($v);
        }
    }
}


 function stripslashes_checkstrings($value){
        if(is_string($value)){
                return stripslashes($value);
        }
        return $value;

 }
require_once("include/cls_UrlEncryptyJudge.php");
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($_REQUEST);
 if( function_exists("get_magic_quotes_gpc")&& get_magic_quotes_gpc() == 1){
        $_REQUEST = array_map("stripslashes_checkstrings", $_REQUEST);
        $_POST = array_map("stripslashes_checkstrings", $_POST);
        $_GET = array_map("stripslashes_checkstrings", $_GET);

}
convert_req($_REQUEST);
foreach($_POST as $k=>$v)
{
    //富文本  过滤
  $_POST[$k]=RemoveXSS($_POST[$k]);
    
}
 
/**
 * 过滤js代码
 * */
function RemoveXSS($val) 
{ 
    $str=preg_replace("/<(script.*?)>(.*?)<(\/script.*?)>/si","",$val); //过滤script标签
    $str=preg_replace("/<(\/?script.*?)>/si","",$str); //过滤script标签
    $str=preg_replace("/javascript/si","Javascript",$str); //过滤script标签
    $str=preg_replace("/vbscript/si","Vbscript",$str); //过滤script标签
    $str=preg_replace("/on([a-z]+)\s*=/si","On\\1=",$str); //过滤script标签
    $str = preg_replace( "@<iframe(.*?)</iframe>@is", "", $str );
 //   $str = preg_replace( "@<style(.*?)</style>@is", "", $str );
    $str = preg_replace( "@document.write@is", "", $str );
    //$str = preg_replace( "/eval[ ]*/si", "", $str);
   //$str =preg_replace("/<(\/?img.*?)>/si","",$str);

    return $str;
}  


//判断当前浏览器是否是低版本ie浏览器
function checkBrowserIsSupport(){
    $agent=$_SERVER["HTTP_USER_AGENT"];

  
    if(strpos($agent,'MSIE') || strpos($agent,'Trident')){
        if(preg_match('/Trident\/(\d+)\..*/i', $agent, $regs)){
            if($regs[1]>=7) return 'yes';
        }
        return 'no';
    }
    return 'yes';
}

if($_REQUEST['clean_cache']=='yes')
{
    require_once("modules/Cache/index.php");
    if(function_exists('opcache_invalidate'))
    {
        opcache_list_file(globalStatic::$root_directory);
    }
}

?>