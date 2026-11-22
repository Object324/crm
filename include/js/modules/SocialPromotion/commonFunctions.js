/**
 * User: Dong
 * Project: ldcrm
 * Date: 2020/7/29 13:28
 * Description:
 */
function nowTime() {
    var d = new Date();
    var time = d.getTime();
    return time;
}

//获取url中的uid 赋值给uid
function changeUid() {
    var url = window.location.href;
    var uid = getSearchString('uid', url)
    $('input[name=uid]').val(uid);
}

//改变h5按钮的链接 在后面加上url的参数
function changeH5ButtonUrl() {
    var url = window.location.href;
    var uid = getSearchString('uid', url)
    var href = $('#h5button a').attr('href');
    $('#h5button a').attr('href', href + '?uid=' + uid);
}

//获取url中的参数
function getSearchString(key, Url) {
    var str = Url;
    str = str.substring((str.indexOf('?') + 1), str.length); // 获取URL中?之后的字符（去掉第一位的问号）
    // 以&分隔字符串，获得类似name=xiaoli这样的元素数组
    var arr = str.split("&");
    var obj = new Object();
    // 将每一个数组元素以=分隔并赋给obj对象
    for (var i = 0; i < arr.length; i++) {
        var tmp_arr = arr[i].split("=");
        obj[decodeURIComponent(tmp_arr[0])] = decodeURIComponent(tmp_arr[1]);
    }
    return obj[key];
}

/**
 * 检查访问时间 5秒内算访问一次
 * @param viewKey
 */
function checkViewTime(viewKey,record){
    var oldViewTime = sessionStorage.getItem(viewKey);
    // @edit:dong @date:2020/07/16 @reason: 添加 5秒内重复刷新只算一次访问量
    if(oldViewTime!= undefined && oldViewTime != '' ){
        if (nowTime() - oldViewTime > 5000) {
            //更新访问数
            upViewNum(record);
            sessionStorage.setItem(viewKey, nowTime());
        }
    }else{
        //更新访问数
        upViewNum(record);
        //缓存访问时间
        sessionStorage.setItem(viewKey, nowTime());
    }

}
//访问一次更新一次单据访问数量
function upViewNum(record) {
    var url = window.location.href;
    var uid = getSearchString('uid', url)
    $.ajax({
        url: '../../modules/SocialPromotion/UpdateViewNum.php',
        data: 'record=' + record+'&uid='+uid,
        type: 'POST',
        dataType: 'json',
        timeout: 5000,
        success: function (data) {

        }
    })
}

// 联动检查是前字段是否有值
function checkBeforecascade(obj) {
    var beforecascade = $(obj).attr('beforecascade');
    var value = $('select[name=' + beforecascade + ']').val();
    if (value == '' || value == undefined) {
        layer.open({
            content: PleaseSelectFirst+fieldsColumnName[beforecascade],
            btn: Close,
        })
    }
    return false;
}

// 设置联动下级的内容 并清空下下级内容
function setAfterCascade(obj) {
    var afterCascade = $(obj).attr('afterCascade')
    if (afterCascade == '' || afterCascade == undefined) {
        //不存在下级级联字段直接返回
        return false;
    }
    //循环清空所有下级级联字段
    clearAfterHtml(afterCascade);
    var value = $(obj).val();


    $.ajax({
        url: '../../modules/SocialPromotion/GetCascadeValue.php',
        data: 'afterCascade=' + afterCascade + '&value=' + value + '&mappingmodule=' + Mappingmodule,
        type: 'POST',
        dataType: 'json',
        timeout: 5000,
        success: function (data) {
            if (data.code == 1) {
                $('select[name=' + afterCascade + ']').html(data.result.content);
            } else {
                layer.open({
                    content: PleaseRefresh,
                    btn: Close,
                })
            }
        }
    })
    return false;
}

// 有下级级联的级联字段选值时 循环清空所有下级字段的html
function clearAfterHtml(afterCascade) {
    $('input[name='+afterCascade+']').html();
    var that =this;

    this.clear=function(afterCascade){
        $.each(Cascade,function (i,val) {
            if(val == afterCascade){
                $('input[name='+i+']').html();
                that.clear(i)
            }
        })
    }
    this.clear(afterCascade);
}

//判断是否是微信浏览器的函数
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

function  getWxShareConfig(url) {

    $.ajax({
        url : "../../modules/SocialPromotion/GetWeixinShareSign.php",//网址
        data: {url:url},
        type: 'POST',
        dataType: 'json',
        timeout: 5000,
        success : function(data){
            if(data.code ==1){
                wx.config({
                    appId: data.result.appId,
                    timestamp: data.result.timestamp,
                    nonceStr: data.result.nonceStr,
                    signature: data.result.signature,
                    jsApiList: [
                        "updateAppMessageShareData",
                        "updateTimelineShareData",
                        "onMenuShareWeibo"
                    ]
                });
            }
        },
        error:function(data){
            console.log((JSON.stringify(data)));
            //alert("连接失败！");
        }
    });
}