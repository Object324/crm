function SaveDataRecord() {

}

SaveDataRecord.validate = function () {
    var popupobj = CrmPopup.getPopupObj("last");

    if (popupobj.before_validate()) {
        if (popupobj.detailfieldmodule != undefined && popupobj.detailfieldmodule == 'Products' && popupobj.module != 'WorkSheet') {
            //产品分录明细保存
            if (validateInventory(popupobj.module)) {

                return popupobj.after_validate();
            }

        } else if (formValidate())   //验证
        {
            if (popupobj.hasOwnProperty('detailfieldmodule') && popupobj.detailfieldmodule !== undefined
                && popupobj.detailfieldmodule.indexOf('detailhtml') > -1 && !verifyTabDetailField()) {
                return false;
            }
            return popupobj.after_validate();
        }
    }
    return false;
}

SaveDataRecord.getprodcutdetailfieldurl = function () {
    //editor:gyq_161 reason:获取产品分录明细的url   2019/11/21 16:18
    var ret = true;
    var popupobj = CrmPopup.getPopupObj('last');
    var tableobj = popupobj.getDetailTableObj();
    var module = popupobj.module;
    var trobjs = popupobj.getTrObjsByDelType("no");//获取没有删除的行
    var rowcnt = ld("#" + popupobj.divid + " [name=rowcnt]").val();
    //duplicateid:被复制的单据id
    var i = 1;
    var url = "&duplicateid=" + ld("#" + popupobj.divid + " [name=duplicateid]").val();
    var detailhidecolumns = popupobj.detailhidecolumns;
    var rowindex = 0;
    var tmpdetailfield=popupobj.detailfields;
    //popupobj.noprofiledetailfields:不是数组
    //if(popupobj.noprofiledetailfields!=undefined&&popupobj.noprofiledetailfields.length>0)
        //  tmpdetailfield=popupobj.detailfields.concat(popupobj.noprofiledetailfields);
    var rowcount = 0;
    var hidden_arr = [];
    ld.each(tmpdetailfield, function (tmpindex, tmpfieldinfo) {
        if (ld('#' + popupobj.divid + ' #proTab td[head_detailfieldname=' + tmpfieldinfo.columnname + ']:visible').length === 0) {
            hidden_arr.push(tmpfieldinfo.columnname);
        }
    });

    ld.each(popupobj.detaildatavalue_arr, function (tmpvalueindex, tmpvalueinfo) {
        var productid = tmpvalueinfo.productid;
        rowindex++;
        if (ld.trim(productid) == '' || parseInt(productid) <= 0) {
            //判断是否为空行
            return true;
        }
        rowcount++;
        var productbomid = tmpvalueinfo.productbomid;
        if (productbomid == undefined)
            productbomid = 0;
        var productbomquantity = tmpvalueinfo.productbomquantity;
        if (productbomquantity == undefined)
            productbomquantity = 0;
        var lineitem_name = "lineitem_id" + i;
        var before_lineitem_id_name = "before_lineitem_id" + i;
        var paramname = "hdnProductId" + i;
       
        url += "&productbomid" + i + "=" + productbomid + "&productbomquantity" + i + "=" + productbomquantity;//产品套餐
        url += "&" + paramname + "=" + productid + "&" + lineitem_name + "=" + tmpvalueinfo.parent_lineitem_id;
        url += "&" + before_lineitem_id_name + "=" + tmpvalueinfo.lineitem_id;
        if (module == 'WorkSheet') {
            //var related_productid = tmpvalueinfo.relatedProductId;
            var related_productid = tableobj.find("tr[rowindex="+rowindex+"]").find(" [name=relatedProductId]").val();
            url += "&related_productid" + i + "=" + related_productid;
        }
       

        ld.each(tmpdetailfield, function (tmpindex, tmpfieldinfo) {
            var tablename = tmpfieldinfo.tablename;
            var fieldlabel = tmpfieldinfo.fieldlabel;
            if (tablename == popupobj.detailtablenamescf || tablename == popupobj.detailtablename) {
                var tmpname = tmpfieldinfo.columnname;
                var paramname = tmpfieldinfo.columnname + i;
                var typeofdata = tmpfieldinfo.typeofdata;
                var value = tmpvalueinfo[tmpname];
                typeofdatas = typeofdata.split("~");
                if (detailhidecolumns != undefined && detailhidecolumns.includes(tmpname)) {
                    typeofdatas[1] = 'O';//布局规则隐藏必填字段后，不需要判断必填项目
                }
                if(hidden_arr.includes(tmpname)){
                    typeofdatas[1] = 'O';//没查看权限字段不判断必填
                }
                if(tmpfieldinfo.uitype==60 && tmpname=='wareid')
                {
                    value=tmpvalueinfo[tmpname+"_rawvalue"];
                    
                }
                else if(tmpfieldinfo.uitype == 56){
                    value = (value==true||value==1)?1:0;
                }
                //多选框  多选框的uitype为63
                if (tmpfieldinfo.uitype == 63) {
                   /* var trobj=ld("tr[rowindex=1]");
                     var tmpobj = ld(trobj).find("#" + tmpname);
                    var strtmp = getMultiPickListSelectValueByObj(tmpobj);
                    alert(strtmp);*/
                    
                    var strtmp = tmpvalueinfo[tmpname];
                    if (typeofdatas[1] == 'M' && ld.trim(value) == '') {
                        //var tmpobj=ld(tableobj).find("tr[rowindex="+rowindex+"]").find("#"+columnname);
                        var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                        audioRemindsMsg("", "", module, "", "", confirm_str);
                        //ld(tmpobj).focus();
                        //emptyCheckObj(tmpobj, tmpfieldinfo.uitype);
                        ret = false;
                        return false;
                    }
                
                    url += "&" + paramname + "=" + strtmp;
                }
                
                 else if (tmpfieldinfo.uitype == '69' || tmpfieldinfo.uitype == '1109') {
                    //ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(产品分录保存时将图片信息写入url)
                    //edit: xll 2023/06/25 XUQIU1000357 单据分录增加附件字段(产品分录保存时将附件信息写入url)
                    //edit: xll 2023/07/18 BUG0069656 kfbcrm-销售退货单-单据分录-新增附件字段，设置为必填，不生效 
                    var file_url = SaveDataRecord.getDetailFileurlNew(tmpfieldinfo, popupobj, ld(trobjs).eq(i-1).attr('rowindex'));
                    if((file_url == undefined || file_url == '' || file_url.length == 0) && typeofdatas[1] == 'M'){
                        var confirm_str = tmpfieldinfo.fieldlabel+arrJsPopLabel['CANOTEMPTY'];

                        audioRemindsMsg("","","","","",confirm_str);
                        ret = false;
                        return false;
                    }
                    else
                        url += file_url;
                }
                //zkt 20230614 批次字段非空判断，没有批次的产品应不显示批次
				//zkt BUG0067613 kfbcrm-出库单-新建-选择产品，当此产品没有开启批次字段，但在出库单批次为必填时，单据保存不了 
                else if(tmpfieldinfo.columnname == 'batchtext'){
                    if (typeofdatas[1] == 'M' && tmpvalueinfo['producthave_batchtext'] == 'yes' && ld.trim(tmpvalueinfo[tmpname]) == '') {
                        var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                        audioRemindsMsg("", "", module, "", "", confirm_str);
                        //edit: xll 2023/05/16 BUG0066221 产品分录的必填项为空时点击保存，应在弹出提示信息的同时将输入框标红
                        var tmpobj=ld(tableobj).find("tr[rowindex="+rowindex+"]").find("#"+tmpname);
                        ld(tmpobj).focus();
                        emptyCheckObj(tmpobj, tmpfieldinfo.uitype);
                        ret = false;
                        return false;
                    }
                    url += '&' + paramname + "=" + encodeURIComponent(value);
                }
                else {
                    if (typeofdatas[1] == 'M' && ld.trim(tmpvalueinfo[tmpname]) == '') {
                        var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                        audioRemindsMsg("", "", module, "", "", confirm_str);
                        
                        //edit: xll 2023/05/16 BUG0066221 产品分录的必填项为空时点击保存，应在弹出提示信息的同时将输入框标红
                        var tmpobj=ld(tableobj).find("tr[rowindex="+rowindex+"]").find("#"+tmpname);
                        ld(tmpobj).focus();
                        emptyCheckObj(tmpobj, tmpfieldinfo.uitype);
                        
                        ret = false;
                        return false;
                    }
                    if ((typeofdatas[0].toLowerCase() == 'nn' || typeofdatas[0].toLowerCase() == 'n') && isNaN(value) && version_account != 'langjie') {
                        var confirm_str = arrJsPopLabel['INVALID'] + fieldlabel;
                        audioRemindsMsg("", "", module, "", "", confirm_str);

                        //var tmpobj=ld(tableobj).find("tr[rowindex="+rowindex+"]").find("#"+tmpname);
                        //ld(tmpobj).focus();
                        //emptyCheckObj(tmpobj, tmpfieldinfo.uitype);
                        ret = false;
                        return false;
                    }
                    //wym BUG20240402-65 导入明细时保存时，多次点击保存后没有提示信息且点不动
                    if((typeofdatas[0] == 'N' || typeofdatas[0] == 'NN') && value!=undefined && value!='' && value!='undefined'){
                        value = value.toString(); // duan 20240511 replace 方法只有string类型的变量才有，增加格式转换
                        if (value.replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                            if (value != 0) {
                                // duan 20231020 单据分录有些字段不能设置小数位数,不能判断数据格式
                                /*
                                if (typeof (typeofdatas[2]) == "undefined") var numformat = "any";
                                else var numformat = typeofdatas[2];
                                */
                                var numformat = "any";
                                if (typeofdatas[0] == "NN") {
                                    if (!detail_numValidate(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, numformat, true,value)){
                                        var rowobj = ld(tableobj).find("tr[rowindex="+rowindex+"]");
                                        rowobj.find("#"+tmpname).focus();
                                        audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                        ret = false;
                                        return false;
                                    }
                                } else if (!detail_numValidate(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, numformat,false,value)){
                                    var rowobj = ld(tableobj).find("tr[rowindex="+rowindex+"]");
                                    rowobj.find("#"+tmpname).focus();
                                    audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                    ret = false;
                                    return false;
                                }
                                if (typeofdatas[3]) {
                                    if (!detail_numConstComp(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, typeofdatas[3], typeofdatas[4],value)){
                                        audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                        var rowobj = ld(tableobj).find("tr[rowindex="+rowindex+"]");
                                        rowobj.find("#"+tmpname).focus();
                                        ret = false;
                                        return false;
                                    }

                                }
                            }
                        }
                    }
                    //BUG20240425-31 ls 240510 编辑单据，验证规则不生效(无源单时entitytypeid存的0,0会被认为不为空，即有源单)
                    if(tmpfieldinfo.columnname == 'entitytypeid'){
                        if (value === '0') {
                            value = '';
                        }
                    }
                    url += '&' + paramname + "=" + encodeURIComponent(value);


                }
                if (tmpfieldinfo.columnname == 'entitytypeid') {
                    //var entityname = "entitytype" + i;
                    //url += '&' + entityname + "=" +tmpvalueinfo.entitytype;
                    var tmpselectSourceModuleid = "selectSourceModuleid" + i;
                    url += '&' + tmpselectSourceModuleid + "=" + value;

                }
            }

        })
        if(tmpvalueinfo.is_present === 'yes') {
            // 赠品信息
            url += `&present${i}=${tmpvalueinfo.present}`;
        }
        i++;
    })
    url += '&rowcnt=' + rowcount;



    if (!ret) {
        return false;
    }

    return url;

}
SaveDataRecord.duplicate = function () {
    var popupobj = CrmPopup.getPopupObj("last");
    if (popupobj.hasOwnProperty('before_duplicate') && !popupobj.before_duplicate()) {
        return false;
    }
    if (FieldDuplicateValidate(popupobj.module, CrmPopup.findHtmlobj(popupobj.divid, "EditView"), '')) {
        return popupobj.after_duplicate();
    }

    return false;
}
SaveDataRecord.after_duplicate = function () {

    return true;
}
SaveDataRecord.save = function () {
    // puyoungJS_DialogBox.block();
    var popupobj = CrmPopup.getPopupObj("last");
    if (popupobj.module == 'LessionPlan') {
        saveLessionPlan();//排课计划
        return true;
    }
    var btnobj = popupobj.getbtnOkobj();
    btnobj.disabled = true;
    //  var ret=SaveDataRecord.validate();

    if (SaveDataRecord.validate()) {
        if (SaveDataRecord.duplicate()) {

            //getJsScript('include/js/DetailButtons.js',function(){
            SaveDataRecord.ajaxsave();
            //});
        } else {
            btnobj.disabled = false;
            popupobj.issavesubmit = 'no';
        }
    } else {
        popupobj.issavesubmit = 'no';

        btnobj.disabled = false;
    }
}
SaveDataRecord.getSpecialurl = function () {
    var popupobj = CrmPopup.getPopupObj("last");
    var url = "";

    if (popupobj.module == 'Expense' && typeof PiaozoneObj != 'undefined' && PiaozoneObj.isauthorize=='yes') {
        var pz_invoicetotal = ld('#' + popupobj.divid + ' #pz_invoicetotal').val();//发票合计值
        url += "&pz_invoicetotal="+pz_invoicetotal+"&pz_deleteserialno_arr="+encodeURIComponent(JSON.stringify(PiaozoneObj.deleteserialno_arr))+"&pz_invoicedata="+encodeURIComponent(JSON.stringify(PiaozoneObj.invoicedata));

        return url;
    }

    return false;
}
SaveDataRecord.save.funname = "SaveDataRecord.save";
SaveDataRecord.ajaxsave = function () {

    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var savedeskvaluepage = popupobj.getsavedeskpageValue();
    var module = popupobj.module;
    var filedataarr = popupobj.getFileDataArr();
    var htmlurl = "index.php?module=" + popupobj.module + "&action=Save&issavesubmit=" + popupobj.issavesubmit;
    // console.log(popupobj);
    //添加来源
    htmlurl += "&sourcefrom=PC";
    if (popupobj.type == CreatePagePopup.type && popupobj.callcenter == 'yes') {
        //呼叫中心
        htmlurl += "&callbutlername=" + encodeURIComponent(ld("#" + popupobj.divid + " [name=callbutlername]").val());
        htmlurl += "&callButlerRemarks=" + encodeURIComponent(ld("#" + popupobj.divid + " [name=callButlerRemarks]").val());

        htmlurl += "&calltype=" + ld("#" + popupobj.divid + " [name=calltype]").val();
        htmlurl += "&jiuweiaccount=" + ld("#" + popupobj.divid + " [name=jiuweiaccount]").val();
        htmlurl += "&callcenter_switch=" + ld("#" + popupobj.divid + " [name=callcenter_switch]").val();

        // htmlurl+="&calltalkid="+ld("#"+popupobj.divid+" [name=calltalkid]").val();

    }
    if (popupobj.frommodule != undefined) {
        htmlurl += "&frommodule=" + popupobj.frommodule + "&fromid=" + popupobj.fromid + "&fromcheck=no";
    }
    if (popupobj.upgradefrommodule != undefined) {
        //销售线索升级
        htmlurl += "&upgradefrommodule=" + popupobj.upgradefrommodule + "&upgradefromid=" + popupobj.upgradefromid ;
    }
    //duan 2022-2-14 销售线索增加'升级到客户和销售机会选项'判断是否需要升级到销售机会
    if (popupobj.upgradetomodule != undefined && popupobj.upgradetomodule != '') {
        htmlurl += "&upgradetomodule=" + popupobj.upgradetomodule;
        htmlurl += "&fromid=" + popupobj.fromid;
    }
    if(!empty(popupobj.upgradestatus)){
        htmlurl += "&upgradestatus=" + popupobj.upgradestatus;
    }

    var mode = '';
    if (popupobj.type == PageRecordPopup.type) {
        mode = 'edit';
        htmlurl += "&record=" + popupobj.record + "&mode=edit";
    } else if (popupobj.type == CreatePagePopup.type) {
        mode = 'create';
        htmlurl += "&mode=create&Create=yes";
    }
    var tmpurl = "&refreshpage=no";
/*  popobj中有refreshpage的参数 269行并没有引用该参数 但目前还没有相关bug提出 先不修改
    var refreshpage = popupobj.refreshpage ? popupobj.refreshpage:'no';
    var tmpurl = "&refreshpage="+refreshpage;*/
    if (popupobj.cashbilltype != undefined) {

        htmlurl += "&cashbilltype=" + popupobj.cashbilltype;
        if (popupobj.cashbilltype == 'cashbill')//收款单预收款信息
            htmlurl += "&save_debuctioninfo=" + popupobj.save_debuctioninfo + "&deleted_debuctioninfodetailid=" + popupobj.deleted_debuctioninfodetailid;
    }
    //duan 20220630 将获取字段值的判断放到方法里，方便外部调用
    tmpurl += SaveDataRecord.getFieldValue(popupobj, popupobj.fields, savedeskvaluepage);
    tmpurl += SaveDataRecord.getSaveParams(popupobj);

    //34302: 服务收费管理新增界面>新增一条单服务收费单（填写首要联系人区块的信息）>编辑刚才新增的服务收费单据的首要联系人姓名>结果：生成了另一外一条联系人单据，而不是覆盖掉。
    if (popupobj.module == 'Accounts' || popupobj.module == 'ServiceCharge') {
        tmpurl += '&contactid=' + CrmPopup.getHtmlobjval(divid, 'contactid');
        tmpurl += '&publicaccount=' + CrmPopup.getHtmlobjval(divid, 'publicaccount');
    }
    if (popupobj.module == 'Leads') {
        tmpurl += '&publicaccount=' + CrmPopup.getHtmlobjval(divid, 'publicaccount');
    }
    //duan 20220919 保存用户信息时获取“是否需要替换所有正在审批中单据”
    if (popupobj.module == 'Users') {
        if (CrmPopup.getHtmlobjval(divid, 'approvestatus') == 0 && !empty(CrmPopup.getHtmlobjval(divid, 'approveby')))
            tmpurl += '&resetapprover=' + ld("#" + divid + " [name=approveby]").attr('resetapprover');
        //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
        if(popupobj.user_type){
            tmpurl += '&user_type='+popupobj.user_type;
        }
    }
    //日程管理
    if ('Calendar' == popupobj.module) {
        if (ld('input:radio[name="set_remind"]') != undefined) {
            tmpurl += '&set_remind=' + ld('input:radio[name="set_remind"]:checked').val() + '&email_date_only=' + ld('#jscal_field_email_remind').val();

        }
        if (ld('input:radio[name="pop_reminds"]') != undefined) {

            tmpurl += '&pop_reminds=' + ld('input:radio[name="pop_reminds"]:checked').val() + '&date_time=' + ld('#jscal_field_date_only').val();

        }
        var selectedColumnsObj = getObj('selectedusers');
        if (selectedColumnsObj != undefined) {
            var selectedColStr = "";
            for (i = 0; i < selectedColumnsObj.options.length; i++) {
                selectedColStr += selectedColumnsObj.options[i].value + ";";
            }
            if (!empty(selectedColStr)) {
                tmpurl += '&inviteesid=' + selectedColStr;
            }
        }


        /*循环日程
        * //ls 20240412 XUQIU1002280  优化日程界面及其设置循环日程功能
        * */
        var loop_type = ld("#" + divid + " [name=loop_type]").val();
        var loop_month = '' ;
        var loop_dayvalue = '';
        var reminder_setting = '';
        var expiredate = '';

        var btnobj = popupobj.getbtnOkobj();
        reminder_setting = ld("#" + divid + " [name='reminder_setting[]']").val() || '';
        expiredate = ld("#" + divid + " [name='expiredate']").val() || '';

        var date_start = ld("#" + divid + " [name='date_start']").val() || '';//单据头"开始时间"
        if (/*!empty(reminder_setting) && */empty(date_start)) { //若设置提醒时间，但没有录入“开始时间”保存时，提示“开始时间不能为空”
            MessagePopup.TipZero_error(arrJsPopLabel['STARTTIME']+arrJsPopLabel['CANOTEMPTY']);
            ld("#" + divid + " [name='date_start']").focus().css('border','1px solid #eb0f51');
            btnobj.disabled = false;
            return;
        }
        if (!empty(expiredate) && expiredate <= date_start) { //“到期日期”要大于“开始时间”
            MessagePopup.TipZero_error(arrJsPopLabel['ExpireDateCanNotLTStartTime']);
            btnobj.disabled = false;
            return;
        }


        if (loop_type == 'daily') {
        }else if (loop_type == 'weekly' || loop_type == 'biweekly') {
            loop_dayvalue = ld("#" + divid + " [name='loop_dayvalue[]']").val();
            console.log(loop_dayvalue);
            if (empty(loop_dayvalue)) {
                MessagePopup.TipZero_error(arrJsPopLabel['CANOTEMPTY']);
                ld("#" + divid + " [name='loop_dayvalue[]']").focus().css('border','1px solid #eb0f51');
                btnobj.disabled = false;
                return;
            }
        }else if (loop_type == 'monthly') {
            // var loop_month = getMultiPickListSelectValue('loop_month[]');//值为中文,一月########三月########五月
            loop_month = ld("#" + divid + " [name='loop_month[]']").val();//1,3,5
            loop_dayvalue = ld("#" + divid + " [name='loop_dayvalue[]']").val();
            if (empty(loop_month)) {
                MessagePopup.TipZero_error(arrJsPopLabel['CANOTEMPTY']);
                ld("#" + divid + " [name='loop_month[]']").focus().css('border','1px solid #eb0f51');
                btnobj.disabled = false;
                return;
            }else if (empty(loop_dayvalue)) {
                MessagePopup.TipZero_error(arrJsPopLabel['CANOTEMPTY']);
                ld("#" + divid + " [name='loop_dayvalue[]']").focus().css('border','1px solid #eb0f51');
                btnobj.disabled = false;
                return;
            }
        }

        tmpurl += '&loop_type=' + loop_type+'&loop_month=' + loop_month+'&loop_dayvalue=' + encodeURIComponent(loop_dayvalue)+'&reminder_setting=' + reminder_setting+'&expiredate=' + expiredate;

    }

    //市场活动管理创建联系人和客户等类似功能


    if (popupobj.tablerelfields != "") {
        htmlurl += '&tablerelmodule=' + popupobj.tablerelfields['module'];

        htmlurl += '&tablerelid=' + popupobj.tablerelfields['fromid'];

    }

    if (popupobj.module == 'ServiceCharge' || popupobj.module == 'Accounts') {
        htmlurl += '&contactid=' + popupobj.columnfields_value['contactid'];
    }
    //035709: 附件上传删除保存后，希望将服务器里附件同步删除。
    if (popupobj.module == 'Attachment') {
        if (popupobj.attachmentdelfileids != undefined && popupobj.attachmentdelfileids.length > 0) {
            var delfileid = popupobj.attachmentdelfileids.join();
            htmlurl += "&attachmentdelfileid=" + delfileid;
        }
    } else {
        if (popupobj.delfileids != undefined && popupobj.delfileids.length > 0) {
            var delfileid = popupobj.delfileids.join();
            htmlurl += "&delfileid=" + delfileid;
        }
        if (popupobj.imagedelfileids != undefined && popupobj.imagedelfileids.length > 0) {
            var delfileid = popupobj.imagedelfileids.join();
            htmlurl += "&imagedelfileid=" + delfileid;

        }
    }

    if (popupobj.detailfieldmodule == 'Products')//产品分录保存
    {
        // 工单管理模块同时保存产品分录和配件分录
        if (popupobj.module == 'WorkSheet') {
            partdetailurl = getpartdetailfieldurl();
            tmpurl += partdetailurl;
            popupobj.js_detailtablename = 'proTab';
        }

        var productdetailurl = SaveDataRecord.getprodcutdetailfieldurl();

        if (!productdetailurl) {
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return false;
        }
        tmpurl += productdetailurl;
        //  alert(ld("#" + popupobj.divid + " [name=total]").val());
        if (popupobj.module == 'CashBill') {
            tmpurl += "&cashbill_total=" + ld("#" + popupobj.divid + " [name=total]").val();
        } else if (popupobj.module == 'SendCashBill') {
            tmpurl += "&sendcashbill_total=" + ld("#" + popupobj.divid + " [name=total]").val();
        } else
            tmpurl += "&total=" + ld("#" + popupobj.divid + " [name=total]").val();
        var subtotal = 0;
        if(ld("#" + popupobj.divid + " [name=subtotal]").length >0 ){
            subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
        }
        tmpurl += "&subtotal=" + subtotal;
        tmpurl += "&inventory_currency=" + ld("#" + popupobj.divid + " [name=inventory_currency]").val();
        var adjustmentobj = ld("#" + popupobj.divid + " [name=adjustment]");
        if (adjustmentobj.length > 0) {
            tmpurl += "&adjustment=" + adjustmentobj.val();
            tmpurl += "&adjustmentType=" + encodeURIComponent(ld("#" + popupobj.divid + " [name=adjustmentType]").val());
        }
        var allSingledDiscountobj = ld("#" + popupobj.divid + " [name=allSingledDiscount]");
        if (allSingledDiscountobj.length > 0) {
            tmpurl += "&allSingledDiscount=" + allSingledDiscountobj.val();
            //edit:can 2020-11-11 043220: （本地php54，8.3.0版本）销售管理-合同订单-详情编辑；单据编号 SO3 分录中的整单折扣输入增加或减少金额 保存后，详情中整单折扣数值显示0；

            tmpurl += "&discount_amount=" + ld("#" + popupobj.divid + " [name=discount_amount]:last").val();
            // tmpurl += "&adjustmentType=" + ld("#" + popupobj.divid + " [name=adjustmentType]").val();
        }
    } else if (popupobj.hasOwnProperty('detailfieldmodule') && popupobj.detailfieldmodule !== undefined && popupobj.detailfieldmodule.indexOf('detailhtml') > -1) {
        //editor:gyq_161 reason:源单分录保存   2019/11/26 17:51
        var tabdetailurl = SaveDataRecord.gettabdetailfieldurl(htmlurl + tmpurl);
        if (tabdetailurl != false)
            tmpurl += tabdetailurl;
        else {
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return false;
        }
    }


    var specialurl = SaveDataRecord.getSpecialurl();
    if (specialurl != false)
        tmpurl += specialurl;
    /*
    *edit: chj
    *date: 2020/8/28
    *reason: 42537: （61mis.com/kfbcrm）客户问题（麦莎），合同订单>选择编号为“SO378”进入单据详情界面>相关创建“销售退货单”：退货单保存后不显示（需要补丁）
    */
    if (popupobj.lasturl != undefined)
        tmpurl += popupobj.lasturl;


    //module/Users/save.js
    tmpurl += popupobj.addOtherSaveUrl();//41581: （61mis.com/kfbcrm）成员管理明细界面>更多>复制：复制成员保存后，该成员的数据范围会自动变为“全部”（需要补丁）
    var con = true; //zkt 0046269: 验证规则，允许保存的时候，弹出的提示信息界面有“是”、“否”（确定/取消）2个按钮 选择“是”（确定），保存;选择“否”（取消），返回新增或者编辑界面
    // edit:can 20211015 048306: 这个账套-采购管理-采购申请单-下推生成采购合同，把验证规则关闭了，甚至删除了，但是还是提醒了

    //复制保存时不判断审批状态
    if (popupobj.issavesubmit == 'no' && popupobj.isduplicate != 'yes' ) {
        //duan 20240611 修改后需要判断是否重置审批状态,调整提示框
        con = validatasave.checkResetApprove(popupobj,popupobj.record,popupobj.module,SaveDataRecord.ajaxsave);
        if (!con) {
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return;
        }
    }

    //判断 用户超过授权数量 给出提示
    var usercon = true;
    if(popupobj.module == 'Users' && mode == 'create'){
        usercon = validatasave.checkuserscountsave(popupobj,SaveDataRecord.ajaxsave);
        if (!usercon) {
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return;
        }
    }
    var approvesubmitvalid = true;
    if (popupobj.issavesubmit == 'yes')
        var approvesubmitvalid = Detail_save_submitapprove.validata();

    if (!approvesubmitvalid)
        return false;

    //zxm 20241010 产品模块增加产品属性的分录设置  开启产品属性
    if ('Products' == popupobj.module
        &&ld('#'+popupobj.divid).find('[name=sel_property_status]')
        &&ld('#'+popupobj.divid).find('[name=sel_property_status]').length>0
        &&ld('#'+popupobj.divid).find('[name=sel_property_status]').prop('checked')==1) {
        //产品属性开启 则属性组合至少要有一个
        var tmprowcnt = ld('#'+popupobj.divid).find('#productproperty_list_body tr').length;
        if(tmprowcnt==0){
            MessagePopup.TipZero_error('至少保存一个产品属性组合');
            //RemindsMsg("", "LdPopWidth400px", module, "", "", '至少保存一个产品属性组合');
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return false;
        }
        tmpurl += '&productsDetail='+JSON.stringify(popupobj.moduleData.restBlocks.fieldValueList);
        tmpurl += '&rowcnt='+ld('#'+popupobj.divid).find('#productproperty_list_body tr').length;
        //循环分录行
        var detailimage_arr = popupobj.moduleData.restBlocks['detailimage_arr'];
        var fieldValueList = popupobj.moduleData.restBlocks['fieldValueList'];
        var rowindex = 1;
        ld.each(fieldValueList, function (tmpvalueindex, tmpvalueinfo) {
            if(tmpvalueinfo.selected===true) {
                ld.each(detailimage_arr, function (tmpfieldindex, tmpfieldinfo) {
                    var file_url = SaveDataRecord.getDetailFileurlNew(tmpfieldinfo, popupobj, rowindex);
                    tmpurl += file_url;
                    tmpurl += '&hidden_rowid_'+rowindex+'=0';// 1表示删除行  2表示空行
                });
                rowindex++;
            }
        });
    }
    // con = await validatasave.CheckAllowSavePhpRule(popupobj.module,popupobj.record,tmpurl);
    validatasave.CheckAllowSavePhpRule(popupobj.module,popupobj.record,tmpurl+'&issavesubmit='+popupobj.issavesubmit).then(result => {
        con = result ;
        //ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
        //0049254: （81mis.com/kfbcrm/index.php）报价单》单据QUO151，审批结束的单据，复制该单据时，提示编辑保存更改审批状态，


        if (!con) {
            var btnobj = popupobj.getbtnOkobj();
            btnobj.disabled = false;
            return;
        }

        ld('#rptContentLoading').show();
        //zkt 20231008 XUQIU1001341 登录记住密码优化+SQL注入
        var cls_encryptyurlobj = new cls_encryptyurl();
        var encrypttmpurl = cls_encryptyurlobj.puyoung_urlstringtoencrypty(htmlurl+'&'+tmpurl);
        tmpurl += '&'+encrypttmpurl;

        ld.ajax({
            url: htmlurl,
            type: 'POST',
            data: tmpurl,
            dataType: 'json',
            async: false,//
            timeout: 20000,

            success: function (data) {
                if (isAvailablelocalStorage) {
                    //ls 20221216  XUQIU1000403   单据新建界面增加暂存功能（保存之后取消定时器、清除缓存）
                    SaveDataRecord.cancelInterval();
                    var oldStorageKey = getCurrentUrlSite(false) + '_' + module + '_create_' + CURRENT_USER_ID + '_old';
                    // var tmpStorageKey = getCurrentUrlSite(false) + '_' + module + '_create_' + CURRENT_USER_ID + '_tmp';
                    var newStorageKey = getCurrentUrlSite(false) + '_' + module + '_create_' + CURRENT_USER_ID + '_new';
                    // console.log('保存之后取消定时器、清除缓存');
                    localStorage.removeItem(oldStorageKey);
                    // localStorage.removeItem(tmpStorageKey);
                    localStorage.removeItem(newStorageKey);
                }

                var popupobj = CrmPopup.getPopupObj("last");
                var fields = popupobj.fields;
                var savedata = data;
                if (data.code == 1) {


                    //32710: 报价单新增界面：销售机会名称字段，选择销售机会弹出层->快速创建销售机会保存，结果界面跳转错误，到销售机会明细界面了
                    if (data.result.loc_url != undefined && data.result.loc_url.length > 0 && popupobj.createdtype != 'quickcreate') {
                        //32220:参数“设置销售机会新增保存后是否立即创建回款预测”为是，销售机会列表新建单据后，跳转到销售机会明细界面，并且弹出回款预测弹出层
                        window.location = data.result.loc_url;
                        return false;
                    }
                    picklist = false;
                    ld('#rptContentLoading').hide();
                    var prevpopupobj = CrmPopup.getPopupObj("lastprev");

                    var edit_createPopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);// 编辑或新增界面

                    //zxm @date:2024/10/24 @reason:  购物车创建订单  创建完需要刷新购物车
                    if(popupobj&&popupobj.paramsobj&&popupobj.paramsobj.params){
                        var tmpparamsarr = popupobj.paramsobj.params;
                        //popupobj.CancelEvent();//弹窗不能关闭  因为还有可能要创建收款计划
                        if(tmpparamsarr.UpdateShopCartNew){
                            tmpparamsarr.UpdateShopCartNew(tmpparamsarr.cartid);
                        }
                    }

                    //(prevpopupobj.type == 'listpage' || prevpopupobj.type == 'relatedpagelist')
                    //进度追踪页面新建单据后，刷新页面
                    if (prevpopupobj != undefined) {

                        if (prevpopupobj.module != popupobj.module) {
                            //将来做扩展,不用模块的判断
                            /*36668: （1.6）客户列表界面>操作列>点击跟进：做完跟进记录后，自动跳转到第一条单据这里来了。（需要补丁）
                                蔡云桥的客户提出这样的问题

                                解决办法：
                                1、客户列表中点击“跟进”按钮，保存或取消时，不刷新界面（影响未联系天数和最新进展），如果需要更新，可以手动刷新界面；
                                2、客户的编辑界面，不修改（现在编辑保存后还是刷新界面）；*/
                            if (popupobj.module == 'ContactRecords') {
                                //详情页创建跟进记录后更新进度追踪图 推进弹出层创建相关单据后更新弹出层信息
                                if (prevpopupobj.pagetype == 'detailview_modulepage' || prevpopupobj.pagetype == 'advancepopup') {
                                    if(prevpopupobj.AdvanceStageobj!=undefined)
                                    prevpopupobj.AdvanceStageobj.RefreshPopup(prevpopupobj, popupobj);
                                }
                                //zkt 20220722 XUQIU1000266单据“最新进展”等反写字段关联创建相关单据后，单据列表界面字段应该自动刷新，无需手动刷新显示（李森）
                                if (prevpopupobj.pagetype == 'listpage' && (prevpopupobj.module == 'Accounts' || prevpopupobj.module == 'Contacts' || prevpopupobj.module == 'Leads' || prevpopupobj.module == 'ServiceCharge' || prevpopupobj.module == 'Potentials')) {
                                    var tmpfieldvalue = data.result['fieldvalue'];
                                    var tmparr = [];
                                    tmparr.push({
                                        'lastcontent': 'content',
                                        'lastcontactdate': 'contactdate',
                                        'lastcontactuser': 'assigned_user_id',
                                        'nextcontactdate': 'nextcontactdate'
                                    });
                                    //销售线索、销售机会、联系人、服务收费管理跟进后反写字段返回至列表界面
                                    var tmpindex_fieldname = 'account_id';
                                    if (prevpopupobj.module == 'Contacts') {
                                        tmpindex_fieldname = 'contact_id';
                                    } else if (prevpopupobj.module == 'Leads') {
                                        tmpindex_fieldname = 'leads_id';
                                    } else if (prevpopupobj.module == 'Potentials') {
                                        tmpindex_fieldname = 'potential_id';
                                    }
                                    var tmpmoduleobjs = ld("#" + prevpopupobj.divid + " [module=" + prevpopupobj.module + "][record=" + tmpfieldvalue[tmpindex_fieldname] + "]");
                                    ld.each(tmpmoduleobjs, function () {
                                        var tmpfieldname = ld(this).attr('fieldname');
                                        var tmprecord = ld(this).attr('record');
                                        if (tmparr[0][tmpfieldname] == undefined || tmparr[0][tmpfieldname] == '') {
                                            return true;
                                        }
                                        if (tmpfieldvalue[tmparr[0][tmpfieldname]] == undefined) {
                                            return true;
                                        }
                                        if (ld(this).prop("tagName").toLowerCase() == 'span')//
                                        {
                                            ld(this).html(tmpfieldvalue[tmparr[0][tmpfieldname]]);
                                        } else {
                                            ld(this).val(tmpfieldvalue[tmparr[0][tmpfieldname]]);
                                        }
                                    })

                                }

                                if (popupobj.issavesubmit == 'yes') {
                                    //edit:can 52513:（https://81mis.com/kfbtest/index.php）客户--任意一个公海--公海已分配--跟进一个客户--跟进记录选择“保存并提交审批”--打开跟进记录显示未提交审批 
                                    ld("#" + popupobj.divid + ' [name=frmsubmitapprove]').find("input[name=idstring]").val(data.result.fieldvalue.maintable_id);

                                    Detail_save_submitapprove();//保存并提交
                                } else {
                                    //zkt 20221117 BUG0058803kfbcrm 客户页面--下推跟进记录---保存跟进记录没反应
                                    popupobj.CancelEvent();
                                    SaveDataRecord.afterSave_setPrevPopupValue(data);
                                    /*//wyt 221110 XUQIU1000658 主题：关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮(跟进记录保存后未带出)
                                    if (prevpopupobj != undefined && prevpopupobj.type == selectSearchPopup.type) {
                                        var posturl = prevpopupobj.reload_showrelationlistobj.posturl;
                                        posturl += "&quickcreate=yes&recordid=" + data.result.fieldvalue.maintable_id;
                                        ldAjaxNoProgress('index.php',posturl,function (tmpdata) {
                                            if (tmpdata.code == 1) {
                                                SaveDataRecord.afterSave_setPrevPopupValue(data);
                                            } else if (tmpdata.code == -1) {
                                                prevpopupobj.CancelEvent();
                                            }
                                        });
                                    }*/
                                }
                                // if (prevpopupobj.type == DetailViewPage.type) {//百特需求：跟进记录相关信息新建保存后，刷新列表页；和跟进记录列表页操作列跟进按钮新建保存后，刷新列表
                                    var tmpobj = new AfterUpdatePrevPopupObjContent(prevpopupobj.module, "", new Array(prevpopupobj.record));
                                    tmpobj.eachrefreshlistbyModules(new Array(prevpopupobj.module));
                                // }
                                return;//refreshlistmodules.push(CrmPopup.getlastPopupObjByPageType('listpage').module);
                            }
                        }else{
                            //duan20240124 推进和审批小编辑触发布局规则后进入大编辑操作
                            if (!empty(popupobj.paramsobj) &&!empty(popupobj.paramsobj.miniedit_fieldrule)) {
                                if(popupobj.paramsobj.miniedit_fieldrule == 'fromadvance' && prevpopupobj.pagetype == 'advancepopup'){
                                    //推进小编辑触发布局规则判断进入大编辑后需要关闭弹窗
                                    prevpopupobj.CancelEvent();
                                }else if(popupobj.paramsobj.miniedit_fieldrule == 'fromapprove'){
                                    //审批小编辑触发布局规则判断进入大编辑后需要关闭保存窗口并重新执行审批操作,不能直接通过,因为可能存在保存后依旧不符合条件的情况
                                    popupobj.CancelEvent();
                                    saveApproveLog();
                                    return false;
                                }
                            }
                        }
                        if (prevpopupobj.type == 'home' && popupobj.homestuffid !=undefined ){
                            var popupobj=CrmPopup.getPopupObj("last");
                            popupobj.CancelEvent();
                            if(ld('#stuff_'+popupobj.homestuffid).length>0){
                                loadStuff(popupobj.homestuffid,popupobj.homestufftype);
                            }
                            return false;
                        }
                        if (prevpopupobj.type == 'calendarview') {
                            //日程管理视图
                            //ls 2022-04-02 0050719: (通用账套)日程管理(日历视图)保存并提交审批失败
                            ld("#" + popupobj.divid + ' [name=frmsubmitapprove]').find("input[name=idstring]").val(data.result.fieldvalue.maintable_id);
                            if (popupobj.issavesubmit == 'yes')
                                Detail_save_submitapprove();//保存并提交

                            //33003: 日程管理-日历视图--“日周月”界面： 新增日程管理弹出层，保存后不要进入明细界面，应该留在当前界面
                            updateEventData();

                            return false;
                        }
                        if (prevpopupobj.module == 'WriteDailyReport') {//36606: （1.6）写报告>当日数据参考>点击右边的新建按钮：结果把这一行收缩起来了而不是打开新建界面。（需要补丁）
                            window.location.reload();
                            return false;
                        }
                        //单据编号重复提示
                        if (savedata.result.haigesavetip != undefined && savedata.result.haigesavetip != '') {

                            //海格保存的提示审批流程
                            RemindsMsg("", "LdPopWidth400px", module, "", "", savedata.result.haigesavetip);
                        }
                        ld("#" + popupobj.divid + ' [name=frmsubmitapprove]').find("input[name=idstring]").val(data.result.fieldvalue.maintable_id);

                        if (prevpopupobj.type == selectDataPopup.type && popupobj.module == 'Products') {
                            var cur_row = 1;
                            //037081: 合同订单-新增/编辑-选择产品-快速创建：快速创建产品-关闭弹出层之后应该将产品带出来
                            if (popupobj.issavesubmit == 'yes')
                                Detail_save_submitapprove();//保存并提交

                            else
                                popupobj.CancelEvent();//关闭快速创建

                            var tmpobj = CrmPopup.getPopupObj('last');//选择产品的界面


                            //35053: （1.6登录）选择“产品管理”弹出层界面：快速创建产品管理保存时，产品管理字段应直接显示快速创建的新产品字段值（报价单模块测试）
                            if (tmpobj.type == "relatedpagelist") {
                                //相关信息选择产品,例如销售机会查看界面
                                var recordid = CrmPopup.findHtmlobj(prevpopupobj.divid, 'recordid').val();
                                add_data_to_relatedlist(data.result.fieldvalue.maintable_id, recordid, popupobj.module);
                                tmpobj.CancelEvent();
                            } else {

                                if (edit_createPopupobj != undefined && edit_createPopupobj.divid != undefined) {
                                    cur_row = CrmPopup.findHtmlobj(edit_createPopupobj.divid, 'curr_row').val();
                                    //tmpobj.CancelEvent();
                                }
                                //edit:can 2020-11-23 43259: （本地php54，8.3.0版本）首页-快速创建-合同订单（需要补丁）；合同订单新

                                edit_createPopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);// 编辑或新增界面
                                var fun_selectproduct_obj = edit_createPopupobj.selectproductobj;

                                fun_selectproduct_obj.quick_product = true;
                                fun_selectproduct_obj.getProductInfo(cur_row, data.result.fieldvalue.maintable_id);


                            }
                            return false;
                        }


                        if (popupobj.issavesubmit == 'yes')
                            Detail_save_submitapprove();//保存并提交

                        else
                            edit_createPopupobj.CancelEvent();//关闭新增/编辑/复制界面
                        if (prevpopupobj.type == RelateListPage.type && prevpopupobj.balanceaccountobj != undefined) {
                            //往来对账
                            prevpopupobj.module = popupobj.module;

                        }

                        workflowCallApiPop(data.result);

                        if (popupobj.record > 0) {


                        } else {
                            //列表界面相关信息界面新增

                            if (popupobj.isduplicate == 'yes') {
                                //复制   前一页类型为详情页，并且当前编辑页的module等于详情页的module才等于复制，否则应为：前一页为详情页，当前页为相关信息模块点击浮出的新建按钮所新增的编辑页（非复制按钮新增）
                                // @edit:liushuai,2021-03-12,reason:【ID1001092】模块明细界面，相关信息增加可直接创建窗口(更新模块相关信息数量)

                                if (prevpopupobj.type == DetailViewPage.type) {
                                    if (popupobj.module == prevpopupobj.module) { //复制
                                        if (module == 'Reminds' && popupobj.module == "Reminds"){//BUG0074864 xxy 2023-11-2 提醒中复制单据刷新了详情页,直接显示新建的单据详情,导致新建的提醒就已经已读了

                                        }else{
                                            prevpopupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID
                                            var popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                                            popupobj.record = prevpopupobj.record;
                                        }
                                    } else {  //新建
                                        //详情页创建相关信息后刷新页面
                                        //合同订单管理创建服务合同，服务合同保存后，无法立即创建回款计划
                                        popupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID
                                        DetailViewRelation.getRelatedCount(prevpopupobj);//获取相关信息数量
                                    }
                                } else {
                                    //ls 2022-06-24 BUG0053171 (V8.4.6.6.3 http://szlhzs.gnway.cc）合同订单模块，参数中开启了新增保存后立即创建收款计划，现在新增合同保存后弹出收款计划整个页面直接卡住，只有刷新页面才能继续操作。
                                    popupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID
                                }


                            }
                            //详情页创建跟进记录后更新进度追踪图 推进弹出层创建相关单据后更新弹出层信息
                            if (prevpopupobj.pagetype == 'detailview_modulepage' || prevpopupobj.pagetype == 'advancepopup') {
                                //zkt 20230411 销售线索升级应不刷新详情页 BUG0064582 线索转客户和销售机会问题 
                                if(!(prevpopupobj.module == 'Leads' && popupobj.upgradetomodule != undefined && popupobj.upgradetomodule != '')){
                                    if(prevpopupobj.AdvanceStageobj!=undefined)
                                    prevpopupobj.AdvanceStageobj.RefreshPopup(prevpopupobj, popupobj);
                                }
                            }
                            // popupobj.record=data.result.fieldvalue.maintable_id;//保存的单据ID


                        }

                        var tmparra = new Array();
                        tmparra.push(popupobj.record);

                        //销售机会看板试图
                        var iskanbanshow=ld('#iskanbanshow').val();
                        if(iskanbanshow=='yes'){

                            var browserwidth=window.innerWidth;
                            var pageleftwidth=ld("#pageleft_unfold").css('width');
                            var browserheight=window.innerHeight;
                            var pagetopheight=ld("#pagehead").css('height');

                            pageleftwidth=browserwidth-parseFloat(pageleftwidth)+'px';
                            var main_grid_topheight=0;
                            if(ld("#ListViewNavBarAndBtn").length>0){
                                main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
                            }
                            if(ld("#ListViewBtnAndSeach").length>0){
                                main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
                            }
                            pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-10-50+'px';//10：头部间隔。50看板列头
                            var surl = '';
                            //参数用与判断是否是数据分类转为模块  禁用数据分类下拉框及隐藏 数据分类设置
                            var listpage_popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            				if(listpage_popupobj != undefined && listpage_popupobj.linkmodulecustom == 'yes'){
                                surl += '&ajaxtype=ld_linkmodulecustom';
                            }
                            surl += '&viewid='+ld("#viewname").val();
                            surl += '&viewname='+ld("#viewname").val();
                            var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=ListView&viewmode=kanban&kanbanajax=true&pageleftwidth='+pageleftwidth+'&pagetopheight='+pagetopheight+surl;
                            ldAjax(urlstring,"",function(data){
                                if(data.code==1){
                                    // data.result.refreshdetailmodules.push(popupobj.module);
                                    ld('#ListViewContents').html(data.result);
                                    DelProgressObjs();
                                }
                            })

                            return;//看板树结构计数

                        }else
                        var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
                        //新增刷新列表
                        if (popupobj.module == 'Accounts' && prevpopupobj.type == 'maplist') {
                            data.result.refreshlistmodules.push(popupobj.module);
                        }
                        else if (popupobj.module == 'SalesOrder' && prevpopupobj.module == 'Quotes') {
                            //报价单列表，勾选单据点击【合并创建销售订单】保存后，报价单列表界面没有刷新
                            data.result.refreshlistmodules.push(prevpopupobj.module);
                        }
                        //销售线索推进 - 客户
                        if (module == 'Accounts' && prevpopupobj.module == 'Leads') {
                            //zkt 20230515 BUG0066265 线索升级成客户以后，线索界面的当前线索不会消失，
                            data.result.refreshlistmodules.push(prevpopupobj.module);
                            prevpopupobj.CancelEvent();
                            var upgradetomodule = popupobj.upgradetomodule;
                            //duan 2022-2-14 销售线索增加'升级到客户和销售机会选项'客户保存后判断是否需要创建销售机会
                            if (upgradetomodule != undefined && upgradetomodule != '') {
                                var objparams = new CreatePagePopup.params();
                                var tmpurl = "&fromid=" + data.result.fieldvalue.maintable_id + "&frommodule=" + module + "&relatedcreate=yes";
                                tmpurl += "&upgradetomodule=" + upgradetomodule + "&upgradestatus=" + popupobj.upgradestatus;
                                objparams.params['refreshpage'] = 'no';
                                objparams.params['relatedcreate'] = 'yes';
                                CreatePagePopup.showpage(upgradetomodule, tmpurl, objparams);
                            }
                            
                        }
                        var refreshlistmodules = data.result.refreshlistmodules;
                        //40683: （http://www.51mis.com/demo/panlulu15/演示账套 [^]）客户管理->客户查看详情界面，相关信息->出库单界面，编辑单据保存后，该界面列值行错位
                        refreshlistmodules.push(popupobj.module);
                        if (prevpopupobj.type == DetailViewPage.type) {
                            refreshlistmodules.push(prevpopupobj.module);//相关信息新建保存后，刷新列表页(列表页和详情页为同一module)
                        }
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            if (!data.result.refreshdetailmodules.includes(popupobj.module)) {
                                //刷新查看界面，联系人保存
                                data.result.refreshdetailmodules.push(popupobj.module);

                            }


                            tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);

                            //zkt 20221027 XUQIU1000463 灵当CRM详细需求-PC端_移动端：相关信息-联系人列表增加“联系人图谱”
                            tmpobj.eachrefreshModuleMapViewByModules(data.result.refreshdetailmodules);

                        if (popupobj.record > 0) {
                            var tmpglobaluitype = prevpopupobj.globaluitype;
                            if (prevpopupobj.type == DetailViewPage.type) {
                                itsonview = false;//edit:can 2020-10-10 中孚合同点击查看界面的编辑按钮，修改有布局规则的字段内容，后保存，则查看界面会出现小编辑
                                // prevpopupobj.globaluitype='';
                            }

                            tmpobj.update();//更新界面字段

                            // prevpopupobj.globaluitype=tmpglobaluitype;
                        }

                        //wyt 221116 XUQIU1000658 关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮
                        if (prevpopupobj != undefined && prevpopupobj.type == selectSearchPopup.type) {
                            //BUG20240112-13  ls 240119 原因是requestvalue过长导致请求失败，应该放到body里；但最终修改为不需要发起该请求，故先注释请求代码
                            SaveDataRecord.afterSave_setPrevPopupValue(data);
                            /*popupobj.record = data.result.fieldvalue.maintable_id;
                            var posturl = prevpopupobj.reload_showrelationlistobj.posturl;
                            posturl += "&quickcreate=yes&recordid=" + data.result.fieldvalue.maintable_id;
                            ldAjaxNoProgresssync('index.php',posturl,function (tmpdata) {////当requestvalues过多时,就无法请求成功,应当放在body里
                                if (tmpdata.code == 1) {
                                    SaveDataRecord.afterSave_setPrevPopupValue(data);
                                } else if (tmpdata.code == -1) {
                                    prevpopupobj.CancelEvent();
                                }
                            });*/
                        }
                        CrmPopup.start_progressObjs.push(new Object());
                        tmpobj.System_deploySaveByModule(popupobj);
                        DelProgressObjs();
                        delete tmpobj;

                        // popupobj.CancelEvent();
                        //38461: （51mis.com/kfbcrm）客户管理>联系人(列表)>新建联系人界面，当“联系人编号”重复自动生成新的编号，应弹出提示信息：“编号已存在，系统将自动生成一个新的编号”。
                        setdupBillNoTip(data.result.modulebillnotip, fields);
                    }
                
                    else {
                        //工作协同，创建日程
                        if (popupobj != undefined && popupobj.type == 'cooperativework_create') {
                            popupobj.CancelEvent();
                            intStart();
                        }
                        //购物车创建合同订单和服务合同 //zxm @date:2024/10/24 @reason: 去掉 改成后端删购物车  前端刷新 UpdateShopCartNew
                        /*if (popupobj != undefined && popupobj.detailfieldmodule == 'Products' && (popupobj.module == 'SalesOrder' || popupobj.module == 'ServiceContracts')) {
                            popupobj.CancelEvent();
                            //更新购物车信息
                            UpdateShopCart(productdetailurl);
                        }*/
                    }
                    if (typeof edit_createPopupobj.after_save != "undefined")
                        edit_createPopupobj.after_save();//通过自定义保存函数，例如选择产品套餐调整界面

                    // ljj 20231214 BUG0077226 成员管理-编辑个人头像并保持后，系统管理员的头像也会发生相应的改变，刷新又正常了。
                    //@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片(单据编辑个人头像后保存)
                    if (popupobj.module == 'Users' && !empty(ld('#' + CrmPopup.getPopupObj("last").divid + ' [name=dtlview_imagename] img').attr('src')) && popupobj.record == CURRENT_USER_ID) {//在系统设置里修改没有弹出层
                        ld('#oamenubar .user-icon').css("background-image", "url(" + ld('#' + CrmPopup.getPopupObj("last").divid + ' [name=dtlview_imagename] img').attr('src') + ")"); //右上角头像动态更新
                    }
                    // wym 240529 BUG20240506-48 成员管理人员名称修改了之后，右上角个人信息显示名称不能自动变更
                    if (popupobj.module == 'Users' && ld('#oamenubar .user-name').length>0 && !empty(data.result.aftersave_username) && popupobj.record == CURRENT_USER_ID) {
                        ld('#oamenubar .user-name').text(data.result.aftersave_username); //右上角成员名称动态更新
                    }
                    //克莱门特定制开发需求：报损单保存后，自动弹出关联创建“故障工时”的单据
                    if (version_account != undefined && version_account == 'climaveneta' && popupobj.module == 'Quotes') {
                        var surl = 'index.php?module=Quotes&action=QuotesAjax&file=getRelatedForCmta&fromid=' + popupobj.record;
                        ldAjaxNoProgress(surl, {}, function (ajaxdata) {
                            if (ajaxdata.code == '1') {
                                var objparams = new CreatePagePopup.params();
                                objparams.params['refreshpage'] = 'no';
                                objparams.params['relatedcreate'] = 'yes';
                                objparams.params['relatedcreate'] = 'yes';
                                var tmpurl = "&fromid=" + popupobj.record + "&frommodule=" + popupobj.module + "&relatedcreate=yes";
                                CreatePagePopup.showpage('CustomForm45', tmpurl, objparams);
                            }
                        });
                    }
                } else {
                    var btnobj = popupobj.getbtnOkobj();
                    btnobj.disabled = false;

                    ld('#rptContentLoading').hide();
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "", data.msg);
                    DelProgressObjs();
                }
            }
        });
    });
}
SaveDataRecord.cancel = function () {
    //编辑页取消时，关闭定时器
    if (isAvailablelocalStorage) {
        SaveDataRecord.cancelInterval();
        // var Popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
        var Popupobj = CrmPopup.getPopupObj("last");
        var regex = /_.+_create_\d+_/;//暂存缓存的正则
        var oldStorageKey = getCurrentUrlSite(false)+'_'+Popupobj.module+'_create_'+CURRENT_USER_ID+'_old';
        //zkt 20230110 BUG0060571产品管理，购物车，点击新建合同订单，点击取消按钮点不动
        var tmpStorageKey = getCurrentUrlSite(false)+'_'+Popupobj.module+'_create_'+CURRENT_USER_ID+'_tmp';
        var newStorageKey = getCurrentUrlSite(false)+'_'+Popupobj.module+'_create_'+CURRENT_USER_ID+'_new';
        //取消时，如果新页面有缓存，则将新页面复制给旧页面，再删除新页面(此時只保留旧頁面的值)。
        var finished = 'no';
        var circle_len = 0;
        var max_circle_len = 10;
        if (!empty(localStorage.getItem(newStorageKey))) {
            while (finished == 'no' && circle_len < max_circle_len) {
                try {
                    localStorage.setItem(oldStorageKey, localStorage.getItem(newStorageKey));
                    localStorage.removeItem(newStorageKey);
                    //localStorage.removeItem(tmpStorageKey);//晓梅加了强制刷新浏览器及关闭浏览器的提示事件,因此这个中间变量tmpStorageKey可以先去掉了

                    //BUG0062471 存储的值为undefined,导致后面取值时报错
                    if (!empty(localStorage.getItem(newStorageKey + '_productdetail'))) {
                        
                        localStorage.setItem(oldStorageKey + '_productdetail', localStorage.getItem(newStorageKey + '_productdetail'));
                        localStorage.removeItem(newStorageKey + '_productdetail');
                    }
                    finished = 'yes';
                } catch (e) {
                    if (e.name === 'QuotaExceededError') {
                        removeOldStorage(Popupobj);
                    }
                }
                circle_len++;
            }

        }
        window.removeEventListener("beforeunload",addwindowlistener);//关闭浏览器监听
    }
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    if (prevpopupobj && prevpopupobj.type == 'calendarview') {
        //日程管理视图
        calendar.refetchEvents();
    }

}
SaveDataRecord.cancel.funname = "SaveDataRecord.cancel";
//取消缓存定时器
SaveDataRecord.cancelInterval = function () {
    if (isAvailablelocalStorage) {
        if (create_storage_timer !== null) {
            clearInterval(create_storage_timer);
            // console.log('定时器取消');
            create_storage_timer = null;
        }
    }
}
//data:保存后返回json,目前是选择框上的快速创建，例如联系人编辑界面选择客户，然后点击快速创建
SaveDataRecord.afterSave_setPrevPopupValue = function (data) {
    //选择框弹出层界面的快速创建
    //var popupobj = CrmPopup.getPopupObj("last");
    var selectsearchpopupobj = CrmPopup.getPopupObj("last");//获取选择框
    var prevmodule = data.result.fieldvalue.record_module;//获取选择查询的模块
    var prev_prevpopupobj = CrmPopup.getPopupObj("lastprev");//编辑或新建界面
    if(empty(prev_prevpopupobj))return '';
    var findreference = 'no';
    if (prev_prevpopupobj.type == CreatePagePopup.type
        || prev_prevpopupobj.type == PageRecordPopup.type
        || prev_prevpopupobj.type == 'moduledetailpage') {
        var fields = popupobj.fields;
        //zkt 20240123 BUG20240123-64 卫元：选择关联单据快速创建后无法选到
        if (selectsearchpopupobj.selectfieldtype == 'detailfield' && !empty(selectsearchpopupobj.detailcolumnname) && !empty(selectsearchpopupobj.rowindex)) {
            var prepopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
            var tableobj = prepopupobj.getDetailTableObj();
            var rowobj = ld(tableobj).find("tr[rowindex=" + selectsearchpopupobj.rowindex + "]");
            if (ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname).length > 0) {
                ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname ).val(data.result.fieldvalue.maintable_id);
                ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name").get(0).value = data.result.fieldvalue[data.result.fieldhrefname];
                ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name").get(0).disabled = true;
                ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name" ).get(0).style.cursor = 'not-allowed';
                selectsearchpopupobj.CancelEvent();
                findreference = 'yes';
            }

        }
        else{
            for (var i = 0; i < prev_prevpopupobj.fields.length; i++) {


                if (prev_prevpopupobj.fields[i].referencemodule == prevmodule) {
                    var fieldname = prev_prevpopupobj.fields[i].fieldname;
                    //表体 - 关联选择单据，快速创建
                    if (selectsearchpopupobj.selectfieldtype == 'detailfield' && !empty(selectsearchpopupobj.detailcolumnname) && !empty(selectsearchpopupobj.rowindex)) {
                        var prepopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
                        var tableobj = prepopupobj.getDetailTableObj();
                        var rowobj = ld(tableobj).find("tr[rowindex=" + selectsearchpopupobj.rowindex + "]");
                        if (ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname).length > 0) {
                            ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname ).val(data.result.fieldvalue.maintable_id);
                            ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name").get(0).value = data.result.fieldvalue[data.result.fieldhrefname];
                            ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name").get(0).disabled = true;
                            ld(rowobj).find(' #' + selectsearchpopupobj.detailcolumnname+"_name" ).get(0).style.cursor = 'not-allowed';
                        }
                        selectsearchpopupobj.CancelEvent();
                    } else {
                        //edit:can 20210728 47150: （http://maarscrm.xicp.vip:38060/crm [^]）客户问题（邬丹华），项目报备（原“销售机会”模块）新建界面，“项目类型”字段选择“经销”，“经销商”字段选择客户，“终端用户全称”字段快速创建客户后，“经销商”字段选择的客户被替换了
                        if (fieldname != selectsearchpopupobj.reload_showrelationlistobj.fieldname)
                            continue;
                        CrmPopup.setHtmlobjval(prev_prevpopupobj.divid, prev_prevpopupobj.fields[i].fieldname, data.result.fieldvalue.maintable_id);
                        CrmPopup.setHtmlobjval(prev_prevpopupobj.divid, fieldname + "_name", data.result.fieldvalue[data.result.fieldhrefname]);
                        // popupobj.CancelEvent();//关闭快速创建界面
                        //38122: （51mis.com/kfbcrm）合同订单模块：合同订单页面增加了引用联系人的字段，选联系人的时候会自动带出。但是合同订单页面通过快速创建联系人时不会自动带出
                        selectrelateds(prevmodule, '', data.result.fieldvalue.maintable_id, data.result.fieldvalue[data.result.fieldhrefname], fieldname, '', prev_prevpopupobj.module, '');
                    }
                    findreference = 'yes';
                    break;
                }
            }
        }
        if (findreference == 'no') {
            //popupobj.CancelEvent();//关闭快速创建界面
            selectsearchpopupobj.CancelEvent();//关闭选择框界面
        }

    } else {
        //群发邮件界面

        //哪位开发人员得到该bug请到module/mail/mail.js添加该函数
        // setEmailValue();//全局查找已经没有此方法
    }

}
/**
 判断是否为附件类型字段
 **/
SaveDataRecord.isfileattachUitype = function (uitype) {
    if (uitype == 28 || uitype == 1109 || uitype == 69 || uitype == 1108 || uitype == 105) {

        return true;
    } else {
        return false;
    }

}
SaveDataRecord.getFileAttachmenturl = function (fieldinfo, divid) {
    var htmlurl = "";
    var fieldname = fieldinfo.fieldname;
    if (fieldinfo.uitype == 28 && CrmPopup.getHtmlobjval(divid, 'filelocationtype') == "E") {
        htmlurl += "&" + fieldname + "_E__" + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "_E__"));
    } else if (CrmPopup.isExistsObj(divid, fieldname + '-file_num')) {
        var filenum = CrmPopup.getHtmlobjval(divid, fieldname + '-file_num');
        if (filenum > 0) {
            var tmpfilenum = 0;
            for (var k = 1; k <= 220; k++) {
                //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/2/26 23:00
                if (CrmPopup.isExistsObj(divid, fieldname + "-file_name_" + k)) {
                    htmlurl += "&" + fieldname + "-file_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_name_" + k));
                    htmlurl += "&" + fieldname + "-file_type_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_type_" + k));
                    htmlurl += "&" + fieldname + "-file_size_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_size_" + k));
                    htmlurl += "&" + fieldname + "-file_path_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_path_" + k));
                    htmlurl += "&" + fieldname + "-newfile_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-newfile_name_" + k));
                    htmlurl += "&" + fieldname + "-upload_from_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-upload_from_" + k));
                    // alert(globalWebUploadType);
                    //考虑历史数据
                    var storage_location = CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k)
                    // if (storage_location == 'cos') {
                        htmlurl += "&" + fieldname + "-cloud_path_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-cloud_path_" + k));
                    // }
                    htmlurl += "&" + fieldname + "-storage_location_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k));
                    var imagefromtype = CrmPopup.getHtmlobjval(divid, fieldname + "-imagefromtype_" + k);
                    imagefromtype = empty(imagefromtype)?'':imagefromtype;
                    htmlurl += "&" + fieldname + "-imagefromtype_" + k + "=" + encodeURIComponent(imagefromtype);
                    htmlurl += "&" + fieldname + "-isEncrypt_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-isEncrypt_" + k));
                    tmpfilenum++;
                }

            }

            htmlurl += "&" + fieldname + "-file_num=" + tmpfilenum + "&" + fieldname + "&-attachmentcolumnname=" + fieldinfo.columnname;
        }
    } else {


    }
    return htmlurl;
}
// ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(分录图片保存时生成入参url)
//edit: xll 2023/06/25 XUQIU1000357 单据分录增加附件字段(分录保存时将附件字段信息写入url)
SaveDataRecord.getDetailFileurl = function (detailfieldinfo, divid, rowindex) {
    var htmlurl = "";
    //为了区分分录行图片信息。拼接url的时候需要加上行号，因为每一行的同一字段的图片信息name是一样
    var fieldname = detailfieldinfo.fieldname;
    var newfieldname = detailfieldinfo.fieldname + rowindex;//字段名 + 行号
    if (ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_num]").val()) {
        var filenum = ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_num]").val();
        if (filenum > 0) {
            var tmpfilenum = 0;
            for (var k = 1; k <= 220; k++) {
                //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/2/26 23:00
                if (ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_name_" + k + "]") != undefined && ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_name_" + k + "]").length > 0) {
                    htmlurl += "&" + newfieldname + "-file_name_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_name_" + k + "]").val());
                    htmlurl += "&" + newfieldname + "-file_type_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_type_" + k + "]").val());
                    htmlurl += "&" + newfieldname + "-file_size_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_size_" + k + "]").val());
                    htmlurl += "&" + newfieldname + "-file_path_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-file_path_" + k + "]").val());
                    htmlurl += "&" + newfieldname + "-newfile_name_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-newfile_name_" + k + "]").val());
                    htmlurl += "&" + newfieldname + "-upload_from_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-upload_from_" + k + "]").val());
                    // alert(globalWebUploadType);
                    //考虑历史数据
                    var storage_location = ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-storage_location_" + k + "]").val();
                    if (storage_location == 'cos') {
                        htmlurl += "&" + newfieldname + "-cloud_path_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-cloud_path_" + k + "]").val());
                    }
                     
                    htmlurl += "&" + newfieldname + "-storage_location_" + k + "=" + encodeURIComponent(ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-storage_location_" + k + "]").val());
                    var imagefromtype = ld("#" + divid + " tr[rowindex=" + rowindex + "] [name=" + fieldname + "-imagefromtype_" + k + "]").val();
                    imagefromtype = empty(imagefromtype)?'':imagefromtype;
                    htmlurl += "&" + newfieldname + "-imagefromtype_" + k + "=" + encodeURIComponent(imagefromtype);
                    //edit:can 20230615 68299 户费用报销单据里分录里面的附件图片，加载不出来，
                    htmlurl += "&" + newfieldname + "-isEncrypt_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-isEncrypt_" + k));
                    tmpfilenum++;
                }

            }
            //edit: xll 2023/06/25  BUG0069656 kfbcrm-销售退货单-单据分录-新增附件字段，设置为必填，不生效
            if(htmlurl.length != 0 && htmlurl != '')
                htmlurl += "&" + newfieldname + "-file_num=" + tmpfilenum + "&" + newfieldname + "&-attachmentcolumnname=" + detailfieldinfo.columnname;
        }
    } else {


    }
    return htmlurl;
}
//zkt 20230822 XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据
//新增、编辑界面附件保存
SaveDataRecord.getDetailFileurlNew =function(detailfieldinfo,popupobj,rowindex){
    var htmlurl = '';
    if(popupobj != undefined){
        if(!empty(popupobj.detailfilejsondata)&&popupobj.pagetype == 'create_edit_modulepage'){
            var fieldname = detailfieldinfo.fieldname;
            var tmpcolumnname = detailfieldinfo.columnname;
            var newfieldname = detailfieldinfo.fieldname + rowindex;//字段名 + 行号
            if(popupobj.detailfilejsondata[rowindex] != undefined &&  popupobj.detailfilejsondata[rowindex][tmpcolumnname] != undefined){
                if(popupobj.detailfilejsondata[rowindex][tmpcolumnname].length>0){
                    var tmpjsondata_arr =popupobj.detailfilejsondata[rowindex][tmpcolumnname];//字段所在行要获取保存的信息
                    for(var tmpi=0;tmpi<tmpjsondata_arr.length;tmpi++){
                        var tmpfiledata = tmpjsondata_arr[tmpi];
                        var tmpfilerowindex = tmpfiledata['filerowindex'];//上传文件对应的文件行号
                        ld.each(tmpfiledata,function(tmpindex,tmpitem){
                            htmlurl += "&" + newfieldname + "-"+tmpindex+"_" + tmpfilerowindex + "=" +encodeURIComponent(tmpitem);
                        })
                    }
                    if(htmlurl.length != 0 && htmlurl != '')
                        htmlurl += "&" + newfieldname + "-file_num=" + tmpjsondata_arr.length + "&" + newfieldname + "&-attachmentcolumnname=" + detailfieldinfo.columnname;
                }
            }
            
        }
        else if(popupobj.divid != undefined){
            htmlurl=SaveDataRecord.getDetailFileurl(detailfieldinfo,popupobj.divid,rowindex);
        }
    }
    return htmlurl;
}

function showType() {

    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var filelocationtype = CrmPopup.findHtmlobj(divid, "filelocationtype").find("option:selected").val();

    var E_file_Value = CrmPopup.findHtmlobj(divid, "hidetext").val();
    var newfilenames = popupobj.docfilename;

    if (filelocationtype == 'I') {

        CrmPopup.findHtmlobj(divid, newfilenames + '_I__').css("display", "block");
        CrmPopup.findHtmlobj(divid, newfilenames + '_E__').css("display", "none");
    } else if (filelocationtype == 'E') {
        CrmPopup.findHtmlobj(divid, newfilenames + '_I__').css("display", "none");
        CrmPopup.findHtmlobj(divid, newfilenames + '_E__').css("display", "block");
    }
}

function changeDldType(type, onInit) {
    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var filenames = popupobj.docfilename;
    var v1 = type;

    if (v1 == 'file') {
        CrmPopup.findHtmlobj(divid, filenames + '_E__').val("");
        CrmPopup.findHtmlobj(divid, filenames + '_I__').css("display", "block");
        CrmPopup.findHtmlobj(divid, filenames + '_E__').css("display", "none");
    } else if (v1 == 'text') {
        CrmPopup.findHtmlobj(divid, filenames + '_I__').css("display", "none");
        CrmPopup.findHtmlobj(divid, filenames + '_E__').css("display", "block");
    }
}

//editor:gyq_161 reason:模块源单分录保存   2019/11/26 17:33
SaveDataRecord.gettabdetailfieldurl = function (url) {
    var popupobj = CrmPopup.getPopupObj('last');
    var trobjs = popupobj.getTrObjsByDelType("no")//获取没有删除的行
    var ret = true;
    var rowcnt = ld(trobjs).length;// ld("#" + popupobj.divid + " [name=rowcnt]").val();
    //duplicateid:被复制的单据id

    var url = '&rowcnt=' + rowcnt + "&duplicateid=" + ld("#" + popupobj.divid + " [name=duplicateid]").val();
    var detailhidecolumns = popupobj.detailhidecolumns;

    var hidden_arr = [];
    ld.each(popupobj.detailfields, function (tmpindex, tmpfieldinfo) {
        if(ld('#'+popupobj.divid+' #proTab td[head_detailfieldname='+tmpfieldinfo.columnname+']:visible').length === 0){
            hidden_arr.push(tmpfieldinfo.columnname);
        }
    });

    ld.each(ld(trobjs), function () {
        var rowindex = ld(this).attr("rowindex");
        var rowobj = ld(this);
        if (ld(this).find(" [name=" + popupobj.detailtableindex + ']').length > 0) {
            url += "&" + popupobj.detailtableindex + rowindex + "=" + ld(this).find(" [name=" + popupobj.detailtableindex + ']').val();
        }
        url += "&deleterow" + rowindex + "=0&hidden_rowid_" + rowindex + '=0';
        if (version_account == 'langjie' && popupobj.module == 'Commission') {
            url += "&parent_lineitem_id" + rowindex + "=" + ld(this).find(" #parent_lineitem_id").val();
        }else{
            //zxm 20240926 编辑保存加上lineitem_id和parent_lineitem_id
            if(ld(this).find(" [name=lineitem_id]")&&ld(this).find(" [name=lineitem_id]").val()){
                url += "&lineitem_id" + rowindex + "=" + ld(this).find(" [name=lineitem_id]").val();
            }
            if(ld(this).find(" [name=parent_lineitem_id]")&&ld(this).find(" [name=parent_lineitem_id]").val()){
                url += "&parent_lineitem_id" + rowindex + "=" + ld(this).find(" [name=parent_lineitem_id]").val();
            }
        }

        if (!empty(popupobj.detailfields) && popupobj.detailfields.length > 0) {
            ld.each(popupobj.detailfields, function (tmpindex, tmpfieldinfo) {

                var tablename = tmpfieldinfo.tablename;
                var fieldtype = tmpfieldinfo.fieldtype;
                var typeofdata = tmpfieldinfo.typeofdata;
                var typeofdatas = typeofdata.split('~');

                if (tablename == popupobj.detailtablenamescf || tablename == popupobj.detailtablename) {


                    var tmpname = tmpfieldinfo.columnname;
                    //edit:can 2020-09-10 明细字段布局规则，隐藏的必填字段不需要提示
                    if (detailhidecolumns != undefined && ld.inArray(tmpname, detailhidecolumns) >= 0) {
                        return true;
                    }
                    //没查看权限字段不判断必填
                    if(hidden_arr.includes(tmpname)){
                        typeofdatas[1] = 0;
                    }
                    var paramname = tmpname + rowindex;

                    if (tmpfieldinfo.fieldtype == 'SelectComBox') {

                        //多选框
                        var tmpobj = ld(rowobj).find(" #" + tmpname );
                        if(tmpobj.attr("multiple")!=undefined) {
                            var strtmp = getMultiPickListSelectValueByObj(tmpobj);
                        }else{
                            var strtmp = tmpobj.val();
                        }

                        if (typeofdatas[1] == 'M' && ld.trim(strtmp) == '') {
                            var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                            audioRemindsMsg("", "", module, "", "", confirm_str);
                            ld(tmpobj).focus();
                            emptyCheckObj(tmpobj, tmpfieldinfo.fieldtype);
                            ret = false;
                            return false;
                        }
                        url += "&" + paramname + "=" + encodeURIComponent(strtmp);
                    }else if(tmpfieldinfo.fieldtype == 'Image' || tmpfieldinfo.fieldtype == 'Attachment')
                    {//收款单源单为产品分录字段时，没有fieldtype属性，tmpfieldinfo.fieldtype为null，因此不能调用toLocaleLowerCase()，会报错
                        //ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(非产品分录保存时将图片信息写入url)
                        //edit: xll 2023/06/25 XUQIU1000357 单据分录增加附件字段(非产品分录保存时将附件信息写入url)
                        var file_url = SaveDataRecord.getDetailFileurlNew(tmpfieldinfo, popupobj, ld(rowobj).attr('rowindex'));
                        if((file_url == undefined || file_url == '' || file_url.length == 0) && typeofdatas[1] == 'M'){
                            var confirm_str = tmpfieldinfo.fieldlabel+arrJsPopLabel['CANOTEMPTY'];

                            audioRemindsMsg("","","","","",confirm_str);
                            ret = false;
                            return false;
                        }
                        else
                            url += file_url;
                    } else {
                        if (tmpname == 'entitytype') {
                            tmpname = 'select_entitytypeid';
                        }
                        var tmpobj = ld(rowobj).find(" #" + tmpname );
                        var value = ld(tmpobj).val() || '';
                        if (typeofdatas[1] == 'M') {

                            if ((tmpfieldinfo.fieldtype == 'SelectSource' || tmpfieldinfo.fieldtype == 'Reference') && (ld.trim(ld(tmpobj).val()) == 0 || ld.trim(ld(tmpobj).val()) == '')) {
                                var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                                audioRemindsMsg("", "", module, "", "", confirm_str);
                                ld(tmpobj).focus();
                                emptyCheckObj(tmpobj, tmpfieldinfo.fieldtype);
                                ret = false;
                                return false;
                            } else if (ld.trim(ld(tmpobj).val()) == '') {
                                var confirm_str = tmpfieldinfo.fieldlabel + arrJsPopLabel['CANOTEMPTY'];
                                audioRemindsMsg("", "", module, "", "", confirm_str);
                                ld(tmpobj).focus();
                                emptyCheckObj(tmpobj, tmpfieldinfo.fieldtype);
                                ret = false;
                                return false;
                            }


                        }
                        if(typeofdatas[0] == 'N' || typeofdatas[0] == 'NN'){
                            value = value.toString(); // duan 20240511 replace 方法只有string类型的变量才有，增加格式转换
                            if (value.replace(/^\s+/g, '').replace(/\s+$/g, '').length != 0) {
                                if (value != 0) {
                                    // duan 20231020 单据分录有些字段不能设置小数位数,不能判断数据格式
                                    /*
                                    if (typeof (typeofdatas[2]) == "undefined") var numformat = "any";
                                    else var numformat = typeofdatas[2];
                                    */
                                    var numformat = "any";
                                    if (typeofdatas[0] == "NN") {
                                        if (!detail_numValidate(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, numformat, true,value)){
                                            tmpobj.focus();
                                            audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                            ret = false;
                                            return false;
                                        }
                                    } else if (!detail_numValidate(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, numformat,false,value)){
                                        tmpobj.focus();
                                        audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                        ret = false;
                                        return false;
                                    }
                                    if (typeofdatas[3]) {
                                        if (!detail_numConstComp(tmpfieldinfo.columnname, tmpfieldinfo.fieldlabel, typeofdatas[3], typeofdatas[4],value)){
                                            audioRemindsMsg("", "", module, "", "", tmpfieldinfo.fieldlabel+arrJsPopLabel['FORMATERROR']);
                                            tmpobj.focus();
                                            ret = false;
                                            return false;
                                        }

                                    }
                                }
                            }
                        }
                        if (tmpobj.length > 0) {
                            //zkt 20230712 BUG0069430 http://125.70.13.124:85/crm ；四川丁点儿；登录彭善浩（账户：13266168453 密码：123），新建单据【客户定制需求】，分录字段“是否满足”子段默认值设置为“是”，但是保存后自动变成否 
                            if (fieldtype == 'CheckBox'&&(tmpfieldinfo.edit_permission != undefined && tmpfieldinfo.edit_permission != 1)) {
                                if (ld(tmpobj).prop("checked")) {
                                    url += '&' + paramname + "=1";
                                } else {
                                    url += '&' + paramname + "=0";
                                }
                            } else

                                url += '&' + paramname + "=" + encodeURIComponent(ld(tmpobj).val());
                            if (tmpfieldinfo.fieldtype == 'SelectSource') {
                                url += '&select_entitytypeid' + rowindex + '=' + ld(rowobj).find(" #select_entitytypeid").val();
                            }
                        }


                    }
                   
                }

            })
        }

    })
    if (ret == false) {
        return ret;
    }
    if (popupobj.module == 'CashBill') {
        // alert(ld("#"+popupobj.divid+" [name=cashbill_total]").val());
        url += "&cashbill_total=" + ld("#" + popupobj.divid + " [name=total]").val();
        //zkt 20220919 BUG0056654（http://crm.airmaster.com.cn/crm）8474版本，收款单-收款信息-本次收款金额的字段名是否发生改变？导致所有做的报表、首页销售简报“销售经理确认收款单金额(分配前)”数据统计全部出错。
        if (ld("#" + popupobj.divid + " [name=subtotal]").length > 0 ) {
            var subtotal = 0;
            if( ld("#" + popupobj.divid + " [name=selectsource]").length > 0){
                //未选择源单时subtotal值可能空，仅在客户预收单是才可设置值
                if (ld("#" + popupobj.divid + " [name=selectsource]").val() == '') {
                    if (ld("#" + popupobj.divid + " [name=subtotal]").val() == 0 || ld("#" + popupobj.divid + " [name=subtotal]").val() == '') {
                        subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                    } else {
                        subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
                    }
                }
                url += "&subtotal=" + subtotal;
            }
            else if(popupobj.cashbilltype != undefined && popupobj.cashbilltype == 'cashbill'){
                subtotal = ld("#" + popupobj.divid + " [name=subtotal]").val();
                url += "&subtotal=" + subtotal;
            }

        }
    } else if (popupobj.module == 'SendCashBill') {
        url += "&sendcashbill_total=" + ld("#" + popupobj.divid + " [name=total]").val();
        if (ld("#" + popupobj.divid + " [name=subtotal]").length > 0) {
            var subtotal = 0;
            if(ld("#" + popupobj.divid + " [name=selectsource]").length > 0){
                //未选择源单时subtotal值为，取total的值
                if (ld("#" + popupobj.divid + " [name=selectsource]").val() == '') {
                    subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                }
                url += "&subtotal=" + subtotal;
            }
            else{
                subtotal = ld("#" + popupobj.divid + " [name=total]").val();
                url += "&subtotal=" + subtotal;
            }
        }
    } else {
        url += "&total=" + ld("#" + popupobj.divid + " [name=total]").val();
    }

    return url;

    
}

SaveDataRecord.getQueryVariable = function (rVar, rVariable) {
    for (var i = 0; i < rVar.length; i++) {
        var pair = rVar[i].split("=");
        if (pair[0] === rVariable) {
            return 1;
        }
    }
    return 0;
}

SaveDataRecord.getFieldValue = function (popupobj, fields_arr, savedeskvaluepage) {
    var fieldlen = fields_arr.length;
    var divid = popupobj.divid;
    var tmpurl = '';
    var sensitiverequestfield_arr = [];
    var popupJqObj = ld("#" + divid);
    for (var i = 0; i < fieldlen; i++) {
        var fieldname = fields_arr[i].fieldname;
        var fieldinfo = fields_arr[i];
        var tmpfieldvalue = '';

        if (SaveDataRecord.isfileattachUitype(fields_arr[i].uitype))//附件，图片
        {
            tmpurl += SaveDataRecord.getFileAttachmenturl(fields_arr[i], popupobj.divid);

        } else if (fields_arr[i].uitype == 208) {
            tmpurl += '&selectsource=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'selectsource'));
            tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
        } else if (fields_arr[i].uitype == 202) {
            tmpurl += '&selectsourcename=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'selectsource'));
            tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
        } else if (fields_arr[i].uitype == 112) {
            tmpurl += '&reltab=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'related_to_type'));
            tmpurl += '&' + fieldname + '=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname));
        } else if (fields_arr[i].uitype == 117) {
            //币种
            var elementobj = CrmPopup.findHtmlobj(divid, fieldname);
            tmpfieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
            if(fieldinfo != undefined && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                tmpfieldvalue = fieldinfo.sensitiveencryptvalue;
                sensitiverequestfield_arr.push(fieldname);
            }
            tmpurl += '&' + fieldname + '=' + encodeURIComponent(tmpfieldvalue);
            tmpurl += '&hidden_currency_id=' + encodeURIComponent(CrmPopup.getHtmlobjval(divid, 'hidden_currency_id'));
        } else if (fields_arr[i].uitype == 99) {
            //密码框//zkt 20240524 BUG20240524-35  添加成员，点保存，没动静
            tmpurl += "&" + fieldname + '=' + encodeURIComponent(ld("#" + popupobj.divid + " [name=" + fieldname + "]").val());
        }
        else if (fields_arr[i].uitype == 118){//增加单据来源：PC段
                tmpurl += "&" + fieldname + '=PC';
        }
        else if (CrmPopup.isExistsObj(popupobj.divid, fieldname)) {

            if (fields_arr[i].uitype == 33) {
                //zkt 20220523 52029（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批通过，编辑单据时，不可编辑字段显示界面异常；“多选框”“图片”字段
                if (ld("#" + popupobj.divid + " [name='" + fields_arr[i].fieldname + "[]']").length <= 0) {
                    var strtmp = CrmPopup.getHtmlobjval(popupobj.divid, fieldname);
                } else {
                    var strtmp = getMultiPickListSelectValue(fields_arr[i].fieldname + "[]");
                }

                tmpurl += "&" + fieldname + "=" + encodeURIComponent(strtmp);


            }
            //zkt 20241105 BUG20241104-47 http://1.95.69.17:85/crm ；共同管业；用印申请,编号：ZDYBD06-676>详情页面可以看到字段“ *盖章要求 ”有值，点击编辑>在编辑页面发现就没值了。
            else if (fields_arr[i].uitype == 34) {
                //edit:duan date:2024/10/24 reason:用户模块的职位级别字段特殊处理
                tmpfieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
                tmpurl += "&" + fieldname + "=" + encodeURIComponent(tmpfieldvalue);

                var json_value = CrmPopup.getHtmlobjval(divid, 'jsonvalue_'+fieldname);
                tmpurl += "&jsonvalue_" + fieldname + "=" + encodeURIComponent(json_value);
            } else {
                var elementobj = CrmPopup.findHtmlobj(divid, fieldname);
                tmpfieldvalue = CrmPopup.getHtmlobjval(divid, fieldname);
                if(fieldinfo != undefined && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
                    tmpfieldvalue = fieldinfo.sensitiveencryptvalue;
                    sensitiverequestfield_arr.push(fieldname);
                }
                tmpurl += '&' + fieldname + '=' + encodeURIComponent(tmpfieldvalue);
            }
        }
        // 获取合计字段的值
        else if (fieldname === 'hdnGrandTotal'){
            tmpfieldvalue = popupJqObj.find(`[name=total]`).val();
            tmpurl += '&' + fieldname + '=' + encodeURIComponent(tmpfieldvalue);
        }
        else if (ld.isArray(savedeskvaluepage))//新增界面
        {
            //chj 2021/3/12 43804: （http://58.33.216.46:85/crm [^]）客户问题（邬丹华），业务项目管理->合同评审表，新增单据保存后，创建人显示空
            if (savedeskvaluepage[fieldname] != undefined && savedeskvaluepage[fieldname] != 'undefined') {
                tmpurl += '&' + fieldname + '=' + encodeURIComponent(savedeskvaluepage[fieldname]);
            } else {
                if (fieldname == 'reltab') {
                    tmpurl += '&related_to_type=' + CrmPopup.getHtmlobjval(divid, 'related_to_type');
                } else
                    tmpurl += '&' + fieldname + '= ';
            }

        }

        if (fields_arr[i].uitype == 125) {	//分摊 - 通用代码
            if (CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_count') > 0) {
                var shareequally_value_array = new Array();
                var shareequally_value_count = CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_count');
                tmpurl += '&' + fieldname + '_shareequally_value_count=' + shareequally_value_count;
                tmpurl += '&' + fieldname + '_shareequally_type=' + CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_type');
                for (var row_id = 1; row_id <= shareequally_value_count; row_id++) {
                    tmpurl += '&' + fieldname + '_shareequally_value_' + row_id + '=' + CrmPopup.getHtmlobjval(divid, fieldname + '_shareequally_value_' + row_id);
                }
            }
        }
        if (fields_arr[i].uitype == 303) {	//东贸：适用范围
            var advft_criteria = CrmPopup.getHtmlobjval(divid, fieldname + '_advft_criteria');
            var advft_criteria_groups = CrmPopup.getHtmlobjval(divid, fieldname + '_advft_criteria_groups');
            tmpurl += '&' + fieldname + '_advft_criteria=' + encodeURIComponent(advft_criteria);
            tmpurl += '&' + fieldname + '_advft_criteria_groups=' + encodeURIComponent(advft_criteria_groups);
        }
        //230726 wym XUQIU1000102 unit_price和procostprice字段会含有更多币种 隐藏域中的值也需要传值保存
        if (fields_arr[i].uitype == 72&&popupobj.module=="Products" ) {
            if(ld("#" + divid + " #"+ fieldname+"_currency_class").find("input[type=checkbox]:checked")) {
                var check_Arr = ld("#" + divid + " #"+ fieldname+"_currency_class").find("input[type=checkbox]:checked");
                check_Arr.each(function (){
                    var fldname_check = ld(this).attr('name');
                    var fldvalue_check = ld(this).val();
                    tmpurl += '&' + fldname_check + '=' + encodeURIComponent(fldvalue_check);

                    var fldname_check_arr = fldname_check.split('_check');
                    var currency_id = fldname_check_arr[0].substr(-1);
                    var fldname_cur = fieldname+"_curname"+currency_id ;
                    var fldvalue_cur = ld('#' + fldname_cur).val();
                    tmpurl += '&' + fldname_cur + '=' + encodeURIComponent(fldvalue_cur);
                })
            }
        }
        if ('SendPayment' == popupobj.module && fieldname == 'purchaseorder_id') {
            tmpurl += '&selectsource=' + CrmPopup.getHtmlobjval(divid, 'selectsource');
            tmpurl += '&salesorder_id=' + CrmPopup.getHtmlobjval(divid, 'salesorder_id');
            tmpurl += '&entitytypeid=' + CrmPopup.getHtmlobjval(divid, 'entitytypeid');
        }
    }
    if(sensitiverequestfield_arr.length>0){
        tmpurl += "&sensitiverequestfield="+JSON.stringify(sensitiverequestfield_arr);
    }
    return tmpurl;
}

SaveDataRecord.getSaveParamsFun = {
    PricePolicy: function () {
        return PricePolicy.getInstance().getEditInstance().getSaveParams();
    }
}
SaveDataRecord.getSaveParams = function (popupObj) {
    var module = popupObj.module,
        params = '',
        SaveParams = SaveDataRecord.getSaveParamsFun[module];
    // 模块的参数
    if(typeof SaveParams === 'function') {
        params += SaveParams();
    }
    if(popupObj.detailfieldmodule === 'Products') {
        // 产品分录使用价格政策的参数
        AjaxJSPage('PricePolicyUse', 'include/js/modules/PricePolicy/PricePolicyUse.js');
        params += PricePolicyUse.getInstance().getSaveParams();
    }
    return params;
}