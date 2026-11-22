<div class="DivC" style="float:left; ">
	<div class="Top">
		<table class="bgwhite"  width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody><tr>
				<td class="DivCL c" style="width: 75%;"></td>
				<td class="DivCR">
					<div class="PageDiv0" style="margin-top: 4px;margin-bottom:4px;">
						<div class="ld-flex-start">
							<div class="ld-pagenum-div"> {'TOTALOF'|@getFixedLabel} {$COUNTROWS} {'RECORDS'|@getFixedLabel}</div>
							{$navigationOutput[1]}

{*							<li><span {if $PREPAGE eq 'yes'}class="icon-prevpage" title="{'PREVPAGE'|@getFixedLabel}" onclick="channelcode_related_page({$RECORD},{$PREPAGENUM});"{else}class="no-icon-prevpage"{/if}></span></li>*}
{*							<li><span {if $NEXTPAGE eq 'yes'}class="icon-nextpage" title="{'NEXTPAGE'|@getFixedLabel}" onclick="channelcode_related_page({$RECORD},{$NEXTPAGENUM});"{else}class="no-icon-nextpage"{/if}></span></li>*}
{*							<li class="Input"><input name="pagenum" class="txtBox btn-radius-system pagenum_system" start="0" relatetag="ChannelCode" record="{{$RECORD}}" type="text" value="{$PAGE}" style="width: 3em;margin-right: 0.7em;"></li>*}
{*							<li style="float:right;padding-left:5px;"><span title="GO"><a href="javascript:void(0);" onclick="channelcode_related_pagebygo(event,ld(this));" relatetag="ChannelCode" record="{{$RECORD}}" start="0">GO</a></span></li>*}
						 </div>
					</div>
				</td>
			</tr></tbody>
		</table>
	</div>
	<table id="resize_content_tableid_ViewHistory" name="resize_content_tableid_ViewHistory" class="listEntries" style="width: 100%;" cellspacing="1" cellpadding="0" border="0">
		<tbody><tr>
			<th style="width:20%" tag="fieldname" headermodule="" headername="fieldname">{'nameofenterprise'|@getFixedLabel}</th>
			<th style="width:20%" tag="prevalue" headermodule="" headername="prevalue">{'WEIXIN'|@getFixedLabel}{'MAILNAME'|@getFixedLabel}</th>
			<th style="width:20%" tag="prevalue" headermodule="" headername="prevalue">{'WEIXIN'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}</th>
			<th style="width:20%" tag="postvalue" headermodule="" headername="postvalue">{'ADDITIONAL'|@getFixedLabel}{'people'|@getFixedLabel}</th>
			<th style="width:20%x" tag="whodid" headermodule="" headername="whodid">{'ADDITIONAL'|@getFixedLabel}{'TIMES'|@getFixedLabel}</th>
		</tr>
		
		{foreach item=external_info key=ikey from=$DATA}
		<tr id="relation_ViewHistory_0" class="lvtColData" onmouseout="relationListOnMouseOut('ViewHistory_{$ikey}','on');" onmouseover="relationListOnMouseOver('ViewHistory_{$ikey}');">
			<td align="left">{$external_info.external_contact_corpname}</td>
			

			<td align="left">{$external_info.external_contact_name}</td>


			<td align="left">{$external_info.external_contact_type}</td>


			<td align="left">{$external_info.last_name}</td>

			<td align="left">{$external_info.createdtime}</td>
		</tr>
		{/foreach}
		</tbody>
	</table>
</div>