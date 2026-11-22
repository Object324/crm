<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>第三方主管重新分配界面</title>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
    {*下拉单选*}
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/popper.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.js"></script>
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.css" type="text/css" />
    <link href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap-select.min.css" rel="stylesheet" />
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap-select.min.js"></script>
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/defaults-zh_CN.min.js"></script>

    {*下拉多选*}
    <link href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap-multiselect.css" rel="stylesheet" />
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap-multiselect.js"></script>

    {*日期范围选择器*}
    <link rel="stylesheet" type="text/css" media="all" href="{$CRMCOMMONURL}crmcommon/js/daterangepicker/daterangepicker.css" />
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/daterangepicker/moment.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/daterangepicker/daterangepicker.js"></script>

    {*弹窗*}
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/layer.js'></script>

    <style>
        .table {
            table-layout: fixed; /*固定表格布局*/
            word-break:break-all;
        }

        .table td,
        .table th {
            overflow: hidden; /*隐藏超出单元格宽度的内容*/
            text-overflow: ellipsis; /*将超出单元格宽度的内容省略为省略号*/
        }
        .expand {
            cursor: pointer;
        }
        .cursor-pointer {
            cursor: pointer;
        }
    </style>
</head>
<body>

    {*表单*}
    <div style="max-width：90%;">
        <div class="card border" style="padding:20px; margin:20px">
            <div class="card bg-info text-white mb-2">
                <div class="card-body">重新分配负责坐席<span id="RedistributionCount"></span></div>
            </div>

            <form id="redistributionForm" action="">

                <div class="row text-right">
                    <div class="col-sm-3">
                        <div class="form-group row" style="width:auto;">
                            <label for="smownerid" class="col-sm-3 col-form-label">原坐席</label>
                            <div class="col-sm-9 text-left">
                                <select class="form-control" name="smownerid" id="smownerid" {*multiple="multiple"*}>
{*                                    <option value=""></option>*}
                                    {foreach item=last_name key=userid from=$assigned_person_arr}
                                        <option value="{$userid}">{$last_name}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="form-group row">
                            <label for="rating" class="col-sm-2 col-form-label">状态</label>
                            <div class="col-sm-10 text-left">
                                <select class="form-control" name="rating" id="rating" multiple="multiple">
                                    <option value="New">New</option>
                                    <option value="Active" selected>Active</option>
                                    <option value="Unreachable">Unreachable</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="text-center">
                        <span class="btn btn-primary" onclick="searchRedistribution();">查询</span>
                        <span class="btn btn-success ml-5" onclick="redistribution();">确认</span>
                    </div>
                </div>


            </form>

            {*外包病人总览页面*}
            <div class="row" id="viewRedistributionList">
                <div class="col-sm-8 mt-4">
                    <table class="table {*table-sm*}" id="redistributionTable">
                        <thead>
                        <tr>
                            <th>大区</th>
                            <th>省份</th>
                            <th>城市</th>
                            <th>医院</th>
                            <th>负责坐席</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                </div>


        </div>
    </div>


</body>

<script>
    var endremarks = '<p>保存成功！</p>';
    var Close ='关闭';


    $().ready(function() {
        //多选下拉框初始化
        $('#rating').multiselect({
            includeSelectAllOption: true,
            enableFiltering: true,
            enableCaseInsensitiveFiltering: true,
            filterPlaceholder: '搜索',
            nonSelectedText: '请选择',
            selectAllText: '全选',
            nSelectedText: '已选',
            allSelectedText: '全选',
            maxHeight: 300,
            buttonWidth: '100%',
            numberDisplayed: 4,
        });

        //初始化加载 外包病人预览 列表数据
        searchRedistribution();
    });


    //按查询条件搜索病人
    function searchRedistribution(){
        var formData = "&rating="+encodeURIComponent($('#redistributionForm #rating').val() || '')+
            "&smownerid="+encodeURIComponent($('#redistributionForm #smownerid').val() || '');

        // console.log(formData);
        // return;

        $('#viewRedistributionList').removeData();//查询前先清空保存的值（search_where）

        $.ajax({
            url: 'BaxterPatientDistribution.php?mode=searchRedistribution',
            data: formData,
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // console.log(data);
                if (data.code==1){
                    //保存搜索的条件，病人总览页面发送及取消时要用到
                    $('#viewRedistributionList').data('search_where', data.result.search_where);
                    $('#viewRedistributionList').data('regions', data.result.regions);
                    $("#redistributionTable tbody").html(data.result.content);

                    $("#RedistributionCount").html("("+data.result.total+")");
                }

            }
        })

    }


    //确认重新分配
    function redistribution(){
        var regions = $('#viewRedistributionList').data('regions') || '';
        // console.log(regions);
        for($i=0;$i<regions.length;$i++)
        {
            var region_id = regions[$i]['id'];
            var value = $('#viewRedistributionList select[name=region_'+region_id+']').val();
            // console.log("region_id: "+value);
            if(value != ''){
                regions[$i]['value'] = value;
            }

            for($j=0;$j<regions[$i]['provinces'].length;$j++)
            {
                var province_id = regions[$i]['provinces'][$j]['id'];
                var value = $('#viewRedistributionList select[name=region_'+region_id+'_'+province_id+']').val();
                // console.log("province_id: "+value);
                if(value != ''){
                    regions[$i]['provinces'][$j]['value'] = value;
                }
                for($k=0;$k<regions[$i]['provinces'][$j]['cities'].length;$k++)
                {
                    var city_id = regions[$i]['provinces'][$j]['cities'][$k]['id'];
                    var value = $('#viewRedistributionList select[name=region_'+region_id+'_'+province_id+'_'+city_id+']').val();
                    // console.log("city_id: "+value);
                    if(value != ''){
                        regions[$i]['provinces'][$j]['cities'][$k]['value'] = value;
                    }
                    for($h=0;$h<regions[$i]['provinces'][$j]['cities'][$k]['hospitals'].length;$h++)
                    {
                        var hospital_id = regions[$i]['provinces'][$j]['cities'][$k]['hospitals'][$h]['id'];
                        var value = $('#viewRedistributionList select[name=region_'+region_id+'_'+province_id+'_'+city_id+'_'+hospital_id+']').val();
                        // console.log("hospital_id: "+value);
                        if(value != ''){
                            regions[$i]['provinces'][$j]['cities'][$k]['hospitals'][$h]['value'] = value;
                        }
                    }
                }
            }
        }


        var search_where = $('#viewRedistributionList').data('search_where') || '';
        $.ajax({
            url: 'BaxterPatientDistribution.php?mode=redistribution',
            data: '&search_where='+encodeURIComponent(search_where)+"&regions="+encodeURIComponent(JSON.stringify(regions)),
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                layer.open({
                    content: data.msg,
                    btn: Close,
                    yes: function(){
                        var index = layer.open();
                        layer.close(index);

                        //刷新页面
                        searchRedistribution();
                    },
                });

            }
        })
    }


    //外包病人预览查询后的表格
    function expandRegion(obj,region_id) { //closest 获取当前元素最近的符合指定选择器的祖先元素
        $(obj).closest('table').find(".province_" + region_id).toggle();
        $(obj).closest('table').find(".hospital_region_" + region_id).hide();
        $(obj).closest('table').find(".city_region_" + region_id).hide();

    }
    function expandProvince(obj,province_id) {
        $(obj).closest('table').find(".city_" + province_id).toggle();
        $(obj).closest('table').find(".hospital_province_" + province_id).hide();

    }
    function expandCity(obj,city_id) {
        $(obj).closest('table').find(".hospital_" + city_id).toggle();

    }


    //隐藏展开搜索条件
    function toggleForm(formname){
        $("#"+formname).toggle();
    }

</script>

</html>