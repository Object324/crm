<!--************************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
{if $FOLDERS}
<div class="EmailOneMenu">
    <div class="div1">{'MAILFOLDER'|@getFixedLabel}</div>
    <div class="div2">
    <ul>
    {foreach item=FOLDER from=$FOLDERS}
        <li>
        <span class="icon-homeimg icon-emial02"></span>&nbsp;
        <a id='_mailfolder_{$FOLDER->name()|@htmlentities}' href='#{$FOLDER->name()|@htmlentities}' onclick="MailManager.clearSearchString(); MailManager.folder_open('{$FOLDER->name()|@htmlentities}'); ">
            {if $FOLDER->unreadCount()} 
                {$FOLDER->name()|@getFixedLabel} ({$FOLDER->unreadCount()}) 
            {else}
                {$FOLDER->name()|@getFixedLabel}
            {/if}
        </a>
        </li>
    {/foreach}
    </ul>
    </div>
</div>
{/if}