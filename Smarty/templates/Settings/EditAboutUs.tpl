{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
{*create zhouxiaomei 2020-9-23 公司信息增加公司简介弹窗模板*}
<style>
    .delete-button{
        position: absolute;
        right: 20px;
        bottom: 20px;
        color:orangered;
        cursor: pointer;
    }
</style>
<div id="editContent" style="max-height: 500px;overflow-y: auto;">
<form action="index.php?module=Settings&action=SaveCompanyBrief" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
    <input type="hidden" name="return_module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="return_action" value="OrganizationConfig"/>
    <input type="hidden" name="title_name" value="{'MAILTITLE'|@getFixedLabel}"/>
    <input type="hidden" name="brief_name" value="{'BRIEF'|@getFixedLabel}"/>
    <input type="hidden" name="organization_id" value="{$organization_id}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MAILTITLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" name="brief_title" class="ld-input-inner" value="{$brief_title}"/></td>
        </tr>
        <tr style="display:none;">
            <td class="ld-form-item-label">{'MAINMAPLINK'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" name="image_main" class="ld-input-inner" value="{$image_main}"/></td>
        </tr>
        <tr style="display:none;">
            <td class="ld-form-item-label">{'VIDEOCOVER'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" name="video_cover" class="ld-input-inner" value="{$video_cover}"/></td>
        </tr>
        <tr style="display:none;">
            <td class="ld-form-item-label">{'VIDEOLINK'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" name="video_link" class="ld-input-inner" value="{$video_link}"/></td>
        </tr>
        {*图片多条*}
        <tr style="display:none;">
            <td class="ld-form-item-label">{'IMAGELINK'|@getFixedLabel}</td>
            <td class="ld-form-item-content">{'MAXNUMBERFIVE'|@getFixedLabel}</td>
        </tr>
        {if $brief_image|@count gt 0}
        {foreach from=$brief_image item=$image_one }
        <tr style="display:none;">
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content">
                <input type="text" name="image_link[]" class="ld-input-inner" value="{$image_one['image_link']}"/>
                <div class="delete-button" onclick="OrganizationConfig.deleteaimagelink(this)">{'DELETE'|@getFixedLabel}</div>
            </td>
        </tr>
        {/foreach}
        {/if}
        <tr style="display:none;">
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content">
                <div class="ld-button ld-button-primary" onclick="OrganizationConfig.addaimagelink(this)">{'ADD'|@getFixedLabel}</div>
            </td>
        </tr>
    </table>
    <div class="ld-pop-container ld-table-container ld-table-container-lines ld-table-container-bgcolor padT0">
        <table border=0 cellspacing=0 cellpadding=0 width=100%>
            <thead>
            <th width="5%">#</th>
            <th width="85%">{'BRIEF'|@getFixedLabel}{'MAXNUMBERFIVE'|@getFixedLabel}</th>
            <th width="10%">{'OPERATING'|@getFixedLabel}</th>
            </thead>
            <tbody>
            {foreach from=$brief_res item=$one key=$key}
                <tr id="tr_{$key}" name="brief">
                    <td name="td_one">{$key + 1}</td>
                    <td name="td_brief" style="cursor: pointer;">
                        <div style="padding: 10px">
                            <div style="line-height: 24px; font-size: 13px;padding: 0 8px;" class="brief_class"
                                 name="brief[]">{$one['brief']}</div> {*style="line-height: 24px; font-size: 13px;padding: 0 8px;"*}
                            <textarea class="ld-textarea-inner" style="display: none;"
                                      name="brief[]">{$one['brief']}</textarea>
                        </div>
                    </td>
                    <td class="sort_td">
                        <div class="displayflex flexcenter">
                            <a class="tip-items-list" href="javascript:void(0);" tag="delete" brief_id="{$key}"
                               onclick="OrganizationConfig.deleteabrief(this);"
                               style="white-space:nowrap;margin-left:8px;" data-tip="{'DELETE'|@getFixedLabel}"
                               data-direction="top" data-type="position">
                                <i class="ld-fonticon ld-fonticon-del"></i>
                            </a>
                            <a class="ld-category-icon ld-category-drag drag-handle tip-items-list"
                               style="cursor: move;" data-tip="{'drag'|@getFixedLabel}" data-direction="right"
                               data-type="position"></a>
                        </div>
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
        <div class="padT16">
            <div {if $brief_count eq 5}style="display:none;"{/if} class="ld-btn-icontext-item" tag="create" onclick="OrganizationConfig.addabrief(this)">
                <i class="ld-fonticon ld-fonticon-addhover"></i><span class="blueFont">{'ADDBRIEF'|@getFixedLabel}</span>
            </div>
        </div>
    </div>
</form>
</div>
