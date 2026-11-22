<input type="hidden" name="email" value="{$email}" />
<input  type="hidden" name="security_code" value="{$security_code}"/>
<div class="ld-crm-container-body" style="height: 320px;">
    <div class="login-title">{if $LANGUAGETYPE eq 'zh'}找回密码{else}Retrieve password{/if}</div>
    <div class="ld-crm-container-input" style="margin-top: 20px;position: relative;">
        <input type="text" id="new_password"  value="" class="text-input" name="new_password" placeholder='{if $LANGUAGETYPE eq 'zh'}请输入您的新密码{else}New password{/if}' tabindex="1">
        <span class="errorinfo error_new_password"></span>
    </div>
    <div class="ld-crm-container-input">
        <input type="text" id="confirm_new_password" name="confirm_new_password" class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请再次确认新密码{else}Confirm the new password{/if}' tabindex="2">
        <span class="errorinfo error_confirm_new_password"></span>
    </div>
    <div class="ld-crm-container-btn">
        <a href="javascript:;" class="btn-submit inline-block" onclick="SubmitNewPassword();">{if $LANGUAGETYPE eq 'zh'}提交{else}Submit{/if}</a>
    </div>

    <div class="ld-crm-container-other" style="margin-top: auto;">
        <a href="javascript:window.close();" class="btn-submit-weixin inline-block" style="line-height: 30px;padding: 0 12px;font-size: 14px;color:#3B7CFF;">{if $LANGUAGETYPE eq 'zh'}返回登录{else}Return to login{/if}</a>
    </div>
</div>