<div class="ld-crm-container-body" style="height: 320px;">
    <div class="login-title">{if $LANGUAGETYPE eq 'zh'}找回密码{else}Retrieve password{/if}</div>
    <div class="ld-crm-container-input" style="margin-top: 20px;position: relative;">
        <input type="text" id="email" style="{if $LANGUAGETYPE eq 'zh'}padding-right: 100px;{else}padding-right: 145px;{/if}" value="" class="text-input" name="email" placeholder="{if $LANGUAGETYPE eq 'zh'}请输入您的邮箱{else}Email{/if}" tabindex="1">
        <span class="getsecuritycode" onclick="get_security_code();">{if $LANGUAGETYPE eq 'zh'}获取验证码{else}Get verification code{/if}</span>
        <span class="errorinfo error_email"></span>
    </div>
    <div class="ld-crm-container-input">
        <input type="text" id="email_security_code" name="email_security_code" class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请输入您的验证码{else}Verification code{/if}' tabindex="2">
        <span class="errorinfo error_email_security_code"></span>
    </div>
    <div class="ld-crm-container-btn">
        <a href="javascript:;" class="btn-submit inline-block" onclick="return CheckForgetPassword();">{if $LANGUAGETYPE eq 'zh'}下一步{else}Next step{/if}</a>
    </div>

    <div class="ld-crm-container-other" style="margin-top: auto;">
        <a href="javascript:window.close();" class="btn-submit-weixin inline-block" style="line-height: 30px;padding: 0 12px;font-size: 14px;color:#3B7CFF;">{if $LANGUAGETYPE eq 'zh'}返回登录{else}Return to login{/if}</a>
    </div>
</div>