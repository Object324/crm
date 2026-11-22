<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <title>直接成本预算实际对照表</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <link rel="stylesheet" href="themes/softed/common.css" type="text/css" />
    <link rel="stylesheet" href="themes/softed/yichongreport.css" type="text/css" />
    <script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript">
        var language = "{$language}";
        var ld = $;
    </script>
    <script type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body>
<div class="report-content report-content-second">
    <form id="queryForm">
                <div class="search-bar">
        {*            <div class="search-one-text">*}
        {*                <label>项目编号:<input type="text" name="project_no" id="project_no" value="{$project_no}"></label>*}
        {*            </div>*}
        {*            <div class="search-one-text">*}
        {*                <label>客户名称:<input type="text" name="account_name" id="account_name" value="{$account_name}"></label>*}
        {*            </div>*}
                    <div class="search-one-text">
                        <label>开始日期:
                            <input type="hidden" value="{$request['start_time']}">
                            <input maxlength="25" size="15" name="start_time" value="{$request['start_time']}"  id="start_time" style="border:1px solid #bababa;width:150px;" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate"/>
                            <input type="hidden">
                        </label>
                    </div>
                    <div class="search-one-text">
                        <label>截止日期:
                            <input type="hidden" value="{$request['end_time']}">
                            <input maxlength="25" size="15" name="end_time" value="{$request['end_time']}"  id="end_time" style="border:1px solid #bababa;width:150px;" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate"/>
                            <input type="hidden">
                        </label>
                    </div>
                </div>
        <input type="hidden" name="search_date_custom_value" id="search_date_custom_value" value="{$request['search_date_custom_value']}">
        <div class="search-bar">
                        <div class="btn-search" onclick="searchSubmit('')">搜索</div>
            {*            <div class="btn-search" onclick="resetSearch()">重置</div>*}
            {*            <div class="btn-search" id="toExport" onclick="toExport(this)">导出</div>*}
            <div class="btn-page" style="display:flex;justify-content: flex-end">
                <div onclick="lastPage()" style="cursor:pointer;padding:0 4px;color:#666;line-height: 24px;margin-right:4px;">上页</div>
                <input id="curPage" name="page" style="width:50px;margin-right:4px;" type="text" value="{$page}">
                <div onclick="nextPage()" style="cursor:pointer;padding:0 4px;color:#666;line-height: 24px;">下页</div>
                <div style="line-height: 24px;">共<span id="total_pages">{$total_pages}</span>页</div><div style="line-height: 24px;">,共<span id="total_nums">{$total_nums}</span>条</div>
            </div>
        </div>
    </form>
    <div class="report-title">直接成本预算实际对照表</div>
    <div id="tblContent" style="overflow: auto">
        <table>
            <thead>
            <tr>
                <th rowspan="2">序号</th>
                <th rowspan="2">项目编号</th>
                <th rowspan="2">项目名称</th>
                <th colspan="3">材料</th>
                <th colspan="3">劳务</th>
                <th colspan="3">分包</th>
                <th colspan="3">租赁</th>
                <th colspan="3">项目小计</th>
            </tr>
            <tr>
                <th>计划金额</th>
                <th>实际金额</th>
                <th>差额</th>
                <th>计划金额</th>
                <th>实际金额</th>
                <th>差额</th>
                <th>计划金额</th>
                <th>实际金额</th>
                <th>差额</th>
                <th>计划金额</th>
                <th>实际金额</th>
                <th>差额</th>
                <th>计划金额</th>
                <th>实际金额</th>
                <th>差额</th>
            </tr>
            </thead>
            <tbody id="list">
            {foreach item=one from=$list}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr class="">
                        {else}
                    <tr class="lvtColDataBj">
                {/if}
                <td>{$one['no']}</td>
                <td>{$one['projectid']}</td>
                <td>{if {$one['projectid']}>0}<a target="_blank" href="index.php?pageto_module=Project&pageto_action=index&pageto_record={$one['projectid']}">{$one['projectname']}</a>{else}{$one['projectname']}{/if}</td>
                <td>{$one['plan_cailiao']}</td>
                <td>{$one['cailiao']}</td>
                <td {$one['gap_cailiao_style']}>{$one['gap_cailiao']}</td>
                <td>{$one['plan_laowu']}</td>
                <td>{$one['laowu']}</td>
                <td {$one['gap_laowu_style']}>{$one['gap_laowu']}</td>
                <td>{$one['plan_fenbao']}</td>
                <td>{$one['fenbao']}</td>
                <td {$one['gap_fenbao_style']}>{$one['gap_fenbao']}</td>
                <td>{$one['plan_zulin']}</td>
                <td>{$one['zulin']}</td>
                <td {$one['gap_zulin_style']}>{$one['gap_zulin']}</td>
                <td>{$one['plan_total']}</td>
                <td>{$one['total']}</td>
                <td {$one['gap_total_style']}>{$one['gap_total']}</td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>
</div>
<script type="text/javascript">

    ld('#tblContent').css('height', ld(window).height()-180);
    function toExport(obj)
    {
        ld(obj).text('导出中...');
        searchSubmit("&is_export=yes");
    }
    function resetSearch()
    {
        ld('#queryForm')[0].reset();
    }
    function lastPage(){
        var curPage = ld('#curPage').val();
        if(parseInt(curPage)<=1){
            return false;
        }else{
            curPage -= 1;
            ld('#curPage').val(curPage);
            searchSubmit("");
        }
    }
    function nextPage(){
        var curPage = ld('#curPage').val();
        var totalPages = ld('#total_pages').text();
        if(parseInt(curPage)>=parseInt(totalPages)){
            return false;
        }else{
            curPage = parseInt(curPage) + 1;
            ld('#curPage').val(curPage);
            searchSubmit("");
        }
    }
    function searchSubmit(elseWhere)
    {
        var params = ld('#queryForm').serialize();
        params += "&is_ajax=yes"+elseWhere;
        ld.ajax({
            url:'index.php?module=Customreport&action=CustomreportAjax&file=ConstructionReport&function_name=getCostCompare',
            type:'post',
            data:params,
            success:function(e) {
                e = JSON.parse(e);
                var code = e.code;
                var result = e.result;
                if (code == 2) {
                    ld('#toExport').text('导出');
                    //2的时候是导出数据
                    window.open(result.filepath);
                } else if (code == 1) {
                    search_date_custom_value
                    ld('#search_date_custom_value').text(result.search_date_custom_value);
                    ld('#total_nums').text(result.total_nums);
                    ld('#total_pages').text(result.total_pages);
                    ld('#curPage').val(result.page);
                    ld('#list').empty();
                    ld.each(result.list, function (index, item) {
                        var html_str = '';
                        if (index % 2 == 0) {
                            html_str += '<tr>\n';
                        } else {
                            html_str += '<tr class="lvtColDataBj">\n';
                        }
                        var alink = item.projectid>0?'<a target="_blank" href="index.php?pageto_module=Project&pageto_action=index&pageto_record='+item.projectid+'">'+item.projectname+'</a>':item.projectname;
                        html_str += '<td>' + item.no + '</td>\n' +
                            '<td>' + item.projectid + '</td>\n' +
                            '<td>' + alink + '</td>\n' +
                            '<td>' + item.plan_cailiao + '</td>\n' +
                            '<td>' + item.cailiao + '</td>\n' +
                            '<td '+item.gap_cailiao_style+'>' + item.gap_cailiao + '</td>\n' +
                            '<td>' + item.plan_laowu + '</td>\n' +
                            '<td>' + item.laowu + '</td>\n' +
                            '<td '+item.gap_laowu_style+'>' + item.gap_laowu + '</td>\n' +
                            '<td>' + item.plan_fenbao + '</td>\n' +
                            '<td>' + item.fenbao + '</td>\n' +
                            '<td '+item.gap_fenbao_style+'>' + item.gap_fenbao + '</td>\n' +
                            '<td>' + item.plan_zulin + '</td>\n' +
                            '<td>' + item.zulin + '</td>\n' +
                            '<td '+item.gap_zulin_style+'>' + item.gap_zulin + '</td>\n' +
                            '<td>' + item.plan_total + '</td>\n' +
                            '<td>' + item.total + '</td>\n' +
                            '<td '+item.gap_total_style+'>' + item.gap_total + '</td>\n' +
                            '</tr>';
                        ld('#list').append(html_str);
                    })
                }
            }
        })
    }

</script>
</body>
