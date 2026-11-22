<!DOCTYPE html PUBLIC "-//W3C//DTD html 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset={$LBL_CHARSET}">
{if $LANGUAGETYPE eq 'zh'}
<title>{$VERSIONINFO.LBL_BROWSER_TITLE}</title>
{else}
<title>{$VERSIONINFO.EN_LBL_BROWSER_TITLE}</title>
{/if}
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link type="text/css" href="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/crm/login/css/login_new.css" rel="stylesheet" />
<link rel="stylesheet" href="login/css/popup_new.css" type="text/css" />
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/crm/login/js/ldcrm.base.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/crypto-js.min.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
<script type="text/javascript" language="JavaScript">
var ld = $;
var language='{$LANGUAGETYPE}';
var global_js_url ='https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/crm/';
</script>

</head>
<body  onkeyup="keyLogin(event);">
<div class="header">
      
    <div class="row">
    
        {if $PALYBOX eq 'yes'}
			{if  $LANGUAGETYPE eq 'zh'}
			<div class="tips" style="margin:10px 10px 0 0; position: fixed;top:0px;right:0px;height:50px; color:#F00; text-align: right;">
				您的浏览器可能不支持或只支持部分软件功能，为了更好地体验，建议您使用这些浏览器：
				<a href="http://www.firefox.com.cn/download/" target="_blank"><img title="火狐" src="themes/images/browser/Firefox.jpg"></a>
				<a href="http://pcr11.pc6.com/rm/chrome.zip" target="_blank"><img title="谷歌" src="themes/images/browser/Chrome.jpg"></a>
				<a href="http://windows.microsoft.com/zh-cn/internet-explorer/ie-11-worldwide-languages" target="_blank"><img title="IE8及其以上" src="themes/images/browser/IE8.jpg"></a>
				<a href="http://www.maxthon.cn/" target="_blank"><img title="傲游" src="themes/images/browser/Maxthon.jpg"></a>
				<a href="http://www.opera.com/zh-cn/computer/windows" target="_blank"><img title="欧朋" src="themes/images/browser/Opera.jpg"></a>
				<a href="http://se.360.cn/" target="_blank"><img title="360(兼容模式)" src="themes/images/browser/360.jpg"></a>
				<a href="http://ie.sogou.com/" target="_blank"><img title="Sogou(兼容模式)" src="themes/images/browser/Sogou.jpg"></a>       
			</div>
			{else}
			<div class="tips" style="margin:10px 10px 0 0; position: fixed;top:0px;right:0px;height:50px; color:#F00; text-align: right;">
				Your browser may not support or support only part of the software functions, in order to obtain better experience, it is recommended that you use the following browser to access：
				<a href="http://www.firefox.com.cn/download/" target="_blank"><img  title="Firefox" src="themes/images/browser/Firefox.jpg"></a>
				<a href="http://pcr11.pc6.com/rm/chrome.zip" target="_blank"><img title="Chrome" src="themes/images/browser/Chrome.jpg"></a>
				<a href="http://windows.microsoft.com/zh-cn/internet-explorer/ie-11-worldwide-languages" target="_blank"><img title="IE8 And above" src="themes/images/browser/IE8.jpg"></a>
				<a href="http://www.maxthon.cn/" target="_blank"><img title="Maxthon" src="themes/images/browser/Maxthon.jpg"></a>
				<a href="http://www.opera.com/zh-cn/computer/windows" target="_blank"><img title="Opera" src="themes/images/browser/Opera.jpg"></a>
				<a href="http://se.360.cn/" target="_blank"><img title="360(compatibility mode)" src="themes/images/browser/360.jpg"></a>
				<a href="http://ie.sogou.com/" target="_blank"><img title="Sogou(compatibility mode)" src="themes/images/browser/Sogou.jpg"></a>
			</div>
			{/if}
        {/if}
        
        <div class="rig_bar" >
            {if $COMMON_VERSIONINFO.companyurllabel neq ''}
            {if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.companyurllabel}{else}{$COMMON_VERSIONINFO.EN_companyurllabel}{/if}
                
            {/if}
            {if $COMMON_VERSIONINFO.companyurllabel neq '' && $COMMON_VERSIONINFO.apptellabel neq '' }
                |
            {/if}
            {if $COMMON_VERSIONINFO.apptellabel neq ''}
                <span>{if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.apptellabel}{else}{$COMMON_VERSIONINFO.EN_apptellabel}{/if}</span>
            {/if}
              {if $COMMON_VERSIONINFO.QQ neq '' }
                | 
                <span>
                  <!-- WPA Button Begin -->
                  <script charset="utf-8" type="text/javascript" src="http://wpa.b.qq.com/cgi/wpa.php?key=XzkzODA3MTY5Nl80Nzk4MjlfNDAwODg4NTExMF8"></script>
                  <!-- WPA Button End -->
                </span>
                <style type="text/css">
                  {literal}
                    .rig_bar span iframe {margin-bottom: -6px;}
                  {/literal}
                </style>
            {/if}
        </div>
    </div>
</div>
	