<div class="selectField" style="width: 100%;">
    {if $STATUS == '暂停'}
    <button class="ld-button ld-button-primary" onclick="cls_questionnaire.addquestionnaireblock(0);" type="button" style="float: right;margin-bottom: 10px;">{'NEWBLOCK'|@getFixedLabel}</button>
    {/if}
    <button class="ld-button" onclick="cls_questionnaire.previewQuestionnaire();" type="button" style="float: right;margin-bottom: 10px;{if $STATUS == '暂停'}margin-right: 20px;{/if}">{'PREVIEW'|@getFixedLabel}</button>
</div>
{assign var="blockindex" value=0}
{foreach key=blockid item=blockdata from=$LAYOUTBLOCKARRAY name=blocknames}
    <div class="blocks" id="block_{$blockid}" blockid="{$blockid}" block_sequence="{$blockdata['sequence']}" draggable="false" style="width: 100%;">
        <div class="DivCName title settingpage" style="margin-bottom: 0;margin-top: 15px;">
            {if $blockdata['blocktype'] == 'virtual'}
                <span id="block_name_9" style="margin-right: 0;">{'Virtual_block'|@getFixedLabel}{'blocknotshow'|@getFixedLabel}</span>
            {else}
                {if $LAYOUTBLOCKARRAY|@count > 2}
                    <div class="drag-handle icon-layout2 icon-layout2-move" title="" style="cursor:move;"></div>
                {/if}
                <span id="block_name_9" style="margin-right: 0;">{$blockdata['blockname']}</span>
            {/if}
            {if $STATUS == '暂停'}
                <a class="icon-layout2 icon-layout2-edit" href="javascript:void(0);" title="{'MODIFIEDBLOCK'|@getFixedLabel}" onclick="cls_questionnaire.addquestionnaireblock({$blockid})" draggable="false"></a>
            {/if}
            <div class="DivCNameRight" style="margin-right: 20px;">
                <!--新增题目-->
                {if $STATUS == '暂停'}
                    <a href="javascript:void(0);" onclick="cls_questionnaire.addQuestionTopic({$blockid},0)" draggable="false">{'CreatTopic'|@getFixedLabel}</a>
                {/if}
                {if $blockdata['blocktype'] != 'virtual'}
                    <!--区块上移下移-->
                    {if $blockindex+1 != $LAYOUTBLOCKARRAY|@count}
                        <a href="javascript:void(0);" onclick="cls_questionnaire.change_Block_Order('moveDown',{$blockid})" draggable="false">区块下移</a>
                    {/if}
                    {if $blockindex > 1}
                        <a href="javascript:void(0);" onclick="cls_questionnaire.change_Block_Order('moveUp',{$blockid})" draggable="false">区块上移</a>
                    {/if}
                    <!--区块删除-->
                    {if $STATUS == '暂停'}
                        <a href="javascript:void(0);" onclick="cls_questionnaire.deletequestionnaireblock({$blockid})">删除区块</a>
                    {/if}
                {/if}
            </div>
        </div>
        <div>
            <table cellspacing="1" cellpadding="0" style="width:800px" name="topic_table" width="100%">
                <input type="hidden" name="topic_row_cnt" value="{$blockdata['topic_array']|@count}">
                <tbody>
                    <tr rowindex=1>
                        <th style="text-align:center">{'Topicname'|@getFixedLabel}</th>
                        <th style="text-align:center">{'Topictype'|@getFixedLabel}</th>
                        <th style="text-align:center">{'Required'|@getFixedLabel}</th>
                        {if $STATUS == '暂停'}
                            <th style="text-align:center">{'OPERATING'|@getFixedLabel}</th>
                        {/if}
                    </tr>
                    <tr rowindex=2 {if $blockdata['topic_array']|@count == 0}{else}style="display: none;{/if}">
                        <td colspan="4" style="text-align:center;">{'Noquestions'|@getFixedLabel}</td>
                    </tr>
                    {if $blockdata['topic_array']|@count > 0}
                        {assign var="rowindex" value=3}
                        {foreach key=topicid item=topic from=$blockdata['topic_array']}
                            <tr rowindex="{$rowindex}" id="topicid_{$topicid}" topicid="{$topicid}">
                                <input type="hidden" name="topic_json_{$topicid}" id="topic_json_{$topicid}" value='{$topic['topic_json']}'>
                                <td width="50%" align="center">{$topic['topic_name']}</td>
                                <td width="20%" align="center">{$topic['topic_type_label']}</td>
                                <td width="10%" align="center">{$topic['required_label']}</td>
                                {if $STATUS == '暂停'}
                                    <td width="20%" align="center">
                                        <b class="icon-homeimg icon-pen" name="edit_topic" topicid="{$topicid}" onclick="cls_questionnaire.addQuestionTopic({$blockid},{$topicid})" style="cursor: pointer;margin-bottom: 4px;margin-right: 6px;"></b>
                                        {*<b class="icon-homeimg icon-copy" name="copy_topic" rowindex="'+rowindex+'" topicid="'+topic.topicid+'" title="" style="cursor: pointer;margin-bottom: 4px;margin-left: 0px;"></b>*}
                                        <b class="icon-up" name="moveUp" {if $rowindex == 3}style="display: none"{/if} onclick="cls_questionnaire.change_Topic_Order('moveUp',{$blockid},{$topicid})"></b>
                                        <b class="icon-down" name="moveDown" {if $rowindex-2 == $blockdata['topic_array']|@count}style="display: none"{/if} onclick="cls_questionnaire.change_Topic_Order('moveDown',{$blockid},{$topicid})"></b>
                                        <b class="icon-delete" name="delete_topic" topicid="{$topicid}" onclick="cls_questionnaire.deletedTopic({$blockid},{$topicid})"></b>
                                    </td>
                                {/if}
                            </tr>
                            {assign var="rowindex" value=$rowindex+1}
                        {/foreach}
                    {/if}
                </tbody>
            </table>
        </div>
    </div>
    {assign var="blockindex" value=$blockindex+1}
{/foreach}
