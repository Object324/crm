    {*+**********************************************************************************
     * The contents of this file are subject to the lingdang CRM Public License Version 1.0
     * ("License"); You may not use this file except in compliance with the License
     * The Original Code is:  lingdang CRM Open Source
     * The Initial Developer of the Original Code is lingdang.
     * Portions created by lingdang are Copyright (C) lingdang.
     * All Rights Reserved.
     ***********************************************************************************
     *}
    <!--修改编码格式:统一编码：UTF-8-->
    {if $MODULE neq 'ModComments'}
        {if empty($smarty.request.ajax) && 'ModComments'|@vtlib_isModuleActive == true}
        {if $COMMENTS[0] eq ""}
            {assign var='arrawcls' value=''}
        {else}
            {assign var='arrawcls' value='On'}
        {/if}
        <div class="DivCName DivCNamehover">
            <label class="cursorPointer" style='display:inline-block; width:80%' onclick="showHideStatus('tbl{$UIKEY}','aid{$UIKEY}');">
                <span class="{$arrawcls}" id="aid{$UIKEY}" name="aid{$UIKEY}"></span>{'COMMENT'|@getFixedLabel}
                {if $MODCOMMENTDISPLAYRIGHT neq 'yes'}
                <a class="tip-items-list" data-commentmode="concise" onclick="changeMode(this)" id="commentMode" data-tip="{'ADVANCEDMODE'|@getFixedLabel}" data-direction ="top" data-type="position"><img src="themes/softed/images/commentmode0.png" style="margin-bottom: 2px; margin-left: 5px;"></a>
                {/if}
            </label>
            <label  style="float: right;">
                <img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border=0 id="indicator{$UIKEY}" style="display:none;">
                {'DISPLAY'|@getFixedLabel} <select style="width:auto;" class="commonDetailedTextBox small" onchange="ModCommentsCommon.reloadContentWithFiltering('{$WIDGET_NAME}', '{$ID}', this.value, 'contentwrap_{$UIKEY}', 'indicator{$UIKEY}');"> //更改传参,tbl{$UIKEY}->contentwrap_{$UIKEY},保留发布框
                    <option value="All" {if $CRITERIA eq 'All'}selected{/if}>{'ALL'|@getFixedLabel}</option>
                    <option value="Last5" {if $CRITERIA eq 'Last5'}selected{/if}>{'TOP5'|@getFixedLabel}</option>
                    <option value="Mine" {if $CRITERIA eq 'Mine'}selected{/if}>{'MINEADD'|@getFixedLabel}</option>
                </select>&nbsp;&nbsp;
            </label>
        </div>

        {/if}
        <div class="DivCNotice DivCNoticeBor" style="display: block;" name="tbl{$UIKEY}" id="tbl{$UIKEY}">
            <div class="Pldiv">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td class="L" colspan="2" style="position: relative;">
                            <div class="textarea-container">
                                <textarea id="create_comment_{$UIKEY}" class="detailedViewTextBox" onFocus="this.className='commonDetailedTextBox bgcolordh'" onBlur="this.className='detailedViewTextBox'" cols="90" rows="2" style="border: none; overflow-y: auto; width: 100%;"></textarea>
                            </div>
                            <div style="position: absolute;right: 50px;bottom: 15px;">
                                <a href="javascript:void(0);" onclick="ModCommentsCommon.addComment('{$UIKEY}', '{$ID}');" class=" modCommentsCommon_save">{'PUBLISH'|@getFixedLabel}</a>
                                <!--
                                <a href="javascript:void(0);" onclick="$('txtbox_{$UIKEY}').value='';"  class=" modCommentsCommon_clear">{'CLEAR'|@getFixedLabel}</a>
                            -->
                            </div>
                        </td>
                    </tr>
                </table>
                <table  class="small" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr style="height: 25px;">
                        <td colspan="4" align="left" class="Note">
                        <div id="contentwrap_{$UIKEY}" style="overflow: auto; max-height: 400px; width: 100%;">
                            {$MODCOMMENTOBJ}
                        </div>
                        </td>
                    </tr>
                </table>

                
            </div>
        </div>
    {/if}
       