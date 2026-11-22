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
{include file="LoginHeader.tpl"}
<div class="container">
    <div class="content">
    	<div class="log_left">
        	<img src="dataCache/test/logo/login_img.png" width="511" height="379" class="log_left_img" />
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
                    <input type="hidden" id="hantianlogin" name="hantianlogin" value="">
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
                                        {if $NOREGISTER eq 0}                                       
                                        <div  {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} class="disable account"{else}class="account"{/if}>
                                            <span></span>
                                            <input type="text"  maxlength="100" tabindex="1" {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} disabled="true" class="disableInput" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} id="login_user_name" name="login_user_name" value="{$LOGINUSERNAME}" placeholder="账号" onblur="checkForm(this,name,'zh');"/>
                                        </div>
                                        {else}
                                        <div class="disable account" >
                                            <span></span>
                                            <input class="disableInput" {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} type="text" maxlength="100" tabindex="1" name="login_user_name" value="admin" readonly="true"  disabled="true" style="-webkit-box-shadow:none !important;"/>
                                        </div>
                                        {/if}
                                        <div class="errtip" id="error_name"></div>
                                        <div {if $EXPIREDTIP eq 'yes'} class="disable password"{else}class="password"{/if}>
                                            <span></span>
                                            <input type="password" tabindex="2" id="login_password" {if $EXPIREDTIP eq 'yes'} disabled="true" class="disable" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} name="login_user_password" value="" placeholder="密码" onblur="checkForm(this,name,'zh');"/>
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
                                        {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq ''}
                                            <div class="errorMessage">
                                                {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}{else}{$LOGIN_ERROR}{/if}                                          
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="login-action">
                            <input tabindex="3" style="cursor:pointer" class="submit" onFocus="this.blur()" onclick="return Check();" type="button"  {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} id="submitButton" value="登 录" />
                            <div class="wx-login-btn" {if ''|@getCommonVersion eq 'yes' } style="display:none" {/if}><i class="icon-qy-wexi-qywx-login"></i>企业微信登录</div>
                            <div class="other">
                                <div class="fl">
                                </div>
                                {if $NOREGISTER neq 0||$EXPIREDTIP eq 'yes'}
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
                                        {if $NOREGISTER eq 0}
                                            <div {if $EXPIREDTIP eq 'yes'|| $KEHU001_NO_DISTRIBUTE eq 'yes'} class="disable account"{else}class="account" style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if}>
                                                <span></span>
                                                <input type="text" maxlength="100" tabindex="1" id="login_user_name" name="login_user_name" {if $EXPIREDTIP eq 'yes' || $KEHU001_NO_DISTRIBUTE eq 'yes'} disabled="true" class="disable"{else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} value="{$LOGINUSERNAME}" placeholder="UserName" onblur="checkForm(this,name,'en');"/>
                                            </div>
                                        {else}
                                            <div class="disable account" style="background-color:#F0F0F0;">
                                                <span></span>
                                                <input class="disableInput"  type="text" maxlength="100" tabindex="1" name="login_user_name" value="admin" readonly="true"  disabled="true"  style=" height: 35px;width: 239px;-webkit-box-shadow:none !important;"/>
                                            </div>
                                        {/if}
                                        <div class="errtip" id="error_name"></div>
                                        <div {if $EXPIREDTIP eq 'yes'} class="disable password"{else}class="password"{/if}>
                                            <span></span>
                                            <input type="password" tabindex="2" {if $EXPIREDTIP eq 'yes'} disabled="true" class="password disable" {else}style="-webkit-box-shadow: 0 0 0px 1000px white inset !important;"{/if} id="login_password" name="login_user_password" value="" placeholder="Password" onblur="checkForm(this,name,'en');"/>
                                        </div>
                                        <!--<div class="errtip" id="error_pwd"></div>-->
                                        <span id="capsLockHint" style="display:none;font-size:12px;padding:7px 10px;">A state capital opening</span>
                                        {if $CODE neq ''}
                                        <div id="yzm_value" class="token">
                                            <input type="text" tabindex="3" id="secutity_code" name="secutity_code" value="" placeholder="Code" onblur="checkForm(this,name,'en');"/>
                                            <img src="picture.php?code={$CODE}" onclick="yzm_change(this);" class="val_m img_b" style="margin-left:4px" width="79" height="29" />
                                            <a href="javascript:void(0);" style="color:#2E7ECD" onclick="yzm_change(this);">Change</a>
                                        </div>
                                        <div class="errtip" id="error_code" style="margin:0px;"></div>
                                        {/if}
                                        {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq ''}
                                            <div class="errorMessage">
                                                {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}{else}{$LOGIN_ERROR}{/if}                                         
                                            </div>
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="login-action">
                            <input style="cursor:pointer" class="submit" onFocus="this.blur()" onclick="return Check();" type="button"  {if $EXPIREDTIP eq 'yes'} disabled="true"{/if} id="submitButton" value="Login" />
                            <div class="wx-login-btn" {if ''|@getCommonVersion eq 'yes' } style="display:none" {/if}><i class="icon-qy-wexi-qywx-login"></i>WeChat login</div>
                            <div class="other">
                                <div class="fl">
                                </div>
                                {if $NOREGISTER neq 0||$EXPIREDTIP eq 'yes'}
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
{include file="LoginFooter.tpl"}
<!-- edit by LD Can reason:用户注册需求-->
<script>
var languageType='{$LANGUAGETYPE}';
var regtype='{$SOFTGETTYPE}';
var logininfo='{$REGINFOTIP}';
var puyoungpermited='{$LINGDANGTIP}';
var weixinlogin ='{$WEIXINLOGIN}';
var weixinloginurl = '{$WEIXINLOGINURL}';
</script>
{literal}
<script>




//<![CDATA[
function  detectCapsLock(event){
    var e = event||window.event;
    var o = e.target||e.srcElement;
    var oTip =  eval(document.getElementById('capsLockHint'));
    var keyCode  =  e.keyCode||e.which; // 按键的keyCode 
    //alert(keyCode);
    var isShift  =  e.shiftKey ||(keyCode  ==   16 ) || false ; // shift键是否按住
     if (
     ((keyCode >=   65   &&  keyCode  <=   90 )  &&   !isShift) // Caps Lock 打开，且没有按住shift键 
     || ((keyCode >=   97   &&  keyCode  <=   122 )  &&  isShift)// Caps Lock 打开，且按住shift键
     ){oTip.style.display = '';}
     else{oTip.style.display  =  'none';} 
}
document.getElementById('login_password').onkeypress = detectCapsLock;

function getLoginerror(labelbol)
{
    var enjspop={'USERNAMECANOTEMPTY':'User name can not be empty!',
    'VERIFICATIONCODENOTEMPTY':'Verification code can not be empty!',
    'VERIFICATIONCODEERROR':'Verification code is incorrect, please re-enter!'};
    
    var zhjspop={'USERNAMECANOTEMPTY':'账号不能为空！',
    'VERIFICATIONCODENOTEMPTY':'验证码不能为空！',
     'VERIFICATIONCODEERROR':'验证码不正确，请重新输入！'};
     
     if(languageType=='zh')
     {
        return zhjspop[labelbol];
     }
     else
     {
        return enjspop[labelbol];
     }
}
function _createElementDiv(divid){
	var divObj;
	if(languageType == 'zh'){
		var _lbl_close = '关闭';
		var _lbl_confirme = '确定';
		var _lbl_cancel = '取消';
	}else{
		var _lbl_close = 'Close';
		var _lbl_confirme = 'Confirm';
		var _lbl_cancel = 'Cancel';
	}
	if(0 == ld('#'+divid).length){//当层未创建时，创建层
		divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'D_pop_box LdPopWidth650px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		//divObj.style.maxHeight = "200px";
		divObj.style.display = "none";
		//divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="D_pop_tit">'+
								'<strong class="D_ptita" id="'+divid+'titlename"></strong>'+
								'<a href="javascript:;" class="D_ptitc">'+
									'<img class="D_ptitcimg" src="themes/icon/pop_close.png" '+
									'alt="'+_lbl_close+'" title="'+_lbl_close+'">'+
								'</a>'+
							'</div>'+
							'<div id="'+divid+'content" class="pop_remind_content">'+
								'&nbsp;'+
							'</div>'+
							'<div class="D_pbtn"><input class="D_pbtnok" value="'+_lbl_confirme+'" type="button"><span>&nbsp;</span>'+
							'<input class="D_pbtncancel" value="'+_lbl_cancel+'" type="button"></div>';
		var isbg = 0;
		if(ld('#layer').length > 0){
			isbg = 1;
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
		/**
		 * 关闭事件
		 * @author Tujt 2015-04-15
		 */
		ld('#'+divid+' .D_pop_tit .D_ptitc').on('click',function(){
			ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
			return false;
		});
		ld('#'+divid+' .D_pbtn .D_pbtncancel').on('click',function(){
			if(0 == isbg){
				fninvshnew(divid);
			}else{
				ld('#'+divid).css('display','none');
			}
		});
	}else{
		divObj = document.getElementById(divid);
		if(ld('#layer').length > 0){
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
	}
	return divObj;
}
function Check(){ 
    var form=document.forms['DetailView'];
    var code=form.code.value;
	//var bodyWidth = document.body.scrollWidth;	//网页正文全文宽
    var bodyWidth = window.screen.availWidth;	//屏幕可用工作区宽度
	if(form.secutity_code!=undefined)
    var inputcode=form.secutity_code.value;
    else
    var inputcode='';
    //获取屏幕分辨率的可见宽度
	if(document.getElementById('bodywidth') != undefined){
		document.getElementById('bodywidth').value = bodyWidth;
	}
	
    if(form.login_user_name.value==''){   
        windowDiv(getLoginerror('USERNAMECANOTEMPTY'));
        form.login_user_name.focus();
        return false;
    }
   
     if(form.secutity_code!=undefined){
        if(form.secutity_code.value==''){
         windowDiv(getLoginerror('VERIFICATIONCODENOTEMPTY'));
        form.secutity_code.focus();
        return false;
        }
     } 
    
   if(document.getElementById('secutity_code')!='undefined'&&document.getElementById('secutity_code')!=undefined)
   {
        $.ajax({
                url:'picture.php',
                type:'POST', 
                async:false,   
                data:{
                    code:'2',age:25,'textvalue':document.getElementById('secutity_code').value
                },
                timeout:5000,    //超时时间
                dataType:'text',    //返回的数据格式：json/xml/html/script/jsonp/text
                
                success:function(data,textStatus,jqXHR)
                {
                           if(data.indexOf('$$ERROR$$')>=0)
                           {
                                windowDiv(getLoginerror('VERIFICATIONCODEERROR'));
                                form.secutity_code.focus();
                                return false;
                           }
                           else
                         {
                            document.getElementById('form_login').submit();
                            return true;
                         }
                   
                 }
                 
                
                })
   }
   else
   {
        var iframeswitch = ld('#JWtitle',window.parent.document).val();
        if(iframeswitch == 4){
           document.getElementById('hantianlogin').value = 'yes';
        }
        
        document.getElementById('form_login').submit();
   }
	
     
}

function changeLangage(obj)
{ 
    window.location='index.php?languageType='+obj.value+'&login_method=1';

}

function yzm_change(obj)
{
 
    document.getElementById('img_codepicture').src="picture.php?"+Math.random()*10000;
   
    
     
}

/**
    * 控制按tab键时,焦点只在指定元素中切换
    * edit:zhuyiping
    * date:20160714
    * */
function tabGoHome(){
    document.getElementById("login_user_name").focus();
}
function stopEvent(e)
{
    if(e.stopPropagation)
    {
        e.stopPropagation();
    }
    else
    {
        e.cancelBubble=true;
    };
     
    if(e.preventDefault)
    {
        e.preventDefault();
    }
    else
    {
        e.returnValue=false;
    }
}
function tabchange(event){        
    var e = event || window.event;
    var target = e.target||e.srcElement;
    var keyCode = e.keyCode||e.which;
    var stop="";
    if(document.getElementById("secutity_code")==null)
    {
        stop="login_password";
    }else{
        stop="secutity_code";     
    };
    
    if(9 == keyCode)
	{
		if(stop!="" && stop == target.id)
		{
			stopEvent(e);
			tabGoHome();
		}
	}
}
function windowDiv(msg){
        var divobj = _createElementDiv('loginreminder');
        var title = '温馨提示';
        if(languageType == 'en')
            title = 'Warm prompt';
       	var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
    	+'<div class="msgDlg_left">'
    	+'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
    	+'</div>'
    	+'<div class="msgDlg_right">'   
    	+'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+msg
    	+'</div>'
    	+'</div>'
    	+'</div>';
    	ld(divobj).find('.D_pop_tit .D_ptita').html(title);
    	ld('#loginremindercontent').html(div_text);
    	ld(divobj).css('max-height','500px');
    	ld(divobj).css('width','350px');
    	ld(divobj).css('background','#FDFDFD');
    	ld('#loginremindercontent').css('max-height','400px');
    	ld('#loginremindercontent').css('border','none');
    	ld(divobj).find('div.D_pbtn .D_pbtncancel').remove();
    	ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
    	ld(divobj).find('div.D_pop_tit a').remove();
    	ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","fninvshnew('loginreminder');");
    	fnvshobj(this,'loginreminder');  
}

</script>
<script type="text/javascript">  
$('.wx-login-btn').click(function(){
    if(weixinlogin == 'yes'){
		var bodyWidth = window.screen.availWidth; 
        window.location = weixinloginurl+'&languageType='+languageType+'&bodywidth='+bodyWidth;
       // window.location = 'http://www.51mis.cn/webapi/weixinapi_v5/function/crm_login_transfer.html?orignurl='+weixinloginurl+'&languageType='+languageType;
    }else{
        var r='当前登录地址没有绑定企业微信，是否立即绑定？';
        var close_alt='关闭';
        var popTitle = '温馨提示';
        var popbtn_ok = '确定';
        var popbtn_cancel = '取消'
        if(languageType == 'en'){
         r='The current login address is not bound to the enterprise WeChat, or is it immediately bound?';
         popTitle = 'Warm prompt';
         close_alt = 'Close';
         popbtn_ok = 'Confirmed';
         popbtn_cancel = 'Cancel';
        }
        getJsScript('include/js/ldcrm.base.js',function(){
            //创建提示弹出层
            create_divobj('weixinloginError',popTitle,r,'yes','','yes');
            ld('#weixinloginError .D_ptitc .D_ptitcimg').attr({alt:close_alt});
            ld('#weixinloginError .D_ptitc .D_ptitcimg').attr({title:close_alt});    
            ld('#weixinloginError .D_pbtn .D_pbtnok').val(popbtn_ok);
            ld('#weixinloginError .D_pbtn .D_pbtncancel').val(popbtn_cancel);

            $('#weixinloginError .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                fninvshnew('weixinloginError');
                if(weixinlogin.indexOf("kehu001") > -1){
                    window.open('http://www.kehu001.com');
                }else{
                    window.open('http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
                }
            });
        });    
           
    }
});
</script>  
{/literal}
{if $login_usererror neq ''}
<script>
	var loginerror='{$login_usererror}';
	var divobj = _createElementDiv('loginreminder');
    var title = '温馨提示';
	if(languageType == 'en')
		title = 'Warm prompt';

	var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
	+'<div class="msgDlg_left">'
	+'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
	+'</div>'
	+'<div class="msgDlg_right">'   
	+'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+loginerror
	+'</div>'
	+'</div>'
	+'</div>';
	ld(divobj).find('.D_pop_tit .D_ptita').html(title);
	ld('#loginremindercontent').html(div_text);
	ld(divobj).css('max-height','500px');
	ld(divobj).css('width','400px');
	ld(divobj).css('background','#FDFDFD');
	ld('#loginremindercontent').css('max-height','400px');
	ld('#loginremindercontent').css('border','none');
	ld(divobj).find('div.D_pbtn .D_pbtncancel').remove();
	ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
	ld(divobj).find('div.D_pop_tit a').attr("onclick","fninvshnew('loginreminder');");
	ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","fninvshnew('loginreminder');");
	fnvshobj(this,'loginreminder');
</script>
{/if}
{if $NOREGISTER eq 1}
<script>
    if(document.DetailView.login_user_password==''){
	    document.DetailView.login_user_password.focus();
	    document.DetailView.login_user_password.select();
    }
</script>
{/if}                                                           
<script type="text/javascript" src="Register/login.js"></script>