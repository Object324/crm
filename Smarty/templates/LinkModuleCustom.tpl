<!--修改编码格式:统一编码：UTF-8-->
{if $IFRAMEURL neq ''}
    <iframe src="{$IFRAMEURL}" frameborder="0" width="100%" height="100%"></iframe>
{else}
{*   url为空所以发生错误*}
    {'error'|@getFixedLabel}
{/if}