﻿<div id="HelpDeskHistory">
{if $COUNT >= 1}
<!--分页-->
  <div class="PageDiv0" style="padding:0px 5px 10px 5px;margin-top:0px; ">
  	<div class="ld-flex-start">
    	<div class="ld-pagenum-div">{$recordListRange}</div>
        {$NAVIGATION}
    </div>
  </div>
  <!--分页  end-->
{/if}
{$TABLE}
</div>
