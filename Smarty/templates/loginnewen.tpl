<header class="crm-container-title">
  <h1>{$LOGINWELCOME.after_en_content}</h1>
</header>
<div class="crm-container-choose" {if $ENORZH eq 'no'} style="display:none"{/if}>
  <div>
    <label  tag="zh">中文</label>
  </div>
  <div>                
    <label class="choosed" tag="en">English</label>
  </div>
</div>
<div class="crm-container-body">
  <ul>
    <li>
      <div class="crm-container-input">
        <input type="text" id="login_user_name"  value="{$LOGINUSERNAME}" class="text-input" name="login_user_name" {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" class="disable"{else}{/if} placeholder='Username' tabindex="1" autocomplete="off"/>
      </div>
      <span class="errorinfo error_name"></span>
    </li>
    <li>
      <div class="crm-container-input">
        <input type="password" id="login_password" onfocus="this.type='password'" name="login_user_password"  {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" class="password disable" {else}{/if} class="text-input"  placeholder='Password' tabindex="2" autocomplete="off"/>

      </div>
      <span class="errorinfo error_pwd"></span>
    </li>
    {if $CODE neq ''}
      <li>
        <div class="crm-container-input">
          <input type="text"  class="text-input" id="secutity_code" name="secutity_code" placeholder='Code' tabindex="3">
          <img id="img_codepicture" src="picture.php?code={$CODE}" width="79" height="29" onclick="yzm_change(this);">
        </div>
        <span class="errorinfo error_yanzhengma"></span>
      </li>
    {/if}
  </ul>
  <div style="font-size: 16px;cursor: pointer;height: 23px;padding-bottom: 3px;margin-bottom: 10px;width: 100%;">
      {if $have_remember_password eq 'yes'}
          <div style="float:left;line-height:1;">
              <input class="checkbox-item" type="checkbox" id="remember_password"  value="rempassword"  />
              <label  for="remember_password">Remember password</label>
          </div>
      {/if}
      <div style="float:right;line-height:1;">
          <span class="" style="font-size: 16px;float: right;cursor: pointer;" onclick="jumpForgetPassword();">Forget the password?</span>
      </div>
    </div>
</div>
 {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq ''||$EXPIREDTIP  eq 'yes'|| $EXPIRINGTIP eq 'yes'||$REGTESTTIP neq ''}
     <div class="divError">
         <span class="errorinfo error_all">
            {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}
            
            {else if $LOGIN_ERROR neq ''}{$LOGIN_ERROR}
            
            
            
             {else if $EXPIRINGTIP  eq  'yes'}
                
                    Your software will expire in {$EXPIREDDAYS} days, ，<a href="index.php?action=isReg">please click show info</a>
                
         {else if $EXPIREDTIP eq 'yes'}
                 
                    Your software has expired, please <a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">Register now</a>!
                 
              {else if $REGTESTTIP eq 'yes'}
                 
                    Your software is for internal demo use only, not allowed to sell to customers！
                  
              
            
            {/if}   
         </span>
                                                                                
     </div>
{/if}
{if $NOREGISTER eq 0}
  <div class="divError">
    <span class="errorinfo error_all">
        You are not allowed to log in without registering, please <a href="index.php?action=isReg" style="color: #fa7252;text-decoration: underline;">Register now</a>
    </span>
  </div>
{/if}
<div class="crm-container-btn">
  <a href="javascript:;" class="btn-submit inline-block" {if $NOREGISTER neq 0}onclick="return Check();"{/if} {if $NOREGISTER eq 0}style="cursor: not-allowed;"{/if}>Login</a>
    {if $WXLOGINBTN.isshow eq 'yes'}
        {if $WEIXINLOGIN eq 'yes'}
            <a href="javascript:;"  class="btn-submit-weixin inline-block" style="margin-left: 40px;{if $NOREGISTER eq 0}cursor: not-allowed;{/if}"><i class="icon-qy-wexi-qywx-login"></i>{$WXLOGINBTN.after_en_content}</a>
        {else}
            <a href="javascript:;" class="btn-submit-installweixin inline-block" style="margin-left: 40px;{if $NOREGISTER eq 0}cursor: not-allowed;{/if}" {if $NOREGISTER neq 0}onclick="openWechatURL('{$LOGININFO.weixin.content}');"{/if} ><i class="icon-qy-wexi-qywx-login"></i>{$LOGININFO.weixin.en}</a>
        {/if}
    {/if}
</div>
{* {if $NOREGISTER neq 1||$EXPIREDTIP eq 'yes'}
  <div class="crm-container-register">
    <a href="index.php?action=isReg">Register now</a>
  </div>
{/if} *}
</div>