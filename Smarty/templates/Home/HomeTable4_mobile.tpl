<div class="widget-content">
  <ul class="salekit-list">
    {foreach item=row from=$HOME_STUFF}
      <li class="salekit-item">
        {if $cnt > 3}
          <div class="item-info j-toBiSale item-ico {$row.css} hover">
        {else if $cnt == 3}
          <div class="item-info j-toBiSale item-ico {$row.css} hover" style="width:80%;">
        {else if $cnt == 2}
          <div class="item-info j-toBiSale item-ico {$row.css} hover" style="width:50%;">
        {else if $cnt == 1}
          <div class="item-info j-toBiSale item-ico {$row.css} hover" style="width:30%;">
        {/if}
            <div class="item-info-c">
              <div class="item-info-l" searchtype='now' stufflabel='{$row.stufflabel}' pageurl='{$row.urls}' module='{$row.module}' onclick="setSalesTragetUrl('{$row.stufflabel}',ld(this))">
                <div class="item-amout item-title-div" title="{$row.value}">
                  <span pageurl='{$row.urls}' module='{$row.module}'>{$row.value}</span>
                </div>
                <div class="item-title item-title-div" title="{$row.curlabel}">{$row.curlabel}{$row.label}</div>
              </div>
              <div class="item-info-r" searchtype='last' stufflabel='{$row.stufflabel}' pageurl='{$row.urls}' module='{$row.module}' onclick="setSalesTragetUrl('{$row.stufflabel}',ld(this))">
                <div class="item-amout item-title-div" title="{$row.beforevalue}">
                  <span pageurl='{$row.urls}' module='{$row.module}'>{$row.beforevalue}</span>
                </div>
                <div class="item-title item-title-div" title="{$row.beforelabel}">
                  {$row.beforelabel}
                  {if $row.percentstatus == 'red'}
                    <b class="bg_red">{$row.percent}</b>
                  {else}
                    <b class="bg_green">{$row.percent}</b>
                  {/if}
                </div>
              </div>
            </div>
          </div>
      </li>
    {/foreach}
  </ul>
</div>