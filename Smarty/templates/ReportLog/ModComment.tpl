<!--修改编码格式:统一编码：UTF-8-->
            <div class="yb_lm" style="margin:0px;padding:0px;">
                    <div class="yb_lm_t" style="height:32px;"><strong>{'Instructions_and_reply'|@getFixedLabel}</strong>
                      <span style=" position: absolute; top:4px; right:10px;"> <select id="reloadContent" {if $STATUS eq 1}onchange="reloadContentFiltering(this,{$REPORTLOGID},{$REPORTLOGTYPE});"{/if}>
							<option value="All" {if $CRITERIA eq 'All'}selected{/if}>{'ALL'|@getFixedLabel}</option>
							<option value="Last5" {if $CRITERIA eq 'Last5'}selected{/if}>{'TOP5'|@getFixedLabel}</option>
							<option value="Mine" {if $CRITERIA eq 'Mine'}selected{/if}>{'MINEADD'|@getFixedLabel}</option>
                        </select></span> 
                    </div>
               
               
                     {if $STATUS eq 1}
<div id="ModCommentsDetailViewBlockCommentWidget" style="display: block;">
<table cellspacing="0" cellpadding="5" border="0" width="100%">
    <tr style="height: 25px;">
        <td class="dvtCellInfo" align="left" colspan="4">
            <div id="ModCommentsDetailView" style="overflow-y:auto;overflow-x: auto;word-break:break-all; height: 150px; width: 100%;"> 
            {$MODCOMMENTS}                  
            </div>
        </td>                    
    </tr>
    <tr style="height: 25px;">
        <td class="dvtCellLabel" align="right">
            {'Reply'|@getFixedLabel}:
        </td>
        <td class="dvtCellInfo" align="left" width="100%" colspan="3">
        <textarea id="txtbox_ModCommentsDetailViewBlockCommentWidget" class="detailedViewTextBox" rows="4" cols="90" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'"></textarea>
        <br>
		<a class="link" onclick="AddModComments(this,{$REPORTLOGID},{$REPORTLOGTYPE});" href="javascript:;">{'SAVE'|@getFixedLabel}</a>
        {'OR'|@getFixedLabel}
        <a class="link" onclick="$('txtbox_ModCommentsDetailViewBlockCommentWidget').value='';" href="javascript:;">{'CLEAR'|@getFixedLabel}</a>
        </td>
    </tr>
</table>  
</div>
{/if}
                     
                     
            </div> 
