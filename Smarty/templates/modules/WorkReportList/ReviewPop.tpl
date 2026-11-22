<div class="wrapper-panel-inner"> <link type="text/css" href="themes/softed/coordination.css" rel="stylesheet">
    <script type="text/javascript">
        var current_language = "zh";
        AjaxJSPage("Coordination_js",'include/js/modules/Home/Coordination.js');
    </script>
</div>
{*//ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(“现在点评"弹出层)*}
<script type="text/javascript" src="{$JSURL}include/js/modules/{$MODULE}/{$MODULE}.js"></script>
<!-- 点评弹出层 -->
<input type="hidden" name='record' value="{$RECORD}">
<div id="dialogDiv" style="width:500px;top:512px;">
    <div class="popup-centent ui-popup-centent">
        <p class="dialog-l-tit">
            <img src="{$detailData['userimage']}" alt="" width="30" height="30" class="name-img">
            <span class="name">{$detailData['usercreator']}</span><span class="content_dis">的{$detailData['typelabel']}原文</span>
            (<span class="aj-ctime">{$detailData['createdtime']}</span>)
        </p>
        <div class="comment-feedcontent">
            {foreach  item=columninfo from=$ShowSpecialColumnInfo}
                <p class="work-tit" tag="{$columninfo.columnname}">{$columninfo.fieldlabel}</p>
                <div class="content-text writeexperience"
                     style="-webkit-user-select: text !important;-moz-user-select: text !important;-ms-user-select: text !important;">
                    {$columninfo.value}
                </div>
                <br/>
            {/foreach}
        </div>
        <p>
            <textarea class="input-text" placeholder="添加回复..."
                      style="overflow: hidden; word-wrap: break-word; resize: none; height: 94px;"></textarea>
        </p>
        <div class="CCrange selectbar" style='width:458px;margin-top:10px;margin-bottom:10px;' tag='dialog'>
            <ul class="reader-bar-list">
            </ul>
            <span class="input-tip"><i class="prefix">+</i>{'SELECTCCRANGE'|@getFixedLabel}</span>
            <input class="input-field ui-hide" type="text" autocomplete="off" value=''>
            <span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
        </div>
        <div>
            评分
            <select class="commenton-select">
                <option value="5">五分：非常满意</option>
                <option value="4">四分：超过预期</option>
                <option value="3" selected="selected">三分：符合要求</option>
                <option value="2">二分：不合格</option>
                <option value="1">一分：严重批评</option>
            </select>
        </div>
    </div>
</div>
