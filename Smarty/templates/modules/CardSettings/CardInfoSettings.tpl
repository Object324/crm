
{*<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">*}
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            名片信息设置
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="pg-btn-blue dinline-block lfloat" onclick="CardSettingsobj.CardInfoEdit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <div class="TitleHeading">
                卡片基本信息设置
            </div>
            <table class=" singleList" width="100%" border="0" cellspacing="0" cellpadding="5"
                   style="color:#555;">
                <tr style="height:85px;">
                    <td width="20%" class="cellLabel"> 名片默认背景 </td>
                    <td width="80%" class="cellLabel" align="left">
                        <img style="width:120px;height:80px;" src="{if $CardInfo.background neq ''}{$IMAGE_PATH}{$CardInfo.background}{else}https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob827/backgroung_card.jpg{/if}" border="0">
            		</td>
                </tr>
                <tr style="height:85px;">
                    <td class="cellLabel"> 名片默认头像 </td>
                    <td class="cellLabel" align="left">
                        <img style="width:120px;height:80px;" src="{if $CardInfo.avatar neq ''}{$IMAGE_PATH}{$CardInfo.avatar}{else}themes/images/defaultuser.png{/if}" border="0">
            		</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示职称 </td>
                    <td class="borderBR">{if $CardInfo.display_level eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示公司名称 </td>
                    <td class="borderBR">{if $CardInfo.display_company_name eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示个人手机 </td>
                    <td width="50%" class="borderBR">{if $CardInfo.display_phone_mobile eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示个人邮箱 </td>
                    <td width="50%" class="borderBR">{if $CardInfo.display_email eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示公司电话 </td>
                    <td class="borderBR">{if $CardInfo.display_company_phone eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
                <tr>
                    <td class="cellLabel"> 是否显示公司地址 </td>
                    <td class="borderBR">{if $CardInfo.display_company_address eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
            </table>
        </div>
    </div>
</div>
{*</form>*}