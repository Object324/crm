<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<form action="index.php" method="post" id="CardInfoEdit" name="CardInfoEdit">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="right">名片默认背景</td>
            <td align="left">
                {*<div style="width: 145px;">
                    <img src="{if $CardInfo.background neq ''}{$IMAGE_PATH}{$CardInfo.background}{else}https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob827/backgroung_card.jpg{/if}" style="width: 130px;">
                </div>*}
                <div>
                <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                    <input type="file" name="background" accept="image/*" id="background" onchange="CardSettingsobj.validateFilename(this)">
                </a>
                <span class="info" name="span_background" style="padding-left:5px;">{$CardInfo.background}</span>
                </div>
            </td>
        </tr>
        <tr>
            <td align="right">名片默认头像</td>
            <td align="left">
                {*<div style="width: 145px;">
                    <img src="{if $CardInfo.avatar neq ''}{$IMAGE_PATH}{$CardInfo.avatar}{else}themes/images/defaultuser.png{/if}" style="width: 130px;">
                </div>*}
                <a href="javascript:;" class="uploadfile" style="display:inline;">{'Select_file'|@getFixedLabel}
                    <input type="file" name="avatar" accept="image/*" id="avatar" onchange="CardSettingsobj.validateFilename(this)">
                </a>
                <span class="info" name="span_avatar" style="padding-left:5px">{$CardInfo.avatar}</span>
            </td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_level" type="checkbox" {if $CardInfo.display_level eq 'yes'}checked{/if} />
            </td>
            <td>是否显示职称</td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_company_name" type="checkbox" {if $CardInfo.display_company_name eq 'yes'}checked{/if} />
            </td>
            <td>是否显示公司名称</td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_phone_mobile" type="checkbox" {if $CardInfo.display_phone_mobile eq 'yes'}checked{/if} />
            </td>
            <td>是否显示个人手机</td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_email" type="checkbox" {if $CardInfo.display_email eq 'yes'}checked{/if} />
            </td>
            <td>是否显示个人邮箱</td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_company_phone" type="checkbox" {if $CardInfo.display_company_phone eq 'yes'}checked{/if} />
            </td>
            <td>是否显示公司电话</td>
        </tr>
        <tr height="37">
            <td width="45" align="right">
                <input name="display_company_address" type="checkbox" {if $CardInfo.display_company_address eq 'yes'}checked{/if} />
            </td>
            <td>是否显示公司地址</td>
        </tr>
    </table>
</form>