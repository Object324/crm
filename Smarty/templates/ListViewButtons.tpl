<ul class="D_btn_box">
	{foreach key=btn_key item=btn_item from=$LISTBUTTON}
		{if $btn_item.permit eq 'yes'}
			<li class="D_anu_a D_menu_hova {if $buttonsPosition eq 'down'}D_more_menua1{/if}" {if $btn_key  neq 'More'} onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;"{/if}>
				<a title="{$btn_item.label}" >
				<b class="icon-homeimg {$btn_item.icon}"></b><span>{$btn_item.label}</span>
                {*edit:duan reason:列表页按钮右上角增加数字显示 *}
                <b name="{$btn_item.btnkey}" class="ListView_ButtonNum">{if $btn_item.num neq "" && $btn_item.num >0}[{$btn_item.num}]{/if}</b>
                </a>
        {if $btn_item.list neq ''}
            {if $btn_key eq 'Create' && $MODULE eq 'Accounts'}
                {if ($btn_item.list.public_ordinary neq '' && $btn_item.list.btnkey neq '') || ($btn_item.list.public_ordinary neq '' && $btn_item.list.public_allocated neq '') || ($btn_item.list.btnkey neq '' && $btn_item.list.public_allocated neq '') }
                    <ol class="D_more_menua">
                {else}  
                    <ol class="D_more_menua" style="display: none;">      
                {/if}         
            {else}   	
					<ol class="D_more_menua">
            {/if}             
						{foreach key=more_key item=more_item from=$btn_item.list}
                        
                            {if $more_item.permit eq 'yes'}
								<li onclick="listviewbutton_click(this,'{$MODULE}','{$more_key}',event);   return false;">
									<a title="{$more_item.label}">
										{$more_item.label}</a>
								</li>
							{/if}
						{/foreach}
					</ol>
				{/if}
			</li>
		{/if}
	{/foreach}
</ul>