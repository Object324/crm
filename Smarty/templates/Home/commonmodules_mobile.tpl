{*移动端--常用模块组件内容*}
<div class="ld-stuff-content" style="height:212px;">
    {foreach item=row from=$HOME_STUFF}
        <div class="ld-stuff-item" style="width:25%;">
            <div style="width:35px;height:35px;margin: 0 auto;"><img style="height:100%;width:100%;" src="{$row['icon']}"></div>
            <div style="height:42px;margin-top:5px;">{$row['label']}</div>
        </div>
    {/foreach}
    <div class="ld-stuff-item" style="width:25%;">
        <div style="width:35px;height:35px;margin: 0 auto;"><img style="height:100%;width:100%;" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/crm2022/crm_more.png"></div>
        <div style="height:42px;margin-top:5px;">更多</div>
    </div>
</div>