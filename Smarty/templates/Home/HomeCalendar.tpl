<link type="text/css" href="{$CSSURL}themes/softed/coordination.css" rel="stylesheet" />
<script>
 
	// @edit:zxm,2020-09-09,reason:日程管理js引入
	AjaxJSPage("Coordination_js",'include/js/modules/Home/Coordination.js');
 
</script>
<style>
    .wh_item_date{
        height:30px;
        width:30px;
    }
    .wh_top_tag_spot{
        
    }
    .calendar-content-list ul{
        overflow: hidden;
    }
</style>
<div style="width:100%;height:auto;">
    <div style="width:100%;height:auto;overflow-y: auto;">
        <div class="work-calendar" style="padding-bottom: 0px">
            <div class="calendar-content">
                <div class="wh_container">
                    <div class="wh_content_all">
                        <div class="wh_top_changge">
                            <li>
                                <div class="wh_jiantou1"></div>
                            </li>
                            <li class="wh_content_li"></li>
                            <li>
                                <div class="wh_jiantou2"></div>
                            </li>
                        </div>
                        <div class="wh_content wh_content_weeks">
                        </div>
                        <div name="content_days" class="wh_content wh_content_days">
                        </div>
                        <div name="click_hide_show" class="wh_content wh_click_hide_show">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="work-calendar" style="width:100%;overflow: hidden;height:auto;padding-top: 0px">
        <div class="calendar-content-list" style="width:100%;">
        </div>
    </div>
</div>

