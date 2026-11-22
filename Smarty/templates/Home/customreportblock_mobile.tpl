{*移动端--常用模块组件内容*}
<div class="ld-stuff-content" style="height:212px;">
    {foreach item=row from=$HOME_STUFF}
    <div class="ld-flex-start padTB10" style="border-bottom: 1px solid #e5e5e5">
        <div>{$row['tabname']}</div>
    </div>
    {/foreach}
</div>