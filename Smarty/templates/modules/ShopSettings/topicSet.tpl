{*ls 2021-10-26 【ID1001109】增加“小程序商城设置”*}
<div class="ld-pop-container ld-table-container ld-table-container-lines">
    <div class="divPopOverflow">
        <table class="" name="topic_table" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th>{'SPECIALNAME'|@getFixedLabel}</th>
                    <th style="width: 20%;">{'WHETHERTOENABLE'|@getFixedLabel}</th>
                    <th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
                </tr>
            </thead>
            <tbody>
            {if $TopicLists|@count >0 }
            {foreach key=index item=TopicList from=$TopicLists }
            <tr topicid="{$TopicList.topicid}" class="ld-topic-draggable">
                <td><input class="ld-input-inner" oldvalue="{$TopicList.topic_name}" name="topicid_{$TopicList.topicid}" value="{$TopicList.topic_name}" type="text">
                </td>
                {*wym BUG0072058 fbcrm-商城设置-点击“首页专题设置”，选择专题右边设置页面，关闭“精选商品”专题，点击保存，关闭功能生效了，但是再打开设置界面，按钮还是显示开启状态*}
                <td>
                    <input class="second_switch" type="checkbox" name="presenceTopic" presence="{$TopicList.presence}" onclick="ShopSettingsobj.presenceTopic(this);" {if $TopicList.presence=='yes'}checked{/if}></input>
                </td>
                <td class="sort_td drag-handle">
                    <i class="ld-fonticon ld-fonticon-del" name="deleteTopic" onclick="ShopSettingsobj.deleteTopic(this);" title="{'DELETE'|@getFixedLabel}"></i>
                    <a class="Anu3_a ld-dragicon sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="cursor: move" ></a>
                </td>
            </tr>
            {/foreach}
            {/if}
            </tbody>
        </table>
    </div>
    <div class="padT20">
        <a href="javascript:void(0);" onclick="ShopSettingsobj.addTopicSet()">{'CREATESPECIAL'|@getFixedLabel}</a>
    </div>
</div>