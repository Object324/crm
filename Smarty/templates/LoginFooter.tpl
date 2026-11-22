{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div class="footer">
    <p>


        {if $LANGUAGETYPE eq 'zh'}
           
            授权于：{$SOFTCOMPANY}&nbsp;&nbsp;&nbsp;&nbsp;序列号：{$SERIALNUM}&nbsp;&nbsp;&nbsp;&nbsp;软件版本：{$SOFTVERSION}
        {else}
           
            Authorize:{$SOFTCOMPANY}&nbsp;&nbsp;&nbsp;&nbsp;Serial Number:{$SERIALNUM}&nbsp;&nbsp;&nbsp;&nbsp;Version:{$SOFTVERSION}
        {/if}
        <br />
        {if $COMMON_VERSIONINFO.aboutweb neq ''}
        <a href="{$COMMON_VERSIONINFO.aboutweb}" target="_blank">{if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.aboutweblabel}{else}{$COMMON_VERSIONINFO.EN_aboutweblabel}{/if}</a>|
        {/if}
		{if $LINGDANG eq 'yes'}
			<!--<img src="dataCache/test/logo/westore.png" width="18" height="18" class="val_m" /><a href="{$COMMON_VERSIONINFO.westore}" target="_blank">{$WESTORE.$LANGUAGETYPE}</a>|-->
		{else}
			{if $COMMON_VERSIONINFO.iosdownload neq ''}
			<img src="dataCache/test/logo/iPhone.png" class="val_m" /><a href="{$COMMON_VERSIONINFO.iosdownload}" target="_blank">iPhone</a>
			{/if}
			{if $COMMON_VERSIONINFO.androiddownload neq ''}
			<img src="dataCache/test/logo/android_img.jpg" class="val_m" /><a href="{$COMMON_VERSIONINFO.androiddownload}">Android</a>|
			{/if}
		{/if}
        
            <a href="javascript:void(0);" onclick="getRootPath();">{if $LANGUAGETYPE eq 'zh'}授权信息{else}Authorization Information{/if}</a>|
        
        {if 'oem_crm'|@getCommonVersion eq 'no'}
            <a href="javascript:void(0);" onclick="openWechatURL();">{if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.Install_Weixinlabel}{else}{$COMMON_VERSIONINFO.EN_Install_Weixinlabel}{/if}</a>|
        {/if}
        <a href="javascript:void(0);" onclick="clearcache('{$TOKEN}');">{if $LANGUAGETYPE eq 'zh'}清除缓存{else}Clear Cache{/if}</a>
        <br />
        {if $LANGUAGETYPE eq 'zh'}版权所有{else}Copyright{/if} {$SOFTINFO.BeginYear}~{$smarty.now|date_format:'%Y'}  
            {if $LANGUAGETYPE eq 'zh'}
                {$SOFTINFO.CopyRight}
            {else}
                {$SOFTINFO.EN_CopyRight}
            {/if}
    </p>
</div>
</body>

<script language="javascript">

{literal}
function clearcache(num)
{
     $.ajax({
   
    url: 'modules/Cache/unsetCache.php',
    data:{'ajax':true,'num':num},
    dataType:'json',
    type:"POST",
    success: function(data)
    {
         
        if(document.forms['DetailView'].languageType==undefined||document.forms['DetailView'].languageType[0].checked==true){
            
                var objdiv_title = 	'温馨提示';//标题
                var confirm_str = '清除成功';

                getJsScript('include/js/ldcrm.base.js',function(){
                    //创建提示弹出层
                    create_divobj('clearcache_reminder',objdiv_title,confirm_str,'no','','yes');
                    ld('#clearcache_reminder .E_pop_tit .E_ptita').html(objdiv_title);
                    ld('#clearcache_reminder .E_ptitc').css('display','none');
                    ld('#clearcache_reminder .E_pbtn .E_pbtnok').val('确定');
                    ld('#clearcache_reminder .E_pbtn .E_pbtncancel').val('取消');
                });
                return ;
        }
        else{
                var objdiv_title = 	'Warm prompt';//标题
                var confirm_str = 'Clear success!';

                getJsScript('include/js/ldcrm.base.js',function(){
                    //创建提示弹出层
                    create_divobj('clearcache_reminder',objdiv_title,confirm_str,'no','','yes');
                    ld('#clearcache_reminder .E_pop_tit .E_ptita').html(objdiv_title);
                    ld('#clearcache_reminder .E_ptitc').css('display','none');
                    ld('#clearcache_reminder .E_pbtn .E_pbtnok').val('Confirmed');
                    ld('#clearcache_reminder .E_pbtn .E_pbtncancel').val('Cancel');
                });
                return ;
        }
    }
    }
    );
}
function getRootPath(){
    //获取当前网址，如： http://localhost:8088/crm/index.php
    var curPath=window.document.location.href;
    //获取主机地址之后的目录，如： crm/index.php
    var pathName=window.document.location.pathname.split('index.php');
	var pos=curPath.indexOf(pathName[0]);
    //获取主机地址，如： http://localhost:8088
    var localhostPaht=curPath.substring(0,pos);
    var url=localhostPaht+pathName[0];
	if(url.substr(url.length-1,1) == '/'){
		window.open(url+'index.php?action=isReg');
	}else{
		window.open(url+'/index.php?action=isReg');
	}
    
	
   /* //获取带"/"的项目名，如：/crm
    var projectName=pathName.substring(0,pathName.substr(1).indexOf('/')+1);
    var url=localhostPaht+projectName;
    window.open(url+'/index.php?action=isReg');*/
}
//安装微信版本，客户001跳转到客户001网站首页，其他跳转到51mis上面的网页
function openWechatURL(){
    var urlPath = window.location.host;//获取当前网页主机地址
    if(urlPath.indexOf("kehu001") > -1){
        window.open('http://www.kehu001.com');
    }else{
        window.open('http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
    }
}
{/literal}
</script>