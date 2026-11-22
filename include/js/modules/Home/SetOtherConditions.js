/**
 * Edit: xll
 * Date: 2023/09/04
 * Reason: 首页组件中设置其他查询条件的方法改成类，以以便所有需要的地方同意调用
 */
function SetOtherConditions() {
    var that = this;
    this.DirDataObj = null;     //advance_demand、advance_demand_groups存放的数据对象，利用指针特性，修改对应指针数值即可
    this.AfterOkfunTaskList = [];
    this.poptitle = arrJsPopLabel['SettingOtherConditionJS'];
    this.poptype = '';
    this.module = 'Home';

    this.SetDirDataObj = function (DirDataObj) {
        that.DirDataObj = DirDataObj;
    }
    this.setpoptitle = function (poptitle) {
        that.poptitle = poptitle;
    }
    this.setTypeAndDataObj = function (poptyoe,DirDataObj){
        that.poptype = poptyoe;
        that.DirDataObj = DirDataObj;
    }

    this.SetDirDataObjByRowIndex = function (CurStuffLabelInfo,RowIndex) {
        that.DirDataObj = CurStuffLabelInfo['computeinfo'][RowIndex];
    }

    this.addTaskAfterOkfun = function (Func,ParamsOption) {
        var TaskItem = {
            Function : Func,
            ParamsOption : ParamsOption,
        }
        that.AfterOkfunTaskList.push(TaskItem);
    }

    this.ExcuteAfterOkfunTask = function () {
        var AfterOkfunTaskList = that.AfterOkfunTaskList;
        ld.each(AfterOkfunTaskList,function (Index,TaskItem) {
            var FunObj = TaskItem.Function;
            var ParamsOption = TaskItem.ParamsOption;
            FunObj(ParamsOption);
        });
    }
    
    this.getAjaxUrl = function () {
        return 'index.php?module=Home&action=HomeAjax&file=SalesKitSetOtherCondition';
    }
    
    this.getParams = function (frommodule,includeDetail) {
        return `&frommodule=${frommodule}&includeDetail=${includeDetail}`;
    }

    this.fun_other_conditions = function () {
        //zxm 20230718 新建简报 点击高级查找条件报错的问题
        var computeinfo = that.DirDataObj;
        var frommodule = computeinfo.computemodule;
        var advancedemand =computeinfo.advance_demand;
        var groupcondition=computeinfo.advance_demand_groups;
        if (that.type == 'workBriefReportChuantou'){//工作简报穿透高级查找
            frommodule = computeinfo.penetrateModule;
        }
        if (that.poptype == 'WorkBriefReport'){
            //zkt 20240913 BUG20240913-49 工作简报设置，点击设置查询条件卡死
            frommodule = computeinfo.count_module;
            advancedemand = computeinfo.advft_criteria;
            groupcondition = computeinfo.advft_criteria_groups;
        }
        //edit: xll 2024/07/09 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
        var module = 'Home',
            includeDetail = typeof computeinfo.includeDetail !== "undefined" ? computeinfo.includeDetail : 'yes';

        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
        var advft_criteria_groups_json = groupcondition;
        var advft_criteria_json = advancedemand;
        var params = {};
        if (!empty(advft_criteria_json)){
            params = {'advft_criteria':advft_criteria_json,'advft_criteria_groups':advft_criteria_groups_json};
        }

        crmPopupobj.prevshow();
        ldAjaxNoProgress(that.getAjaxUrl()+that.getParams(frommodule,includeDetail),params ,function(data){
            if(data.code==1){
                crmPopupobj.setParams(that.poptitle,that.set_advancedemand,'',"LdPopWidth800px",'Settings','',data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.createScrollDiv();
                crmPopupobj.show(data.result.content);
                //edit: xll 20/11/14 BUG0074940 企业微信移动端，报表->测试单折线图 点击“筛选”操作按钮没有反应
                var width = CrmPopup.getClientWidth();
                if(width < 800) {
                    var divid = crmPopupobj.divid;
                    ld('#'+divid).css('width',width);
                }
                AjaxJSPage('cls_advanceFilter','include/js/cls_advanceFilter.js');

                var advancefilterobj = new cls_advanceFilter();
                that.advancefilterobj = advancefilterobj;
                var params = {};
                params.columnOptionHtml = data.result.columns_block;
                params.fLabels = data.result.flabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.foption;
                params.fieldsinfo = data.result.fieldinfo;
                params.criteria_groups_arr = data.result.criteria_groups_arr;
                params.module = module;
                params.source = data.result.source;
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advancefilterobj.showAdvanceFilter(crmPopupobj,params);


            }
        });
    }

    this.set_advancedemand = function (){
        var curpopupobj = CrmPopup.getPopupObj('last');
        if(that.advancefilterobj.checkAdvancedFilter()==false)
        {
            return false;
        }
        var advft_criteria = that.advancefilterobj.advft_criteria;
        var advft_criteria_groups = that.advancefilterobj.advft_criteria_groups;
        if (that.poptype == 'WorkBriefReport'){
            that.DirDataObj['advft_criteria']=advft_criteria;
            that.DirDataObj['advft_criteria_groups']=advft_criteria_groups;
        }else {
            that.DirDataObj['advance_demand']=advft_criteria;
            that.DirDataObj['advance_demand_groups']=advft_criteria_groups;
        }
        curpopupobj.CancelEvent();
        that.ExcuteAfterOkfunTask();
    }
}