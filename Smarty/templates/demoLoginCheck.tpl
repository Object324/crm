<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>{$TITLE}</title>
    
	<link rel="stylesheet" href="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/css/chooseIndustry.css">
	<script type="text/javascript" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/js/SMSLoginCheck1.js?v=eea"></script>
    <script type="text/javascript">
     jsrand='{$jsrand}';
     demologinrand='{$demologinrand}';
	 
    </script>
</head>
<body>
	<div class="industry-bg"></div>
	<div class="c-wrap">
		<div class="industry-type">
			<h1 class="title">请您选择行业</h1>
			<ul>
				<li class="type-item type-item-1" id="crm"><em></em><span>标准行业</span></li>
				<li class="type-item type-item-2" id="crmit"><em></em><span>IT行业</span></li>
				<li class="type-item type-item-3" id="demo607"><em></em><span>金融行业</span></li>
				<li class="type-item type-item-4" id="bank"><em></em><span>银行</span></li>
				<li class="type-item type-item-5" id="jiaoyu"><em></em><span>教育培训</span></li>
				<li class="type-item type-item-6" id="yimin"><em></em><span>移民留学</span></li>
				<li class="type-item type-item-7" id="xiangmu"><em></em><span>项目管理</span></li>
				<li class="type-item type-item-8" id="renzheng"><em></em><span>咨询认证</span></li>
				<li class="type-item type-item-9" id="yiliao"><em></em><span>医疗器械</span></li>
				<li class="type-item type-item-10" id="zhileng"><em></em><span>制冷行业</span></li>
				<li class="type-item type-item-11" id="yuanqu"><em></em><span>房地产租赁</span></li>
				<li class="type-item type-item-12" id="jiance"><em></em><span>环境检测</span></li>
				<li class="type-item type-item-13" id="jijin"><em></em><span>私募基金</span></li>
				<li class="type-item type-item-14" id="daizhang"><em></em><span>代理记账</span></li>
			</ul>
		</div>
	</div>
	<div class="registerDiv"></div>
	<div class="content">
	  <div class="pagetitle">欢迎体验灵当CRM</div>
	    <div class="table-row">
	      <div class="table-cell">
	        <ul class="list-style">
	          <li>1、体验帐号的数据是预先设置的，系统将定期更新，请勿在体验帐号中输入重要数据。</li>
	          <li>2、如有疑问，请随时拨打免费咨询热线：021-63201212。</li>
	          <li>
	            <div class="register_form">
	                <div class="form-item">
					  <input type="hidden" id="verson" name="verson" value="{$CVERSION}">
	                  <input id="checkphone" class="form-text" type="text" maxlength="11" value="" placeholder="请输入手机号" autofocus="autofocus"/>
	                  <span class="msg-error">请填写正确的手机号</span>
	                  <span class="required">*</span>
	                </div>
					<div class="inner-form hide">
					  <div class="form-item codetext">
						<div class="text">
						  <input type="text" id="code" class="form-text" placeholder="请输入验证码" maxlength="6" oninput="return keyinput('code');"><span class="msg-error">请输入验证码</span>
						</div>
						<div class="btn-wrap">
						  <input id="send-code" class="form-btn disabled" type="button" value="获取验证码"  onclick="return SMS_send();">
						</div>
					  <div class="codetips"><a href="javascript:;" class="codetips-btn" id="js-fetch-voice-verify">短信可能有延迟，<br> 请稍等一会！</a></div></div>
					</div>
					<div class="form-item">
	                  <input id="demoLogin" class="form-btn disabled" type="button" onclick="return demoLogin();" disabled value="立即体验">
	                  <div class="register_login">已有帐号？<a href="index.php?module=Users&action=Login&login_method=true">立即登录</a></div>
	                </div>
	            </div>
	          </li>
	        </ul>
	      </div>
	    </div>
	</div>
</body>
</html>