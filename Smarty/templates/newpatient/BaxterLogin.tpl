<!-- XUQIU1001174  ls 20230426 百特集成okta -->
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.js"></script>
<!-- <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.css" type="text/css" /> -->
<style>
    .form-control {
        display: block;
        width: 100%;
        height: calc(1.5em + 0.75rem + 2px);
        padding: 0.375rem 0.75rem;
        font-size: 1rem;
        font-weight: 400;
        line-height: 1.5;
        color: #495057;
        background-color: #fff;
        background-clip: padding-box;
        border: 1px solid #ced4da;
        border-radius: 0.25rem;
        transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
    }
</style>
<header class="crm-container-title">
  <h1>{$LOGINWELCOME.after_zh_content}</h1>
</header>
<!-- <div class="crm-container-choose" {if $ENORZH eq 'no'} style="display:none"{/if}>
  <div>
    <label class="choosed" tag="zh">中文</label>
  </div>
  <div>                
    <label tag="en">English</label>
  </div>
</div> -->

<!-- <div class="form-group crm-container-body">
    <select name='choose_login_type' onchange="chooseLoginType(this)" class="form-control">
        <option value="crm">员工账号登录</option>
        <option value="okta" selected>Okta登录</option>
    </select>
</div>  -->

<div class="crm-container-body">
  <ul>
    <li>
        <div class="crm-container-input">
            <select name='choose_login_type' onchange="chooseLoginType(this)" class="text-input" style="color:#FFF;width: 100%;">
                <option value="crm" style="color:#475095;">员工账号登录</option>
                <option value="okta" style="color:#475095;" selected>Okta登录</option>
            </select>
        </div>
    </li>
    <li>
      <div class="crm-container-input">
        <input type="text" id="login_user_name"  value="{$LOGINUSERNAME}" class="text-input" name="login_user_name" {if $EXPIREDTIP eq 'yes' || $NOREGISTER eq '0'} disabled="true" readonly="true" class="disable"{else}{/if} placeholder='请输入账号' tabindex="1">
      </div>
      <span class="errorinfo error_name"></span>
    </li>
    <li>
      <div class="crm-container-input">
        <input type="password" id="login_password" name="login_user_password"  {if $EXPIREDTIP eq 'yes'} disabled="true" class="password disable" {else}{/if} class="text-input"  placeholder='请输入密码' tabindex="2">
        <!-- <span class="" style="font-size: 16px;float: right;cursor: pointer;" onclick="jumpForgetPassword();">找回密码</span> -->
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
</div>
 {if $LOGIN_ERROR neq '' || $WEIXINLOGINERROR neq ''||$EXPIREDTIP eq 'yes'|| $EXPIRINGTIP eq 'yes'||$REGTESTTIP neq ''}
     <div class="divError">
         <span class="errorinfo error_all">
            {if $WEIXINLOGINERROR neq ''}{$WEIXINLOGINERROR}
            {else if $LOGIN_ERROR neq ''}{$LOGIN_ERROR}
            {else if $EXPIRINGTIP  eq  'yes'}  
                您的软件{$EXPIREDDAYS}天后即将到期，请联系供应商！   
            {else if $EXPIREDTIP eq 'yes'}    
                您的软件已经过期，请联系供应商！  
            {else if $REGTESTTIP eq 'yes'}
                您的软件仅供内部演示使用，不可销售给客户！
            {/if}    
         </span>
                                                                                       
     </div>
{/if}
<!-- <div class="crm-container-btn">
  <a href="javascript:;" class="btn-submit inline-block" onclick="return Check();">登     录</a>    
    {if $WXLOGINBTN.isshow eq 'yes'}
        {if $WEIXINLOGIN eq 'yes'}
            <a href="javascript:;"  class="btn-submit-weixin inline-block" style="margin-left: 40px;"><i class="icon-qy-wexi-qywx-login"></i>{$WXLOGINBTN.after_zh_content}</a>
        {else}
            <a href="javascript:;" class="btn-submit-installweixin inline-block" style="margin-left: 40px;" onclick="openWechatURL('{$LOGININFO.weixin.content}');"><i class="icon-qy-wexi-qywx-login"></i>{$LOGININFO.weixin.zh}</a>
        {/if}
    {/if}
</div> -->
<div class="crm-container-btn">
    <a href="javascript:;" class="btn-submit inline-block" onclick="return BaxterCheck();">登 录</a>
</div>
<!-- {if $NOREGISTER neq 1 ||$EXPIREDTIP eq 'yes'}
  <div class="crm-container-register">
    <a href="index.php?action=isReg" >立即注册</a>
  </div>
{/if} -->
</div>

{literal}
<script>
//baxter 切换登录
function chooseLoginType(obj){
    var choose_login_type = ld(obj).val();

    if(choose_login_type == 'okta'){
        ld(" [name=login_user_name]").closest('li').hide();
        ld(" [name=login_user_password]").closest('li').hide();
        ld(" [name=secutity_code]").closest('li').hide();
    }else{
        ld(" [name=login_user_name]").closest('li').show();
        ld(" [name=login_user_password]").closest('li').show();
        ld(" [name=secutity_code]").closest('li').show();

    }
}
ld(" select[name='choose_login_type']").change();


//百特登录按钮
function BaxterCheck(){
    var choose_login_type = ld(" select[name='choose_login_type']").val() || "okta";
    var formobj=ld("#form_login").get(0);
    // var code=ld(formobj).find('#code').val();
    var bodyWidth = window.screen.availWidth;	//屏幕可用工作区宽度

    //获取屏幕分辨率的可见宽度
    if(document.getElementById('bodywidth') != undefined){
        document.getElementById('bodywidth').value = bodyWidth;
    }

    //邹晓宇 让去掉登录页的输入邮箱验证的动作
    /*if(form.login_user_name.value==''){   
        windowDiv(getLoginerror('USERNAMECANOTEMPTY'),350);
        form.login_user_name.focus();
        return false;
    }*/

    localStorage.setItem('baxter_login_type', choose_login_type);
    if (choose_login_type == 'okta') {
        console.log('okta login');
        loginCheckVersion(function(){

            // window.location.href='baxter/index.php?operatetype=login&login_email='+encodeURIComponent(ld(" [name=login_user_name]").val());
            // var url = 'baxter/index.php?operatetype=login&login_email='+encodeURIComponent(ld(" [name=login_user_name]").val());
            var url = 'baxter/index.php?operatetype=login';
            ldAjax(url,"",function(data){
                // console.log(data);
                if(data.code == 1){
                  location.href=data.result.url;
                }else{
                  windowDiv(data.msg,350);
                }
                DelProgressObjs();
            })


            return;  
        
        })
    }else{

        if(ld(formobj).find('#secutity_code')!=undefined){
            if(ld(formobj).find('#secutity_code').val()==''){
                windowDiv(getLoginerror('VERIFICATIONCODENOTEMPTY'),400);
                ld(formobj).find('#secutity_code').focus();
                return false;
            }
        }

        if(document.getElementById('secutity_code')!='undefined'&&document.getElementById('secutity_code')!=undefined)
        {
            $.ajax({
                url:'picture.php',
                type:'POST', 
                async:false,   
                data:{
                    code:'2',age:25,'textvalue':document.getElementById('secutity_code').value
                },
                timeout:5000,    //超时时间
                dataType:'text',    //返回的数据格式：json/xml/html/script/jsonp/text
                
                success:function(data,textStatus,jqXHR)
                {
                           if(data.indexOf('$$ERROR$$')>=0)
                           {
                                windowDiv(getLoginerror('VERIFICATIONCODEERROR'),350);
                               ld(formobj).find('#secutity_code').focus();
                                return false;
                           }
                           else
                         {
                            loginCheckVersion(function(){

                                ld_login_submit();
                            })
                            return true;
                         }
                   
                 }
                     
                    
            })
        }
       else
       {
            loginCheckVersion(function(){
                ld_login_submit();
            })
             
       }

    }

    
    
    
    
   
     
    
   
   //（71mis.com/ldcrm）用电话小管家登录时，输入账号密码点击登录没有反应。（需要连续点击多次登录按钮才有反应）
    return false;
     
}

</script>
{/literal}