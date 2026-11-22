<div class="widget-content">
    <div class="assembly-content" style="">
        {foreach item=row from=$HOME_STUFF['Details']}
        <div class="{if $HOME_STUFFID==47||$HOME_STUFFID==64||$HOME_STUFFID==65}short{else}long{/if} report-list-one report-hover" reportlabel='{$row['label']}' module='{$row['module']}' data-stuffid="{$HOME_STUFFID}" pageurl='index.php?pageto_module={$row['module']}&pageto_action=index' {if $HOME_STUFFID==46||$HOME_STUFFID==47||$HOME_STUFFID==52||$HOME_STUFFID==54}onclick="setSalesTragetUrl('{$row.stufflabel}',ld(this))"{/if}>
            <div class="report-icon">
                <img style="width:40px;" src="themes/icon2021/crm/{$row['back_img']}"/>
            </div>
            <div class="report-right">
                <div class="report-title">{$row['name']}</div>
                <div title="{$row['nums']}" class="report-nums">{$row['prefix']}{$row['nums']}</div>
            </div>
        </div>
        {/foreach}
    </div>
</div>
