<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListViewMap.js"></script>
<div class="map-list">
{assign var="i_count" value=1} 
{foreach key=record item=map_list from=$MAPCONTENT}
	<div class="map-list-item" data-id="{$record}" data-latitude="{$map_list['list']['lat']}" data-longtitude="{$map_list['list']['lng']}" >
		{foreach key=fieldname item=value from=$map_list['list']}
			{if $fieldname neq 'lat' && $fieldname neq 'lng' && $fieldname neq 'local_address'}
				{if $MODULE eq 'Accounts'}
					{if $fieldname eq 'accountname'}
						<h5><a record='{$record}' module='{$MODULE}' fieldname='accountname' href="javascript:;" onclick='ListLinkClick(ld(this),event)'>{$value}</a></h5>
					{else}
						<p style="width: 245px;">{$value}</p>
					{/if}
				{else}
					{if $fieldname eq $linkfield}
						<h5><a record='{$record}' module='{$MODULE}' fieldname='{$fieldname}' href="javascript:;" onclick='ListLinkClick(ld(this),event)'>{$value}</a></h5>
					{else}
						<p style="width: 245px;">{$value}</p>
					{/if}
				{/if}
			{/if}
		{/foreach}
		<span class="pos">{$i_count}</span>
		<a href="javascript:;" class="change-geo" r_m="Accounts" r_a="ListView" r_r="0">{'EDIT'|@getFixedLabel}</a>
	</div>
	{assign var="i_count" value=$i_count+1}  
{/foreach}
</div>
{if $MODULE eq 'Accounts'}
<div class="maplist-btn-box">
	<ul class="">
		<li {if $PREV_PAGE gte 1} onclick="changeListMap(this,'{$MODULE}','map',{$PREV_PAGE},CrmPopup.getPopupObj('last'))" class="maplist-btn maplist-btn-prev" {else} class="maplist-btn maplist-btn-prev maplist-btn-disabled"{/if}>上一页</li>
		<li {if $NEXT_PAGE gt 1} onclick="changeListMap(this,'{$MODULE}','map',{$NEXT_PAGE},CrmPopup.getPopupObj('last'))" class="maplist-btn maplist-btn-next" {else} class="maplist-btn maplist-btn-next maplist-btn-disabled" {/if}>下一页</li>
	</ul>
</div>
{/if}
{if $isShowMap eq 'yes'}
	<div class="maplist-btn-box">
		<ul class="">
			<li {if $PREV_PAGE gte 1} onclick="ListViewMap.getInstance().changeListMap(this,'{$MODULE}','map',{$PREV_PAGE},CrmPopup.getPopupObj('last'))" class="maplist-btn maplist-btn-prev" {else} class="maplist-btn maplist-btn-prev maplist-btn-disabled"{/if}>上一页</li>
			<li {if $NEXT_PAGE gt 1} onclick="ListViewMap.getInstance().changeListMap(this,'{$MODULE}','map',{$NEXT_PAGE},CrmPopup.getPopupObj('last'))" class="maplist-btn maplist-btn-next" {else} class="maplist-btn maplist-btn-next maplist-btn-disabled" {/if}>下一页</li>
		</ul>
	</div>
{/if}
<script>
	var data_map_detail = '{$MAPDETAIL}';
	var first_map_lat = '{$FIRST_MAP_LAT}';
	var first_map_lng = '{$FIRST_MAP_LNG}';
</script>