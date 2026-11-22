<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <title>项目报告</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <link rel="stylesheet" href="themes/softed/common.css" type="text/css" />
    <link rel="stylesheet" href="themes/softed/yichongreport.css" type="text/css" />
    <script type="text/javascript">
        var language = "{$language}";
    </script>
    <script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body>
<div class="report-content report-content-second">
    <form id="queryForm">
{*        <div class="search-bar">*}
{*            <div class="search-one-text">*}
{*                <label>项目编号:<input type="text" name="project_no" id="project_no" value="{$project_no}"></label>*}
{*            </div>*}
{*            <div class="search-one-text">*}
{*                <label>客户名称:<input type="text" name="account_name" id="account_name" value="{$account_name}"></label>*}
{*            </div>*}
{*            <div class="search-one-text">*}
{*                <label>开始日期:*}
{*                    <input type="hidden" value="{$request['start_time']}">*}
{*                    <input maxlength="25" size="15" name="start_time" value="{$request['start_time']}"  id="start_time" style="border:1px solid #bababa;width:150px;" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate"/>*}
{*                    <input type="hidden">*}
{*                </label>*}
{*            </div>*}
{*            <div class="search-one-text">*}
{*                <label>截止日期:*}
{*                    <input type="hidden" value="{$request['end_time']}">*}
{*                    <input maxlength="25" size="15" name="end_time" value="{$request['end_time']}"  id="end_time" style="border:1px solid #bababa;width:150px;" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate"/>*}
{*                    <input type="hidden">*}
{*                </label>*}
{*            </div>*}
{*        </div>*}
        <input type="hidden" name="search_date_custom_value" id="search_date_custom_value" value="{$request['search_date_custom_value']}">
        <div class="search-bar">
{*            <div class="btn-search" onclick="searchSubmit('')">搜索</div>*}
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
    <div class="report-title">账号日志</div>
    <div id="tblContent" style="overflow: auto">
        <table>
            <thead>
            <tr>
                <th>序号</th>
                <th>项目编号</th>
                <th>项目名称</th>
                <th>客户名称</th>
                <th>分公司</th>
                <th>合同金额</th>
                <th>产值收入</th>
                <th>项目成本</th>
                <th>材料采购费</th>
                <th>劳务人工费</th>
                <th>分包人工费</th>
                <th>租赁费</th>
                <th>项目费用报销</th>
                <th>毛利额</th>
                <th>毛利率(%)</th>
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
                <td>{$one['projectname']}</td>
                <td>{$one['accountname']}</td>
                <td>{$one['branch_office']}</td>
                <td>{$one['hetong_money']}</td>
                <td>{$one['chanzhi']}</td>
                <td>{$one['chengben']}</td>
                <td>{$one['nums1']}</td>
                <td>{$one['nums2']}</td>
                <td>{$one['nums3']}</td>
                <td>{$one['nums4']}</td>
                <td>{$one['nums5']}</td>
                <td>{$one['maoli']}</td>
                <td>{$one['maoli_rate']}</td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>
</div>
<script type="text/javascript">
    $('#tblContent').css('height', $(window).height()-180);
    function toExport(obj)
    {
        $(obj).text('导出中...');
        searchSubmit("&is_export=yes");
    }
    function resetSearch()
    {
        $('#queryForm')[0].reset();
    }
    function lastPage(){
        var curPage = $('#curPage').val();
        if(parseInt(curPage)<=1){
            return false;
        }else{
            curPage -= 1;
            $('#curPage').val(curPage);
            searchSubmit("");
        }
    }
    function nextPage(){
        var curPage = $('#curPage').val();
        var totalPages = $('#total_pages').text();
        if(parseInt(curPage)>=parseInt(totalPages)){
            return false;
        }else{
            curPage = parseInt(curPage) + 1;
            $('#curPage').val(curPage);
            searchSubmit("");
        }
    }
    function searchSubmit(elseWhere)
    {
        var params = $('#queryForm').serialize();
        params += "&is_ajax=yes"+elseWhere;
        $.ajax({
            url:'index.php?module=Customreport&action=CustomreportAjax&file=ConstructionReport&function_name=getProjectReport',
            type:'post',
            data:params,
            success:function(e) {
                e = JSON.parse(e);
                var code = e.code;
                var result = e.result;
                if (code == 2) {
                    $('#toExport').text('导出');
                    //2的时候是导出数据
                    window.open(result.filepath);
                } else if (code == 1) {
                    search_date_custom_value
                    $('#search_date_custom_value').text(result.search_date_custom_value);
                    $('#total_nums').text(result.total_nums);
                    $('#total_pages').text(result.total_pages);
                    $('#curPage').val(result.page);
                    $('#list').empty();
                    $.each(result.list, function (index, item) {
                        var html_str = '';
                        if (index % 2 == 0) {
                            html_str += '<tr>\n';
                        } else {
                            html_str += '<tr class="lvtColDataBj">\n';
                        }
                        html_str += '<td>' + item.no + '</td>\n' +
                            '<td>' + item.projectid + '</td>\n' +
                            '<td>' + item.projectname + '</td>\n' +
                            '<td>' + item.accountname + '</td>\n' +
                            '<td>' + item.branch_office + '</td>\n' +
                            '<td>' + item.hetong_money + '</td>\n' +
                            '<td>' + item.chanzhi + '</td>\n' +
                            '<td>' + item.chengben + '</td>\n' +
                            '<td>' + item.nums1 + '</td>\n' +
                            '<td>' + item.nums2 + '</td>\n' +
                            '<td>' + item.nums3 + '</td>\n' +
                            '<td>' + item.nums4 + '</td>\n' +
                            '<td>' + item.nums5 + '</td>\n' +
                            '<td>' + item.maoli + '</td>\n' +
                            '<td>' + item.maoli_rate + '</td>\n' +
                            '</tr>';
                        $('#list').append(html_str);
                    })
                }
            }
        })
    }
</script>
</body>
