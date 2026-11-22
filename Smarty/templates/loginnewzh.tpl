<header class="crm-container-title">
  <h1>{$LOGINWELCOME.after_zh_content}</h1>
</header>
<div class="crm-container-choose" {if $ENORZH eq 'no'} style="display:none"{/if}>
  <div>
    <label class="choosed" tag="zh">中文</label>
  </div>
  <div>                
    <label tag="en">English</label>
  </div>
</div>
<div class="crm-container-body">
  <ul>
    <li>
      <div class="crm-container-input">
        <input type="text" id="login_user_name"  value="{$LOGINUSERNAME}" class="text-input" name="login_user_name" {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" readonly="true" class="disable"{else}{/if} placeholder='请输入账号' tabindex="1" autocomplete="off"/>
      </div>
      <span class="errorinfo error_name"></span>
    </li>
    <li>
      <div class="crm-container-input">
        <input type="password" id="login_password" onfocus="this.type='password'" name="login_user_password"  {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" class="password disable" {else}{/if} class="text-input"  placeholder='请输入密码' tabindex="2" autocomplete="off"/>

      </div>
      <span class="errorinfo error_pwd"></span>
    </li>
    {if $CODE neq ''}
      <li>
        <div class="crm-container-input">
          <input type="text"  class="text-input" id="secutity_code" name="secutity_code" placeholder='请输入验证码' tabindex="3">
          <img id="img_codepicture" src="picture.php?code={$CODE}" width="79" height="29" onclick="yzm_change(this);">
        </div>
        <span class="errorinfo error_yanzhengma"></span>
      </li>
    {/if}
  </ul>
    <div style="font-size: 16px;cursor: pointer;height: 23px;padding-bottom: 3px;margin-bottom: 10px;width: 100%;">
        {if $have_remember_password eq 'yes'}
            <div  style="float:left;line-height:1;">
                <input class="checkbox-item" type="checkbox" id="remember_password"  value="rempassword"  />
                <label  for="remember_password">记住密码</label>
            </div>
        {/if}
    <div style="float:right;line-height:1;">
        <span class="" style="font-size: 16px;float: right;cursor: pointer;" onclick="jumpForgetPassword();">找回密码</span>
    </div>
    </div>
</div>

 {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq ''||$EXPIREDTIP eq 'yes'|| $EXPIRINGTIP eq 'yes'||$REGTESTTIP neq ''}
     <div class="divError">
         <span class="errorinfo error_all">
            {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}
            
            {else if $LOGIN_ERROR neq ''}{$LOGIN_ERROR}
            
            
            
             {else if $EXPIRINGTIP  eq  'yes'}
                
                     您的软件{$EXPIREDDAYS}天后即将到期，<a href="index.php?action=isReg">点击显示授权信息</a>
                 
         {else if $EXPIREDTIP eq 'yes'}
                  
                     您的软件已经过期，请<a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">立即注册</a>！
                
              {else if $REGTESTTIP eq 'yes'}
                
                    您的软件仅供内部演示使用，不可销售给客户！
                
              
            
            {/if}    
         </span>
                                                                                       
     </div>
{/if}
{if $NOREGISTER eq 0}
  <div class="divError">
    <span class="errorinfo error_all">
        未注册不允许登录，请<a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">立即注册</a>
    </span>
  </div>
{/if}

<div class="crm-container-btn">
  <a href="javascript:;" class="btn-submit inline-block" {if $NOREGISTER neq 0}onclick="return Check();"{/if} {if $NOREGISTER eq 0}style="cursor: not-allowed;"{/if}>登     录</a>    
    {if $WXLOGINBTN.isshow eq 'yes'}
        {if $WEIXINLOGIN eq 'yes'}
            <a href="javascript:;"  class="btn-submit-weixin inline-block" style="margin-left: 40px;{if $NOREGISTER eq 0}cursor: not-allowed;{/if}"><i class="icon-qy-wexi-qywx-login"></i>{$WXLOGINBTN.after_zh_content}</a>
        {else}
            <a href="javascript:;" class="btn-submit-installweixin inline-block" style="margin-left: 40px;{if $NOREGISTER eq 0}cursor: not-allowed;{/if}" {if $NOREGISTER neq 0}onclick="openWechatURL('{$LOGININFO.weixin.content}');"{/if} ><i class="icon-qy-wexi-qywx-login"></i>{$LOGININFO.weixin.zh}</a>
        {/if}
    {/if}
</div>
{* {if $NOREGISTER neq 1 ||$EXPIREDTIP eq 'yes'}
  <div class="crm-container-register">
    <a href="index.php?action=isReg" >立即注册</a>
  </div>
{/if} *}
</div>