<div class="ld-stuff-content ld-stuff-content-second">
    {foreach item=saleskitinfo from=$HOME_STUFF}
    <div class="ld-stuff-item" style="width:calc(100%/{$COLCOUNT});">
        {include file="Home/SaleskitContent.tpl"}
    </div>
    {/foreach}
</div>