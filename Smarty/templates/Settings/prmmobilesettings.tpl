<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Home.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Settings/mobile_home_setting/MobileHomeBoard.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homestuff.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homeboard.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/MobileList.js?v={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cutImg.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/cropper.min.js"></script>
<link rel="stylesheet" href="themes/softed/cropper.min.css">
<link rel="stylesheet" href="themes/softed/cropperImg.css">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'prm_mobile_customization'|@getFixedLabel}
        </span>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        {include file='Settings/prmmobilesettings_content.tpl'}
    </div>
</div>
