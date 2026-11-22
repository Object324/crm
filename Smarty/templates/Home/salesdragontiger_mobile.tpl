{*移动端--常用模块组件内容*}
<div class="ld-stuff-content">
{*    龙虎榜指标，龙虎榜排序方式*}
    <div class="ld-flex-between">
        <div class="ld-flex-start"><div>新增服务合同额</div><div><img class="marB4 marL5" style="height:13px;width: 13px;" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/2023/choosenicon.png"></div></div>
        <div class="ld-flex-start"><div>排名从高到低</div><div><img class="marB4 marL5" style="height:13px;width: 13px;" src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/2023/sort_icon2.png"></div></div>
    </div>
{*    内容*}
    <div class="marT10">
        {foreach key=index item=row from=$HOME_STUFF}
        <div class="ld-flex-between pad10">
            <div class="ld-flex-start">
                <div class="marR10"><img src="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/wx_images/2023/{$index+1}_2023_2.png"></div>
                <div>
                    <div style="font-size:10px;color:#ccc;"><b style="color:#666;font-size: 14px;">{$row['last_name']}</b> {$row['groupname']}</div>
                    <div class="marT5" style="width:{$row['percent']}%;height:8px;background: linear-gradient(to right, #38C3A1, #8ED2C5);border-radius: 4px;"></div>
                </div>
            </div>
            <div style="color:#1A6CDA !important;text-align: right;"><p>{$row['count']}</p></div>
        </div>
        {/foreach}
    </div>
</div>