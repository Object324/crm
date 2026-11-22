<!--修改编码格式:统一编码：UTF-8-->
<div class="widget-content">
	<div class="tab">
		{assign var="i" value=0}
		{foreach item=row key=module from=$HOME_STUFF.menu_label}
			{assign var="j" value=$i++}
			{if $j == 0}
				<span class="tab-item cur" data-type="{$module}" data-stuffid="{$HOME_STUFFID}" id="home-stuff-mueu-label">
			{else}
				<span class="tab-item" data-type="{$module}" data-stuffid="{$HOME_STUFFID}" id="home-stuff-mueu-label">
			{/if}
				{$row.name}{if $row.nums gte 0}({$row.nums}){/if}
			</span>
		{/foreach}
	</div>
	
		<ul class="deal-list crm-scroll">
		{assign var="i" value=0}
		{foreach item=label_data key=module from=$HOME_STUFF.menu_data}
			{assign var="j" value=$i++}
			{if $j == 0}
				<li class="deal-total" id="deal-total" tag="{$module}">
			{else}
				<li class="deal-total" id="deal-total" tag="{$module}" style="display:none;">
			{/if}
				{foreach item=row from=$label_data}
				<span class="deal-total-item ld-stuff-item-c-l-c">
					<h6>{$row.name}</h6>
					<a searchtype="now" onclick="homestuffObj.setSalesKitChuantou('{$row.stufflabel}',34,ld(this))" title="{$row.value}">
						{''|@getDefaultCurrecySymbol}{$row.value}
					</a>
				</span>
				{/foreach}
			</li>
		{/foreach}
		{if $HOME_STUFFID eq 33}
			{assign var="i" value=0}
			<li class="ld-titrow-bg">
				<span class="deal-total-item"><span>{'ORDERNUM'|@getFixedLabel}</span></span>
				<span class="deal-total-item"><span>{'ASSIGNEDTO'|@getFixedLabel}</span></span>
				<span class="deal-total-item"><span>{'SUM'|@getFixedLabel}</span></span>
			</li>
			{foreach item=label_data key=module from=$HOME_STUFF.menu_list}
				{assign var="j" value=$i++}
				
				{foreach item=row from=$label_data}
					{if $j == 0 && $row.label1 mod 2 eq '0'}
						<li class="deal-total lvtColDataBj" id="deal-total" tag="{$module}" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On')">
					{elseif  $j == 0}
						<li class="deal-total lvtColData" id="deal-total" tag="{$module}" onmouseover="listOnMouseOver(ld(this),'On')"  onmouseout="listOnMouseOut(ld(this))">
					{else}
						<li class="deal-total" id="deal-total" tag="{$module}" style="display:none;">
					{/if}
							<span class="deal-total-item">
								<span title="{$row.label1}">
									{$row.label1}
								</span>
							</span>
							<span class="deal-total-item">
								<span title="{$row.label1}">
									{$row.label2}
								</span>
							</span>
							<span class="deal-total-item ld-stuff-item-c-l-c rtextalign">
								<span title="{$row.label1}">
									{$row.label3}
								</span>
							</span>
						</li>
				{/foreach}
				
			{/foreach}
		{else}
			{assign var="i" value=0}
			{foreach item=label_data key=module from=$HOME_STUFF.menu_list}
				{assign var="j" value=$i++}
				{foreach item=row from=$label_data}
					
			
						<li class="deal-item j-detail ld-stuff-item-c-l-c" id="deal-item-list" tag="{$module}" {if $j>0}style="display:none;"{/if}>
					
						<h6>{$row.name}</h6>
						<p>{$row.label}</p>
						<span class="status"> </span>
					</li>
				{/foreach}
			{/foreach}
		{/if}
		</ul>
	
</div>
</div>