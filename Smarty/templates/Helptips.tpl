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

{if $helptips neq ''}
    <i data-tip="{$helptips}" class="ld-fonticon ld-fonticon-help" style="vertical-align: middle;line-height: 0;"
    {if $MODULE eq 'Products'&& $keyfldname eq 'qtyinstock'}
        onclick="getLinksUrl('Module','Module','module_products');"
    {/if}
    onmouseenter="tooltip.bind(this)"
    ></i>
{elseif $uitype eq 69 || $uitype eq 1108 || $uitype eq 1109 || $uitype eq 28}
    <i data-tip="{$helptips}" class="ld-fonticon ld-fonticon-help" style="vertical-align: middle;line-height: 0;" tag="attachmentHelp_{$uitype}" onmouseenter="tooltip.bind(this)"></i>
{/if}