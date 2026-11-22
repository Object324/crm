{if !empty($sessionLists)}
    {if empty($sessionLists.contacts_list) && empty($sessionLists.group_chat_list)}
        <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
    {/if}
    {if !empty($sessionLists.contacts_list)}
        <div class="marB20">
            <div class="weui-cells weui-cells-left">
                {foreach item=contacts_list from=$sessionLists.contacts_list}
                    {if !empty($contacts_list)}
                        <div class="weui-cell" block="session">
                            <input type="hidden" name="wx_userid" value="{$contacts_list.tolist}">
                            <div class="weui-cell__hd">
                                <img src="{$contacts_list.imagepath}">
                            </div>
                            <div class="weui-cell__bd">
                                <div>{$contacts_list.last_name}<span class="rfloat greyFont8">{$contacts_list.msgtime}</span></div>
                                <p>{$contacts_list.content}</p>
                            </div>
                        </div>
                    {/if}
                {/foreach}
            </div>
        </div>
    {/if}
    {if !empty($sessionLists.group_chat_list)}
        <div>
            <div class="weui-cells weui-cells-left">
                {foreach item=group_chat_list from=$sessionLists.group_chat_list}
                    {if !empty($group_chat_list)}
                        <div class="weui-cell" block="session">
                            <input type="hidden" name="roomid" value="{$group_chat_list.roomid}">
                            <div class="weui-cell__hd">
                                <img src="themes/images/defaultuser.png">
                            </div>
                            <div class="weui-cell__bd">
                                {if !empty($group_chat_list.roomname)}
                                    <p>{$group_chat_list.roomname}</p>
                                    <p>{$group_chat_list.content}<span class="rfloat greyFont8">{$group_chat_list.msgtime}</span></p>
                                {else}
                                    <p>{$group_chat_list.fromid}</p>
                                {/if}

                            </div>
                        </div>
                    {/if}
                {/foreach}
            </div>
        </div>
    {/if}
{else}
    <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
{/if}