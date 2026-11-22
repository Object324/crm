{* gyq_11  editor:gyq_69 reason:帮我吧呼叫中心 2018/6/4 20:57  *}
<embed id="embed" height="45 " width="598 " src="" style="display: none"/>
<div id="audioCon" style="display: none">
    <audio id="audio" src="">
        您的浏览器不支持audio元素
    </audio>{*D:\wamp\www\ldcrm\Smarty\templates\Playforrecord.tpl*}
    <div style="width:600px">
        <div id="buttonDiv" style="width: 600px;">
            <div id="divLeft" style="width: 600px;">
                <progress id="playPercent" max="100" style="width: 580px;height: 20px;"></progress>
            </div>
            <div id="divRight" style="width: 600px;"><span id="showTime"></span></div>
            <div class="D_pbtn">
                <input type="button" class="D_pbtnok" value="播放" id="btnPlay"
                       onclick="btnPlay_onclick()"><span>&nbsp;</span>
                {* <input type="button" class="D_pbtncancel" value="后退" id="btnBackPlay" onclick="btnBackPlay_click()" disabled="">
                 <input type="button" class="D_pbtncancel" value="前进" id="btnForwardPlay" onclick="btnForwardPlay_click()" disabled="">*}
                <input type="button" class="D_pbtncancel" value="重新开始" id="btnRestart" onclick="btnRestart_click()"
                       disabled="">
                <input type="button" class="D_pbtncancel" value="静音" id="btnMute" onclick="setMute()" disabled="">
                <input type="button" class="D_pbtncancel" value="增大音量" id="btnVolumeUp" onclick="VolumeUp()"
                       disabled="">
                <input type="button" class="D_pbtncancel" value="降低音量" id="btnVolumeDown" onclick="VolumeDown()"
                       disabled="">
            </div>
        </div>
    </div>
</div>

