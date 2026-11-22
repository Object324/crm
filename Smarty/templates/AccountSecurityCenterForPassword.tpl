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
		<!--<script type="text/javascript" type="text/javascript" src="include/jquery/PIE.js"></script>-->
		<style type="text/css">
        {literal}
		* {font-family:"微软雅黑";border: 0px;box-sizing: border-box;}
		a,ul,input{ list-style:none; outline:none;}
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
            background: url(dataCache/test/logo/login_bg.jpg);
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
		.WarmRemindDiv{padding-top:30px;color: #777;font-size: 12px;float:left;}
        .WarmRemindDiv ul {margin:0px;}
        .WarmRemindDiv ul li{/*height:30px;line-height:30px;*/padding:5px 0px;color:#2B2B2B}
        .WarmRemindDiv ul li:first-child{font-size: 13px;color: #000;font-weight: bold;}
        {/literal}
		</style>		
		<script type="text/javascript">
        {literal}


        $(function(){

            $('#checknewerror').prev().focus();

            $('.WarmRemindDiv ul li').eq(-1).css('padding','5px 0px 5px 10px').html('●'+$('.WarmRemindDiv ul li').eq(-1).html());
            $('.WarmRemindDiv ul li').eq(-2).css('padding','5px 0px 5px 10px').html('●'+$('.WarmRemindDiv ul li').eq(-2).html());
            $('.WarmRemindDiv ul li').eq(-3).css('padding','5px 0px 5px 10px').html('●'+$('.WarmRemindDiv ul li').eq(-3).html());
            $('.WarmRemindDiv ul li').eq(-4).css('padding','5px 0px 5px 10px').html('●'+$('.WarmRemindDiv ul li').eq(-4).html());


           /* $(document).keydown(function(event){
                if(event.which == "9") {  $(".inputVerCode").eq(1).click() ;return;}
            });*/


        });


        function mysubmitlogon(){

            $valfir = $('#checknewerror').prev().val();
            $valsec = $('#checknumerror').prev().val();

            $.get("index.php",{passwordinfo : $valfir ,confirmpasswordinfo : $valsec,module:"Users",file:"CheckPwd",'action':"UsersAjax"},function(response){
                
                   
                if(response.indexOf("user_name") >=0)
                {
                   
                    window.location="index.php?module=Users&action=UserSMSLogin&return_action=Login&return_module=Users&CheckPwdSuccess=yes&bodywidth=1423";
                }
                    
                else{

                    if(response.substr(-2) == 'SE') {
                        $('#checknumerror').html(response.substr(0, response.length - 2)).css('display', 'block');
                        $('#checknumerror').prev().focus();
                        $('#checknewerror').css('display', 'none');
                    }else if(response.substr(-2) == 'FI'){
                        $('#checknewerror').html(response.substr(0, response.length - 2)).css('display', 'block');
                        $('#checknewerror').prev().focus();
                        $('#checknumerror').css('display', 'none');
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
    {*
     * editor : gyq_01
     * reason : 新增用户密码严格管理
     * date   : 2016.1.15
    *}
		<div class="SWrap">
			<div class="SendOk" id="alertcss" style="display:none;">{'VERIFICATIONCODESUCCESSFULLYSENT'|@getFixedLabel}</div>
			<div class="SBox">
				<ul>
					<li class="A a1">{'ACCOUNTSECURITYCENTER'|@getFixedLabel}</li>
					<li class="A a2">
                        {'PASSWORDVERFICATION'|@getFixedLabel}

                    </li>
                    <li class="A a3">{$NOTICEPASSWORDSTANDARDFAILED}</li>

                    <li class="C">
                        <input class="inputVerCode" id="code" name="code" type="password" placeholder = "{'NEWPASSWORD'|@getFixedLabel}"   />
                        <span id="checknewerror" style="display:none;" class="Errts"></span>
                    </li>
					<li class="C">
                        <input class="inputVerCode" id="code" name="code" type="password" placeholder="{'Password_confirmation'|@getFixedLabel}"  />
                        <span id="checknumerror" style="display:none;" class="Errts">{'PLEASEENTERTHECORRECTVERFICATIONCODEZH'|@getFixedLabel}</span>
                    </li>
                    <li class="D" style="padding-left:55px;">

                        <input onclick="return mysubmitlogon()" type="submit" value="{'SUBMIT'|@getFixedLabel}" />&nbsp;&nbsp;
                        <input onclick="return unsetsession()" type="button" value="{'CANCEL'|@getFixedLabel}" />
                    </li>

				</ul>
			</div>
            <!--温馨提醒-->
            <div class="WarmRemindDiv">
                <ul>
                    {$WARMREMINDFORPASSWORD}
				</ul>

            </div>

		</div>
	</body>
</html>