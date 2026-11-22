{*<!--
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 
-->*}<!--修改编码格式:统一编码：UTF-8-->
<div class="ld-description">
    <b class="info-icon"></b>
    <div class="ld-description-content">
        {'DEPENCYSELECTNEXTPREVFIELD'|@getFixedLabel}
    </div>
</div>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div id="pickListContents" class="ld-pop-container">
    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="50%">
                {'SOURCEFIELD'|@getFixedLabel}
                <select onchange="changeModuleFieldOption()" name="sourcefield" id="sourcefield" class="ld-select-inner width180 marL10" {if $PICKLISTMODE eq 'edit'} disabled style="background:#ECE9D8;"{/if}>
                    {foreach key=fld_nam item=fld_lbl from=$ALL_LISTS}
                        <option value="{$fld_nam}"  {if $fld_nam eq $SOURCEFIELD} selected {/if}>
                            {$fld_lbl}
                        </option>
                    {/foreach}
                </select>
            </td>
            <td width="50%">
                {'TARGETFIELD'|@getFixedLabel}
                <select name="targetfield" id="targetfield" class="ld-select-inner width180 marL10" {if $PICKLISTMODE eq 'edit'}  disabled style="background:#ECE9D8;"{/if}>
                    {foreach key=fld_nam item=fld_lbl from=$ALL_LISTS}
                        <option value="{$fld_nam}"  {if $fld_nam eq $TARGETFIELD} selected {/if}>
                            {$fld_lbl}
                        </option>
                    {/foreach}
                </select>
            </td>       
        </tr>
    </table>
</div> 