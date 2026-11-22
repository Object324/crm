{if !empty($chatdataLists)}
    {$count} {'RelatedRecords'|@getFixedLabel}
    {foreach item=chatDatas from=$chatdataLists}
        <input type="hidden" name="id" value="{$chatDatas.id}">
        <div class="weui-cells weui-cells-left" name="contextWrap">
            <div class="weui-cell">
                <div class="weui-cell__bd">
                    <div>
                        <p>{$chatDatas.last_name} {$chatDatas.msgtime}</p>
                        <p>{if $chatDatas.content neq ''}
                                {$chatDatas.content}
                            {/if}
                        </p>
                    </div>
                    <div style="float: right;display: none;" name="contextcontent">
                        <input type="hidden" name="seq" value="{$chatDatas.seq}">
                        <a href="javascript:;" onclick="WechatSessionobj.ChatDataListobj.search('context');">{'ViewContext'|@getFixedLabel}</a>
                    </div>
                </div>
            </div>
        </div>
    {/foreach}
{else}
    <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
{/if}