<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <title>{$BROWSETITLE}</title>
    <link rel="stylesheet" type="text/css" href="themes/softed/component.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/leftmenu.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/swiper.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/login-new.css">

    <link rel="stylesheet" href="themes/softed/popup.css" type="text/css" />
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js?v={$GLOBALMINVERSION}"></script>

    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var language='{$LANGUAGETYPE}';
        var global_js_url ='{$JSURL}';
    </script>
    <script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/swiper.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/component/ld_Select.js?v={$GLOBALMINVERSION}"></script>

    <script type="text/javascript" language="JavaScript">
        function set_focus() {ldelim}
            var detailviewobj = ld("#form_login");
            var login_user_passwordobj = ld(detailviewobj).find("#login_password");
            var login_user_nameobj = ld(detailviewobj).find("#login_user_name");
            if (ld(login_user_nameobj).val() != '') {ldelim}
                if(ld(login_user_passwordobj).val() == ''){ldelim}
                  ld(login_user_passwordobj).focus();
                  ld(login_user_passwordobj).select();
                {rdelim}
                else if(ld(detailviewobj).find("#secutity_code").length>0)
                    ld(detailviewobj).find("#secutity_code").focus();
            {rdelim}
            else
                ld(login_user_nameobj).focus();
            {if $NOREGISTER eq 0}
                ld(login_user_passwordobj).focus();
                ld(login_user_passwordobj).select();
            {/if}
        {rdelim}

        function keyLogin(event){ldelim}
            var e = event||window.event;
            var keyCode  =  e.keyCode||e.which;
            if(keyCode == 13){ldelim}
                //document.getElementById('submitButton').click();
                Check();
            {rdelim}
        {rdelim}
    </script>

</head>
<body onload="set_focus()" onkeyup="keyLogin(event);">
    <div id="root">
        {if ($SPSEXPIREDTIP eq 'yes' || $SPSEXPIRINGTIP eq 'yes' || $WEIXINLOGINERROR neq '' || $LOGIN_ERROR neq '' || $EXPIRINGTIP  eq  'yes'
        || $EXPIREDTIP eq 'yes' || $REGTESTTIP eq 'yes' || $NOREGISTER eq 0)
           &&$reglogin_check eq 'no'}
            <div class="ld-crm-container-top" id="dvlogininfo" >
                <span>
                    {if $SPSEXPIREDTIP eq 'yes'}
                        {if $LANGUAGETYPE eq 'zh'}
                            您的畅捷通SPS服务已经过期，请联系供应商！
                        {else}
                            Your SPS service has expired, please contact the supplier!
                        {/if}
                    {elseif $SPSEXPIRINGTIP eq 'yes'}
                        {if $LANGUAGETYPE eq 'zh'}
                            您的畅捷通SPS服务{$SPSEXPIREDDAYS}天后即将到期，请联系供应商！
                        {else}
                            Your SPS service will expire in {$SPSEXPIREDDAYS} days, please contact with the supplier!
                        {/if}
                    {/if}
                    {if $WEIXINLOGINERROR neq ''}
                        {$WEIXINLOGINERROR}
                    {elseif $LOGIN_ERROR neq ''}
                        {$LOGIN_ERROR}
                    {elseif $EXPIRINGTIP  eq  'yes'}
                        您的软件{$EXPIREDDAYS}天后即将到期，<a href="index.php?action=isReg">点击显示授权信息</a>
                    {elseif $EXPIREDTIP eq 'yes'}
                        您的软件已经过期，请<a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">立即注册</a>！
                    {elseif $REGTESTTIP eq 'yes'}
                        您的软件仅供内部演示使用，不可销售给客户！
                    {/if}
                    {if $NOREGISTER eq 0}
                        未注册不允许登录，请<a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">立即注册</a>
                    {/if}
                </span>
            </div>
        {/if}
        {include file="loginswiperblock.tpl"}
        <div name="DetailView" id="form_login" class="ld_form_login" style="{if $SWIPERRATIO == '1:2'}box-shadow: 0px 2px 8px 0px rgba(200,201,204,0.7);{/if}">
            <input type="hidden" name="sessionrand" value="{$SESSIONRAND}" id="sessionrand"/>
            <input type="hidden" id="login_method" name="login_method" value="{$LOGINMETHOD}" />
            <input type="hidden" id="code" name="code" value="{$CODENUM}"/>
            <input type="hidden" id="bodywidth" name="bodywidth" value="">
            <input type="hidden" id="hantianlogin" name="hantianlogin" value="">
            <input type="hidden" id="languageType" name="languageType" value="{$LANGUAGETYPE}">
            <input type="hidden" name="CrmClientIp"  id="CrmClientIp" />
            <div class="ld-crm-container-body">
                {if $reglogin_check != 'yes'}
                    <div class="login-title">{if $LANGUAGETYPE eq 'zh'}登录{else}Login{/if}</div>
                    <div class="login-subtitle">{$LOGINWELCOME.after_zh_content}</div>
                {else}
                    <div class="login-title">注册授权管理</div>
                    <div class="login-subtitle">需要验证管理员身份才能进行注册授权管理</div>
                {/if}

                <div class="ld-crm-container-input" style="margin-top: 20px;">
                    <input type="text" id="login_user_name"  value="{$LOGINUSERNAME}" class="text-input" name="login_user_name" {if ($EXPIREDTIP eq 'yes' || $NOREGISTER eq '0') &&$reglogin_check eq 'no'} disabled="true" readonly="true" class="disable"{else}{/if} placeholder='{if $LANGUAGETYPE eq 'zh'}请输入账号{else}Username{/if}' tabindex="1" autocomplete="off"/>
                    <span class="errorinfo error_name"></span>
                </div>
                <div class="ld-crm-container-input">
                    <input type="password" id="login_password" onfocus="this.type='password'" name="login_user_password"  {if ($EXPIREDTIP eq 'yes' || $NOREGISTER eq '0') &&$reglogin_check eq 'no'} disabled="true" class="text-input password disable" {else}{/if} class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请输入密码{else}Password{/if}' tabindex="2" autocomplete="off"/>
                    <span class="errorinfo error_pwd"></span>
                </div>
                {if $reglogin_check != 'yes'}
                    {if $CODE neq ''}
                        <div class="ld-crm-container-input">
                            <input type="text" class="text-input" id="secutity_code" name="secutity_code" placeholder='{if $LANGUAGETYPE eq 'zh'}请输入验证码{else}Code{/if}' tabindex="3" style="width: 260px;margin-right: 12px;float: left;">
                            <img id="img_codepicture" src="picture.php?code={$CODE}" width="79" height="29" onclick="yzm_change(this);" style="width: 88px;height: 40px;background: black;border: 1px solid #DCDEE0;border-radius: 4px;">
                            <span class="errorinfo error_yanzhengma"></span>
                        </div>
                    {/if}
                    <div class="ld-crm-container-input" style="display: flex;align-items: center;">
                        {if $have_remember_password eq 'yes'}
                            <div class="ld-crm-container-remember_password">
                                <input class="checkbox-item" type="checkbox" id="remember_password"  value="rempassword"  />
                                <label  for="remember_password">{if $LANGUAGETYPE eq 'zh'}记住密码{else}Remember password{/if}</label>
                            </div>
                        {/if}
                        <div class="ld-crm-container-forgetpassword">
                            <span onclick="jumpForgetPassword();">{if $LANGUAGETYPE eq 'zh'}忘记密码?{else}Forget the password?{/if}</span>
                        </div>
                    </div>
                {/if}
                <div class="ld-crm-container-btn">
                    <a href="javascript:;" class="btn-submit inline-block" {if $NOREGISTER neq 0 || $reglogin_check eq 'yes'}onclick="return Check();"{/if} {if $NOREGISTER eq 0 && $reglogin_check eq 'no' }style="cursor: not-allowed;"{/if}>{if $LANGUAGETYPE eq 'zh'}登     录{else}Login{/if}</a>
                </div>
                {if $reglogin_check != 'yes'}
                    <div class="ld-crm-container-agreement">
                        <div class="ld-crm-container-agreement-div">
    {*                                    <input class="checkbox-item" type="checkbox" id="agreement_privacy" value="rempassword" />*}
                            {if $LANGUAGETYPE eq 'zh'}
                                <label for="agreement_privacy">
                                    登录即表明您同意
                                    <a style="cursor: pointer;" target="_blank" rel="noopener noreferrer" href="https://www.51mis.com/usermastersubscriptionagreement.html">《服务协议》</a>
                                    及
                                    <a style="cursor: pointer;" target="_blank" rel="noopener noreferrer" href="https://www.51mis.com/privacy.htm">《隐私政策》</a>
                                </label>
                            {else}
                                <label for="agreement_privacy">
                                    By logging in, you agree to the
                                    <a style="cursor: pointer;" target="_blank" rel="noopener noreferrer" href="https://www.51mis.com/usermastersubscriptionagreement.html">《User Agreement》</a>
                                    and
                                    <a style="cursor: pointer;" target="_blank" rel="noopener noreferrer" href="https://www.51mis.com/privacy.htm">《Privacy Statement》</a>
                                </label>
                            {/if}
                        </div>
                    </div>
                {/if}
                <div class="ld-crm-container-other">
                    <div class="ld-crm-container-other-list">
                        {if $WXLOGINBTN.isshow eq 'yes'}
                            {if $WEIXINLOGIN eq 'yes'}
                                <div class="other-login-item" id="btn-submit-qiyeweixin">
                                    <div class="other-login-item-img"></div>
                                    <div class="other-login-item-label">{$WXLOGINBTN.after_zh_content}</div>
                                </div>
                            {else}
                                <div class="other-login-item" id="btn-submit-qiyeweixin-install" {if $NOREGISTER neq 0}onclick="openWechatURL('{$LOGININFO.weixin.content}');"{/if}>
                                    <div class="other-login-item-img"></div>
                                    <div class="other-login-item-label">{$LOGININFO.weixin.zh}</div>
                                </div>
                            {/if}
                        {/if}
                    </div>
                </div>
            </div>
        </div>
        {include file="loginswiperblockfooler.tpl"}
    </div>
    {if $ISUPATE eq 'yes'}
        {include file="updatesql.tpl"}
    {/if}
</body>

<script>
var languageType='{$LANGUAGETYPE}';
var regtype='{$SOFTGETTYPE}';
var logininfo='{$REGINFOTIP}';
var puyoungpermited='{$LINGDANGTIP}';
var weixinlogin ='{$WEIXINLOGIN}';
var weixinloginurl = '{$WEIXINLOGINURL}';
var agentid='{$agentid}';
var corpid='{$corpid}';
var account_version='{$account_version}';
var ldtokenrand='{$TOKENRAND}';
var have_remember_password = 'yes';
var global_loginpage_url_arr = {$global_loginpage_url_arr};
var reglogin_check='{$reglogin_check}';
var reloginsession='{$reloginsession}';

if('{$have_remember_password}' == 'no'){
    have_remember_password = '{$have_remember_password}';
}

 if(agentid!='')
 {ldelim}
    console.log(weixinloginurl);
    
    var url='{$WEIXINLOGINURL|@urlencode}';
   
    weixinloginurl="https://open.work.weixin.qq.com/wwopen/sso/qrConnect?appid="+corpid+"&agentid="+agentid+"&redirect_uri="+url+"&state=STATE";

 {rdelim}
</script>
{literal}
<style>
    .ld_Select-component .ld_Select-lefticon {
        background-size: 18px 18px !important;
    }
</style>
<script>

    if(ld('[name=ld-container-form-language]').length > 0){
        var languagearr = [];
        var zharr = {'label':'简体中文','value':'zh'};
        var enarr = {'label':'English','value':'en'};
        if(languageType == 'zh'){
            zharr['selected'] = true;
        }else{
            enarr['selected'] = true;
        }
        languagearr.push(zharr);
        languagearr.push(enarr);
        var Showselect_obj = ld_Select.showSelect(ld('[name=ld-container-form-language]').get(0), {
            list: languagearr,
            width: '180px',
            optionwidth: '180px',
            showtype: 'click',
            selecticonurl: 'themes/icon/languagetype.png',
            change: function (evt){
                var languagetype = evt.NavBarItem.value;
                OpenNewWebTab(cls_encryptyurl.Puyoung_Encryptyurlhavephp('index.php?languageType='+languagetype+'&login_method=1',''),'');
            }
        });
    }
    if(ld('#moresetselect').length > 0){
        var Showselect_obj = ld_Select.showSelect(ld('#moresetselect').get(0), {
            list: global_loginpage_url_arr,
            width: '180px',
            selectname: '更多操作',
            optionwidth: '180px',
            showtype: 'click',
            change: function (evt){
                if(evt.NavBarItem.url != ''){
                    window.open(evt.NavBarItem.url, '_blank');
                }
            }
        });
    }

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
     ){
      if(oTip){
        oTip.style.display = '';
      }
    }
    else{
      if(oTip){
        oTip.style.display = 'none';
      }
    } 
}
document.getElementById('login_password').onkeypress = detectCapsLock;
//记住密码复选框 勾选状态 赋值
if(ld("#remember_password").length>0){
    ld(document).on('input propertychange','#login_user_name',function (args) {
          if ((args.type.toLowerCase() == "propertychange" && args.originalEvent.propertyName.toLowerCase() == "value") || args.type == "input") {
            ldcrm_setpassword(ld(this));
          }
    })
    if(localStorage.getItem('ldcrm_remember_password')=='no'){
        ld("#remember_password").prop('checked',false);
    }
    else{
        ld("#remember_password").prop('checked',true);
        if(ld('#login_user_name').value != ''){
            ldcrm_setpassword(ld('#login_user_name'));
        }
    }
}

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
function _createElementDiv(divid){ //BUG0067660 BUG0067657 xxy 2023-6-13 登陆界面弹出框样式优化
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
		divObj.className = 'E_pop_box LdPopWidth400px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		//divObj.style.maxHeight = "200px";
		divObj.style.display = "none";
		//divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="ld-E-pop-tit">'+
								'<strong class="ld-E-ptita" id="'+divid+'titlename"></strong>'+
							'</div>'+
							'<div id="'+divid+'content" class="pop_remind_content" style="margin:0;">'+
								'&nbsp;'+
							'</div>'+
							'<div class="ld-E-pbtn-bg"><input class="ld-button ld-button-primary" value="'+_lbl_confirme+'" type="button">'+
							'<input class="ld-button ld-button-cancel" value="'+_lbl_cancel+'" type="button"></div>';
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
		ld('#'+divid+' .ld-E-pop-tit .ld-E-ptitc').on('click',function(){
			ld('#'+divid+' .ld-E-pbtn-bg .ld-E-pbtncancel').click();
			return false;
		});
		ld('#'+divid+' .ld-E-pbtn-bg .ld-E-pbtncancel').on('click',function(){
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
function loginCheckVersion(callbackfun)
{
     var form=ld("#form_login").get(0);
    var languagetype=ld("#form_login").find(' [name=languageType]').val();
    var param = {'languagetype':languagetype};
    var urlstring = 'loginCheckVersion.php';
    param= cls_encryptyurl.Puyoung_Encryptyurltoparamhavephp(urlstring,param);
    ld.ajax({
        url: urlstring,
        type: 'POST',
        data:param,
        dataType:'json',
        async: true,//
        timeout: 900000,
        success: function(ajaxdata)
        {
            if(ajaxdata.code==1)
                callbackfun();
            else
            {
                var divobj=windowDiv(ajaxdata.result.error,450);

                ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","resetUpdateDb()");
            }
        },
        error:function(jqXHR, textStatus, errorThrown)
        {
            console.log(param);
            console.log(jqXHR);
            console.log(textStatus);
        }
    })
}
function resetUpdateDb()
{
    window.location.reload();
    fninvshnew('loginreminder');
}
function Check(){
    var formobj=ld("#form_login").get(0);
    var code=ld(formobj).find('#code').val();
	//var bodyWidth = document.body.scrollWidth;	//网页正文全文宽
    var bodyWidth = window.screen.availWidth;	//屏幕可用工作区宽度
	if(ld(formobj).find('#secutity_code').length>0)
    var inputcode=ld(formobj).find('#secutity_code').val();
    else
    var inputcode='';
    //获取屏幕分辨率的可见宽度
	if(document.getElementById('bodywidth') != undefined){
		document.getElementById('bodywidth').value = bodyWidth;
	}
	
    if(ld(formobj).find('#login_user_name').val()==''){   
        windowDiv(getLoginerror('USERNAMECANOTEMPTY'),400);
        ld(formobj).find('#login_user_name').focus();
        return false;
    }
   
    if(ld(formobj).find('#secutity_code')!=undefined){
        if(ld(formobj).find('#secutity_code').val()==''){
            windowDiv(getLoginerror('VERIFICATIONCODENOTEMPTY'),400);
            ld(formobj).find('#secutity_code').focus();
            return false;
        }
    }
    var iframeswitch = ld('#JWtitle',window.parent.document).val();
    if(iframeswitch == 4){
        document.getElementById('hantianlogin').value = 'yes';
    }
    loginCheckVersion(function(){

        ld_login_submit();
    })
	return false;
     
}

function ld_login_submit()
{
    var encode_login_password_value='';
    var encode_login_user_name_value='';
    var login_user_name_value='';
    if(ld("#login_password").length>0){
        
        var login_user_name_obj = ld("#login_user_name");
        var login_password_obj = ld("#login_password");
        //登录密码加密
        var login_password_value = ld(login_password_obj).val();
        login_user_name_value = ld(login_user_name_obj).val();
        encode_login_password_value = ld_login_secret(login_password_value,login_user_name_value,false);
        encode_login_user_name_value = ld_login_secret(login_user_name_value,encode_login_password_value,false);
        
        
        //ld(login_password_obj).val(encode_login_password_value);
        
    }
     
    var formData = new FormData();
   
    var formobj = ld("#form_login");
   
    formData.append('module','Users');
       
    formData.append('action','Authenticate');
     
    formData.append('return_module','Users');
    formData.append('return_action','Login');
    formData.append('ldtokenrand',ldtokenrand);
    formData.append("reloginsession",reloginsession)

    //获取值
    if(ld(formobj).find("#sessionrand").length >0){
        formData.append('sessionrand',ld(formobj).find("#sessionrand").val());
    }
    if(ld(formobj).find("#login_method").length >0){
        formData.append('login_method',ld(formobj).find("#login_method").val());
    }
        
    if(ld(formobj).find("#code").length >0){
        formData.append('code',ld(formobj).find("#code").val());
    }
    if(ld(formobj).find("#bodywidth").length >0){
        formData.append('bodywidth',ld(formobj).find("#bodywidth").val());
    }
       
    if(ld(formobj).find("#hantianlogin").length >0){
        formData.append('hantianlogin',ld(formobj).find("#hantianlogin").val());
    }
    
    if(ld(formobj).find("#languageType").length >0){
        formData.append('languageType',ld(formobj).find("#languageType").val());
    }
    if(ld(formobj).find("#CrmClientIp").length >0){
        formData.append('CrmClientIp',ld(formobj).find("#CrmClientIp").val());
    }
    if(ld(formobj).find("#secutity_code").length >0){
        formData.append('secutity_code',ld(formobj).find("#secutity_code").val());
    }
      
    formData.append('login_user_password',encode_login_password_value);
    formData.append('encode_login_user_name_value',encode_login_user_name_value);
     
    //添加辨别参数，告诉后台这里是ajax访问
    formData.append('loginajax','yes');
    formData.append('pc_puyoung_loginajax','yes');
    var urlstring = 'index.php?';
    if(reglogin_check=='yes')//注册界面登录
        {
            urlstring="Register/RegLogin.php?dologin=yes"
        }
    ld.ajax({
        url:urlstring,
        type: 'POST',
        cache: false,
        data:formData,
        processData: false,
        contentType: false,
        timeout:20000,
        dataType:'json',
        success: function(data)
        {

            if(data.code==1){
                //记住密码
                if(ld("#remember_password").length>0){
                    if(ld("#remember_password").prop('checked')){
                        ld_storagepassword_bytype('set','',encode_login_password_value);//保存密码
                        ld_storagepassword_bytype('set','ldcrm_remember_password','yes');//保存记住密码勾选状态
                    }
                    else{
                        ld_storagepassword_bytype('delete','','');//清除保存的密码
                        ld_storagepassword_bytype('set','ldcrm_remember_password','no');//保存记住密码勾选状态
                    }
                }
                ld("#login_password").val('');
                // 获取当前页面的URL
                var currentUrl = new URL(window.location.href);
                // 构造新的URL
                var newUrl = new URL(data.result.href, currentUrl.origin + currentUrl.pathname);
                // 重定向到新的URL
                //alert(newUrl.href);
               // window.location.href = newUrl.href+"&v="+Math.random();

                if(reglogin_check=='yes')
                {
                    window.location.href ="index.php?action=isReg";
                    return false;
                }
                //edit:can 从英文版换回中文版后，系统内会有许多界面显示为英文，如：数据简报定制界面
                if(window.location.href.indexOf('action=Login&module=Users')>0){


                    window.location.href = newUrl.href+"&v="+Math.random();
                }
                else{
                    window.location.reload();
                }
            }
            //需跳转值其他界面
            else if(data.code==2){
                ld("#login_password").val('');
                // 获取当前页面的URL
                var currentUrl = new URL(window.location.href);
                // 构造新的URL
                var newUrl = new URL(data.result.href, currentUrl.origin + currentUrl.pathname);
                // 重定向到新的URL
                window.location.href = newUrl.href;
            }
            //产生提示信息 -- 过段时间消失
            else if(data.code == -1&&data.msg!=''){
                MessagePopup.TipZero_warning(data.msg);

            }
            //产生提示信息 -- 带有按钮
            else if(data.code == -2&&data.msg!=''){
                windowDiv(data.msg,400,'');

            }
            // 验证码错误
            else if(data.code == -3){
                windowDiv(getLoginerror('VERIFICATIONCODEERROR'),350);
                ld(formobj).find('#secutity_code').focus();
            }
            else{
                window.location.href = location.href;
            }

            if(data.code < 0){
                if(ld(formobj).find('#secutity_code').length > 0){
                    ld(formobj).find('#secutity_code').val('');
                    ld(formobj).find('#img_codepicture').click();
                }
            }
            if(data.result.ldtokenrand != undefined){
                ldtokenrand = data.result.ldtokenrand;
            }
            
        },
        error:function(jqXHR, textStatus, errorThrown)
        {
            //location.reload();
            console.log(jqXHR);
            if(jqXHR.getResponseHeader&&jqXHR.getResponseHeader('REDIRECT')){
                window.location.href = jqXHR.getResponseHeader('CONTENTPATH');
            }
            //访问超时刷新页面
            else if(textStatus == 'timeout'){
                window.location.href = location.href;
            }
            console.log(textStatus);

        }
    })
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
//获取用户对应的key
function getuserstoragekey(obj){
    var key = '';
    if(obj==undefined||obj ==''){
        obj = ld("#login_user_name");
    }
    username = ld(obj).val();
    //处理key ,
	username = username.trim();
    key = window.location.origin+window.location.pathname+username;
    return key;
}
//设置、获取、清除 浏览器缓存，默认key为用户密码对应key
function ld_storagepassword_bytype(type,key,secretpassword){
    if(key == '' || key == undefined){
        key = getuserstoragekey();    
    }
    if(secretpassword == '' || secretpassword == undefined){
        secretpassword = '';    
    }
    if(type == 'set'){
        localStorage.setItem(key, secretpassword);
    }
    else if(type == 'get'){
        return localStorage.getItem(key);
    }
    else if(type == 'delete'){
        localStorage.removeItem(key);
    }
}
//输入用户名后设置密码
function ldcrm_setpassword(obj){
    var inputusername = ld(obj).val();//用户名
    var storagepassword = ld_storagepassword_bytype('get');
    //账号直接加载对应密码
    if(ld("#login_password").length>0&&storagepassword!=undefined){
        if(ld("#remember_password").length>0&&ld("#remember_password").prop('checked')){
            storagepassword = ld_login_secret(storagepassword, inputusername, true);
            ld("#login_password").val(storagepassword);
        }
    }
}
// @edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能
function jumpForgetPassword()
{
    // var login_user_name = document.DetailView.login_user_name.value;
    var url = 'LoginForgetPassword.php?languageType='+languageType+'&step=1';
    url += '&ldtokenrand='+ldtokenrand;
    url = cls_encryptyurl.Puyoung_EncryptyurlhavephpByoriginphp(url,'','LoginForgetPassword.php');
    OpenNewWebTab(url);
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
function windowDiv(msg,width,type,title=''){  //BUG0067660 BUG0067657 xxy 2023-6-13 登陆界面弹出框样式优化
    var divobj = _createElementDiv('loginreminder');
    if(title == ''){
        title = '温馨提示';
        if(language == 'zh'){
            title = '温馨提示';
        }
        else{
            title = 'Warm prompt';
        }
    }
    var titleicon = '<div class="ld-E-ptita ld-E-ptita-left-headicon-1" style="margin:0px 10px 0px 0px"></div>'; //灯泡图标
    var div_text = '<div class="qui_dialog_body ld-dialog-Boxbody">'
    +'<div class="ld-msgDlg-Boxtop">';
    if(type == 'success'){ 
        div_text +='<div class="ld-commonImg ld-commonImg-BoxSuccess ld-msgDlg-top-icon"></div>'
    }
    else{
        div_text +='<div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon"></div>'
    }
    div_text += '</div>'
    +'<div class="ld-msgDlg-Boxbottom">'   
    +'<div class="ld-msgDlg-bottom-Boxtext" style="font-size:15px;padding-left: 8px;">'+msg
    +'</div>'
    +'</div>'
    +'</div>';
    ld(divobj).find('.ld-E-pop-tit .ld-E-ptita').html(titleicon+title);
    ld('#loginremindercontent').html(div_text);
    ld(divobj).css('max-height','500px');
    ld(divobj).css('width',width+'px');
    ld(divobj).css('background','#FDFDFD');
    ld('#loginremindercontent').css('max-height','400px');
    ld('#loginremindercontent').css('border','none');
    ld(divobj).find('div.ld-E-pbtn-bg .ld-button-cancel').remove();
    ld(divobj).find('div.ld-E-pop-tit a').remove();
    ld(divobj).find('div.ld-E-pbtn-bg .ld-button-primary').attr("onclick","fninvshnew('loginreminder');");
    fnvshobj(this,'loginreminder');  
    return divobj;
}

</script>
<script type="text/javascript">  
ld('#btn-submit-qiyeweixin').click(function(){
    
    loginCheckVersion(function(){
        alert(weixinlogin);
                if(weixinlogin == 'yes'){
                    alert(weixinloginurl);
            		var bodyWidth = window.screen.availWidth; 
                    window.location = weixinloginurl+'&languageType='+languageType+'&bodywidth='+bodyWidth;
                
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
                        ld('#weixinloginError .E_pop_tit .E_ptita').html(popTitle);
                        ld('#weixinloginError .E_ptitc').css('display','none');
                        ld('#weixinloginError .E_pbtn .E_pbtnok').val(popbtn_ok);
                      
                        ld('#weixinloginError .E_pbtn .E_pbtncancel').val(popbtn_cancel);
            
                        $('#weixinloginError .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                            fninvshnew('weixinloginError');
                            if(weixinlogin.indexOf("kehu001") > -1){
                                OpenNewWebTab('http://www.kehu001.com');
                            }else{
                                OpenNewWebTab('http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
                            }
                        });
                    });    
                       
                }
    })
});
</script>  
{/literal}
{if $login_usererror neq ''}
<script>
	var loginerror='{$login_usererror}';
	var divobj = _createElementDiv('loginreminder');
    var title = '温馨提示';
    var titleicon = '<div class="ld-E-ptita ld-E-ptita-left-headicon-1" style="margin:0px 10px 0px 0px"></div>'; //灯泡图标
	if(languageType == 'en')
		title = 'Warm prompt';

	var div_text = '<div class="qui_dialog_body ld-dialog-Boxbody">'
	+'<div class="ld-msgDlg-Boxtop">'
	+'<div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon"></div>'
	+'</div>'
	+'<div class="ld-msgDlg-Boxbottom">'   
	+'<div class="ld-msgDlg-bottom-Boxtext" style="font-size:15px;padding-left: 4px;">'+loginerror
	+'</div>'
	+'</div>'
	+'</div>';
    ld(divobj).find('.ld-E-pop-tit .ld-E-ptita').html(titleicon+title);
	ld('#loginremindercontent').html(div_text);
	ld(divobj).css('max-height','500px');
	ld(divobj).css('width','400px');
	ld(divobj).css('background','#FDFDFD');
	ld('#loginremindercontent').css('max-height','400px');
	ld('#loginremindercontent').css('border','none');
	ld(divobj).find('div.ld-E-pbtn-bg .ld-button-cancel').remove();
	ld(divobj).find('div.ld-E-pop-tit a').attr("onclick","fninvshnew('loginreminder');");
	ld(divobj).find('div.ld-E-pbtn-bg .ld-button-primary').attr("onclick","fninvshnew('loginreminder');");
	fnvshobj(this,'loginreminder');
</script>
{/if}
{if $NOREGISTER eq 0}
<script>
document.getElementById("login_password").focus();
document.getElementById("login_password").select();
</script>
{/if} 

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
        if(document.getElementById("languageType")==undefined||document.getElementById("languageType").value == 'zh'){
            
                var objdiv_title = 	'温馨提示';//标题
                var confirm_str = '清除成功！';
                windowDiv(confirm_str,400,'success',objdiv_title); //BUG0067660 xxy 2023-6-13 清除缓存清除成功弹出框样式优化，直接调用本tpl中修改好的函数，create_divobj函数用的地方多不好改
                return ;
        }
        else{
                var objdiv_title = 	'Warm prompt';//标题
                var confirm_str = 'Clear success!';
                windowDiv(confirm_str,400,'success',objdiv_title);
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
    /*var url = 'regcheck.php?languageType='+languageType;
    url += '&ldtokenrand='+ldtokenrand;
    url = cls_encryptyurl.Puyoung_EncryptyurlhavephpByoriginphp(url,'','regcheck.php');
    OpenNewWebTab(url);*/
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
function openWechatURL(url){
    var urlPath = window.location.host;//获取当前网页主机地址
    if(urlPath.indexOf("kehu001") > -1){
        window.open('http://www.kehu001.com');
    }else{
        window.open(url);
    }
}
/**中英文切换***/

ld(function(){
    ld(".crm-container-choose div").click(function(){
        ld(".crm-container-choose div label").removeClass('choosed');
        ld(this).find('label').addClass('choosed');
        var languagetype = ld(this).find('label').attr('tag');
        
        window.location='index.php?languageType='+languagetype+'&login_method=1';
    });    
});
{/literal}
</script>
                                                          
<script type="text/javascript" src="Register/login.js"></script>
</html>