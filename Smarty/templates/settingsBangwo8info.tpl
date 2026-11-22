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
<form  name="savetrackpostionform" >  
<input type="hidden" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" id="fieldidsetting" value="{$FIELDIDSETTING}"/>
<input type="hidden" id="supportname" name="supportname" value="{$SUPPORTNAME}"/>
<input id="selectallocatetype_default"  type="hidden" value="{$ALLOCATETYPE}">
<input id="bangwo8supportnameid" name="bangwo8supportnameid"  type="hidden" value="{$BANGWO8SUPPORTNAMEID}">
<input id="selectallocateid_default"  type="hidden" value="{$USERIDS}" >
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>           
          <td align="left" width="60%">{'BANGWO8CUSTOMERSERVICEACCOUNT'|@getFixedLabel}</td>
          <td width="40%">{$SUPPORTNAME}</td>
      </tr>
      <tr>
         <td align="left">{'ADDOREDITRECORDSYSTEMOPERATE'|@getFixedLabel}</td>
         <td>
			<select id="operate_smownerid" class="commonSelectPop" style="width:100px;">
				{foreach name=info_name item=infos from =$USERINFO}
					<option value="{$infos.id}" {if $OPERATESMOWNERID eq $infos.id }selected="true"{/if}>{$infos.last_name}</option>
                {/foreach}
			</select>
        </td>
      </tr>
      <tr>
		<td align="left">{'SYSTEMSCOPECLIENTSANDCONTACTS'|@getFixedLabel}</td>
		<td id="allocate_divcontent" class="select-input"></td>
	  </tr>
    </table>
</form>