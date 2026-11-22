/**
 * User: Dong
 * Project: ldcrm
 * Date: 2020/7/29 13:30
 * Description: 表单推广 外部访问需要的js
 */
document.write("<script type='text/javascript' src='../../include/jquery/jquery.min.js'></"+"script>");

// 文本
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/ExternalAccessLang.js'></"+"script>");
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/rem-simple.js'></"+"script>");
//验证
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/jquery.validate.min.js'></"+"script>");
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/validate-methods.js'></"+"script>");
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/messages_zh.min.js'></"+"script>");
// 弹出层js
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/layer.js'></"+"script>");
// 时间选择器插件
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/jdate.min.js'></"+"script>");
//  加载公共方法
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/commonFunctions.js'></"+"script>");
// 复选单选插件
document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/dropdown.min.js'></"+"script>");
// 分享

if(isWeiXin()){
    document.write("<script type='text/javascript' src='https://res.wx.qq.com/open/js/jweixin-1.6.0.js'></"+"script>");
    document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/wxjssdk_share.js'></"+"script>");
}



// 判断是否是微信浏览器的函数
function isWeiXin(){
    //window.navigator.userAgent属性包含了浏览器类型、版本、操作系统类型、浏览器引擎类型等信息，这个属性可以用来判断浏览器类型
    var ua = window.navigator.userAgent.toLowerCase();
    //通过正则表达式匹配ua中是否含有MicroMessenger字符串
    if(ua.match(/MicroMessenger/i) == 'micromessenger'){
        return true;
    }else{
        return false;
    }
}

