{include file='EditViewHidden.tpl'}
{*控制最大宽度:max-width: 1300px;margin:auto;*}
<table style="width:100%;" class="ld-createedit-qucikcontent">
    <tr>
        <td class="Tdcenter" valign="top">
            <div id="DetailContent" class="ld-createedit-content">
                <table class="ld-createedit-tablecontent" cellspacing="0" cellpadding="0" border="0" style="width:100%;table-layout: fixed;">
                    <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
                    {assign var="curr_row_num" value="0"}
                    {if is_array($QUICKCREATE)}
                        {assign var="table_all_rowcount" value=$QUICKCREATE|@count}
                    {else}
                        {assign var="table_all_rowcount" value=0}
                    {/if}
                    {foreach item=subdata from=$QUICKCREATE}
                        {math equation="($curr_row_num+y)" y=1 assign=curr_row_num }  
                    	<tr class="ld-form-item">
							{assign var="td1_uitype" value=$subdata[0][0][0][0]}
							{assign var="td2_uitype" value=$subdata[1][0][0][0]}
                    		{foreach key=mainlabel item=maindata from=$subdata}
                                {if is_array($subdata)}
                                    {assign var="row_td_count" value=$subdata|@count}
                                {else}
                                    {assign var="row_td_count" value=0}
                                {/if}
                    			{include file='DetailView/EditViewUI.tpl'}
                    		{/foreach}
                    	</tr>
                    {/foreach}    
                    <tr>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
    {if $MODULE eq 'Events'}
        {**{include file="ActivityEditView.tpl"}**}
    {/if}
</table>
</form>
<div class="E_morefields ctextalign">
    <a href="javascript:;" id="pagechange" onclick="CreatePagePopup.pagechange()">{"DISPLAYMOREITEM"|@getFixedLabel}<i class="icon-homeimg icon-chevrondown-blue"></i></a>
</div>

<table id="popup_submit_head" border="0" cellspacing="0" cellpadding="0" width="100%" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="DetailContentTable linefeed">
    <tbody><tr>
        <td colspan="4" class="ld-from-headblock">
            <div class="ld-from-headblock-title" tag="headblock-title">{"SELECTAPPROVALPROC"|@getFixedLabel}</div>
        </td>
    </tr></tbody>
</table>
<div id="popup_submit_content" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="ld-public-content-big dd">
    {include file="Approve/SubmitApproveNew.tpl"}
</div>
