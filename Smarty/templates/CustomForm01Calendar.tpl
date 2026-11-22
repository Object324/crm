<link type="text/css" href="{$CSSURL}themes/softed/coordination.css" rel="stylesheet" />
<style>
    .wh_item_date{
        height:30px;
        width:30px;
    }
    .wh_top_tag_spot{
        
    }
    .calendar-content-list ul{
        overflow: auto;
    }
    .calendar-content-list .schedule-item .content {
        font-size: 14px;
        font-weight: bold;
        margin-bottom: 5px;
    }
    .calendar-content-list .schedule-item .date {
        color: #999;
        font-size: 14px;
    }
    .calendar-content-list li {
        margin-bottom: 10px;
        margin-top: 5px;
    }
</style>
<div id="{$MODULE}_calendardiv" style="width:100%;display:flex;">
    <div id="{$MODULE}_calendardivleft" style="width:50%;border-right:1px solid #eee;">
        <div class="work-calendar">
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
                        <div class="wh_content wh_content_days">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="work-calendar" style="width:100%;">
        <div class="calendar-header-list" style="width:100%;font-size: 18px;margin-left: 5px;">
            {$clickDateLabel}
        </div>
        <div class="calendar-content-list" style="width:100%;">
            <p class="line"></p>
        {$rightcontent}
        </div>
    </div>
</div>
<script>
    //wym 240105 BUG0077547 PC端日历界面。右侧高度计算有问题，没有显示所有数据。
    if(ld('#pagecontent1').length>0){ //整个列表页面高度
        var pageheight = ld('#pagecontent1').height();
    }else{
        var pageheight = 800;
    }
    var minus_height = 0;
    if(ld('.main_grid_top').length>0){ //列表页面按钮高度
        minus_height += ld('.main_grid_top').height();
    }
    if(ld('#listviewpagination').length>0){ //翻页高度
        minus_height += ld('#listviewpagination').height();
    }
    minus_height += 61; //右侧日程列表标题固定高度
    ld('.calendar-content-list ul').css('height',pageheight-minus_height);
    ld('.calendar-content-list ul').css('max-height',pageheight-minus_height);
</script>

