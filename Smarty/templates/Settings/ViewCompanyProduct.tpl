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
{*create zhouxiaomei 2020-9-23 公司信息增加查看公司产品简介弹窗模板*}
<style>
    .th-title{
        background-color: #F3F3F3;
    }
</style>
<div style="max-height: 500px;overflow-y: auto;">
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <input type="hidden" id="organization_id" name="organization_id" value="{$organization_id}">
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MAILTITLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" id="product_title" name="product_title" class="ld-input-inner" value="{$product_title}"/></td>
        </tr>
    </table>
    <div class="ld-pop-container ld-table-container ld-table-container-lines ld-table-container-bgcolor padT0">
        <table id="have_border_table" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
                <th width="10%">{'MAILNAME'|@getFixedLabel}</th>
                <th width="20%">{'IMAGELINK'|@getFixedLabel}</th>
                <th width="50%">{'BRIEF'|@getFixedLabel}</th>
                <th width="15%">{'ACTIVITYOPERATION'|@getFixedLabel}</th>
            </thead>
            <tbody>
                {if $brief_arr|@count gt 0}
                {foreach item=$brief from=$brief_arr}
                <tr id="{$brief['id']}">
                    <td>{$brief['title']}</td>
                    <td><img style="width:50%" src="{$brief['image_link']}"/></td>
                    <td>
                        <ul style="line-height: 24px;">
                            {if $brief['brief']}
                            {foreach from=$brief['brief'] item=$brief_one }
                            <li>{$brief_one}</li>
                            {/foreach}
                            {/if}
                        </ul>
                    </td>
                    <td>
                        <div class="displayflex flexcenter">
                            <a class="tip-items-list" href="javascript:void(0);" tag="edit" onclick="OrganizationConfig.productedit({$brief['id']})" style="white-space:nowrap;margin-left:8px;" data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position">
                                <i class="ld-fonticon ld-fonticon-edit"></i>
                            </a>
                            <a class="tip-items-list" href="javascript:void(0);" tag="delete" onclick="OrganizationConfig.productdel({$brief['id']},this)" style="white-space:nowrap;margin-left:8px;" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position">
                                <i class="ld-fonticon ld-fonticon-del"></i>
                            </a>
                            <a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;" data-tip="{'drag'|@getFixedLabel}" data-direction="right" data-type="position"></a>
                        </div>
                    </td>
                </tr>
                {/foreach}
                {else}
                <tr>
                    <div class="home_nomsg_div">
                        <div>
                            <img class="icon-empty" alt="{'NOTFOUNDANYRECORD'|@getFixedLabel}" src="themes/images/emptyinfo.png"/>
                            <span>{'NOTFOUNDANYRECORD'|@getFixedLabel}</span>
                        </div>
                    </div>
                </tr>
                {/if}
            </tbody>
        </table>
        <div class="padT16">
            <div class="ld-btn-icontext-item" onclick="OrganizationConfig.productedit(0)">
                <i class="ld-fonticon ld-fonticon-addhover"></i><span class="blueFont">{'ADDBRIEF'|@getFixedLabel}</span>
            </div>
        </div>
    </div>
</div>
