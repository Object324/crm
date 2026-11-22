{*列表按钮*}
{if $MODULE neq 'Reminds'}
    <div class="listview_toprightbox" tag="555" {if $listviewtopuitype neq 1}style="margin-right: 15px;" {/if}>
        <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
            {foreach key=btn_key item=btn_item from=$LISTBUTTON}
                {if $btn_item|@is_array && $btn_item.permit eq 'yes'}
                    {if $btn_key == 'More'}
                        <div class="ld-button-more tip-items-list" data-tip="{'MORE'|@getFixedLabel}" data-direction="top" data-type="position" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;"><i class="ld-button-icon-more"></i>
                    {else}
                        {if $btn_item.list neq ''}
                            <div class="ld-button ld-button-down" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;">{$btn_item.label}<b class="ld-button-arrow-down"></b>
                        {else}
                            <div class="ld-button" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;">{$btn_item.label}
                        {/if}
                    {/if}
                    <b name="{$btn_item.btnkey}" class="ListView_ButtonNum">{if $btn_item.num neq "" && $btn_item.num >0}[{$btn_item.num}]{/if}</b>
                    {if $btn_item.list neq ''}
                        {if $btn_key eq 'Create' && $MODULE eq 'Accounts'}
                            {if ($btn_item.list.public_ordinary neq '' && $btn_item.list.btnkey neq '') || ($btn_item.list.public_ordinary neq '' && $btn_item.list.public_allocated neq '') || ($btn_item.list.btnkey neq '' && $btn_item.list.public_allocated neq '') }
                                <ol class="D_more_menua" style="z-index:902;{if $listviewtopuitype neq 1}left:0;right:unset;{/if}">
                            {else}
                                <ol class="D_more_menua" style="display: none;z-index:902;{if $listviewtopuitype neq 1}left:0;right:unset;{/if}">
                            {/if}
                        {else}
                            <ol class="D_more_menua" style="overflow-x: hidden;z-index:902;{if $listviewtopuitype neq 1}left:0;right:unset;{/if}">
                        {/if}
                        {foreach key=more_key item=more_item from=$btn_item.list}
                            {if $more_item|@is_array && $more_item.permit eq 'yes'}
                                <li tag="{$more_key}" {if $more_key eq 'ContinuousDialing'}style="display: none"{/if} onclick="listviewbutton_click(this,'{$MODULE}','{$more_key}',event);return false;">
                                    <a title="{$more_item.label}">{$more_item.label}</a>
                                </li>
                            {/if}
                        {/foreach}
                        </ol>
                    {/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    </div>
{/if}