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
		<input type="hidden" name="action" value="LayoutBlockList">
		<input type="hidden" name="module" value="Settings">
        <input type="hidden" name="formodule" value="{$modulename}">
        <input type="hidden" name="tabid" value="{$tabid}">
        <input type="hidden" name="sub_mode" value="SetRelatedlistsSave">
	
        <div class="D_pop_tit">
        	<strong class="D_ptita">{'SELECTOFPERSONNEL'|@getFixedLabel}</strong>
            <a href="javascript:fninvshnew('recipient_namediv');" class="D_ptitc">
                <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
            </a>
        </div>
		<table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0">
            <tr>
        		<td>
        			<b>{'AVAILABLEPERSONNEL'|@getFixedLabel}</b>
                    <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
        			<select style="overflow:auto; height: 180px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
                        {foreach item=related_module key=related_moduleid from=$USER_ARR name=relinfo}                                                          
                            <option value="{$related_moduleid}">
                            {$related_module}
                            </option>                                                                                                                     
                        {/foreach}
                    </select> 
                   
        		</td>
        		<td width="60" align="left">
        			<a class="icon-homearr icon-mright" href="javascript:;" onclick="selectOptions('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
        			<br />
                    <a class="icon-homearr icon-mleft" href="javascript:;" onclick="selectOptions('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
        		</td>
        		<td>
        			<b>{'SELECTEDPERSONNEL'|@getFixedLabel}</b>
                    <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
        			<select size="11" style="overflow:auto; height: 180px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">                                                               
 			            {foreach item=item key=itemid from=$BECHOSEDUSER name=relinfo}                                                          
                            <option value="{$itemid}">
                            {$item}
                            </option>                                                                                                                     
                        {/foreach}
                    </select>
        		</td>
            </tr>                      
        </table>
        <div class="D_pbtn">
        	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="recipient_name_id_toistr()"/><span>&nbsp;</span>
            <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('recipient_namediv')"/> 
        </div>
	</form>	