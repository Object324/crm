<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/SelfServiceConfig.js"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" id="selftype" value="{$SELFTYPE}"/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<input type="hidden" name="platform" value="{$PlatForm}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {$CUSTOMERSELFSERVICECONFIG01}{if $HelpHtml.SelfServiceConfigHome neq '' }{$HelpHtml.SelfServiceConfigHome}{/if}
        </span>
        {if $MINIPROGRAM_SETTING eq ''}
            <span class="grid-view-choose dinline-block redFont">
                {'CUSTOMERSELFSERVICECONFIGHOME01'|@getFixedLabel}
            </span>
        {/if}
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="setsubmit" href="javascript:;" class="ld-button ld-button-primary" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{$CUSTOMERSELFSERVICECONFIG01}</th>
                </tr>
                <tr id="setting_switchtype" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'CUSTOMERSELFSERVICECONFIGHOME02'|@getFixedLabel}
                    </td>
                    <td width="80%">
                        <select class="ld-select-inner gwidth30" id="weixinmp_switchtype" onchange="SelfServiceConfig.bindtype()">
                            {foreach item=item key=key from=$MPBINDTYPEARR}
                                <option value="{$item.value}" {$item.selected}>{$item.label}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr id="setting_bindtype" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'AppAccountBindObj'|@getFixedLabel}
                    </td>
                    <td width="80%">
                        <select class="ld-select-inner gwidth30" id="weixinmp_bindtype" onchange="SelfServiceConfig.bindtype()">
                            {foreach item=item key=key from=$BINDTYPEARR}
                                <option value="{$item.value}" {$item.selected}>{$item.label}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr id="phonefield_div" class="lvtColData" style="display:{if $SWITCHTYPE neq 'Login'}none;{/if}" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td>
                        {'CUSTOMERSELFSERVICECONFIGHOME05'|@getFixedLabel}
                    </td>
                    <td>
                        <select class="ld-select-inner gwidth30" id="weixinmp_bindtype_phonefield">
                            {foreach item=item key=key from=$MPBINDTYPEPHONEFIELD[0]}
                                <option value="{$item.value}" fieldfrom="{$BINDTYPEFIELDFROM[0]}" {$item.selected}>{$BINDTYPEFIELD[0]}-{$item.label}</option>
                            {/foreach}
                            {foreach item=item key=key from=$MPBINDTYPEPHONEFIELD[1]}
                                <option value="{$item.value}" fieldfrom="{$BINDTYPEFIELDFROM[1]}" {$item.selected}>{$BINDTYPEFIELD[1]}-{$item.label}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr id="setting_allowcreate" class="lvtColDataBj" style="display:{if $SWITCHTYPE neq 'Login'}none;{/if}" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" id="allowcreatenew">{'WhetherAllowToCreateNew'|@getFixedLabel}{if $BINDTYPE eq 'Accounts'}{'Accounts'|@getTranstab}{else}{'Contacts'|@getTranstab}{/if}
                        
                    </td>
                    <td width="80%">
                        <input class="second_switch" type="checkbox" {if $ALLOWEDTOCREATE eq 'yes'}checked{/if}>
                    </td>
                </tr>
                <tr id="setting_usecode" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" id="useverificationcode">
                        {if $SWITCHTYPE eq 'Login'}{'LBL_TO_LOGIN'|@getFixedLabel}{'WhetherToUseCode'|@getFixedLabel}
                        {else}{'CELLREGISTER'|@getFixedLabel}{'WhetherToUseCode'|@getFixedLabel}{/if}
                    </td>
                    <td width="80%">
                        <input class="second_switch" type="checkbox" name="setting_usecode_checked" {if $USECODE eq 'yes'}checked{/if}>
                    </td>
                </tr>

                {if $PlatForm eq 'aliyun'}
                <tr id="setting_smstemplatelist" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" style="display: {if $USECODE neq 'yes'}none{/if};">
                    <td class="ld-form-item-label">{'SELECT'|@getFixedLabel}{'SMS_templates'|@getFixedLabel}</td>
                    <td class="ld-form-item-content">
                        <select name="smstemplatelist" class="ld-select-inner">
                            {foreach item=item from=$SmsTemplateList}
                                <option value="{$item.templateid}" {if isset($SmsRelatedArr.template_id) && $item.templateid eq $SmsRelatedArr.template_id}selected{/if}>{$item.templatename}</option>
                            {/foreach}
                        </select>

                    </td>
                </tr>
                {/if}

{*                XUQIU20240725-02 服务小程序登录页设置--增加首页横幅图片设置 wsh 20240807*}
                <tr id="setting_image" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">
                        {'HomepageBannerImageSetting'|@getFixedLabel}
                    </td>
                    <td width="80%">
                        <div style="width: 145px;height:40px;padding-top: 6px;display: inherit;font-size: 13px">
                            <input name="MAX_FILE_SIZE" value="800000" type="HIDDEN">
                            <input name="PREV_FILE" value="{$BANNERIMAGEURL}" type="HIDDEN">
                            <input name="banner_url_hidden" value="{$BANNERIMAGEURL}" type="hidden">
                            <img src="{$BANNERIMAGEURL}" name="banner_img_url" class="Logo" style="width: 130px;height: 36px;margin-top: -4px;{if {$BANNERIMAGEURL} eq ''}display: none;{/if}">
                            <div style="height: 20px;line-height: 20px;width: max-content;margin-left: 140px;margin-top: {if {$BANNERIMAGEURL} eq ''}-9px;{else}-40px{/if};">
                                {'ChooseNewBackground'|@getFixedLabel}：<span style="color: red;">{'RecommendedSizeRatioBanner'|@getFixedLabel}</span>
                                <input name="banner_img" value="{$BANNERIMAGEURL}" type="file" accept="image/*" onchange="show_banner_img(this)" style="padding-bottom: 5px;">
                            </div>
                        </div>
                    </td>
                </tr>
            </table>
            {*editor:gyq_20200303 reason:小程序参数没有设置时，不显示服务订单小程序码显示栏*}
            {if $MINIPROGRAM_SETTING neq ''}
                <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <th colspan="2">{$CUSTOMERSELFSERVICECONFIGHOME06}<span class="fontnormal">({$CUSTOMERSELFSERVICECONFIGHOME07})</span></th>
                    </tr>
                    <tr id="setting_2" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td width="20%">
                            {$CUSTOMERSELFSERVICECONFIGHOME08}
                        </td>
                        <td width="80%">
                            <img src="{$QRCODEIMAGE}" alt="wechat_miniprogram.jpg" class="padTB10" width="120">
                        </td>
                    </tr>
                    <!--wyt_220719_XUQIU1000433_增加“服务小程序绑定微信公众号密钥”参数-->
                    {*zxm 20220822 id=setting_3冲突  改成12*}
                    <tr id="setting_miniprogramsecret" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td width="20%">
                            {$CUSTOMERSELFSERVICECONFIGHOME09|@getFixedLabel}
                        </td>
                        <td width="80%">{$WECHAT_KEYS_OUT}</td>
                    </tr>
                </table>
            {/if}
        </div>
    </div>
</div>
</form>
<div id="selfconfig_create" style="display:none;width:450px;">
    <div id="selfconfig_create_div"></div>
</div>
<div id="selfconfig_module" style="display:none;width:450px;">
    <div id="selfconfig_module_div"></div>
</div>