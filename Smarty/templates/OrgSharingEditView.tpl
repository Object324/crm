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
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<div class="ld-description">
    <b class="info-icon"></b>
    <div class="ld-description-content">{'AFTERMAKINGMODIFIPRESS'|@getFixedLabel}</div>
</div>
<div class="ld-pop-container ld-table-container ld-table-container-nobg ld-table-container-lines">
    <div class="divPopOverflow">
        <form action="index.php" method="post" name="def_org_share" id="form" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
            <input type="hidden" name="module" value="Users">
            <input type="hidden" name="action" value="SaveOrgSharing">
            <input type="hidden" name="parenttab" value="Settings">
            <input type="hidden" name="allmodulelabel" value="{{$ALLMODULELABEL}}"/>
            <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th width="5%">#</th>
                        <th width="30%" title="{'MODULE'|@getFixedLabel}">{'MODULE'|@getFixedLabel}</th>
                        <th width="20%" title="{'LBL_SHARING_ACCESS'|@getFixedLabel}">{'LBL_SHARING_ACCESS'|@getFixedLabel}</th>
                        <th title="{'CUSTOMRULES'|@getFixedLabel}">{'CUSTOMRULES'|@getFixedLabel}</th>
                    </tr>
                </thead>
                <tbody>
                    {assign var="i" value=0}
                    {assign var="modulenum" value='0'}
                    {assign var="modulenamenum" value='1'}
                    {foreach item=elements from=$ORGINFO}
                        {assign var="MODULELABEL" value=$elements.0}
                        {if $elements.0|@getTranslatedString:$elements.0 neq ''}
                            {assign var="MODULELABEL" value=$elements.0}
                            {assign var="modulenum" value=$modulenum+1}
                        {/if}
                        {assign var="j" value=$i++}
                        <tr id="setting_{$j}">
                            <td>{$modulenamenum}</td>
                            <td>{$MODULELABEL}</td>
                            <td>{$elements.2}</td>
                            <td width="50%" nowrap><b name="showCustomrules_btn" style="cursor: pointer;margin-left: 10px;" module="{$elements.1}" onclick="OrgSharingDetailView.showCustomrules(this)" stauts="hide"  data-tip="{'EXPANSION'|@getFixedLabel}" data-direction='top' data-type='position' class='ld-category-icon ld-category-expansion sort-tip-items'></b></td>
                        </tr>
                        {assign var="modulenamenum" value=$modulenamenum+1}
                    {/foreach}
                </tbody>
            </table>
        </form>
    </div>
</div>
<script>
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    {/literal}
</script>