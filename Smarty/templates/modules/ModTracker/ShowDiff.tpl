<!--*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<!--{$TRACKRECORD->getDisplayName()}-->

<div id="orgLay" class="D_pop_box LdPopWidth600px">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'View History'|@getFixedLabel}</strong>
        <a href="javascript:ModTrackerCommon.hide();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>		
	<table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0">
      <tr>
        <td class="Note">
    		<ul class="LdPop_ul4 page">
        		<li>{'LBL_CHANGED_BY'|@getFixedLabel} <span>{$TRACKRECORD->getModifiedByLabel()} @ {$TRACKRECORD->getModifiedOn()}</span></li>            
        		<li style="float:right">
					{if $ATPOINT<$SHOWHISTORYCOUNT-1&&$SHOWHISTORYCOUNT>0}
                        <span class="icon-prevpage" onclick="ModTrackerCommon.showhistory({$TRACKRECORD->crmid},{$ATPOINT_PREV});"></span>
					{else}
                        <span class="icon-prevpagedis"></span>
					{/if}

					{if $ATPOINT< $SHOWHISTORYCOUNT&&$ATPOINT>0}
                        <span class="icon-nextpage" onclick="ModTrackerCommon.showhistory({$TRACKRECORD->crmid},{$ATPOINT_NEXT});"></span>
					{else}
                        <span class="icon-nextpagedis"></span>
					{/if}
				</li>   
        	</ul>
            <div class="Logscroll">	
				<table class="listEntries linefeed" width="100%" border="0" cellspacing="1" cellpadding="0">							
					<tr>
                		<th width="90">{'LBL_Field'|@getFixedLabel}</th>            
                		<th>{'LBL_Earlier'|@getFixedLabel}</th>
    					<th>{'LBL_Present'|@getFixedLabel}</th>
            	   </tr>
                    {foreach item=DETAIL from=$TRACKRECORD->getDetails()}
                    {assign var=fieldname value=$DETAIL->getFieldName()}
					<tr>
						<td>{$ARRFIELDLABEL.$fieldname}</td>
						<td>{$DETAIL->getDisplayLabelForPreValue()}</td>
						<td>
                            {if $smarty.request.highlight eq 'true'}
                                {$DETAIL->diffHighlight()}
                            {else}
                                {if $LOGMODULE eq 'ModComments' && $fieldname eq 'reltab'}
                                    {assign var=tabdnames value=$DETAIL->getDisplayLabelForPostValue()}
                                    {$tabdnames|@getTranstab}
                                {else}
                                    {$DETAIL->getDisplayLabelForPostValue()}
                                {/if}
                            {/if}
                        </td>
					</tr>
					{foreachelse}							
					<tr>
						<td colspan="3" align="center">
							{'MODIFIEDFIELDNOTALLOWED'|@getFixedLabel}
                            <br/>
                            {'RESUMEDRECORDING'|@getFixedLabel}
						</td>
					</tr>
					{/foreach}
				</table>
            </div>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="ModTrackerCommon.hide();puyoungJS_DialogBox.unblock();"/>
        <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
    </div>    
</div>