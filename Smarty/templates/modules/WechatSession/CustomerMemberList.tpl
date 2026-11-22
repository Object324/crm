{if !empty($memberLists)}
    {if empty($memberLists.contacts_list) && empty($memberLists.group_chat_list)}
        <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
    {/if}
    {if !empty($memberLists.contacts_list)}
        <div class="marB20">
            {*<div class="talk-tabs">
                <ul class="talk-tabs-nav talk-tabs-nav-two">
                    <li>联系人</li>
                    <li>显示更多</li>
                </ul>
            </div>*}
            <div class="weui-cells weui-cells-left">
                {foreach item=contacts_list from=$memberLists.contacts_list}
                    {if !empty($contacts_list)}
                        <div class="weui-cell" block="member">
                            <input type="hidden" name="wx_userid" value="{$contacts_list.weixin_external_userid}">
                            <div class="weui-cell__hd">
{*                                <img src="themes/images/defaultuser.png">*}
                                <img src="{$contacts_list.imagepath}">
                            </div>
                            <div class="weui-cell__bd">
                                <p>{$contacts_list.lastname}{*<span>@灵当科技</span>*}</p>
                                <p>{$contacts_list.corp_name}</p>
                            </div>
                        </div>
                    {/if}
                {/foreach}
            </div>
        </div>
    {/if}


    {if !empty($memberLists.group_chat_list)}
        <div>
            {*<div class="talk-tabs">
                <ul class="talk-tabs-nav talk-tabs-nav-two">
                    <li>群聊</li>
                    <li>显示更多</li>
                </ul>
            </div>*}
            <div class="weui-cells weui-cells-left">
                {foreach item=group_chat_list from=$memberLists.group_chat_list}
                    {if !empty($group_chat_list)}
                        <div class="weui-cell" block="member">
                            <input type="hidden" name="roomid" value="{$group_chat_list.roomid}">
                            <div class="weui-cell__hd">
                                <img src="themes/images/defaultuser.png">
                            </div>
                            <div class="weui-cell__bd">
                                {if !empty($group_chat_list.roomname)}
                                    <p>{$group_chat_list.roomname}{*<span>@灵当科技</span>*}</p>
                                    <p></p>
{*                                    <p><span style="float: right;">{$group_chat_list.msgtime}</span></p>*}
                                {else}
                                    <p>{$group_chat_list.tolist}{*<span>@灵当科技</span>*}</p>
                                    <p></p>
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
