{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
{foreach key=blockid item=block from=$data['blockinfo']}
    <div>
    {if $block.blocktype != 'virtual'}
        <div id="block_{$blockid}" style="height: 50px;font-size: 28px;font-weight: bold;line-height: 50px;margin: 4px 0 12px;color: #333;">
            {$block.blockname}
        </div>
    {/if}
    {assign var=i value=1}
    {foreach key=topicid item=topic from=$block['topic_array']}
        <div topic_id="{$topic.topicid}" class="Q_Content" style="margin-left: 20px">
            {if $topic.topic_type == 'text'}
                <div id="show_{$topic.topicid}" class="">
                    {$topic.topic_name}
                </div>
                {assign var=i value=$i-1}
            {else}
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
            {/if}
            {if $topic.topic_type == 'one' || $topic.topic_type == 'more'}
                <div class="answer select-input">
            {elseif $topic.topic_type == 'Singleline' || $topic.topic_type == 'tel'}
                <div class="answer text-input ld-form-item-content">
            {elseif $topic.topic_type == 'SelectBill'}
                <div class="answer ld-form-item-content" style="max-width: 400px;width: 95%;">
            {elseif $topic.topic_type == 'Multiline'}
                <div class="answer textarea-input">
            {/if}

            {if $topic.topic_type == 'one'}
                {foreach key=optionid item=value from=$topic.topic_option_array}
                    <input type="radio" name="one_{$topic.topicid}" optionid="{$optionid}" value="{$topic.topicid},{$optionid},{$value.topicoption}" id="{$topic.topicid}_{$optionid}">
                    <label for="{$topic.topicid}_{$optionid}">{$value.topicoption}</label>
                    <br>
                {/foreach}
                </div>
            {elseif $topic.topic_type == 'more'}
                {foreach key=optionid item=value from=$topic.topic_option_array}
                    <input type="checkbox" name="more_{$topic.topicid}[]" optionid="{$optionid}" value="{$topic.topicid},{$optionid},{$value.topicoption}" id="{$topic.topicid}_{$optionid}">
                    <label for="{$topic.topicid}_{$optionid}">{$value.topicoption}</label>
                    <br>
                {/foreach}
                </div>
            {elseif $topic.topic_type == 'Singleline'}
                <input fieldonly="0" type="text" name="Singleline_{$topic.topicid}" id="Singleline_{$topic.topicid}" value="" class="ld-input-inner" placeholder="请输入" style="line-height: 100%;height: 35px;">
                </div>
            {elseif $topic.topic_type == 'Multiline'}
                <textarea name="Multiline_{$topic.topicid}" id="Multiline_{$topic.topicid}" value="" placeholder="请输入" class="ld-textarea-inner"></textarea>
                </div>
            {elseif $topic.topic_type == 'SelectBill'}
                <input readonly="" name="SelectBill_{$topic.topicid}" id="SelectBill_{$topic.topicid}" type="text" fieldonly="0" class="ld-input-inner ld-input-inner-add" value="" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;padding-right: 8px; line-height: 100%;height: 35px;">
                <input name="SelectBillId_{$topic.topicid}" id="SelectBillId_{$topic.topicid}" referencemodule="{$topic.topic_other_info.referencemodule}" type="hidden" value="">
                <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist({$topic.topicid},'{$topic.topic_other_info.referencemodule}');">+</a>
                {* <input class="Q_Content_clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" style="top: -2px;" onclick="clearinput({$topic.topicid});"> *}
                <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearinput({$topic.topicid});">+</a>
                </div>
            {elseif $topic.topic_type == 'tel'}
                <input fieldonly="0" type="text" name="tel_{$topic.topicid}" id="tel_{$topic.topicid}" value="" class="ld-input-inner" placeholder="请输入" style="line-height: 100%;height: 35px;">
                </div>
            {/if}
        {*ls 20221028 BUG0058138 错位了 放到这里 text类型的 会多出来一个</div>，因此需要移到if条件里*}
        </div>
        {assign var=i value=$i+1}
    {/foreach}
    </div>
{/foreach}