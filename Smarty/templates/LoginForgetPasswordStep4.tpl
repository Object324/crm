{*@edit:liushuai,2021-04-21,reason:【ID1001464】增加忘记密码功能*}
<header style="text-align:left;text-indent: 20px;">
    <h1>{if $LANGUAGETYPE eq 'zh'}请设置新的登录密码{else}New password{/if}</h1>
</header>
<input type="hidden" name="email" value="{$email}" />
<input  type="hidden" name="security_code" value="{$security_code}"/>
<div class="crm-container-body">
    <ul>
        <li>
            <div class="crm-container-input">
                <input type="text" id="new_password"  value="" class="text-input" name="new_password" placeholder='{if $LANGUAGETYPE eq 'zh'}请输入您的新密码{else}New password{/if}' tabindex="1">
            </div>
            <span class="errorinfo error_new_password"></span>
        </li>
        <li>
            <div class="crm-container-input">
                <input type="text" id="confirm_new_password" name="confirm_new_password" class="text-input"  placeholder='{if $LANGUAGETYPE eq 'zh'}请再次确认新密码{else}Confirm the new password{/if}' tabindex="2">
            </div>
            <span class="errorinfo error_confirm_new_password"></span>
        </li>
    </ul>
</div>

<div class="crm-container-btn">
    <a href="javascript:;" class="btn-submit inline-block" onclick="SubmitNewPassword();">{if $LANGUAGETYPE eq 'zh'}提交{else}Submit{/if}</a>
</div>


