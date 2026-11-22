/**
 * 朗捷 报关单 隐藏某些字段  用在展示报关单页面
 * @constructor
 */
function HideDetail(){
   
    var popupobj = CrmPopup.getPopupObj("last"),
        rowcnt = ld('#' + popupobj.divid + ' [name="rowcnt"]').get(0).value;
    if (popupobj.pagetype == "detailview_modulepage") {  //展示
        /*if (popupobj.column_fields_value.declare_type[0] == '出口') {
            ld("#" + popupobj.divid + " [name=detail_sf146]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf146]").hide();
            ld("#" + popupobj.divid + " [name=detail_sf145]").show();
            ld("#" + popupobj.divid + " [name=subtotal_sf145]").show();
            for (var i = 1; i <= eval(rowcnt) + 1; i++) {
                ld("#" + popupobj.divid + " [name=detail_sf146" + i + "]").hide();
                ld("#" + popupobj.divid + " [name=detail_sf145" + i + "]").show();
            }
        }
        if (popupobj.column_fields_value.declare_type[0] == '进口') {
            ld("#" + popupobj.divid + " [name=detail_sf145]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf145]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf146]").show();
            ld("#" + popupobj.divid + " [name=detail_sf146]").show();
            for (var i = 1; i <= eval(rowcnt) + 1; i++) {
                ld("#" + popupobj.divid + " [name=detail_sf145" + i + "]").hide();
                ld("#" + popupobj.divid + " [name=detail_sf146" + i + "]").show();
            }
        }*/
    } else { //编辑 新建
        if (popupobj.columnfields_value.declare_type == null) {
            return false;
        }
        /*if (popupobj.columnfields_value.declare_type == '出口') {
            ld("#" + popupobj.divid + " [name=detail_sf146]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf146]").hide();
            ld("#" + popupobj.divid + " [name=detail_sf145]").show();
            ld("#" + popupobj.divid + " [name=subtotal_sf145]").show();
            for (var i = 1; i <= eval(rowcnt) + 1; i++) {
                ld("#" + popupobj.divid + " [name=detail_sf146" + i + "]").hide();
                ld("#" + popupobj.divid + " [name=detail_sf145" + i + "]").show();
            }
        }
        if (popupobj.columnfields_value.declare_type == '进口') {
            ld("#" + popupobj.divid + " [name=detail_sf145]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf145]").hide();
            ld("#" + popupobj.divid + " [name=subtotal_sf146]").show();
            
            ld("#" + popupobj.divid + " [name=detail_sf146]").show();
            for (var i = 1; i <= eval(rowcnt) + 1; i++) {
                ld("#" + popupobj.divid + " [name=detail_sf145" + i + "]").hide();
                ld("#" + popupobj.divid + " [name=detail_sf146" + i + "]").show();
            }
        }*/
    }
}
// 朗捷列表报关单邮件
function exportCustomsOrderEmail(module,selectidstring,setype){
    // 打开新连接 跳转到发送邮件页面
    this.openSendEmail = function (zipName,fileSuffix,zipData) {
        var page_addurl=encodeURIComponent("&attachment="+encodeURI(zipData.result.zipName)+"&emailtitle="+encodeURI(zipData.result.returntitle)+"&fromModule="+module);

        var URL='index.php?pageto_module=Emails&pageto_action=EditView&page_addurl='+page_addurl;
        window.open(URL);
    }
    getXlsxZip(module,selectidstring,setype,this.openSendEmail);
}

// 朗捷列表报关单导出
function ExportCustomsOrder(module,selectidstring,setype){
    this.getResult =function(fileName,fileSuffix){
        var surl = 'index.php?module=' + module + "&action=" + module + "Ajax&file=ExportResult&langjieExport=true&fileName="+fileName+"&fileSuffix="+fileSuffix;
        ldAjax(surl,'',function (data) {
            DelProgressObjs();
            if (data.code == 1) {
                var crmPopupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth500px", module, "", '', "", "");
                crmPopupobj.show(data.result.content);
            }
        });
    }
    getXlsxZip(module,selectidstring,setype,this.getResult);
}

/**
 * 获取选择的数据 生成xlsx 多个打包
 * @param module
 * @param selectcount
 * @param selectidstring
 * @param setype
 * @param getResult
 */
function getXlsxZip(module,selectidstring,setype,getResult){
    var that =this;
    this.createFileAjax ='';
    this.eachExportNum = 1; //每次导出数量
    this.times =1; //第几次导出
    this.selectcount=0;
    this.fileArr=[]; //每次返回的文件集合
    this.init = function () {
        if(!that.alertRemindsMsg()){
            return false
        }else{
            that.createExportProgress();
        }
    }
    this.alertRemindsMsg= function () {
        // list_view和detail_view 的selectidstirng 不一样， list 以;结尾  detail的只有单个数字没有符号
        // 修复朗捷报关单导出 不选择也能导出
        if(selectidstring != ''){
            if(selectidstring.slice(-1) == ';'){
                that.selectcount = selectidstring.slice(0,-1).split(';').length;
            }else{
                that.selectcount = selectidstring.split(';').length;
            }
        }
        if(that.selectcount == 0){
            RemindsMsg("","LdPopWidth400px",that.module,"","",arrJsPopLabel['PLEASESELECTONEENTITY']);
            return  false;
        }else{
            return  true;
        }
    }
    this.createExportProgress = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();
        var createUrl ='index.php?module='+module+'&action='+module+'Ajax&file=ExportCustomForm22&search_type=selecteddata&idstring='+selectidstring+'&langjieExport=true&setype='+setype+'&times='+that.times+'&eachExportNum=0&getprogress=yes';

        ld.ajax({
            url: createUrl,
            type: 'POST',
            data: '',
            dataType: 'json',
            async: true,
            timeout: 10000,
            success: function (data) {
                if (data.code == 1) {
                    ld('#rptContentLoading').hide();
                    var crmPopupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth500px", module, "", '', "", "");
                    crmPopupobj.show(data.result.content);
                    //点击关闭 停止ajax

                    document.getElementById(crmPopupobj.divid + "_imgclose").onclick = function () {
                        crmPopupobj.CancelEvent();
                        if (that.createFileAjax != '') {
                            that.createFileAjax.abort();
                        }
                    }

                    that.createFile(that.times);
                }
            }
        })
    }
    this.createFile = function(){
        var createUrl ='index.php?module='+module+'&action='+module+'Ajax&file=ExportCustomForm22&search_type=selecteddata&idstring='+selectidstring+'&langjieExport=true&setype='+setype+'&times='+that.times+'&eachExportNum='+that.eachExportNum+'&getprogress=yes';

        that.createFileAjax = ld.ajax({
            url: createUrl,  //这里是网址
            type: 'POST',
            dataType:'json',
            timeout:30000,
            success: function (data) {
                if(data.code ==1){
                    var width = (that.times*that.eachExportNum)/that.selectcount*100;
                    if(width >100){
                        width=100;
                    }
                    // ld("#dvctimedescription").html(data.result.timedescription);
                    ld("#dvExportprogress").css("width", width+'%');
                    for (var i=0;i<data.result.files.length ;i++){
                        that.fileArr.push(data.result.files[i]);
                    }
                    if(data.result.complete =='yes'){
                        if(that.fileArr.length == 1){ //单个导出不压缩直接结束
                            var popupobj = CrmPopup.getPopupObj('last');
                            popupobj.CancelEvent();
                            var fileSuffix ='.xlsx';
                            getResult(data.result.files[0].filename,fileSuffix)
                        }else{
                            that.createZip(that.fileArr);
                        }
                    }else{
                        that.times++
                        that.createFile();
                    }
                }
            }
        })

    }
    this.createZip = function (files) {
        var fileSuffix ='.zip';
        ld("#dvctimedescription").html('正在压缩文件...');
        var zipUrl = 'index.php?module='+module+'&action='+module+'Ajax&file=ZipCustomForm22Langjie&files='+encodeURI(JSON.stringify(files))+'&idstring='+selectidstring+'&setype='+setype;
        ld.ajax({
            url: zipUrl,
            type: 'POST',
            data: '',
            dataType: 'json',
            async: true,
            timeout: 10000,
            success: function (zipData) {
                if(zipData.code ==1){
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    getResult(zipData.result.zipName,fileSuffix,zipData)
                }
            }
        })

    }

    this.init();

}

