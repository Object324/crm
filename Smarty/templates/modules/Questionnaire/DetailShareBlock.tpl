{*<script language="javascript" type="text/javascript" src="{$JSURL}include/js/clipboard.min.js?v={$GLOBALMINVERSION}"></script>*}
<script type="text/javascript">
    AjaxJSPage("clipboard_min",'include/js/clipboard.min.js');
</script>
{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
    <tr>
        <td style="width:100%;">
            <div class="DivCName DivCNamehover" onclick="showHideStatus('tbltgm','aidtgm')">
                <span class="{$arrawcls}" id="aidtgm" name="aidtgm"></span>问卷分享
            </div>

            <div id="tbltgm" name="tbltgm">
                <table class="DetailContentTable " style="width: 100%; text-align: center">
                    {if $Have_Questionnaire == 'yes'}
                        <tr>
                            <td width="20%">{$Qrcode['lastname']}</td>
                            <td width="20%">{*模拟点击img 展示图片*}
                                <img width="0" height="0" name="qrcode" onclick="" data-original="{$Qrcode['qrcode']}" src="{$Qrcode['qrcode']}" alt="">
                                <a href="javascript:void(0)" onclick="ld('img[name=qrcode]').click()">{'ACTIVITYMOBILEPHONESCANANDSHARE'|@getFixedLabel}</a>
                            </td>
                            <td width="20%">
                                <a  href="{$Qrcode['downQrcode_URL']}" target="_blank">{'ACTIVITYDOWNEWM'|@getFixedLabel}</a>
                            </td>
                            <td width="20%">
                                <a href="javascript:void(0)" class="copyUrl" data-clipboard-text="{$Qrcode['shareUrl']}">{'ACTIVITYCOPYURL'|@getFixedLabel}</a>
                            </td>
                            <td width="20%">
                                <a href="{$Qrcode['shareUrl']}" target="_blank"">{'OpenQuestionnaire'|@getFixedLabel}</a>
                            </td>
                        </tr>
                    {else}
                        <tr>
                            <td colspan="5" width="20%">{'NOQUESTIONNAIREHTML'|@getFixedLabel}</td>
                        </tr>
                    {/if}
                </table>
            </div>
        </td>
    </tr>

<script>


    // 使用listview.js中的previewImage函数 展示图片
    ld(function(){
        // 复制插件
        var Clipboard = new ClipboardJS('.copyUrl');
        Clipboard.on('success', function(e) {
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED']);
        });

        var images= ld('#tbltgm img');
        if(images.length>0){
            ld.each(images,function (i,val) {
                // 使用previewImage函数 需要提前加载加载事件。要不会出现第一次点击不能弹出
                previewImage(val);
            })
        }
    })
</script>