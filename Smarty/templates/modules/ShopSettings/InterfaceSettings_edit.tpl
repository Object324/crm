<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="ShopSettings"/>
    <input type="hidden" name="ajax" value="save"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>appId</td>
            <td class="ld-form-item-content">
                <input type="text" name="appid" value="{$APPID}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>appSecret</td>
            <td class="ld-form-item-content">
                <input type="text" name="appsecret" value="{$APPSECRET}" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'BASICSETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MINIPROGRAMNAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="appname" value="{$APPNAME}" class="ld-input-inner">
            </td>
        </tr>
        <tr style="display: none;">
            <td class="ld-form-item-label"><font color="red">*</font>{'EVALUATESETTING04'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="custelno" value="{$CUSTELNO}" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'SHARINGSETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'SHAREDESCRIPTION'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="sharedescription" value="{$SHAREDESCRIPTION}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'SHAREIMAGE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div>
                    <div style="padding-bottom: 10px;">
                    <div class="E_pbtncancel" style="float:left;height:25px;line-height:22px;margin-top:5px;" >
            		  <input type="file" name="sharepicture" accept="image/*"   id="sharepicture" onchange="ShopSettingsSelectpicture(this)" style="opacity:0;position:absolute;margin-left: -10px;width:70px">
                      <label for="upload">{'Select_file'|@getFixedLabel}</label>
                    </div>
                    <span style="margin-top:12px;margin-left: 10px;display: inline-block;">{'SUGGESTEDIMAGESIZE'|@getFixedLabel}</span>
                </div>
                <div name="div_upload_span" style="{if $SHAREPICTURE eq ''}display: none;{else}display: block;{/if}">
                    <div  style="display: inline-block;max-width: 300px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;height:24px;float:left;">
                        <span class="info" id="span_sharepicture" name="span_sharepicture" title="{$SHAREPICTURE}" style="line-height: 24px;padding-left:5px">{$SHAREPICTURE}</span>
                        <input type="hidden" value="{$SHAREPICTURE}"/>    
                    </div>
                    <span class="" style="line-height: 24px;padding-left:5px"><a href="javascript:;" onclick="ShopSettingsdeletepicture('sharepicture')">{'DELETE'|@getFixedLabel}</a></span>
                </div>
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'LBL_OTHER_SETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'WHETHERDISPLAYINVOICE'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="checkbox" name='displayinvoice' tag="1" onclick="" class="second_switch" {if $DISPLAYINVOICE!='no'}checked=""{/if}></td>
        </tr>
    </table>
</form>
</div>