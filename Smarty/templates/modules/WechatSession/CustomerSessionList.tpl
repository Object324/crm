{if !empty($sessionLists)}
    {if empty($sessionLists.contacts_list) && empty($sessionLists.group_chat_list)}
        <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
    {/if}
    {if !empty($sessionLists.contacts_list)}
        <div class="marB20">
            {*<div class="talk-tabs">
                <ul class="talk-tabs-nav talk-tabs-nav-two">
                    <li>联系人</li>
                    <li>显示更多</li>
                </ul>
            </div>*}
            <div class="weui-cells weui-cells-left">
                {foreach item=contacts_list from=$sessionLists.contacts_list}
                    {if !empty($contacts_list)}
                        <div class="weui-cell" block="session">
                            <input type="hidden" name="wx_userid" value="{$contacts_list.tolist}">
                            <div class="weui-cell__hd">
{*                                <img src="themes/images/defaultuser.png">*}
                                <img src="{$contacts_list.imagepath}">
                            </div>
                            <div class="weui-cell__bd">
                                <p>{$contacts_list.last_name}{*<span>@外部</span>*}</p>
                                <p>{$contacts_list.content}<span style="float: right;">{$contacts_list.msgtime}</span></p>
                            </div>
                        </div>
                    {/if}
                {/foreach}
            </div>
        </div>
    {/if}


    {if !empty($sessionLists.group_chat_list)}
        <div>
            {*<div class="talk-tabs">
                <ul class="talk-tabs-nav talk-tabs-nav-two">
                    <li>群聊</li>
                    <li>显示更多</li>
                </ul>
            </div>*}
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
                                    <p>{if strlen($group_chat_list.roomname)>21}{substr($group_chat_list.roomname,0,21)|cat:'...'}{else}{$group_chat_list.roomname}{/if}{*<span>@灵当科技</span>*}</p>
                                    <p>{$group_chat_list.content}<span style="float: right;">{$group_chat_list.msgtime}</span></p>
                                {else}
                                    <p>{$group_chat_list.fromid}{*<span>@灵当科技</span>*}</p>
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