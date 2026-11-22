{*@edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能*}
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <title>{if $LANGUAGETYPE eq 'zh'}注册授权管理{else}Registration authorization management{/if}</title>

    <link rel="stylesheet" type="text/css" href="themes/softed/component.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/leftmenu.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/swiper.css">
    <link rel="stylesheet" type="text/css" href="themes/softed/login-new.css">

    <link rel="stylesheet" href="themes/softed/popup.css" type="text/css" />

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var languageType='{$LANGUAGETYPE}';
        var language='{$LANGUAGETYPE}';
        var global_js_url ='{$JSURL}';
    </script>
    <script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/swiper.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjax.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_encryptyurl.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/crypto-js.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/component/ld_Select.js"></script>

</head>
<body>
<div id="root">
    {include file="loginswiperblock.tpl"}
    <form action="index.php" method="post" name="DetailView" id="form_forgetpwd" style="width: 100%;">
        <div name="registration" class="ld_form_login" style="{if $SWIPERRATIO == '1:2'}box-shadow: 0px 2px 8px 0px rgba(200,201,204,0.7);{/if}">
            <div class="ld-crm-container-body" style="height: 320px;">
                <div class="login-title">{if $LANGUAGETYPE eq 'zh'}注册授权管理{else}Registration authorization management{/if}</div>
                <div class="login-subtitle">需要验证管理员身份才能进行注册授权管理</div>
                <div class="ld-crm-container-input" style="margin-top: 20px;">
                    <input type="text" id="login_user_name"  value="{$LOGINUSERNAME}" class="text-input" name="login_user_name" {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" readonly="true" class="disable"{else}{/if} placeholder='{if $LANGUAGETYPE eq 'zh'}请输入账号{else}Username{/if}' tabindex="1" autocomplete="off"/>
                    <span class="errorinfo error_name"></span>
                </div>
                <div class="ld-crm-container-input">
                    <input type="password" id="login_password" onfocus="this.type='password'" name="login_user_password"  {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" class="text-input password disable" {else}{/if} class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请输入密码{else}Password{/if}' tabindex="2" autocomplete="off"/>
                    <span class="errorinfo error_pwd"></span>
                </div>
                <div class="ld-crm-container-btn">
                    <a href="javascript:;" class="btn-submit inline-block" onclick="">确认</a>
                </div>
                <div class="ld-crm-container-other">
                    <div class="ld-crm-container-other-list">
                        {if $WXLOGINBTN.isshow eq 'yes'}
                            {if $WEIXINLOGIN eq 'yes'}
                                <div class="other-login-item" id="btn-submit-qiyeweixin">
                                    <div class="other-login-item-img"></div>
                                    <div class="other-login-item-label">{$WXLOGINBTN.after_zh_content}</div>
                                </div>
                            {/if}
                        {/if}
                    </div>
                </div>
            </div>
        </div>
    </form>
    <div class="ld-loginform-afterdiv">
        <a href="javascript:void(0);">版本号: 8.6.4.8</a>
        <a href="javascript:void(0);" style="padding-left: 13px;border-left: 1px solid #DCDEE0;">序列号: 123456789</a>
    </div>
</div>
</section>
</main>
</div>
</body>
</html>
<script>
    var global_loginpage_url_arr = {$global_loginpage_url_arr};
    {literal}
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
    {/literal}

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

    {literal}
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

    function getLoginerror(labelbol)
    {
        var enjspop={'USERNAMECANOTEMPTY':'User name can not be empty!',
            'VERIFICATIONCODENOTEMPTY':'Verification code can not be empty!',
            'VERIFICATIONCODEERROR':'Verification code is incorrect, please re-enter!',
            'EMAILNOTEMPTY':'Email cannot be empty!',
            'EmailFormatError':'Email format error!',
            'NEWPWDNOTEMPTY':'New password cannot be empty!',
            'CONFIRMPWDNOTEMPTY':'Confirm password cannot be empty!',
            'PASSWORDINCONSISTENT':'The new password is inconsistent with the confirmed password, please reenter!',
            'SENDSUCCESSFULLY':'Send successfully!',
            'SendFailed':'Send failed!',
            'EmailNotExist':'User account information does not exist, please contact the CRM admin!',
            'VerificationCodeError':'The verification code is incorrect or invalid, please try again!',
            'ResetPasswordSuccessfully':'Reset password successfully!',
            'ResetPasswordFailed':'Reset password failed!',
        };

        var zhjspop={'USERNAMECANOTEMPTY':'账号不能为空！',
            'VERIFICATIONCODENOTEMPTY':'验证码不能为空！',
            'VERIFICATIONCODEERROR':'验证码不正确，请重新输入！',
            'EMAILNOTEMPTY':'邮箱不能为空！',
            'EmailFormatError':'邮箱格式错误！',
            'NEWPWDNOTEMPTY':'新密码不能为空！',
            'CONFIRMPWDNOTEMPTY':'确认密码不能为空！',
            'PASSWORDINCONSISTENT':'新密码与确认密码不一致，请重新输入！',
            'SENDSUCCESSFULLY':'发送成功！',
            'SendFailed':'发送失败！',
            'EmailNotExist':'用户账号信息不存在，请联系CRM管理员！',
            'VerificationCodeError':'验证码错误或已失效，请重试！',
            'ResetPasswordSuccessfully':'重置密码成功！',
            'ResetPasswordFailed':'重置密码成功！',
        };

        if(languageType=='zh')
        {
            return zhjspop[labelbol];
        }
        else
        {
            return enjspop[labelbol];
        }
    }
    {/literal}
</script>
