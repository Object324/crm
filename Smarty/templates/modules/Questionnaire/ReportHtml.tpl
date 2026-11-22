{*//表单推广 统计数据页面  ajax 请求页面*}
<div class="container" style="margin: 12px auto;">
    <div class="formdiv">
        <div id="mainFieldsIphone">
            {if !empty($reportArr)}
                {foreach key=blockid item=block from=$reportArr}
                    <div>
                        {if $block.blocktype != 'virtual'}
                            <div id="block_{$blockid}" style="height: 50px;font-size: 28px;font-weight: bold;line-height: 50px;margin: 4px 0 12px;color: #333;">
                                {$block.blockname}
                            </div>
                        {/if}
                    {assign var=i value=1}
                    {foreach key=key item=topic from=$block['topic_array']}
                        <div topic_id="{$topic.topicid}" class="Q_Content">
                            {if $topic.topic_type neq 'text'}
                                <div id="show_{$topic.topicid}" class="question">
                                    {if $block.autonumber == 'yes'}
                                        {if $block.numberstyle == ','}
                                            <span>{$i}</span>
                                        {elseif $block.numberstyle == 'O,'}
                                            <span style="margin-top:1px;height: 19px;width: 19px;display: block;float: left;border: 1px solid #333;border-radius: 100%;line-height: 18px;text-align: center;font-size: 12px;">
                                                {$i}
                                            </span>
                                        {elseif $block.numberstyle == '),'}
                                            <span>{$i})</span>
                                        {elseif $block.numberstyle == '(),'}
                                            <span>({$i})</span>
                                        {/if}
                                        {if $block.numbersuffix == ''}
                                            <span> </span>
                                        {elseif $block.numbersuffix == '、'}
                                            <span>、</span>
                                        {elseif $block.numbersuffix == '.'}
                                            <span>. </span>
                                        {/if}
                                    {/if}
                                    {$topic.topic_name}
                                    {if $topic.required eq 'yes'}
                                        <span id="show_r_{$topic.topicid}" class="required">*</span>
                                    {/if}
                                </div>
                            {else}
                                {assign var=i value=$i-1}
                            {/if}
                            <div class="answer">
                                {if $topic.topic_type == 'Singleline' || $topic.topic_type == 'tel'}
                                    填写率：{if $topic.chair_count!=0}{round(($topic.chair_count/$recoverys)*100)}{else}0{/if}% / 填写：{$topic.chair_count}
                                    <div class="report-textanswer">
                                        <div class="report-textanswer-title">文本答案</div>
                                        {if $topic.chair_count == '0'}
                                            <div>{'NOQUESTIONNAIRERESULT'|@getFixedLabel}</div>
                                        {else}
                                            <div class="report-textanswer-contentscoll">
                                                {foreach key=Singlelineid item=info from=$topic.option_info}
                                                    <div class="report-textanswer-content">
                                                        {count($topic.option_info)-$Singlelineid}、{$info}
                                                    </div>
                                                {/foreach}
                                            </div>
                                        {/if}
                                    </div>
                                {elseif $topic.topic_type == 'Multiline'}
                                    填写率：{if $topic.chair_count!=0}{round(($topic.chair_count/$recoverys)*100)}{else}0{/if}% / 填写：{$topic.chair_count}
                                    <div class="report-textanswer">
                                        <div class="report-textanswer-title">文本答案</div>
                                        {if $topic.chair_count == '0'}
                                            <div>{'NOQUESTIONNAIRERESULT'|@getFixedLabel}</div>
                                        {else}
                                            <div class="report-textanswer-contentscoll">
                                                {foreach key=Multilineid item=info from=$topic.option_info}
                                                    <div class="report-textanswer-content">
                                                        {count($topic.option_info)-$Multilineid}、{$info}
                                                    </div>
                                                {/foreach}
                                            </div>
                                        {/if}
                                    </div>
                                {elseif $topic.topic_type == 'more' || $topic.topic_type == 'one'}
                                    <div>填写率：{if $topic.chair_count!=0}{round(($topic.chair_count/$recoverys)*100)}{else}0{/if}% / 填写：{$topic.chair_count}</div>
                                    {if $topic.option_info neq ''}
                                        {foreach key=optionid item=info from=$topic.option_info}
                                            <div style="margin-top:10px;">
                                                <div>{$info[1]}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;填写数：{$info[2]}</div>
                                                <div style="width: 100%;border: 1px solid #eee;">
                                                    <div class='progressbar' style="width: {$info[3]}%;background: #6abd3d;height:30px;line-height: 30px;padding: 0 5px;color: #fff;overflow:hidden;text-overflow: ellipsis;white-space: nowrap;{if $info[3]<10}color:#333;{/if}">
                                                    <span title="{$info[1]}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{$info[2]}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{$info[3]}%">{$info[3]}%</span></div>
                                                </div>
                                            </div>
                                        {/foreach}
                                    {else}
                                        {foreach key=optionid item=value from=$topic.topic_option_array}
                                        {$value['topicoption']}
                                        <div style="width: 100%;border: 1px solid #eee;">
                                            <div class='progressbar' style="width: 0%;background: #6abd3d;height:30px;line-height: 30px;padding: 0 5px;color: #fff;color:#333;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0%</div>
                                        </div>
                                        <br>
                                        {/foreach}
                                    {/if}
                                {/if}
                            </div>
                        </div>
                        {assign var=i value=$i+1}
                    {/foreach}
                    </div>
                {/foreach}
            {else}
                <div style="padding: 12px;width: 100%;text-align: center;">暂无数据</div>
            {/if}
        </div>
    </div>
</div>