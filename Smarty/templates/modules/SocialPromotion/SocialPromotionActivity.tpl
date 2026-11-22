<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8"/>
    <meta name="renderer" content="webkit"/>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1"/>
    <meta content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"
          name="viewport"/>
    <title>{$activitytitle}</title>
    <meta name="keywords" content=""/>
    <meta name="description" content=""/>
    <meta content="fullscreen=yes,useHistoryState=yes,transition=yes" name="App-Config"/>
    <script type='text/javascript' src='../../include/jquery/jquery.min.js'></script>
    <link rel="stylesheet" type="text/css" href="../../themes/softed/layer_mobile.css">
    <link rel="stylesheet" type="text/css" href="../../themes/softed/socialOutAccess.css">
{*    <link rel="stylesheet" type="text/css" href="themes/softed/socialOutAccess.css">*}

    <style>
        /*//错误信息颜色*/
        label.error {
            color: Red;
        }
    </style>
</head>
<body>
<div class="container">
    {*    仅表单和h5和表单的form存的情况显示提交窗口*}
    {if $social_activitytype eq 'onlyForm' || $form == 1}
        {include file="modules/SocialPromotion/SocialActivityFrom.tpl"}
    {else}
        {include file="modules/SocialPromotion/SocialActivityH5.tpl"}
    {/if}
</div>
</body>

<script>
    // 所有字段对应的中文名称
    var fieldsColumnName = {$fieldsColumnName};
    // 联动关系
    var Cascade = {$cascade};
    //映射模块
    var Mappingmodule = "{$mappingmodule}";
    var record = {$record};
    var shareTitle = '{$sharetitle}';
    var sharepicture = '{$sharepicture}';
    var shareurl =window.location.href.split('#')[0];//当前页面的链接 不可以带#及以后参数
    document.write("<script type='text/javascript' src='../../include/js/modules/SocialPromotion/ExternalAccess.js'></"+"script>");
</script>
<script>
    // 生成复选框
    $().ready(function () {
        if(isWeiXin()){
            $.each(urlArr,function(i,val){
                if(shareurl.indexOf(val) !== -1){
                    getWxShareConfig(shareurl);
                }
            })
        }
        //生成时间字段的时间选择器    // 生成复选框
        {foreach key=key item=field from=$customFields}

            {if $field['bigtype'] eq 'date' || $field['bigtype'] eq 'time' || $field['bigtype'] eq 'datetime'}
            new Jdate({
                el: 'input[name={$field['columnname']}]',
                format: {$field['formate']},
                beginYear: 1920,
                endYear: 2100
            })
            {/if}
            {if $field['bigtype'] eq 'multipicklist' &&  $field['pickListValue'] !=''}
                var multiple_{$field['columnname']} = new Dropdown({
                        dom: '{$field['columnname']}',//点击触发下拉的选择框的id
                        type: 'multiple',//是单选还是多选 单选 single 多选 multiple
                        title: PleaseSelect,//选择框title
                        required: false,//是否必填 true:必填 ，false : 非必填
                        requiredTip: '', // required为true，用户没有选择的提示文案
                        columnname: '{$field['columnname']}',
                        dataArr: {$field['pickListValue']},//选择的选项数据，为3的倍数，不足用 '' 代替
                        success: function (resp) { // 回调函数
                            console.log('{$field['columnname']}');
                            var val = '';
                            var data_id = '';
                            if(resp.length>0){
                                for(var i in resp){
                                    val += resp[i].cont + ','
                                    data_id += resp[i].id + ','
                                }
                            }else{
                                val =  PleaseSelect
                            }
                            $('#{$field['columnname']}').val(val);
                            $('#{$field['columnname']}').attr('data-id',data_id);
                        }
                    })
            {/if}

        {/foreach}
        // end 时间选择器
        var key = 'clickTime';
        var viewKey = 'viewKey';
        //检查访问时间
        checkViewTime(viewKey,record);
        var height = window.screen.availHeight;
        $('#h5iframe').height(height);
        // 在键盘按下并释放及提交后验证提交表单
        $("#validate").validate({
            rules: {
                // 生成字段验证信息
                {foreach key=key item=field from=$customFields}
                {$field['columnname']}:
                    {
                    {if $field['required'] eq 1}required:true,{/if}
                            {if $field['bigtype'] eq 'phone' or $field['bigtype'] eq 'fax'}isPhone:true,{/if}
                            {if $field['bigtype'] eq 'qq'}isQQ:true,{/if}
                            {if $field['bigtype'] eq 'mobile'}isMobile:true,{/if}
                            {if $field['bigtype'] eq 'email'}email:true,{/if}
                            {if $field['bigtype'] eq 'url'}url:true,{/if}
                            {if $field['bigtype'] eq 'number'}number:true,{/if}
                    },
                {/foreach}
            },
        //验证通过提交事件
        submitHandler:function (form) {
            var oldtime = sessionStorage.getItem(key)
            // 验证两次提交间隔
            if (oldtime != undefined && oldtime != '') {
                if (nowTime() - oldtime < 10000) {
                    layer.open({
                        content: NotSubmitAgain,
                        btn: Close})
                    return false;
                }
            }
            //缓存提交时间
            sessionStorage.setItem(key, nowTime());
            $('.submit').attr('disabled', 'disabled')

            $.ajax({
                url: '../../modules/SocialPromotion/SaveHtmlForm.php',
                data: $('#validate').serialize(),
                type: 'POST',
                dataType: 'json',
                timeout: 5000,
                success: function (data) {
                    //信息框
                    layer.open({
                        content: MsgSubmit,
                        btn: Close,
                        yes: function(){
                            // 清空表单
                            document.getElementById("validate").reset();
                            $('.submit').attr('disabled',false)
                            var index = layer.open();
                            layer.close(index);
                        },
                    });

                }
            })
        }
    })
        {if $social_activitytype eq 'onlyForm' || $form == 1}
        changeUid()
        {else}
        {literal}
        changeH5ButtonUrl();
        {/literal}
        {/if}
    });

</script>

</html>