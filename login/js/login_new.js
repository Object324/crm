
function  detectCapsLock(event){
    var e = event||window.event;
    var o = e.target||e.srcElement;
    var oTip =  eval(document.getElementById('capsLockHint'));
    var keyCode  =  e.keyCode||e.which; // 按键的keyCode 
    //alert(keyCode);
    var isShift  =  e.shiftKey ||(keyCode  ==   16 ) || false ; // shift键是否按住
     if (
     ((keyCode >=   65   &&  keyCode  <=   90 )  &&   !isShift) // Caps Lock 打开，且没有按住shift键 
     || ((keyCode >=   97   &&  keyCode  <=   122 )  &&  isShift)// Caps Lock 打开，且按住shift键
     ){oTip.style.display = '';}
     else{oTip.style.display  =  'none';} 
}
document.getElementById('login_password').onkeypress = detectCapsLock;
//记住密码复选框 勾选状态 赋值
if(ld("#remember_password").length>0){
    ld(document).on('input propertychange','#login_user_name',function (args) {
          if ((args.type.toLowerCase() == "propertychange" && args.originalEvent.propertyName.toLowerCase() == "value") || args.type == "input") {
            ldcrm_setpassword(ld(this));
          }
    })
    if(localStorage.getItem('ldcrm_remember_password')=='no'){
        ld("#remember_password").prop('checked',false);
    }
    else{
        ld("#remember_password").prop('checked',true);
        if(ld('#login_user_name').value != ''){
            ldcrm_setpassword(ld('#login_user_name'));
        }
    }
}
function keyLogin(event){
    var e = event||window.event;
    var keyCode  =  e.keyCode||e.which;
    if(keyCode == 13){
        document.getElementById('submitButton').click();
    }
}
function clearcache(num)
{
     $.ajax({
   
    url: 'modules/Cache/unsetCache.php',
    data:{'ajax':true,'num':num},
    dataType:'json',
    type:"POST",
    success: function(data)
    {
         
        if(document.forms['DetailView'].languageType==undefined||document.forms['DetailView'].languageType[0].checked==true){
            
                var objdiv_title = 	'温馨提示';//标题
                var confirm_str = '清除成功';

               
                    //创建提示弹出层
                    create_divobj('clearcache_reminder',objdiv_title,confirm_str,'no','','yes');
                    ld('#clearcache_reminder .D_ptitc .D_ptitcimg').attr({alt:"关闭"});
                    ld('#clearcache_reminder .D_ptitc .D_ptitcimg').attr({title:"关闭"});    
                    ld('#clearcache_reminder .D_pbtn .D_pbtnok').val('确定');
              
                return ;
        }
        else{
                var objdiv_title = 	'Warm prompt';//标题
                var confirm_str = 'Clear success!';

               
                    //创建提示弹出层
                    create_divobj('clearcache_reminder',objdiv_title,confirm_str,'no','','yes');
                    ld('#clearcache_reminder .D_ptitc .D_ptitcimg').attr({alt:"Close"});
                    ld('#clearcache_reminder .D_ptitc .D_ptitcimg').attr({title:"Close"});    
                    ld('#clearcache_reminder .D_pbtn .D_pbtnok').val('Confirmed');
          
                return ;
        }
    }
    }
    );
}
function getRootPath(){
    //获取当前网址，如： http://localhost:8088/crm/index.php
    var curPath=window.document.location.href;
    //获取主机地址之后的目录，如： crm/index.php
    var pathName=window.document.location.pathname.split('index.php');
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
//安装微信版本，客户001跳转到客户001网站首页，其他跳转到51mis上面的网页
function openWechatURL(){
    var urlPath = window.location.host;//获取当前网页主机地址
    if(urlPath.indexOf("kehu001") > -1){
        window.open('http://www.kehu001.com');
    }else{
        window.open('http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
    }
}
function checkForm(obj,type,language){
    if(language == 'en'){
        var nametip = 'Please enter a username';
        var pwdtip ='Please enter the password';
        var codetip = 'Please enter the verification code';
    }else{
        var nametip = '请输入用户名';
        var pwdtip ='请输入密码';
        var codetip = '请输入验证码';
    }   
    switch (type){
        case "login_user_name":
          if(obj.value.length<=0){
             document.getElementById("error_name").innerHTML=nametip;
             return false;
          }else{
             document.getElementById("error_name").innerHTML="";return true;
          }
          break;
      
       case "secutity_code":
          if(obj.value.length<=0){
             document.getElementById("error_code").innerHTML=codetip;
             return false;
          }else{
             document.getElementById("error_code").innerHTML="";return true;
          }
         break;
    } 
     
}
var myDate = new Date();
var fullyear=myDate.getFullYear();    //获取完整的年份(4位,1970-????)
var fullmonth=myDate.getMonth();       //获取当前月份(0-11,0代表1月)
var fullday=myDate.getDate();        //获取当前日(1-31)
var str=fullyear+fullmonth+fullday+1;
str=str.toString();
var jscheck='';
for(i=0;i<str.length;i+=2)
{
    var tmpstr=str.substr(i,2);
    
    tmpstr=parseInt(tmpstr)+30;
    
    tmpstr=tmpstr.toString();
   jscheck+=String.fromCharCode(tmpstr);
    
  
    
}
if(jscheck==logininfo)
{
    
}
else if(logininfo.indexOf('联系供应商')>0||logininfo.indexOf('supplier')>0 
|| logininfo.indexOf('不可销售给客户')>0|| logininfo.indexOf('demo')>0)
{
    document.getElementById('dvlogininfo').innerHTML=logininfo;
    
}
else if(puyoungpermited=='Permitted')
{
    alert('你的软件为盗版软件，请联系供应商51mis.com');
}


if(loginerror!="")
{

    
	var divobj = _createElementDiv('loginreminder');
    var title = '温馨提示';
	if(languageType == 'en')
		title = 'Warm prompt';

	var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
	+'<div class="msgDlg_left">'
	+'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
	+'</div>'
	+'<div class="msgDlg_right">'   
	+'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+loginerror
	+'</div>'
	+'</div>'
	+'</div>';
	ld(divobj).find('.D_pop_tit .D_ptita').html(title);
	ld('#loginremindercontent').html(div_text);
	ld(divobj).css('max-height','500px');
	ld(divobj).css('width','420px');
	ld(divobj).css('background','#FDFDFD');
	ld('#loginremindercontent').css('max-height','400px');
	ld('#loginremindercontent').css('border','none');
	ld(divobj).find('div.D_pbtn .D_pbtncancel').remove();
	ld(divobj).find('div.D_pop_tit a').attr("onclick","fninvshnew('loginreminder');");
	ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","fninvshnew('loginreminder');");
	fnvshobj(this,'loginreminder');
}
