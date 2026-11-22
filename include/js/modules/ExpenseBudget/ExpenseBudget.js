function ExpenseBudget(){
    var that = this;

    //选中预算人员的事件请求 预算类型为basicBudget时候 需要将用户循环到分录中
    this.selectedUsers = function(){
        var popobj = CrmPopup.getPopupObj('last');
        var budgetType = ld('#'+popobj.divid+' input[name="expensebudget_type"]').val();
        if(budgetType=="basicBudget"){
            this.calculationBudget();
        }
    }
    //预算类型为 按目标 按业绩时候的 点击计算预算 事件
    this.calculationBudget = function (){
        var params = {};
        var popobj = CrmPopup.getPopupObj('last');
        var budgetType = ld('#'+popobj.divid+' input[name="expensebudget_type"]').val();
        params.selected_groupname = ld('#'+popobj.divid+' input[name="budget_person_name"]').val();
        params.selected_groupid = ld('#'+popobj.divid+' input[name="budget_person"]').val();
        params.budgetType = budgetType;
        params.record = ld('#'+popobj.divid+' input[name="record"]').val();

        //请求后台 计算指标金额 参数 预算指标、预算比例、指标起始日期、指标结束日期
        if(budgetType!="basicBudget") {
            params.budget_indicators = ld('#' + popobj.divid + ' input[name="budget_indicators"]').val();
            params.budget_rate = ld('#' + popobj.divid + ' input[name="budget_rate"]').val();
            params.indicators_start_date = ld('#' + popobj.divid + ' input[name="indicators_start_date"]').val();
            params.indicators_end_date = ld('#' + popobj.divid + ' input[name="indicators_end_date"]').val();
        }
        //判断参数不为空
        if(popobj.fields != undefined) {
            for (var i = 0; i < popobj.fields.length; i++) {
                var fieldlabel = htmldecode(popobj.fields[i].fieldlabel);
                var columnname = popobj.fields[i].columnname;
                if (budgetType!="basicBudget" && (columnname=="budget_person"||columnname=="budget_indicators"||columnname=="budget_rate"||columnname=="indicators_start_date"||columnname=="indicators_end_date")
                    && !emptyCheck(columnname,fieldlabel,CrmPopup.findHtmlobj(popobj.divid,columnname).attr("type")))
                {
                    return false;
                }

                if (budgetType=="basicBudget" && (columnname=="budget_person")&& !emptyCheck(columnname,fieldlabel,CrmPopup.findHtmlobj(popobj.divid,columnname).attr("type")))
                {
                    return false;
                }
            }
        }
        //请求路径
        var url = "index.php?module=ExpenseBudget&action=ExpenseBudgetAjax&file=calculationBudget";
        ld('#' + popobj.divid).find('#expenseBudgetDetails .dragtrrow').remove();
        ldAjaxNoProgress(url,params,function(e){
            var detailHtml = e.result.detailHtml;
            ld('#'+popobj.divid+' [tag="trhead"]').after(detailHtml);
            that.setSubTotalRow();
            ld('#' + popobj.divid + ' #expenseBudgetDetails input[name="budget_rate"]').unbind('change').bind('change',function(e){
                that.changeAmount(this);
            });
            ld('#' + popobj.divid + ' input[name="adjustment_amount"]').unbind('change').bind('change',function(){
                that.changeAmount(this);
            });
            ld('#' + popobj.divid + ' input[name="budget_amount"]').unbind('change').bind('change',function(){
                that.changeAmount(this);
            });
            popobj.center();
        });
    }

    this.changeAmount=function(obj){
        var rowindex = ld(obj).parent().parent().attr('rowindex');
        var trobj = ld(obj).parents('tr[rowindex="'+rowindex+'"]');
        var target = trobj.find('input[name="reference_amount"]').val();
        var rate = trobj.find('input[name="budget_rate"]').val();
        var amount = eval(target*rate*0.01);
        var adjustment_amount = trobj.find('input[name="adjustment_amount"]').val();
        //zxm 20230904 kfbcrm-费用预算单-编辑单据（BUD5），点击删除“调整”字段的值，预算金额输入框内显示“NaN”
        adjustment_amount = adjustment_amount==''?0:adjustment_amount;
        var budget_amount =  trobj.find('input[name="budget_amount"]').val();
        budget_amount = budget_amount==''?0:budget_amount;
        //当前改变的值的name
        var currName = ld(obj).attr('name');
        if(currName=='budget_rate'){
            //金额 调整 预算金额 三个改变
            trobj.find('input[name="amount"]').val(amount);
            trobj.find('span[name="span_amount"]').text(amount);
            budget_amount = parseFloat(amount)+parseFloat(adjustment_amount);
            budget_amount = budget_amount.toFixed(2);
            trobj.find('input[name="budget_amount"]').val(budget_amount);
        }else if(currName=='budget_amount'){
            //调整 一个改变
            adjustment_amount = parseFloat(budget_amount)-parseFloat(amount);
            adjustment_amount = adjustment_amount.toFixed(2);
            trobj.find('input[name="adjustment_amount"]').val(adjustment_amount);
        }else if(currName=='adjustment_amount'){
            //预算金额 一个改变
            budget_amount = parseFloat(amount)+parseFloat(adjustment_amount);
            budget_amount = budget_amount.toFixed(2);
            trobj.find('input[name="budget_amount"]').val(budget_amount);
        }
        this.setSubTotalRow();
    }

    //设置小计行
    this.setSubTotalRow = function()
    {
        var popupobj = CrmPopup.getPopupObj('last');
        var subtotalrowobj = ld("#"+popupobj.divid+' [name=detail_subtotal_row]');
        var totalobj = ld("#"+popupobj.divid+' [name=total]');
        var sum_totalobj = ld("#"+popupobj.divid+' [name=sum_total]');
        //四个值 指标金额 金额 调整 预算金额
        var detailFields = popupobj.detailfields;
        var totalTdNames = ['reference_amount','amount','adjustment_amount','budget_amount'];
        ld.each(totalTdNames,function(index,item){
            var objs = ld("#"+popupobj.divid+' [name="'+item+'"]');
            var total = 0;
            ld.each(objs,function(){
                var thisvalue = ld(this).val();
                thisvalue = thisvalue==''?0:thisvalue;
                total += parseFloat(thisvalue);
            });
            total = total.toFixed(2);
            subtotalrowobj.find('[name="subtotal_'+item+'"]').text(total);
            //分录总合计字段值
            if(item=='budget_amount'){
                totalobj.val(total);
                sum_totalobj.text(total);
            }
        });
    }

    //预算指标 启用停用
    this.setIndicatorsStatus = function(obj,name,budgetType){
        var isopen = ld(obj).attr('isopen');
        var newisopen = isopen=='yes'?'no':'yes';
        var color = isopen=='yes'?'#3B7CFF':'red';
        var text = isopen=='yes'?arrJsPopLabel['ENABLE']:'停用';
        var url='index.php?module=ExpenseBudget&action=ExpenseBudgetAjax&file=budgetIndicatorsSave';
        ldAjaxNoProgress(url,{'newisopen':newisopen,'name':name,'budgetType':budgetType},function(e){
            if(e.code==-1){
                RemindsMsg("","LdPopWidth400px","","yes","",e.msg);
            }else{
                ld(obj).attr('isopen',newisopen);
                ld(obj).text(text);
                ld(obj).css('color',color);
            }
        });
    }

    //预算指标 保存
    this.ComboxSave = function(){
        var comboxarr = [];
        var popupobj = CrmPopup.getPopupObj('last');
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        ld("#"+popupobj.divid+" input[tag='combox']").each(function(){
            var comboxname = ld(this).attr('name');
            var comboxtext = {'name':''+comboxname+''};
            comboxarr.push(comboxtext);
        });
        var fieldname=popupobj.fieldname;
        var selectvalue = ld("#"+prevpopupobj.divid+" input[name='budget_indicators']").val();
        var budgetType = ld("#"+prevpopupobj.divid+" input[name='expensebudget_type']").val();
        var url='index.php?module=ExpenseBudget&action=ExpenseBudgetAjax&file=budgetIndicatorsSave';
        //ajax请求
        ldAjaxNoProgress(url,{'fieldname':fieldname,'budgetType':budgetType,'comboxjson':JSON.stringify(comboxarr),'selectvalue':selectvalue},function(data){
            if (data.code == 1) {
                console.log(data.result.budgetTypePicklist);
                that.coverComboxContent(data.result.budgetTypePicklist,fieldname,prevpopupobj);
                popupobj.CancelEvent();
            }else
            {
                var confirm_str = data.msg+arrJsPopLabel['Savefailed'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            }
        });
    }
    //覆盖下拉框内容
    this.coverComboxContent = function(content,fieldname,prevpopupobj){
        prevpopupobj.picklistobjarray[fieldname].picklistcontentarray=content;
        for (var k = 0; k < prevpopupobj.picklistcontent.length; k++) {
            var tmpfieldname=prevpopupobj.picklistcontent[k].fieldname;
            if(tmpfieldname==fieldname)
            {
                prevpopupobj.picklistcontent[k].optionvalue=content;
                break;
            }
        }
    }


    //重算预算金额 列表页操作
    this.reCalculationBudget = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var selectid = ld("#"+popupobj.divid+" [name=allselectedboxes]").val();// document.getElementById('allselectedboxes').value;
        var selectlen = 0;
        if (selectid != 'all') {//非全选状态，依次获取选中的单据ID
            var selectobj = document.getElementsByName("selected_id");
            var selectobjlen = selectobj.length;
            selectid = '';
            for (var i = 0; i < selectobjlen; i++) {
                if (selectobj[i].checked) {//获取选中的ID
                    selectid += selectobj[i].value + ',';
                    selectlen++;
                }
            }
            if (selectid == '') {//请至少选择一条记录
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
                return false;
            }
        } else {
            selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
        }
        var urlstring = 'index.php?module=ExpenseBudget&action=ExpenseBudgetAjax&file=reCalculationBudget&selectid=' + selectid + "&selectlen="+selectlen;
        //超过500条，给出提示
        if (selectlen > getMaxMassOperationLimit()) {
            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
            //创建提示弹出层
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
            //确定事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                fninvshnew('approveSubmit_reminder');
                that.reCalculationSubmit(urlstring, selectid, selectlen);
            });
        } else {
            that.reCalculationSubmit(urlstring, selectid, selectlen);
        }
    }
    //详情页的重算预算金额
    this.reCalculationBudgetDetail = function(record){
        var urlstring = 'index.php?module=ExpenseBudget&action=ExpenseBudgetAjax&file=reCalculationBudget&selectid=' + record + "&selectlen=1";
        that.reCalculationSubmit(urlstring, record, 1);
    }

    this.reCalculationSubmit = function(urlstring, selectid){
        var params = {'selectid':selectid};
        ldAjax(urlstring,params,function(data){
            MessagePopup.TipOne_success('成功');
            //RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg );
            //服务单保存后刷新服务单的历史记录(查看界面)
            var tmparra=new Array();
            var tmpobj= new AfterUpdatePrevPopupObjContent('ExpenseBudget',"",tmparra);
            //服务单保存后刷新服务单的历史记录(查看界面)
            var refreshlistmodules = new Array('ExpenseBudget');
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
            DelProgressObjs();
            return false;
        });
        return false;
    }
}

var ExpenseBudgetObj = new ExpenseBudget();