function BalanceGJPSalesOrderInOut(popupobj) {
    //往来对账

    var balancesalesorderinoutmodules = ['erpOutboundOrder', 'erpCashBill', 'erpInvoice'];


    var that = this;
    that.popupobj = popupobj;
    that.advft_criteria = {};
    that.advft_criteria_groups = {};
    that.advancefieldnames = {};
    that.fields = {};
    that.viewids = {};
    that.advanceset = []; //相关信息栏-高级设置
    //that.searchscopes={};

    this.init = function () {
        var popupobj = this.popupobj;

        var tmparr = balancesalesorderinoutmodules
        var strhtml = '';

        for (var i = 0; i < tmparr.length; i++) {
            strhtml += "<div name='balance_" + popupobj.divid + "_" + tmparr[i] + "'></div>";
        }
        ld('#' + popupobj.divid + ' .DivCTable').html(strhtml);
        for (var i = 0; i < tmparr.length; i++) {
            that.callsearch(tmparr[i]);
        }
    }
    this.callsearch = function (related_module) {
        var popupobj = this.popupobj;
        var divid = popupobj.divid;
        var module = popupobj.headermodule;//相关信息所关联的模块(查看界面的模块)
        var record = popupobj.detailpage_record;//相关信息所关联的
        var related_id = popupobj.relateid;

        var otherurl = popupobj.otherurl;
        var _start = 1;
        var urldata = "&header=SalesOrder"  + "&record=" + record + "";
        urldata += "&relatedid=" + related_id ;
        //urldata += '&currpage=1&related_left_type=1';
        urldata += "&SearchScope=SmOwner_Search_All";
        urldata += '&related_module=GuanJiaPoReport';
        urldata += '&start=1';
        urldata += '&erpModuleName=' + related_module;
        urldata += '&fromtab=GuanJiaPoReport';

        var url = 'index.php?module=Users&action=UsersAjax&file=setRelatedModList' + urldata;
        ldAjax(url,"",function(data){
            if(data.code=="-1") {
                // Popupobj.CancelEvent();
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                DelProgressObjs();
                return false;
            }
            if(data.code==1) {
                ld("#"+popupobj.divid+" [name=balance_"+popupobj.divid+"_"+related_module+"]").html(data.result.content);
                that.fields[related_module]=data.result.fields;
                DelProgressObjs();
            }
        })
        this.popupobj.advanceset = that.advanceset;
        this.popupobj.module = 'GuanJiaPoReport';
    }
}