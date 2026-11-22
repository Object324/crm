<li class="customview_oplist_group_li {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq 'ALL'}activate{/if}" name="{'ALL'|@getFixedLabel}" groupid="ALL" onclick="changeCustomViewGroup(this,'ALL')"><span>{'ALL'|@getFixedLabel}</span><span>（{$CUSTOMVIEW_OPTION|@count}）</span></li>
{foreach key=sequence item=group_info from=$CUSTOMVIEWGROUPLIST['groupList']}
    {if $group_info['cvCount'] neq 0 ||($group_info['cvCount'] eq 0 &&$group_info['groupid'] eq 'commonCustomView')}
        <li class="customview_oplist_group_li {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq $group_info['groupid']}activate{/if}" name="{$group_info['group_name']}" groupid="{$group_info['groupid']}" onclick="changeCustomViewGroup(this,'{$group_info.groupid}')"><span>{$group_info['group_name']}</span><span>（{$group_info['cvCount']}）</span></li>
    {/if}
{/foreach}