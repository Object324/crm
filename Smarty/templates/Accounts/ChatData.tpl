
<div class="conversation-content" id="wechatSession_content">
    {if empty($weChatDatas)}
        <div style="text-align:center;">{'NONE'|@getFixedLabel}</div>
    {else}
        {foreach item=chatDatas from=$weChatDatas}
            <div class="conversation-content-item">
                <input type="hidden" name="record" value="{$chatDatas.id}"/>
                <div class="conversation-item-first">{$chatDatas.fromid}<span>{$chatDatas.msgtime}</span></div>
                {if $chatDatas.content neq ''}
                    <div class="conversation-item-second">{$chatDatas.content}</div>
                {/if}
                {if $chatDatas.filepath neq ''}
                    {if $chatDatas.msgtype eq 'image'}
                        <div class="conversation-item-second">
                            <div onclick="WechatSession.prototype.preview(this);">
                                <img src="{$chatDatas.filepath}" style='width: 100px;cursor:pointer;'/>
                            {if $chatDatas.upload_way == 'cos'}
                                <!-- <button onclick="WechatSession.download(this)" filepath="{$chatDatas.filepath}" filename="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</button> -->
                                <a href="javascript:;" onclick="WechatSession.prototype.download(this)" filepath="{$chatDatas.filepath}" filename="{$chatDatas.filename}" target="_blank">{'DOWNLOAD'|@getFixedLabel}</a>
                            {else}
                                <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>
{*                                <a href="{$chatDatas.filepath}" target="_blank">{'PREVIEW'|@getFixedLabel}</a>*}
                            {/if}
                            </div>
{*                            <button onclick="WechatSession.preview(this)" value="{$chatDatas.filepath}"  msgid="{$chatDatas.msgid}" sessionid="{$chatDatas.id}">{'PREVIEW'|@getFixedLabel}</button>*}
{*                            <a href="javascript:;" onclick="WechatSession.prototype.preview(this)" filepath="{$chatDatas.filepath}"  msgid="{$chatDatas.msgid}" sessionid="{$chatDatas.id}">{'PREVIEW'|@getFixedLabel}</a>*}


                        </div>

                    {elseif $chatDatas.msgtype eq 'video'}
                        <div class="conversation-item-second">
                            <video width="100" controls  height="200">
                                <source src="{$chatDatas.filepath}" type="video/mp4">
                                <source src="{$chatDatas.filepath}" type="video/ogg">
                                您的浏览器不支持 video 标签。
                            </video>
                            <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>
                        </div>
                    {elseif $chatDatas.msgtype eq 'voice'}
                        <div class="conversation-item-second" style="width: {$chatDatas.play_length*3+60}px;border: 1px solid #e5e5e5;border-radius: 5px;color: #666;font-size: 14px;line-height: 26px;">
                            <a href="javascript:;" id="" onclick="WechatSession.prototype.plays(this)" value="{$chatDatas.filepath}" style="text-decoration: none;color: #666;">
                                <div style="cursor: pointer;">
                                    <img src="themes/softed/images/voice.png" style="width: 20px;margin: 4px 5px;vertical-align: middle;">
                                    <span>{$chatDatas.play_length}"</span>
                                </div>
                            </a>

{*                            <a href="javascript:;" id="" onclick="WechatSession.prototype.plays(this)" value="{$chatDatas.filepath}">{'PLAYER'|@getFixedLabel}</a>*}
                            {*<audio style='width: 200px;' controls="controls">
                                <source src="{$chatDatas.filepath}" type="audio/ogg">
                                <source src="{$chatDatas.filepath}" type="audio/mpeg">
                                您的浏览器不支持 audio 标签。
                            </audio>*}
{*                            <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>*}
                        </div>
                    {elseif $chatDatas.msgtype eq 'file'}
                        <div>
                            {$chatDatas.filename}
                            {if $chatDatas.upload_way == 'cos'}
                                <a href="javascript:;" onclick="WechatSession.prototype.download(this)" filepath="{$chatDatas.filepath}" filename="{$chatDatas.filename}" target="_blank">{'DOWNLOAD'|@getFixedLabel}</a>
                            {else}
                                <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>
                            {/if}
                        </div>
                    {/if}
                {elseif in_array($chatDatas.msgtype,array("image",'video','voice','file'))}
                    加载中
                {/if}
            </div>
        {/foreach}
    {/if}
</div>