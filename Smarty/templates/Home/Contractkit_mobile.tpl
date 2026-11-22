{*移动端--常用模块组件内容*}
<div class="ld-stuff-content">
    {foreach item=row from=$HOME_STUFF}
        <div class="ld-flex-start padTB10" style="border-bottom: 1px solid #e5e5e5;width: 100%;">
            <div style="width:20%">
                <div><img style="width:24px;height:24px;margin:0 auto;" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/2023/{$row['imgname']}"></div>
                <div>{$row['name']}</div>
            </div>
            {foreach item=item from=$row['list']}
                <div style="width:40%">
                    <div style="text-align: left;height:24px;font-size: 15px;color: #1A6CDA;font-weight: 600;">{$item['content']}</div>
                    <div style="text-align: left;">{$item['describe']}</div>
                </div>
            {/foreach}
        </div>
    {/foreach}
</div>