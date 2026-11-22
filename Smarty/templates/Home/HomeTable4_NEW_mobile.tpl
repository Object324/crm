{*移动端--常用模块组件内容*}
<div class="ld-stuff-content">
    {foreach item=row from=$HOME_STUFF}
        <div class="ld-flex-start padT10B10" style="border-bottom: 1px solid #e5e5e5">
            <div style="width:20%">
                <div><img style="width:32px;height:32px;margin:0 auto;" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/crm2022_2/{$row['icon']}"></div>
            </div>
            <div style="width:40%">
                <div style="text-align: left;">{$row['label']}</div>
                <div style="text-align: left;height:32px;font-size: 15px;color: #1A6CDA;font-weight: 600;">{$row['value']}</div>
            </div>
            <div style="width:40%">
                <div class="ld-flex-start" style="text-align: left;">
                    <div style="width:50px;">{$row['beforelabel']}</div>
                    <div style="width:50px;padding:0 5px;height:16px;border-radius:4px;background: linear-gradient(to right, #38C3A1, #8ED2C5);">{$row['percent']}</div>
                </div>
                <div style="text-align: left;height:32px;font-size: 15px;color: #1A6CDA;font-weight: 600;">{$row['beforevalue']}</div>
            </div>
        </div>
    {/foreach}
</div>

