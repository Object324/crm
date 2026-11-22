<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
	<head>  
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />  
		<title>{$username} - {'ACCOUNTSECURITYCENTER'|@getFixedLabel}</title>
        {if $languageType eq 'en'} 
            <script language="javascript" type="text/javascript" src="include/language/en.js"></script>
        {else}
            <script language="javascript" type="text/javascript" src="include/language/zh.js"></script>              
        {/if}
        <script language="javascript" type="text/javascript" src="include/jquery/jquery.min.js"></script>
		<style type="text/css">
        {literal}
		* {font-family:"微软雅黑";border:0px;box-sizing: border-box;}
		a,ul,input { list-style:none; outline:none;}
		html { height:100%;}
		
		 body { 
            background:#F7F8F8;
            margin:0px auto;
            width:100%;
            height:100%;
            display: flex;
            align-items: center;
            background-size: cover !important;
            background-position: center !important;
            background: url({/literal}{$backgroundbg}{literal});
        }

		.SWrap {
            position: absolute;
            left: 50%;
            width:520px;
            margin-left: -260px;
            background:#fff; 
            border:1px #eee solid; 
            border-radius:5px; 
            padding:40px 10px 10px 40px; 
            overflow:hidden;
        }
		.SWrap .SendOk { float:left; position:absolute; left:340px; width:300px; top:10px; z-index:2; background:#A1D36E url(themes/images/icon_ok.png) no-repeat 10px 5px; border-radius:3px 3px 3px 3px; color:#fff; font-size:12px; line-height:24px;height:24px; padding:0px 15px 0px 33px;}
		
		.SBox ul {margin:0px;}
        .SBox ul li.A{/*height:42px; line-height:42px;*/padding:10px 0px;}
        .SBox ul li.a1{font-size: 18px; color: #333;}
        .SBox ul li.a2{font-size: 13px; color:#000;font-weight:bold;}
        .SBox ul li.a3{font-size: 13px; color:#666;}
        
        .SBox ul li.B,.SBox ul li.C{height:52px; line-height:52px;}
        .SBox ul li.B input,.SBox ul li.C input{font-size: 13px; border-radius: 3px;float:left;}
        .SBox ul li.B input.phoneNum {border: 1px solid #ccc; color: #ccc; height:30px; line-height:30px; padding-left:5px; width:240px;}
        .SBox ul li.B input.getVerCode{background-color:#FFE7B4;height: 30px; line-height: 30px; color: #d3a752;margin-left: 10px;padding: 0 15px;cursor: pointer;}
        .SBox ul li.B input.getVerCodeOn{background-color:#FFE7B4;height: 29px; line-height: 29px;box-shadow: 1px 1px 1px #d79c22; color: #d3a752;margin-left: 10px;padding: 0 15px;}
        .SBox ul li.B input.getVerCode:hover { background-color:#FFDB8E;}
        .SBox ul li.B .On { background-color:#DFE3E3; box-shadow:1px 1px 1px #7E8F8F; color:#aaa;}
		
        .SBox ul li.C input.inputVerCode{border: 1px solid #ccc;color: #ccc;height: 30px;line-height: 30px;padding-left: 5px;width:345px;}
        .SBox ul li.D input { width:90px; height:32px; background:#2795DC; border-radius:3px 3px 3px 3px; color:#fff; font-size:13px; cursor:pointer;}
		.SBox ul li.D input:hover {  background:#2187CB;}
		.SBox ul li.D span { float:left; font-size:13px; color:#666; height:40px; line-height:40px; padding-left:30px;}
		.SBox ul li.D span a { text-decoration:underline; color:#666;}
        
        .SBox ul li span.Errts { float:left; width:100%; font-size:12px; color:#f00; height:24px; line-height:24px;}
		.WarmRemindDiv{padding-top:12px;color: #777;font-size: 12px;float:left;}
        .WarmRemindDiv ul {margin:0px;}
        .WarmRemindDiv ul li{padding:5px 0px;}
        {/literal}
		</style>		
		<script type="text/javascript">
        {literal}
			function checkphone(obj){
				var mobile = document.getElementById('phone');
				var ab=/^[1][0-9]{10}$/;
				if(ab.test(mobile.value) != true)
				{
				    if(mobile.disabled == true){
                        var e= document.getElementById('phoneerror').style.display = 'block';
                        alert(arrJsPopLabel['MOBILEPHONENUMBERISNOTCORRECT']);
                        return false;
				    }else{
				        if(phone.value=='请输入手机号' || phone.value=='Please enter the mobile phone number')
                        {
                            alert(arrJsPopLabel['MOBILEPHONENUMBERCANNOTBEEMPTY']);
                            return false;
                        }
				        mobile.value = "";
    					var e= document.getElementById('phoneerror').style.display = 'block';
    					mobile.focus();
    					return false; 
				    }
					
				}else{
					GetMobileLoginCode(obj,mobile.value);
				}		
			}
			function GetMobileLoginCode(obj,phone)
			{
				var second = 60;
                var phone= document.getElementById('phone').value;
                var languageType=document.getElementById('languageType').value;
                var user_name=document.getElementById('user_name').value;
				obj.disabled = true;
                obj.className='getVerCodeOn On';
                $.ajax({
                    type : "POST",
                    url : "AccountSecurityCenter.php",
                    data : {'checkphone':phone,'languageType':languageType,'user_name':user_name,'getcode':'true'},
                    dataType : "json",//
                    success : function(msg) {
						if(msg == '5')
						{
							document.getElementById('alertcss').style.display = 'block';
                            var e= document.getElementById('phoneerror').style.display = 'none';
							window.setTimeout("closewin()",5000); 
							countDown(obj,second);
						}else if(msg=='1'){
                            obj.disabled = false;
                             obj.className='getVerCode';
                            alert(arrJsPopLabel['COMMUNICATIONACCOUNTISNOTSET']);
                        }else if(msg=='2'){
                            obj.disabled = false;
                             obj.className='getVerCode';
                            alert(arrJsPopLabel['COMMUNICATIONACCOUNTISNOTSETSUMISPOOR']);
                        }else if(msg=='3'){
                             obj.className='getVerCode';
                            obj.disabled = false;
                            alert(arrJsPopLabel['COMMUNICATIONACCOUNTISNOTSETEMPTY']);
                        }else if(msg=='4'){
                            obj.disabled = false;
                            obj.className='getVerCode';
                            alert(arrJsPopLabel['COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED']);
                        }
                    }
                });
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
				    var languagetype=document.getElementById('languageType');
				    if(languagetype.value=='zh')
	                    obj.value = '('+second+')'+'秒后重新获取';
                    else
                        obj.value ='Resend after'+ '('+second+')'+'seconds';
					second--;
					setTimeout(function(){countDown(obj,second);},1000);
				}else{
					obj.disabled = false;
                    obj.className='getVerCode';
					obj.value = arrJsPopLabel['TOOBTAINTHEVERFICATIONCODE'];
				}
			}
			function clickOnFoucus()
			{
               
				var mobile = document.getElementById('phone');
				var ab=/^[0-9]*[1-9][0-9]*$/;
				if(ab.test(mobile.value)!= true)
                {
					mobile.value = "";
					mobile.style.color='#000';
					mobile.focus;
				}
			}
			function clickOnBlur()
			{
				var mobile = document.getElementById('phone');
                var ab=/^[0-9]*[1-9][0-9]*$/;
				if(ab.test(mobile.value)!= true)
				{
                    mobile.value =arrJsPopLabel['PLEASEENTERTHEMOBILEPHONENUMBEREN'];
					mobile.style.color='#ccc';
				}
			}
			function clickOnFoucus_code()
			{
				var mobile = document.getElementById('code');
                var ad=/^[0-9]*[1-9][0-9]*$/;
				if(ad.test(mobile.value) != true)
				{
					mobile.value = "";
					mobile.style.color='#000';
					mobile.focus;
				}
			}
			function clickOnBlur_code()
			{
				var mobile = document.getElementById('code');
                var ad=/^[0-9]*[1-9][0-9]*$/;
				if(ad.test(mobile.value) != true)
				{
					mobile.value =arrJsPopLabel['PLEASEENTERTHEVERIFIFATIONCODEEN'];
					mobile.style.color='#ccc';
                    document.getElementById('checknumerror').style.display = 'none';
				}
			}

            function submitlogon()
            {
                var ab=/^[1][0-9]{10}$/;
                var phone= document.getElementById('phone');
                var code = document.getElementById('code');
                var user_name=document.getElementById('user_name').value;
                if(phone.disabled == true)//区分手机是否手动录入
				    var getcode='default';
				else
                    var getcode='inputtrue';
                if(phone.value=='请输入手机号' || phone.value=='Please enter the mobile phone number')
                {
                    alert(arrJsPopLabel['MOBILEPHONENUMBERCANNOTBEEMPTY']);
                    return false;
                }
                if(ab.test(phone.value) != true)
				{
					var e= document.getElementById('phoneerror').style.display = 'block';
					phone.focus();
					return false;
				}
                if(code.value=='请输入收到的验证码' || code.value=='Please enter the verification code'){
                    alert(arrJsPopLabel['VERIFCATIONCODECANNOTBEEMPTY']);
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
                    url : "AccountSecurityCenter.php",
                    data : {'phone':phone.value,'getcode':getcode,'codes':code.value,'user_name':user_name},
                    dataType : "json",
                    success : function(msg) {
                       
						if(msg == '1')
                        {
                            alert(arrJsPopLabel['PLEASEENTERTHECORRECTVERFICATIONCODE']);
                        	phone.focus();
                        }else if(msg =='4'){
                            alert(arrJsPopLabel['MOBILECODEDONTMATCH']);
                        	phone.focus();
                        }else if(msg == '2'){
                            alert(arrJsPopLabel['THEVERIFICATIONCODEHASEXPIRED']);
                        }else if(msg=='3'){
                            location.assign("index.php?action=index&module=Home");
                        }else{
                            alert(arrJsPopLabel['THEOPERATIONFAILEDTRYAGAIN']);
                        }
                    }
                });
            }
            function unsetsession() {//重新登陆
                window.location="index.php?action=Login&module=Users&login_method=true&unsetsession=true";
            }
            $(document).keypress(function(e) { 
            //监测回车键事件 
               if(e.which == 13) { 
                    submitlogon();
               } 
           }); 
        	
       {/literal}
		</script>
	</head>
	<body>
		<div class="SWrap">
			<div class="SendOk" id="alertcss" style="display:none;">{'VERIFICATIONCODESUCCESSFULLYSENT'|@getFixedLabel}</div>
			<div class="SBox">
				<ul>
					<li class="A a1">{'ACCOUNTSECURITYCENTER'|@getFixedLabel}</li>
					<li class="A a2">
                        {'MOBILEPHONEVERFICATION'|@getFixedLabel}
                        
                    </li>
                    <li class="A a3">{'INORDERTOPROTECTYOURACCOUNTSECURITY'|@getFixedLabel}</li>
					<li class="B">
                        <input class="phoneNum" id="phone" name="phone" onfocus="return clickOnFoucus(this)" onblur="return clickOnBlur(this)" type="text" {if $phone_mobile neq ''}value="{$phone_mobile}" disabled="true"{else}value="{'PLEASEENTERTHEMOBILEPHONENUMBER'|@getFixedLabel}"{/if} />
                        <input type="button" class="getVerCode"  onclick=" return checkphone(this)" value="{'TOOBTAINTHEVERIFIFATIONCODE'|@getFixedLabel}" />
                        <input type='hidden' id="languageType" name="languageType" value="{$languageType}"/>
                        <input type="hidden" id='user_name' name='user_name' value="{$user_name}"/>
                        <span id="phoneerror" style="display:none;" class="Errts">{'PLEASEENTERTHECORRECTMOBILEPHONENUMBER'|@getFixedLabel}</span>
                    </li>
					<li class="C">
                        <input class="inputVerCode" id="code" name="code" onfocus="return clickOnFoucus_code(this)" onblur="return clickOnBlur_code(this)" type="text" value="{'PLEASEENTERTHEVERIFIFATIONCODE'|@getFixedLabel}"  />
                        <span id="checknumerror" style="display:none;" class="Errts">{'PLEASEENTERTHECORRECTVERFICATIONCODEZH'|@getFixedLabel}</span>
                    </li>
                    <li class="D" style="padding-left:55px;">
                        <input onclick="return submitlogon()" type="submit" value="{'SUBMIT'|@getFixedLabel}" />&nbsp;&nbsp;
                        <input onclick="return unsetsession()" type="button" value="{'RELOGIN'|@getFixedLabel}" />
                    </li>
				</ul>
			</div>
            <!--温馨提醒-->
            <div class="WarmRemindDiv">
                <ul>
                    <li>{'WARMREMINDE'|@getFixedLabel}</li>
                    <li>{'WARMREMINDEONE'|@getFixedLabel}</li>
					<li>{'WARMREMINDETWO'|@getFixedLabel}</li>
                    <li>{'WARMREMINDETHREEE'|@getFixedLabel}</li>
                    <li>{'WARMREMINDEFOR'|@getFixedLabel}</li>
				</ul>
            </div>
			
		</div>
        <script type="text/javascript">
            $(function(){
                $('#phone').focus();
            })
        </script>
	</body>
</html>