<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Access-Control-Allow-Origin" content="*">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>{$name}</title>
    <meta name="viewport" content="initial-scale=1, maximum-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/base.css">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/Questionnaire.css">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/common.css">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/style.css">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/leftmenu.css">
    <script type='text/javascript' src='../../include/jquery/jquery.min.js'></script>
    <script>
        if(ld==undefined){
            var ld = $;
            var browser_ie = true;
            var languege = 'zh';
        }
    </script>
    <script type='text/javascript' src='../../include/js/modules/SocialPromotion/commonFunctions.js'></script>
    <script type='text/javascript' src='../../include/js/modules/SocialPromotion/jquery.validate.min.js'></script>
    <script type='text/javascript' src='../../include/js/modules/SocialPromotion/validate-methods.js'></script>
    <script type='text/javascript' src='../../include/js/modules/SocialPromotion/messages_zh.min.js'></script>
    <script type='text/javascript' src='../../include/js/modules/SocialPromotion/layer.js'></script>
    <script language="JavaScript" type="text/javascript" src="../../include/js/SystemPopup/CrmPopup.js"></script>
    <script language="JavaScript" type="text/javascript" src="../../include/js/MsgPopup.js"></script>
    <script language="JavaScript" type="text/javascript" src="../../include/js/SystemPopup/PopupLayer.js"></script>
    <script language="JavaScript" type="text/javascript" src="../../include/language/zh.js"></script>
    <script language="JavaScript" type="text/javascript" src="../../include/js/SystemPopup/PopupDrag.js"></script>
    <script language="JavaScript" type="text/javascript" src="../../include/js/ldAjax.js"></script>
</head>
<body>
<input type="hidden" name="description" value="{$description}">
<div class="container">
    <div class="headdiv">
        <h1 id="show_activitytitle">{$name}</h1>
        {if $description neq ''}
            <p id="show_activityintroduction">
                {$description|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
            </p>
        {/if}
    </div>
    <div class="formdiv">
        <form id="validate" action="">
            <input type="hidden" name="record" value="{$record}">
            <div id="mainFieldsIphone" style="margin-top: 20px;">
                {include file='modules/Questionnaire/PC.tpl'}
            </div>
            <div class="Q_Submit">
                <button class="ld-button ld-button-primary">提交</button>
            </div>
        </form>
    </div>
</div>
</body>
{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
<script>
    // 所有字段对应的中文名称
    var fieldsColumnName = '{$fieldsColumnName}';
    var data = '{$data}';
    var datajson = '{$datajson}';
    var record = '{$record}';
    var name = '{$name}';
    //ls 2022-05-06  0051464: 做完调查问卷之后，扫码填写完点击提交会刷新掉填写的内容并没有提交(报错了，问卷描述带换行后，js这里报错语法不对)
    {*var description = '{$description}';*}
    var description = $("input[name='description']").val();
    var recovery_endremarks = '{$recovery_endremarks}';

    var  PleaseSelect='请选择';
    var  NotSubmitAgain='请勿重复提交';
    var  Close ='关闭';
    var  MsgSubmit ='信息已提交';
    var  PleaseSelectFirst='请选择先选择';
    var  PleaseRefresh='请刷新后重试';
    var  urlArr = ['51mis.com','61mis.com','xiaoshou360.com'];

    var shareurl =window.location.href.split('#')[0];//当前页面的链接 不可以带#及以后参数
</script>
<script language="JavaScript" type="text/javascript" src="../../include/js/modules/Questionnaire/QuestionnaireHtml.js"></script>
<script>
    // 生成复选框
    $().ready(function () {
        /*if(isWeiXin()){
            $.each(urlArr,function(i,val){
                if(shareurl.indexOf(val) !== -1){
                    getWxShareConfig(shareurl);
                }
            })
        }*/

        var key = 'clickTime';
        var viewKey = 'viewKey';
        //检查访问时间
        // checkViewTime(viewKey,record);
        //更新浏览次数，访问一次更新一次单据访问数量
        upViewNum();
        function upViewNum() {
            var url = window.location.href;
            var uid = getSearchString('uid', url)
            $.ajax({
                url: '../../modules/Questionnaire/StatisticsHtml.php',
                data: 'action=upview&record='+record+'&uid='+uid,
                type: 'POST',
                dataType: 'json',
                timeout: 5000,
                success: function (data) {
                    if (data.code == '-1'){ //提示问卷已暂停
                        // 信息框
                        layer.open({
                            // content: MsgSubmit,
                            content: data.msg,
                            btn: Close,
                            yes: function(){
                                var index = layer.open();
                                layer.close(index);
                                window.close();
                            },
                        });
                    }
                    console.log('views 已更新');
                }
            })
        }

        // var height = window.screen.availHeight;
        // $('#h5iframe').height(height);
        // 在键盘按下并释放及提交后验证提交表单
        $("#validate").validate({
            rules: {
                // 生成字段验证信息
                {foreach key=blockid item=block from=$data['blockinfo']}
                    {foreach key=key item=topic from=$block['topic_array']}
                        {if $topic.topic_type == 'more'}
                            '{$topic.topic_type}_{$topic.topicid}[]':
                                {
                                    {if $topic.required eq 'yes'}required:true,{/if}
                                },
                        {else}
                            {$topic.topic_type}_{$topic.topicid}:
                            {
                                {if $topic.required eq 'yes'}required:true,{/if}
                            },
                        {/if}
                    {/foreach}
                {/foreach}
            },
            //将错误提示信息放在标题后面,而不是输入框后
            errorPlacement: function(error, element) {
                error.appendTo(element.parent("div").prev("div"));
            },
            //验证通过提交事件
            submitHandler:function (form) {
                var oldtime = sessionStorage.getItem(key)
                // 验证两次提交间隔
                if (oldtime != undefined && oldtime != '') {
                    if (nowTime() - oldtime < 1000) {
                        layer.open({
                            content: NotSubmitAgain,
                            btn: Close})
                        return false;
                    }
                }
                //缓存提交时间
                sessionStorage.setItem(key, nowTime());
                //$('.submit').attr('disabled', 'disabled')

                $.ajax({
                    url: '../../modules/Questionnaire/StatisticsHtml.php',
                    data: $('#validate').serialize()+'&action=save',
                    type: 'POST',
                    dataType: 'json',
                    timeout: 5000,
                    success: function (data) {
                        if(data.code == 1){
                            //信息框
                            layer.open({
                                // content: MsgSubmit,
                                content: recovery_endremarks,
                                btn: Close,
                                yes: function(){
                                    // 清空表单
                                    document.getElementById("validate").reset();
                                    $('.submit').attr('disabled','disabled')
                                    var index = layer.open();
                                    layer.close(index);
                                    window.close();
                                },
                            });
                        }else if(data.code == -2){
                            layer.open({
                                // content: MsgSubmit,
                                content: data.msg,
                                btn: Close,
                                yes: function(){
                                    var index = layer.open();
                                    layer.close(index);
                                },
                            });
                        }
                    }
                })
            }
        });
    });
</script>
<style>
label.error {
  color: red;
  font-weight: bold;
}
</style>
</html>