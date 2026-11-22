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
{*<!-- buttons for the home page -->*}
	<!--修改编码格式:统一编码：UTF-8-->
	<form action="index.php" method="post" name="Saveresults" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="action" value="SaveProfileField">
	<input type="hidden" name="module" value="Users">
	<input type="hidden" name="formodule" value="{$modulename}">
	<input type="hidden" name="tabid" value="{$TABID}">
	<input type="hidden" name="profileid" value="{$PROFILEID}" >
	<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}" >
	<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}" >

	 
    {assign var=entries value=$CFENTRIES}
    <div style="width:100%">
        <div class="ld-description" id="description_area" style="flex-direction: column;max-height: 150px;">
            <div style="display: flex;justify-content: space-between;">
                <b class="info-icon"></b>
                <div class="ld-description-content">
                    <strong style="color:#333;">{'SHARERULE_EXPLAIN'|@getFixedLabel}</strong>
                </div>
                <div class="ld_Select-component" id="showhide_tips" style="background-color: inherit;align-items: initial;">
                    <b class="ld_Select_arrowicon"></b>
                </div>
            </div>
            <div class="ld-description-content" id="tipscontent" style="line-height: 26px;">
                1、{'INVISIBLEEXPLAIN'|@getFixedLabel}<br />
                2、{'READANDWRITEEXPLAIN'|@getFixedLabel}<br />
                3、{'READONLYEXPLAIN'|@getFixedLabel}<br />
                4、{'READANDWRITEDURINGEDITEXPLAIN'|@getFixedLabel}<br />
            </div>
        </div>
        <div class="ld-rolesprofile-search" id="search_area" style="width: 40%;margin: 20px 24px 0px 24px;">
            <span class="leftmenu-fonticon">&#xe623;</span>
            <input class="ld-input-inner" id="search_fieldname" type="text" placeholder="{'SearchFieldname'|@getFixedLabel}" autocomplete="off" style="">
            <b class="ld-icon-clearsearch" id="clear_search_fieldname" style="position: absolute; right: 0px; top: 0px; cursor: pointer; visibility: visible;display: none;"></b>
        </div>
        <div id="EditProfileFieldDiv" class="ld-pop-container ld-table-container ld-table-container-lines">
            <div id="EditProfileFieldScrollDiv" class="ld-rolesprofile-editprofilefield" style="width: 100%; overflow-y: auto;">
                <table id="EditProfileFieldTable" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <thead>
                        <tr>
                            <th style="width:20%;padding-left: 16px;">{'BLOCK'|@getFixedLabel}</th>
                            <th style="width:20%;padding-left: 24px;">{'LBL_FIELDNAME'|@getFixedLabel}</th>
                            <th style="width:58%;text-align: center;">{'LBL_FIELDS_ACCESS'|@getFixedLabel}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr name="selectAll">
                            <td style="padding-left: 16px;">{'ALLSELECT'|@getFixedLabel}</td>
                            <td style="padding-left: 24px;"></td>
                            <td align='center' style="word-break:break-all;padding: 0px 24px;">
                                <label><input type="radio" name="selectAll_input" class="input-btn-align" id="" value="invisible" />&nbsp;{'INVISIBLE'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                <label><input type="radio" name="selectAll_input" class="input-btn-align" id="" value="readandwrite" />&nbsp;{'READANDWRITEPERMISSIONS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                <label><input type="radio" name="selectAll_input" class="input-btn-align" id="" value="readonly" />&nbsp;{'READONLYPERMISSIONS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                <label><input type="radio" name="selectAll_input" class="input-btn-align" id="" value="readonlyduringedit" />&nbsp;{'READONLYPERMISSIONSDURINGEDIT'|@getFixedLabel}</label>
                            </td>
                        </tr>
                        {foreach item=row_values from=$RETURNARR}
                            <tr name="fieldTr" fieldid="{$row_values[1].fieldid}">
                                <td style="padding-left: 16px;">{$row_values[0].blocklabel}</td>
                                <td style="padding-left: 24px;">
                                    {$row_values[1].fieldlabel}
                                </td>
                                <td align='center' style="word-break:break-all;padding: 0px 24px;">
                                    <label><input type="radio" name="{$row_values[2].fldname}"{if $row_values[2].checked eq 'invisible'}checked{/if} {$row_values[2].disabled[0]} id="{$row_values[2].fldname}" class="input-btn-align"  value="invisible" />&nbsp;{'INVISIBLE'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                    <label><input type="radio" name="{$row_values[2].fldname}" {if $row_values[2].checked eq 'readandwrite'}checked{/if} {$row_values[2].disabled[1]} class="input-btn-align" id="{$row_values[2].fldname}"  value="readandwrite" />&nbsp;{'READANDWRITEPERMISSIONS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                    <label><input type="radio" name="{$row_values[2].fldname}" {if $row_values[2].checked eq 'readonly'}checked{/if} {$row_values[2].disabled[2]} class="input-btn-align" id="{$row_values[2].fldname}"  value="readonly" />&nbsp;{'READONLYPERMISSIONS'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                    <label><input type="radio" name="{$row_values[2].fldname}" {if $row_values[2].checked eq 'readonlyduringedit'}checked{/if} {$row_values[2].disabled[3]} class="input-btn-align" id="{$row_values[2].fldname}"  value="readonlyduringedit" />&nbsp;{'READONLYPERMISSIONSDURINGEDIT'|@getFixedLabel}</label>
                                    <input type="hidden" name="{$row_values[1].fieldname}" id="{$row_values[1].fieldid}" tag="tabid_field" value="{$row_values[2].checked}" />
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</form>
