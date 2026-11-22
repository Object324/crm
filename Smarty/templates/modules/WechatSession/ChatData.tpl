{if !empty($chatdataLists)}
    {foreach item=chatDatas from=$chatdataLists}
        <input type="hidden" name="id" value="{$chatDatas.id}">
        <div class="weui-cells weui-cells-left {if {$chatDatas.leftorright} eq 'right'}weui-cells-right{/if}">
            <div class="weui-cell">
                {if {$chatDatas.leftorright} eq 'left'}
                    <div class="weui-cell__hd">
                        <img src="{$chatDatas.imagepath}">
                    </div>
                    <div class="weui-cell__bd">
                        <p>{$chatDatas.last_name}</p>
                        <p>{$chatDatas.msgtime}</p>
                    </div>
                {else}
                    <div class="weui-cell__bd">
                        <p>{$chatDatas.last_name}</p>
                        <p>{$chatDatas.msgtime}</p>
                    </div>
                    <div class="weui-cell__hd">
                        <img src="{$chatDatas.imagepath}">
                    </div>
                {/if}
            </div>
            <div class="{if $chatDatas.msgtype neq 'voice'}talk-record-left {if {$chatDatas.leftorright} eq 'right'}talk-record-right{/if} {else}talk-voice-left {if {$chatDatas.leftorright} eq 'right'}talk-voice-right{/if}{/if}"    {if $chatDatas.msgtype eq 'voice'} style="width: {$chatDatas.play_length*3+60}px;" {/if}>
                {if $chatDatas.msgtype eq 'text'}
                    {$chatDatas.content}
                {elseif in_array($chatDatas.msgtype,array("image",'video','voice','file'))}
                    {if $chatDatas.filepath eq ''}
                        加载中
                    {elseif $chatDatas.msgtype eq 'image'}
                        <div onclick="WechatSessionobj.ChatDataListobj.preview(this);">
                            <img style="cursor:pointer" alt=""  src="{$chatDatas.filepath}" {*width="100" height="100"*}>
                        </div>
                    {elseif $chatDatas.msgtype eq 'video'}
                        <div>
                            <video width="100" controls  height="200">
                                <source src="{$chatDatas.filepath}" type="video/mp4">
                                <source src="{$chatDatas.filepath}" type="video/ogg">
                                nonsupport video
                            </video>
                            <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>
                        </div>
                    {elseif $chatDatas.msgtype eq 'voice'}
                        <a href="javascript:;" id="" onclick="WechatSession.prototype.plays(ld(this))" value="{$chatDatas.filepath}" style="text-decoration: none;color: #666;">
                            <div style="cursor: pointer;">
                                    <img src="themes/softed/images/voice.png">
                                    <span>{$chatDatas.play_length}"</span>
                            </div>
                        </a>
                            {*<a href="javascript:;" id="" onclick="WechatSession.prototype.plays(this)" value="{$chatDatas.filepath}">{'PLAYER'|@getFixedLabel}</a>*}
                            {*<audio style='width: 200px;' controls="controls">
                                <source src="{$chatDatas.filepath}" type="audio/ogg">
                                <source src="{$chatDatas.filepath}" type="audio/mpeg">
                                您的浏览器不支持 audio 标签。
                            </audio>*}
                            {*<a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>*}
                    {elseif $chatDatas.msgtype eq 'file'}
                        <div>
                            {$chatDatas.filename}
                            {if $chatDatas.upload_way == 'cos'}
                                <a href="javascript:;" onclick="WechatSession.prototype.download(this)" filepath="{$chatDatas.filepath}" filename="{$chatDatas.filename}" >{'DOWNLOAD'|@getFixedLabel}</a>
                            {else}
                                <a href="{$chatDatas.filepath}" target="_blank" download="{$chatDatas.filename}">{'DOWNLOAD'|@getFixedLabel}</a>
                            {/if}
                        </div>
                    {/if}
                {elseif $chatDatas.msgtype eq 'link'}
                    <div>
                        <a class="weui-cell" href="{$chatDatas.link_url}" target="_blank">
                            <div class="weui-cell__bd">
                                <p>{$chatDatas.title}</p>
                                <p style="font-size: 13px;color: #888888;">{$chatDatas.description}</p>
                            </div>
                            {if $chatDatas.image_url neq ''}
                                <div class="weui-cell__hd" style="margin-right: 10px;">
                                    <img src="{$chatDatas.image_url}" style="width: 50px;display: block">
                                </div>
                            {/if}
                        </a>
                    </div>
                {else}
                    【未知消息类型】
                {/if}
            </div>
        </div>
    {/foreach}
{else}
    <div class="no_data">{'NoRecordsFound'|@getFixedLabel}</div>
{/if}