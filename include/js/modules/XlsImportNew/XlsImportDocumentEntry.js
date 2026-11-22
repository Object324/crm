//editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:33
function cls_XlsImportDocumentEntry(module) {
    this.module = module;
    this.stepindex = 1;
    var that = this;
    this.blocks = new Array();
    this.fields = new Array();
    this.detailblocks = new Array();
    this.detailfields = new Array();
    this.popupobjs = new Array();
    this.haigequotenoedit = new Array();//海格报价单折扣不可修改行数组，结构{{rowindex,productid}}
    that.ajaxobj = '';
    this.getemptycount=0;

    /*
    *上一步
    */
    this.previndex = function () {
        this.stepindex--;
    }

    /*
    添加条件
    */
    this.addcondition = function () {

    }
    this.firstimport = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        
        
          var fieldname='';
     
           ld.each(popupobj.fields,function(index,info){
            
            if(info.bigtype=='selectsource')
            {
                ishavesourcefield='yes';
                 fieldname=info.fieldname;
                return false;
            }
           })
           
         var withproductdetail='yes';
           var strictsourcebillcolums='';//严格参照原单
           ld.each(popupobj.sourcemodule_arr,function(tmpindex,sourcemoduleinfo){
                
                if(sourcemoduleinfo.entitytype==ld("#"+popupobj.divid+" [name=selectsource]").val())
                {
                    withproductdetail=sourcemoduleinfo.withdetail;//选择源单是否允许带出分录，yes:允许带出分录
                    strictsourcebillcolums=sourcemoduleinfo.strictsourcebillcolums;
                    return false;
                }
           })

        //zkt 20230915 BUG0072742 生产发货单（自定义表单 14），表头上选择了源单，产品分录点［导入明细］，就提示如下截图“不允许选择源单外产品”。但是手工一行一行加可以加源单之外的产品，点导入怎么取消如下提示，已检查字段参数设置如下图 2 
        	if(strictsourcebillcolums!=''&&strictsourcebillcolums!='null'&&strictsourcebillcolums!=null&&strictsourcebillcolums!=','&&!this.popup_selectsource){
        	   
        		if((withproductdetail=='yes' && CrmPopup.findHtmlobj(popupobj.divid,fieldname).val()!=''&&CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined 
                    && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != 'climaveneta')){
                    if(that.module == 'SalesOrder' && account_version == 'haige'){
                        //海格合同订单分录，选择源单后可以导入
                        that.entitytypeid = CrmPopup.findHtmlobj(popupobj.divid,fieldname).val();
                    }
                    else{
        			     RemindsMsg("","LdPopWidth400px",module,"yes","yes",arrJsPopLabel['SELECTPRODUCTLINEITEM']);
        			     return false;
                    }
        		}
        	}
			if(that.module == 'SalesOrder' && account_version == 'haige'){
                //海格合同订单分录，选择源单后可以导入
                that.entitytypeid = CrmPopup.findHtmlobj(popupobj.divid,fieldname).val();
            }
        
        that.listurl = popupobj.url;//列表查询的url
        that.stepindex = 1;
        ld.ajax({
            url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&second_file_index=documentEntry&frommodule=' + that.module + "&stepindex=" + that.stepindex,
            type: 'POST',
            data: '',
            dataType: 'json',
            async: true,//
            timeout: 0,
            success: function (data) {
                if (data.code == 1 || data.code == 2) {
                    if (data.code == 2) {
                        if (confirm(data.msg) == false) {
                            return false;
                        }
                    }
                    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
                    crmPopupobj.filename = '';
                    crmPopupobj.prevshow();
                    crmPopupobj.setParams(data.result.title, cls_XlsImportDocumentEntry.getInstance(that.module).secondimport, "", "LdPopWidth800px", this.module, "", data.result.oktext, "", "");
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                    ld("#link_down").unbind("click").bind("click", function () {
                        cls_XlsImportDocumentEntry.getInstance(that.module).downloadtemplate(ld(this));
                    });
                    crmPopupobj.nonelabel = data.result.nonelabel;
                    crmPopupobj.andlabel = data.result.andlabel;
                    crmPopupobj.deletelabel = data.result.deletelabel;
                    crmPopupobj.orlabel = data.result.orlabel;
                    crmPopupobj.blocks = data.result.blocks;
                    crmPopupobj.fields = data.result.fields;
                    crmPopupobj.detailblocks = data.result.detailblocks;
                    crmPopupobj.detailfields = data.result.detailfields;
                    crmPopupobj.detailmodule = data.result.detailmodule;
                    crmPopupobj.noimport = data.result.noimport;
                    document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {

                        that.closePopup();
                    }
                    that.detailmodule = data.result.detailmodule;
                    that.popupobjs[that.stepindex] = crmPopupobj;

                }
                else {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
                }
            }
        })

    }
    //下载数据模板
    this.downloadtemplate = function (ldobj) {
        //var popupobj=CrmPopup.getPopupObj('last');
        ldobj.attr("href", "index.php?file=ExportTemplateFile&action=UsersAjax&module=Users&frommodule=" + this.module + "&second_file_index=documentEntry");
    }
    this.btn_addnewcondition = function () {

        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var dupobj = ld("#" + divid + " [name=dv_dupcondition]");
        var conditionhtml = "<select class='btn-radius-system' tag='dupcondition'>";
        conditionhtml += '<option value="or">' + popupobj.orlabel + "</option>";
        conditionhtml += '<option value="and">' + popupobj.andlabel + "</option>";

        conditionhtml += "</select>";

        var selectfieldshtml = '<select class="ld-select-inner gwidth30 mr50" tag="dupcolumns">';
        selectfieldshtml += "<option value=''>" + popupobj.nonelabel + "</option>";
        // console.log(popupobj.fields);

        ld.each(popupobj.blocks, function (blockid, blockinfo) {
            selectfieldshtml += "<optgroup label='" + blockinfo.blocklabel + "'>" + blockinfo.blocklabel;
            var thatblock = this;
            ld.each(popupobj.fields, function (fieldname, fieldinfo) {

                if (fieldinfo.blockid == blockid)
                    if (fieldinfo.uitype != 69 && fieldinfo.uitype != 1109)
                        selectfieldshtml += '<option value="' + fieldinfo.fieldname + '">' + fieldinfo.fieldLableKey + '</option>';


            });
            selectfieldshtml += "</optgroup>";

        });
        var html = "<div>  <span>";
        html += selectfieldshtml + "</select></span>";

        html += "<span>&nbsp;" + conditionhtml + "</span>";
        html += "<span> <label onclick='cls_XlsImportDocumentEntry.getInstance(\"" + this.module + "\").deleteimportdupfieldtr(ld(this),\"dv_dupcondition\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
        html += "</div>";
        dupobj.append(html);

    }
    //产品明细，联系人明细的查重条件
    this.btn_add_detailnewcondition = function () {

        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var dupobj = ld("#" + divid + " [name=dv_detail_dupcondition]");
        var conditionhtml = "<select class='btn-radius-system' tag='detail_dupcondition'>";
        conditionhtml += '<option value="or">' + popupobj.orlabel + "</option>";
        conditionhtml += '<option value="and">' + popupobj.andlabel + "</option>";

        conditionhtml += "</select>";

        var selectfieldshtml = '<select class="ld-select-inner gwidth30 mr50" tag="detail_dupcolumns">';
        if (popupobj.detailmodule == 'Contacts') {
            selectfieldshtml += "<option value=''>" + popupobj.noimport + "</option>";
        }
        else
            selectfieldshtml += "<option value=''>" + popupobj.nonelabel + "</option>";
        // console.log(popupobj.fields);

        // ld.each(popupobj.detailblocks,function(blockid,blockinfo){
        // selectfieldshtml+="<optgroup label='"+blockinfo.blocklabel+"'>"+blockinfo.blocklabel;
        var thatblock = this;
        ld.each(popupobj.detailfields, function (fieldname, fieldinfo) {

            //if(fieldinfo.blockid==blockid)

            if (fieldinfo.uitype != 69 && fieldinfo.uitype != 1109 && fieldinfo.uitype != 202)
                selectfieldshtml += '<option value="' + fieldname + '">' + fieldinfo.fieldLableKey + '</option>';

        });
        //  selectfieldshtml+="</optgroup>";

        // });
        var html = "<div>  <span>";
        html += selectfieldshtml + "</select></span>";

        html += "<span>&nbsp;" + conditionhtml + "</span>";
        html += "<span> <label onclick='cls_XlsImportDocumentEntry.getInstance(\"" + this.module + "\").deleteimportdupfieldtr(ld(this),\"dv_detail_dupcondition\")' class='icon-homeimg icon-sdel popupselectdiv' style='margin-top:2px;cursor:pointer;'></label></span>";
        html += "</div>";
        dupobj.append(html);

    }
    this.deleteimportdupfieldtr = function (ldobj, parentname) {
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var dupobj = ld("#" + divid + " [name=" + parentname + "]");
        ldobj.parent().parent().remove();
        // dupobj.remove(ldobj.parent().parent());
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
        //zkt 20231127 BUG0076041 （http://43.138.27.230:85/crm）8612版本，销售订单SalesOrder产品分录点击“导入明细”，添加文件后报错
        var tmpurl = 'index.php?module=Users&action=UsersAjax&file=XlsFileUpload&second_file_index=documentEntry&frommodule=' + that.module;
        var tmpparam = {};
        tmpparam['filename'] = name;
        tmpurl = cls_encryptyurl.Puyoung_EncryptyFileurl(tmpurl,tmpparam);
        that.ajaxobj = ld.ajax({
            url: tmpurl,
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
        var choose = ld("#" + popupobj.divid + " [name=choose]").val();//导入方式：覆盖，跳过，追加
        var importdupcheckfields = new Array();//查重字段
        var importdupfields_condition = new Array();//查重字段的条件
        var detail_importdupcheckfields = new Array();//明细查重字段
        var detail_importdupfields_condition = new Array();
        //可删，合同订单查重字段
        ld.each(ld("#" + popupobj.divid + " [tag=dupcolumns]"), function (index, obj) {

            if (ld(obj).val() == '') {
                return true;
            }
            importdupcheckfields.push(ld(obj).val());
            var dupconditionobjs = ld("#" + popupobj.divid + " [tag=dupcondition]");
            importdupfields_condition.push(ld(dupconditionobjs[index]).val());
        });
        //明细查重字段
        ld.each(ld("#" + popupobj.divid + " [tag=detail_dupcolumns]"), function (index, obj) {

            if (ld(obj).val() == '') {
                return true;
            }
            detail_importdupcheckfields.push(ld(obj).val());

            var dupconditionobjs = ld("#" + popupobj.divid + " [tag=detail_dupcondition]");
            detail_importdupfields_condition.push(ld(dupconditionobjs[index]).val());
        });

        if (that.detailmodule == 'Products') {
            //设置产品管理不存在时导入方式
            that.product_import_type = ld("#" + popupobj.divid + " [name=product_import_type]").val();
        }
        that.filename = filename;
        that.choose = choose;

        that.importdupcheckfields = importdupcheckfields;
        that.importdupfields_condition = importdupfields_condition;
        that.detail_importdupcheckfields = detail_importdupcheckfields;
        that.detail_importdupfields_condition = detail_importdupfields_condition;

        var urlData = {};
        var quoteid=0;
        //将界面产品分录信息传入后台
        //zxm 2021-1203上海晴明 单据分录导入 更新价格
        if((that.module == 'Quotes' && account_version == 'haige') ||(that.module == 'CustomForm11' && account_version == 'shqingming'))
        {
            var prevpopupobj = CrmPopup.getPopupObj('lastprev');
            var trobjs=prevpopupobj.getTrObjsByDelType("no");
             var haigedetails = new Array();
            if(prevpopupobj.record>0){
                quoteid=prevpopupobj.record;
            }
            else if(ld("#"+prevpopupobj.divid+' [name=duplicateid]').val()>0){
                quoteid=ld("#"+prevpopupobj.divid+' [name=duplicateid]').val();
            }
           
            ld.each(trobjs,function(){
                var haigeproduct = new Array();
                var rowindex = ld(this).attr('rowindex');
                var productname = ld(this).find(' [name=productname]').val();
                var hdnProductId = ld(this).find(' [name=hdnProductId]').val();
                if(hdnProductId == '' || productname == '') return true;
                var productgroup_name = ld(this).find(' [name=productgroup_name]').val();
                var discount_percent = ld(this).find(' [name=discount_percent]').val();
                var agent_discount = ld(this).find(' [name=agent_discount]').val();
                haigeproduct = {'rowindex':rowindex,'procuctname':productname,'hdnProductId':hdnProductId,'productgroup_name':productgroup_name,
                        'discount_percent':discount_percent,'agent_discount':agent_discount
                        }
                haigedetails.push(haigeproduct);
                
            });
            urlData={'haigedetails':JSON.stringify(haigedetails),'quoteid':quoteid};
            
        }
        
        ld("#" + popupobj.divid).css("display", 'none');
        //zkt 0047706: （81mis.com/kfbcrm）合同订单-新建-导入单据分录，导入单据分录映射字段时，字段下拉框显示宽度异常
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        crmPopupobj.prevshow();
        that.stepindex = 2;
        that.ajaxobj = ld.ajax({
            url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&second_file_index=documentEntry&frommodule=' + that.module + "&stepindex=" + that.stepindex + "&filename=" + popupobj.filename,
            type: 'POST',
            data: urlData,
            dataType: 'json',
            async: true,//
            timeout: 0,
            success: function (data) {
                that.popupobjs[that.stepindex] = crmPopupobj;

                if (data.code == 1) {

                    crmPopupobj.setParams(data.result.title, cls_XlsImportDocumentEntry.getInstance(that.module).prevstep, "", "LdPopWidth800px", this.module, "", data.result.oktext, "", data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                    crmPopupobj.excelcolumncount = data.result.excelcolumncount;

                    //037256: 单据列表界面>更多>导入>选择模板后点击下一步：底部的【上一步、下一步】按钮应该是【下一步】为蓝色的，【上一步】为白色的。
                    ld("#" + crmPopupobj.divid + "_btnok").attr("class", 'E_pbtncancel ld-button');
                    ld("#" + crmPopupobj.divid + "_btncancel").attr("class", 'E_pbtnok ld-button ld-button-primary');


                    document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {

                        that.closePopup();
                    }
                    document.getElementById(crmPopupobj.divid + '_btncancel').onclick = function () {


                        cls_XlsImportDocumentEntry.getInstance(that.module).threeimport();

                    }

                }
                else {

                    audioRemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
                    that.prevstep();
                    return false;
                }
            },
            error: function (one, two, status) {
                alert(status);
            }
        })
    }

    this.secondimport.funname = "cls_XlsImportDocumentEntry.prototype.secondimport";
    //导入方式选择覆盖，则提示
    this.chooseAlert = function (tipcontent) {
        var popupobj = CrmPopup.getPopupObj("last");
        if (ld("#" + popupobj.divid + " [name=choose]").val() == 'Update' || ld("#" + popupobj.divid + " [name=choose]").val() == 'UpdateAll') {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", tipcontent);
            return false;
        }

    }

    //第三步骤
    this.threeimport = function () {
        //editor:gyq_20200121
        var secondpopupobj = CrmPopup.getPopupObj("last");
        var divid = secondpopupobj.divid;
        var mapped_fields = new Array();
        var isfieldname = new Array();
        var isdefaultvalue = new Array();
        for (var i = 0; i < secondpopupobj.excelcolumncount; i++) {
            var selectcolumn = ld("#" + secondpopupobj.divid + " [name=" + i + "]").val();
            mapped_fields.push(selectcolumn);//导入的字段
            if(ld("#" + secondpopupobj.divid + " input[name=" + selectcolumn + "-defaultvalue]").length > 0){
                isdefaultvalue.push(ld("#" + secondpopupobj.divid + " input[name=" + selectcolumn + "-defaultvalue]:first").val());//导入字段默认值
            }else{
                isdefaultvalue.push('');
            }
        }
        that.mapped_fields = mapped_fields;
        that.isdefaultvalue = isdefaultvalue;
        that.getImportDataRows();//获取导入数
    }
    this.threeimport.funname = "cls_XlsImportDocumentEntry.prototype.threeimport";
    /*
    获取导入数据
    */
    that.getImportDataRows = function () {
        var secondpopupobj = CrmPopup.getPopupObj("last");
        ld("#" + secondpopupobj.divid).css("display", 'none');//隐藏导入步骤二
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        crmPopupobj.prevshow();
        var tmpurl = "choose=" + that.choose + "&importdupfields_condition=" + JSON.stringify(that.importdupfields_condition) + "&importdupcheckfields=" + JSON.stringify(that.importdupcheckfields);
        tmpurl += "&mapped_fields=" + JSON.stringify(that.mapped_fields) + "&defaultvalue=" + JSON.stringify(that.isdefaultvalue) + "&filename=" + that.filename;
        if (that.detailmodule != '') {

            tmpurl += "&detail_importdupcheckfields=" + JSON.stringify(that.detail_importdupcheckfields) + "&detail_importdupfields_condition=" + JSON.stringify(that.detail_importdupfields_condition);

        }
        if (that.detailmodule == 'Products') {
            tmpurl += "&product_import_type=" + that.product_import_type;
        }
        that.ajaxobj = ld.ajax({

            url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&frommodule=' + that.module + "&getimportrows=yes&second_file_index=documentEntry",
            type: 'POST',
            data: tmpurl,
            dataType: 'json',
            async: true,//
            timeout: 0,
            success: function (data) {

                if (data.code == 1) {


                    that.showthreeimport(data);//显示导入进度条

                }
                else {
                    crmPopupobj.CancelEvent();
                    ld("#" + secondpopupobj.divid).css("display", 'block');
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
                    return false;
                }
            }


        })
    }
    /*
    显示导入进度的界面
    */
    this.showthreeimport = function (tmpdata) {
        var crmPopupobj = CrmPopup.getPopupObj('last');
        that.stepindex = 3;
        that.ajaxobj = ld.ajax({
            url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&second_file_index=documentEntry&frommodule=' + that.module + "&stepindex=" + that.stepindex,
            type: 'POST',
            data: '',
            dataType: 'json',
            async: true,//
            timeout: 5000,
            success: function (data) {
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
                else {

                }
            }
        })
    }
    //导入数据
    this.importdata = function (startrow, endrow) {
        var popupobj = CrmPopup.getPopupObj('last');
            
        var tmpurl = "choose=" + that.choose + "&importdupfields_condition=" + JSON.stringify(that.importdupfields_condition) + "&importdupcheckfields=" + JSON.stringify(that.importdupcheckfields);
        tmpurl += "&mapped_fields=" + JSON.stringify(that.mapped_fields) + "&defaultvalue=" + JSON.stringify(that.isdefaultvalue) + "&filename=" + that.filename;
        tmpurl += "&startrow=" + startrow + "&endrow=" + endrow;
        if (that.detailmodule != '') {
            tmpurl += "&detail_importdupcheckfields=" + JSON.stringify(that.detail_importdupcheckfields) + "&detail_importdupfields_condition=" + JSON.stringify(that.detail_importdupfields_condition);
        }
        if (that.detailmodule == 'Products') {
            tmpurl += "&product_import_type=" + that.product_import_type;
        }
        if(!empty(that.entitytypeid)&&that.module == 'SalesOrder' && account_version == 'haige'){
            tmpurl += "&haigequoteid=" + that.entitytypeid;
        }
        that.ajaxobj = ld.ajax({

            url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&second_file_index=documentEntry&frommodule=' + that.module + "&stepindex=" + that.stepindex,
            type: 'POST',
            data: tmpurl,
            dataType: 'json',
            async: false,//
            timeout: 0,
            success: function (data) {
                if (data.code == '-1') {
                    alert(data.msg);
                    return false;
                }
                that.startrow = parseInt(data.result.endrow, 10) + 1;

                ld("#" + popupobj.divid + " .import_info").html(data.result.timedescription);

                ld('#' + popupobj.divid + " .process_now").css("width", data.result.cur_progress_step + "%");
                ld("#" + popupobj.divid + " .percent").html(data.result.cur_progress_step + "%");
                var productList = data.result.product_list;
                var popupobjEdit = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
                popupobjEdit.fieldformulaobj.ismasscount='yes';
                var hidden_row_array = new Array();
                var rowid = 0;
                if(that.getemptycount<=2)
                {

                    var trobjs=popupobjEdit.getTrObjsByDelType('no');
                    var tableobj=popupobjEdit.getDetailTableObj();

                    var trlen=ld(trobjs).length;
                    //获取当前有空行的rowid
                    if(trlen > 0){
                        var hdnProductIdObj_arr=ld(tableobj).find(' [detailcolumnname="hdnProductId"]');
                        for(var tmpi=trlen-1;tmpi>=0;tmpi--)
                        {
                            if(ld(hdnProductIdObj_arr[tmpi]).val()==''||
                                ld(hdnProductIdObj_arr[tmpi]).val()==0)
                            {
                                var rowobj=trobjs[tmpi];
                                hidden_row_array.push(ld(rowobj).attr("rowindex"));
                            }
                            else{
                                break;
                            }
                        }
                    }
                }
                var hidden_rowlen=hidden_row_array.length;
                if(hidden_rowlen<=0)
                {
                    that.getemptycount=3;
                }
                popupobjEdit.selectproductobj.massaddrow='yes';

                var cnt = 0;
                var hidden_rowindex = hidden_rowlen-1;

                ld.each(productList,function(index,fieldcontent){
                    var productid = fieldcontent['hdnProductId'];
                    if(that.maxrows-cnt<=2)
                    {
                        popupobjEdit.selectproductobj.massaddrow='no';
                    }
                    if (hidden_rowlen >= 1 && hidden_rowindex >=0) {
                        rowid = hidden_row_array[hidden_rowindex];
                    } else {
                        rowid = popupobjEdit.selectproductobj.fnaddProductRow();
                    }
                    setproduct_value(productid, fieldcontent, rowid);
                    cnt++;
                    hidden_rowindex--;

                    //海格--报价单导入数据后带出标准面价、金额等信息
                    //zxm 2021-1203上海晴明 单据分录导入 更新价格
                    if(((that.module == 'Quotes' || that.module == 'SalesOrder') && account_version == 'haige')||(that.module == 'CustomForm11' && account_version == 'shqingming')){
                        if(rowid==0)rowid=hidden_row_array[hidden_rowindex+1];
                        popupobj.RelatedProductToolFieldtriggcols=[];
                        getRelatedProductToolFieldPriceCallBack(popupobjEdit,rowid);
                    }
                });

                if((that.module == 'Quotes' && account_version == 'haige')||(that.module == 'CustomForm11' && account_version == 'shqingming')){
                    //海格--报价单，产品重复导入，更新产品数量
                    var haigechangequantity = data.result.haigechangequantity;
                    var popupobjEdit = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
                    var tableobj=popupobjEdit.getDetailTableObj();
                    if(haigechangequantity != undefined && !empty(haigechangequantity))
                    {
                        ld.each(haigechangequantity,function(index,haigechangeinfo){
                            var tmprowindex = haigechangeinfo.rowindex;
                            var trobj = ld(tableobj).find("tr[rowindex="+tmprowindex+"]");
                            //zkt 20230824 BUG0071431  导入的时候有相同产品会合并数量，但是保存后没有变为变化后数量
                            if (popupobjEdit.detaildatavalue_arr[tmprowindex - 1].databind != 'yes'){
                                popupobjEdit.selectproductobj.setDataBind(ld(trobj));
                            }
                            var tmpquantity = popupobjEdit.detaildatavalue_arr[tmprowindex-1]['quantity'];// ld(trobj).find(" [name=quantity]").val();
                            var hdnProductId = popupobjEdit.detaildatavalue_arr[tmprowindex-1]['productid'];//ld(trobj).find(" [name=hdnProductId]").val();
                            var addquantity = haigechangeinfo.changequantity;
                            if(hdnProductId == haigechangeinfo.hdnProductId)
                            {
                                var newquantity = parseInt(tmpquantity)+parseInt(addquantity);
                                popupobjEdit.detaildatavalue_arr[tmprowindex-1]['quantity'] = newquantity;
                                //数量改变时，更新金额信息
                                popupobjEdit.RelatedProductToolFieldtriggcols=[];
                                getRelatedProductToolFieldPriceCallBack(popupobjEdit,tmprowindex);
                            }
                        })

                    }
                    var discountnoeditarr = data.result.discountnoeditarr;
                    if(discountnoeditarr != undefined && !empty(discountnoeditarr)){
                        ld.each(discountnoeditarr,function(index,haigenoeditinfo){
                            that.haigequotenoedit.push(haigenoeditinfo);
                        })
                    }
                }
                if (parseInt(that.maxrows, 10) <= parseInt(that.startrow)) {
                    that.importfinished();//导入完成
                    return false;
                }
                setTimeout(function(){
                    ///谷歌浏览器进度条无法显示

                    that.importdata(that.startrow, that.startrow + 19);
                },200);
            },
        })
    }


    this.importfinished = function () {
         var lastprevpopupobj = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
         lastprevpopupobj.fieldformulaobj.ismasscount='no';
         //BUG20240522-39  新增报价单，手工选择分录产品时人民币单价手工修改后可以回写人民币金额，但是分录通过导入时第一行参与计算，后面全部不参与计算（具体操作见附件视频），相关导入产品明细数据见附件
        lastprevpopupobj.selectproductobj.massaddrow="no";
         //zkt 20230425 BUG0065536 （http://crm.rzxr.com/crm）8498版本，销售计划CustomForm16，在表头中增加了分录计算函数，当分录手动录入时，表头的分录计算函数可以计算；当分录导入时，表头的分录函数没有计算。 
         if(lastprevpopupobj.fieldformulaobj != undefined){
            lastprevpopupobj.fieldformulaobj.CountsubTotal();
         }
         if(lastprevpopupobj.detail2mainformulaobj != undefined){
            lastprevpopupobj.detail2mainformulaobj.changeRowEvent();
         }
         //zkt 20240802 BUG20240801-74 商机（SOJH20240801-006）下推报价单，填写报价分录时通过导入明细，导入后数据错位了。 --导入完成调用布局规则
        if(lastprevpopupobj.fieldruleobj != undefined&&lastprevpopupobj.detailfieldrulefieldnames!=undefined){
            if(lastprevpopupobj.detailfieldrulefieldnames.length>0&&lastprevpopupobj.detailfieldrulefieldnames[0]!='')
            {
                lastprevpopupobj.fieldruleobj.setTrContent();
            }
        }
        // lastprevpopupobj.fieldformulaobj.CountsubTotal();

        lastprevpopupobj.selectproductobj.fnAddProductTdBtn();
        var popupobj = CrmPopup.getPopupObj('last');

        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth800px", that.module, "", 'none', "", "");
        that.stepindex = 4;
        var tmpurl = 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&second_file_index=documentEntry&frommodule=' + that.module + "&stepindex=" + that.stepindex;

        if (that.detailmodule == 'Products') {
            tmpurl += "&product_import_type=" + that.product_import_type;
        }
        that.ajaxobj = ld.ajax({
            url: tmpurl,
            type: 'POST',
            data: '',
            dataType: 'json',
            async: true,//
            timeout: 5000,
            success: function (data) {
                if (data.code == 1) {
                    ld("#" + popupobj.divid).css('display', 'none');
                    crmPopupobj.setParams(data.result.title, that.closePopup, "", "LdPopWidth800px", that.module, "", data.result.oktext, "", "");
                    CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj, data.result.content);
                    that.popupobjs[that.stepindex] = crmPopupobj;
                    document.getElementById(crmPopupobj.divid + '_imgclose').onclick = function () {
                        that.closePopup();
                    }

                }
            }
        })
    }
    this.prevstep = function () {

        //上一步
        var tmppopupobj = CrmPopup.getPopupObj('last');
        that.popupobjs.pop();
        tmppopupobj.CancelEvent();

        that.stepindex--;
        var popupobj = CrmPopup.getPopupObj('last');
        ld("#" + popupobj.divid).css("display", 'block');
    }
    /*
    弹出层关闭
    */
    this.closePopup = function () {
        //zxm 2021-1203上海晴明 单据分录导入 更新价格
        if(that.module == 'Quotes' && account_version == 'haige' && !empty(that.haigequotenoedit)){
            //海格-报价单控制导入产品折扣不可修改(产品组存在)，that.haigequotenoedit为不可编辑行信息
            var popupobjEdit = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
            var tableobj=popupobjEdit.getDetailTableObj();
            ld.each(that.haigequotenoedit,function(index,haigenoeditinfo){
                var tmprowindex = haigenoeditinfo.rowindex;
                var trobj = ld(tableobj).find("tr[rowindex="+tmprowindex+"]");
                var hdnProductId = ld(trobj).find(" [name=hdnProductId]").val();
                if(hdnProductId == haigenoeditinfo.hdnProductId)
                {
                     
                     ld(trobj).find(" [name=discount_percent]").attr('readonly',true);
                     ld(trobj).find(" [name=agent_discount]").attr('readonly',true);
                }
            })
        }
        for (var i = 1; i <= that.stepindex; i++) {
            var popupobj = that.popupobjs.pop();
            if (popupobj == undefined) {
                break;
            }
            popupobj.CancelEvent();

        }
        that.popupobjs = new Array();
        cls_XlsImportDocumentEntry.thisobj = "";
        if (that.ajaxobj != '') {
            that.ajaxobj.abort();
        }
        if (that.stepindex == 3)//导入进度条界面
        {
            //需要清空session
            
            var lastprevpopupobj = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
            lastprevpopupobj.fieldformulaobj.ismasscount='no';
            if(lastprevpopupobj.fieldformulaobj != undefined){
                lastprevpopupobj.fieldformulaobj.CountsubTotal();
             }
             if(lastprevpopupobj.detail2mainformulaobj != undefined){
                lastprevpopupobj.detail2mainformulaobj.changeRowEvent();
             }
           // lastprevpopupobj.fieldformulaobj.CountsubTotal();
            ld.ajax({
                url: 'index.php?module=' + that.module + '&action=' + that.module + 'Ajax&file=ImportxlsStep&frommodule=' + that.module + "&clearimportsession=yes",
                type: 'POST',
                data: '',
                dataType: 'json',
                async: true,//
                timeout: 20000,
                success: function (data) {
                    if (data.code == 1) {

                    }
                }
            })
        }
        else if (that.stepindex == 4)//导入完成，刷新列表界面
        {
            var popupobj = CrmPopup.getPopupObj('last');
            if (popupobj.url == undefined || popupobj.url == '') {
                return false;
            }
            ld.ajax({
                url: "index.php?" + popupobj.url,
                type: 'POST',
                data: '',
                dataType: 'html',
                async: true,//
                timeout: 10000,

                success: function (data) {
                    $("status").style.display = "none";


                    var str = data;
                    if (data.indexOf("&#&#&#&#&#&#") >= 0) {
                        str = data.split("&#&#&#&#&#&#");
                        str = str[1];
                    }
                    ld("#" + popupobj.divid).html(str);
                     popupobj.listresizeobj.setReiszeTable_Init(module, 'ajax');
                    if (popupobj.module == 'Accounts') {
                        IsFrameElement();
                    }

                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                     
                    popupobj.CancelEvent();
                }
            });
        }
        

    }
}

cls_XlsImportDocumentEntry.thisobj = "";
cls_XlsImportDocumentEntry.getInstance = function (module) {
    
  
        
    if (cls_XlsImportDocumentEntry.thisobj == '') {

        cls_XlsImportDocumentEntry.thisobj = new cls_XlsImportDocumentEntry(module);
    }
    return cls_XlsImportDocumentEntry.thisobj;
}


function defaultImportXls(obj, rowindex) {

    /*
     var tab=document.getElementById('Importtable');
     rowindex=parseInt(rowindex)+1;
     var cellobj=tab.rows[rowindex].cells[3];
     var oldspanobj=cellobj.firstChild;
     var parentnode=cellobj;
     var optvalue=obj.options[obj.selectedIndex].value;

     var newspanobj=document.getElementById(optvalue+'-defaultvalue-container');
     var defaultValuesElementsContainer=document.getElementById('defaultValuesElementsContainer');
     var childhtml= parentnode.innerHTML;

     if(newspanobj != undefined && newspanobj != null){
          if(newspanobj.parentNode.id==undefined||newspanobj.parentNode.id=='')
          {
               parentnode.innerHTML='';
               defaultValuesElementsContainer.innerHTML+=childhtml;

              return ;
          }

          parentnode.innerHTML='';
          defaultValuesElementsContainer.removeChild(newspanobj);
     }else{

         var newNode = document.createElement('span');
         var newNodeId = optvalue+'-defaultvalue-container';
         //var newNodeId = document.getElementById(optvalue+'-defaultvalue-container');
         newNode.setAttribute('id',newNodeId);
         newNode.setAttribute('name',optvalue+'-defaultvalue-container');
         newNode.innerHTML = "<input id="+optvalue+"-defaultvalue name="+optvalue+"-defaultvalue type=\"text\" class=\"btn-radius-system\">";
         //newNode.innerHTML = "";
         parentnode.appendChild(newNode);
         newspanobj=document.getElementById(newNodeId);
         parentnode.innerHTML='';
     }

     parentnode.appendChild(newspanobj);
     defaultValuesElementsContainer.innerHTML+=childhtml;;*/


}
 