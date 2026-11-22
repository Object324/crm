<!--修改编码格式:统一编码：UTF-8-->
<div id="RemindsCenterPagination" class="ld-remindscenter-list-pagination">
    <div class="PageDiv0">
        <div class="ld-flex-start">
            <div class="ld-pagenum-div">{$recordListRange}</div>
            {$NAVIGATION}
        </div>
    </div>
</div>
<div id="RemindsCenterLine" style="width: 90%;height: 1px;background-color: #EEEEEE;margin: 5px auto;"></div>
<div id="RemindsCenterList" class="ld-remindscenter-list-section">
    <div class="ld-remindscenter-list-content">

        {foreach key=index item=data from=$ListData}
            <div class="ld-remindscenter-list-content-block" name="remindslistclick" module="Reminds" record="{$data.remindsid}" data-status="{$data.status}" data-tip="{'ClickToViewDetail'|@getFixedLabel}" onmouseenter="tooltip.bind(this)">
                <div >
                    <div class="ld-remindscenter-list-content-block-icon"></div>
                    {if $data.status eq 'unread'}<b class="ld-remindscenter-list-content-block-unread"></b>{/if}
                </div>
                <div class="ld-remindscenter-list-content-block-text">
                    <span class="remindscontent">{$data.content}</span>
                    <span class="related_to_record">{$data.related_to}</span>
                    <span class="reminds_date_time">{$data.date_time} &nbsp; {'Sender2'|@getFixedLabel}：{$data.creator}</span>
                </div>
            </div>
            <div id="" style="width: 90%;height: 1px;background-color: #EEEEEE;"></div>
        {/foreach}
                
    </div>
</div>