<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />  
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
<title>{$TITLE}</title> 
<script language="javascript" type="text/javascript" src="include/jquery/jquery.min.js"></script>
<!--<script type="text/javascript" type="text/javascript" src="include/jquery/PIE.js"></script>-->
<style type="text/css">
{literal}
* { margin:0px; padding:0px; border:0px; font-family: tahoma,arial,'Hiragino Sans GB','Hiragino Sans GB W3','Microsoft Yahei',宋体;}
a,ul { list-style:none; outline:none;}
a:link, a:visited {text-decoration:none;color:#2898e0;}
a:hover {color:#006cb1;text-decoration:underline;}
html { height:100%;}
body { background:#f7f8f8;color: #525252;height: 100%;font-size: 12px;}
/* WebKit browsers */
::-webkit-input-placeholder { color: #b0b0b0 !important;}
 /* Mozilla Firefox 4 to 18 */
:-moz-placeholder {color: #b0b0b0 !important;}
 /* Mozilla Firefox 19+ */
::-moz-placeholder {color: #b0b0b0 !important;}
 /* Internet Explorer 10+ */
:-ms-input-placeholder {color: #b0b0b0 !important;}

.wrapper{height:100%;width:100%;min-width:960px;}
.left_img{
	width:40%;
	height:100%;
	float:left;
	display:block;
	background:url(themes/images/left_img.jpg) no-repeat center;
	background-size:cover;
}
.right_content
{
	width:60%;
	height:100%;
	float:right;
	position:relative;
	overflow:auto;
}
.register
{
	height:auto;
	position:relative;
	margin:130px 0 0 65px;
    clear: both;
}
.register .sendok {
    float: left;
    position: absolute;
    left: opx;
    width: 300px;
    top: -60px;
    z-index: 2;
    background: url("themes/images/icon_ok.png") no-repeat scroll 11px 10px #A1D36E;
    border-radius: 3px;
    color: #FFF;
    font-size: 12px;
    line-height: 35px;
    padding: 0px 15px 0px 33px;
}
.logo{
	height:42px;
	width:204px;
    display: block;
	background:url("dataCache/test/logo/logo.png") left center no-repeat;
}
.register h1
{
	font-size:25px;
	font-weight:normal;
	color:#343d47;
	margin-top:25px;
	font-family: tahoma,arial,'Hiragino Sans GB','Hiragino Sans GB W3','Microsoft Yahei',宋体;
    line-height: 44px;
}
.register_tip
{
	color:#959ca8;
	margin-top:25px;
}
.register_form
{
	margin-top:20px;
}
.register_form li
{
	margin-bottom:10px;
	position:relative;
}
.register_form li .span_watermark
{
	display:block;
	float:left;
}
.register_form li input[type='text']
{
	height:42px;
	line-height:42px;
	border:1px solid #e8e8e8;
	border-radius:4px;
	font-size:16px;
	padding: 0 10px;
	float:left;
	color:#343D47;
}
.input_code
{
	width:440px;
}
.error_info
{
	color:#e54245;
	float:left;
	display:block;
	clear:both;
	margin:2px 0 0 0;
	padding-left:5px;
}
.validateBox  div.sucess_info
{
	position: relative;
	background: #ffffff;
	border: 1px solid #E8E8E8;
	border-radius: 4px;
	overflow: hidden;
	float: left;
	width: 300px;
}
.validateBox .input_code
{
   width: 278px !important;
   border: medium;
}
.validateBox .verification_img
{
	
	width: 95px;
	height: 42px;
	display: block;
	float: left;
	margin: 1px 10px 0 10px;
	border: 1px solid #E8E8E8;
	overflow: hidden;
}
.change_pic
{
	overflow: hidden;
	width: 40px;
}
.validateBox  span.dimness
{

	color:#959ca8;
	display: block;
	margin: 3px 0 5px 0;
	float: left;

}
.validateBox a.change
{
	float: left;
}
.button_yellow,.button_yellow:visited
{
	display:block;
	float:left;
	height:41px;
	line-height:41px;
	background:#ffe7b4;
	border-bottom:3px solid #f8d998;
	color:#c49124;
	padding:0 25px;
	border-radius:4px;
	font-size:14px;
}
.button_yellow:hover
{
	background:#f8d896;
	border-bottom:3px solid #f0cd83;
	color:#ba8004;
	text-decoration:none;
}
.register_form .button_yellow
{
	padding:0;
	text-align:center;
	width:151px;
}
.button_blue,.button_blue:visited
{
	display:block;
	float:left;
	height:41px;
	line-height:35px;
	background:#52a5e4;
	border:none;
	border-bottom:3px solid #217bc1;
	color:#fff;
	border-radius:4px;
	font-size:16px;
	width:120px;
	text-align:center;
	cursor:pointer;
}
.button_blue:hover
{
	background:#0081c1;
	border-bottom:3px solid #006698;
	color:#fff;
	text-decoration:none;
}
.button_disable,.button_disable:visited,.button_disable:hover
{
	background-color:#dfe3e3!important;
	border-bottom:3px solid #d1d7d7!important;
	color:#959ca8!important;
	cursor:default!important;
}
.register_help
{
	color:#959ca8;
	height:24px;
	line-height:24px;
}
.register_submit
{
	margin-top:30px;
	margin-bottom: 30px;
}
.register_login
{
	color:#959ca8;
	float:left;
	margin:15px 0 0 30px;
}
.register_login a,.register_login a:visited
{
	color:#959ca8;
}
.register_login a:hover
{
	color:#525252;
}

.clear:after {
	content:".";
	display:block;
	height:0;
	font-size:0;
	clear:both;
	visibility:hidden;
}
{/literal}
</style>		
<script type="text/javascript">
{literal}
function checkphone(obj){
	var mobile = document.getElementById('phone');
	var ab=/^[1][0-9]{10}$/;
	if(ab.test(mobile.value) != true)
	{
		mobile.value = "";
		var e= document.getElementById('phoneerror').style.display = 'block';
		mobile.focus();
		return false;
	}else{
		SMS_getListViewEntries_js(obj,mobile.value);
	}		
}
function SMS_getListViewEntries_js(obj,phone)
{
  var second = 600;
  var verson= document.getElementById('verson').value;
  var checkphone= document.getElementById('phone').value;

  $.ajax({
    url: 'SMS_Phone_Collection.php',
    type:'post',
    data: "&checkphone="+checkphone+"&verson="+verson,    
    success:function(rest){
      if(rest.indexOf('1')>=0){
        document.getElementById('alertcss').style.display = 'block';
        obj.disabled = true;
        obj.className='button_yellow button_disable';
        var e= document.getElementById('phoneerror').style.display = 'none';
        window.setTimeout("closewin()",3000); 
        countDown(obj,second);
        if(document.getElementById('code') != undefined){
          document.getElementById('code').focus();
        }
      }
      else{
		var confirm_str = '操作失败，请重新尝试！';
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
      }
    },
    timeout:20000,
    error:function(rest,textStatus){
		var confirm_str = '操作失败，请重新尝试！';
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
      return false;
    }
  });

  // $.ajax({
  //     type : "POST",
  //     url : "SMS_Phone_Collection.php",
  //     data : {'checkphone':checkphone,'verson':verson},
  //     dataType : "json",//
  //     success : function(msg) {
  //       alert(msg);
  //       if(msg == '1'){
  // 				document.getElementById('alertcss').style.display = 'block';
  // 				obj.disabled = true;
  //         obj.className='button_yellow button_disable';
  //         var e= document.getElementById('phoneerror').style.display = 'none';
  // 				window.setTimeout("closewin()",3000); 
  // 				countDown(obj,second);
  // 				if(document.getElementById('code') != undefined){
  // 					document.getElementById('code').focus();
  // 				}
  // 			}
  //       else
  //       {
  //         alert('操作失败，请重新尝试！')
  //       }
  //     }
  // });
}
//关闭提示信息
function closewin()
{
	document.getElementById('alertcss').style.display = 'none';
}
//发送按钮计时
function countDown(obj,second)
{
	if(second >= 0 ){
		obj.value = '('+second+')'+'秒后重新获取';
		second--;
		setTimeout(function(){countDown(obj,second);},1000);
	}else{
		obj.disabled = false;
        obj.className='button_yellow';
		obj.value = "重新获取验证码";
	}
}
//验证验证码，表单提交
function submitFrom()
{
    var ab=/^[1][0-9]{10}$/;
    var phone= document.getElementById('phone');  
    var verson= document.getElementById('verson');
    var code = document.getElementById('code');
    if(ab.test(phone.value) != true)
	{
		var e= document.getElementById('phoneerror').style.display = 'block';
		phone.focus();
		return false;
	}
    if(code.value.length != '6')
	{
	    var e= document.getElementById('checknumerror').style.display = 'block';
		code.focus();
		return false;
	}
    $.ajax({
        type : "POST",
        url : "SMS_Phone_Collection.php",
        data : {'phone':phone.value,'versons':verson.value,'codes':code.value},
        dataType : "json",
        success : function(msg) {
			if(msg != '1')
            {
				var confirm_str = "对不起，您的手机号码与验证码不匹配，请重新尝试！";
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            	phone.focus();
            }else{
               var bodyWidth = document.body.scrollWidth;
					window.location.href="index.php?module=Users&action=Authenticate&return_module=Users&return_action=Login&login_method=2&bodywidth=0";
              
            }
        }
    });
}

{/literal}
</script>
</head>
<body>
		<div class="wrapper">
            <div class="left_img"></div>
            <div class="right_content">
                <div class="register">
                    <div style="display:none;" class="sendok" id="alertcss">验证码发送成功！</div>
                    <div id="images_change"><a href="{$WEB_URL}" class="logo" ></a></div>
                    <div id="registerDiv">
                        <h1>{$SUBJECT}</h1>
                        <div class="register_tip">{$DESCRIPTION_ONE}</div>
                        <ul class="register_form">
                            <!--输入手机号-->
                            <li class="clear">
                              <span class="span_watermark">
                              <input class="input_code" id="phone" placeholder="请输入手机号" name="phone" maxlength="100" type="text"/>
                              </span>
                              <input type="hidden" id="verson" name="verson" value="{$CVERSION}">
                              <span id="phoneerror" style="display:none;" class="error_info">请输入正确的手机号码</span>
                            </li>
                            
                            <!--输入识别码-->
                            <li class="clear validateBox" style="display:none">
                                <div class="sucess_info">
                                  <span class="span_watermark">
                                    <input placeholder="请输入4位识别码" class="input_code" id="gcode" maxlength="4" checktype="verify" type="text"/>
                                  </span>
                                </div>
                                <span class="verification_img"><img src="themes/images/exp-check-code.png" id="img_code_id" class="img_code" height="42"></span>
                                <div class="change_pic">
                                    <span class="dimness">看不清</span>
                                    <a href="#" class="change" id="change_code_id">换一张</a>
                                </div>
                                <span id="checkgcodeerror" style="display:none;" class="error_info">请输入正确的识别码</span>
                            </li>
                            
                            <!--输入手机验证码-->
                            <li class="clear">
                                <input type="button" class="button_yellow"  onclick=" return checkphone(this)" value="获取手机验证码" style="color:#c49124;"/>
                            </li>
                            
                            <li class="clear">
                              <span class="span_watermark">
                              <input class="input_code" id="code" name="code"  placeholder="请输入收到的验证码" maxlength="6" type="text"/>
                              </span>                 
                              <span id="checknumerror" style="display:none;" class="error_info">请输入正确的验证码</span>
                            </li>
                            
                        </ul>
                        <div class="register_help">
                            如果一段时间没有收到，请重新获取。咨询热线：
                            <span style="color:#FF7E00; font-family: tahoma,arial,'Hiragino Sans GB','Hiragino Sans GB W3','Microsoft Yahei',宋体;">{$HOT_LINE}</span>
                        </div>
                        <div class="register_submit clear">
                            <input value="提交" type="button" class="button_blue" onclick="return submitFrom()"/>
                            <span class="register_login">
                                已有帐号，<a href="index.php?module=Users&action=Login&login_method=true" title="直接登录" style="color:#2898E0">直接登录</a>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
	</body>
</html>
<script>
{literal}
//0017104: 体验登录界面：手机号文本框、验证码文本框缺少光标，输入手机号、验证码后，按Enter键应可以直接提交。
	if(document.getElementById('phone') != undefined){
		document.getElementById('phone').focus();
	}
	document.onkeydown = function(evt){
   　 var evt = window.event?window.event:evt;
    　if (evt.keyCode==13) {
          submitFrom();
    　}
   }
{/literal}
</script>