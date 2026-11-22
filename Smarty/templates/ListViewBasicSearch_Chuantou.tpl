{*穿透弹窗的基本查找组件*}
<div id="basicsearchcolumns_real" style="width:112px;">
    {*onchange事件  去获取基本查找历史*}
    <select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth100 overflow-space" style="border-radius: 4px 0 0 4px;border-right:none;" >
        {html_options  options=$SEARCHLISTHEADER selected=$SEATCH_INPUT.search_field}
    </select>
</div>
<div class="ld-listview-basicsearch">
    <!--zxm 20230807 升级到"客户" 搜索的时候 会从双引号处截断 所以加htmlspecialchars处理-->
<input type="text" class="commonSelectPop gwidth100 padR40" id="search_text" name="search_text" value="{if !empty($SEATCH_INPUT.search_text)}{$SEATCH_INPUT.search_text|htmlspecialchars}{/if}" autocomplete="off" style="border-radius: 0 4px 4px 0;padding-right:40px;">
    <b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" id="clearsearch"></b>
    <b class="categorysear-search ld-listview-search" id="callsearch"></b>
    <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
        <ol class="D_more_menua" id="basicSearchList">
        </ol>
    </div>
</div>
