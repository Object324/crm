//切换页签(切换页签需要刷新批量编辑按钮)
function getCollectionSlipStatus(status,obj){
    ld('#rptContentLoading').show();
    var popupobj=CrmPopup.getPopupObj("last");
    var searchScope = '';
    if(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
        searchScope= encodeURIComponent(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val());
    var urlstring = "module=CollectionSlip&action=CollectionSlipAjax&file=ListView&start=1&SearchScope="+searchScope+"&collectionslip_status="+status;
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
        urlstring += '&isshowModuleListTree=yes';
    }
    urlstring += '&viewname='+ld("#"+popupobj.divid+" #viewname").val();
    if(ld("#"+popupobj.divid+' [name = dv_chzn_selectcustomview_'+module+']').find('a').attr('onclick') == undefined){
        urlstring += '&ajaxtype=ld_linkmodulecustom';
    }

    var listview_page=new ListView_Page('CollectionSlip',urlstring,"pagecontent1");
    listview_page.callback_fun=function() {
        popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
        setContentHeight(module);//计算内容高度
        IsFrameElement();
    }
    listview_page.page();
}

//领取收款认领单
function receive_collectionslip(){
    var popupobj=CrmPopup.getPopupObj('last');
    var idstring = "";
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
    var selectlen = 0;
    var paramobj = '';
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
        //duan 20240621 当只领取一条数据时,也弹出“是否立即填写对应单据信息”提示
        if(selectlen == 1){
            paramobj = selectid.replace(',','');
        }
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    var url = 'index.php?module=CollectionSlip&action=CollectionSlipAjax&file=receive_collectionslip';
    url += '&selectid='+selectid+'&selectlen='+selectlen;
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
			crmPopupobj.prevshow();
			crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,paramobj,data.result.oktext,"",'',"");
			crmPopupobj.selectid=selectid;
            crmPopupobj.show(data.result.content);
        }
    });
}

//释放收款认领单
function release_collectionslip(){
    var popupobj=CrmPopup.getPopupObj('last');
    var idstring = "";
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
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

    var url = 'index.php?module=CollectionSlip&action=CollectionSlipAjax&file=release_collectionslip';
    url += '&selectid='+selectid+'&selectlen='+selectlen;
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext,"");
            crmPopupobj.selectid=selectid;
            crmPopupobj.show(data.result.content);
        }
    });
}

//收款认领单管理操作列 领取 按钮
var receive_collectionsliplist=function(record){
    var url = 'index.php?module=CollectionSlip&action=CollectionSlipAjax&file=receive_collectionslip&fromtype=list';
    url += '&selectid='+record+'&selectlen=1';
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,record,data.result.oktext,"","","");
            crmPopupobj.selectid=record;
            crmPopupobj.show(data.result.content);
        }
    });
}

//收款认领单管理操作列 释放 按钮
var release_collectionsliplist=function(record){
    var url = 'index.php?module=CollectionSlip&action=CollectionSlipAjax&file=release_collectionslip';
    url += '&selectid='+record+'&selectlen=1';
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,"",data.result.oktext,"","","");
            crmPopupobj.selectid=record;
            crmPopupobj.show(data.result.content);
        }
    });
}

//关闭弹窗并刷新页面
function cancel_received(){
	var popupobj=CrmPopup.getPopupObj("last");
    var recordid=popupobj.OkfunParamObj;
    var tmparra=new Array();
    var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
    var refreshlistmodules = new Array(popupobj.module);
    tmpobj.eachrefreshlistbyModules(refreshlistmodules);
	popupobj.CancelEvent();
    //wym 240313 目前只有列表领取按钮传了record值 关闭弹窗后直接打开编辑页面
    if(recordid){
        var confirmstr=arrJsPopLabel['SKIPTOEDIT'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirmstr);
        var popupobj_edit=CrmPopup.getPopupObj('last');
        ld('#'+popupobj_edit.divid+' .E_pbtnok').click(function(){
            detailbutton_click('','CollectionSlip','Edit',recordid);
            return false;
        })
    }
}


