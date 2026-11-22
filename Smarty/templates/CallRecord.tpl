<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/CallRecordSetting.js?v={$GLOBALMINVERSION}"></script>
<div id="divFileCallButlerlist" style="display:none;"></div>

<div class="ld-callrecord-list">
    <div class="topnews">
        <div class="box">
            {if count($CallRecordinfos) > 0}
                <ul class="event_list">
                    {foreach item=CallRecordinfo from=$CallRecordinfos}
                        <div>
                            <h3>{$CallRecordinfo.title}</h3>
                            {foreach item=CallRecord from=$CallRecordinfo.list}
                                <div class="div_phonecall">
                                    <div class="div_phonecall-icon"></div>
                                    {if $CallRecord.calltype eq "去电"}
                                        <div class="div_phonecall-text">{$CallRecord.username} {'Called'|@getFixedLabel} <span style="color: #161616;font-weight:bolder">{$CallRecord.recordlabel}</span></div>
                                    {else}
                                        <div class="div_phonecall-text">{$CallRecord.username} {'Answered'|@getFixedLabel} <span style="color: #161616;font-weight:bolder">{$CallRecord.recordlabel}</span> {'sPhoneCall'|@getFixedLabel}</div>
                                    {/if}
                                    <span style="margin-left: 20px;">{$CallRecord.time}</span>
                                </div>
                                <li>
                                    <div class="div_p">
                                        <div class="div_span">
                                            <div class="">{'Phone'|@getFixedLabel}：<span style="color: #272727;">{$CallRecord.phone}</span></div>

                                            <div style="display: flex;align-items:end;">
                                                <div class="callrecord-player_box" style="width: 300px;">
                                                    {if $CallRecord.filepath neq ''}
                                                        <div class="callrecord-player_waveform" style="background: url({$CallRecord.waveform}) 0px 0 no-repeat;"></div>
                                                        <div class="callrecord-player_time">{$CallRecord.talktime}</div>
                                                        <div class="callrecord-player_play tip-items-list" onclick="CallRecordSetting.getInstance().playClick(this,'{$CallRecord.filepath}')" data-tip="{'PLAYER'|@getFixedLabel}" data-direction="top" data-type="position"></div>
                                                        <a class="callrecord-player_download tip-items-list" href ="{$CallRecord.filepath}" download="" target = "_blank" data-tip="{'DOWNLOAD'|@getFixedLabel}" data-direction="top" data-type="position"></a>
                                                    {else}
                                                        <div class="callrecord-player_waveform empty"></div>
                                                        <div class="callrecord-player_time">00:00</div>
                                                        <div class="callrecord-player_play empty tip-items-list" data-tip="录音为空" data-direction="top" data-type="position"></div>
                                                        <a class="callrecord-player_download empty tip-items-list" download="" target = "_blank" data-tip="录音为空" data-direction="top" data-type="position"></a>
                                                    {/if}
                                                </div>
                                                {if count($CallRecord.relatedcreate) gte 1}
                                                    <a href="javascript:void(0);" class="Anu3_a callrecord-relatedcreate" onclick="related_add_url('{$CallRecord.relatedcreate.url}','{$CallRecord.relatedcreate.frommodule}','{$CallRecord.relatedcreate.module}','{$CallRecord.relatedcreate.record}')">
                                                        {'WRITEFOLLOWUP'|@getFixedLabel}
                                                    </a>
                                                {/if}
                                            </div>
                                        </div>
                                    </div>
                                </li>
                            {/foreach}
                        </div>
                    {/foreach}
                </ul>
            {else}
                <div id="callrecord-norecords" align="center">
                    {include file="NoRecords.tpl"}
                </div>
                <script>
                    var popupobj = CrmPopup.getPopupObj("last");
                    ld('#'+popupobj.divid).find('#callrecord-norecords').css('height',ld('#'+popupobj.divid).find('.DivCTable').css('max-height'));
                </script>
            {/if}
        </div>
    </div>
</div>
