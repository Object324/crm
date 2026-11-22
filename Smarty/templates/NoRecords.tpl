{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

-->*}
<!--修改编码格式:统一编码：UTF-8-->
{if !$NoRecords_CONTENT || $NoRecords_CONTENT eq ''}
    {assign var = NoRecords_CONTENT value = {'NOTFOUNDANYRECORD'|@getFixedLabel}}
{/if}
<div class="warningTableContent" style="z-index:2;padding-top:30px;{if $NoRecords_STYLE && $NoRecords_STYLE neq ''}{$NoRecords_STYLE}{/if}">
    <div class="wtc_img" style="{if $NoRecords_IMGSTYLE && $NoRecords_IMGSTYLE neq ''}{$NoRecords_IMGSTYLE}{/if}">
        <img src="themes/icon2023/ld-no-records.png?v={$GLOBALMINVERSION}">
    </div>
    <div class="wtc_title" style="{if $NoRecords_TITLE eq ''}display:none;{/if}">
        {$NoRecords_TITLE}
    </div>
    <div class="wtc_content">
        {$NoRecords_CONTENT}
    </div>
    <div class="wtc_btn" style="{if $NoRecords_TITLE eq ''}display:none;{/if}">
        {$NoRecords_BUTTON}
    </div>
</div>