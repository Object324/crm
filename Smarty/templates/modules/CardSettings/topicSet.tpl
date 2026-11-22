
<div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">
    <table class="settingPopTable" name="topic_table" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tbody>
        <tr>
            <th>专题名称</th>
            <th width="30%">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        {if $TopicLists|@count >0 }
            {foreach key=index item=TopicList from=$TopicLists}
                <tr topicid="{$TopicList.topicid}">
                    <td><input class="detailedViewTextBox" tag="{$TopicList.topicname}" oldvalue="{$TopicList.topiclabel}" name="topicid_{$TopicList.topicid}" value="{$TopicList.topiclabel}" type="text"
                               onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox bgcolordh'">
                    </td>
                    <td>
                        <a class="Anu3_a {if $TopicList.presence eq 'yes'}redFont{/if}" href="javascript:void(0);" name="presenceTopic" presence="{$TopicList.presence}" onclick="CardSettingsobj.presenceTopic(this);">{if $TopicList.presence eq 'yes'}{'INACTIVATE'|@getFixedLabel}{else}{'ACTIVATE'|@getFixedLabel}{/if}</a>
                    </td>
                </tr>
            {/foreach}
        {/if}

        </tbody>
    </table>
</div>