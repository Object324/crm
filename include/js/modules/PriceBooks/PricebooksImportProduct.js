function cls_PricebooksImportProduct(module) {
    var that = this;
    this.module = module;
    this.stepindex = 1;
    this.blocks = new Array();
    this.fields = new Array();
    this.detailblocks = new Array();
    this.detailfields = new Array();
    this.popupobjs = new Array();
    this.record = 0; //单据id



    that.ajaxobj = '';
    this.getemptycount=0;

    this.firstimport = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        if(empty(popupobj.detailpage_record)){
            return false;
        }
        that.record = popupobj.detailpage_record;
        that.listurl = popupobj.url;//列表查询的url
        that.stepindex = 1;
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        crmPopupobj.filename = '';
        var urlstring = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ProductImportFirst&frommodule=' + that.module + "&stepindex=" + that.stepindex;
        crmPopupobj.prevshow();
        ldAjaxNoProgress(urlstring,'',function(data){
            if (data.code == 1 || data.code == 2) {
                if (data.code == 2) {
                    if (confirm(data.msg) == false) {
                        return false;
                    }
                }
                crmPopupobj.setParams(data.result.title, that.secondimport, "", "LdPopWidth800px", this.module, "", data.result.oktext, "", "");
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                ld("#"+crmPopupobj.divid+" #link_down").unbind("click").bind("click", function () {
                    that.downloadtemplate(ld(this));
                });
                crmPopupobj.detailblocks = data.result.detailblocks;
                crmPopupobj.detailfields = data.result.detailfields;
                crmPopupobj.detailmodule = data.result.detailmodule;
                document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {
                    that.closePopup();
                }
                that.detailmodule = data.result.detailmodule;
                that.popupobjs[that.stepindex] = crmPopupobj;
            } else {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
            }
            DelProgressObjs();
        });

    }

    //下载数据模板
    this.downloadtemplate = function (ldobj) {
        ldobj.attr("href", cls_encryptyurl.Puyoung_Encryptyurl("index.php?module=" + that.module + "&action=" + that.module +"Ajax&file=ExportFileModule&frommodule=" + this.module ));
    }

    /*上传导入文件**/
    this.uploadxls = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        var that = this;
        var formData = new FormData();
        formData.append('ImportXlsFile', ld('#' + popupobj.divid + " [name=xls_file_upload]").get(0).files[0]);
        formData.append('name', ld('#' + popupobj.divid + " [name=xls_file_upload]").val());
        //console.log(ld('#'+popupobj.divid+" [name=xls_file_upload]").get(0).files[0]);
        var size = ld('#' + popupobj.divid + " [name=xls_file_upload]").get(0).files[0].size;
        var name = ld('#' + popupobj.divid + " [name=xls_file_upload]").get(0).files[0].name;
        var sizedescription = '';
        if (size >= 1024 * 1024) {
            sizedescription = parseFloat(size / 1024 / 1024).toFixed(2) + 'MB';
        }
        else if (size >= 1024) {
            sizedescription = parseFloat(size / 1024).toFixed(2) + 'KB';
        }
        else {
            sizedescription = size.toFixed(2) + 'b';
        }

        if (name.toLocaleLowerCase().indexOf(".xls") <= 0 && name.toLocaleLowerCase().indexOf(".xlsx") <= 0) {
            audioRemindsMsg('', '', this.module, '', '', '只能导入excel文件');
            return false;
        }
        ld("#" + popupobj.divid + " [name=showfilename]").html(name + "-" + sizedescription);
        var urlstring = 'index.php?module=Users&action=UsersAjax&file=XlsFileUpload&frommodule=' + that.module;
        var tmpparam = {};
        tmpparam['filename'] = name;
        urlstring = cls_encryptyurl.Puyoung_EncryptyFileurl(urlstring,tmpparam);
        that.ajaxobj = ld.ajax({
            url: urlstring,
            type: 'POST',
            cache: false,
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',
            xhr: function () {
                var xhr = new XMLHttpRequest();
                xhr.upload.addEventListener('progress', function (e) {
                    var progressRate = (e.loaded / e.total) * 100 + "%";
                    ld("#" + popupobj.divid + ' .xlsimportprogress').css('display', 'block');
                    ld("#" + popupobj.divid + ' .xlsimportprogress > div').css('width', progressRate);
                })
                return xhr;
            }
        }).done(function (res) {
            ld("#" + popupobj.divid + ' .xlsimportprogress').css('display', 'none');
            ld("#" + popupobj.divid + ' .xlsimportprogress > div').css('width', 0);
            popupobj.filename = res.result.filename;
            console.log(popupobj);
        }).fail(function (res) {
        });
    }
    //第二步骤
    this.secondimport = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        if (popupobj.filename == '') {
            audioRemindsMsg('', '', this.module, '', '', arrJsPopLabel['IMPORTFILECANOTEMPTY']);
            return false;
        }
        var filename = popupobj.filename;
        var detail_importdupcheckfields = new Array();//明细查重字段
        //明细查重字段
        ld.each(ld("#" + popupobj.divid + " [tag=detail_dupcolumns]"), function (index, obj) {
            if (ld(obj).val() == '') {
                return true;
            }
            detail_importdupcheckfields.push(ld(obj).val());
        });

        if (that.detailmodule == 'Products') {
            //设置产品管理不存在时导入方式
            that.product_import_type = 'NoImportRow';//ld("#" + popupobj.divid + " [name=product_import_type]").val();
        }
        that.filename = filename;

        that.detail_importdupcheckfields = detail_importdupcheckfields;

        var urlData = {};
        var quoteid=0;
        

        ld("#" + popupobj.divid).css("display", 'none');
        //zkt 0047706: （81mis.com/kfbcrm）合同订单-新建-导入单据分录，导入单据分录映射字段时，字段下拉框显示宽度异常
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        crmPopupobj.prevshow();
        that.stepindex = 2;
        var urlstring = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ProductImportFirst&frommodule=' + that.module + "&stepindex=" + that.stepindex + "&filename=" + popupobj.filename;
        that.ajaxobj = ldAjax(urlstring,'',function(data){
            that.popupobjs[that.stepindex] = crmPopupobj;
            if (data.code == 1) {
                that.showthreeimport(data);//显示导入进度条
            }
            else {
                crmPopupobj.CancelEvent();
                //wym BUG0072929 kfbtest-价格表-单据明细页面，相关信息栏“产品管理”页面，导入不是系统自带的模板，跳出提示，点确定后，页面变灰色且不能操作了
                popupobj.CancelEvent();
                RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
                return false;
            }
        });
        DelProgressObjs();
    }
    this.secondimport.funname = "cls_PricebooksImportProduct.prototype.secondimport";

    
    /*
    显示导入进度的界面
    */
    this.showthreeimport = function (tmpdata) {
        //zkt 20230719 BUG0069486 kfbcrm-价格表-产品管理-导入-导入过一次后再点击导入，没反应 
        var secondpopupobj = CrmPopup.getPopupObj("last");
        ld("#" + secondpopupobj.divid).css("display", 'none');//隐藏导入步骤二
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        crmPopupobj.prevshow();
        that.stepindex = 3;
        var record = that.record;
        var urlstring = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ProductImportFirst&frommodule=' + that.module + "&stepindex=" + that.stepindex+"&pricebookid="+record;
        that.ajaxobj = ldAjax(urlstring,'',function (data) {
            if (data.code == 1) {
                that.startrow = 0;
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth600px", that.module, "", "", "", data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {
                    that.closePopup();
                }
                that.popupobjs[that.stepindex] = crmPopupobj;

                that.maxrows = parseInt(tmpdata.result.maxrows, 10);
                ld("#" + crmPopupobj.divid + " .import_info").html(tmpdata.result.timedescription);

                ld('#' + crmPopupobj.divid + " .process_now").css("width", tmpdata.result.cur_progress_step + "%");
                ld("#" + crmPopupobj.divid + " .percent").html(tmpdata.result.cur_progress_step + "%");
                setTimeout(function(){
				  ///谷歌浏览器进度条无法显示

				  that.importdata(that.startrow, that.startrow + 19);
			    },200);
            }
            DelProgressObjs();
        });
    }
    //导入数据
    this.importdata = function (startrow, endrow) {
        var popupobj = CrmPopup.getPopupObj('last');
        var record = that.record;
        var tmpurl = "choose=Update&filename=" + that.filename;
        tmpurl += "&startrow=" + startrow + "&endrow=" + endrow+"&pricebookid="+record;
        if (that.detailmodule == 'Products') {
            tmpurl += "&detail_importdupcheckfields=" + JSON.stringify(that.detail_importdupcheckfields) +"&product_import_type=" + that.product_import_type;
        }
        var urlstring = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ProductImportFirst&frommodule=' + that.module + "&stepindex=" + that.stepindex;
        that.ajaxobj = ldAjax(urlstring,tmpurl,function(data) {
                if (data.code == '-1') {
                    alert(data.msg);
                    return false;
                }
                that.startrow = parseInt(data.result.endrow, 10) + 1;
                ld("#" + popupobj.divid + " .import_info").html(data.result.timedescription);

                ld('#' + popupobj.divid + " .process_now").css("width", data.result.cur_progress_step + "%");
                ld("#" + popupobj.divid + " .percent").html(data.result.cur_progress_step + "%");
                    if (parseInt(that.maxrows, 10) <= parseInt(that.startrow)) {
                        that.importfinished();//导入完成
                        return false;
                    }
                    setTimeout(function(){
					  ///谷歌浏览器进度条无法显示

					  that.importdata(that.startrow, that.startrow + 19);
				    },200);
                DelProgressObjs();
        });
    }
    
    this.importfinished = function () {
         
        // lastprevpopupobj.fieldformulaobj.CountsubTotal();
        var popupobj = CrmPopup.getPopupObj('last');

        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        that.stepindex = 4;
        var tmpurl = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ProductImportFirst&frommodule=' + that.module + "&stepindex=" + that.stepindex;

        if (that.detailmodule == 'Products') {
            tmpurl += "&product_import_type=" + that.product_import_type;
        }
        that.ajaxobj = ldAjax(tmpurl,'', function (data) {
                if (data.code == 1) {
                    ld("#" + popupobj.divid).css('display', 'none');
                    crmPopupobj.setParams(data.result.title, that.closePopup, "", "LdPopWidth800px", that.module, "", data.result.oktext, "", "");
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                    that.popupobjs[that.stepindex] = crmPopupobj;
                    document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {
                        that.closePopup();
                    }

                }
                DelProgressObjs();
        })
    }
    //弹出层关闭
    this.closePopup = function () {
        for (var i = 1; i <= that.stepindex; i++) {
            var popupobj = that.popupobjs.pop();
            if (popupobj == undefined) {
                break;
            }
            popupobj.CancelEvent();
        }
        that.popupobjs = new Array();
        cls_PricebooksImportProduct.thisobj = "";
        if (that.ajaxobj != '') {
            that.ajaxobj.abort();
        }
        if (that.stepindex == 4)//导入完成，刷新相关信息界面
        {
            //zkt 20230719 BUG0069488  kfbcrm-价格表-产品管理-导入-导入成功后界面还是显示无，手动刷新界面后才会显示 
            var popupobj=CrmPopup.getPopupObj('last');
            DetailViewRelation.searchByPopupobj(popupobj);
        }
    }
}

cls_PricebooksImportProduct.thisobj = "";
cls_PricebooksImportProduct.getInstance = function (module) {
    if (cls_PricebooksImportProduct.thisobj == '') {
        cls_PricebooksImportProduct.thisobj = new cls_PricebooksImportProduct(module);
    }
    return cls_PricebooksImportProduct.thisobj;
}

