{*@edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能*}
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <title>{if $LANGUAGETYPE eq 'zh'}找回密码{else}Retrieve password{/if}</title>

    <link rel="stylesheet" type="text/css" href="themes/softed/login-new.css">
    <link rel="stylesheet" href="themes/softed/popup.css" type="text/css" />
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var languageType='{$LANGUAGETYPE}';
        var global_js_url ='{$JSURL}';
        var ldtokenrand ='{$ldtokenrand}';
    </script>
    <script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjax.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_encryptyurl.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/crypto-js.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" language="JavaScript">
        function set_focus() {
            if (document.DetailView.email.value == '') {
                document.DetailView.email.focus();
                document.DetailView.email.select();
            } else if (document.DetailView.email_security_code.value == '') {
                document.DetailView.email_security_code.focus();
                // document.DetailView.email_security_code.select();
            }
        }

        function keyLogin(event){
            var e = event||window.event;
            var keyCode  =  e.keyCode||e.which;
            if(keyCode == 13){
                CheckForgetPassword();
            }
        }
    </script>

</head>
<body onload="set_focus()" onkeyup="keyLogin(event);">
<section class="crm-container">
    <div class="crm-container-bg" style="background:url({$LOGININFO.backgroundbg.content});">
        <div class="crm-container-form  {if $LOGININFO.loginlocation.content eq '中'}crm-container-form-center{elseif $LOGININFO.loginlocation.content eq '左'} crm-container-form-left{else}crm-container-form-right{/if}">

            <form action="index.php" method="post" name="DetailView" id="form_forgetpwd" >
                <div name="forgetpassword">
                    {include file="LoginForgetPasswordEntries.tpl"}
                </div>
            </form>

        </div>
</section>
</body>
</html>
<script>
    //获取验证码
    function get_security_code() {
        //检查邮箱
        var form=document.forms['DetailView'];
        if(form.email.value==''){
            windowDiv(getLoginerror('EMAILNOTEMPTY'));
            form.email.focus();
            return false;
        }else{
            var reg = /^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/;
            var isok= reg.test(form.email.value);
            if (!isok) {
                windowDiv(getLoginerror('EmailFormatError'));
                form.email.focus();
                return false;
            }
        }

        ldAjax('LoginForgetPassword.php',"step=2&email="+form.email.value+'&ldtokenrand='+ldtokenrand,function (data) {
            if(data.code==1) {
                // audioRemindsMsg("","","","","",data.msg);
                // windowDiv(data.msg);
                windowDiv(getLoginerror('SENDSUCCESSFULLY'));
                return true;
            }else if (data.code=='-1'){
                windowDiv(getLoginerror('SendFailed'));
            }else if (data.code=='-2'){
                windowDiv(getLoginerror('EmailNotExist'));
            }else if (data.code=='-3'){
                windowDiv(getLoginerror('EMAILNOTEMPTY'));

            }
            if(data.result.ldtokenrand != undefined){
                ldtokenrand = data.result.ldtokenrand;
            }
            return false;
        });

    }


    //检查验证码
    function CheckForgetPassword(){
        var form=document.forms['DetailView'];

        if(form.email.value==''){
            windowDiv(getLoginerror('EMAILNOTEMPTY'));
            form.email.focus();
            return false;
        }else{
            var reg = /^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/;
            var isok= reg.test(form.email.value);
            if (!isok) {
                windowDiv(getLoginerror('EmailFormatError'));
                form.email.focus();
                return false;
            }
        }

        if(form.email_security_code.value==''){
            // var confirm_str = arrJsPopLabel['VERIFICATIONCODENOTEMPTY'];
            // audioRemindsMsg("","","","","",confirm_str);
            windowDiv(getLoginerror('VERIFICATIONCODENOTEMPTY'));
            form.email_security_code.focus();
            return false;
        }

        if(document.getElementById('email_security_code')!='undefined'&&document.getElementById('email_security_code')!=undefined)
        {
            ldAjax('LoginForgetPassword.php',"step=3&email="+form.email.value+"&security_code="+form.email_security_code.value+'&ldtokenrand='+ldtokenrand,function(data){
                if(data.code==1)
                {
                    ldAjax("LoginForgetPassword.php","step=4&email="+form.email.value+"&languageType="+languageType+"&security_code="+form.email_security_code.value+'&ldtokenrand='+ldtokenrand,function (data){
                        if(data.code==1)
                        {
                            ld("div[name=forgetpassword]").html(data.result.content);

                            // document.getElementsByName('forgetpassword').innerHTML(data.result.content);
                        }
                        if(data.result.ldtokenrand != undefined){
                            ldtokenrand = data.result.ldtokenrand;
                        }
                    });
                    return true;
                }
                else
                {
                    // windowDiv(data.msg);
                    windowDiv(getLoginerror('VerificationCodeError'));
                    form.email_security_code.focus();
                    return false;
                }
                if(data.result.ldtokenrand != undefined){
                    ldtokenrand = data.result.ldtokenrand;
                }
            })
        }

        return false;
    }

    //重置密码
    function SubmitNewPassword() {
        var form=document.forms['DetailView'];

        //检查密码
        if(form.new_password.value==''){
            windowDiv(getLoginerror('NEWPWDNOTEMPTY'));
            form.new_password.focus();
            return false;
        }

        if(form.confirm_new_password.value==''){
            windowDiv(getLoginerror('CONFIRMPWDNOTEMPTY'));
            form.confirm_new_password.focus();
            return false;
        }

        if (form.new_password.value != form.confirm_new_password.value){
            windowDiv(getLoginerror('PASSWORDINCONSISTENT'));
            form.confirm_new_password.focus();
            return false;
        }

        var email = ld("input[name=email]").val();
        var security_code=ld("input[name=security_code]").val()
        ldAjax("LoginForgetPassword.php","step=5&email="+encodeURIComponent(email)+"&new_password="+encodeURIComponent(form.new_password.value)+"&security_code="+security_code+'&ldtokenrand='+ldtokenrand,function (data){
            if(data.code==1)
            {
                // windowDiv(data.msg);
                windowDiv(getLoginerror('ResetPasswordSuccessfully'));
                //2秒后，自动关闭提示弹出层
                setTimeout(function(){
                    window.close();
                    return false;
                }, 2000);
            }else{
                windowDiv(getLoginerror('ResetPasswordFailed'));
                return false;
            }
            if(data.result.ldtokenrand != undefined){
                ldtokenrand = data.result.ldtokenrand;
            }
        });
    }



    function windowDiv(msg){
        var divobj = _createElementDiv('loginreminder');
        var title = '温馨提示';
        if(languageType == 'en')
            title = 'Warm prompt';
        var div_text = '<div class="qui_dialog_body ww_dialog_body">'
            +'<div class="msgDlg_left">'
            +'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
            +'</div>'
            +'<div class="msgDlg_right">'
            +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+msg
            +'</div>'
            +'</div>'
            +'</div>';
        ld(divobj).find('.E_pop_tit .E_ptita').html(title);
        ld('#loginremindercontent').html(div_text);
        ld(divobj).css('max-height','500px');
        ld(divobj).css('width','350px');
        ld(divobj).css('background','#FDFDFD');
        ld('#loginremindercontent').css('max-height','400px');
        ld('#loginremindercontent').css('border','none');
        ld(divobj).find('div.D_pbtn .D_pbtncancel').remove();
        ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
        ld(divobj).find('div.E_pop_tit a').remove();
        ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","fninvshnew('loginreminder');");
        fnvshobj(this,'loginreminder');
    }

    {literal}
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
            divObj.className = 'E_pop_box LdPopWidth650px';
            divObj.style.position = "absolute";
            divObj.style.zIndex = "10001";
            divObj.style.top = "120px";
            divObj.style.left = "350px";
            //divObj.style.maxHeight = "200px";
            divObj.style.display = "none";
            //divObj.style.backgroundColor = "#ffffff";
            document.body.appendChild(divObj);
            divObj.innerHTML = '<div class="E_pop_tit">'+
                '<strong class="E_ptita" id="'+divid+'titlename"></strong>'+
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
            ld('#'+divid+' .E_pop_tit .E_ptitc').on('click',function(){
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
