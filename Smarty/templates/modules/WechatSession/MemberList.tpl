{if !empty($memberLists)}
    {$memberLists}
{else}
    <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
{/if}