<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <title>{$title}</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <link rel="stylesheet" href="themes/softed/common.css" type="text/css" />
    <link rel="stylesheet" href="themes/softed/yichongreport.css" type="text/css" />
    <script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>
    <script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body>
<div class="report-content report-content-second">
    <form id="queryForm">
        <div>
            <input type="hidden" name="selectuserid" value="{$request['selectuserid']}">
            <input type="hidden" name="search_date_custom_value" value="{$request['search_date_custom_value']}">
            <input type="hidden" name="approve_value" value="{$request['approve_value']}">
        </div>
        <div class="search-bar">
{*            <div class="btn-search" onclick="searchSubmit('')">搜索</div>*}
{*            <div class="btn-search" onclick="resetSearch()">重置</div>*}
{*            <div class="btn-search" id="toExport" onclick="toExport(this)">导出</div>*}
            <div class="btn-page" style="display:flex;justify-content: flex-end">
                <div onclick="lastPage()" style="cursor:pointer;padding:0 4px;color:#666;line-height: 24px;margin-right:4px;">上页</div>
                <input id="curPage" name="page" style="width:50px;margin-right:4px;" type="text" value="{$page}">
                <div onclick="nextPage()" style="cursor:pointer;padding:0 4px;color:#666;line-height: 24px;">下页</div>
                <div style="line-height: 24px;">共<span id="total_pages">{$total_pages}</span>页</div><div style="line-height: 24px;">,共<span id="total_nums">{$total_nums}</span>条,每页100条</div>
            </div>
        </div>
    </form>
    <div class="report-title">{$title}</div>
    <div id="tblContent" style="overflow: auto">
        <table>
            <thead>
            <tr>
                <th>序号</th>
                <th>{$table_th[0]}</th>
                <th>{$table_th[1]}</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody id="list">
            {foreach item=one from=$list}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr class="" >
                        {else}
                    <tr class="lvtColDataBj">
                {/if}
                <td>{$one['no']}</td>
                <td>{$one['name']}</td>
                <td>{$one['money']}</td>
                <td class="actions">{if $one['no']!="本页小计"&&$one['no']!="总计"}<a style="cursor: pointer" data-status="close" data-name="{$one['name']}" data-accountid="{$one['accountid']}" onclick="showDetails(this)"><span>展开</span><span style="display:none;">收起</span>&nbsp;|&nbsp;</a><a style="cursor: pointer" data-name="{$one['name']}" data-accountid="{$one['accountid']}" module='OutboundOrder' pageurl='index.php?pageto_module=OutboundOrder&pageto_action=index'  onclick="setSalesTragetUrl('{$reportlabel}',this)">列表<div/>{/if}</td>
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
        var reportlabel = "{$reportlabel}";
        params += "&is_ajax=yes"+elseWhere;
        $.ajax({
            url:'index.php?module=Customreport&action=CustomreportAjax&file=YichongReport&function_name=getCustomsList&reportlabel='+reportlabel,
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
                    $('#total_nums').text(result.total_nums);
                    $('#total_pages').text(result.total_pages);
                    $('#curPage').val(result.page);
                    $('#list').empty();
                    $.each(result.list, function (index, item) {
                        var html_str = '';
                        if (index % 2 == 0) {
                            html_str += '<tr class="">\n';
                        } else {
                            html_str += '<tr class="lvtColDataBj">\n';
                        }
                        if(item.no!='本页小计'&&item.no!='总计'){
                            $action_a = '<a style="cursor: pointer" data-status="close" data-name="'+item.name+'" data-accountid="'+item.accountid+'" onclick="showDetails(this)"><span>展开</span><span style="display:none;">收起</span>&nbsp;|&nbsp;</a><a data-name="'+item.name+'" data-accountid="'+item.accountid+'" style="cursor: pointer" module=\'OutboundOrder\' pageurl=\'index.php?pageto_module=OutboundOrder&pageto_action=index\'  onclick="setSalesTragetUrl(\'{$reportlabel}\',this)">详情</a>';
                        }else{
                            $action_a = '';
                        }
                        html_str += '<td>' + item.no + '</td>\n' +
                            '<td>' + item.name + '</td>\n' +
                            '<td>' + item.money + '</td>\n' +
                            '<td class="actions">'+$action_a+'</td>\n' +
                            '</tr>';
                        $('#list').append(html_str);
                    })
                }
            }
        })
    }
    function showDetails(obj)
    {
        var params_detail = $('#queryForm').serialize();
        var name = $(obj).attr('data-name');
        var accountid = $(obj).attr('data-accountid');
        var status = $(obj).attr('data-status');
        var reportlabel = "{$reportlabel}";
        $(obj).attr('data-status','open');
        if(status=="close"){
            params_detail += '&name='+name+'&accountid='+accountid+'&reportlabel=' + reportlabel;
            $.ajax({
                url: 'index.php?module=Customreport&action=CustomreportAjax&file=YichongReport&function_name=getCustomsDetail',
                type: 'post',
                data: params_detail,
                success: function (e) {
                    e = JSON.parse(e);
                    var code = e.code;
                    var result = e.result;
                    var html ='<tr><td colspan="4"><table style="width:80%;margin:20px 10%;">\n' +
                        '            <thead>\n' +
                        '            <tr>\n' +
                        '                <th>序号</th>\n' +
                        '                <th>出库单号</th>\n' +
                        '                <th>金额</th>\n' +
                        '            </tr>\n' +
                        '            </thead>\n' +
                        '            <tbody>';
                    $.each(result.list,function(idx,itm) {
                        html += '<tr><td>'+itm.no+'</td><td><a class="out_no" target="_blank" href="index.php?pageto_module=OutboundOrder&pageto_action=index&pageto_record='+itm.out_id+'">'+itm.out_no+'</a></td><td>'+itm.money+'</td></tr>';
                    });
                    html +='</tbody></table></td></tr>'
                    $(obj).parents('tr').after(html);
                }
            });
        }else{
            $(obj).parents('tr').next().toggle();
        }
        $(obj).children().toggle();


    }
    function setSalesTragetUrl(stufflabel,obj){
        var params_detail = $('#queryForm').serialize();
        var name = $(obj).attr('data-name');
        var accountid = $(obj).attr('data-accountid');
        var reportlabel = "{$reportlabel}";
        params_detail += '&name='+name+'&accountid='+accountid+'&reportlabel=' + reportlabel;
        $.ajax("index.php?module=Customreport&action=CustomreportAjax&file=YichongReport&function_name=setListSession&"+params_detail).done(function(){
            var pageurls = $(obj).attr("pageurl").split(",");
            var addurl = encodeURIComponent("&query_session=1");
            $.each(pageurls,function(tmpindex,tmpurl){
                var url = tmpurl+'&page_addurl='+addurl;
                window.open(url);
            })
        })
    }
</script>
</body>