<div class="trendview">
    <div class="topnews"
    <div class="box">
      <ul class="event_list">
        {foreach item=Trendinfo from=$Trendinfos}
        <div>
          <h3>{$Trendinfo.title}</h3>
            {foreach item=Trend from=$Trendinfo.list}
            <li>
            <div class="div_p">
              <div class="div_span">
                <div class="">
                {if $Trend.frommodule neq 'Users' && $Trend.frommodule neq ''}
                <div style="float: left;margin-right: 20px;">{$Trend.frommodule|getTranstab}</div>
                <a module="{$Trend.frommodule}" record="{$Trend.record}" 
                  href="index.php?pageto_module={$Trend.frommodule}&pageto_action=index&pageto_record={$Trend.record}" 
                  onclick="ListLinkClick(ld(this),event)"  title="{$Trend.lastname}">{$Trend.lastname}
                  </a>
                {else}
                {$Trend.lastname}    
                {/if}
                <span>{$Trend.time}</span></div>
                <div>{$Trend.title}<b class="">{$Trend.link}</b></div>
                <div class="text_word_brea fontsize06" >{$Trend.content}</div>
              </div>
            </div>
            </li>
            {/foreach}
        </div>
        {/foreach}
      </ul>
    </div>
    </div>
</div>