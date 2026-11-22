<div class="trendview">
    <div class="topnews" <div class="box">
        <ul class="event_list">
            {foreach item=Trendinfo from=$Trendinfos}
                <div>
                    <h3>{$Trendinfo.title}</h3>
                    {foreach item=Trend from=$Trendinfo.list}
                        <li>
                            <div class="div_p">
                                <div class="div_span">
                                    <div class="">{$Trend.lastname} <span>{$Trend.time}</span></div>
                                    {if $Trend.type eq 'signin'}
                                        {foreach item=value from=$Trend.list}
                                            <div class="ld-wordwrap-listcontent">{$value}</div>
                                        {/foreach}
                                        <div class="weui-uploader weui-uploader-sign">
                                            <div class="weui-uploader__bd">
                                                <ul class="weui-uploader__files">
                                                    <li class="weui-uploader__file">
                                                        {foreach item = value from=$Trend.img_list}
                                                            <img src="{$value.img}" onclick="previewImage(this)">
                                                        {/foreach}
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    {else if $Trend.relatemodule neq ''}
                                        <div class="ld-wordwrap-listcontent">{$Trend.title}
                                            <a module="{$Trend.relatemodule}" record="{$Trend.secid}"
                                                href="index.php?pageto_module={$Trend.relatemodule}&pageto_action=index&pageto_record={$Trend.secid}"
                                                onclick="ListLinkClick(ld(this),event)" title="{$Trend.link}">{$Trend.link}
                                            </a>
                                        </div>
                                        <div class="text_word_brea fontsize06 ld-wordwrap-listcontent">{$Trend.content}</div>
                                    {else}
                                        <div class="ld-wordwrap-listcontent">{$Trend.title}<b class="">{$Trend.link}</b></div>
                                        <div class="text_word_brea fontsize06 ld-wordwrap-listcontent">{$Trend.content}</div>
                                    {/if}
                                </div>
                            </div>
                        </li>
                    {/foreach}
                </div>
            {/foreach}
        </ul>
    </div>
</div>