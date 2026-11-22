{*@edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能*}
<header style="text-align:left;text-indent: 20px;">
    <h1>{if $LANGUAGETYPE eq 'zh'}找回密码{else}Retrieve password{/if}</h1>
</header>

<div class="crm-container-body">
    <ul>
        <li>
            <div class="crm-container-input">
                <input type="text" id="email"  value="" class="text-input" style="width: 60%;" name="email" placeholder="{if $LANGUAGETYPE eq 'zh'}请输入您的邮箱{else}Email{/if}" tabindex="1">
                <span class="" style="font-size: 16px;float: right;cursor: pointer;" onclick="get_security_code();">{if $LANGUAGETYPE eq 'zh'}获取验证码{else}Get verification code{/if}</span>
            </div>
            <span class="errorinfo error_email"></span>
        </li>
        <li>
            <div class="crm-container-input">
                <input type="text" id="email_security_code" name="email_security_code" class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请输入您的验证码{else}Verification code{/if}' tabindex="2">
            </div>
            <span class="errorinfo error_email_security_code"></span>
        </li>
    </ul>
</div>

<div class="crm-container-btn">
    <a href="javascript:;" class="btn-submit inline-block" onclick="return CheckForgetPassword();">{if $LANGUAGETYPE eq 'zh'}下一步{else}Next step{/if}</a>

{*    <a href="javascript:;" class="btn-submit-weixin inline-block" style="margin-left: 40px;width: 130px;">取消</a>*}
    <a href="javascript:window.close();" class="btn-submit-weixin inline-block" style="margin-left: 40px;width: 130px;">{if $LANGUAGETYPE eq 'zh'}取消{else}Cancel{/if}</a>
</div>


