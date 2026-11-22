{*@edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能*}
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <title>{if $LANGUAGETYPE eq 'zh'}找回密码{else}Retrieve password{/if}</title>

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
        var pagestep = '{$STEP}';
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
    <script type="text/javascript" language="JavaScript">
        function set_focus() {
			if(pagestep == '1'){
				if (document.DetailView.email.value == '') {
					document.DetailView.email.focus();
					document.DetailView.email.select();
				} else if (document.DetailView.email_security_code.value == '') {
					document.DetailView.email_security_code.focus();
					// document.DetailView.email_security_code.select();
				}
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
    <div id="root">
        {include file="loginswiperblock.tpl"}
        <form action="index.php" method="post" name="DetailView" id="form_forgetpwd" style="width: 100%;">
            <div name="forgetpassword" class="ld_form_login" style="{if $SWIPERRATIO == '1:2'}box-shadow: 0px 2px 8px 0px rgba(200,201,204,0.7);{/if}">
                {if $STEP == '4'}
                    {include file="LoginForgetPasswordStep4Swiper.tpl"}
                {else}
                    {include file="LoginForgetPasswordEntriesSwiper.tpl"}
                {/if}
            </div>
        </form>
        {include file="loginswiperblockfooler.tpl"}
    </div>
</body>
</html>
<script>
    var global_loginpage_url_arr = {$global_loginpage_url_arr};
    var ldtokenrand = "{$ldtokenrand}";
    {literal}
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
                var tmp_languagetype = evt.NavBarItem.value;
                var url = '';
                if(pagestep == 1){
                    url='LoginForgetPassword.php?languageType='+tmp_languagetype+'&step='+pagestep;
                }
                else{
                    var form=document.forms['DetailView'];
                    url="LoginForgetPassword.php?step=4&email="+form.email.value+"&languageType="+tmp_languagetype+"&security_code="+form.security_code.value;
                }
                url += '&ldtokenrand='+ldtokenrand;
                var cls_encryptyurlobj = new cls_encryptyurl();
                cls_encryptyurlobj.origin_php = 'LoginForgetPassword.php';
                url =cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(url,'');
                window.location=url;
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
    {/literal}

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
            ldAjax('LoginForgetPassword.php',"step=3&email="+form.email.value+"&security_code="+form.email_security_code.value+'&ldtokenrand='+ldtokenrand,function (data) {
                if(data.code==1)
                {
                    ldAjax("LoginForgetPassword.php","ajax=yes&step=4&email="+form.email.value+"&languageType="+languageType+"&security_code="+form.email_security_code.value+'&ldtokenrand='+ldtokenrand,function(data){
                        if(data.code==1)
                        {
                            ld("div[name=forgetpassword]").html(data.result.content);
                            pagestep = '4';
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
            });
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
        var security_code=ld("input[name=security_code]").val();
        ldAjax("LoginForgetPassword.php","step=5&email="+encodeURIComponent(email)+"&new_password="+encodeURIComponent(form.new_password.value)+"&security_code="+security_code+'&ldtokenrand='+ldtokenrand,function(data){
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

    //授权信息
    function getRootPath(){
        //获取当前网址，如： http://localhost:8088/crm/index.php
        var curPath=window.document.location.href;
        //获取主机地址之后的目录，如： crm/index.php
        var pathName=window.document.location.pathname.split('LoginForgetPassword.php');
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
    //清除缓存
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
    {/literal}
</script>
