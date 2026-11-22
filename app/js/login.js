var t1=null;
var loginurl='';var forgetloginurl='';
var logintype = 1;//1体验登录，2手机号码登录
var userid = '';
var phone_mobile = '';
var login_sms = 0;
var appname = '';
var enterprise_name = '';//企业账号
var individual_name = '';//个人账号
var login_pwd = '';//密码
var isrememeberpwd = 'no';//是否记住密码
var iosInterfaceKey = 'firstlogin';//IOS接口，key
var iosInterfaceValue = '';//IOS接口，value
var iosInterfaceBackValue = '';//IOS接口，键值返回值
var isloginout = 'no';//是否退出登录

var phonenum = '';//验证码接收手机
var divStack = Array();//记录返回事件的div
var second=-1;

document.addEventListener('touchmove', function(e) {
	e.preventDefault();
}, false);

document.addEventListener('DOMContentLoaded', function() {
	ld(document).ready(function() {
		loaded();
	});
}, false);
//节点加载事件，在onload之前
ld(function(){
	// 判断当前浏览器是否支持indexOf、remove事件，不支持则添加
	if(typeof Array.indexOf !== 'function'){//数组包含
		Array.prototype.indexOf = function(args){
			var index = -1;
			for(var i=0,l=this.length;i<l; i++){
				if(this[i] === args){
					index = i;
					break;
				}
			}
			return index;
		}
	}
	String.prototype.len = function(){// 给string增加个len ()方法，计算string的字节数
		return this.replace(/[^\x00-\xff]/g,"xx").length;
	}
});
//移动终端浏览器版本信息
var phoneversion = '';
var browser = {
    versions: function(){
        var u = navigator.userAgent.toLowerCase(), app = navigator.appVersion;
        return{
            trident: u.indexOf('trident') > -1, //IE内核
            presto: u.indexOf('presto') > -1, //opera内核
            webKit: u.indexOf('applewebkit') > -1, //苹果、谷歌内核
            gecko: u.indexOf('gecko') > -1 && u.indexOf('khtml') == -1, //火狐内核
            mobile: !!u.match(/applewebkit.*mobile.*/) || !!u.match(/applewebkit/), //是否为移动终端
            ios: !!u.match(/\(i[^;]+;( u;)? cpu.+mac os x/), //ios终端
            iPhone: u.indexOf('iphone os') > -1, //是否为iPhone或者QQHD浏览器
            iPad: u.indexOf('ipad') > -1, //是否iPad
            android: u.indexOf('android') > -1 || u.indexOf('linux') > -1, //android终端或者uc浏览器
            midp: u.indexOf('midp') > -1, //是否midp
            webApp: u.indexOf('safari') == -1 //是否web应用程序，没有头部与底部
        };
    }()
};
if(browser.versions.ios || browser.versions.iPhone || browser.versions.iPad){
    document.write("<script type='text/javascript' src='js/ios/cordova_ios.js'></"+"script>");
    phoneversion = 'ios';
}
else if(browser.versions.android){
    phoneversion = 'android';
}
else{
    phoneversion = 'other';
}

function loaded(){
    //引导页滑动
    var windowHeight=innerHeight;
    var windowWidth=innerWidth;
    var footHeight=ld('footer').height();
    ld('.wrap,.swiper-container').css({
        'height':windowHeight-footHeight-1,
        'width':windowWidth
    });
    var mySwiper = new Swiper('.swiper-container',{
        pagination: '.pagination',
        loop:false,
        grabCursor: true,
        paginationClickable: true
    });
    //判断是不是退出到登录页面
    if(phoneversion=='other'){
        var urlStr=window.location.search;   //location.search是从当前URL的?号开始的字符串
        if(urlStr.length>0){
            urlArr = urlStr.split("&");//字符串转变成数组
            for(var i=0;i<urlArr.length;i++){ 
                if(urlArr[i].indexOf('a1')!=-1){            
                    enterprise_name = urlArr[i].split("=")[1];
                }
                if(urlArr[i].indexOf('b2')!=-1){
                    individual_name = urlArr[i].split("=")[1];
                }
                if(urlArr[i].indexOf('c3')!=-1){
                    login_pwd = urlArr[i].split("=")[1];
                }
            } 
            getLogout(enterprise_name,individual_name,login_pwd,'no','yes');  
        }
    }
    if(phoneversion == 'android'){
        ld('header').css('padding-top','0');
        ld('.loginbg').css('top','1.9rem');
    }
    if(phoneversion == 'android'){
        ld('.divDescription:first').removeClass('ui-hide');
    }
    else{
        ld('.divDescription').removeClass('ui-hide');
    }
    countDownLogin(2);
    //进入登录页面
    ld('.loginleft .login_href,#slider li[tag=showlogin]').unbind('click').on('click',function(){
        if(myClick()=='no') return;//多次点击问题
        ld('#header_login nav p').html('登录');
        ld('#loginHome').addClass('ui-hide');//隐藏登录首页
        ld('#normalLogin').removeClass('ui-hide');//正常登录
        ld('#phoneNumLogin').addClass('ui-hide');//手机登录
        ld('#tryLogin').addClass('ui-hide');//体验登录
        ld('#trySubmit').addClass('ui-hide');
        ld('#loginPage').removeClass('ui-hide');//显示登录页面  
        if(phoneversion == 'ios'){
            window.echo = cordova.exec(
                function(okParam) {
                }, function(err) {
                }, 'CDVLDHelperPlugin', 'changeLoginStatusBarColor',[]
            );
        }
        loginBind();//登录页面事件绑定        
    });
    //进入快速体验页面
    ld('.loginright .trylogin_href').unbind('click').on('click',function(){
        if(myClick()=='no') return;//多次点击问题
        if(checkNetwork()=='no')return false;//判断是否有网络
        if(phoneversion!='android') changeHeight('3r');                
        logintype = 1;//体验登录
        loginurl = experienceurl;
        second=-1;        
        ld('#header_login nav p').html('快速体验');
        ld('#loginHome').addClass('ui-hide');//隐藏登录首页
        ld('#normalLogin').addClass('ui-hide');//正常登录
        ld('#phoneNumLogin').addClass('ui-hide');//手机登录
        ld('#trySubmit').addClass('ui-hide'); 
        ld('#no_message').addClass('ui-hide');//未收到验证短信的说明界面
        ld('#tryLogin .tryLoginContent .tip').html(experienceInfo);
        ld('#tryLogin').removeClass('ui-hide');//体验登录
        ld('#loginPage').removeClass('ui-hide');//显示登录页面
        ld('#tryphonenum').val('');
        ld('#tryphonenum').focus();   
        if(phoneversion == 'ios'){
            window.echo = cordova.exec(
                function(okParam) {
                }, function(err) {
                }, 'CDVLDHelperPlugin', 'changeLoginStatusBarColor',[]
            );
        }     
        tryLoginBind();//快速体验事件绑定
    });
    //进入注册页面
    ld('.loginright .register_href').unbind('click').on('click',function(){
        if(myClick()=='no') return;//多次点击问题
        alert('进入注册页面');
    });
    //取消
    ld('.popup-remind [tag=cancel]').unbind('click').on('click',function(event){
        if(myClick()=='no') return;//多次点击问题
        ld('.popup-remind').css('display','none');
        ld('#poplayerMask').css('display','none');
    });    
    //回到顶部
    ld('a.top').unbind('click').on('click',function(){ 
        if(phoneversion!='android') changeHeight('3r');
    });        
}
//登录页面事件绑定
function loginBind(){
	//绑定登录页返回事件
	setStack('header_login .head_left .back_icon');
    //返回
    ld('#header_login .head_left .back_icon').unbind('click').on('click',function(){
		if(myClick()=='no') return;//多次点击问题
        if(phoneversion!='android') changeHeight('3r');
        ld('#loginPage').addClass('ui-hide');//隐藏登录页面
        ld('#loginHome').removeClass('ui-hide');//显示登录首页
    }); 
    if(enterprise_name==''){
        changeHeight('3r');
        ld('#enterprise_name').focus();
    }
    else if(individual_name==''){
        changeHeight('1r');
        ld('#individual_name').focus();
    }
    else{
        changeHeight('-1r');
        ld('#login_pwd').focus();
    }
    ld('#normalLogin').unbind('click').on('click',function(event){
        if(myClick()=='no') return;//多次点击问题
        var e = event||window.event;
		var obj = e.srcElement||e.target;
        var classname = ld(obj).attr('class');
        //忘记密码      
		if(classname == 'forget'){
            if(phoneversion!='android') changeHeight('3r');
            ld('#loginPage').addClass('ui-hide');//隐藏登录首页
            ld('#forgetPage').removeClass('ui-hide');//显示忘记密码页面
            second=-1;
            forgetBind();//忘记密码事件绑定
        }
        //登陆
        else if(classname == 'login'){
            ld('.loginContent input').blur();//失去焦点            
            ld('#poplayerMask').css({'display':'block'});
            if(checkNetwork()=='no')return false;//判断是否有网络
            if(phoneversion!='android') changeHeight('3r');
            enterprise_name = ld('#enterprise_name').val();//企业账号
            individual_name = ld('#individual_name').val();//个人账号
            login_pwd = ld('#login_pwd').val();//密码
            if(enterprise_name==''){
                popFunction('企业账号不能为空');//弹出层
                closeRemindpop('enterprise_name');
                return false;
            }
            if(individual_name==''){
                popFunction('个人账号不能为空');//弹出层
                closeRemindpop('individual_name');
                return false;
            }
            ld("#status").css('display','block');
            login();//登录            
        }
        else if(classname == 'loginbg'){
            if(phoneversion!='android') changeHeight('3r');
        }
    });
}
//快速体验事件绑定
function tryLoginBind(){    
	//绑定快速体验返回事件
	setStack('header_login .head_left .back_icon');
    //返回
    ld('#header_login .head_left .back_icon').unbind('click').on('click',function(){
        second=-1;
        if(myClick()=='no') return;//多次点击问题
        if(phoneversion!='android') changeHeight('3r');
        ld('#loginHome').removeClass('ui-hide');//显示登录首页
        ld('#loginPage').addClass('ui-hide');//隐藏登录页面
        ld('#tryphonenum').val('');
        ld('#trycode').val('');
		delStack(1);
    });    
    ld('#tryLogin').unbind('click').on('click',function(event){
        if(myClick()=='no') return;//多次点击问题
        var e = event||window.event;
		var obj = e.srcElement||e.target;
        var classname = ld(obj).attr('class');
        //获取验证码
        if(classname == 'submit'){
            if(phoneversion!='android') changeHeight('3r');
            if(checkNetwork()=='no')return false;//判断是否有网络
            phonenum = ld('#tryphonenum').val();
            if(second<0)getCode();//体验登录获取验证码
        }
        else if(classname == 'loginbg'){
            if(phoneversion!='android') changeHeight('3r');
        }
    });
    submitFun();//提交
}
//忘记密码事件绑定
function forgetBind(){
	//绑定忘记密码返回事件
	setStack('header_forget .head_left .back_icon');
    //返回
    ld('#header_forget .head_left .back_icon').unbind('click').on('click',function(){
        if(myClick()=='no') return;//多次点击问题
        if(phoneversion!='android') changeHeight('3r');
        ld('#loginPage').removeClass('ui-hide');//显示登录首页
        ld('#forgetPage').addClass('ui-hide');//隐藏忘记密码页面
		delStack(1);
    });    
    var forget_enterprisename = ld('#forget_enterprise_name').val();
    var forget_individualname =  ld('#forget_individual_name').val();
    var forget_phonenum =  ld('#forget_phonenum').val();
    var forget_codenum =  ld('#forget_codenum').val();
    if(forget_enterprisename==''){
        ld('#forget_enterprise_name').focus();
    }
    else if(forget_individualname==''){
        ld('#forget_individual_name').focus();
    }
    else if(forget_phonenum==''){
        ld('#forget_phonenum').focus();
    }
    else if(forget_codenum==''){
        ld('#forget_codenum').focus();
    }            
    ld('#divForgetPwd').unbind('click').on('click',function(event){
        if(myClick()=='no') return;//多次点击问题
        var e = event||window.event;
		var obj = e.srcElement||e.target;
        var classname = ld(obj).attr('class');
        //获取验证码
        if(classname == 'getcode'){
            if(phoneversion!='android') changeHeight('3r');
            if(second<0)getCodeForget();//忘记密码获取验证码
        }
        //忘记密码提交
        else if(classname == 'submit'){
            if(phoneversion!='android') changeHeight('3r');
            var forget_enterprisename = ld('#forget_enterprise_name').val();
            var forget_individualname =  ld('#forget_individual_name').val();
            var forget_phonenum =  ld('#forget_phonenum').val();
            var forget_codenum =  ld('#forget_codenum').val();
            if(forget_enterprisename==''){
                ld("#status").css('display','none');
                popFunction('企业账号不能为空');//弹出层
                closeRemindpop('forget_enterprise_name');
                return false;
            }
            if(forget_individualname==''){
                ld("#status").css('display','none');
                popFunction('个人账号不能为空');//弹出层
                closeRemindpop('forget_individual_name');             
                return false;
            }
            if(forget_phonenum.length==0){
               popFunction('手机号码不能为空');
               closeRemindpop('forget_phonenum');
               return false;
            }    
            var myreg = /^1\d{10}$/;
            if(!myreg.test(forget_phonenum)){
                popFunction('手机号码格式错误，请重新输入');
                closeRemindpop('forget_phonenum'); 
                return false;
            }
            if(forget_codenum==''){
                ld("#status").css('display','none');
                popFunction('验证码不能为空');//弹出层
                closeRemindpop('forget_codenum');
                return false;
            }            
            ld("#status").css('display','block');
            var urlstring = 'http://'+forgetloginurl+'/mobileindex.php?jsoncallback=?&module=Experience&action=ForgetPwdSMS';
            urlstring += '&user_name='+forget_individualname+'&phonenum='+forget_phonenum;
            urlstring += '&codenum='+forget_codenum+'&appversion='+mobileVersion;
            //判断验证码是否符合，如果符合给出新的密码
            checkCodeNum(urlstring);
        }
        else if(classname == 'loginbg'){
            if(phoneversion!='android') changeHeight('3r');
        }
    });
}
//登录
function getLoginUser(urlstring){
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: urlstring,  //这里是网址
        success: function (data) {
            if(data.code!=1){
                popFunction(data.msg);//弹出层
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
                closeRemindpop('login_pwd');
            }
            else{
                userid = data.result.userinfo.id;
                login_sms = data.result.userinfo.login_sms;
                phone_mobile = data.result.userinfo.phone_mobile; 
                appname = data.result.appname;
                loginSMSCheck(login_sms,userid,phone_mobile);
                ld("#poplayerMask").css('display','none');
				clearStack();
            }
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            ld("#status").css('display','none');
            ld("#loading").css('display','none');
            popFunction('登录失败，请联系供应商');//弹出层
            return false;
        }
    });
}
//登录时启用手机短信验证
function loginSMSCheck(login_sms,userid,phone_mobile){
    if(login_sms==0){
        if(phoneversion == 'ios'){
            cacheData('loginurl',loginurl);
            cacheData('userid',userid);
            cacheData('a1',enterprise_name);
            cacheData('b2',individual_name);
            cacheData('c3',login_pwd);
            cacheData('d4','yes');
            cacheData('e5','no');
            try {
                window.echo = cordova.exec(
                function(okParam){
                    //alert('okParam' + okParam);
                    //getDeviceInfoIOSfromMain(okParam.uuid);
                },
                function(error) {
                    alert('error' + error);
                },'CDVDevice', 'showMainViewController',[]);
            }catch(e){
                alert('error:' + e.message);
            }
        }
        else if(phoneversion == 'android'){
            //企业账号、登录URL、appname、用户ID、用户名称、密码、是否记住密码、是否退出登录
            javatojs.ShowMainFrame(enterprise_name,loginurl,appname,userid,individual_name,login_pwd,'yes','no',mobileVersion);    
        }
        else{
            var url = 'http://'+loginurl+'/app/news.html?loginurl='+loginurl+'&userid='+userid+'&a1='+escape(enterprise_name)+'&b2='+escape(individual_name)+'&c3='+escape(login_pwd)+'&d4=yes&e5=no';
            window.location.href=url; 
        }
    }
    else{
        ld("#status").css('display','none');
        ld("#loading").css('display','none');
        ld('#loginHome').addClass('ui-hide');//隐藏登录首页
        ld('#loginPage').removeClass('ui-hide');//显示登录页面        
        loginBind();//登录页面事件绑定 
        
        if(phoneversion!='android') changeHeight('3r');
        ld('#tryTip').addClass('ui-visihide');
        ld('#normalLogin').addClass('ui-hide');        
        ld('#mobilephonenum').val(phone_mobile);   
        ld('#phoneNumLogin').removeClass('ui-hide');
        ld("#status").css('display','none');        
        logintype = 2;//手机号码登录
        loginurl = loginurl;
        ld('#phoneNumLogin').unbind('click').on('click',function(event){
            if(myClick()=='no') return;//多次点击问题
            var e = event||window.event;
    		var obj = e.srcElement||e.target;
            var classname = ld(obj).attr('class');
            //获取验证码
            if(classname == 'getcode'){
                if(phoneversion!='android') changeHeight('3r');
                phonenum = ld('#mobilephonenum').val();
                if(second<0)getCode();//手机号码登录获取验证码
            }
            else if(classname == 'loginbg'){
                if(phoneversion!='android') changeHeight('3r');
            }
        });
        submitFun();//提交
    }
}
//获取验证码
function getCode(){
    if(phonenum.length==0){
       popFunction('手机号码不能为空');
       closeRemindpop('tryphonenum');
       return false;
    }    
    var myreg = /^1\d{10}$/;
    if(!myreg.test(phonenum)){
        popFunction('手机号码格式错误，请重新输入');
        closeRemindpop('tryphonenum');
        return false;
    }
    //获取验证码链接    
    ld("#status").css('display','block');
    var urlstring ='http://';
    urlstring += loginurl;
    //体验登录获取验证码
    if(logintype==1){
        urlstring += '/mobileindex.php?jsoncallback=?&module=Experience&action=MobileSMS';
    }
    else if(logintype==2){//手机验证码登录获取验证码
        urlstring += '/mobileindex.php?jsoncallback=?&module=Users&action=UserGetSMS&getcode=yes&userid='+userid;
    }
    urlstring += '&smsphone='+phonenum+'&appversion='+mobileVersion;
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: urlstring,  //这里是网址
        success: function (data) {
            if(data.code!=1){
                popFunction(data.msg);//弹出层
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
            }
            else{
                countDown(600,logintype);
                if(logintype==1){
                    ld('#tryphoneSub a.getcode').unbind('click');
                    ld('#trytipText').find('span').html(phonenum);
                    ld('#trytipText').removeClass('ui-visihide');
                    //显示验证码界面
                    ld('#tryLogin').addClass('ui-hide');
                    ld('#trySubmit').removeClass('ui-hide');
                    ld('#tryphonenum').val('');
                    ld('#trycode').focus();
                    ld('#trySubmit .notcodenot').unbind('click').on('click',function(){
                        //读取验证码没有收到文字描述
                        var smsinfohtml = '<li>'+experiencenosmsInfo0+'</li>'+'<li>'+experiencenosmsInfo1+'</li>'+'<li>'+experiencenosmsInfo2+'</li>'+'<li>'+experiencenosmsInfo3+'</li>'+'<li>'+experiencenosmsInfo4+'</li>';
                        ld('#no_message ul').html(smsinfohtml);
                        var callhtml = experiencenosmsInfo5+experiencenosmsInfo6;
                        ld('#no_message .call').html(callhtml);
                        
                        //显示未收到验证短信的说明界面
                        ld('#header_login').addClass('ui-hide');
                        ld('#trySubmit').addClass('ui-hide');
                        ld('#header_intr').removeClass('ui-hide');
                        ld('#no_message').removeClass('ui-hide');
                        setStack('header_intr a.back_icon');
                        //返回
                        ld('#header_intr a.back_icon').unbind('click').on('click',function(){
                            ld('#header_intr').addClass('ui-hide');
                            ld('#no_message').addClass('ui-hide'); 
                            ld('#header_login').removeClass('ui-hide');
                            ld('#trySubmit').removeClass('ui-hide');
							delStack(1);
                        });
                    });
                }
                else if(logintype==2){//手机验证码登录获取验证码                  
                    ld('#phoneNum a.getcode').unbind('click');
                    ld('#tipText').find('span').html(phonenum);
                    ld('#tipText').removeClass('ui-visihide');
                }
                ld("#status").css('display','none');                
                //提交
                submitFun();                  
            }
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            ld("#status").css('display','none');
            ld("#loading").css('display','none');
            popFunction('获取验证码失败');//弹出层
            return false;
        }
    });
}
//提交
function submitFun(){
    ld('#phoneNumLogin a.submit,#trySubmit a.submit').unbind('click').on('click',function(event){
        if(myClick()=='no') return;//多次点击问题
        if(checkNetwork()=='no')return false;//判断是否有网络
        if(phoneversion!='android') changeHeight('3r');
        ld("#status").css('display','block');
        var codenum =  '';
        if(logintype==1){
            codenum = ld('#trycode').val();
        }
        else if(logintype==2){//手机验证码登录
            codenum = ld('#mobilecodenum').val();
        }
        if(codenum==''){
            ld("#status").css('display','none');
            popFunction('验证码不能为空');//弹出层
            closeRemindpop('trycode');
            return false;
        }
        var urlstring = 'http://';
        urlstring += loginurl;
        try {
            //体验登录
            if(logintype==1){
                urlstring += '/mobileindex.php?jsoncallback=?&module=Experience&action=MobileSMS';
                urlstring += '&checkphone='+phonenum+'&codes='+codenum+'&appversion='+mobileVersion;
                ld.ajax({  
                    type: "get",
                    contentType: "application/json; charset=utf-8",
                    dataType: "jsonp",
                    url: urlstring,  //这里是网址
                    success: function (data) {
                        if(data.code==1){   
                            userid = data.result.userinfo.id;
                            ld("#status").css('display','none');
                            if(phoneversion == 'ios'){
                                cacheData('loginurl',loginurl);
                                cacheData('userid',userid);
                                cacheData('a1',enterprise_name);
                                cacheData('b2',individual_name);
                                cacheData('c3',login_pwd);
                                cacheData('d4','yes');
                                cacheData('e5','no');
                                try {
                                    window.echo = cordova.exec(
                                    function(okParam){
                                        //alert('okParam' + okParam);
                                        //getDeviceInfoIOSfromMain(okParam.uuid);
                                    },
                                    function(error) {
                                        alert('error' + error);
                                    },'CDVDevice', 'showMainViewController',[]);
                                }catch(e){
                                    alert('error:' + e.message);
                                }
                            }
                            else if(phoneversion == 'android'){
                                //企业账号、登录URL、appname、用户ID、用户名称、密码、是否记住密码、是否退出登录
                                javatojs.ShowMainFrame(enterprise_name,loginurl,appname,userid,individual_name,login_pwd,'yes','no',mobileVersion);    
                            }
                            else{
                                var url = 'http://'+loginurl+'/app/news.html?loginurl='+loginurl+'&userid='+userid+'&a1='+escape(enterprise_name)+'&b2='+escape(individual_name)+'&c3='+escape(login_pwd)+'&d4=yes&e5=no';
                                window.location.href=url; 
                            }
                            ld('#trycode').val('');
							clearStack();
                        }
                        else{
                            ld("#status").css('display','none');
                            ld("#loading").css('display','none');
                            popFunction(data.msg);//弹出层
                            return false;
                        }
                    },
                    timeout: 20000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        ld("#status").css('display','none');
                        ld("#loading").css('display','none');
                        popFunction('体验登录失败');//弹出层
                        return false;
                    }
                });                
            }
            else if(logintype==2){//手机验证码登录
                urlstring += '/mobileindex.php?jsoncallback=?&module=Users&action=UserSMSLogin';
                urlstring += '&userid='+userid+'&smsphone='+phonenum+'&codes='+codenum+'&appversion='+mobileVersion;
                ld.ajax({  
                    type: "get",
                    contentType: "application/json; charset=utf-8",
                    dataType: "jsonp",
                    url: urlstring,  //这里是网址
                    success: function (data) {
                        if(data.code==1){
                            userid = data.result.userinfo.id;
                            ld("#status").css('display','none');                            
                            if(phoneversion == 'ios'){
                                cacheData('loginurl',loginurl);
                                cacheData('userid',userid);
                                cacheData('a1',enterprise_name);
                                cacheData('b2',individual_name);
                                cacheData('c3',login_pwd);
                                cacheData('d4','yes');
                                cacheData('e5','no');
                                try {
                                    window.echo = cordova.exec(
                                    function(okParam){
                                        //alert('okParam' + okParam);
                                        //getDeviceInfoIOSfromMain(okParam.uuid);
                                    },
                                    function(error) {
                                        alert('error' + error);
                                    },'CDVDevice', 'showMainViewController',[]);
                                }catch(e){
                                    alert('error:' + e.message);
                                }
                            }
                            else if(phoneversion == 'android'){
                                //企业账号、登录URL、appname、用户ID、用户名称、密码、是否记住密码、是否退出登录
                                javatojs.ShowMainFrame(enterprise_name,loginurl,appname,userid,individual_name,login_pwd,'yes','no',mobileVersion);    
                            }
                            else{
                                var url = 'http://'+loginurl+'/app/news.html?loginurl='+loginurl+'&userid='+userid+'&a1='+escape(enterprise_name)+'&b2='+escape(individual_name)+'&c3='+escape(login_pwd)+'&d4=yes&e5=no';
                                window.location.href=url; 
                            }
							clearStack();
                        }
                        else{
                            ld("#status").css('display','none');
                            ld("#loading").css('display','none');
                            popFunction(data.msg);//弹出层
                            return false;
                        }
                    },
                    timeout: 20000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        ld("#status").css('display','none');
                        ld("#loading").css('display','none');
                        popFunction('手机验证码登录失败');//弹出层
                        ld('#poplayerMask').css('display','block');
                        return false;
                    }
                });
            }
        }catch(e){
            ld("#status").css('display','none');
        }
    });
}
//发送按钮计时
function countDown(secondtime,type){
    second = secondtime;
    if(second >= 0 ){
        if(type==1){
            ld('#tryphoneSub a.getcode').html(second+'秒后重新获取');
        }
        else if(type==2){
            ld('#phoneNum a.getcode').html(second+'秒后重新获取');
        }
        else if(type==3){
            ld('#forgetphoneNum a.getcode').html(second+'秒后重新获取');
        }
        second--;
        setTimeout(function(){countDown(second,type);},1000);  
		
	}else{
	    if(type==1){
            ld('#tryphoneSub a.getcode').html('重新获取验证码');
            logintype = 1;//体验登录
            loginurl = experienceurl;
            //获取验证码
            ld('#tryphoneSub a.getcode').unbind('click').on('click',function(event){
                if(myClick()=='no') return;//多次点击问题
                if(checkNetwork()=='no')return false;//判断是否有网络
                if(second<0)getCode();//体验登录获取验证码
            }); 
        }
        else if(type==2){
            ld('#phoneNum a.getcode').html('重新获取验证码');
            logintype = 2;//手机号码登录
            loginurl = loginurl;
            //获取验证码
            ld('#phoneNum a.getcode').unbind('click').on('click',function(event){
                if(myClick()=='no') return;//多次点击问题
                if(checkNetwork()=='no')return false;//判断是否有网络
                if(second<0)getCode();//手机号码登录获取验证码
            });
        }
        else if(type==3){
            ld('#forgetphoneNum a.getcode').html('重新获取验证码');
            logintype = 3;//忘记密码
            //获取验证码
            ld('#forgetphoneNum a.getcode').unbind('click').on('click',function(event){
                if(myClick()=='no') return;//多次点击问题
                if(checkNetwork()=='no')return false;//判断是否有网络
                if(second<0)getCodeForget();//忘记密码获取验证码
            });
        }
	}
}
//忘记密码获取验证码
function getCodeForget(){
    var forget_enterprisename = ld('#forget_enterprise_name').val();
    var forget_individualname =  ld('#forget_individual_name').val();
    var forget_phonenum =  ld('#forget_phonenum').val();
    if(forget_enterprisename==''){
        ld("#status").css('display','none');
        popFunction('企业账号不能为空');//弹出层
        return false;
    }
    if(forget_individualname==''){
        ld("#status").css('display','none');
        popFunction('个人账号不能为空');//弹出层
        return false;
    }
    if(forget_phonenum==''){
        ld("#status").css('display','none');
        popFunction('手机号码不能为空');//弹出层
        return false;
    }
    logintype = 3;//忘记密码
    ld("#status").css('display','block');
    var AjaxUrl = 'http://51mis.com/app/getenterprise.php?jsoncallback=?&corporate_account='+forget_enterprisename;
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: AjaxUrl,  //这里是网址
        success: function (data) {
            if(data.code==1){
                forgetloginurl = data.result.web_url;
                var urlstring = 'http://'+forgetloginurl+'/mobileindex.php?jsoncallback=?&module=Experience&action=ForgetPwdSMS';
                urlstring += '&user_name='+forget_individualname+'&phonenum='+forget_phonenum;
                urlstring += '&checkuser=yes'+'&appversion='+mobileVersion;
                //判断对应企业账号中是否存在该用户,同时判断用户和手机号码是否对应
                checkIsHaveUser(urlstring,forget_phonenum);
            }
            else{
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
                popFunction(data.msg);//弹出层
                return false;
            }
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            ld("#status").css('display','none');
            ld("#loading").css('display','none');
            popFunction('无法连接到服务器，<br/>请联系供应商');//弹出层
            return false;
        }
    });
}
//判断对应企业账号中是否存在该用户,同时判断用户和手机号码是否对应
function checkIsHaveUser(urlstring,forget_phonenum){
    phonenum = forget_phonenum;
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: urlstring,  //这里是网址
        success: function (data) {
            if(data.code!=1){
                popFunction(data.msg);//弹出层
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
            }
            else{
                countDown(600,logintype);
                ld('#forgetphoneNum a.getcode').unbind('click');
                ld('#forgettipText').find('span').html(forget_phonenum);
                ld('#forgettipText').removeClass('ui-visihide');
                ld("#status").css('display','none');
            }
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            ld("#status").css('display','none');
            ld("#loading").css('display','none');
            popFunction('用户对应手机号码判断失败');//弹出层
            return false;
        }
    });
}
//判断验证码是否符合，如果符合给出新的密码
function checkCodeNum(urlstring){
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: urlstring,  //这里是网址
        success: function (data) {
            if(data.code!=1){
                popFunction(data.msg);//弹出层
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
            }
            else{
                popFunction(data.msg);//弹出层
                ld('#divForgetPwd a.submit').unbind('click');
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
            }
        },
        timeout: 20000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            ld("#status").css('display','none');
            ld("#loading").css('display','none');
            popFunction('更新密码失败');//弹出层
            return false;
        }
    });
}
//弹出层
function popFunction(popvalue){
    ld('#poplayerMask').css('display','block');
    ld('.popup-remind .popub-top').html(popvalue);
    ld('.popup-remind').css('display','block');
}
//退出传值——安卓
function getAppLogin(qiyehao,yonghu,mima,jizhu,tuichu){
    logOut(qiyehao,yonghu,mima,jizhu,tuichu,'android');
}
//退出传值——浏览器、IOS
function getLogout(qiyehao,yonghu,mima,jizhu,tuichu){
    logOut(qiyehao,yonghu,mima,jizhu,tuichu,'ios');
}
function logOut(qiyehao,yonghu,mima,jizhu,tuichu,type){
    enterprise_name = qiyehao;//企业账号
    individual_name = yonghu;//个人账号
    login_pwd = mima;//密码
    isrememeberpwd = jizhu;
    isloginout = tuichu;
    if(type=='android'){
        ld('#enterprise_name').val(enterprise_name);
        ld('#individual_name').val(individual_name);
    }
    else{
        ld('#enterprise_name').val(unescape(enterprise_name));
        ld('#individual_name').val(unescape(individual_name));
    }        
    if(isrememeberpwd=='yes'){
        if(type=='android'){
            ld('#login_pwd').val(login_pwd);
        }
        else{
            ld('#login_pwd').val(unescape(login_pwd));
        }
    }
    else{
        ld('#login_pwd').val('');
    }
    if(isloginout=='yes'){
        ld('#login_pwd').val('');
    }
    if(qiyehao!=''&&yonghu!=''&&isrememeberpwd=='yes'&&isloginout!='yes'){
        ld('#loading').css('display','block');
        login();//登录
    }
}
//多次点击问题
function myClick(){
    if (t1 == null){
        t1 = new Date().getTime();
    }
    else{
        var t2 = new Date().getTime();
        if(t2 - t1 < 500){
            t1 = t2;
            return 'no';
        }
        else{
            t1 = t2;
            return 'yes';
        }
    }
}
/*ios 收起键盘后，还原
*18536: iphone5s（9.0.2）:登录界面
*/
if(phoneversion!='android'){
    ld(function () { 
        ld('input').blur(function () {
            changeHeight('3r');
        });
    })
}
//防止头部变动
function changeHeight(top){
    if(phoneversion!='android'){
        //ld('header').css('padding-top','25px');
        if(top=='3r'){
            ld('.loginbg').attr('style','top:3rem;');
        }
        else if(top=='1.5r'){
            ld('.loginbg').attr('style','top:1.5rem;');
        }
        else if(top=='1r'){
            ld('.loginbg').attr('style','top:1rem;');
        }
        else if(top=='0.5r'){  
            ld('.loginbg').attr('style','top:0.5rem;');
        }
        else if(top=='-0.5r'){
            ld('.loginbg').attr('style','top:-0.5rem;');
        }
        else if(top=='-1r'){
           ld('.loginbg').attr('style','top:-1rem;');
        }
        else if(top=='-1.5r'){
           ld('.loginbg').attr('style','top:-1.5rem;');
        }
        else if(top=='-2.5r'){
           ld('.loginbg').attr('style','top:-2.5rem;');
        }
        else if(top=='-3r'){
           ld('.loginbg').attr('style','top:-3rem;');
        }
        else if(top=='-3.5r'){
           ld('.loginbg').attr('style','top:-3.5rem;');
        }
        else if(top=='-4.5r'){
           ld('.loginbg').attr('style','top:-4.5rem;');
        }
        else if(top=='-7r'){
           ld('.loginbg').attr('style','top:-7rem;');
        }
    }
}
//IOS给Key赋值
function cacheData(key,value) {
    window.echo = cordova.exec(
        function(okParam) {
        //alert('ok' + okParam);
        }, function(err) {
        //alert('error' + error);
    }, 'CDVLDHelperPlugin', 'cacheData',[key,value]);
}
//IOS给获取Key值
function fecthData(key) {
    window.echo = cordova.exec(
        function(okParam) {
            //alert('fectch value:' + okParam);
            if(key=='a1'){
                enterprise_name=okParam;
            }
            else if(key=='b2'){
                individual_name=okParam;
            }
            else if(key=='c3'){
                login_pwd=okParam;
            }
            else if(key=='d4'){
                isrememeberpwd=okParam;
            }
            else if(key=='e5'){
                isloginout=okParam;
                getLogout(enterprise_name,individual_name,login_pwd,isrememeberpwd,isloginout);
            }
        }, function(err) {
        //alert('error' + error);
    }, 'CDVLDHelperPlugin', 'fecthData',[key]);
}
//判断是否有网络  
function checkNetwork(){
    if(phoneversion == 'android'){
        //return checkConnection();
    }
    else if(phoneversion == 'ios'){
        return checkConnection();
    }
}
function checkConnection() {
   var networkState = navigator.connection.type;
   var checkresult = 'yes';
   if(networkState=='none'){
        ld("#status").css('display','none');
        ld("#loading").css('display','none');
        popFunction('当前网络不佳或不可用');//弹出层
        checkresult = 'no';
   }
   return checkresult;
}
// 关闭提醒框
function closeRemindpop(closeRemindid){
    ld('.popup-remind div[tag=cancel]').unbind('click').on('click',function(){
        if(myClick()=='no') return;//多次点击问题
        ld('#poplayerMask,.popup-remind').css('display','none');
        ld('#'+closeRemindid).focus();
    });  
}

//登录
function login(){
    var AjaxUrl = 'http://51mis.com/app/getenterprise.php?jsoncallback=?&corporate_account='+enterprise_name;
    ld.ajax({  
        type: "get",
        contentType: "application/json; charset=utf-8",
        dataType: "jsonp",
        url: AjaxUrl,  //这里是网址
        success: function (data) {
            if(data.code!=1){
                popFunction(data.msg);//弹出层
                ld("#status").css('display','none');
                ld("#loading").css('display','none');
            }
            else{
                loginurl = data.result.web_url;
                var urlstring = 'http://'+loginurl+'/mobileindex.php?jsoncallback=?&module=Users&action=UserAuthen';
                urlstring += '&enterprise_name='+enterprise_name+'&user_name='+individual_name;
                urlstring += '&user_password='+login_pwd+'&appversion='+mobileVersion;
                getLoginUser(urlstring);//登录
            }
        },
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            var AjaxUrl = 'http://71mis.com/app/getenterprise.php?jsoncallback=?&corporate_account='+enterprise_name;
			ld.ajax({  
				type: "get",
				contentType: "application/json; charset=utf-8",
				dataType: "jsonp",
				url: AjaxUrl,  //这里是网址
				success: function (data) {
					if(data.code!=1){
						popFunction(data.msg);//弹出层
						ld("#status").css('display','none');
						ld("#loading").css('display','none');
					}
					else{
						loginurl = data.result.web_url;
						var urlstring = 'http://'+loginurl+'/mobileindex.php?jsoncallback=?&module=Users&action=UserAuthen';
						urlstring += '&enterprise_name='+enterprise_name+'&user_name='+individual_name;
						urlstring += '&user_password='+login_pwd+'&appversion='+mobileVersion;
						getLoginUser(urlstring);//登录
					}
				},
				timeout: 10000,
				error: function (XMLHttpRequest, textStatus, errorThrown) {
					ld("#status").css('display','none');
					ld("#loading").css('display','none');
					popFunction('无法连接到服务器，<br/>请检查服务器运行状态');//弹出层
					return false;
				}
			});
        }
    });
}
//IOS需要先加载cordova_ios，所以预留时间
function countDownLogin(secsLogin){ 
    if(--secsLogin>0){     
        setTimeout("countDownLogin("+secsLogin+")",1000);     
    }     
    else{       
        if(phoneversion=='ios'){
            fecthData('a1');
            fecthData('b2');
            fecthData('c3');
            fecthData('d4');
            fecthData('e5');
        } 
    }     
}
//安卓手机返回键
function backForAndroid(){
	getStack();
}