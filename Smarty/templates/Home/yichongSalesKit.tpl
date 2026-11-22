<div class="widget-content">
    <ul class="salekit-list">
        {foreach item=row from=$HOME_STUFF}
        <li class="salekit-item-yichong" style="width:33.33%;">
            <div class="item-info j-toBiSale hover">
                <div class="item-info-c">
                    <div style="text-align: center;" class="item-info-l" reportlabel='{$row[0]['label']}' module='{$row[0]['module']}' data-stuffid="{$HOME_STUFFID}" pageurl='index.php?pageto_module={$row[0]['module']}&pageto_action=index'  onclick="setSalesTragetUrl('{$row[0]['label']}',ld(this))">
                        <div class="item-title item-title-div" title="{$row[0].name}">{$row[0].name}</div>
                        <div class="item-amout item-title-div" title="{$row[0].nums}">
                          <span>{$row[0].nums}</span>
                        </div>
                    </div>
                    <div class="item-info-r" reportlabel='{$row[1]['label']}' module='{$row[1]['module']}' data-stuffid="{$HOME_STUFFID}" pageurl='index.php?pageto_module={$row[1]['module']}&pageto_action=index'  onclick="setSalesTragetUrl('{$row[1]['label']}',ld(this))">
                        <div class="item-title item-title-div" title="{$row[1].name}">{$row[1].name}</div>
                        <div class="item-amout item-title-div" title="{$row[1].nums}">
                          <span>{$row[1].nums}</span>
                        </div>
                    </div>
                </div>
            </div>
        </li>
        {/foreach}
    </ul>
</div>