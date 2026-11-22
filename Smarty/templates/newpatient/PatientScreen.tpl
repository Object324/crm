<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>推送病人筛选</title>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
{*    <script src="{$CRMCOMMONURL}https://cdn.bootcss.com/popper.js/1.14.7/umd/popper.min.js"></script>*}
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

    {*表单验证*}
{*    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/jquery.validate.min.js'></script>*}
{*    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/validate-methods.js'></script>*}


    {*弹窗*}
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/layer.js'></script>

    {*省市区级联*}
{*    <script src="{$CRMCOMMONURL}crmcommon/js/distpicker/dist/distpicker.js"></script>*}
    <style>

        /*验证插件不显示提示信息时 设置input框错误样式*/
        .error {
            border: 1px solid red !important;
        }
        .error:focus {
            border: 1px solid red !important;
        }
        .valid {
            border: 1px solid green !important;
        }
        .cursor-pointer {
            cursor: pointer;
        }
    </style>
</head>
<body>

    {*表单*}
    <div class="{*container*}" id="patientScreenPage" style="max-width：90%;">
        <div class="card border" style="padding:20px; margin:20px /*margin-top:20px*/">
            <div class="card bg-info text-white mb-2">
                <div class="card-body cursor-pointer" onclick="toggleForm('patientScreenForm')">基本信息</div>
            </div>
            <form id="patientScreenForm" action="">


                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="account_no" class="col-sm-4 col-form-label">编号</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="account_no" id="account_no" value="">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6399" class="col-sm-4 col-form-label">插管大区</label>
                            <div class="col-sm-8 text-left">{* CustomForm54 :cf_6399 字段值的集合*}
                                <select class="form-control" name="cf_6399" id="cf_6399" multiple="multiple">
                                    {foreach item=cg_region key=cg_region_id from=$cg_region_arr}
                                        <option value="{$cg_region_id}">{$cg_region}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="distributors_province" class="col-sm-4 col-form-label">终端配送商省份</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="distributors_province" id="distributors_province" multiple="multiple">
                                    {foreach $province_arr as $province}
                                        <option value="{$province}">{$province}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="accountname" class="col-sm-4 col-form-label">姓名</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="accountname" id="accountname" value="">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5333" class="col-sm-4 col-form-label">插管省份</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_5333" id="cf_5333" multiple="multiple">
                                    {foreach $province_arr as $province}
                                        <option value="{$province}">{$province}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="distributors_city" class="col-sm-4 col-form-label">终端配送商城市</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="distributors_city" id="distributors_city" multiple="multiple">
                                    {foreach item=cg_city from=$cg_city_arr}
                                        <option value="{$cg_city}">{$cg_city}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="phone" class="col-sm-4 col-form-label">电话</label>
                            <div class="col-sm-8">{*cf_5678，cf_5686，cf_5674，cf_5682， cf_6455*}
                                <input type="tel" class="form-control" name="phone" id="phone" value="">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5334" class="col-sm-4 col-form-label">插管城市</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_5334" id="cf_5334" multiple="multiple">
                                    {foreach item=cg_city from=$cg_city_arr}
                                        <option value="{$cg_city}">{$cg_city}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="distributors_area" class="col-sm-4 col-form-label">终端配送商县
                                <button class="btn btn-primary btn-sm ml-1" type="button" onclick="get_distributors_area();">获取</button>
                            </label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="distributors_area" id="distributors_area" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="bill_state" class="col-sm-4 col-form-label">居住省份</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="bill_state" id="bill_state" multiple="multiple">
                                    {foreach $province_arr as $province}
                                        <option value="{$province}">{$province}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5335" class="col-sm-4 col-form-label">插管县
                                <button class="btn btn-primary btn-sm ml-1" type="button" onclick="get_cg_area();">获取</button>
                            </label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_5335" id="cf_5335" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="customform02_id2_name" class="col-sm-4 col-form-label">终端配送商</label>
                            <div class="col-sm-8 btn-group">{*关联选择插管医院*}
                                <input type="text" class="form-control" name="customform02_id2_name" id="customform02_id2_name" columnname="customform02_id2" onkeyup="getKeyWordsSearch(this,event)"  autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform02_id2" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" onclick="clear_choose_related(this,event,'customform02_id2');return false;">X</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="bill_city" class="col-sm-4 col-form-label">居住城市</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="bill_city" id="bill_city" multiple="multiple">
                                    {foreach item=cg_city from=$cg_city_arr}
                                        <option value="{$cg_city}">{$cg_city}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="customform02_id_name" class="col-sm-4 col-form-label">插管医院</label>
                            <div class="col-sm-8 btn-group">{*关联选择插管医院*}
                                <input type="text" class="form-control" name="customform02_id_name" id="customform02_id_name" columnname="customform02_id" onkeyup="getKeyWordsSearch(this,event)"  autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform02_id" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" onclick="clear_choose_related(this,event,'customform02_id');return false;">X</button>
                            </div>
                        </div>
                    </div>
                    {*<div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6845" class="col-sm-4 col-form-label">负责PSR</label>
                            <div class="col-sm-8">*}{*关联选择负责人*}{*
                                <select class="form-control" name="cf_6845" id="cf_6845"></select>
                            </div>
                        </div>
                    </div>*}
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="visit_time" class="col-sm-4 col-form-label">最佳拜访时间</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="visit_time" id="visit_time" multiple="multiple">
                                    <option value="9:00-10:00">9:00-10:00</option>
                                    <option value="10:01-11:00">10:01-11:00</option>
                                    <option value="11:01-12:00">11:01-12:00</option>
                                    <option value="12:01-13:00">12:01-13:00</option>
                                    <option value="13:01-15:00">13:01-15:00</option>
                                    <option value="15:01-17:00">15:01-17:00</option>
                                    <option value="17:01-18:00">17:01-18:00</option>
                                    <option value="18:01-20:00">18:01-20:00</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="bill_area" class="col-sm-4 col-form-label">居住县<button class="btn btn-primary btn-sm ml-1" type="button" onclick="get_bill_area();">获取</button></label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="bill_area" id="bill_area" multiple="multiple"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="rating" class="col-sm-4 col-form-label">状态</label>
                            <div class="col-sm-8 text-left">{*New,Active,Unreachable,Dropout*}
                                <select class="form-control" name="rating" id="rating" multiple="multiple">
                                    <option value="New">New</option>
                                    <option value="Active" selected>Active</option>
                                    <option value="Unreachable">Unreachable</option>
                                    <option value="Dropout">Dropout</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5680" class="col-sm-4 col-form-label">要求拜访间隔天数(范围)</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_5680" id="cf_5680" multiple="multiple">
                                    {*                                    <option value="">空</option>*}
                                    <option value="小于31天">小于31天</option>
                                    <option value="31-60天">31-60天</option>
                                    <option value="61-90天">61-90天</option>
                                    <option value="91-180天">91-180天</option>
                                    <option value="大于180天">大于180天</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="bill_street" class="col-sm-4 col-form-label">地址</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="bill_street" id="bill_street" value="">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6156" class="col-sm-4 col-form-label">Active病人管理类型</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_6156" id="cf_6156" multiple="multiple">
                                    <option value="电话联系病人">电话联系病人</option>
                                    <option value="微信联系病人">微信联系病人</option>
                                    <option value="送货上门病人">送货上门病人</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6299" class="col-sm-4 col-form-label">是否适合外包</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_6299" id="cf_6299">
                                    <option value=""></option>
                                    <option value="是" selected>是</option>
                                    <option value="否">否</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5323_from" class="col-sm-4 col-form-label">年龄</label>
                            <div class="col-sm-3">{*cf_5323*}
                                <input type="number" class="form-control" name="cf_5323_from" min="0" placeholder="起始年龄">
                            </div>
                            <label for="cf_5323_to" class="col-form-label">至</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" name="cf_5323_to" min="0" placeholder="结束年龄">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6791_from" class="col-sm-4 col-form-label">第三方成功次数</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" min="0" name="cf_6791_from">
                            </div>
                            <label for="cf_6791_to" class="col-form-label">至</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" min="0" name="cf_6791_to">
                            </div>
                        </div>
                    </div>

                    {*20230412 增加筛选字段 PD治疗方式，cf_5394*}
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5394" class="col-sm-4 col-form-label">pd治疗方式</label>
                            <div class="col-sm-8 text-left">
                                <select class="form-control" name="cf_5394" id="cf_5394">
                                    <option value=""></option>
                                    <option value="CAPD" selected>CAPD</option>
                                    <option value="APD">APD</option>
                                </select>
                            </div>
                        </div>
                    </div>

                </div>



                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="createdtime" class="col-sm-4 col-form-label">创建日期</label>
                            <div class="col-sm-8">
                                <input type="text" id="createdtime" name="createdtime" class="form-control" autocomplete="off">
                            </div>
                        </div>
                        {*<div class="form-group row">
                            <label for="createdtime" class="col-sm-4 col-form-label">创建日期</label>
                            <div class="col-sm-4">
                                <input type="date" class="form-control" id="createdtime" name="createdtime[]">
                            </div>
                            <label for="end_date" class="col-form-label">至</label>
                            <div class="col-sm-4">
                                <input type="date" class="form-control" id="createdtime" name="createdtime[]">
                            </div>
                        </div>*}
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6793_from" class="col-sm-4 col-form-label">第三方失败次数</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" min="0" name="cf_6793_from">
                            </div>
                            <label for="cf_6793_to" class="col-form-label">至</label>
                            <div class="col-sm-3">
                                <input type="number" class="form-control" min="0" name="cf_6793_to">
                            </div>
                        </div>
                    </div>

                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5392" class="col-sm-4 col-form-label">插管日期</label>
                            <div class="col-sm-8">
                                <input type="text" id="cf_5392" name="cf_5392" class="form-control" autocomplete="off">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5456" class="col-sm-4 col-form-label">上次拜访失败日期</label>
                            <div class="col-sm-8">
                                <input type="text" id="cf_5456" name="cf_5456" class="form-control" autocomplete="off">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5454" class="col-sm-4 col-form-label">最近成功拜访日期</label>
                            <div class="col-sm-8">
                                <input type="text" id="cf_5454" name="cf_5454" class="form-control" autocomplete="off">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_5672" class="col-sm-4 col-form-label">无法联系原因</label>
                            <div class="col-sm-8 text-left">{*无人接听/关机/无法接通/无效沟通/拒接/查无此人/停机/空号*}
                                <select class="form-control" name="cf_5672" id="cf_5672" multiple="multiple">
                                    <option value="无人接听">无人接听</option>
                                    <option value="关机">关机</option>
                                    <option value="无法接通">无法接通</option>
                                    <option value="无效沟通">无效沟通</option>
                                    <option value="拒接">拒接</option>
                                    <option value="查无此人">查无此人</option>
                                    <option value="停机">停机</option>
                                    <option value="空号">空号</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-4">
                        <div class="form-group row">
                            <label for="cf_6671" class="col-sm-4 col-form-label">unreachable创建日期</label>
                            <div class="col-sm-8">
                                <input type="text" id="cf_6671" name="cf_6671" class="form-control" autocomplete="off">
                            </div>
                        </div>
                    </div>
                </div>



                <div class="text-center">
{*                    <div style="display: flex;justify-content: flex-end;">*}
{*                        <button type="submit" class="btn btn-primary" onclick="searchPatientScreen();return false;">查询</button>*}
                        <a class="btn btn-primary" {*id="searchPatientScreen"*} onclick="searchPatientScreen(1,'submit');">查询</a>
{*                    </div>*}
                </div>

            </form>
        </div>
    </div>



    {*模糊搜索 结果显示框*}
    <div id="SearchResult" class="SearchResult" style="display: none;max-height:400px;overflow-y: auto;">
    </div>

    <div class="container" id="repeatlist" style="display: none;max-width：90%;">
        <div class="card" style="padding:20px; margin-top:20px">
{*            <h6 id="tabletitle" class="p-3 mb-2 bg-info bg-gradient text-white">重复病人列表</h6>*}
            <div class="card bg-info text-white mb-2">
                <div class="card-body" id="tabletitle">重复病人列表</div>
            </div>
            <table class="table  table-striped {*table-hover*}">
                <thead>
                <tr>
                    <th>重复类型</th>
                    <th>姓名</th>
                    <th>电话</th>
                    <th>地址</th>
                    <th>插管医院</th>
                    <th>状态</th>
                    <th>来源</th>
                </tr>
                </thead>

                <tbody>
                <tr><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td></tr>
                <tr><td>11</td><td>22</td><td>33</td><td>44</td><td>55</td><td>66</td><td>77</td></tr>
                </tbody>
            </table>

            <div class="row" id="patientRepeat" style="display:none;justify-content: center;">
                <span id="patientRepeatCancel" class="btn btn-danger">取消</span>
            </div>


            <input type="hidden" name="is_repeat" value="norepeat">
            <input type="hidden" name="repeat" value="">
            <div class="row" id="patientSeemRepeat" style="display:none;">
                <div class="col-sm-6" style="display:flex;justify-content: flex-end;">
                    <span id="patientSeemRepeatSubmit" class=" btn btn-success" onclick="saveSeemRepeat()">确认</span>
                </div>
                <div class="col-sm-6">
                    <span id="patientSeemRepeatCancel" class="btn btn-danger">取消</span>
                </span></div>
            </div>

        </div>

    </div>

    {*查看查询的新病人列表*}
    <div class="{*container*}" id="viewPatientScreenList" style="margin:50px auto;">
        <div class="card border" style="padding:20px; margin:20px">

                <div class="mb-2">
{*                    <span>共有病人记录：<span id="total_rows">0</span>条</span>*}
                    <button onclick="addWaitingDistribute()" type="button" class="btn btn-success float-center" title="添加到待分配状态">添加</button>
                    <button onclick="outsourcedPatientPreview()" type="button" class="btn btn-dark float-right">外包病人总览</button>
                </div>

                {*<button type="button" class="btn btn-secondary">次要按钮</button>
                <button type="button" class="btn btn-success">成功</button>
                <button type="button" class="btn btn-info">信息</button>*}


{*            <h5>共有病人记录：<span id="total_rows">0</span>条</h5>*}
            <ul class="pagination justify-content-end" style="cursor: pointer;">
                <li  class="page-item disabled mr-5"><span class="page-link">共有病人记录：<span id="total_rows">0</span>条</span></li>
                <li id="first-page" class="page-item disabled"><a class="page-link">首页</a></li>
                <li id="prev-page" class="page-item disabled"><a class="page-link">上一页</a></li>
                <li id="next-page" class="page-item disabled"><a class="page-link">下一页</a></li>
                <li id="last-page" class="page-item disabled"><a class="page-link">尾页</a></li>
                <li class="page-item disabled"><a class="page-link">第<span id="page">0</span>页</a></li>
                <li class="page-item disabled"><a class="page-link">共<span id="total_pages">0</span>页</a></li>
            </ul>

            <table class="table table-striped table-sm">
                <thead>
                <tr>
                    <th><input {*class="form-check-input"*} type="checkbox" id="selectAll"></th>
                    <th>姓名</th>
                    <th>状态</th>
                    <th>插管医院</th>
                    <th>上次成功拜访日期</th>
                    <th>上次成功拜访时间</th>
                    <th>Boost当前负责销售</th>
                    <th>上次拜访状态</th>
                    <th>上次拜访失败日期</th>
                    <th>上次拜访失败时间</th>
                    <th>拜访失败次数</th>
                    <th>第三方成功次数</th>
                    <th>第三方失败次数</th>
                    <th>创建日期</th>
                    <th>插管日期</th>
                    <th>unreachable创建日期</th>
                </tr>
                </thead>

                <tbody>
                {*<tr><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td></tr>
                <tr><td>11</td><td>22</td><td>33</td><td>44</td><td>55</td><td>66</td><td>77</td></tr>*}
                </tbody>
            </table>
        </div>
    </div>


</body>
<script>
    function userEnterKey()
    {
        //16845: 销售机会>新建：客户名称、联系人模糊匹配功能失效。（IE10、IE9）
        //arguments:是js系统变量，可以上网查看
        var event=arguments[arguments.length-1];

        var e=event||window.event;
        var code=e.keyCode||e.which;
        var obj=e.srcElement||e.target;

        if(e.keyCode==13)
        {
            var fun=arguments[0];

            fun.apply(this,arguments[1]);
        }
        return true;
    }

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

    function getKeyWordsSearch(obj, event){
        // console.log(event);
        // console.log(event.key);
        var searchcontent = event.target.value;
        // var searchcontent = $(obj).val().trim();
        var columnname = $(obj).attr('columnname');

        var regex = /^[A-Za-z']+$/; // 匹配字母的正则表达式
        if (regex.test(searchcontent) || event.key == 'Process') {
            // console.log("输入的是字母");
            return;
        }
        // console.log("输入的是汉字，发起请求");

        var addurl = '';
        if (columnname == 'customform02_id'){
            var cg_region = $('#patientScreenPage #cf_6399').val() || '';
            var cg_province = $('#patientScreenPage #cf_5333').val() || '';
            var cg_city = $('#patientScreenPage #cf_5334').val() || '';
            var cg_area = $('#patientScreenPage #cf_5335').val() || '';

            addurl ="&cg_region="+cg_region+"&cg_province="+cg_province+"&cg_city="+cg_city+"&cg_area="+cg_area;
        }else if(columnname == 'customform02_id2'){ //终端配送商
            var cg_province = $('#patientScreenPage #distributors_province').val() || '';
            var cg_city = $('#patientScreenPage #distributors_city').val() || '';
            var cg_area = $('#patientScreenPage #distributors_area').val() || '';

            addurl = "&cg_province="+cg_province+"&cg_city="+cg_city+"&cg_area="+cg_area;
        }


        $.ajax({
            url: 'BaxterPatientScreen.php?mode=searchHospital',
            // data: $('#patientForm').serialize(),
            data: "searchcontent="+encodeURIComponent(searchcontent)+'&columnname='+columnname+addurl,
            type: 'POST',
            dataType: 'json',
            timeout: 5000,
            success: function (data) {
                if (data.code == 1){
                    //显示模糊查询内容
                    var searchinfo = data.result.searchinfo;
                    var columnname = data.result.columnname;
                    if (searchinfo.length>0){
                        var info_str = '<table class="table table-dark table-hover"><tbody>';
                        $.each(searchinfo,function(index,infoData){
                            // console.log(index,infoData);
                            info_str +=
                                '        <tr columnname="'+columnname+'"' +
                                '            onclick="choose_related(this,event,\''+columnname+'\','+infoData.billid+',\''+infoData.name+'\')" title="'+infoData.name+'">' +
                                '            <td>'+infoData.name+'</td>' +
                                '            <td>'+infoData.billno+'</td>' +
                                '        </tr>';

                        });
                        info_str += '</tbody></table>';
                    }else{
                        // $("#SearchResult").html('');
                        /*var info_str = '<table>';
                        //无任何记录
                        info_str += '<tr>';
                        info_str += '<td>无任何记录</td>';
                        info_str += '</tr>';
                        info_str += '</table>';*/
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

                var tmpheight = parseInt($("#" + data.result.columnname+"_name").css("height"));
                var top = $("#" + data.result.columnname+"_name").offset().top;
                var left = $("#" + data.result.columnname+"_name").offset().left;
                $("#SearchResult").css('display','block').css('position','absolute').css('left',left).css('top',top+tmpheight);
                $("#SearchResult").html(info_str);

            }
        })
    }


    $().ready(function() {
        /*$('#bill_area').multiselect({
            includeSelectAllOption: true //多选
        });*/


        //时间日期选择
        $('input[name="createdtime"],input[name="cf_5392"],input[name="cf_5454"],input[name="cf_6671"],input[name="cf_5456"]').daterangepicker({
            autoUpdateInput: false,
            locale: {
                // format: 'YYYY-MM-DD',
                applyLabel: '确认',
                cancelLabel: '取消',
                // fromLabel: '起始日期',
                // toLabel: '结束日期',
                // customRangeLabel: '自定义',
                daysOfWeek: ['日', '一', '二', '三', '四', '五', '六'],
                monthNames: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
                firstDay: 1
            },
        });
        $('input[name="createdtime"],input[name="cf_5392"],input[name="cf_5454"],input[name="cf_6671"],input[name="cf_5456"]').on('apply.daterangepicker', function(ev, picker) {
            $(this).val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
        });

        //多选下拉框初始化
        $('#patientScreenPage #bill_state,#patientScreenPage #bill_city,#patientScreenPage #bill_area').multiselect({
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
        $('#patientScreenPage #cf_6399,#patientScreenPage #cf_5333,#patientScreenPage #cf_5334,#patientScreenPage #cf_5335').multiselect({
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
        $('#distributors_province,#distributors_city,#distributors_area,#visit_time,#rating,#cf_6156,#cf_5680,#cf_5672').multiselect({
            includeSelectAllOption: true, enableFiltering: true, enableCaseInsensitiveFiltering: true, filterPlaceholder: '搜索', nonSelectedText: '请选择', selectAllText: '全选',
            nSelectedText: '已选', allSelectedText: '全选', maxHeight: 300, buttonWidth: '100%', numberDisplayed: 4,
        });

        /*$('#bill_state').multiselect({
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
            // 处理多选框选中事件  获取城市
            /!*onChange: function(option, checked) {
               //onChange无法监听全选,得用全选onSelectAll或者取消全选onDeselectAll才行,怪麻烦的,故选择jq的change事件.
            }*!/
        });*/
        $('#patientScreenPage #bill_state').on('change', function() {
            // $('#bill_city').multiselect('deselectAll', false);//仅取消所有选项,并不会删除option
            // $('#bill_city').multiselect('rebuild');//重构
            // $('#bill_city').empty();
            $('#patientScreenPage #bill_city').multiselect('dataprovider', '');//清空下拉选项option
            $('#patientScreenPage #bill_area').multiselect('dataprovider', '');//清空下拉选项option

            var bill_state = $('#patientScreenPage #bill_state').val();
            // console.log(bill_state);

            // 处理多选框选中事件  获取城市
            if (bill_state !== null){
                $.ajax({
                    url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getcity',
                    data: "selected_province_arr="+encodeURIComponent(bill_state),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        // console.log(data);
                        if (data.code == 1){
                            $('#patientScreenPage #bill_city').multiselect('dataprovider', data.result);
                        }
                    }
                })
            }
        });

        $('#patientScreenPage  #bill_city').on('change', function() {
            $('#patientScreenPage  #bill_area').multiselect('dataprovider', '');//清空居住县下拉选项option
            // $('#bill_city').multiselect('deselectAll', false);//仅取消所有选项,并不会删除option

        });


        //插管大区选择时
        $('#patientScreenPage  #cf_6399').on('change', function() {
            $('#patientScreenPage #cf_5333').multiselect('dataprovider', '');//清空下拉选项option
            $('#patientScreenPage #cf_5334').multiselect('dataprovider', '');
            $('#patientScreenPage #cf_5335').multiselect('dataprovider', '');

            var cg_region = $('#patientScreenPage #cf_6399').val() || '';
            // console.log(cg_region);

            // 处理多选框选中事件  获取大区
            // if (cg_region !== ''){
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
                            $('#patientScreenPage #cf_5333').multiselect('dataprovider', data.result);//插管省份

                            $('#patientScreenPage  #cf_5333').trigger('change');//选择大区后 省份/城市 都需要更新
                        }
                    }
                })
            // }
        });
        //插管省份选插管城市时
        $('#patientScreenPage  #cf_5333').on('change', function() {
            $('#patientScreenPage #cf_5334').multiselect('dataprovider', '');
            $('#patientScreenPage #cf_5335').multiselect('dataprovider', '');

            var cg_region = $('#patientScreenPage #cf_6399').val() || '';
            var cg_province = $('#patientScreenPage #cf_5333').val() || '';
            // console.log(cg_region);
            // console.log(cg_province);

            // if (cg_province !== ''){
                $.ajax({
                    url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getcity',
                    data: "selected_region_arr="+encodeURIComponent(cg_region)+"&selected_province_arr="+encodeURIComponent(cg_province),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        // console.log(data);
                        if (data.code == 1){
                            $('#patientScreenPage #cf_5334').multiselect('dataprovider', data.result);//插管城市
                        }
                    }
                })
            // }
        });
        //终端配送商省份
        $('#distributors_province').on('change', function() {
            $('#distributors_city').multiselect('dataprovider', '');
            $('#distributors_area').multiselect('dataprovider', '');

            var distributors_province = $('#distributors_province').val() || '';
            // console.log(distributors_province);

            // if (distributors_province !== ''){
                $.ajax({
                    url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getcity',
                    data: "selected_province_arr="+encodeURIComponent(distributors_province),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        // console.log(data);
                        if (data.code == 1){
                            $('#distributors_city').multiselect('dataprovider', data.result);
                        }
                    }
                })
            // }
        });


        //点击首页
        $('#viewPatientScreenList #first-page').click(function(event) {
            event.preventDefault();
            searchPatientScreen(1);
        });
        // 点击上一页按钮
        $('#viewPatientScreenList #prev-page').click(function(event) {
            event.preventDefault();
            var page = parseInt($('#viewPatientScreenList').data('page')) - 1;
            // console.log(page);
            searchPatientScreen(page);
        });
        // 点击下一页按钮
        $('#viewPatientScreenList #next-page').click(function(event) {
            event.preventDefault();
            var page = parseInt($('#viewPatientScreenList').data('page')) + 1;
            var total_pages = $('#viewPatientScreenList').data('total_pages');
            searchPatientScreen(page,total_pages);
        });
        // 点击尾页按钮
        $('#viewPatientScreenList #last-page').click(function(event) {
            event.preventDefault();
            var page = parseInt($('#viewPatientScreenList').data('total_pages'));
            searchPatientScreen(page);
        });


        //列表选择框
        // 当全选复选框被选中时，将所有复选框都选中
        $('#viewPatientScreenList #selectAll').change(function() {
            $('#viewPatientScreenList input[type="checkbox"]').prop('checked', $(this).prop('checked'));
        });

        // 当某个复选框被取消选中时，取消全选复选框的选中状态
        $('#viewPatientScreenList input[type="checkbox"]').change(function() {
            if (!$(this).prop('checked')) {
                $('#viewPatientScreenList #selectAll').prop('checked', false);
            }
        });

        //初始化加载列表数据
        searchPatientScreen(1,'');

    });

    //点击获取居住县
    function get_bill_area(){
        var bill_city = $('#bill_city').val() || '';
        // if (JSON.stringify(bill_city) == 'null'){
        if (bill_city == ''){
            layer.open({
                content: '先选择居住城市',
                btn: Close,
                yes: function(){
                    var index = layer.open();
                    layer.close(index);
                },
            });
            return;
        }
        // 处理多选框选中事件  获取区县
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getarea',
            data: "selected_city_arr="+encodeURIComponent(bill_city),
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // console.log(data);
                if (data.code == 1){
                    $('#bill_area').multiselect('dataprovider', data.result);
                }
            }
        })
    }
    //点击获取插管县 cf_5335
    function get_cg_area(){
        var city = $('#patientScreenPage #cf_5334').val() || '';
        if (city == ''){
            layer.open({
                content: '先选择插管城市',
                btn: Close,
                yes: function(){
                    var index = layer.open();
                    layer.close(index);
                },
            });
            return;
        }
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getarea',
            data: "selected_city_arr="+encodeURIComponent(city),
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // console.log(data);
                if (data.code == 1){
                    $('#patientScreenPage #cf_5335').multiselect('dataprovider', data.result);
                }
            }
        })
    }
    //点击获取终端配送县
    function get_distributors_area(){
        var city = $('#distributors_city').val() || '';
        if (city == ''){
            layer.open({
                content: '先选择终端配送商城市',
                btn: Close,
                yes: function(){
                    var index = layer.open();
                    layer.close(index);
                },
            });
            return;
        }
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=get_public_method&operationtype=getarea',
            data: "selected_city_arr="+encodeURIComponent(city),
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // console.log(data);
                if (data.code == 1){
                    $('#distributors_area').multiselect('dataprovider', data.result);
                }
            }
        })
    }


    //模糊搜索医院、医生后确定选择
    function choose_related(obj,event,columnname,billid,name){
        $("#"+columnname+"_name").val(name);
        $("input[name="+columnname+"]").val(billid);
        //隐藏模糊搜索结果框
        // $("#SearchResult").hide();
        $("#SearchResult").empty();

        //选择后只读
        $("#"+columnname+"_name").attr('readonly', true);
        // $("#"+columnname+"_name").css('cursor', 'not-allowed');
    }
    function clear_choose_related(obj,event,columnname){
        $("#"+columnname+"_name").attr('readonly', false);
        $("#"+columnname+"_name").val('');
        $("input[name="+columnname+"]").val('');

        //如果清除插管医院，则插管医生 customform47_id 及主治医生 customform47_id_2 信息也要清空
        /*if (columnname == 'customform02_id'){
            $("#customform47_id_name").attr('readonly', false);
            $("#customform47_id_name").val('');
            $("input[name=customform47_id]").val('');

            $("#customform47_id_2_name").attr('readonly', false);
            $("#customform47_id_2_name").val('');
            $("input[name=customform47_id_2]").val('');
        }*/


    }

    //按查询条件搜索病人
    function searchPatientScreen(page,type){
        // console.log($("#patientScreenForm").serialize());
        // return;

        // var formData = $("#patientScreenForm").serialize();//无法解决多选下拉框的问题,比如居住省份,bill_state:北京;bill_state:上海;  后端无法获取全部的值

        var formData = "&account_no="+encodeURIComponent($('#patientScreenPage #account_no').val())+
            "&accountname="+encodeURIComponent($('#patientScreenPage #accountname').val())+
            "&phone="+$('#patientScreenPage #phone').val()+
            "&bill_state="+encodeURIComponent($('#patientScreenPage #bill_state').val() || '')+
            "&bill_city="+encodeURIComponent($('#patientScreenPage #bill_city').val() || '')+
            "&bill_area="+encodeURIComponent($('#patientScreenPage #bill_area').val() || '')+
            "&bill_street="+encodeURIComponent($('#patientScreenPage #bill_street').val())+
            // "&cf_5323="+$('#patientScreenPage input[name="cf_5323[]"]').serialize()+
            "&createdtime="+$('#patientScreenPage #createdtime').val()+
            "&cf_5392="+$('#patientScreenPage #cf_5392').val()+
            "&cf_5454="+$('#patientScreenPage #cf_5454').val()+
            "&cf_6671="+$('#patientScreenPage #cf_6671').val()+

            "&cf_6399="+encodeURIComponent($('#patientScreenPage #cf_6399').val() || '')+
            "&cf_5333="+encodeURIComponent($('#patientScreenPage #cf_5333').val() || '')+
            "&cf_5334="+encodeURIComponent($('#patientScreenPage #cf_5334').val() || '')+
            "&cf_5335="+encodeURIComponent($('#patientScreenPage #cf_5335').val() || '')+
            "&customform02_id="+$('#patientScreenPage input[name=customform02_id]').val()+
            "&rating="+encodeURIComponent($('#patientScreenPage #rating').val() || '')+
            "&cf_6156="+encodeURIComponent($('#patientScreenPage #cf_6156').val() || '')+
            // "&cf_6791="+$('#patientScreenPage input[name="cf_6791[]"]').serialize()+
            // "&cf_6793="+$('#patientScreenPage input[name="cf_6793[]"]').serialize()+
            "&cf_5456="+encodeURIComponent($('#patientScreenPage #cf_5456').val() || '')+
            "&cf_5672="+encodeURIComponent($('#patientScreenPage #cf_5672').val() || '')+

            "&distributors_province="+encodeURIComponent($('#patientScreenPage #distributors_province').val() || '')+
            "&distributors_city="+encodeURIComponent($('#patientScreenPage #distributors_city').val() || '')+
            "&distributors_area="+encodeURIComponent($('#patientScreenPage #distributors_area').val() || '')+
            "&customform02_id2="+$('#patientScreenPage input[name=customform02_id2]').val()+
            // "&cf_6845="+encodeURIComponent($('#patientScreenPage #cf_6845').val() || '')+
            "&visit_time="+encodeURIComponent($('#patientScreenPage #visit_time').val() || '')+
            "&cf_5680="+encodeURIComponent($('#patientScreenPage #cf_5680').val() || '')+
            "&cf_6299="+encodeURIComponent($('#patientScreenPage #cf_6299').val() || '')+
            "&cf_5394="+encodeURIComponent($('#patientScreenPage #cf_5394').val() || '');


        //年龄 第三方成功次数 第三次失败次数
        var cf_5323_from = $('#patientScreenPage input[name="cf_5323_from"]').val() || '';
        var cf_5323_to = $('#patientScreenPage input[name="cf_5323_to"]').val() || '';
        if (cf_5323_from != '' || cf_5323_to != ''){
            formData += "&cf_5323[]="+cf_5323_from+"&cf_5323[]="+cf_5323_to;
        }
        var cf_6791_from = $('#patientScreenPage input[name="cf_6791_from"]').val() || '';
        var cf_6791_to = $('#patientScreenPage input[name="cf_6791_to"]').val() || '';
        if (cf_6791_from != '' || cf_6791_to != ''){
            formData += "&cf_6791[]="+cf_6791_from+"&cf_6791[]="+cf_6791_to;
        }
        var cf_6793_from = $('#patientScreenPage input[name="cf_6793_from"]').val() || '';
        var cf_6793_to = $('#patientScreenPage input[name="cf_6793_to"]').val() || '';
        if (cf_6793_from != '' || cf_6793_to != '') {
            formData += "&cf_6793[]="+cf_6793_from+"&cf_6793[]="+cf_6793_to;
        }

        // console.log(formData);

        var pagination = '';
        if (type == 'submit'){ //查询前置空数据
            $('#viewPatientScreenList #page').empty();
            $('#viewPatientScreenList #total_pages').empty();
            $('#viewPatientScreenList #total_rows').text('');
            // $('#viewPatientScreenList').data('total_pages','0');
            // $('#viewPatientScreenList').data('total_rows','0');
            // $('#viewPatientScreenList').data('search_where','0');
            $('#viewPatientScreenList').removeData();
        }else{
            var total_pages = parseInt($('#viewPatientScreenList').data('total_pages'));
            var total_rows = parseInt($('#viewPatientScreenList').data('total_rows'));
            pagination += "&page="+page+"&total_pages="+ total_pages+"&total_rows="+ total_rows;
        }


        // var customform02_id_name = $('#viewPatientScreenList select[name=customform02_id_name]').val().trim();
        // var approvestatus = $('#viewPatientScreenList select[name=approvestatus]').val();
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=searchPatientScreen'+pagination,
            data: formData,
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    $('#viewPatientScreenList').data('search_where', data.result.search_where);//保存搜索的where条件,全选时要用

                    var info_str = '';
                    if (data.result.searchinfo.length > 0){
                        $.each(data.result.searchinfo,function(index,infoData){
                            info_str += '<tr>';
                            info_str += '<td><input type="checkbox" name="selected_id" value="'+infoData.accountid+'"></td>';
                            info_str += '<td>'+infoData.accountname+'</td>';
                            info_str += '<td>'+infoData.rating+'</td>';
                            info_str += '<td>'+infoData.cg_hospital+'</td>';
                            info_str += '<td>'+infoData.last_success_visit_date+'</td>';
                            info_str += '<td>'+infoData.last_success_visit_time+'</td>';
                            info_str += '<td>'+infoData.boost_sale+'</td>';
                            info_str += '<td>'+infoData.last_visit_status+'</td>';
                            info_str += '<td>'+infoData.last_fail_visit_date+'</td>';
                            info_str += '<td>'+infoData.last_fail_visit_time+'</td>';
                            info_str += '<td>'+infoData.fail_visit_count+'</td>';
                            info_str += '<td>'+infoData.third_success_count+'</td>';
                            info_str += '<td>'+infoData.third_fail_count+'</td>';
                            info_str += '<td>'+infoData.createdtime+'</td>';
                            info_str += '<td>'+infoData.cg_date+'</td>';
                            info_str += '<td>'+(infoData.unreachable_date || '') +'</td>';
                            info_str += '</tr>';
                        });
                        $("#viewPatientScreenList").find("table tbody").html(info_str);

                        // 渲染翻页导航
                         var total_pages = data.result.total_pages;
                         var total_rows = data.result.total_rows;

                        $('#first-page,#prev-page').toggleClass('disabled', page <= 1);
                        $('#last-page,#next-page').toggleClass('disabled', page >= total_pages);
                        $('#viewPatientScreenList').data('page', page);
                        $('#viewPatientScreenList').data('total_pages', total_pages);
                        $('#viewPatientScreenList #page').text(page);
                        $('#viewPatientScreenList #total_pages').text(total_pages);
                        $('#viewPatientScreenList #total_rows').text(total_rows);

                    }else{
                        $("#viewPatientScreenList").find("table tbody").html("<tr><td colspan='16'><div style='text-align:center;'>无</div></td></tr>");
                    }

                }
            }
        })

    }

    //将所选病人添加到待分配状态
    function addWaitingDistribute() {
        var selected_id_arr = [];
        $('#viewPatientScreenList table input[name="selected_id"]:checked').each(function() {
            selected_id_arr.push($(this).val());
        });

        //如果没有勾选，点击了添加，则 selected_id_arr 为空  默认为添加全部数据。
        // console.log(selected_id_arr);
        var search_where = $('#viewPatientScreenList').data('search_where') || '';
        $.ajax({
            url: 'BaxterPatientScreen.php?mode=update_waiting_distribute&selected_id_arr='+encodeURIComponent(selected_id_arr),
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

                        //点击 添加 后刷新列表
                        searchPatientScreen(1,'submit');
                        $('#selectAll').prop('checked', false);

                    },
                });
            }
        })

    }

    //跳转外包病人预览页
    function outsourcedPatientPreview(){
        var url = "BaxterPatientScreen.php?page=patientscreenpreview";
        window.open(url);
    }

    //隐藏展开搜索条件
    function toggleForm(formname){
        $("#"+formname).toggle();
    }

</script>

</html>