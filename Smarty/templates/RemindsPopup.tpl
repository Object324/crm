<div id="reminds_popup_expansion" style="float: right; width:250px; {if $Reminds_See_Set eq 2 ||  $Expand eq 'yes'} display:none;{/if}">
    <div class="Stcbox_Expansion">
    	<div class="StcboxT" onclick="fn_display_div()" style="cursor:pointer;">
            <span>{'REMINDS'|@getFixedLabel}</span>
            <p>
                <a class="remind-notread-count" id="remind_notread_count" href="javascript:void(0);">{$counts}</a><b style="font-size:14px;">&nbsp;<img src="./themes/softed/images/zhankai.png" style="padding:0 3px;margin-bottom: 2px;">&nbsp;</b>{'EXPANSION'|@getFixedLabel}
            </p>
        </div>
    </div>
</div>

<div id="reminds_popup" style="float: right; width:325px; {if $Expand eq 'no'} display:none;{/if}">
    <div class="Stcbox">
        <div class="StcboxT">
            <span>{'REMINDS'|@getFixedLabel}</span>{* wyt 220921 BUG0056552 首页-消息提醒，展开之后，没有收起的按钮*}
            <div style="float: right;">
                <p style="float: left;line-height: 30px;margin-right: 15px;cursor: pointer;" onclick="fn_folded_div()"><b><img style="float: left;margin: 9px 6px;" src="./themes/softed/images/shouqi.png"></b>{'COLLAPSE'|@getFixedLabel}</p>
                <img onclick="fn_close_div();" src="themes/softed/images/Sclose.png" />
            </div>
        </div>
        <div class="StcboxC">
            <a class='ld_list_href_name tip-items-list'  fieldname='content' module='Reminds' record='{$remindsid}'   href='index.php?pageto_module=Reminds&pageto_action=index&pageto_record={$remindsid}' onclick='ListLinkClick(ld(this),event)'>
            {$content}</a>
        	<p>{$LISTLINKFIELDLABEL}<font>{$label_fld}</font><br />{'operatoroertime'|@getFixedLabel}：{$date_time}</p>
        </div>
        <div class="StcboxB">
        	<ul class="L">
            	<li class="L"><a onclick="return setRemindReaden({$remindsid});" href="javascript:void(0);">{'LBL_READEN'|@getFixedLabel}</a></li>
                <li class="C"><a onclick="return RemindDelayDropDown(event,this,'selectviewremind');" target="main" href="javascript:void(0);">{'POSTPONE'|@getFixedLabel}</a></li>
                <li class="R"><a href='index.php?pageto_action=index&pageto_module=Reminds&viewname=108' target="_blank">{'MORE'|@getFixedLabel}</a></li>
            </ul>
            <ul class="R">
            	<li class="L"><a href="javascript:;" style="display:{if $PAGENUM eq '1'}none;{/if}" onclick="return Remindpages('up',{$remindsid},{$PAGENUM});"></a></li>
                <li class="C" ><strong>{$PAGENUM}</strong> / {$counts}</li>
                <li class="R" style="{if $PAGENUM eq $counts}margin-right:38px;{/if}"><a href="javascript:;" style="display:{if $PAGENUM eq $counts}none;{/if}" onclick="return Remindpages('down',{$remindsid},{$PAGENUM});"></a></li>
            </ul>
        </div>
    </div>
</div>
<input  type="hidden" value="{$remindsid}" id="popremindids"/>