<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>新病人提交</title>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
{*    <script src="{$CRMCOMMONURL}https://cdn.bootcss.com/popper.js/1.14.7/umd/popper.min.js"></script>*}
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/popper.min.js"></script>

    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.js"></script>
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.css" type="text/css" />
    <link href="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap-select.min.css" rel="stylesheet" />
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap-select.min.js"></script>
    <script src="{$CRMCOMMONURL}crmcommon/js/bootstrap-4.6.0-dist/js/defaults-zh_CN.min.js"></script>
    {*表单验证*}
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/jquery.validate.min.js'></script>
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/validate-methods.js'></script>
    {*验证字段的汉化提示包*}
{*    <script src="http://static.runoob.com/assets/jquery-validation-1.14.0/dist/localization/messages_zh.js"></script>*}

    {*弹窗*}
    <script type='text/javascript' src='{$CRMCOMMONURL}include/js/modules/SocialPromotion/layer.js'></script>
{*图标库*}
{*    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">*}
    {*省市区级联*}
    <script src="{$CRMCOMMONURL}crmcommon/js/distpicker/dist/distpickerBaxter.js"></script>
    <style>
        /*input.error { border: 1px solid red; }*/
        /*label.error {
            !*padding-left: 16px;*!
            !*padding-bottom: 2px;*!
            font-weight: bold;
            color: #EA5200;
        }*/
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

    </style>
</head>
<body>
    <div class="container" id="createNewPatientHome" style="margin:100px auto;">
        <div class="row">
            <div class="col-sm">
                <div type="button" id="createNewPatient" class="btn btn-success btn-lg btn-block">创建新病人提交</div>
                <small class="form-text text-muted">为自己负责的医院提交新病人信息</small>
            </div>
            <div class="col-sm">
                <div type="button" id="viewNewPatient" class="btn btn-success btn-lg btn-block">查看新病人提交</div>
                <small class="form-text text-muted">查看已提交的新病人信息</small>
            </div>
        </div>
    </div>

    {*表单*}
    <div class="container" id="createNewPatientForm" style="display: none;max-width：90%;">
        <div class="card" style="padding:20px; margin-top:20px">
            <div style="color: red;">
                <p>PS：1、家庭电活和病人手机至少填一个，请尽可能同时收集并填写家庭电话和病人手机；</p>
                <p>2、新病人提交备注信息审批通过后转入到病人插管信息备注中。</p>
                <p>3、新病人提交后无法修复信息，如信息有误，请邮件联系PMS管理员 fengling_Ii@baxter.com。</p>
            </div>
{*            <h6 class="p-3 mb-2 bg-info bg-gradient text-white">基本信息</h6>*}
            <div class="card bg-info text-white mb-2">
                <div class="card-body">基本信息</div>
            </div>
            <form id="patientForm" action="">
                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="uid" class="col-sm-4 col-form-label">销售ID</label>
                            <div class="col-sm-8">
                                <input type="text" disabled class="form-control-plaintext" id="uid" value="{$uid}">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="uid_salename" class="col-sm-4 col-form-label">销售姓名</label>
                            <div class="col-sm-8 text-left">
                                <span class="form-control-plaintext" id="uid_salename">{$uid_salename}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5891" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 姓名</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="cf_5891" id="cf_5891" value="" {*required*}>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5999" class="col-sm-4 col-form-label">家庭电话</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="cf_5999" id="cf_5999" value="">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5892" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 性别</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_5892" id="cf_5892">
                                    <option value="">--无--</option>
                                    <option value="男">男</option>
                                    <option value="女">女</option>
                                </select>

                                {*<div class="form-check form-check-inline">
                                    <label class="form-check-label" for="man"><input class="form-check-input" type="radio" name="sex" id="man" value="man">
                                        男</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <label class="form-check-label" for="female"><input class="form-check-input" type="radio" name="sex" id="female" value="female">
                                        女</label>
                                </div>*}
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5998" class="col-sm-4 col-form-label">病人手机</label>
                            <div class="col-sm-8">
                                <input type="tel" class="form-control" name="cf_5998" id="cf_5998" value="" maxlength="11" oninput="validateNumberInput(this)">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5893" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 出生年月</label>
                            <div class="col-sm-8">
                                <input type="date" class="form-control" name="cf_5893" id="cf_5893">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6009" class="col-sm-4 col-form-label">家庭电话2</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="cf_6009" id="cf_6009" value="">
                            </div>
                        </div>
                    </div>
                </div>

                <div id="distpicker" data-toggle="distpicker" {*data-autoselect="3"*}>{*省市区字段select非得连起来才行*}
                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="bill_state" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 居住省份</label>
                            <div class="col-sm-8">
{*                                <input type="text" class="form-control" name="bill_state" id="bill_state">*}
                                <select class="form-control" name="bill_state" id="bill_state"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6008" class="col-sm-4 col-form-label">家属手机</label>
                            <div class="col-sm-8">
                                <input type="tel" class="form-control" name="cf_6008" id="cf_6008" value="" maxlength="11" oninput="validateNumberInput(this)">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="bill_city" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 居住城市</label>
                            <div class="col-sm-8">
{*                                <input type="text" class="form-control" name="bill_city" id="bill_city">*}
                                <select class="form-control" name="bill_city" id="bill_city"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6007" class="col-sm-4 col-form-label">家属电话</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="cf_6007" id="cf_6007" value="">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="bill_area" class="col-sm-4 col-form-label">居住县</label>
                            <div class="col-sm-8">
{*                                <input type="text" class="form-control" name="bill_area" id="bill_area">*}
                                <select class="form-control" name="bill_area" id="bill_area"></select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6010" class="col-sm-4 col-form-label">其他电话</label>
                            <div class="col-sm-8">
                                <input type="text" class="form-control" name="cf_6010" id="cf_6010" value="">
                            </div>
                        </div>
                    </div>
                </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5898" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 地址</label>
                            <div class="col-sm-8">
                                <textarea class="form-control" name="cf_5898" id="cf_5898"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6245" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 付费方式</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_6245" id="cf_6245">
                                    <option value="">--无--</option>
                                    <option value="城镇职工医保">城镇职工医保</option>
                                    <option value="城镇居民医保">城镇居民医保</option>
                                    <option value="外来务工人员医保">外来务工人员医保</option>
                                    <option value="新农合">新农合</option>
                                    <option value="自费">自费</option>
                                    <option value="不知">不知</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5900" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 插管日期</label>
                            <div class="col-sm-8">
                                <input type="date" class="form-control" name="cf_5900" id="cf_5900">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5894" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 原发病</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_5894" id="cf_5894">
                                    <option value="">--无--</option>
                                    <option value="糖尿病">糖尿病</option>
                                    <option value="高血压">高血压</option>
                                    <option value="急性肾衰">急性肾衰</option>
                                    <option value="肾小球肾炎">肾小球肾炎</option>
                                    <option value="狼疮肾">狼疮肾</option>
                                    <option value="多囊肾">多囊肾</option>
                                    <option value="其它">其它</option>
                                    <option value="不知">不知</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="customform02_id_name" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 插管医院</label>
                            <div class="col-sm-8 btn-group">{*关联选择【CDC医院模块】只允许选择销售负责的医院*}
                                <input type="text" class="form-control" name="customform02_id_name" id="customform02_id_name" columnname="customform02_id" onkeyup="getKeyWordsSearch(this,event)" onfocus="getKeyWordsSearch(this,event)" autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform02_id" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" value="X" onclick="clear_choose_related(this,event,'customform02_id');return false;">X</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="customform02_id_jxs_name" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 经销商{*（可输入经销商全名连续关键词搜索）*}</label>
                            <div class="col-sm-8 btn-group">{*关联选择【CDC医院模块】只能选择‘类型’为经销商*}
                                <input type="text" class="form-control" name="customform02_id_jxs_name" id="customform02_id_jxs_name" columnname="customform02_id_jxs" onkeyup="getKeyWordsSearch(this,event)" onfocus="getKeyWordsSearch(this,event)" autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform02_id_jxs" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" value="X" onclick="clear_choose_related(this,event,'customform02_id_jxs');return false;">X</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="customform47_id_name" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 插管医生</label>
                            <div class="col-sm-8 btn-group">{*关联选择【HCP医生模块】只允许选择所选插管医院底下的医生*}
                                <input type="text" class="form-control" name="customform47_id_name" id="customform47_id_name" columnname="customform47_id" onkeyup="getKeyWordsSearch(this,event)" onfocus="getKeyWordsSearch(this,event)" autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform47_id" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" value="X" onclick="clear_choose_related(this,event,'customform47_id');return false;">X</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="customform47_id_2_name" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 主治医生{*（有能力确定腹透处方的医生）*}</label>
                            <div class="col-sm-8 btn-group">{*关联选择【HCP医生模块】只允许选择所选插管医院底下的医生*}
                                <input type="text" class="form-control" name="customform47_id_2_name" id="customform47_id_2_name" columnname="customform47_id_2" {*onkeyup="getKeyWordsSearch(this,event)"*} onkeydown="getKeyWordsSearch(this,event)" onfocus="getKeyWordsSearch(this,event)" autocomplete="off" placeholder="可输入关键词搜索">
                                <input type="hidden" name="customform47_id_2" value="">
                                <button class="btn btn-danger btn-sm ml-1" type="button" title="清除" value="X" onclick="clear_choose_related(this,event,'customform47_id_2');return false;">X</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_6244" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 使用的腹透管路类型</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_6244" id="cf_6244">
                                    <option value="">--无--</option>
                                    <option value="Medcomp简包">Medcomp简包</option>
                                    <option value="Medcomp全包">Medcomp全包</option>
                                    <option value="其它">其它</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5902" class="col-sm-4 col-form-label">备注</label>
                            <div class="col-sm-8">
                                <textarea class="form-control" name="cf_5902" id="cf_5902"></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_9116" class="col-sm-4 col-form-label"><span style="color: red;">*</span> 腹透液类型</label>
                            <div class="col-sm-8">
                                <select class="form-control" name="cf_9116" id="cf_9116">
                                    <option value="">--无--</option>
                                    <option value="百特葡萄糖">百特葡萄糖</option>
                                    <option value="百特葡萄糖和艾考">百特葡萄糖和艾考</option>
                                    <option value="其他品牌葡萄糖和艾考">其他品牌葡萄糖和艾考</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-group row">
                    <div class="col-sm-6" style="display: flex;justify-content: flex-end;">
                        {*<div align="center" id="patientInfoSubmit" class="btn btn-primary" data-toggle="modal"
                             data-target="#staticBackdrop">提交
                        </div>*}
                        <button class="submit btn btn-primary">提交</button>
                        {*<input type="submit" align="center" id="patientInfoSubmit" class="btn btn-primary" data-toggle="modal"
                               data-target="#staticBackdrop">*}
                    </div>
                    <div class="col-sm-6">
{*                        <div align="center" id="patientInfoCancel" class="btn btn-secondary">取消</div>*}
                        <span id="patientInfoCancel" class="reset btn btn-danger">取消</>
                    </div>
                </div>

            </form>
        </div>
    </div>

    {*模态框*}
    <div class="modal fade" id="staticBackdrop" tabindex="-1" data-backdrop="static" data-keyboard="false" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">温馨提示</h5>
                </div>
                <div class="modal-body">
                    <p>信息已保存成功！</p>
                </div>
                <div class="modal-footer">
                    <div id="staticBackdropConfirm" class="btn btn-secondary" data-dismiss="modal">确定</div>
                </div>
            </div>
        </div>
    </div>

    <div id="SearchResult" class="SearchResult" style="display: none;max-height:250px;overflow-y: auto;">
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
                    <th>腹透液类型</th>
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

    {*查看提交的新病人列表*}
    <div class="{*container*}" id="viewNewPatientList" style="padding:20px; margin:20px;display: none;">
        <div class="card bg-success text-white" style="font-size: 18px;">
            <div class="card-body">新病人提交结果查看</div>
        </div>
{*        <h5 class="p-3 mb-2 bg-info bg-gradient text-white" style="font-size: 18px;">新病人提交结果查看</h5>*}

        <div class="card" style="padding:20px; margin-top:20px">
            <div class="card bg-info text-white mb-2">
                <div class="card-body">查询条件</div>
            </div>
            <form>
                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="year" class="col-sm-4 col-form-label"> 查询年份</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" name="year" id="year" value="" disabled>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="customform02_id_name" class="col-sm-4 col-form-label">插管医院</label>
                            <div class="col-sm-8">
{*                                <input type="text" class="form-control" name="customform02_id_name" id="customform02_id_name" columnname="customform02_id" onkeyup="getHospitalKeyWords(this,event)" *}{*autocomplete="off"*}{* placeholder="可输入关键词搜索">*}
                                <select class="form-control selectpicker" name="customform02_id_name" id="customform02_id_name"  data-live-search="true" data-live-search-placeholder="搜索" data-actions-box="true">
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row text-right">
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="month" class="col-sm-4 col-form-label"> 查询月份</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" name="month" id="month" value="" disabled>
                                {*<select class="form-control selectpicker" name="month" id="month"  data-live-search="true" data-live-search-placeholder="搜索" data-actions-box="true">
                                    <option value="">--</option>
                                    <option value="1">1</option>
                                    <option value="2">2</option>
                                    <option value="3">3</option>
                                    <option value="4">4</option>
                                    <option value="5">5</option>
                                    <option value="6">6</option>
                                    <option value="7">7</option>
                                    <option value="8">8</option>
                                    <option value="9">9</option>
                                    <option value="10">10</option>
                                    <option value="11">11</option>
                                    <option value="12">12</option>
                                </select>*}
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="form-group row">
                            <label for="cf_5999" class="col-sm-4 col-form-label">审批状态</label>
                            <div class="col-sm-4">
                                <select class="form-control" name="approvestatus" id="approvestatus">
                                    <option value="">--</option>
                                    <option value="待审批">待审批</option>
                                    <option value="已批准">已批准</option>
                                    <option value="已拒绝">已拒绝</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row" id="patientSeemRepeat">
                    <div class="col-sm-6" style="display:flex;justify-content: flex-end;">
                        <span id="searchNewPatient" class=" btn btn-success" onclick="searchNewPatient()">查询</span>
                    </div>
                    <div class="col-sm-6">
                        <span id="viewNewPatientReturn" class="btn btn-danger">返回</span>
                        </span></div>
                </div>
            </form>
            <div class="card bg-info text-white mt-2">
                <div class="card-body">新病人提交数据<span id="NewPatientCount"></span></div>
            </div>
{*            <div class="pre-scrollable">*}{*table 设置滚动条*}
            <table class="table  table-striped">
                <thead>
                <tr>
                    <th>新病人提交名</th>
                    <th>姓名</th>
                    <th style="width:6%">居住省份</th>
                    <th style="width:6%">居住城市</th>
                    <th style="width:6%">插管日期</th>
                    <th>插管医院</th>
                    <th style="width:6%">插管医生</th>
                    <th>提交腹透液类型</th>
                    <th style="width:6%">审批状态</th>
                    <th>审批时间</th>
                    <th>拒绝原因/备注</th>
                </tr>
                </thead>

                <tbody>
                {*<tr><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td>6</td><td>7</td></tr>
                <tr><td>11</td><td>22</td><td>33</td><td>44</td><td>55</td><td>66</td><td>77</td></tr>*}
                </tbody>
            </table>
{*            </div>*}
        </div>

    </div>

</body>
<script>
    // $('.container').show();

    $('#createNewPatient').unbind('click').bind('click',function(){
        $('.container').hide();
        $('#createNewPatientForm').show();
    });

    $('#viewNewPatient').unbind('click').bind('click',function(){
        $('.container').hide();
        $('#viewNewPatientList').show();

        var date = new Date();
        $('#viewNewPatientList input[name=year]').val(date.getFullYear());//默认当前年份
        $('#viewNewPatientList input[name=month]').val(date.getMonth()+1);//默认当前月份
        // $("#viewNewPatientList").find("select[name=month]").val(date.getMonth()+1);//默认当前月份
        // $('#viewNewPatientList input[name=month]').selectpicker('val', date.getMonth()+1);


        //显示插管医院下拉选项
        $.ajax({
            url: 'newpatientsubmitted.php?mode=showCgHospital&uid='+uid,
            data: '',
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                // $("#viewNewPatientList").find("select[name=customform02_id_name]").empty();//应该先清空再赋值，但是不生效
                // $("#viewNewPatientList").find("select[name=customform02_id_name]").selectpicker('refresh');

                if (data.code==1){
                    var info_str = '';
                    if (data.result.searchinfo.length > 0){
                        info_str += '<option value="">--</option>';
                        $.each(data.result.searchinfo,function(index,infoData){
                            info_str += '<option billno="'+infoData.billno+'" value="'+infoData.hospital+'" >'+infoData.hospital+'</option>';
                        });
                        $("#viewNewPatientList").find("select[name=customform02_id_name]").html(info_str);
                    }else{
                        $("#viewNewPatientList").find("select[name=customform02_id_name]").html('<option value="">--</option>');
                    }
                    $('#viewNewPatientList').find("select[name=customform02_id_name]").selectpicker('refresh');//刷新下拉框选项值
                }


            }
        })
    });

    /*$('#staticBackdropConfirm').unbind('click').bind('click',function(){
        $('.container').show();
        $('#createNewPatientForm').hide();
    });*/

    $('#patientInfoCancel,#patientRepeatCancel,#patientSeemRepeatCancel,#viewNewPatientReturn').unbind('click').bind('click',function(){
        $("#patientForm")[0].reset();
        $('.container').hide();
        $('#createNewPatientHome').show();
        $('input').attr('readonly', false);
        $("#patientForm .submit").attr('disabled',false);//提交按钮置灰，防止重复提交

        $.validator.messages.required = '';
        // window.location.reload();
    });
    $('#viewNewPatientReturn').unbind('click').bind('click',function(){
        window.location.reload();
    });

</script>
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

    function validateNumberInput(input) {
        // 移除所有非数字字符
        input.value = input.value.replace(/\D/g, '');

        // 限制长度不超过11位
        if (input.value.length > 11) {
            input.value = input.value.slice(0, 11);
        }
    }
</script>
<script>
    var endremarks = '<p>保存成功！</p>';
    var Close ='关闭';
    var currentURL = getcurrentURL();
    var uid = $("#uid").val();//销售ID

    function getKeyWordsSearch(obj, event){
        // console.log("边输入边搜索");
        console.log(event);
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
        if (columnname == 'customform47_id' || columnname == 'customform47_id_2'){ //选择插管医生、主治医生前，需要先选择插管医院
            var customform02_id_val = $("input[name=customform02_id]").val();
            if (customform02_id_val == '' || parseInt(customform02_id_val)<1){
                // alert("请先选择插管医院");
                layer.open({ content: '请先选择插管医院', btn: Close, yes: function(){ var index = layer.open(); layer.close(index); }, });
                $("#"+columnname+"_name").val('');
                $("input[name=customform02_id_name]").focus();
                return;
            }

            addurl = "&customform02_id="+customform02_id_val;
        }

        $.ajax({
            url: currentURL+'newpatientsubmitted.php?mode=search&uid='+uid,
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
                    var info_str = '<table class="table table-dark table-hover"><tbody>';

                    if (searchinfo.length>0){
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
        //初始化省市区级联插件 省市区字段select标签需要在一个div里，且为连续
        // $("#distpicker").distpicker();
        $("#distpicker").distpicker({
            province: '---- 所在省 ----',
            city: '---- 所在市 ----',
            district: '---- 所在区/县 ----'
        });

        // 在键盘按下并释放及提交后验证提交表单
        $("#patientForm").validate({
            rules: {
                // 生成字段验证信息
                cf_5891: { required:true,},
                cf_5892: { required:true,},
                cf_5893: { required:true,},
                bill_state: { required:true,},
                bill_city: { required:true,},
                cf_5898: { required:true,},
                cf_5900: { required:true,},
                customform02_id: { required:true,},
                customform02_id_name: { required:true,},
                customform47_id: { required:true,},
                customform47_id_name: { required:true,},
                cf_6244: { required:true,},
                cf_9116: { required:true,},
                cf_6245: { required:true,},
                cf_5894: { required:true,},
                customform02_id_jxs: { required:true,},
                customform02_id_jxs_name: { required:true,},
                customform47_id_2: { required:true,},
                customform47_id_2_name: { required:true,},
            },
            /*messages: {
                username: {
                        required: "请输入姓名",  // 如果提交的时候没有填写提示的文字
                    },
                telephone: {
                              required: "年龄不能为空",
                                    range: "年龄范围是18~30"
                           },
                  },*/
            errorPlacement: function(error, element) {
                // error.appendTo(element.parent());
                return false;//隐藏错误消息 return false;  不隐藏使用   error.appendTo(element.parent());
            },
            //验证通过提交事件
            submitHandler:function (form) {
                // BUG20240828-56 240829 姓名字段 cf_5891 校验：只能输入中文、字母和“.”（英文句号）
                var cf_5891 = $('#cf_5891').val();
                var name_pattern = /^[\u4e00-\u9fa5a-zA-Z.]+$/;
                if (!name_pattern.test(cf_5891)) {
                    layer.open({
                        content: '姓名中存在其他字符，请输入规范的姓名！',
                        btn: Close,
                        yes: function () {
                            var index = layer.open();
                            layer.close(index);
                        },
                    });

                    $('#cf_5891').focus();
                    return false;
                }

                //病人手机cf_5998和家庭电话cf_5999必须填一个否则不允许保存
                var cf_5998 = $('#cf_5998').val();
                var cf_5999 = $('#cf_5999').val();
                if (cf_5998.length<1 && cf_5999.length<1){
                    // alert("病人手机和家庭电话必须填一个");
                    layer.open({ content: '病人手机和家庭电话必须填一个', btn: Close, yes: function(){ var index = layer.open(); layer.close(index); }, });
                    $('#cf_5998').focus();
                    return false;
                }

                var cf_6008 = $('#cf_6008').val();
                if ((cf_5998 !='' && cf_5998.length != 11) || (cf_6008 !='' && cf_6008.length != 11)){
                    layer.open({ content: '手机号需要为11位', btn: Close, yes: function(){ var index = layer.open(); layer.close(index); }, });
                    //$('#cf_5998').focus();
                    return false;
                }

                var cf_5900 = $('#cf_5900').val();
                var selectedDate = new Date(cf_5900);// 获取所选日期的值
                var currentDate = new Date();// 获取当前日期的值
                if (selectedDate > currentDate) { // 比较所选日期和当前日期
                    layer.open({ content: '插管日期不能大于当前日期', btn: Close, yes: function(){ var index = layer.open(); layer.close(index); }, });
                    $('#cf_5900').val('');
                    $('#cf_5900').focus();
                    return false;
                }
                $("#patientForm .submit").attr('disabled',true);
                // form.submit();
                $.ajax({
                    url: 'newpatientsubmitted.php?mode=checkrepeat&uid='+uid,
                    data: $('#patientForm').serialize(),
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    success: function (data) {
                        $('.container').hide();
                        $('#repeatlist input[name=is_repeat]').val(data.result.is_repeat);
                        $('#repeatlist input[name=repeat]').val(JSON.stringify(data.result.repeat));

                        if (data.code==1){
                            if (data.result.is_repeat == 'repeat'){
                                var info_str = '';
                                $.each(data.result.repeat,function(index,infoData){
                                    info_str += '<tr>';
                                    info_str += '<td></td>';
                                    info_str += '<td></td>';
                                    info_str += '<td>'+infoData.phone+'</td>';
                                    info_str += '<td></td>';
                                    info_str += '<td></td>';
                                    info_str += '<td></td>';
                                    info_str += '<td></td>';
                                    info_str += '<td>'+infoData.source+'</td>';
                                    info_str += '</tr>';
                                });
                                $("#repeatlist").find("table tbody").html(info_str);
                                $('#repeatlist').show();//显示重复的病人列表
                                $('#patientSeemRepeat').hide();
                                $('#patientRepeat').show();//显示列表底部按钮
                                $('#tabletitle').html('重复病人列表');

                                saveNewPatient(); //重复的直接保存
                            }else if(data.result.is_repeat == 'seemrepeat'){
                                var info_str = '';
                                $.each(data.result.repeat,function(index,infoData){
                                    info_str += '<tr>';
                                    info_str += '<td>'+infoData.repeat_type+'</td>';
                                    info_str += '<td>'+infoData.name+'</td>';
                                    info_str += '<td>'+infoData.phone+'</td>';
                                    info_str += '<td>'+infoData.address+'</td>';
                                    info_str += '<td>'+infoData.hospital+'</td>';
                                    info_str += '<td>'+infoData.futouye_type+'</td>';
                                    info_str += '<td>'+infoData.status+'</td>';
                                    info_str += '<td>'+infoData.source+'</td>';
                                    info_str += '</tr>';
                                });
                                $("#repeatlist").find("table tbody").html(info_str);
                                $('#repeatlist').show();//显示疑似重复的病人列表
                                $('#patientRepeat').hide();
                                $('#patientSeemRepeat').show();//显示列表底部按钮
                                $('#tabletitle').html('疑似重复病人列表');

                                //点击确认保存新病人数据，点击取消不保存
                            }
                            else{ //检查没有重复的病人，可以提交保存
                                saveNewPatient();
                            }

                        }else{
                            //信息框
                            layer.open({
                                // content: MsgSubmit,
                                content: data.msg,
                                btn: Close,
                                yes: function(){
                                    var index = layer.open();
                                    layer.close(index);
                                },
                            });
                        }


                    }
                })
            }
        });

        // $("#reset").click(function() {
        //     validator.resetForm();
        // });

    });

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
        if (columnname == 'customform02_id'){
            $("#customform47_id_name").attr('readonly', false);
            $("#customform47_id_name").val('');
            $("input[name=customform47_id]").val('');

            $("#customform47_id_2_name").attr('readonly', false);
            $("#customform47_id_2_name").val('');
            $("input[name=customform47_id_2]").val('');
        }


    }

    //疑似重复病人的弹窗
    function saveSeemRepeat(){
        if(confirm("确认提交疑似重复病人?")){
            saveNewPatient();
        }else{
            window.location.reload();
        }
    }

    //判断是否重复后，保存新病人信息（通用）
    function saveNewPatient() {
        $('#patientSeemRepeatSubmit').removeAttr('onclick');

        var is_repeat = $('#repeatlist input[name=is_repeat]').val();
        var repeat = $('#repeatlist input[name=repeat]').val();

        $.ajax({
            url: 'newpatientsubmitted.php?mode=save&uid='+uid+'&is_repeat='+is_repeat+'&repeat='+encodeURIComponent(repeat),
            data: $('#patientForm').serialize(),
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    if (is_repeat == 'repeat'){ //保存后无操作

                    }else if(is_repeat == 'seemrepeat'){
                        layer.open({
                            content: endremarks,
                            btn: Close,
                            yes: function(){
                                // 清空表单
                                var index = layer.open();
                                layer.close(index);
                                window.location.reload();
                            },
                        });
                    }else{ //新增新病人，保存后弹出保存成功，点击返回首页返回
                        // console.log(data);
                        //信息框
                        layer.open({
                            // content: MsgSubmit,
                            content: endremarks,
                            btn: Close,
                            yes: function(){
                                // 清空表单
                                var index = layer.open();
                                layer.close(index);
                                window.location.reload();

                                // $('#patientInfoCancel').click();
                                // $("#patientForm input").attr('readonly', false);

                            },
                        });
                    }


                }else{
                    //信息框
                    layer.open({
                        // content: MsgSubmit,
                        content: data.msg,
                        btn: Close,
                        yes: function(){
                            var index = layer.open();
                            layer.close(index);
                        },
                    });
                }


            }
        })
    }

    function searchNewPatient(){
        // var year = $('#viewNewPatientList input[name=year]').val().trim();
        // var month = $('#viewNewPatientList select[name=month]').val();
        var date = new Date();//由于年份 月份 不允许销售员更改，因此防止私自使用F12修改，故做一下调整
        var year = date.getFullYear();
        var month = date.getMonth()+1;

        // var customform02_id_name = $('#viewNewPatientList select[name=customform02_id_name]').selectpicker().val().trim();//or $('#viewNewPatientList select[name=customform02_id_name]').val().trim();
        var customform02_id_name = $('#viewNewPatientList select[name=customform02_id_name]').val().trim();
        var approvestatus = $('#viewNewPatientList select[name=approvestatus]').val();
        $.ajax({
            url: 'newpatientsubmitted.php?mode=searchNewPatient&uid='+uid+'&year='+year+'&month='+month+'&customform02_id_name='+encodeURIComponent(customform02_id_name)+'&approvestatus='+encodeURIComponent(approvestatus),
            data: '',
            type: 'POST',
            dataType: 'json',
            async: false,
            timeout: 5000,
            success: function (data) {
                if (data.code==1){
                    var info_str = '';
                    if (data.result.searchinfo.length > 0){
                        $.each(data.result.searchinfo,function(index,infoData){
                            info_str += '<tr>';
                            info_str += '<td>'+infoData.billno+'</td>';
                            info_str += '<td>'+infoData.patient_name+'</td>';
                            info_str += '<td>'+infoData.juzhu_province+'</td>';
                            info_str += '<td>'+infoData.juzhu_city+'</td>';
                            info_str += '<td>'+infoData.cg_date+'</td>';
                            info_str += '<td>'+infoData.hospital+'</td>';
                            info_str += '<td>'+infoData.doctor_name+'</td>';
                            info_str += '<td>'+infoData.futouye_type+'</td>';
                            info_str += '<td>'+infoData.approvestatus+'</td>';
                            info_str += '<td>'+infoData.approvetime+'</td>';
                            info_str += '<td>'+infoData.reject_cause+'</td>';
                            info_str += '</tr>';
                        });
                        $("#viewNewPatientList").find("table tbody").html(info_str);
                        //BUG0063605 20230327 新病人提交结果添加总数
                        $("#NewPatientCount").html("("+data.result.total+")");
                    }else{
                        $("#viewNewPatientList").find("table tbody").html("<tr><td colspan='10'><div style='text-align:center;'>无</div></td></tr>");
                        $("#NewPatientCount").html("(0)");
                    }


                }


            }
        })
    }

</script>
<script>
    (function( factory ) {
        if ( typeof define === "function" && define.amd ) {
            define( ["jquery", "../jquery.validate"], factory );
        } else {
            factory( jQuery );
        }
    }(function( $ ) {

        /*
         * Translated default messages for the jQuery validation plugin.
         * Locale: ZH (Chinese, 中文 (Zhōngwén), 汉语, 漢語)
         */
        $.extend($.validator.messages, {
            required: "必填字段",
            remote: "请修正此字段",
            email: "请输入有效的电子邮件地址",
            url: "请输入有效的网址",
            date: "请输入有效的日期",
            dateISO: "请输入有效的日期 (YYYY-MM-DD)",
            number: "请输入有效的数字",
            digits: "只能输入数字",
            creditcard: "请输入有效的信用卡号码",
            equalTo: "你的输入不相同",
            extension: "请输入有效的后缀",
            maxlength: $.validator.format("最多可以输入 {0} 个字符"),
            minlength: $.validator.format("最少要输入 {0} 个字符"),
            rangelength: $.validator.format("请输入长度在 {0} 到 {1} 之间的字符串"),
            range: $.validator.format("请输入范围在 {0} 到 {1} 之间的数值"),
            max: $.validator.format("请输入不大于 {0} 的数值"),
            min: $.validator.format("请输入不小于 {0} 的数值")
        });

    }));
</script>
</html>