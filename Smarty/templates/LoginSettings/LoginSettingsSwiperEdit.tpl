<input type="hidden" id="swiperid" value="{$swiperid}"/>
<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
    <tr>
        <td class="ld-form-item-label">{'Carousel'|@getFixedLabel}</td>
        <td class="ld-form-item-content">

            <div name="loginswiper_img_div" style="{if $CONTENT==""}display:none;{/if}">
                <img src="{$CONTENT}" name="loginswiper_img" class="Logo" style="{if $SWIPERRATIO == '1:2'}width: 120px;{else}width:200px;{/if}max-height: 240px;">
            </div>

{*            <div style="display: inherit;">默认背景：[login_bg_001.png]</div>
            <input name="MAX_FILE_SIZE" value="800000" type="hidden">
            <input name="PREV_FILE" value="{$CONTENT}" type="hidden">
            <input name="backgroundbg_hidden" value="{$CONTENT}" type="hidden">
            <input name="loginswiper" value="{$CONTENT}" onchange="validateFilename(this);OrganizationConfig.showLOGO(this,'loginswiper_img')" type="file" style="padding-bottom: 5px;">*}
            <div style="height: 20px;line-height: 20px;">{'Choosepictures'|@getFixedLabel}<span style="color: red;">{if $SWIPERRATIO == '1:2'}{'swipersuggestsmall'|@getFixedLabel}{else}{'swipersuggestbig'|@getFixedLabel}{/if}</span></div>

            <div class="ld-button" name="loginswiperchooseimg"></div>
            <div name="loginswiperchooseimgfilename" style="display: none;">
                <input type="hidden" id="loginswipercontent" value="{$CONTENT}"/>
            </div>
        </td>
    </tr>
    {*<tr>
        <td class="ld-form-item-label">{'LINK'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input name="swiperurl" class="ld-input-inner" type="text" value="{$URL}"/>
        </td>
    </tr>*}
    <tr>
        <td class="ld-form-item-label">{'WHETHERTODISPLAY'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input name="swiperisshow" type="checkbox" {if $ISSHOW == 'yes'}checked{/if} />
        </td>
    </tr>
    </tbody>
</table>