{*editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/15 15:49 *}
<div class="D_pop_box LdPopWidth500px"
     style="position: fixed; z-index: 9999; top: 40%; left: 40%; display: block; margin-top: -147.5px; margin-left: -202px;">
    <div class="D_pop_tit">
        <strong id="createworktpldivtitlename" class="D_ptita">{'WECHATAPPLETHEADER'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:;">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" id="colse_mobile_menu"
                 alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}">
        </a>
    </div>
    <input type="hidden" id="CORPLINK" name="CORPLINK" value="{$CORPLINK}"/>
    <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
        <tr>
            <td colspan="2">
                {'WECHATAPPLETHEADERTITLE01'|@getFixedLabel}
            </td>
        </tr>
        <tr>
            <td style="width:50%;" align="center">
                {'WECHATAPPLETHEADERTITLE02'|@getFixedLabel}
            </td>
            <td align="center">
                {'WECHATAPPLETHEADERTITLE03'|@getFixedLabel}
            </td>
        </tr>
        <tr>
            <td align="center">
                <img width="150" height="150" src="modules/Settings/wechat_miniprogram/001.jpg" alt="">
            </td>
            <td id="qrcode_content" align="center">
            </td>
        </tr>
        <tr>
            <td align="center">
                {'WECHATAPPLETHEADERTITLE04'|@getFixedLabel}
            </td>
            <td align="center">
                {'WECHATAPPLETHEADERTITLE05'|@getFixedLabel}
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
        <input class="D_pbtnok" value="确认" type="button" id="save_mobile_menu">
    </div>
</div>