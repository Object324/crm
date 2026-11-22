//创建弹出框
function CreatePagePopup() {
    this.createpagedata = '';//新建页面数据
    this.picklistcontent = [];//下拉框
    this.fieldrulefieldnames = [];//主表布局规则的查询字段
    this.timeCount = 0;
    this.showquickcreate = "yes";//是否显示的是快速创建字段，yes:是
    this.oCKeditors = [];
    var that = this;

    var parentshow = this.show;
    that.parentsetParams = this.setParams;
    this.deskvaluearr = [];//弹出层界面值
    this.oCKeditor = null;
    this.clickchangepage = 'no';
    this.picklistobjarray = [];//下拉框对象(cls_picklist
    this.uitypes = [];
    that.detailfieldrulefieldnames = [];//明细字段的布局规则
    that.js_detailtablename = 'proTab';//分录所在的表格名称
    that.detailpicklist = [];
    that.detailpicklistseq = [];
    that.detailpicklistColors = [];//主表和明细字段的下拉框内容
    this.newrowhtml = '';//单据分录的新增行的html
    this.approve_arr = [];
    this.issavesubmit = 'no';//是否点击保存提交按钮
    this.islocalstorage = 'no';//是否缓存加载
    that.sys_deploy = [];//系统设置参数
    this.isShowFullscreen='yes';
    this.fullscreenlabel='EditFullscreen';//全屏缩小用于保存后台的label值
    this.fullscreen='yes';//全屏缩小用户值，默认全屏
    this.setObjEventArr = [];

    /** @return {jQuery} */
    this.getPopupJqObj = function () {
        var popupJqObj = this.jQueryObj;
        if(!popupJqObj) {
            popupJqObj = ld('#'+this.divid);
            if(popupJqObj.length > 0) {
                this.jQueryObj = popupJqObj;
            }
        }
        return popupJqObj;
    }
    /** @return {jQuery} */
    this.getDetailTableJqObj = function () {
        return this.detailTableJqObj || (this.detailTableJqObj = this.getPopupJqObj().find(`[name="${this.js_detailtablename}"]`));
    }
    /** @return {jQuery} */
    this.getDetailRowJqObj = function (rowIndex) {
        return this.getDetailTableJqObj().find(`tr[rowindex="${rowIndex}"]`);
    }
    /** @return {jQuery} */
    this.getDetailFieldTdJqObj = function (rowIndex, fieldName) {
        return this.getDetailRowJqObj(rowIndex).find(`td[detailfieldname="${fieldName}"]`);
    }

    this.getDetailTableObj = function () {
        //获取单据分录table对象
        return ld("#" + this.divid + " [name=" + this.js_detailtablename + "]");
    }
    this.ResetgetDetailTableObj = function () {
        //edit:can 2020-09-17 获取单据分录table对象
        this.detailtableobj = ld("#" + this.divid + " [name=" + this.js_detailtablename + "]");
        return this.detailtableobj;
    }
    this.getTrObjsByDelType = function (DelType) {
        var tableobj = this.getDetailTableObj();
        if (DelType == 'no') {
            return ld(tableobj).find("tr[detaildeleted=no]");
        } else if (DelType == 'yes') {
            return ld(tableobj).find("tr[detaildeleted=yes]");
        }

    }
    this.getTrObjByChild = function (jqueryobj) {
        var tagname = '';
        if (ld(jqueryobj).length > 0) {
            while (ld(jqueryobj).prop("tagName") != undefined && ld(jqueryobj).prop("tagName") != "TR" && ld(jqueryobj).prop("tagName") != "BODY") {
                jqueryobj = ld(jqueryobj).parent();
            }
        }
        return jqueryobj;
    }
    this.setInnerHtml = function () {

        ld("#" + this.divid).html(this.popupheadhtml + this.scrolldiv + this.htmlcontent + '</div>' + this.popupbottomhtml);
        document.getElementById(this.divid).style.display = "block";
        this.setScrollDivMaxHeight();

    }
    this.createTextBeforeSave = function () {
        this.issavesubmit = 'no';
        var displaybtn = 'no';
        if (this.approve_arr != undefined && this.approve_arr.length > 0){
            displaybtn = 'yes';
        }
        var btn_html = '<input name="button" id="' + this.divid + '_btnsavesubmit" class="E_pbtnok ld-button ld-button-primary" value="' + this.savesubmittext + '" tagClick="savesubmit"  type="button" '+(displaybtn=='no'?'style="display:none;"':'')+' >';
        return  btn_html;
    }
    this.SaveSubmit = function () {
        //保存提交
        var approveid = ld("#" + that.divid + " [name=approvevalue]").val();
        // if(approveid == 0){
        //     RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['APPROVALNOTEMPTY']);            
        //     return '';
        // }
        if(approveid == 0 || approveid == -1){
            MessagePopup.TipZero_warning(arrJsPopLabel['APPROVALNOTEMPTY']);
            var selectobj = ld("#" + that.divid).find('a[name=cmb_a_approvevalue]');
            // var currentobj = selectobj.offset().top;
            var popup_scrollobj = ld("#" + that.divid).find('.dvpopupsroll');
            popup_scrollobj.scrollTop(popup_scrollobj.prop('scrollHeight'));

            selectobj.addClass('border_red1');
            setTimeout(() => {
                selectobj.removeClass('border_red1');
            }, 2000);
            return '';
        }
        var submitapprove_text = ld("#" + this.divid + " [id=submit_description]").val();//提交意见是否为空
        var submitlabelobj = ld("#" + this.divid + " [name=submitremarkrequire]");//提交意见是否必填
        if (ld.trim(submitapprove_text) == "" && ld(submitlabelobj).css("display") == "inline") {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
            return false;
        }
        this.issavesubmit = 'yes';
        getJsScript('include/js/DetailButtons.js', function () {
            SaveDataRecord.save();
        });

    }
    this.changeapproveEvent = function () {
        /*
        if (this.approve_arr == undefined || this.approve_arr.length <= 0)
            return;
        */
        ld("#" + this.divid + "_btnsavesubmit").unbind("click").bind("click", function () {
            that.SaveSubmit();
        })

        ld("#" + this.divid + " [name=approvevalue]").attr("onchange", '');
        ld("#" + this.divid + " [name=approvevalue]").unbind("change").bind("change", function () {
            that.ChangeApprove();
        })

    }
    this.ChangeApprove = function () {


        if (that.approve_arr == undefined || that.approve_arr.length <= 0)
            return;
        //审批流程改变事件

        var approveid = ld("#" + that.divid + " [name=approvevalue]").val();
        var requestvalues = getPageValueByCrmPopupFieldsNew(that);
        if(approveid == 0 || approveid == -1){
            var submitapprovestep_tableobj=ld("#"+that.divid+" [name=submitapprovestep_table]");
            submitapprovestep_tableobj.find("tr[tag=rowdata]").remove();
            ld("#" + that.divid + " [tag=rowdata]").css('display', 'none');
            return ;
        }
        var param = {
            "frommodule": that.module,
            "requestvalues": requestvalues['requestvalue'],
            "sensitiverequestfield": requestvalues['sensitiverequestfield'],
            "requestvalue_arr": requestvalues['requestvalue_arr']
        };
        var detaildata_arr = getPageValueByCrmPopupAllProductDetail(that);
        if(!empty(detaildata_arr)){
            param['detaildata_arr'] = detaildata_arr;
        }

        // urlstring+="&requestvalues="+encodeURIComponent(requestvalues);+"&requestvalue="+requestvalues
        ldAjaxNoProgress("index.php?module=Approve&action=ApproveAjax&file=getFirstStepInfo&approveid=" + approveid, param, function (ajaxdata) {
            //duan 20230905 BUG0072197:复制单据时，出现了产品禁用提示，导致审批流程中没有审批人,增加pagetype获取弹出层
            ajaxdata.pagetype = that.pagetype;
            ChangeSubmitHtml(ajaxdata);

            ld("#" + that.divid + " [tag=rowdata]").css('display', '');
            ld("#" + that.divid + " #subappcontent").css('width', '100%');

        })
    }
    this.getStagingEvent = function (data) {
        ld("#" + this.divid + "_btnstaging").unbind("click").bind("click", function () {
            var Popupobj = CrmPopup.getPopupObj("last");
            if (isAvailablelocalStorage) {
                var oldStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_old';
                //var tmpStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_tmp';
                var newStorageKey = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_new';

                var oldStorageKey_productdetail = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_old_productdetail';
                //var tmpStorageKey_productdetail = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_tmp_productdetail';
                var newStorageKey_productdetail = getCurrentUrlSite(false) + '_' + Popupobj.module + '_create_' + CURRENT_USER_ID + '_new_productdetail';
                localStorage.removeItem(newStorageKey);//浏览器强制刷新时会导致未清除(也可以不处理，会重新赋值)
                localStorage.removeItem(newStorageKey_productdetail);//浏览器强制刷新时会导致未清除(也可以不处理，会重新赋值)
                if (empty(localStorage.getItem(oldStorageKey))) {
                    audioRemindsMsg("", "", "", "", "", arrJsPopLabel['NotStaging']);
                    return;
                }

                //console.log(Popupobj.productfieldinfo.fields);分录字段
                var confirm_str = arrJsPopLabel['LoadLocalStorage'];//需要加载暂存信息
                if (confirm(confirm_str)) {
                    if (Popupobj.fields != undefined) {
                        // console.log('确定,加载缓存');
                        //TODO  如果是删除实例化过的富文本框，应该在html赋值之前，可惜无法使用UE.delEditor()，莫名的报错
                        //UE.delEditor();
                        /*if (!empty(localStorage.getItem(tmpStorageKey))) {
                            //如果存在tmpStorageKey 不为空，则为强制刷新浏览器的操作。
                            ld("#" + Popupobj.divid + ' form[name="EditView"]').html(localStorage.getItem(tmpStorageKey));
                        } else {
                            ld("#" + Popupobj.divid + ' form[name="EditView"]').html(localStorage.getItem(oldStorageKey));
                        }*/
                        ld("#" + Popupobj.divid + ' form[name="EditView"]').html(localStorage.getItem(oldStorageKey));
                        /* if (!empty(localStorage.getItem(tmpStorageKey_productdetail))) {
                             //如果存在tmpStorageKey 不为空，则为强制刷新浏览器的操作。
                             Popupobj.detaildatavalue_arr = JSON.parse(localStorage.getItem(tmpStorageKey_productdetail));
                         } else {
                             Popupobj.detaildatavalue_arr = JSON.parse(localStorage.getItem(oldStorageKey_productdetail));
                         }*/
                        //zxm 20230110 单据分录 绑定
                        Popupobj.islocalstorage = 'yes';

                        // Popupobj.show(localStorage.getItem(storageKey));

                        Popupobj.oCKeditors = [];
                        ld.each(Popupobj.fields, function (tmpindex, tmpfieldinfo) {
                            var tmpfieldname = tmpfieldinfo.fieldname;
                            if (tmpfieldinfo.uitype == '230' || tmpfieldinfo.uitype == '231') {
                                //zxm BUG0062868 新建页面，点击“获取暂存信息”，富文本框字段中的默认值内容会被清空
                                var content_txtarea = escape2Html(ld('#'+Popupobj.divid+" [name='"+tmpfieldname+"']").html());

                                ld('#' + tmpfieldname).empty();//清除编辑器实例化的html内容
                                var tmpokeditor = UE.getEditor(tmpfieldname);//实例化编辑器
                                Popupobj.oCKeditor = tmpokeditor;
                                Popupobj.oCKeditors[tmpfieldname] = tmpokeditor;
                                //UE.setOpt('en');
                                window.setTimeout(function (j) {
                                    //console.log(escape2Html(ld('#'+Popupobj.divid+" [name='"+j+"']").html()));
                                    Popupobj.oCKeditors[j].setContent(content_txtarea);//localStorage自动把标签转义了，需要反转义回来
                                    //ld('#ueditor_textarea_editorValue').remove();
                                    if( ld('#' +  j).find(".edui-editor").length>1)
                                    {
                                        ld('#' +  j).find(".edui-editor").not("#"+id).remove();
                                    }
                                }, 1000, tmpfieldname);
                            } else if (tmpfieldinfo.uitype == 33) {
                                ld("#" + tmpfieldname).nextAll('span').remove();
                                ld("#" + tmpfieldname).select2({
                                    closeOnSelect: false,
                                    dropdownParent: ld("#" + Popupobj.divid)
                                });
                            } else if (tmpfieldinfo.uitype == 251) {
                                //BUG20240227-17 ls 240227 费用报销单的账户字段,获取暂存后打不开下拉框
                                if(tmpfieldinfo.allowedit == 'yes'){
                                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpfieldname);
                                    cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
                                }
                            }else if (SaveDataRecord.isfileattachUitype(tmpfieldinfo.uitype)) {
                                //BUG0075336 lius 20231113  正常新增项目立项单据可以上传附件，点击获取暂存信息后再点击附件就不能跳出选择文件框
                                ld('#' + Popupobj.divid + ' [name='+tmpfieldname+']').empty();//清空原绑定事件生成的html
                                var fileuploader = CrmPopup.findHtmlobj(Popupobj.divid, tmpfieldname);
                                if (fileuploader.length > 0) {
                                    var uploadFile = new WebUploadFile();
                                    globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                                   
                                    uploadFile.setEvent(globalWebUploadType, fileuploader, that, tmpindex);
                                }

                                if (tmpfieldinfo.uitype == 28) {
                                    that.docfilename = tmpfieldnamee;
                                    showType();
                                }
                            }
                        });
                        /*popupobj.FieldSetEvent=function()
                        {
                                if(this.module=='Account')
                                {
                                    inputobj.unbind("change").bind("change",function(){

                                        filedruloejb.reload();
                                        formobj.change();
                                    })
                                }
                        }*/


                        //没有分录的模块无需处理
                        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0) {
                            if (localStorage.getItem(oldStorageKey_productdetail)!= undefined && localStorage.getItem(oldStorageKey_productdetail).length > 0 && localStorage.getItem(oldStorageKey_productdetail)!= 'undefined') {
                                Popupobj.detaildatavalue_arr = JSON.parse(localStorage.getItem(oldStorageKey_productdetail));
                            }
                            var tableobj = Popupobj.getDetailTableObj();
                            ld.each(Popupobj.detaildatavalue_arr, function (tmprowindex, tmpproductfieldinfo) {
                                Popupobj.detaildatavalue_arr[tmprowindex].databind = 'no';
                                var newrowindex = eval(tmprowindex) + 1;
                                var rowobj = ld(tableobj).find("tr[rowindex=" + newrowindex + "]");
                                Popupobj.selectproductobj.getMethod();
                                Popupobj.selectproductobj.isProductClear = 'no';
                                //出库或入库时必须严格参照源单
                                if (!Popupobj.selectproductobj.sourceOtherProducts()) return false;
                                if (Popupobj.selectproductobj.cur_module == 'QuotesChange' || Popupobj.selectproductobj.cur_module == 'BudgetChange') {
                                    if (CrmPopup.findHtmlobj(Popupobj.divid, 'change_type').val() != undefined && CrmPopup.findHtmlobj(Popupobj.cur_divid, 'change_type').val() == 'replace') {
                                        return false;
                                    }
                                }
                                Popupobj.selectproductobj.setDataBind(rowobj);//数据绑定

                                //DisCountFocusShowMess(Popupobj);	//光标定位在折扣率字段上，显示温馨提示信息
                                if (Popupobj.ordertype_onclick != undefined && Popupobj.ordertype_onclick != '' && Popupobjj.ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined) {
                                    setProductToolFieldDisplay('create', Popupobj);
                                }
                                setInventoryPickListContent(Popupobj);
                                Popupobj.SetDetailFieldControl(newrowindex);
                                //BUG0062771 zxm 20230413 kfbcrm 新建单据----点击获取暂存信息---获取后，分录字段无法快速填充---光标移过去也没有提示
                                Popupobj.selectproductobj.onmouseevent(ld(rowobj));
                            });



                            //BUG0060648 ls 20230112 产品分录【获取暂存信息】后，分录明细中的“多选框”字段输入框显示两行
                            ld.each(Popupobj.detailfields,function(tmpindex,tmpfieldinfo){
                                var tmpfieldname = tmpfieldinfo.fieldname;
                                if(tmpfieldinfo.uitype==63)
                                {
                                    ld("#"+Popupobj.divid + " [detailcolumnname=" + tmpfieldname + "]").nextAll('span').remove();
                                    ld("#"+Popupobj.divid + " [detailcolumnname=" + tmpfieldname + "]").select2({closeOnSelect: false, dropdownParent: ld("#"+Popupobj.divid)});
                                }else if (tmpfieldinfo.uitype==69) {
                                    ld("#"+Popupobj.divid + " [name=" + tmpfieldname + "]").empty();//原来上传的图片就会没有
                                }
                            });

                        }




                        Popupobj.ResetgetDetailTableObj();
                        Popupobj.beforeshowInitValue(data);
                        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0) {
                            Popupobj.SortDetailTableRow();//拖动行

                            Popupobj.detailfieldcolumninfo = [];
                            ld.each(Popupobj.detailfields, function (tmpindex, tmpfieldinfo) {
                                var tmpfieldname = tmpfieldinfo.fieldname;
                                //多选框 zxm
                                if (tmpfieldinfo.uitype == 63) {
                                    ld("[detailcolumnname=" + tmpfieldname + "]").nextAll('span').remove();
                                    ld("[detailcolumnname=" + tmpfieldname + "]").select2({
                                        closeOnSelect: false,
                                        dropdownParent: ld("#" + Popupobj.divid)
                                    });
                                }
                                if(Popupobj.detailtable_arr != undefined && !(Popupobj.detailtable_arr.indexOf(tmpfieldinfo.tablename)>-1)){
                                    return true;
                                }
                                Popupobj.detailfieldcolumninfo[tmpfieldinfo.columnname] = tmpfieldinfo;
                            })
                        }
                        Popupobj.setDetailAttachmentEvent();
                        //BUG20240828-57 ls 240904 获取暂存信息功能，设置了布局规则才显示的字段值暂存的值会被置空(设置有布局规则和字段公式的页面,获取暂存后,会触发字段公式的计算,计算之后又会触发布局规则,由于新建的popupobj.field里是没有布局规则隐藏的字段的,导致会取不到值(表现为页面会被置空))
                        // Popupobj.aftershowInitValue(data);//跟灿哥商量暂时先注释(注释后存在的问题: 当前如果有设置新的字段公式等等就会不生效)
                    }
                }
            }
        })


    }
    this.picklist_arrow_click = function (event, fieldname) {
        cmb_fldname = fieldname;//用于picklist.js中document.onclick调用
        cmb_parentdivid = this.divid;//用于picklist.js中document.onclick调用
        that.picklistobjarray[fieldname].arrow_click(fieldname);
    }
    this.picklist_end_foucs = function (event, fieldname) {
        var e = event || window.event;
        var obj = e.srcElement || e.target;//查询文本框

        if (ld(obj).attr("picklisttype") == 'smownerpicklist') {
            if (document.selection) {
                var range = document.body.createTextRange();
                range.moveToElementText(obj);
                range.select();
            } else if (window.getSelection) {
                var range = document.createRange();
                range.selectNodeContents(obj);
                window.getSelection().removeAllRanges();
                window.getSelection().addRange(range);
            }
        } else
            ld("#" + this.divid + " [name=cmb_span_optiontext_" + fieldname + "]").select();
        //var cur_value=ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").val();
        //ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").val("").focus().val(cur_value);

    }
    this.setParams = function (headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText) {
        that.parentsetParams.apply(that, [headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText]);

    }
    //zxm2021-0629 title部分增加【页面设置】【单据分录定制】按钮
    this.createHeadHtml = function () {
        var popupobj = CrmPopup.getPopupObj("last");
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        this.popupheadhtml += '<button class="ld-fonticon ld-fonticon-close tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose" data-direction="bottom" data-type="position" ></button>';
        //wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
        if(this.isShowFullscreen && that.getFullscreen()=='yes'){
            this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gosmall tip-items-pop' data-tip='" + arrJsPopLabel['RECOVERY'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='recovery'></i> ";
        } else if(this.isShowFullscreen && that.getFullscreen()=='no'){
            this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gobig tip-items-pop' data-tip='" + arrJsPopLabel['FULLSCREEN'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='fullscreen'></i> ";
        }
        if (this.module != "CustomEcharts" && popupobj != undefined &&popupobj.is_page_setting == "yes"  ) {//工作汇报-日程管理-新建 报错popupobj为undefined
            if (popupobj.detailfieldmodule != '' && popupobj.detailfieldmodule != undefined && this.module != "ExpenseBudget") {
                this.popupheadhtml += '<a target="_blank" href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ProductToolField&formodule=' + this.module + '" style="float: right">' + arrJsPopLabel['LBL_ProductTool_field'] + '</a>';
            }
            this.popupheadhtml += '<a target="_blank" href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&formodule=' + this.module + '" style="float: right;">' + arrJsPopLabel['LBL_PAGE_SET'] + '</a>';

        }
        /* 赛可出行
        * edit: chj
        * date: 2020/8/11
        * reason: 流转、更新、结案、结案备注
        */
        if (this.module == 'Accounts' && typeof (version_account) != "undefined" && version_account != undefined && version_account == 'saic') {

            if (popupobj.type == 'createpage' || popupobj.type == 'pagerecord') {
                this.popupheadhtml += '<a href="javascript:;" tag="closedremarks" value="结案备注" onclick="saic_save_account(ld(this),event);return false;" style="padding-right:50px;">结案备注</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="closed" value="结案" onclick="saic_save_account(ld(this),event);return false;">结案</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="wander" value="流转" onclick="saic_save_account(ld(this),event);return false;">流转</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="submit1" value="提交" onclick="saic_save_account(ld(this),event);return false;">提交</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="update" value="更新" onclick="saic_save_account(ld(this),event);return false;">更新</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="zancun" value="暂存" onclick="saic_save_account(ld(this),event)">暂存</a>';
            }
        }
        this.popupheadhtml += '</div>';

    }
    this.createBottomHtml = function () {
        if (this.OkText != "" && this.CancelText != "") {
            this.popupbottomhtml = '<div class="E_pbtn" id="' + this.divid + '_popupbottom"> ';
            this.popupbottomhtml += this.createTextBeforeSave();
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary" value="' + this.OkText + '" tagClick="' + this.Okfun.funname + '"  type="button">';
            if (isAvailablelocalStorage) {
                this.popupbottomhtml += '<input name="button" class="E_pbtnstaging ld-button" value="' + arrJsPopLabel['GetStaging'] + '" tagClick="staging" id="' + this.divid + '_btnstaging" type="button">'
            }
            this.popupbottomhtml += '<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'
            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
            this.btncancelid = this.divid + "_btncancel";
        }
    }

    /**
     *展开和收缩
     **/
    this.changepage = function () {

        for (var i = 0; i < this.fields.length; i++) {

            var curr_fieldname = this.fields[i].fieldname;
            curr_fieldname = CrmPopup.deletequotation(curr_fieldname);
            var referencemodule = this.fields[i].referencemodule;

            if (!CrmPopup.isExistsObj(this.divid, curr_fieldname) && !SaveDataRecord.isfileattachUitype(this.fields[i].uitype)) {
                continue;
            }
            var bigtype = this.fields[i].bigtype;
            var relatedmodulefield = this.fields[i].relatedmodulefield;

            this.deskvaluearr[curr_fieldname] = CrmPopup.getHtmlobjval(this.divid, curr_fieldname);
            if (this.fields[i].allowedit == 'no') {
                if (this.fields[i].uitype == 153) {
                    this.deskvaluearr["span_" + curr_fieldname] = CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html();
                } else
                    this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html();
            }
            //如果当前弹出层的元素在前一个弹出层也出现了，那么就把上一层的值赋值给当前层

            if (referencemodule != '' && referencemodule != undefined) {

                if(this.fields[i].uitype == 154){
                    this.deskvaluearr[curr_fieldname + "_name"] = (CrmPopup.findHtmlobj(this.divid, curr_fieldname + "_name").text());
                }
                else{
                    this.deskvaluearr[curr_fieldname + "_name"] = (CrmPopup.findHtmlobj(this.divid, curr_fieldname + "_name").val());
                }
            }

            if (this.fields[i].uitype == 33) {

                this.deskvaluearr[curr_fieldname] = [];
                CrmPopup.findHtmlobj(this.divid, curr_fieldname).find("option:selected").each(function () {
                    //多选框
                    that.deskvaluearr[curr_fieldname].push(ld(this).val());

                });
            }
            /*  else if(this.fields[i].uitype==153&&this.fields[i].allowedit=='no')
              {
                this.deskvaluearr["span_"+curr_fieldname] =(CrmPopup.findHtmlobj(this.divid,"span_"+curr_fieldname).html());
              }*/

            else if (this.fields[i].uitype == 102)//项目 - 选择源单
            {
                this.deskvaluearr['salesorder_id'] = CrmPopup.findHtmlobj(this.divid, 'salesorder_id').val();
                //zkt 20230531 BUG0067247 https://www.51mis.com/hy/516项目管理新建并选择源单-往下滑点击收起-再展开-显示客户名称却不显示源单编号
                this.deskvaluearr['salesorder_id_name'] = CrmPopup.findHtmlobj(this.divid, 'salesorder_id_name').val();
                this.deskvaluearr['salesorder_id_type'] = CrmPopup.findHtmlobj(this.divid, 'salesorder_id_type').val();
            } else if (this.fields[i].uitype == 100)//提醒人
            {
                this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
                this.deskvaluearr['txt_select_user'] = CrmPopup.findHtmlobj(this.divid, 'txt_select_user').val();
            } else if (this.fields[i].uitype == 242)//接受人
            {
                this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
                this.deskvaluearr[curr_fieldname + '_name'] = CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_name').val();
            } else if (this.fields[i].uitype == 53 || this.fields[i].uitype == 153) {
                this.deskvaluearr[curr_fieldname + "_cmb_span"] = CrmPopup.findHtmlobj(this.divid, "cmb_span_optiontext_" + curr_fieldname).text();

                this.deskvaluearr[curr_fieldname + "_select"] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).get(0).selectedIndex;
            } else if (this.fields[i].uitype == 117) {
                this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
            } else if (this.fields[i].uitype == 112) {
                //zkt 20230531 BUG0067160 kfbcrm首页附件管理中点击新建选择客户之后展开更多栏目我选择的客户也随之消失 
                this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
                this.deskvaluearr[curr_fieldname + '_type'] = CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_type').val();
                this.deskvaluearr[curr_fieldname + '_name'] = CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_name').val();
            } else if (this.fields[i].uitype == 15) {
                //BUG0073686 lius 20231017 联系人-新建-下拉框字段“联系人手机办公电话”，直接输入内容，点击保存，会提示字段不能为空，但是点击“展开更多栏目”判断就不生效了，可以保存单据
                this.deskvaluearr[curr_fieldname + "_cmb_span"] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
                this.deskvaluearr[curr_fieldname] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();

            }else if (this.fields[i].uitype == 1600) {
                this.deskvaluearr[curr_fieldname + "_name"] = CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html();

                this.deskvaluearr[curr_fieldname ] = CrmPopup.findHtmlobj(this.divid, curr_fieldname).val();
            } else if (SaveDataRecord.isfileattachUitype(this.fields[i].uitype)) {

                var fileuploader = CrmPopup.findHtmlobj(this.divid, this.fields[i].fieldname);
                var tmp_fieldname = this.fields[i].fieldname;
                var tmp_columnname = this.fields[i].columnname;
                for (var k = 1; k <= 100; k++) {

                    if (fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]") != undefined && fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").length > 0 && fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").val() != undefined) {
                        var filearr = {};

                        filearr['newfile_name'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "newfile_name_" + k + "]").val();
                        filearr['file_name'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_name_" + k + "]").val();
                        filearr['file_type'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_type_" + k + "]").val();
                        filearr['file_size'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_size_" + k + "]").val();
                        filearr['file_path'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "file_path_" + k + "]").val();

                        filearr['cloud_path'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "cloud_path" + k + "]").val();
                        filearr['storage_location'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "storage_location" + k + "]").val();
                        filearr['upload_from'] = fileuploader.find("[name=" + tmp_fieldname + "-" + "upload_from" + k + "]").val();
                        if (this.filejsondata[tmp_columnname] == undefined || k == 1) {
                            this.filejsondata[tmp_columnname] = [];
                        }
                        this.filejsondata[tmp_columnname].push(filearr);

                    }
                }

            }

        }


        if (that.showquickcreate == 'yes') {
            that.showquickcreate = "no";
            that.show(that.allhtmlcontent);
        } else {
            that.showquickcreate = "yes";
            that.show(that.quickcreatehtml);
        }

        if(that.calendar_picklistdata_json !=undefined){
			//zkt 20240905 BUG20240905-48 快速创建，新建日程管理，日程管理界面：循环日程页签下面，提醒设置不能下拉选择；(邱：多选框插件没有生效)
            if(that.loopCalendarobj != undefined){
                var loopCalendarobj=that.loopCalendarobj;
                loopCalendarobj.setEvent();
            }
            else{
                getJsScript('include/js/modules/Calendar/LoopCalendar.js', function () {
                    var loopCalendarobj=new LoopCalendar();
                    var picklistdata = that.calendar_picklistdata_json;
                    loopCalendarobj.picklistdata = eval('('+ picklistdata +')')?eval('('+ picklistdata +')'):JSON.parse(picklistdata);
                    loopCalendarobj.pagemode = that.pagemode;
                    loopCalendarobj.setEvent();
                })
            }
        }

        // @edit:liushuai,2021-06-16,reason:0046359: 新建单据提交审批问题；模块-自定义表单01，新建单据时，设置的默认显示快速创建字段，展开全部字段后，下方选择审批流界面异常
        if (this.approve_arr != undefined && this.approve_arr.length > 0) {
            this.ChangeApprove();
        }
        that.setScrollDivMaxHeight();

        that.center();

        for (var i = 0; i < this.fields.length; i++) {
            var curr_fieldname = this.fields[i].fieldname;
            curr_fieldname = CrmPopup.deletequotation(curr_fieldname);
            var referencemodule = this.fields[i].referencemodule;

            if (!CrmPopup.isExistsObj(this.divid, curr_fieldname)) {
                continue;
            }
            if (this.deskvaluearr[curr_fieldname] == undefined)
                continue;
            var bigtype = this.fields[i].bigtype;
            var relatedmodulefield = this.fields[i].relatedmodulefield;

            if (this.fields[i].allowedit == 'no') {
                if (this.fields[i].uitype == 153) {
                    //引用了选择成员的字段
                    //38191: 页面设置->新增字段->引用字段->引用客户销售负责人、保存到数据库、不可编辑，带出信息后收起/展开字段显示为ID了
                    CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html(this.deskvaluearr["span_" + curr_fieldname]);
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).html(this.deskvaluearr[curr_fieldname]);
                } else
                    CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html(this.deskvaluearr[curr_fieldname]);
            }
            //如果当前弹出层的元素在前一个弹出层也出现了，那么就把上一层的值赋值给当前层
            if (CrmPopup.findHtmlobj(this.divid, "sel_"+curr_fieldname).attr("type") == "checkbox") {
                if (this.deskvaluearr[curr_fieldname] == 1) {
                    CrmPopup.findHtmlobj(this.divid, "sel_"+curr_fieldname).click();
                    CrmPopup.findHtmlobj(this.divid, "sel_"+curr_fieldname).attr("checked", this.deskvaluearr[curr_fieldname]);
                }

            } else if (this.fields[i].uitype == 33) {
                //多选框
                if (this.deskvaluearr[curr_fieldname].length >= 1) {
                    ld.each(this.deskvaluearr[curr_fieldname], function (index, value) {
                        ld("#" + curr_fieldname + " option").each(function () {
                            if (ld(this).val() == value) {
                                ld(this).attr("selected", "selected");
                            }
                        })
                    });
                    ld("#" + curr_fieldname).select2({closeOnSelect: false});

                }

            } else if (this.fields[i].uitype == 53 || this.fields[i].uitype == 153) {
                if (this.deskvaluearr[curr_fieldname + "_select"] != undefined) {
                    CrmPopup.findHtmlobj(this.divid, "cmb_span_optiontext_" + curr_fieldname).text(this.deskvaluearr[curr_fieldname + "_cmb_span"]);

                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).get(0).selectedIndex = this.deskvaluearr[curr_fieldname + "_select"];
                }
            } else if (this.fields[i].uitype == 154) {
                CrmPopup.findHtmlobj(this.divid, curr_fieldname+ "_name").text(this.deskvaluearr[curr_fieldname+"_name"]);
            }else if (this.fields[i].uitype == 117) {
                CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
            } else if (this.fields[i].uitype == 15) {


                CrmPopup.findHtmlobj(this.divid, "cmb_span_optiontext_" + curr_fieldname).val(this.deskvaluearr[curr_fieldname + "_cmb_span"]);
                CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                //级联字段
                if (typeof CrmPopup.findHtmlobj(this.divid, curr_fieldname).change == 'function')
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).change();

            } else if (CrmPopup.findHtmlobj(this.divid, curr_fieldname).attr("type") == "text" ||
                CrmPopup.findHtmlobj(this.divid, curr_fieldname).attr("type") == "hidden" ||
                (CrmPopup.findHtmlobj(this.divid, curr_fieldname).prop('tagName') != undefined && CrmPopup.findHtmlobj(this.divid, curr_fieldname).prop('tagName').toLowerCase() == 'textarea')) {
                if (this.fields[i].uitype == 4) {
                    //单据编号可以自动生成
                    if (this.deskvaluearr[curr_fieldname] != "" && this.deskvaluearr[curr_fieldname] != undefined) {
                        CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    }
                } else if (this.fields[i].uitype == 102) {	//项目 - 选择源单
                    CrmPopup.findHtmlobj(this.divid, 'salesorder_id').val(this.deskvaluearr['salesorder_id']);
                    CrmPopup.findHtmlobj(this.divid, 'salesorder_id_name').val(this.deskvaluearr['salesorder_id_name']);
                    CrmPopup.findHtmlobj(this.divid, 'salesorder_id_type').val(this.deskvaluearr['salesorder_id_type']);
                } else if (this.fields[i].uitype == 100)//提醒人
                {
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    CrmPopup.findHtmlobj(this.divid, 'txt_select_user').val(this.deskvaluearr['txt_select_user']);
                } else if (this.fields[i].uitype == 242)//接受人
                {
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_name').val(this.deskvaluearr[curr_fieldname + '_name']);

                } else if (this.fields[i].uitype == 112) {
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_type').val(this.deskvaluearr[curr_fieldname + '_type']);
                    
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname + '_name').val(this.deskvaluearr[curr_fieldname + '_name']);
                }else if (this.fields[i].uitype == 1600) {
                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    CrmPopup.findHtmlobj(this.divid, "span_" + curr_fieldname).html(this.deskvaluearr[curr_fieldname + '_name']);
                } else {

                    CrmPopup.findHtmlobj(this.divid, curr_fieldname).val(this.deskvaluearr[curr_fieldname]);
                    if (referencemodule != '' && referencemodule != undefined) {
                        CrmPopup.findHtmlobj(this.divid, curr_fieldname + "_name").val(this.deskvaluearr[curr_fieldname + "_name"]);
                    }
                }
            }

        }


        ld('textarea').not('.proName_note').autosize();//textarea根据内容自动调整大小
        //that.fieldruleobj.CheckReLoadPopup();
    }
    /**
     *获取界面的值
     **/
    this.getsavedeskpageValue = function () {
        //BUG20240228-01 ls 240229 【出库单】，复制 已审核 、出库状态已出库的单据做单时，在保存界面的出库状态改为‘未出库’，但是保存后变为‘已出库’
        var that = this;
        ld.each(that.columnfields_value, function (fieldname, value) {
            //获取界面没有显示的字段的值
            if (!CrmPopup.isExistsObj(that.divid, fieldname) && that.deskvaluearr[fieldname] == undefined) {
                if (that.fieldname_fields.hasOwnProperty(fieldname) && (that.fieldname_fields[fieldname].displaytype == 1 || that.fieldname_fields[fieldname].displaytype == 4)) {
                    if (that.uitypes[fieldname] == 56) {
                        if (fieldname == 'discontinued')
                            that.deskvaluearr[fieldname] = 0;
                    else {
                            //35906: 新建银行账户“欧元”，结束初始化后，在收款单、费用报销等单据上无法看到该银行账户
                            that.deskvaluearr[fieldname] = 1;
                        }
                    } else
                        that.deskvaluearr[fieldname] = value;
                }

            }

        });
        return this.deskvaluearr;


    }
    /**
     **/
    this.getFileDataArr = function () {
        return "";
    }
    this.setTimeCount = function () {
        this.timeintervalid = setInterval(function () {
            that.timeCount += 3;
        }, 3000);


    }
    this.clearTimeCount = function () {
        this.timeCount = 0;

        clearInterval(this.timeintervalid);
    }
    var parentcancelevent = this.CancelEvent;
    this.CancelEvent = function () {

        parentcancelevent.apply(this, []);
        this.clearTimeCount();
    }
    /**
     重新加载内容
     **/
    this.reload = function (htmlcontent) {
        document.getElementById(this.divid).innerHTML = this.popupheadhtml +
            this.scrolldiv +
            htmlcontent + '</div>' + this.popupbottomhtml;
        document.getElementById(this.divid).style.display = "block";
        this.setScrollDivMaxHeight();
        this.setEvent();
    }

    this.getpopupMaxHeight = function () {
        return CrmPopup.getClientHeight();
    }
    /*var parentprevshow=this.prevshow;
    this.prevshow=function()
    {
        this.popupMaxHeight=CrmPopup.getClientHeight();

        parentprevshow.apply(that,[]);

    }*/
    this.show = function (htmlcontent) {
        if (this.showquickcreate == 'yes') {
            that.quickcreatehtml = htmlcontent;
        }

        if (that.quickcreatehtml != undefined && that.quickcreatehtml.indexOf('##noquickdata##') >= 0) {
            htmlcontent = that.allhtmlcontent;
        }
        parentshow.apply(this, [htmlcontent]);  //调用父类show()函数
        if (that.detailfields != undefined && that.detailfields.length > 0) {

            that.SortDetailTableRow();//拖动行

            var trobjs = this.getTrObjsByDelType("no");
            var rowcnt = ld(trobjs).length;
            for (var tmpi = 1; tmpi <= rowcnt; tmpi++) {
                this.SetDetailFieldControl(tmpi);
            }

            that.detailfieldcolumninfo = [];
            ld.each(that.detailfields, function (tmpindex, tmpfieldinfo) {
                //zkt 20230719 BUG0069585 折扣额无法自动带出  同时启用折扣额和整单折扣字段
                if(that.detailtable_arr != undefined && !(that.detailtable_arr.indexOf(tmpfieldinfo.tablename)>-1)){
                    return true;
                }
                that.detailfieldcolumninfo[tmpfieldinfo.columnname] = tmpfieldinfo;
            })

        }
        if (that.quickcreatehtml.indexOf('##noquickdata##') >= 0) {
            //放在show函数后面判断是对的，不要移动
            CrmPopup.findHtmlobj(this.divid, "dv_pagecollapse").css("display", "none");
        }

        if (this.showquickcreate == "no" && that.clickchangepage == 'no') {
            //clickchangepage:是否点击：展开收缩
            //初始化调用
            this.showafter();
        }

        that.updateBlocklist();

        that.InitPageValue();

        CreatePagePopup.moduleEdit(that);

        that.setDetailAttachmentEvent();

        that.setRelatedFieldEvent();

        that.center();
    }
    this.updateBlocklist=function()
    {
        //XUQIU1002354 新增编辑界面优化
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]");
        var block_list = [];
        ld.each(ld(blockobjs),function(tmpindex,tmpblockobj){
            if(ld(tmpblockobj).is(':visible')){
                block_list[tmpindex]=ld(tmpblockobj).text();
            }
        })
        var editleft_html = '<ul>';
        ld.each(block_list,function(tmpindex,tmpblock_label) {
            editleft_html += '<li><div class="block-list" block_index="'+tmpindex+'"><a title="'+tmpblock_label+'">'+tmpblock_label+'</a></div></li>';
        });
        editleft_html += '</ul>';
        ld("#"+that.divid+" .edit-left").html(editleft_html);
    }
    this.SetDetailFieldControl = function (rowindex) {
        var rowobj = ld("#" + that.divid + " #" + that.js_detailtablename).find("tr[rowindex=" + rowindex + "]");
        var selectobjs = ld(rowobj).find("[fieldtype=select]");
        var strrowindex = rowindex + "";//转换为字符串
        var rowindex_strlen = strrowindex.length;
        ld.each(selectobjs, function () {
            var name = ld(this).attr("name");
            var columnname = name;//name.substr(0,name.length-rowindex_strlen);


            var comboxobj = ld(this);
            var cls_resetComboxHtmlobj = new cls_resetComboxHtml(name);
            var picklistcontent = that.detailpicklist[columnname];
            var picklistcontentseq = that.detailpicklistseq[columnname];

            cls_resetComboxHtmlobj.setPopupObj(that);//edit:can 产品多选//产品套餐选择
            cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowindex);
            cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
            cls_resetComboxHtmlobj.setPickListContentseq(picklistcontentseq);


            var tmpwidth = Tools.Number.convertmmToPx(ld("#" + that.divid + " [head_detailfieldname=" + columnname + "]").attr("head_width"));
            tmpwidth = parseInt(tmpwidth);
            var setgreyobj = ld(comboxobj).parent().find(" .icon-setgrey");
            var setobj = ld(comboxobj).parent().find("[name=picklistset_icon]");

            //dv_chzn_minusjobtype
            if (setgreyobj.length > 0 || setobj.length > 0) {
                var settingwdith = parseInt(ld(setgreyobj).css("width"));
                var picklist_colors_values = that.detailpicklistColors[columnname];
                cls_resetComboxHtmlobj.setPickListColors(picklist_colors_values);
                if (that.detailfieldmodule == 'Products')
                    cls_resetComboxHtmlobj.setEvent();
                else
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj, tmpwidth - 10);
            } else {
                if (that.detailfieldmodule == 'Products')
                    cls_resetComboxHtmlobj.setEvent(); //仓库
                else
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj, tmpwidth);
            }

        })
        ld.each(that.detailfields, function (tmpindex, tmpdetailfieldinfo) {
            //edit:can 20200731 42213: （61mis.com/kfbcrm）费用报销单模块>新建单据界面：分录明细自定义“多选框111”字段无法选择（需要补丁）
            if (tmpdetailfieldinfo.edit_permission != 1 && (tmpdetailfieldinfo.uitype == 63 || tmpdetailfieldinfo.fieldtype == 'SelectComBox')) {
                //多选框 edit:wangcong 20201229 0049441: （81mis.com/kfbtest/index.php）自定义表单11》新建界面：分录的多选框字段无法连续多选（设置连续多选不收起）
                 if(that.detailfieldmodule == 'Products')
                 {
                    ld(rowobj).find("#" + tmpdetailfieldinfo.columnname).select2({
                        closeOnSelect: false,
                        dropdownParent: ld("#" + that.divid)
                    });
                 }
                 else{
                    ld(rowobj).find("#"+tmpdetailfieldinfo.columnname).select2({
                        closeOnSelect: false,
                        dropdownParent: ld("#" + that.divid)
                    });
                 }
                
            }


        })
        
        //zkt 先注释，后续客户那边实现方式修改
        /*
        if (that.module == 'CustomForm26') {
            ld(rowobj).find(" #sf314]").unbind("change").bind("change", function () {
                var cls_resetComboxHtmlobj = new cls_resetComboxHtml("sf315");
                var comboxobj = ld(rowobj).find(" #sf315");

                var setgreyobj = ld(comboxobj).parent().find(" .icon-setgrey");

                cls_resetComboxHtmlobj.setPopupObj(popupobj);//edit:can 产品多选//产品套餐选择
                cls_resetComboxHtmlobj.setDetailFieldRowIndex(rowindex);

                var picklistcontent = [];
                switch (ld(this).val()) {
                    case '线索阶段':
                        picklistcontent.push("客户面谈，客户需求挖掘/现场勘察");
                        picklistcontent.push("商机决策");
                        break;
                    case '商机阶段':
                        picklistcontent.push("客户基本信息摸排（预算、决策链、全面客户关系管理策略）");
                        picklistcontent.push("策划方案启动会");
                        picklistcontent.push("概念方案制作");
                        picklistcontent.push("概念方案内审/交底");
                        picklistcontent.push("概念方案概算/内审");
                        picklistcontent.push("立项决策");
                        break
                    case '立项阶段':
                        picklistcontent.push("立项会输出：边际目标、项目CEO、项目级别、施工范围、合同引导目标");
                        picklistcontent.push("全面客户关系管理目标和实施计划");
                        picklistcontent.push("设计方案勘察现场");
                        picklistcontent.push("设计方案制作");
                        picklistcontent.push("《设计方案》内审");
                        picklistcontent.push("《设计方案》清单预算/内审");
                        picklistcontent.push("《设计方案》汇报并获得决策人认可，方案定稿");
                        picklistcontent.push("《设计方案》交底");
                        picklistcontent.push("施工图设计/内审");
                        picklistcontent.push("设计施工方案报价清单/内审");
                        break;
                    case '商务谈判阶段':
                        picklistcontent.push("明确客户内部采购流程及决策因素");
                        picklistcontent.push("明确客户招投标流程及影响因素");
                        picklistcontent.push("商务流程推动（前审）");
                        picklistcontent.push("标书撰写及排他性举措");
                        picklistcontent.push("客户发标书");
                        picklistcontent.push("投标决策");
                        picklistcontent.push("拆标会（投标组织和策略制定）");
                        picklistcontent.push("标书制作");
                        picklistcontent.push("投标文件内审评标");
                        break;
                    case '合同签订阶段':
                        picklistcontent.push("中标/中标方案确认");
                        picklistcontent.push("设计方案深化");
                        picklistcontent.push("合同决策");
                        picklistcontent.push("合同签订");
                        picklistcontent.push("首付款");
                        break;
                    case '交付阶段':
                        picklistcontent.push('客户预计使用时间');
                        break;
                    case '交付阶段-项目启动':
                        picklistcontent.push("项目内部启动会");
                        break;
                    case '交付阶段-深化设计':
                        picklistcontent.push("深化设计（方案深化、图纸深化、全专业合图）");
                        picklistcontent.push("深化设计内审");
                        picklistcontent.push("深化设计汇报/确认 ");
                        picklistcontent.push("深化设计交底");
                        break;
                    case '交付阶段-装修':
                        picklistcontent.push("空间方案确认");
                        picklistcontent.push("装修分包进场-放线验线");
                        picklistcontent.push("封样/定样");
                        picklistcontent.push("隐蔽验收");
                        picklistcontent.push("装修收尾");
                        break;
                    case '交付阶段-美工':
                        picklistcontent.push("资料整理");
                        picklistcontent.push("方案汇报/确认");
                        picklistcontent.push("美工/1:1上墙");
                        picklistcontent.push("平面发排");
                        picklistcontent.push("设计交底");
                        picklistcontent.push("美工收尾");
                        break;
                    case '交付阶段-沙盘/模型/雕塑':
                        picklistcontent.push("方案确认");
                        picklistcontent.push("过程/出厂验收");
                        break;
                    case '交付阶段-多媒体/设备设计、实施':
                        picklistcontent.push("多媒体/设备设计方案确认");
                        picklistcontent.push("多媒体/设备设计中勘");
                        picklistcontent.push("主要设备进场/报验");
                        picklistcontent.push("展项调试完成");
                        break;
                    case '交付阶段-影片/程序':
                        picklistcontent.push("影片脚本/程序方案汇报及确认");
                        picklistcontent.push("影片预演/程序DEMO汇报及确认");
                        picklistcontent.push("成片/程序完整版输出");
                        break;
                    case '交付阶段-竣工验收':
                        picklistcontent.push("内部验收");
                        picklistcontent.push("外部初验");
                        picklistcontent.push("外部竣工验收");
                        break;
                    case '结算阶段':
                        picklistcontent.push("审计结算资料及报送甲方");
                        picklistcontent.push("完成对审，定案");
                        break;
                    case '客户使用时间':
                        picklistcontent.push("客户使用时间");
                        break;
                }
                ld(comboxobj).empty();
                ld.each(picklistcontent, function (index, value) {
                    comboxobj.append("<option value='" + value + "'>" + value + "</option>");
                })
                cls_resetComboxHtmlobj.setPickListContent(picklistcontent);
                var settingwdith = parseInt(ld(setgreyobj).css("width"));
                var picklist_colors_values = popupobj.detailpicklistColors['sf315'];
                cls_resetComboxHtmlobj.setPickListColors(picklist_colors_values);
                var tmpwidth = Tools.Number.convertmmToPx(ld("#" + that.divid + " [head_detailfieldname=sf315]").attr("head_width"));
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(comboxobj, tmpwidth - 40);
            })
        }
        */
    }
    this.InitPageValue = function () {

        if (that.picklistcontent != null && that.picklistcontent != undefined)
            for (var k = 0; k < that.picklistcontent.length; k++) {
                //下拉框
                var fieldname = that.picklistcontent[k].fieldname;
                that.picklistobjarray[that.picklistcontent[k].fieldname] = new cls_picklist(that.picklistcontent[k].fieldname, that.picklistcontent[k].optionvalue);

                if (that.picklistdepencyfields != null && that.picklistdepencyfields != "" && that.picklistdepencyfields[fieldname] != undefined) {

                    that.picklistobjarray[that.picklistcontent[k].fieldname].setparentDependField(that.picklistdepencyfields[fieldname]);

                }
            }

        if (that.picklistdepencyfields != null && that.picklistdepencyfields != undefined) {
            ld.each(that.picklistdepencyfields, function (childfieldname, parentfieldname) {
                if (that.picklistobjarray[parentfieldname] != undefined) {

                    that.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
                }
            });
        }

        fielddepend = new FieldDependencies(this.picklistdepency);
        fielddepend.setup(CrmPopup.findHtmlobj(this.divid, "EditView"));
        //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/3/2 11:22
        var webUploadType = false;
        for (var i = 0; i < this.fields.length; i++) {

            if (SaveDataRecord.isfileattachUitype(this.fields[i].uitype)) {
                var fileuploader = CrmPopup.findHtmlobj(this.divid, this.fields[i].fieldname);
                if (fileuploader.length > 0) {
                    var uploadFile = new WebUploadFile();
                    globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                    uploadFile.setEvent(globalWebUploadType, fileuploader, that, i);
                }

                if (that.fields[i].uitype == 28) {
                    that.docfilename = this.fields[i].fieldname;
                    showType();

                }
            } else if (this.fields[i].uitype == 230 || this.fields[i].uitype == 231) {


                var tmpokeditor = UE.getEditor(that.fields[i].fieldname);//实例化编辑器
                this.oCKeditor = tmpokeditor;
                this.oCKeditors[that.fields[i].fieldname] = tmpokeditor;

                var tmpfieldname = that.fields[i].fieldname;
                window.setTimeout(function (j) {

                    var id = ld('#' + j).children("div:first-child").attr("id");
                    ld('#' + id).css('z-index', '99999');
                    ld('#' + id).css('width','100%');
                    that.center();//38378: （51mis.com/kfbcrm）公告模块新增界面：新增弹出层没有在当前屏幕居中，太靠下了。
                    //zkt BUG20240830-04 BUG管理，BUG管理界面，按F5刷新页面，新建bug的时候，详情下面会有3个富文本框；原因及解决办法那里也有；第二次新建就没有了；（谷歌浏览器）
                    if( ld('#' +  j).find(".edui-editor").length>1)
                    {
                        ld('#' +  j).find(".edui-editor").not("#"+id).remove();
                    }
                }, 400, tmpfieldname);

            } else if (this.fields[i].uitype == 33) {
                //33706: 新建联系人界面：点击“上级联系人”后面的“+”，进入快速创建界面，“多选框”字段没有弹出层
                var tmpfieldname = that.fields[i].fieldname;
                //设置select2的zIndex
                ld('#' + this.divid + " [name='" + tmpfieldname + "[]']").select2({
                    closeOnSelect: false,
                    dropdownParent: ld("#" + this.divid)
                });//新建详情页面的多选框支持连续多选不收起
            } else if (this.fields[i].uitype == 251) {
                //40471: （http://51mis.com/demo/panlulu004演示账套 [^]）财务核算->收款单，收款单新建界面，选择客户有预收单的源单后，更改账户下拉选项，可使用的预收单信息也应该随之更新
                if (this.fields[i].allowedit == 'yes') {
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(that.fields[i].fieldname);
                    cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);
                    ld('[name=dv_drop_'+that.fields[i].fieldname+']').css('width',ld('[name=dv_chzn_'+that.fields[i].fieldname+']').width());
                }
            }else if (this.fields[i].uitype == 65){
                var tmpfieldname = that.fields[i].fieldname;
                var locationaddressobj = ld('#'+this.divid).find('#'+tmpfieldname);
                if (locationaddressobj.length > 0){
                    locationaddressobj.unbind('compositionstart').bind('compositionstart',function(){ //开始输入
                        ld(this).attr('inputtype','start');
                    });
                    locationaddressobj.unbind('compositionend').bind('compositionend',function(){ //结束输入
                        ld(this).attr('inputtype','finish');
                    });
                }
            }
        }
        that.column_fields = [];

        ld.each(that.fields, function (tmpindex, fieldinfo) {

            that.fieldname_fields[fieldinfo.fieldname] = fieldinfo;
            that.column_fields[fieldinfo.columnname] = fieldinfo;
            //判断不要重复绑定，data.result.approve_fieldname_arr
            if(!empty(that.approve_fieldname_arr)){
                if(that.approve_fieldname_arr['main_fieldname'].includes(fieldinfo.fieldname)){
                    return true;
                }
            }
            if (fieldinfo.uitype == 53 || fieldinfo.uitype == 153 || fieldinfo.uitype == 154) {
                //edit:can 20220628 服务工单模块，单据号FWGD-0016，第一步审批找不到审批人，详见单据的审批日志~
                var tmpobj = ld("#" + that.divid + " [name=" + fieldinfo.fieldname + "]");

                ld(tmpobj).unbind("change", that.ChangeApprove);
                ld(tmpobj).bind("change", event, that.ChangeApprove);


            }

        })

        var fieldruleobj = new cls_fieldrule(that, that.fieldrulefieldnames);
        that.fieldruleobj = fieldruleobj;
        fieldruleobj.setEvent();
        fieldruleobj.setValues(that.columnfields_value);
        var fieldSensitiveruleobj=new cls_fieldSensitiverule(that,that.sensitiverelatedfield);
        that.fieldSensitiveruleobj=fieldSensitiveruleobj;
        fieldSensitiveruleobj.setEvent();
        //edit:can 2021-01-06 042970: （8.2.7安装包）项目工时新建界面，工时详细信息区块界面显示异常
        //20231010 hzx resetDetailColumns调用移到aftershowInitValue函数
        // if (that.detailfields != undefined && that.detailfields.length > 0) {
        //
        //     fieldruleobj.resetDetailColumns();//布局规则，重新设置分录表头的显示和隐藏
        // }
        if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(that);
        }
        if (account_version == 'langjie') {
            //edit：can 20200803 郎捷,分录数量的控制
            if (that.module == 'CustomForm18')
                setTableTdLabellangjie();
            else if (that.module == 'CustomForm19')
                setTableTdLabellangjieCustomForm19();


        }

        var blocklist_obj = ld('#' + this.divid).find('.block-list');
        
        ld.each(blocklist_obj,function(tmpindex,tmpblockobj){//wym XUQIU1002285 新增编辑界面，点击左侧快速定位到指定区块
            ld(tmpblockobj).unbind("click").bind("click", function () {
                that.blocklist_anchor(this);
            })
        })
        ld("#" + this.divid + " .dvpopupsroll").get(0).addEventListener('scroll', that.blocklist_scroll);
        that.blocklist_scroll();//一进界面先触发一下滚动事件

        that.setSpecialEvent();//布局规则参与时，会调用方法InitPageValue()，故放到此处公共调用

        that.setCommonFieldEvent();//绑定公共字段事件

        //产品模块 zxm 20241011
        if(that.setObjEventArr){
            ld.each(that.setObjEventArr,function(i,eventfun){
                eventfun();
            })
        }

    }
    //wym XUQIU1002285 新增编辑界面，左侧增加快速定位到指定区块
    this.blocklist_anchor = function (obj) {
        var blockobj= ld('#'+this.divid+' .block-list.selected');
        ld(blockobj).removeClass('selected');
        ld(blockobj).find('a').css('color','#8392A7');
        ld(obj).addClass('selected');
        ld(obj).find('a').css('color','#3B7CFF');
        var target_index = ld(obj).attr('block_index'); // 获取点击的区块序号
        //XUQIU1002354 新增编辑界面优化
        var targetElement = ld("#"+that.divid+" [tag=headblock-title]").eq(target_index); // 查找对应序号的区块
        if (targetElement.length) {
            var scrollobj= ld('#'+this.divid+' .dvpopupsroll');
            var currentScrollPosition = ld(scrollobj).scrollTop();
            if(ld("#" + that.divid + '_head').length>0){
                var headheight = ld("#" + that.divid + '_head').outerHeight();
            }
            //点击事件不能触发滚动事件，先把右侧滚动条事件解绑
            ld(scrollobj).get(0).removeEventListener('scroll', that.blocklist_scroll);
            // 使用动画效果滚动到目标元素
            ld(scrollobj).get(0).scrollTop = currentScrollPosition+targetElement.offset().top-headheight;

            // 等待一段时间，然后重新绑定滚动事件处理程序
            setTimeout(function () {
                ld(scrollobj).get(0).addEventListener('scroll', that.blocklist_scroll);
            }, 1000); // 1秒后重新绑定滚动事件处理程序
        }
    }
    //wym XUQIU1002285 右侧滚动，左侧选中当前区块
    this.blocklist_scroll = function () {
        //XUQIU1002354 新增编辑界面优化
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]"); //区块标题元素
        var headheight=0;
        if(ld("#" + that.divid + '_head').length>0){
            headheight = ld("#" + that.divid + '_head').outerHeight();
        }
        ld.each(ld(blockobjs),function(tmpindex,tmpobj){
            var targettop = ld(tmpobj).offset().top-headheight;
            if(targettop>=0){
                var select_blockobj= ld('#'+that.divid+' .block-list.selected');
                if(ld(select_blockobj).length>0){
                    ld(select_blockobj).removeClass('selected');
                    ld(select_blockobj).find('a').css('color','#8392A7');
                }
                var blockobjs= ld('#'+that.divid+' .block-list');
                if(targettop>0){//targettop大于零，则表示是上一个区块
                    if(tmpindex==0){ //BUG0077529 如果是第一个区块 则选中第一个
                        var cur_blockobj=ld(blockobjs).eq(tmpindex);
                    }else{
                        var cur_blockobj=ld(blockobjs).eq(tmpindex-1);
                    }
                }else if(targettop==0){//targettop等于零，则表示是当前区块
                    var cur_blockobj=ld(blockobjs).eq(tmpindex);
                }
                ld(cur_blockobj).addClass('selected');
                ld(cur_blockobj).find('a').css('color','#3B7CFF');
                return false;
            }
        })
    }

    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（新建）
    this.setDetailAttachmentEvent = function () {
        that.detailimage_arr = [];
        //edit: xll XUQIU1000357 单据分录定制，增加“附件”字段类型（新建界面）
        if (!empty(that.detailfields)) {//分录
            for (var i = 0; i < that.detailfields.length; i++) {
                if (that.detailfields[i].bigtype == "image") {//this.detailfields[i].uitype == '69'
                    that.detailimage_arr.push(that.detailfields[i]);
                }
                if (that.detailfields[i].bigtype == "fileattachment") {
                    that.detailimage_arr.push(that.detailfields[i]);
                }
            }

            var trobjs = this.getTrObjsByDelType('no');
            for (var j = 0; j < trobjs.length; j++) {
                var rowindex = ld(trobjs[j]).attr("rowindex");
                for (var i = 0; i < that.detailimage_arr.length; i++) {
                    // var fileuploader = ld("#"+this.divid+" tr[rowindex="+rowindex+"] [detailfieldname="+that.detailimage_arr[i].fieldname+"] div[name="+that.detailimage_arr[i].fieldname+"]");//分录可能有多行需要区分
                    var fileuploader = ld(trobjs[j]).find(" [detailfieldname=" + this.detailimage_arr[i].fieldname + "]").find(" div#" + this.detailimage_arr[i].fieldname );
                    if (fileuploader.length > 0) {
                        var uploadFile = new WebUploadFile();
                        globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                        uploadFile.setDetailEvent(globalWebUploadType, fileuploader, that, i, rowindex);
                    }
                }
            }
        }
    }
    that.beforeshowInitValue = function (data) {
        var Popupobj = that;
        Popupobj.picklistdepency = data.result.picklistDependencyDatasource;
        Popupobj.isshowpage = true;

        Popupobj.validatasave = data.result.validatasave;
        Popupobj.validatasaverule = data.result.validatasaverule;
        Popupobj.fieldname = data.result.fieldname;
        Popupobj.fieldlabel = data.result.fieldlabel;
        Popupobj.fielddatatype = data.result.datatype;
        Popupobj.fields = data.result.fields;
        Popupobj.allhtmlcontent = data.result.allcontent;
        Popupobj.isadmin = data.result.isadmin;
        Popupobj.is_page_setting = data.result.is_page_setting;
        Popupobj.filejsondata = data.result.filejsondata;
        Popupobj.detailfilejsondata = data.result.detailfilejsondata;
        Popupobj.helpdesk_log = data.result.helpdesk_log;
        Popupobj.detailfieldrulefieldnames = data.result.detailfieldrulefieldnames;//明细字段的布局规则
        Popupobj.fieldrulefieldnames = data.result.fieldrulefieldnames;//布局规则查询字段
        Popupobj.sensitiverelatedfield = data.result.sensitiverelatedfield;//敏感规则相关字段
        Popupobj.allproductimagefieldname = new Array();//产品分录的所有的产品属性图片字段
        if(data.result.fieldrulevalues)
            Popupobj.fieldrulevalues = data.result.fieldrulevalues;//布局规则隐藏的字段


        //布局规则
        Popupobj.fieldname_fields = [];
        for (var i = 0; i < Popupobj.fields.length; i++) {
            var fieldname = Popupobj.fields[i].fieldname;
            var columnname = Popupobj.fields[i].columnname;
            Popupobj.uitypes[fieldname] = Popupobj.fields[i].uitype;
            Popupobj.fieldname_fields[fieldname] = Popupobj.fields[i];
        }
        Popupobj.picklistcontent = data.result.picklistcontent;//下拉框
        Popupobj.picklistdepencyfields = data.result.picklistdepencyfields;
        if (Popupobj.filejsondata == "") {
            Popupobj.filejsondata = new Array();
        }
        if (Popupobj.detailfilejsondata == "") {
            Popupobj.detailfilejsondata = new Array();
        }
        if (data.result.frommodule != undefined) {
            //关联创建
            Popupobj.frommodule = data.result.frommodule;
            Popupobj.fromid = data.result.fromid;
        } else {
            Popupobj.frommodule = '';
            Popupobj.fromid = '0';
        }
        if (data.result.upgradefrommodule != undefined) {
            Popupobj.upgradefrommodule = data.result.upgradefrommodule;
            Popupobj.upgradefromid = data.result.upgradefromid;
            Popupobj.upgradestatus = data.result.upgradestatus;//wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        }
        //duan 2022-2-14 销售线索增加'升级到客户和销售机会选项'判断是否需要升级到销售机会
        if (data.result.upgradetomodule != undefined && data.result.upgradetomodule != '') {
            Popupobj.upgradetomodule = data.result.upgradetomodule;
            Popupobj.fromid = data.result.fromid;
        }
        Popupobj.detailfields = data.result.detailfields;

        Popupobj.detailfieldmodule = data.result.detailfieldmodule;
        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0) {
            Popupobj.detailtable_arr = [];
            Popupobj.detailtable_arr.push(data.result.detailtablename);
            Popupobj.detailtable_arr.push(data.result.detailtablenamescf);
            if(Popupobj.detailfieldmodule == 'Products'){
                Popupobj.detailtable_arr.push('ld_products');
                Popupobj.detailtable_arr.push('ld_productscf');
            }
        }
        
        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0 && Popupobj.detailfieldmodule == 'Products') {
            Popupobj.productfieldinfo = data.result.productfieldinfo;
            //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示（产品分录的所有的产品属性图片字段）
            for (var i = 0; i < Popupobj.detailfields.length; i++) {
                if (Popupobj.detailfields[i].uitype == 69 && (Popupobj.detailfields[i].tablename == "ld_products" || Popupobj.detailfields[i].tablename == "ld_productcf")) {
                    Popupobj.allproductimagefieldname.push(Popupobj.detailfields[i].fieldname);
                }
            }
            Popupobj.detailpicklist = data.result.detailpicklist;//明细下拉框字段的内容
            Popupobj.detailpicklistseq = data.result.detailpicklistseq;//明细下拉框字段的排序
            Popupobj.detailpicklistColors = data.result.global_picklist_colors_values;//明细下拉框字段的内容


        }
        //值
        Popupobj.columnfields_value = data.result.columnfields_value;

        Popupobj.quickcreatehtml = data.result.content;
        if (Popupobj.module == 'Accounts' || Popupobj.module == 'Contacts'
            || Popupobj.module == 'Documents' || Popupobj.module == 'HelpDesk')
            Popupobj.tablerelfields = data.result.tablerelfields;//相关信息创建

        Popupobj.moduleData = data.result;

        if (data.result.cur_groupinfo != undefined) {
            Popupobj.cur_groupinfo = data.result.cur_groupinfo;
        }
    }
    that.setInitValue = function (data, paramsobj) {
        var Popupobj = that;

        Popupobj.refreshpage = paramsobj.params['refreshpage'];
        Popupobj.relatedcreate = paramsobj.params['relatedcreate'];
        Popupobj.callcenter = paramsobj.params['callcenter'];
        if (paramsobj.params['createdtype'] == 'create' && data.result.isduplicate != undefined && paramsobj.params['isduplicate'] != 'yes') {
            paramsobj.params['isduplicate'] = data.result.isduplicate;
        }
        Popupobj.isduplicate = paramsobj.params['isduplicate'];
        Popupobj.createdtype = paramsobj.params['createdtype'];
        if (paramsobj.params['button'] != "" && paramsobj.params['button'] != undefined) {
            paramsobj.params['button'].disabled = false;
        }
        Popupobj.paramsobj = paramsobj;
        this.beforeshowInitValue(data);
        Popupobj.createScrollDiv();//创建滚动条
    }

    this.aftershowInitValue = function (data) {
          
        var Popupobj = that;
        var paramsobj = Popupobj.paramsobj;
        Popupobj.mainfieldformulaobj = new cls_mainfieldformula(data.result.mainfieldformula);
        Popupobj.mainfieldformulaobj.setPopupobj(Popupobj);
        Popupobj.mainfieldformulaobj.init();
        Popupobj.mainfieldformulaobj.CreatePageComputer();
        Popupobj.mainfieldformulaobj.setEvent();

        Popupobj.detail2mainformulaobj = new cls_detail2mainformula(data.result.mainfieldformula);
        Popupobj.detail2mainformulaobj.setPopupobj(Popupobj);
        Popupobj.detail2mainformulaobj.init();
        Popupobj.detail2mainformulaobj.setEvent();

        if (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0 && Popupobj.detailfieldmodule == 'Products') {
            Popupobj.noprofiledetailfields = data.result.noprofilefields;
            //setProductDivWidth.pageMode='create';
            setProductDivWidth(Popupobj);//设置列宽
            // Popupobj.detaildatavalue_arr = data.result.detaildatavalues;
            if (Popupobj.islocalstorage == 'no')
                Popupobj.detaildatavalue_arr = new Array();//zxm


            Popupobj.detailtablename = data.result.detailtablename;
            Popupobj.detailtablenamescf = data.result.detailtablenamescf;
            Popupobj.detailtableindex = data.result.detailtableindex;//明细表主键
            var oS = document.createElement('script');
            oS.src = global_js_url + "include/js/modules/Products/Products.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            Popupobj.selectproductobj = new fun_selectproduct(Popupobj.productfieldinfo);
            if(Popupobj.module=="WorkSheet"){
                Popupobj.selectproductobj.worksheettablecolumn_arr=data.result.headdetailcolumn
                Popupobj.selectproductobj.worksheet_sourcevalue_arr=data.result.worksheet_sourcevalue
            }
            Popupobj.selectproductobj.setPopupobj(Popupobj);
            //if (Popupobj.islocalstorage == 'no')
              //  Popupobj.detaildatavalue_arr.push(Popupobj.selectproductobj.getDetailDataValues());//zxm
            Popupobj.baseColumn = data.result.baseColumn;
            Popupobj.fieldformulaobj = new fieldFormula(Popupobj.productfieldinfo);
            //edit:can 2020-10-12 产品分录明细：系统参数“价格和金额计算时的基准字段”设置为“不含税单价”，录入“税率”应反算“含税单价”
            Popupobj.fieldformulaobj.setPopupobj(Popupobj)
            Popupobj.fieldformulaobj.baseColumn = data.result.baseColumn;
            Popupobj.pricestrategyobj = new PriceStrategy();
            Popupobj.productstrategyobj = data.result.productstrategyobj;
            Popupobj.havebatchtextcolumnname = 'no';
            //Popupobj.ordertype_onclick=data.result.ordertype_onclick;
            //分录字段布局规则
            Popupobj.detaildisplaycolumns = data.result.detailfieldruleinfo.displaycolumns;
            Popupobj.detailhidecolumns = data.result.detailfieldruleinfo.hidecolumns;
            Popupobj.fieldruleobj.resetDetailColumns();


            if (data.result.sourcemodule != null)
                Popupobj.sourcemodule_arr = data.result.sourcemodule;
            Popupobj.selectproductobj.fnAddProductTdBtn();
            Popupobj.selectproductobj.AfterchooseSourceHide();//选择源单后隐藏按钮（严格控制选择源单）
            //@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品、输入数量后自动带出价格
            Popupobj.relatedproducttoolfield = data.result.relatedproducttoolfield;
            Popupobj.sys_deploy = data.result.sys_deploy;

           

            


            for (var i = 0; i < Popupobj.productfieldinfo.fields.length; i++) {
                if (Popupobj.productfieldinfo.fields[i].columnname == 'batchtext') {
                    Popupobj.havebatchtextcolumnname = 'yes';

                    break;
                }
            }
            //js 代码加载完成 ， 分录开始计算
            oS.onload = oS.onreadystatechange = function () {
                
                var ishavedefaultvalue='no'
               
                 var rowobjs = Popupobj.getTrObjsByDelType("no");
            
                //复制分录有两行以上单据有问题，关联创建也是 //zkt 20230525 BUG0066983 从报价单下推报价变更单，提示无更换前产品名称，单页面上更换前产品名称存在。 
                if(!empty(data.result.detaildatavalues)&&data.result.detaildatavalues.length>0&&(data.result.detaildatavalues[0].productid>0||data.result.detaildatavalues[0].pro_id>0)){
                    Popupobj.detaildatavalue_arr=data.result.detaildatavalues;
                }else{
                 
                    if(!empty(data.result.detaildatavalues)&&data.result.detaildatavalues.length>1)
                    {
                        //edit:can 20230322 系统参数 默认增加行 63668 退货通知单，点击新增，选择源单后什么都没有带过来，合同订单选择产品也是的带不出来 
                        Popupobj.detaildatavalue_arr=data.result.detaildatavalues;
                    }
                    else 
                    {
                             
                               
                                for (var i = 0; i < Popupobj.detailfields.length; i++) {
                                        
                                        if (Popupobj.detailfields[i].columnname == 'productname' && Popupobj.detailfields[i].defaultvalue > 0) {
                         
                                                ishavedefaultvalue='yes';
                                            ld.each(rowobjs, function () {
                        
                                                //默认新增多行，所有循环
                                               
                                                 
                                                if(ld(this).attr("rowindex")>Popupobj.detaildatavalue_arr.length)
                                                    Popupobj.detaildatavalue_arr.push(Popupobj.selectproductobj.getDetailDataValues());//zxm
                                              
                                                fun_selectproduct.setProductDefaultValue(ld(this).attr("rowindex"), Popupobj.detailfields[i].defaultvalue);
                        
                                            })
                        
                        
                                            break;
                                        }
                            }  
                        if(ishavedefaultvalue!='yes')
                            Popupobj.detaildatavalue_arr.push(Popupobj.selectproductobj.getDetailDataValues());//zxm 
                    }
                   
                }
               
              
                UpDownPointFocus(Popupobj);
                 
                //DisCountFocusShowMess(Popupobj);
                if (Popupobj.module == 'Quotes' && account_version == 'haige') //0045000
                {
                    getJsScript('include/js/modules/Quotes.js', function () {
                        HaigeControlTrElement();
                    });
                }
                 
                var rowobjs = Popupobj.getTrObjsByDelType('no');
                ld.each(rowobjs, function () {
                    if (Popupobj.module == 'Quotes' && account_version == 'haige') return false;
                    Popupobj.RelatedProductToolFieldtriggcols = [];
                    getRelatedProductToolFieldPriceCallBack(Popupobj, ld(this).attr("rowindex"));
                    //后台sql事件
                       
                    getRelatedProductToolFieldPrice(Popupobj, ld(this).attr("rowindex"));
                    that.selectproductobj.setDataBind(ld(this));
                })
                
                //调用计算公式，分录加载后需要先计算
                if (data.result.from_module == 'Products') {
                    //产品关联创建报价单，函数单价公式设置未其他，可能导致，选择产品界面和关联创建界面不同
                    //zkt 20230602 BUG0066930 产品在报价单中选择产品无法将”产品报价“字段传入”含税单价“中，在产品相关信息中下推也无法显示
                    Popupobj.fieldformulaobj.CountFormulaColumn();
                    //BUG20240726-40 ls 240730 	从产品下推订单时，设置的定价策略不生效
                    if (Popupobj.pricestrategyobj.modulehaveprice(Popupobj.module) == 'yes' ) {
                        Popupobj.pricestrategyobj.startcomputer(1);//从产品模块下推
                    }

                } else {
                    var autobalancecolumnname;
                    if (data.result.from_module != '' && data.result.from_module != null) {
                        ld.each(Popupobj.sourcemodule_arr, function (tmpindex, tmpinfo) {
                            if (tmpinfo['entitytype'] == data.result.from_module) {
                                autobalancecolumnname = tmpinfo['autobalancevalue'];
                                return false;
                            }
                        })
                    } else if (paramsobj.params.isduplicate == 'yes') {
                        if (ld("#" + Popupobj.divid + ' [name=selectlistval]').length > 0 && ld("#" + Popupobj.divid + ' [name=selectlistval]').val() > 0) {
                                ld.each(Popupobj.sourcemodule_arr, function (tmpindex, tmpinfo) {
                                if (tmpinfo['entitytype'] == ld("#" + Popupobj.divid + " [name=selectsource]").val()) {
                                    autobalancecolumnname = tmpinfo['autobalancevalue'];
                                    return false;
                                }
                            })
                        }
                    }
                    var samesourcevalue_arr=[];//原单关联创建哪些字段不需要调用字段公式
                    if (Popupobj.islocalstorage == 'no') {
                        if(Popupobj.sourcemodule_arr!=undefined&&data.result.from_module!=undefined)
                        {
                            ld.each(Popupobj.sourcemodule_arr,function(tmpindex,tmpinfo){
                                
                                if(tmpinfo.entitytype==data.result.from_module)
                                {
                                    if(tmpinfo.samesourcevalue!=''&&tmpinfo.samesourcevalue!=undefined)
                                     {
                                        samesourcevalue_arr=JSON.parse(tmpinfo.samesourcevalue);
                                        
                                     }
                                     return false;
                                }
                            })
                        }
                       
                        if(samesourcevalue_arr!=undefined&&samesourcevalue_arr.sametype=='all')
                        {
                            
                        }
                        else{
                            
                            
                            if (autobalancecolumnname != '' && autobalancecolumnname != null) {
                                Popupobj.fieldformulaobj.changeAllDatabyColumnname(autobalancecolumnname);
                            } else {
                                Popupobj.fieldformulaobj.CountFormulaColumn();
                            }
                        }
                        
                    } else {
                        //zxm 暂存加载分录数据之后 设置分录事件 20220110
                        Popupobj.fieldformulaobj.setAllRowEvent();
                    }
                    if (Popupobj.pricestrategyobj.modulehaveprice(Popupobj.module) == 'yes' ) {
                        ld.each(rowobjs, function () {
                            Popupobj.pricestrategyobj.startcomputer(ld(this).attr("rowindex"));//从其他模块下推
                        })
                    }

                }
                //zkt 20221106 BUG0058789客户->详情->相关信息的合同订单->创建合同订单->打开该合同的详情->点击该合同相关信息的收款单->创建收款单   实际收款金额是0
                if(Popupobj.fieldformulaobj != undefined){
                    Popupobj.fieldformulaobj.CountsubTotal();
                }
                //zkt 20230112 BUG0060022销售商机下推销售报价单----报价单上的‘未税总价’字段引用分录的未税总价，没有取到数值
                if(Popupobj.detail2mainformulaobj != undefined){
                    Popupobj.detail2mainformulaobj.changeRowEvent();
                }
            }
          
        }
        else if (Popupobj.hasOwnProperty('detailfieldmodule') && Popupobj.detailfieldmodule !== undefined && Popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
            // setProductDivWidth.pageMode='create';
            setProductDivWidth(Popupobj);//设置列宽
            //zkt 20210930 0047602: https://81mis.com/kfbcrm [^]，请假单-进入后如图显示 布局规则，设置分录表头的显示和隐藏

            Popupobj.detailtablename = data.result.detailtablename;
            Popupobj.detailtablenamescf = data.result.detailtablenamescf;
            Popupobj.detailtableindex = data.result.detailtableindex;//明细表主键
            //字段布局规则
            Popupobj.detaildisplaycolumns = data.result.detailfieldruleinfo.displaycolumns;
            Popupobj.detailhidecolumns = data.result.detailfieldruleinfo.hidecolumns;
            Popupobj.fieldruleobj.resetDetailColumns();

            if (data.result.sourcemodule != null)
                Popupobj.sourcemodule_arr = data.result.sourcemodule;
            var oS = document.createElement('script');
            oS.src = global_js_url + "include/js/producttool/TabDetailFieldFormula.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            oS.onload = oS.onreadystatechange = function () {
                Popupobj.fieldformulaobj = new tabDetailFieldFormula(data.result.product_fields_info);
                Popupobj.fieldformulaobj.setPopupobj(Popupobj)
                fnAddProductTdBtn();
                if (Popupobj.fieldformulaobj.baseColumn != '')
                    Popupobj.fieldformulaobj.cur_input_focus_obj = ld('#' + Popupobj.divid + ' [name="' + Popupobj.fieldformulaobj.baseColumn + '1"]').get(0);
                Popupobj.fieldformulaobj.setAllRowEvent();//设置字段公式
                ld("#"+Popupobj.divid+" .E_morefields ").css('display','none');
                //zkt 20221124 BUG0059119【苏州灵当】V8.4.7.9（https://kh.xiaoshou360.com/suzhould/）档案管理，客户档案：湖北金合软件有限公司，相关创建正式账套，点击保存无反应
                if(Popupobj.fieldformulaobj != undefined){
                    Popupobj.fieldformulaobj.CountFormulaColumn();//BUG20240606-36 ls 240612 销售订单下推创建收款单，自定义字段的字段公式计算未生效。在收款单模块手动选择正常
                    Popupobj.fieldformulaobj.CountsubTotal();
                }
                if(Popupobj.detail2mainformulaobj != undefined){
                    Popupobj.detail2mainformulaobj.changeRowEvent();
                }

            };
            Popupobj.selectproductobj = new fun_selectproduct(Popupobj.productfieldinfo);

        }
        //XUQIU1000651	zxm 20220909
        // 系统设置->单据分录定制，增加“设置冻结前几列”参数
        setTimeout(function(Popupobj){
            getJsScript('include/js/freezeEntriesColumns.js', function () {
                var freezeEntriesColumnsobj = new FreezeEntriesColumns(Popupobj,'proTab');
                freezeEntriesColumnsobj.freezeTheadAndBody();
            });



            // getJsScript('include/js/freezecolumns.js', function () {
            //
            //      //alert(ld(popupobj.getDetailTableObj()).find('tr[tag=trhead]').find('.set-sticky').length);
            //      popupobj.freezecolumnsObj= freezecolumnsObj;
            //     popupobj.freezecolumnsObj.stickthindex=ld(popupobj.getDetailTableObj()).find('tr[tag=trhead]').find('.set-sticky').attr("thindex");
            //
            //     if(popupobj.stickthindex!=undefined&&popupobj.stickthindex>0)
            //      {
            //
            //
            //         freezecolumnsObj.init('proTab');//冻结列类初始化
            //         freezecolumnsObj.freezeThColumn('set-sticky');
            //      }
            // });

            //加载tip 20230525 diony
            // tooltip(ld("#"+Popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
        },1000,Popupobj);

    }
    this.SortDetailTableRow = function () {
        if (that.detailfieldmodule == '' || that.detailfieldmodule == undefined)
            return false;
        var tableobj = this.getDetailTableObj();
        var tbody = ld(tableobj).find("tbody").get(0);
        if(tbody instanceof HTMLElement) {
            Sortable.create(tbody, {
                //	animation: 500,
                handle: '.drag-handle',
                draggable: ".dragtrrow",  //  // 允许拖拽的项目类名,否则会拖拽到小计行
                onEnd: function (evt) {	//移动行
                    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录拖动
                    var tmpfromrowindex = evt.oldIndex - 1;//因为table默认空tr及header的tr,因此rowindex=trindex-1
                    var tmptorowindex = evt.newIndex - 1;

                    Detaildatachange_byrowindexoperation(that, 'before', 'exchange', tmpfromrowindex, tmptorowindex);

                    if (that.detailfieldmodule == 'Products') {
                        that.selectproductobj.fnAddProductTdBtn();
                        var trobjs = ld(tableobj).find("tr[detaildeleted=no]");
                        var startrowindex = 1;
                        if (parseInt(evt.oldIndex) < parseInt(evt.newIndex)) {
                            var start = parseInt(evt.oldIndex) - 1;
                            var end = parseInt(evt.newIndex);
                        } else {
                            var start = parseInt(evt.newIndex) - 1;
                            var end = parseInt(evt.oldIndex);
                        }

                        //交换行数组内容交换
                        var arr_temp = [].concat(that.detaildatavalue_arr);  //创建一个新的临时数组，用以操作后不变更原数组
                        arr_temp.splice(tmptorowindex - 1, 0, arr_temp.splice(tmpfromrowindex - 1, 1)[0]);  //在b位置插入从a位置截取的元素

                        ld.each(trobjs, function () {
                            ld(this).attr("rowindex", startrowindex);
                            ld(this).attr("row", startrowindex);
                            var tmprowindex = parseInt(ld(this).attr("rowindex"));
                            if (tmprowindex >= start && tmprowindex <= end) {
                                var tmparr = {};
                                ld.each(arr_temp[startrowindex - 1], function (tmpcolumnname, value) {
                                    tmparr[tmpcolumnname] = value;
                                })
                                that.detaildatavalue_arr[startrowindex - 1] = tmparr;
                                //BUG20240118-36 ls 240129 北京盈电：开票申请单下推实际开票申请单，调整产品分录的顺序（第一条和后面的调整顺序），编辑调整后的第一条分录数量，公式不计算。
                                that.detaildatavalue_arr[startrowindex - 1].databind = 'no';

                                that.selectproductobj.onmouseevent(ld(this));
                            }
                            startrowindex++;
                        })

                    } else {
                        fnAddProductTdBtn();
                        that.fieldformulaobj.setAllRowEvent();
                    }

                    ld(tableobj).find("tr[rowindex=1]").find('[tag="btn_del"]').remove;//删除第一行的删除按钮
                    Detaildatachange_byrowindexoperation(that, 'after', 'exchange', tmpfromrowindex, tmptorowindex);
                }
            });
        }
    }

    //liushuai 202305225 XUQIU1001464 【广东丰明】请款单、调账申请单、内部调整单、价差调整单开发需求（文本数字类的小写金额带出大写金额）
    //非选择弹窗的关联带出,多为特殊开发(可扩展为，文本数字字段存在某一属性时触发)，别忘了编辑页哦
    this.setRelatedFieldEvent = function () {
        ld.each(that.fields, function (tmpindex, fieldinfo) {
            var tmpfieldname = fieldinfo.fieldname;

            if (account_version == 'fengming' &&
                ((that.module == 'CustomForm04' && tmpfieldname == 'cf_5591') || (that.module == 'CustomForm16' && tmpfieldname == 'cf_5619') ||
                (that.module == 'CustomForm17' && tmpfieldname == 'cf_5858') || (that.module == 'CustomForm18' && tmpfieldname == 'cf_5865'))
            ) {
                ld('#' + that.divid + " [name='" + tmpfieldname + "']").on('input', function() {
                    // 在这里编写输入内容变化时的处理逻辑
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(that.module, 1, '', tmpfieldname, that.module, 'special_noselect');//special_noselect 对应的是fieldname
                    });
                });
            }
        })


        // 240129 帮路总给客户做的临时需求，下拉框字段可以关联带出（不具有通用性，需优化）
        /*ld.each(that.picklistcontent, function (tmpindex, fieldinfo) {
            var tmpfieldname = fieldinfo.fieldname;
            ld("#" + that.divid + ' [name=dv_cmb_' + tmpfieldname + "]").unbind('click').on('click', function() {
                getJsScript('include/js/relatedfield.js', function () {
                    getRelatedFieldData(that.module, 1, '', tmpfieldname, that.module, 'select');
                });
            });
        })*/
    }
    //wym 231204 XUQIU1002278 新增编辑页全屏,重写setScrollDivMaxHeight事件
    //wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
    this.setScrollDivMaxHeight = function () {
        var fullscreen=this.getFullscreen();
        if(fullscreen=='no'){//缩小
            var maxheight = that.getMaxHeight();
            ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
            ld("#" + this.divid + " .dvpopupsroll").css("height", 'auto');
        }else{//全屏
            var maxheight = CrmPopup.getClientHeight();
            if(ld("#" + this.divid + '_head').length>0){
                maxheight -= ld("#" + this.divid + '_head').outerHeight();
            }
            if(ld("#" + this.divid + '_popupbottom').length>0){
                maxheight -= ld("#" + this.divid + '_popupbottom').outerHeight();
            }
            ld("#" + this.divid + " .dvpopupsroll").css("height", maxheight);
            ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
        }
    }

    this.getBigpopupwidth = function (){
        return parseInt(CrmPopup.getClientWidth());
    }

    this.getSmallpopupwidth = function (){//全屏与缩小界面切换比例
        return parseInt(CrmPopup.getClientWidth()*0.8);
    }

    this.Fullscreencallback = function (switchtotype){
        if(switchtotype=="fullscreen"){
            this.fullscreen='yes';
        }else{
            this.fullscreen='no';
        }
        this.setScrollDivMaxHeight();
        //zkt 20240328 3、BUG20240328-21  	kfbcrm-销售订单-下推出库单1.先点击在当前页签新建出库单，右上角点击缩小界面，关闭新建界面2.再点击打开新页签新建出库单，这时候的界面大小是记住上次的选择 是缩小的，点击右上角放大界面，分录不会跟着变化
        if(/*that.detailfields != undefined && that.detailfields.length > 0 && */that.detailfieldmodule != undefined){//BUG20240812-43 ls 240813 分录模块不启用分录字段时，也需要计算一下
            setProductDivWidth(that);
        }
        that.center();
    }

    this.getFullscreen = function () {
        if(empty(that.fullscreen)){
            var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
            ldAjaxNoProgresssync(urlstring,'',function(data) {
                if(data.code==1){
                    if(data.result.content != ''){
                        that.fullscreen=data.result.content;
                    } else{
                        that.fullscreen = 'yes';
                    }
                }
            });
        }
        var fullscreen = that.fullscreen;
        return fullscreen;
    }
    //wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
    this.getWidth = function () {
        var fullscreen = that.getFullscreen();
        if(fullscreen == 'no'){
            return parseInt(CrmPopup.getClientWidth()*0.8);
        }else{
            return parseInt(CrmPopup.getClientWidth());
        }
    }

    //特殊开发的一些页面动作监听事件
    this.setSpecialEvent = function () {
        if (account_version == 'baxter' && ld.inArray(that.module,['CustomForm72','CustomForm74'])>=0) {
            getJsScript('include/js/Baxter.js', function () {
                var baxterobj = new Baxter(that);
                that.baxterobj = baxterobj;
                baxterobj.setEvent();
            })

        }
    }
    //duan 20240925 绑定公共字段事件
    this.setCommonFieldEvent = function () {
        var common_field_event_obj = new cls_common_field_event(this);
        this.common_field_event_obj = common_field_event_obj;
        this.common_field_event_obj.setEvent();
        this.common_field_event_obj.setAllEntryEvent();
    }
}

CreatePagePopup.type = 'createpage';
CreatePagePopup.pagetype = "create_edit_modulepage";//
//CreatePagePopup.params={"refreshpage":"yes","relatedcreate":"no","isDuplicate":"no","button":"","createdtype":"create"};
CreatePagePopup.params = function () {

    this.params = {
        "refreshpage": "yes",
        "relatedcreate": "no",
        "isduplicate": "no",
        "button": "",
        "createdtype": "create",
        'callcenter': 'no'
    };


}
CreatePagePopup.load = function (headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText) {
    picklist = false;
    CreatePagePopup.prototype = new CrmPopup();
    CreatePagePopup.prototype.constructor = CreatePagePopup;

    CreatePagePopup.prototype.refreshpage = 'yes';

    CreatePagePopup.prototype.type = CreatePagePopup.type;
    CreatePagePopup.prototype.fieldname = "";
    CreatePagePopup.prototype.fieldlabel = "";
    CreatePagePopup.prototype.fielddatatype = "";
    CreatePagePopup.prototype.fields = "";
    CreatePagePopup.prototype.picklistdepency = [];
    CreatePagePopup.prototype.quickcreatehtml = "";
    CreatePagePopup.prototype.allhtmlcontent = "";//所有字段html
    //CreatePagePopup.prototype.filejsondata=[];//附件
    CreatePagePopup.prototype.isadmin = "";//是否管理员
    CreatePagePopup.prototype.columnfields_value = "";//获取$focus->column_fields的值
    CreatePagePopup.prototype.isduplicate = "no";
    CreatePagePopup.prototype.tablerelfields = "";
    CreatePagePopup.prototype.createdtype = "create";	//判断区分是否是快速快创建，还是模块列表创建    quickcreate快速创建
    CreatePagePopup.prototype.record = 0;
    var Popupobj = new CreatePagePopup();
    Popupobj.pagetype = CreatePagePopup.pagetype;

    if(cssWidth != CrmPopup.getClientWidth()){
        Popupobj.fullscreen = 'no';
    }
    Popupobj.setParams(headtitle, SaveDataRecord.save, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText);

    Popupobj.showafter = function () {

        //界面显示后，加载相关ajax
    }

    return Popupobj;

}

CreatePagePopup.pagechange = function () {
    var popupobj = CrmPopup.getPopupObj("last");
    popupobj.clickchangepage = 'yes';

    popupobj.changepage();
    popupobj.showafter();
    popupobj.getStagingEvent(popupobj.createpagedata);//liushuai 20230605 BUG0066925 kfbcrm新建界面，点击“展开更多栏目”，点击“获取暂存信息”没有反应(获取暂存信息事件)
    popupobj.changeapproveEvent();//edit:duan reason:点击收起或展开后，审批按钮绑定事件丢失
    //zkt 20220930 BUG0057280FORECAST预计订单表：新建单据时，不显示客户名称，只有点开展开更多栏目才显示客户名称字段，如果展开更多栏目后，系统设置计算规则不生效。
    if (!empty(popupobj.mainfieldformulaobj)) {
        popupobj.mainfieldformulaobj.setEvent();
    }
}
CreatePagePopup.getWidth = function () {
    var fullscreen = '';
    var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
    ldAjaxNoProgresssync(urlstring,'',function(data) {
        if(data.code==1){
            if(data.result.content != ''){
                fullscreen=data.result.content;
            }
            else{
                fullscreen = 'yes';
            }
        }
    });
    if(fullscreen == 'no'){
        return parseInt(CrmPopup.getClientWidth()*0.8);
    }else{
        return parseInt(CrmPopup.getClientWidth());
    }
}
CreatePagePopup.showpage = function (module, lasturl, paramsobj) {
    //zxm  2021-0609 预算单  没有数据的列表页中间的创建按钮  无法传输参数【预算类型】
    if (module == 'ExpenseBudget' && lasturl == '') {
        var setype = 'basicBudget';
        lasturl = "&budgetType=" + setype;
        //创建预算单
        paramsobj.params['budgetType'] = setype;
    }
    //zxm  2021-0803 获客文章
    if (module == 'Articles' && lasturl == '') {
        var setype = 'textArticles';
        lasturl = "&articlesType=" + setype;
        //创建获客文章
        paramsobj.params['articlesType'] = setype;
    }
    var url = 'index.php?module=' + module + '&action=' + module + 'Ajax&file=EditView&return_action=DetailView&Create=true' + lasturl;

// @edit:liushuai,2021-03-19,reason:【ID1001377】链接模块，弹出层标签修改
    //zkt 添加判断，链接模块的新增、复制操作,防止相关信息的新增、复制冲突
    var popupobj = CrmPopup.getPopupObj('last');
    if (typeof linkmodulecustom != "undefined" && popupobj != undefined && popupobj != 'undefined' && popupobj.type != undefined && popupobj.type != 'undefined' && popupobj.type != 'relatelistpage' && paramsobj.params['relatedcreate'] == 'no') {
        var page_title = ld(" .detail_path li").html();
        url += '&is_linkmodulecustom=' + linkmodulecustom ;
        //BUG0065253 在链接模块 快速创建别的单据，出现的新建界面名称是连接模块的名称  
        if(module == popupobj.module){
            url += '&page_title=' + encodeURIComponent(page_title);
        }
        //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
        //获取链接模块viewname
        var page_addurl = getSearchString('page_addurl', location.href);
        if (page_addurl != undefined) {
            var linkmodule_viewname = getSearchString('viewname', page_addurl);
            if (linkmodule_viewname != undefined) {
                url += '&linkmodule_viewname=' + linkmodule_viewname;
            }
        }
    }

    //editor:zkt 20220613  1000204点击左侧树结构“分类名称”，新建时，自动带出字段选项值(工作汇报右上角新建日历popupobj为空)
    if (popupobj && popupobj.type == 'listpage' && ld("#isshowModuleListTree") != undefined && ld("#isshowModuleListTree").val() == 'yes') {
        url += '&CreateHaveModuleListTree=yes';
    }

    var tmpwidth = CreatePagePopup.getWidth();


    var Popupobj = CreatePagePopup.load("", "", "", tmpwidth, module, "", "", "", "");
    Popupobj.prevshow();
    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    if(module == 'Users' && popupobj.pagetype == 'listpage' && popupobj.user_type){
        url += '&user_type='+popupobj.user_type;
        Popupobj.user_type = popupobj.user_type;
    }
    var PopupJqObj = ld('#'+Popupobj.divid);
    Popupobj.lasturl = lasturl;
    if (linkmodule_viewname != 'undefied' && !empty(linkmodule_viewname)) {
        Popupobj.linkmoduleviewname = linkmodule_viewname;
    }
    // diony 2023-12-15 XUQIU1002381 新增、编辑、明细界面做Skeleton 骨架屏
    AjaxJSPage('ld_Skeleton','include/js/component/ld_Skeleton.js');
    PopupJqObj.find('div[name=prevshowdv]').remove();
    ld_Skeleton.showSkeletonPop(Popupobj, CrmPopup.getClientHeight()-128);
    Popupobj.center();
    // return;

    // Safari浏览器增加一个样式
    if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Mac') != -1 && navigator.userAgent.indexOf('Chrome') == -1) {
        // console.log('Safari on Mac detected, applying class...');
        PopupJqObj.addClass('ld-safari-mac'); // provide a class for the safari-mac specific css to filter with
    }
    
    ldAjax(url,{"namename": "uname", "namenameage": 18},function(data){
        if (data.code == "-1") {

            Popupobj.CancelEvent();
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
            return false;
        }
        if (data.code == 1) {
            //zxm 20230714 加載按鈕不是這個了
            // $("status").style.display = "none";
            cur_PageInfo.pagetype.push('poplayerdetailview');
            cur_PageInfo.modulenames.push(module);
            cur_PageInfo.pagemode.push('poplayer');

            //BUG20240829-42 建议：如果模块名称是“***管理”，新增、编辑、复制单据的时候，标题显示新增、编辑、复制****即可，把管理2个字去掉（邱：只修改中文版，最后两个字是【管理】）
            if (data.result.title.trim().slice(-2) == '管理'){
                data.result.title = data.result.title.trim().slice(0,-2);
            }
            //设置title
            if (paramsobj.params.isduplicate != undefined && paramsobj.params.isduplicate == 'yes'){
                data.result.title = arrJsPopLabel['TitleCopy']+data.result.title;
            }else {
                data.result.title = arrJsPopLabel['TitleCreate']+data.result.title;
            }
            Popupobj.createHeadHtml(data.result.title);
            if (module == 'SocialPromotion') {
                // @edit:dong @date:2020/7/10 @reason:  增加弹出层按钮上一步
                Popupobj.createBottomHtml = function () {
                    Popupobj.popupbottomhtml = socialCreateBtnHtml(Popupobj, data);
                }

                //社交推广 新建步骤为一步一步
                Popupobj.setParams(data.result.title, socialCreateNextStep, "", tmpwidth, module, "", data.result.oktext, "", data.result.canceltext);

            } else if (module == 'Questionnaire') {
                //问卷调查   ID1001572
                Popupobj.createBottomHtml = function () {
                    Popupobj.popupbottomhtml = Questionnaire.prototype.questionnaireCreateBtnHtml(Popupobj, data);
                }
                var parentdivmaxheight = Popupobj.setScrollDivMaxHeight;
                Popupobj.setScrollDivMaxHeight = function () {
                    //edit:can 20210519 0045915: 调查问卷，新增界面弹出层，没有居中
                    parentdivmaxheight.apply(this, []);
                    var maxheight = this.getMaxHeight() - 10;

                    ld("#" + this.divid + " [name=displayfields]").css("height", maxheight);
                }

                Popupobj.setParams(data.result.title, Questionnaire, "", tmpwidth, module, "", data.result.oktext, "", data.result.canceltext);
            }
            //海格报价单保存事件改为savehaigequote
            else if (account_version == 'haige' && module == 'Quotes') {
                Popupobj.SaveSubmit = function () {
                    //保存提交
                    var submitapprove_text = PopupJqObj.find("[id=submit_description]").val();//提交意见是否为空
                    var submitlabelobj = PopupJqObj.find("[name=submitremarkrequire]");//提交意见是否必填
                    if (ld.trim(submitapprove_text) == "" && ld(submitlabelobj).css("display") == "inline") {
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SUBMITREMARKREQUIRE']);
                        return false;
                    }
                    this.issavesubmit = 'yes';
                    getJsScript('include/js/DetailButtons.js', function () {
                    });
                    getJsScript('include/js/modules/Quotes/Quotes.js', function () {
                        savehaigequote();
                    });

                }

                Popupobj.setParams(data.result.title, savehaigequote, SaveDataRecord.cancel, tmpwidth, module, "", data.result.oktext, "", data.result.canceltext);

            } else {
                Popupobj.setParams(data.result.title, SaveDataRecord.save, SaveDataRecord.cancel, tmpwidth, module, "", data.result.oktext, "", data.result.canceltext);
            }
            Popupobj.sourcemodule_arr = [];
            Popupobj.createpagedata = data;
            Popupobj.setInitValue(data, paramsobj);//赋值
            Popupobj.cashbilltype = paramsobj.params.cashbilltype;
            
            if (module == 'CashBill') {
                //显示预收款信息
                if (data.result.cashbilltype != undefined) {
                    //收款单的收款类型
                    Popupobj.cashbilltype = data.result.cashbilltype;
                }
                if (data.result.columnfields_value['account_id'] != undefined)
                    var accountid = data.result.columnfields_value['account_id'];
                else
                    var accountid = 0;
                if (data.result.columnfields_value['bankaccountsetid'] != undefined)
                    var bankaccountsetid = data.result.columnfields_value['bankaccountsetid'];
                else
                    bankaccountsetid = 0;
                //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
                if (data.result.columnfields_value['currency_id'] != undefined)
                    var currency_id = data.result.columnfields_value['currency_id'];
                else
                    currency_id = 0;

                if (Popupobj.cashbilltype != undefined)
                    var cashtype = Popupobj.cashbilltype;
                else
                    var cashtype = '';

                if (accountid > 0) {
                    var relatelistobj = getChooseRelateLists.getInstance(Popupobj);
                    relatelistobj.setCurrencyId(currency_id);
                    relatelistobj.getChooseAccountRelateList(bankaccountsetid, accountid, cashtype);

                }
            }


            /*if(Popupobj.detailfields!=undefined&&Popupobj.detailfields.length>0&&Popupobj.detailfieldmodule=='Products')
            {
                Popupobj.detailpicklist=data.result.detailpicklist;//明细下拉框字段的内容
                 Popupobj.detailpicklistColors=data.result.global_picklist_colors_values;//明细下拉框字段的内容
            }*/
            Popupobj.savesubmittext = data.result.savesubmittext;
            Popupobj.approve_arr = data.result.approve_arr;
            if (data.result.approve_fieldname_arr != undefined){
                Popupobj.approve_fieldname_arr = data.result.approve_fieldname_arr;
            }
            if (data.result.module_setting != undefined){
                Popupobj.module_setting = data.result.module_setting;
            }else{
                Popupobj.module_setting = {};
            }


            if (Popupobj.isduplicate == 'yes' || (Popupobj.fieldrulefieldnames != null && Popupobj.fieldrulefieldnames != "") || (Popupobj.detailfields != undefined && Popupobj.detailfields.length > 0)) {
                Popupobj.showquickcreate = 'no';

                Popupobj.show(data.result.allcontent);
            } else
                Popupobj.show(data.result.content);

            if(data.result.calendar_picklistdata_json !=undefined){
                Popupobj.calendar_picklistdata_json = data.result.calendar_picklistdata_json;
            }
            //ls 20221216  XUQIU1000403   单据新建界面增加暂存功能（新建页面增加浏览器定时缓存）
            if (isAvailablelocalStorage && module != 'SocialPromotion' && module != 'Questionnaire' && module != 'Articles') {
                var newStorageKey = getCurrentUrlSite(false) + '_' + module + '_create_' + CURRENT_USER_ID + '_new';
                var tmpStorageKey = getCurrentUrlSite(false) + '_' + module + '_create_' + CURRENT_USER_ID + '_tmp';//临时缓存，防止客户关闭浏览器或者强制刷新
                //绑定关闭事件
                PopupJqObj.find('.E_pop_tit .ld-fonticon-close').unbind('click').on('click', function () {
                    // console.log('右上角关闭事件');
                    SaveDataRecord.cancel();
                    return false;
                });
                    //XUQIU1001933 xxy 2023-10-10 页面暂存功能问题，如果缓存的信息过多，会导致写入缓存的时候报错，进而导致新建弹出层无法关闭
                if(localStorage.getItem('tmpStorageKey_arr') == null || empty(localStorage.getItem('tmpStorageKey_arr'))){//将缓存的键值按顺序存在数组内，数组也存在缓存中
                    localStorage.setItem('tmpStorageKey_arr','');
                    var tmpStorage_arr = [];
                }else{
                    var tmpStorage_arr = localStorage.getItem('tmpStorageKey_arr');
                    tmpStorage_arr = tmpStorage_arr.split(',');
                }
                //每隔指定秒后缓存当前的编辑页面
                create_storage_timer = setInterval(function () {
                    for (var i = 0;i < localStorage.length; i++) {
                        var key = localStorage.key(i);

                        if (!tmpStorage_arr.includes(key)) {
                            tmpStorage_arr.push(key);
                        }
                    }

                    // console.log('开始缓存当前页面');
                    var tmpInnerHtml = PopupJqObj.find('form[name="EditView"]').formhtml();
                    // localStorage.setItem(tmpStorageKey, tmpInnerHtml);
                    try {
                        localStorage.setItem(newStorageKey, tmpInnerHtml);
                        //分录的值数组 zxm
                        // localStorage.setItem(tmpStorageKey + '_productdetail', JSON.stringify(Popupobj.detaildatavalue_arr));
                        if (Popupobj.detaildatavalue_arr !== undefined && Popupobj.detaildatavalue_arr.length > 0) //去除undefined
                            localStorage.setItem(newStorageKey + '_productdetail', JSON.stringify(Popupobj.detaildatavalue_arr));
                        if (!tmpStorage_arr.includes(key)) {
                            tmpStorage_arr.push(newStorageKey);
                            tmpStorage_arr.push(newStorageKey + '_productdetail');
                        }
                        localStorage.setItem('tmpStorageKey_arr',tmpStorage_arr);
                    } catch (e) {
                        if (e.name === 'QuotaExceededError') {
                            removeOldStorage(Popupobj);
                        }
                    }

                }, localStorageTime * 1000);

            }
            Popupobj.getStagingEvent(data);//获取暂存信息事件
            Popupobj.changeapproveEvent();//审批流程改变事件

            if (data.result.approve_arr != undefined && data.result.approve_arr.length > 0) {
                Popupobj.ChangeApprove();
            }
            if (Popupobj.cashbilltype == 'cashbill' && relatelistobj != undefined) {
                relatelistobj.showDebuctionList();//收款单创建或复制界面
            }
            if (data.result.approve_fieldname_arr != undefined) {
                getJsScript('include/js/modules/Approve/cls_approvestep_change.js', function () {
                    Popupobj.approvestep_changeobj = new cls_approvestep_change(Popupobj,data.result.approve_fieldname_arr);
                });
            }

                
            Popupobj.aftershowInitValue(data);
            if (Popupobj.fieldrulefieldnames != null && Popupobj.fieldrulefieldnames != "")//如果有布局规则，则隐藏展开和收缩
                PopupJqObj.find(".E_morefields ").css('display', 'none');


            //快速创建字段和全部一样
            if (data.result.showexpand != undefined && data.result.showexpand == 'no') {
                PopupJqObj.find(".E_morefields ").css('display', 'none');
            }
            if (Popupobj.module == 'Accounts') {
                if (data.result.systemcodenumprefixtype == 1) {
                    //省份
                    var billstate = PopupJqObj.find('[name=bill_state]').val();
                    setCodeNumPrefix('bill_state', billstate, 'actions');
                } else if (data.result.systemcodenumprefixtype == 2) {
                    //城市
                    var billcity = PopupJqObj.find('[name=bill_city]').val();
                    setCodeNumPrefix('bill_city', billcity, 'actions');
                }
            }
            Popupobj.before_validate = function () {

                return true;
            }
            Popupobj.after_validate = function () {
                return true;
            }
            Popupobj.before_duplicate = function () {
                return true;
            }
            Popupobj.after_duplicate = function () {
                return true;
            }
            Popupobj.addOtherSaveUrl = function () {
                // 41581: （61mis.com/kfbcrm）成员管理明细界面>更多>复制：复制成员保存后，该成员的数据范围会自动变为“全部”（需要补丁）
                return '';
            }

            CommonPagePopup.sendprevPageValueToCurpage();//把编辑或新建界面的值传递给快速创建界面上
            var oS = document.createElement('script');
            //if(dynamicJsScript[module+"_js"]!=1)
            //{

            //各个模块的有相同名称函数，所以每次都要重新加载
            oS.src = global_js_url + "include/js/modules/" + module + "/" + module + ".js?v=" + Math.random();
            oS.id = module + "_js";
            document.getElementById(Popupobj.divid).appendChild(oS);
            //}
            oS = document.createElement('script');
            oS.src = global_js_url + "include/js/modules/" + module + "/Save.js?v=" + Math.random();
            document.getElementById(Popupobj.divid).appendChild(oS);
            oS.onload = oS.onreadystatechange = function () {

                if (!this.readyState || this.readyState == 'loaded' || this.readyState == 'complete') {
                    ld('textarea').not('.proName_note').autosize();//textarea根据内容自动调整大小
                    Popupobj.showafter();//js加载完成
                    //朗捷

                    if (CrmPopup.findHtmlobj(Popupobj.divid, 'version_account').val() == 'langjie') {
                        if (Popupobj.module == "CustomForm22") {
                            // 报关单复制 某些字段重置为空
                            HideDetail();
                            setDetailNull();
                        }

                        if (paramsobj.params.relatedcreate == 'yes') {

                            var frommodule = getSearchString('frommodule', url);
                            if (module == 'CustomForm18') {

                                //应收
                                setLangJieRelateFieldValue('', frommodule);

                            } else if (module == 'CustomForm19') {
                                setLangJieRelateFieldValueCustomForm19('', frommodule);
                            }
                        }
                        /*else if(popupobj.module=='CustomForm18'&&ld("#"+popupobj.divid+" [name=service_type]").length>0)
                        {

                        }*/

                        //关联创建的时候 空运订单回传单据分录自动根据选定的“空运订单”带出
                        if (Popupobj.module == "CustomForm25" && CrmPopup.findHtmlobj(popupobj.divid, 'customform24_id').val() != '') {
                            getLangjieModuleRelatedInfo('CustomForm24', CrmPopup.findHtmlobj(Popupobj.divid, 'customform24_id').val())
                        }

                    }

                    //@edit:liushuai,2020-8-12,reason:【ID1001000】（王耀文的客户）个性化开发
                    if (account_version == 'haochen' && module == 'Accounts') { //编辑，PageRecordPopup.js  showpage也需要该逻辑
                        PopupJqObj.find("[name=accountname]").on("input", function () {
                            var accountname = CrmPopup.getHtmlobjval(Popupobj.divid, 'accountname');
                            var account_product_line = CrmPopup.getHtmlobjval(Popupobj.divid, 'cf_2738');//客户产品线
                            PopupJqObj.find("[name=cf_2787]").val(trim(accountname) + trim(account_product_line));//客户全称(产品)
                        });
                    }
                }
            }
            
           // alert(paramsobj.params.relatedcreate);
            //单据新增- 默认根据负责人，带出关联的引用字段（如：部门）
            //ls 2022-04-24 0051258:产品管理模块，成员所属部门不显示值(产品管理负责人fieldname为prosmownerid)
            if(paramsobj.params.relatedcreate=='yes')
            {
                
                //edit:can 20231227 销售订单下推发货通知单，不会带出客户的负责人和客户管理中的客户特殊需求，直接新建发货通知单可以带出 
                //php 不好修改，所以我放到js
                   var referencefieldname='';
                   
                   var fromid=getParamByurl(url,'fromid');
                   
                   var frommodule=getParamByurl(url,'frommodule');
                   ld.each(Popupobj.fields,function(tmpindex,tmpinfo){
                             if(tmpinfo.referencemodule==frommodule)
                             {
                                referencefieldname=tmpinfo.fieldname;
                                return false;
                             }
                            
                   })
                   var referencejqobj=undefined;
                   var selecttype='';
                  
                   if(referencefieldname=='')
                   {
                            ld.each(Popupobj.sourcemodule_arr,function(tmpindex,tmpsourcemodule){
                                //原单
                                if(tmpsourcemodule==frommodule)
                                {
                                  selecttype ='popupselectfield';
                                  return false;
                                }
                            })
                   }
                   else{
                         selecttype='select';
                   }
                    
                 if(selecttype!='')
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, fromid, '', referencefieldname, Popupobj.module, selecttype);
                    });
            }
            if (PopupJqObj.find("[name=assigned_user_id]").val() != undefined || PopupJqObj.find("[name=ServiceContractsassigned_user_id]").val() != undefined ||
             PopupJqObj.find("[name=prosmownerid]").val() != undefined) {
                if (PopupJqObj.find("[name=assigned_user_id]").val() != undefined) {
                    var assigned_user_id = PopupJqObj.find("[name=assigned_user_id]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, assigned_user_id, '', 'assigned_user_id', Popupobj.module, 'select');
                    });
                } else if (PopupJqObj.find("[name=prosmownerid]").val() != undefined) {
                    var assigned_user_id = PopupJqObj.find("[name=prosmownerid]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, assigned_user_id, '', 'prosmownerid', Popupobj.module, 'select');
                    });
                } else {
                    var assigned_user_id = PopupJqObj.find("[name=ServiceContractsassigned_user_id]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, assigned_user_id, '', 'ServiceContractsassigned_user_id', Popupobj.module, 'select');
                    });
                }

            }
            if (PopupJqObj.find("[name=creator]").val() != undefined || PopupJqObj.find("[name=ServiceContractscreator]").val() != undefined || PopupJqObj.find("[name=smcreatorid]").val() != undefined) {
                if (PopupJqObj.find("[name=creator]").val() != undefined) {
                    var creator = PopupJqObj.find("[name=creator]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, creator, '', 'creator', Popupobj.module, 'select');
                    });
                } else if (PopupJqObj.find("[name=ServiceContractscreator]").val() != undefined) {
                    var creator = PopupJqObj.find("[name=ServiceContractscreator]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, creator, '', 'ServiceContractscreator', Popupobj.module, 'select');
                    });
                } else {
                    var creator = PopupJqObj.find("[name=smcreatorid]").val();
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(Popupobj.module, creator, '', 'smcreatorid', Popupobj.module, 'select');
                    });
                }

            }
            //zkt 20221103 XUQIU1000798 产品设置了禁用，复制过往有这个产品的订单时，增加提示信息：产品分录明细中存在已禁用产品，复制后不会带入这些产品！
            if (data.result.warningmsg != undefined && !empty(data.result.warningmsg)) {
                resultRemindsMsg("", "LdPopWidth450px", "", "yes", "", data.result.warningmsg);
                var rmindpopupobj = CrmPopup.getPopupObj('last');
                ld('#' + rmindpopupobj.divid + " #pop_remind_content div").css('padding', '10px 8px');
            }
            if (data.result.isduplicate != undefined && !empty(data.result.isduplicate) && data.result.isduplicate == 'yes' &&
                paramsobj.params.createdtype == 'quickcreate'&&Popupobj.showquickcreate =='yes'){
                //edit:can BUG20241023-50;
                PopupJqObj.find('#pagechange').click();
            }
            Popupobj.setTimeCount();
            //if (typeof Popupobj.selectproductobj != 'undefined')
            //Popupobj.selectproductobj.showTooltipByTable();

            // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
            tooltip(PopupJqObj.find(".tip-items-pop"), {transition: true, time: 200});
            return Popupobj;
        } else {

            PopupJqObj.remove();
            Popupobj.crmpopuplayerobj.unblock();
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
        }
    });
    if (isAvailablelocalStorage) {
        //zxm 20220110 关闭浏览器保存新建页面的暂存信息
        window.addEventListener("beforeunload", addwindowlistener);
    }
}

CreatePagePopup.moduleEditFun = {
    PricePolicy: function () {
        AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
        PricePolicy.getInstance().getEditInstance().moduleEdit();
    },
    //产品属性模块
    ProductProperty: function () {
        AjaxJSPage('ProductProperty', 'include/js/modules/ProductProperty/ProductProperty.js');
        ProductProperty.moduleEdit();//编辑页事件设置
    },
    //产品新建页面的产品属性信息
    Products: function () {
        AjaxJSPage('ProductsEdit', 'include/js/modules/Products/ProductsEdit.js');
        ProductsEdit.moduleEdit();
    }
}

CreatePagePopup.moduleEditDetail = {
    Products: function (popupObj) {
        try {
            AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
            PricePolicy.getInstance().getUseInstance().showBlock();

            // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
            AjaxJSPage('ProductPropertyGroup', 'include/js/modules/ProductProperty/ProductPropertyGroup.js');
        }
        catch (e) {
            console.log(e);
        }
    },
}

CreatePagePopup.moduleEdit = function (popupObj) {
    var module = popupObj.module,
        detailModule = popupObj.detailfieldmodule,
        moduleEdit = CreatePagePopup.moduleEditFun[module],
        moduleEditDetail = CreatePagePopup.moduleEditDetail[detailModule];
    if(typeof moduleEdit === "function") {
        moduleEdit();
    }
    if(typeof moduleEditDetail === "function") {
        moduleEditDetail(popupObj);
    }
}
