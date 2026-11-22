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
{*create zhouxiaomei 2020-9-23 公司信息增加公司产品简介弹窗模板*}
<style>
    .delete-button{
        position: absolute;
        right: 20px;
        bottom: 20px;
        color:orangered;
        cursor: pointer;
    }
</style>
<div id="editContent" style="max-height: 500px;overflow-y: scroll;">
<form action="index.php?module=Settings&action=add2db" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
    <input type="hidden" name="return_module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="return_action" value="OrganizationConfig"/>
    <input type="hidden" name="title_name" value="{'MAILNAME'|@getFixedLabel}"/>
    <input type="hidden" name="image_name" value="{'IMAGELINK'|@getFixedLabel}"/>
    <input type="hidden" name="brief_name" value="{'BRIEF'|@getFixedLabel}"/>
    <input type="hidden" name="organization_id" value="{$organization_id}"/>
    {if $product}
        <input type="hidden" name="id" value="{$product['id']}"/>
    {else}
        <input type="hidden" name="id" value="0"/>
    {/if}
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MAILNAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" name="title" class="ld-input-inner" value="{$product['title']}"/></td>
        </tr>
        {*图片一条*}
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'IMAGELINK'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="image_link" class="ld-input-inner" value="{$product['image_link']}"/>
            </td>
        </tr>
    </table>
    <div class="ld-pop-container ld-table-container ld-table-container-lines ld-table-container-bgcolor padT0">
        <table border=0 cellspacing=0 cellpadding=0 width=100% >
            <thead>
                <th width="5%">#</th>
                <th width="85%">{'BRIEF'|@getFixedLabel}{'MAXNUMBERFIVE'|@getFixedLabel}</th>
                <th width="10%">{'OPERATING'|@getFixedLabel}</th>
            </thead>
            <tbody>
                {if $product && $product['brief']}
                    {foreach from=$product['brief'] item=$brief_one key=$key}
                        <tr id="tr_{$key}" name="brief">
                            <td name="td_one">{$key + 1}</td>
                            <td name="td_brief" style="cursor: pointer;">
                                <div style="padding: 10px"">
                                    <div name="brief[]" style="line-height: 24px; font-size: 13px;padding: 0 8px;" class="brief_class">{$brief_one}</div>
                                    <textarea class="ld-textarea-inner" style="display: none;" name="brief[]">{$brief_one}</textarea>
                                </div>
                            </td>
                            <td class="sort_td">
                                <div class="displayflex flexcenter">
                                    <a class="tip-items-list" href="javascript:void(0);" tag="delete" brief_id="{$key}" onclick="OrganizationConfig.deleteabrief(this);" style="white-space:nowrap;margin-left:8px;" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position">
                                        <i class="ld-fonticon ld-fonticon-del"></i>
                                    </a>
                                    <a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;" data-tip="{'drag'|@getFixedLabel}" data-direction="right" data-type="position"></a>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                {else}
                <tr id="tr_0" name="brief">
                    <td name="td_one">1</td>
                    <td name="td_brief" style="cursor: pointer;">
                        <div style="padding: 10px"">
                            <div name="brief[]" style="line-height: 24px; font-size: 13px;padding: 0 8px;" class="brief_class" edit="yes"></div>
                            <textarea class="ld-textarea-inner" style="display: none;" name="brief[]"></textarea>
                        </div>
                    </td>
                    <td class="sort_td">
                        <div class="displayflex flexcenter">
                            <a class="tip-items-list" href="javascript:void(0);" tag="delete" brief_id="0" onclick="OrganizationConfig.deleteabrief(this);" style="white-space:nowrap;margin-left:8px;display:none;" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position">
                                <i class="ld-fonticon ld-fonticon-del"></i>
                            </a>
                            <a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;" data-tip="{'drag'|@getFixedLabel}" data-direction="right" data-type="position"></a>
                        </div>
                    </td>
                </tr>
                {/if}
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