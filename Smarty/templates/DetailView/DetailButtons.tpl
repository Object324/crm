<div style="display: none;">
    <div class="btn-r">
        {if $privrecord neq ''}
          <a class="yes-prevpage" name="privrecord" startpage="{$nextrecordstart}" module="{$MODULE}" viewtype="{$VIEWTYPE}" record='{$nextrecord}' onclick="DetailViewPreVNext(ld(this))" href="#" lasturl="{if $result_aprove  eq '1' || $result_aprove eq '2' }&result_aprove={$result_aprove}{/if}{if $PAGEFROM neq ''}&pagefrom={$PAGEFROM}{/if}">{'PREVDATA'|@getFixedLabel}</a>
        {else}
          <a class="no-prevpage" href="javascript:;">{'PREVDATA'|@getFixedLabel}</a>
        {/if}
        &nbsp;
        {if $nextrecord neq ''}
          <a class="yes-nextpage" name="nextrecord" startpage="{$nextrecordstart}" module="{$MODULE}" viewtype="{$VIEWTYPE}" record='{$nextrecord}' onclick="DetailViewPreVNext(ld(this))" href="#" lasturl="{if $result_aprove  eq '1' || $result_aprove eq '2' }&result_aprove={$result_aprove}{/if}{if $PAGEFROM neq ''}&pagefrom={$PAGEFROM}{/if}">{'NEXTDATA'|@getFixedLabel}</a>&nbsp;
        {else}
          <a class="no-nextpage" href="javascript:;">{'NEXTDATA'|@getFixedLabel}</a>&nbsp;
        {/if}
      </div>
</div>
{include file='RelatedListsHidden.tpl'}
{*wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）*}

<div id="related_keywords_field" {if $VIEWKEYWORDS eq 0 && $KEYWORDSHTML neq ''} class="related_keywords_field related_keywords_field-{$CURRENT_USER_ID}" {/if}>
    {if $VIEWKEYWORDS eq 0 && $KEYWORDSHTML neq ''}
        {$KEYWORDSHTML}
    {/if}
</div>
<div name="relatelisttab" style="display: flex;justify-content: space-between;">
    {include file="RelatedListTab.tpl"}
</div>