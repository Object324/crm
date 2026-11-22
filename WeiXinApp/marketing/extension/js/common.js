/** 
* @edit:diony 
* @date:2020-11-16
* @description:手机端推广大使
*/

$(function(){
    if (sessionStorage.getItem('userid') == null) {
        if (getQueryStringByName('userid')) {
            sessionStorage.setItem('userid', getQueryStringByName('userid'));
        }
        else {
            sessionStorage.setItem('userid', '1');
        }
    }

	var $el = $('.dialog');
    $el.hDialog();

    //获取验证码
    $('.getCode').click(function() {
        var PhoneReg=/^[1][0-9]{10}$/;//手机正则
        var $phone = $('.phone');
        if($phone.val() == ''){
            $.tooltip('手机不能为空'); $phone.focus();
        }
        else if(!PhoneReg.test($phone.val())){
            $.tooltip('手机格式不正确'); $phone.focus();
        }        
        else{
            $.tooltip('获取验证码成功，2秒后自动关闭',2000,true);
            var smshidecode = getCode(6);
            $('.smshidecode').val(smshidecode);
            var url = corpurl + 'module=SmsSender&action=index&times=2&mobile=' + $phone.val() + '&code=' + smshidecode;
		    $.ajax({
		        type: "get",
		        dataType: "json",
		        url: url,
		        success: function(data) {
		            if(data.code == 1){                        
		                $('#send-code').attr('disabled','disabled');
		                countDown(second);
		            }
                    else{
                        $.tooltip(data.result.data);
		            }
		        },
		        timeout: 20000,
		        error: function(XMLHttpRequest, textStatus, errorThrown){
		        }
		    });
            setTimeout(function(){
                $el.hDialog('close',{box:'#HBox'});
            },2000);
        }
    });

    //提交并验证表单
    $('.submitBtn').click(function() {
        var PhoneReg=/^[1][0-9]{10}$/;//手机正则
        var ZhongWenReg=/^[\u4e00-\u9fa5]{0,}$/;//中文正则
        var $nickname = $('.nickname');
        var $phone = $('.phone');
        var $smscode = $('.smscode');
        var $smshidecode = $('.smshidecode');
        if($nickname.val() == ''){
            $.tooltip('姓名不能为空'); $nickname.focus();
        }
        else if(!ZhongWenReg.test($nickname.val())){
            $.tooltip('姓名只能为中文'); $nickname.focus();
        }
        else if($phone.val() == ''){
            $.tooltip('手机不能为空'); $phone.focus();
        }
        else if(!PhoneReg.test($phone.val())){
            $.tooltip('手机格式不正确'); $phone.focus();
        }
        else if($smscode.val() == ''){
            $.tooltip('验证码不能为空'); $smscode.focus();
        }
        else if($smscode.val() != $smshidecode.val()){
            $.tooltip('验证码和手机号码不匹配'); $smscode.focus();
        }
        else{
            $.tooltip('提交成功，2秒后自动关闭',2000,true);            
            var url = corpurl + 'module=Ambassador&action=applyAmbassador&apply_name=' + $nickname.val() + '&apply_phone=' + $phone.val() + '&smownerid=' + sessionStorage.getItem('userid');
            $.ajax({
                type: "get",
                dataType: "json",
                url: url,
                success: function(data) {
                    if(data.code == 1){                        
                    }
                    else{
                        $.tooltip(data.result.data);
                    }
                },
                timeout: 20000,
                error: function(XMLHttpRequest, textStatus, errorThrown){
                }
            });
            $nickname.val('');
            $phone.val('');
            $smscode.val('');
            setTimeout(function(){
                $el.hDialog('close',{box:'#HBox'}); 
            },2000);
        }
    });
});

//随机数字字符串
function getCode(e) {
  e = e || 6;
  var t = "0123456789",
  a = t.length,
  n = "";
  for (i = 0; i < e; i++) n += t.charAt(Math.floor(Math.random() * a));
  return n;
}

//倒计时
function countDown(second) {
  	if(second >= 0 ){
		$('#send-code').val(second+'s');
        $('#send-code').html(second+'s');
		second--;
		setTimeout(function(){countDown(second);},1000);
	}
	else{
		$('#send-code').removeAttr("disabled");
		$('#send-code').val('获取验证码');
        $('#send-code').html('获取验证码');
	}
}

//获取传参
function getQueryStringByName(name){
    var queryString = location.href;
    if (queryString) {
        var result = queryString.match(new RegExp("[\?\&]" + name+ "=([^\&]+)","i"));
        if(result == null || result.length < 1){
            return "";
        }
        return result[1];
    }
}