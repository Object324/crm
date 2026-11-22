{foreach key=page_no item=page_detail from=$PAGELIST}
    {if $page_detail.1 eq $VIEWID}
        <li onclick="showDefaultCustomView(this,'{$MODULE}','','{$page_detail.1}')"><a class="On">{$page_detail.0|@getFixedLabel}</a></li>
    {else}
        <li onclick="showDefaultCustomView(this,'{$MODULE}','','{$page_detail.1}')"><a>{$page_detail.0|@getFixedLabel}</a></li>
    {/if}
{/foreach}