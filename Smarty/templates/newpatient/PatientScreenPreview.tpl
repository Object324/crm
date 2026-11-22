<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>外包病人总览</title>

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

    {*表单验证*}
{*    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/jquery.validate.min.js'></script>*}
{*    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/validate-methods.js'></script>*}


    {*弹窗*}
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/layer.js'></script>

    {*省市区级联*}
{*    <script src="{$CRMCOMMONURL}crmcommon/js/distpicker/dist/distpicker.js"></script>*}
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
        {*外包病人总览页面*}
        <div class="card border" id="patientScreenPreviewPage" style="padding:20px; margin:20px">

            <div class="card bg-info text-white mb-2">
                <div class="card-body cursor-pointer" onclick="toggleForm('patientScreenPreviewForm')">外包病人总览<span id="patientScreenPreviewCount"></span></div>
            </div>
            <div class="card-body text-center">
                <div class="btn-group">
                    <button type="button" class="btn btn-success mr-5" onclick="patientScreenPreviewDistribute()">发送</button>
                    <button type="button" class="btn btn-danger" onclick="patientScreenPreviewCancel()">取消</button>
                </div>
            </div>



            <form id="patientScreenPreviewForm" action="">

                <div class="row text-right">
                    <div class="col-sm-3">
                        <div class="form-group row">
                            <label for="rating" class="col-sm-2 col-form-label">状态</label>
                            <div class="col-sm-10 text-left">{*New,Active,Unreachable,Dropout*}
                                <select class="form-control" name="rating" id="rating" multiple="multiple">
                                    <option value="New" selected>New</option>
                                    <option value="Active" selected>Active</option>
                                    <option value="Unreachable">Unreachable</option>
                                    <option value="Dropout">Dropout</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-3">
                        <div class="form-group row" style="width:auto;">
                            <label for="cf_6399" class="col-sm-2 col-form-label">大区</label>
                            <div class="col-sm-10 text-left">{* CustomForm54 :cf_6399 字段值的集合*}
                                <select class="form-control" name="cf_6399" id="cf_6399" multiple="multiple">
                                    {foreach item=cg_region key=cg_region_id from=$cg_region_arr}
                                        <option value="{$cg_region_id}">{$cg_region}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="form-group row">
                            <label for="cf_5333" class="col-sm-2 col-form-label">省份</label>
                            <div class="col-sm-10 text-left">
                                <select class="form-control" name="cf_5333" id="cf_5333" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="form-group row">
                            <label for="cf_5334" class="col-sm-2 col-form-label">城市</label>
                            <div class="col-sm-10 text-left">
                                <select class="form-control" name="cf_5334" id="cf_5334" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="form-group row">
                            <label for="customform02_id" class="col-sm-4 col-form-label">医院<button class="btn btn-primary btn-sm ml-1" type="button" onclick="get_hospital('customform02_id');">获取</button></label>
                            {*<div class="col-sm-8 btn-group">*}{*关联选择插管医院*}{*
                                <input type="text" class="form-control" name="customform02_id_name" id="customform02_id_name" columnname="customform02_id" onkeyup="getKeyWordsSearch(this,event)" autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform02_id" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" onclick="clear_choose_related(this,event,'customform02_id');return false;">X</button>
                            </div>*}
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="customform02_id" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                </div>



                <div class="text-center">
                    <a class="btn btn-primary" onclick="searchPatientScreenPreview();">查询</a>
                </div>
                {*<div class="row" >
                    <div class="col-sm-6" style="display:flex;justify-content: flex-end;">
                        <span id="searchNewPatient" class=" btn btn-success" onclick="searchNewPatient()">查询</span>
                    </div>
                    <div class="col-sm-6">
                        <span id="viewNewPatientReturn" class="btn btn-danger">返回</span>
                        </span>
                    </div>
                </div>*}

            </form>

            {*外包病人总览页面*}
            <div class="row" id="viewPatientScreenPreviewList">
                <div class="col-sm-9 mt-4">
                    <table class="table {*table-sm*}" id="previewTable">
                        <thead>
                        <tr>
                            <th width="20%">大区</th>
                            <th width="20%">省份</th>
                            <th width="20%">城市</th>
                            <th width="40%">医院</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                </div>
                <div class="col-sm-2 mt-4 text-center">
                    <div class="card-header"></div>
                    <table class="table" id="ratingCountTable">
                        <thead>
                        <tr>
                            <th>状态</th>
                            <th>数量</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                </div>
            </div>


            {* <table class="table table-striped table-sm mt-4">
                 <thead>
                 <tr>
                     <th>大区</th>
                     <th>省份</th>
                     <th>城市</th>
                     <th>医院</th>
                 </tr>
                 </thead>

                 <tbody>
                 *}{*<tr><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td></tr>
                <tr><td>11</td><td>22</td><td>33</td><td>44</td><td>55</td><td>66</td><td>77</td></tr>*}{*
                </tbody>
            </table>*}
        </div>


        {*已发送外包病人*}
        <div class="card border" id="patientScreenAssignedPage" style="padding:20px; margin:20px">
            <div class="card bg-info text-white mb-2">
                <div class="card-body">已发送外包病人<span id="patientScreenAssignedCount"></span></div>
            </div>
            <div class="card-body text-center">
                <div class="btn-group">
                    <button type="button" class="btn btn-dark mr-5" onclick="patientScreenAssignedCancelMonthMiddle()">月中按病人条件撤回</button>
                    <button type="button" class="btn btn-danger" onclick="patientScreenAssignedCancelMonthEnd()">全部撤回</button>
                </div>
            </div>
            <div class="card-header">1."全部撤回"按钮：所有病人都从外包中撤回。</div>
            <div class="row table-responsive">
                <div class="col-sm-9 mt-4">
                    <table class="table {*table-sm*}" id="patientScreenAssignedTable">
                        <thead>
                        <tr>
                            <th width="20%">大区</th>
                            <th width="20%">省份</th>
                            <th width="20%">城市</th>
                            <th width="40%">医院</th>
                        </tr>
                        </thead>
                        <tbody>

                        </tbody>
                    </table>
                </div>
            </div>


        </div>
    </div>

    {*模糊搜索 结果显示框*}
    {*<div id="SearchResult" class="SearchResult" style="display: none;">
    </div>*}


</body>

<script>
    function getcurrentURL() {
        var currentURL = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ":" + window.location.port : "");

        var indexSlash = window.location.pathname.lastIndexOf("/");
        if (indexSlash <= 0) {
            var path = "/";
        } else {
            var path = window.location.pathname.substr(0, indexSlash) + "/";
        }
        return currentURL + path;
    }
</script>
<script>
    var endremarks = '<p>保存成功！</p>';
    var Close ='关闭';
    var currentURL = getcurrentURL();


    $().ready(function() {
        //多选下拉框初始化
        $('#rating,#patientScreenPreviewForm #cf_6399,#patientScreenPreviewForm #cf_5333,#patientScreenPreviewForm #cf_5334,select[name=customform02_id]').multiselect({
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

        //插管大区选择时
        $('#patientScreenPreviewForm  #cf_6399').on('change', function() {
            $('#patientScreenPreviewForm #cf_5333').multiselect('dataprovider', '');//清空下拉选项option
            $('#patientScreenPreviewForm #cf_5334').multiselect('dataprovider', '');

            var cg_region = $('#patientScreenPreviewForm #cf_6399').val();
            // console.log(cg_region);

            // 处理多选框选中事件  获取大区
            if (cg_region !== null){
                $.ajax({
                    url: 'BaxterPatientScreen.php?mode=getcg&operationtype=getprovince',
                    data: "selected_region_arr="+encodeURIComponent(cg_region),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        // console.log(data);
                        if (data.code == 1){
                            $('#patientScreenPreviewForm #cf_5333').multiselect('dataprovider', data.result);//插管省份
                        }
                    }
                })
            }
        });
        //插管省份选插管城市时
        $('#patientScreenPreviewForm  #cf_5333').on('change', function() {
            $('#patientScreenPreviewForm #cf_5334').multiselect('dataprovider', '');

            var cg_province = $('#patientScreenPreviewForm #cf_5333').val();
            // console.log(cg_province);

            if (cg_province !== null){
                $.ajax({
                    url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getcity',
                    data: "selected_province_arr="+encodeURIComponent(cg_province),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        // console.log(data);
                        if (data.code == 1){
                            $('#patientScreenPreviewForm #cf_5334').multiselect('dataprovider', data.result);//插管城市
                        }
                    }
                })
            }
        });


        //初始化加载 外包病人预览 列表数据
        searchPatientScreenPreview();

        //初始化加载 已分配外包病人 列表数据
        patientScreenAssigned();
    });


    //获取总览页面的医院
    function get_hospital(columnname){
        $('select[name=customform02_id]').multiselect('dataprovider', '');

        var addurl = '';
        if (columnname == 'customform02_id'){
            var cg_region = $('#patientScreenPreviewForm #cf_6399').val() || '';
            var cg_province = $('#patientScreenPreviewForm #cf_5333').val() || '';
            var cg_city = $('#patientScreenPreviewForm #cf_5334').val() || '';

            addurl ="&cg_region="+cg_region+"&cg_province="+cg_province+"&cg_city="+cg_city;
        }

        $.ajax({
            url: 'BaxterPatientScreen.php?mode=searchHospital&operationtype=getall',
            // data: $('#patientForm').serialize(),
            data: '&columnname='+columnname+addurl,
            type: 'POST',
            dataType: 'json',
            timeout: 5000,
            success: function (data) {
                //console.log(data);

                if (data.code == 1){
                    //显示模糊查询内容
                    var searchinfo = data.result.searchinfo;
                    var columnname = data.result.columnname;
                    if (searchinfo.length>0){
                        // 处理数据
                        $.each(searchinfo, function(index, item) {
                            $('select[name=customform02_id]').append($('<option>', {
                                value: item.billid,
                                text: item.name
                            }));
                        });

                        // 刷新下拉多选框
                        $('select[name=customform02_id]').multiselect('rebuild');
                    }

                }
                else{
                    layer.open({
                        content: '缺少参数',
                        btn: Close,
                        yes: function(){
                            var index = layer.open();
                            layer.close(index);
                        },
                    });
                    return;
                }

                // var tmpheight = parseInt($("#" + data.result.columnname+"_name").css("height"));
                // var top = $("#" + data.result.columnname+"_name").offset().top;
                // var left = $("#" + data.result.columnname+"_name").offset().left;
                // $("#SearchResult").css('display','block').css('position','absolute').css('left',left).css('top',top+tmpheight);
                // $("#SearchResult").html(info_str);

            }
        })
    }

    //按查询条件搜索病人
    function searchPatientScreenPreview(){
        // var formData = $("#patientScreenPreviewForm").serialize();//无法解决多选下拉框的问题,比如居住省份,bill_state:北京;bill_state:上海;  后端无法获取全部的值,除非改为<select id="my-select" name="my-select[]" multiple="false"> 才可以.

        var formData = "&rating="+encodeURIComponent($('#patientScreenPreviewForm #rating').val() || '')+
            "&region="+encodeURIComponent($('#patientScreenPreviewForm #cf_6399').val() || '')+
            "&province="+encodeURIComponent($('#patientScreenPreviewForm #cf_5333').val() || '')+
            "&city="+encodeURIComponent($('#patientScreenPreviewForm #cf_5334').val() || '')+
            "&customform02_id="+encodeURIComponent($('#patientScreenPreviewForm select[name=customform02_id]').val() || '');


        // console.log(formData);
        // console.log($('#viewPatientScreenPreviewList').data("search_where"));
        // return;

        $('#viewPatientScreenPreviewList').removeData();//查询前先清空保存的值（search_where）

        $.ajax({
            url: 'BaxterPatientScreen.php?mode=searchPatientScreenPreview',
            data: formData,
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    //保存搜索的条件，病人总览页面发送及取消时要用到
                    $('#viewPatientScreenPreviewList').data('search_where', data.result.search_where);
                    $("#previewTable tbody").html(data.result.content);
                    $("#ratingCountTable tbody").html(data.result.rating_count_html);
                    $("#ratingCountTable").prev("div").html("将要推送的病人数："+data.result.total);

                    $("#patientScreenPreviewCount").html("("+data.result.total+")");
                }

            }
        })

    }

    //已分配的外包病人
    function patientScreenAssigned(){
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=patientScreenAssigned',
            data: '',
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    $("#patientScreenAssignedTable tbody").html(data.result.content);

                    $("#patientScreenAssignedCount").html("("+data.result.total+")");
                }

            }
        })

    }

    //分配
    function patientScreenPreviewDistribute(){
        var search_where = $('#viewPatientScreenPreviewList').data('search_where') || '';
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=patientScreenPreviewDistribute',
            data: '&search_where='+encodeURIComponent(search_where),
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
                        searchPatientScreenPreview();
                        patientScreenAssigned();//已分配
                    },
                });

            }
        })
    }

    //取消分配
    function patientScreenPreviewCancel(){
        var search_where = $('#viewPatientScreenPreviewList').data('search_where') || '';
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=patientScreenPreviewCancel',
            data: '&search_where='+encodeURIComponent(search_where),
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
                        searchPatientScreenPreview();
                    },
                });

            }
        })
    }

    //月底撤回
    function patientScreenAssignedCancelMonthEnd(){

        $.ajax({
            url: 'BaxterPatientScreen.php?mode=patientScreenAssignedCancelMonthEnd',
            data: '',
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

                        //月底撤回是更改负责人，只刷新已发送外包病人页面，上面的待分配病人不用管
                        patientScreenAssigned();
                    },
                });

            }
        })
    }

    //月中按条件撤回  跳转新页面
    function patientScreenAssignedCancelMonthMiddle(){
        var url = "BaxterPatientScreen.php?page=patientscreenassigned";
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