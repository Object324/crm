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
{include file="LoginHeaderkh001.tpl"}
<div class="container">
    <div class="content">
    	<div class="log_left">
        	
        </div>
        <div class="log_rig">
            <div class="login span8 ml0">
                <form action="index.php" method="post" name="DetailView" id="form_login" class="form_log">
                    <input  type="hidden" name="sessionrand" value="{$SESSIONRAND}" id="sessionrand"/>
                    <input type="hidden" name="module" value="Users" />
					<input type="hidden" name="action" value="Authenticate" />
					<input type="hidden" name="return_module" value="Users" />
					<input type="hidden" name="return_action" value="Login" />
                    <input type="hidden" name="login_method" value="{$LOGINMETHOD}" />
                    <input type="hidden" id="code" name="code" value="{$CODENUM}"/>
					<input type="hidden" id="bodywidth" name="bodywidth" value="">
                    {if $LANGUAGETYPE eq 'zh'}
                        <div class="login-info" style="padding-bottom:13px" onkeydown="tabchange(event)">
                            <div class="valm_a"> 
                               <div class="valm_b">
                                    <div class="valm_c" {if $ENORZH neq 'yes'}style="padding-top:25px;"{/if}>
                                        {if $ENORZH eq 'yes'}
                                            <div style="height:53px;">
                                                <span class="val_m" style="padding-right:20px;line-height:53px;">语　言</span>
                                                <input tabindex="5" type="radio" class="val_m" name="languageType" value="zh" checked="true" onclick="changeLangage(this)"/>
                                                <span class="val_m" style="padding-right:30px;line-height:53px;">中文</span>
                                                <input tabindex="6" type="radio" class="val_m" name="languageType" value="en" onclick="changeLangage(this)"/>
                                                <span class="val_m" >English</span>
                                            </div>
                                        {/if}
                                        {if $NOREGISTER eq 1}                                       
                                        <div  {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} class="disable account"{else}class="account"{/if}>
                                            <span></span>
                                            <input type="text"   maxlength="100" tabindex="1" {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} disabled="true" class="disableInput" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} id="login_user_name" name="login_user_name" value="{$LOGINUSERNAME}" placeholder="用户名" onblur="checkForm(this,name,'zh');" autocomplete="off"/>
                                        </div>
                                        {else}
                                        <div class="disable account" >
                                            <span></span>
                                            <input class="disableInput"  {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} type="text" maxlength="100" tabindex="1" name="login_user_name" value="admin" style="-webkit-box-shadow:none !important;"/>
                                        </div>
                                        {/if}
                                        <div class="errtip" id="error_name"></div>
                                        <div {if $EXPIREDTIP eq 'yes'} class="disable password"{else}class="password"{/if}>
                                            <span></span>
                                            <input type="password" tabindex="2" id="login_password" {if $EXPIREDTIP eq 'yes'} disabled="true" class="disable" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} name="login_user_password" value="" placeholder="密码" onblur="checkForm(this,name,'zh');" autocomplete="off" />
                                        </div>
                                        {*<div class="errtip" id="error_pwd"></div>*}
                                        <span id="capsLockHint" style="display:none;font-size:12px;padding:7px 10px;">大写状态开启</span>
                                        {if $CODE neq ''}
                                        <div id="yzm_value" class="token">
                                            <input type="text" tabindex="3" id="secutity_code" name="secutity_code" value="" placeholder="验证码" onblur="checkForm(this,name,'zh');"/>
                                            <img id="img_codepicture" src="picture.php" onclick="yzm_change(this);" class="val_m img_b" style="margin-left:4px" width="79" height="29" />
                                            <a href="javascript:void(0);" style="color:#2E7ECD" onclick="yzm_change(this);">换一张</a>
                                        </div>
                                        <div class="errtip" id="error_code" style="margin:0px;"></div>
                                        {/if}
                                        <div style="font-size: 16px;cursor: pointer;height: 23px;padding-bottom: 3px;margin-bottom: 10px;width: 100%;">
                                            <div style="float:left;">
                                                <input type="checkbox" id="remember_password"  value="rempassword"  />
                                                <label class="" for="remember_password">记住密码</label>
                                            </div>
                                        </div>
                                        {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq '' ||$EXPIREDTIP eq 'yes'|| $EXPIRINGTIP eq 'yes'||$REGTESTTIP neq ''}
                                            <div class="errorMessage">
                                                     {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}
                                                    {else if $LOGIN_ERROR neq ''}{$LOGIN_ERROR}
            
            
            
                                                            {else if $EXPIRINGTIP  eq  'yes'}
                                                            
                                                                 您的软件{$EXPIREDDAYS}天后即将到期，请联系供应商！
                                                             
                                                     {else if $EXPIREDTIP eq 'yes'}
                                                              
                                                                 您的软件已经过期，请联系供应商！
                                                            
                                                          {else if $REGTESTTIP eq 'yes'}
                                                            
                                                                您的软件仅供内部演示使用，不可销售给客户！
                                                            
                                                          
                                                        
                                                     {/if}                                          
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="login-action">
                            <input tabindex="3" style="cursor:pointer" class="submit" onFocus="this.blur()" onclick="return NewCheck_One();" type="button"  {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} id="submitButton" value="登 录" />
                            <div class="wx-login-btn" ><i class="icon-qy-wexi-qywx-login"></i>企业微信登录</div>
                            <div class="other">
                                <div class="fl">
                                </div>
                                {if $NOREGISTER eq 0||$EXPIREDTIP eq 'yes'}
                                    <div class="fr">
                                        <a href="index.php?action=isReg" class="go_reg">立即注册</a>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    {else}
                        <div class="login-info" style="padding-bottom:13px" onkeydown="tabchange(event)">
                            <div class="valm_a">
                               <div class="valm_b">
                                    <div class="valm_c" {if $ENORZH neq 'yes'}style="padding-top:25px;"{/if}>
                                       {if $ENORZH eq 'yes'}
                                            <div style="height:53px;">
                                                <span class="val_m" style="padding-right:20px;line-height:53px;">Language</span>
                                                <input type="radio" class="val_m" name="languageType" value="zh" onclick="changeLangage(this)"/>
                                                <span class="val_m" style="padding-right:30px;line-height:53px;">中文</span>
                                                <input type="radio" class="val_m" name="languageType" value="en" checked="true" onclick="changeLangage(this)"/>
                                                <span class="val_m" style="padding-top:2px">English</span>
                                            </div>
                                        {/if}
                                        
                                       
                                            <div {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} class="disable account"{else}class="account" style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if}>
                                                <span></span>
                                                <input type="text" maxlength="100" tabindex="1" id="login_user_name"    name="login_user_name" {if $EXPIREDTIP eq 'yes' || $KEHU001_NO_DISTRIBUTE eq 'yes'} disabled="true" class="disable"{else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} value="{$LOGINUSERNAME}" placeholder="UserName" onblur="checkForm(this,name,'en');" autocomplete="off"/>
                                            </div>
                                            <div class="errtip" id="error_name"></div>
                                            <div {if $EXPIREDTIP eq 'yes'} class="disable password"{else}class="password"{/if}>
                                                         <span></span>
                                                        <input type="password" tabindex="2" {if $EXPIREDTIP eq 'yes'} disabled="true" class="password disable" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} id="login_password" name="login_user_password" value="" placeholder="Password" onblur="checkForm(this,name,'en');" autocomplete="off"/>
                                            </div>
                                        
                                        <!--<div class="errtip" id="error_pwd"></div>-->
                                        <span id="capsLockHint" style="display:none;font-size:12px;padding:7px 10px;">A state capital opening</span>
                                       <div style="font-size: 16px;cursor: pointer;height: 23px;padding-bottom: 3px;margin-bottom: 10px;width: 100%;">
                                            <div style="float:left;">
                                                <input type="checkbox" id="remember_password"  value="rempassword"  />
                                                <label class="" for="remember_password">Remember password</label>
                                            </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="login-action">
                            <input style="cursor:pointer" class="submit" onFocus="this.blur()" onclick="return NewCheck_One();" type="button"  {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} id="submitButton" value="Login" />
                            <div class="wx-login-btn" ><i class="icon-qy-wexi-qywx-login"></i>WeChat login</div>
                            <div class="other">
                                <div class="fl">
                                </div>
                                {if $NOREGISTER eq 0||$EXPIREDTIP eq 'yes'}
                                <div class="fr">
                                <a href="index.php?action=isReg" class="go_reg">立即注册</a>
                                </div>
                                {/if}
                            </div>
                        </div>
                    {/if}   
                </form>
            </div>
        </div>
    </div>
</div>
{if ""|@checkBrowserIsSupport eq 'no'}
    <div style="z-index:9999">
	<div class="shade_div_dark"></div>
	<div class="browser_judge">
		<span class="browser_title">您的浏览器版本太低</span>
		<p>您目前的IE浏览器版本较低，为了更好的安全性和浏览体验，请更新浏览器 <font>点击图标立即下载</font></p>
        <p>或者使用360浏览器极速模式、搜狗浏览器极速模式</p>
		<ul class="browser_list clear">
			<li class="browser_ico"><a href="http://w.x.baidu.com/alading/anquan_soft_down_b/11843"><span class="browser_firefox"></span></a></li>
			<li class="browser_ico"><a href="http://w.x.baidu.com/alading/anquan_soft_down_b/12966"><span class="browser_safari"></span></a></li>
			<li class="browser_ico"><a href="http://w.x.baidu.com/alading/anquan_soft_down_normal/23360"><span class="browser_ie"></span></a></li>
			<li class="browser_ico"><a href="http://w.x.baidu.com/alading/anquan_soft_down_b/14744"><span class="browser_chorme"></span></a></li>
		</ul>
		<ul class="browser_namelist clear">
			<li><div class="browser_name"><a>Firefox</a></div></li>
			<li><div class="browser_name"><a>Safari</a></div></li>
			<li><div class="browser_name"><a>IE11</a></div></li>
			<li><div class="browser_name"><a>Chrome</a></div></li>
		</ul>
	</div>
    </div>   
 {/if}  
{include file="LoginFooterkh001.tpl"}
<!-- edit by LD Can reason:用户注册需求-->
<script>
var languageType='zh';
var regtype='{$SOFTGETTYPE}';
var logininfo='{$REGINFOTIP}';
var puyoungpermited='{$LINGDANGTIP}';
var weixinlogin ='{$WEIXINLOGIN}';
var weixinloginurl = '{$WEIXINLOGINURL}';
var ldtokenrand = '{$TOKENRAND}';
var loginerror="";

{if $login_usererror neq ''}

var loginerror='{$login_usererror}';

{/if}
{if $NOREGISTER eq 1}

	document.DetailView.login_user_password.focus();
	document.DetailView.login_user_password.select();

{/if} 
 {literal}
 function NewCheck_One()
 {
    Check();
 }

// 加密解密方法：string-需要解密的字段  code-约定的密钥    operation 默认false表示加密，传入true表示解密
function ld_login_secret(string, code, operation) {
    code = code.trim();
      code = CryptoJS.MD5(code).toString()
      var iv = CryptoJS.enc.Utf8.parse(code.substring(0, 16))
      var key = CryptoJS.enc.Utf8.parse(code.substring(16))
      if (operation) {
        return CryptoJS.AES.decrypt(string, key, {
          iv: iv,
          padding: CryptoJS.pad.Pkcs7
        }).toString(CryptoJS.enc.Utf8)
      }
      return CryptoJS.AES.encrypt(string, key, {
        iv: iv,
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
      }).toString()
}
 {/literal}
</script>  

<script type="text/javascript" src="login/js/general_new.js"></script>                                                      
<script type="text/javascript" src="login/js/login_new.js"></script>