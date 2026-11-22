<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>疑似重复病人分配</title>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/popper.min.js"></script>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.js"></script>
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.css" type="text/css" />
    <link href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap-select.min.css" rel="stylesheet" />
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap-select.min.js"></script>
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/defaults-zh_CN.min.js"></script>

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
        <div class="card border" id="patientScreenPreviewPage" style="padding:20px; margin:20px">
            <div class="card bg-info text-white mb-2">
                <div class="card-body">疑似重复病人分配<span id="distributionCount"></span></div>
            </div>

            <div class="card-body text-center">
                <div class="btn-group">
                    <button type="button" class="btn btn-dark mr-5" onclick="toBeRedistribution()">重新分配</button>
                    <button type="button" class="btn btn-success" onclick="toBeDistribution()">确认分配</button>
                </div>
            </div>



            <div class="row" id="viewNewPatientDistributionList">
                <div class="col-sm-8 mt-4">
                    <table class="table {*table-sm*}" id="distributionTable">
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
                <div class="col-sm-4 mt-4 text-center">
                    <table class="table" id="distributionCountTable">
                        <thead>
                        <tr>
                            <th>坐席</th>
                            <th>本次分配病人数</th>
                            <th>未完成拜访病人数</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>


</body>

<script>
    var endremarks = '<p>保存成功！</p>';
    var Close ='关闭';

    $().ready(function() {
        //初始化加载 疑似重复病人分配 列表数据
        searchPatientDistribution();
        //右侧的小报表,改为单独请求
        getCountinfo();
    });



    // var regions=[];
    function searchPatientDistribution(){

        $.ajax({
            url: 'BaxterNewPatientDistribution.php?mode=searchPatientDistribution',
            data: '',
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // console.log(data);
                if (data.code==1){
                    //保存搜索的条件，病人总览页面发送及取消时要用到
                    // regions = data.result.regions;
                    $('#viewNewPatientDistributionList').data('regions', data.result.regions);
                    $("#distributionTable tbody").html(data.result.content);
                    $("#distributionCount").html("("+data.result.total+")");
                }

            }
        })

    }

    function getCountinfo(){
        $.ajax({
            url: 'BaxterNewPatientDistribution.php?mode=getCountinfo',
            data: '',
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    //右侧的小报表,改为单独请求
                    $("#distributionCountTable tbody").html(data.result.countcontent);
                }
            }
        })
    }


    //确认分配
    function toBeDistribution(){
// console.log(regions);
        var regions = $('#viewNewPatientDistributionList').data('regions') || '';
        for($i=0;$i<regions.length;$i++)
        {
            var region_id = regions[$i]['id'];
            var value = $('#viewNewPatientDistributionList select[name=region_'+region_id+']').val();
            if(value != ''){
                regions[$i]['value'] = value;
                // continue;
            }

            for($j=0;$j<regions[$i]['provinces'].length;$j++)
            {
                // console.log('$i:'+$i+'---$j:'+$j);

                var province_id = regions[$i]['provinces'][$j]['id'];
                var value = $('#viewNewPatientDistributionList select[name=region_'+region_id+'_'+province_id+']').val();
                console.log("province_id: "+value);
                if(value != ''){
                    regions[$i]['provinces'][$j]['value'] = value;
                    // continue;
                }
                for($k=0;$k<regions[$i]['provinces'][$j]['cities'].length;$k++)
                {
                    // console.log('$i:'+$i+'---$j:'+$j);

                    var city_id = regions[$i]['provinces'][$j]['cities'][$k]['id'];
                    var value = $('#viewNewPatientDistributionList select[name=region_'+region_id+'_'+province_id+'_'+city_id+']').val();
                    console.log("city_id: "+value);
                    if(value != ''){
                        regions[$i]['provinces'][$j]['cities'][$k]['value'] = value;
                        // continue;
                    }
                    for($h=0;$h<regions[$i]['provinces'][$j]['cities'][$k]['hospitals'].length;$h++)
                    {
                        // console.log('$i:'+$i+'---$j:'+$j);

                        var hospital_id = regions[$i]['provinces'][$j]['cities'][$k]['hospitals'][$h]['id'];
                        var value = $('#viewNewPatientDistributionList select[name=region_'+region_id+'_'+province_id+'_'+city_id+'_'+hospital_id+']').val();
                        console.log("hospital_id: "+value);
                        if(value != ''){
                            regions[$i]['provinces'][$j]['cities'][$k]['hospitals'][$h]['value'] = value;
                            // continue;
                        }
                    }
                }
            }
        }




        $.ajax({
            url: 'BaxterNewPatientDistribution.php?mode=tobedistribution',
            data: "&regions="+encodeURIComponent(JSON.stringify(regions)),
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
                        if (data.code==1){
                            $("#distributionCountTable tbody").html(data.result.countcontent);

                            searchPatientDistribution();
                        }
                    },
                });


            }
        })
    }

    //重新分配
    function toBeRedistribution(){
        var url = "BaxterNewPatientDistribution.php?page=toBeRedistribution";
        window.open(url);
    }

    //外包病人预览查询后的表格
    function expandRegion(obj,region_id) { //closest 获取当前元素最近的符合指定选择器的祖先元素
        $(obj).closest('table').find(".province_" + region_id).toggle();
        $(obj).closest('table').find(".hospital_region_" + region_id).hide();
        $(obj).closest('table').find(".city_region_" + region_id).hide();

    //     var icon = document.querySelector('.expand[onclick="expandRegion(' + region_id + ')"] .glyphicon');
    //     icon.classList.toggle('glyphicon-chevron-right');
    //     icon.classList.toggle('glyphicon-chevron-down');
    }
    function expandProvince(obj,province_id) {
        $(obj).closest('table').find(".city_" + province_id).toggle();
        $(obj).closest('table').find(".hospital_province_" + province_id).hide();

        // var icon = document.querySelector('.expand[onclick="expandProvince(' + province_id + ')"] .glyphicon');
        // icon.classList.toggle('glyphicon-chevron-right');
        // icon.classList.toggle('glyphicon-chevron-down');
    }
    function expandCity(obj,city_id) {
        $(obj).closest('table').find(".hospital_" + city_id).toggle();
        // var icon = document.querySelector('.expand[onclick="expandCity(' + city_id + ')"] .glyphicon');
        // icon.classList.toggle('glyphicon-chevron-right');
        // icon.classList.toggle('glyphicon-chevron-down');
    }
    function selectHospital(hospital_id) {
        // 处理选中医院的代码
    }

    //隐藏展开搜索条件
    function toggleForm(formname){
        $("#"+formname).toggle();
    }

</script>

</html>