/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/


/*光标定位在折扣率字段上，显示温馨提示信息
function DisCountFocusShowMess(popupobj) {


    if (account_version == 'haige' && popupobj.module == 'Quotes') {
        ld("#" + popupobj.divid + " input[name^='agent_discount']").first().focus(function () {
            ld("#" + popupobj.divid + ' [name=kindlyremind]').show();
        });
        ld("#" + popupobj.divid + " input[name^='agent_discount']").first().blur(function () {
            ld("#" + popupobj.divid + ' [name=kindlyremind]').hide();
        })
    }
}*/
/*
edit:xll 2023/02/17 XUQIU1000546
单据分录定制，“整数”、“数字”、“数量”、“单价”、“金额”、“百分比”字段，分录明细行增加快速填充字段功能（黄运林）
*/
function SetBillData(popupobj,trobj,columnname){
    var bigtype = '';
    ld.each(popupobj.detailfields,function(tmpindex,tmpdetailfieldinfo){
        if(tmpdetailfieldinfo['columnname'] == columnname){
            bigtype = tmpdetailfieldinfo['bigtype'];
        }

    })
    var obj_select =ld(trobj).find("#"+columnname);// ld("#" + popupobj.divid + " input[type='text']").not("#productname, .Wdate, .commonDetailedTextBox, [bigtype^='reference'], [bigtype^='selectsource']");
    // var multipicklist_selelct = ld(trobj).find("span[aria-owns=select2-" + columnname + "-results]");
    //wsh 2024-07-17 XUQIU1001940 单据分录定制，“文本”、“文本区域”、“日期”和“多选框”字段，分录明细行增加快速填充字段功能（史星磊、陈钦帅）
    if(bigtype === 'multipicklist'){
        var input_obj_select = ld(trobj).find('td[detailfieldname='+columnname+']');
        input_obj_select.on('focus', '.select2-selection__rendered', function (evt) {
            var tip_str = arrJsPopLabel['TIPOFBILL'];
            var filed_name = ld(input_obj_select).attr("detailfieldname");
            //edit: xll 2023/10/25 避免出现两个对象导致text错误
            var fieldname_txt = ld("#" + popupobj.divid + " td[head_detailfieldname = " + filed_name + "]").text();
            fieldname_txt = fieldname_txt.includes("*") ? fieldname_txt.slice(1) : fieldname_txt;
            var tip_str_fieldname = tip_str.replaceAll("$字段名称$", fieldname_txt);
            tip_str_fieldname = tip_str_fieldname.replaceAll("$field name$", fieldname_txt);
            ld("#" + popupobj.divid + ' [name=kindlyremind]').text(tip_str_fieldname);
            ld("#" + popupobj.divid + ' [name=kindlyremind]').show();
        });
        input_obj_select.on('blur', '.select2-selection__rendered', function (evt) {
            ld("#" + popupobj.divid + ' [name=kindlyremind]').hide();
        });
        input_obj_select.on("keyup", '.select2-selection__rendered', function(event){
            var e = event || window.event;
            var keyCode = e.keyCode || e.which || e.charCode;
            var ctrlKey = e.ctrlKey || e.metaKey;
            if(ctrlKey && (keyCode == 13 || keyCode == 10)){
                var select_value = input_obj_select.find("select").val();
                //edit: xll 2023/09/21 BUG0072950 CTRL+Enter 仅修改当前行及之后行
                var tabobj =  Tools.getParentobjByChild(ld(this),'table');
                var tmprowindex =  Tools.getParentobjByChild(ld(this),'tr').index();
                var col_inputobj = ld(tabobj).find(" tr:gt("+tmprowindex+") #"+columnname);
                var trobjs = ld(tabobj).find('tr');
                ld.each(col_inputobj,function(){
                    ld(this).val(select_value).trigger('change');
                })
                //duan 20230927 使用覆盖列值时,一次性绑定所有行事件
                ld.each(trobjs,function(){
                    if (ld(this).attr("havemouseevent") != 'yes' ){
                        popupobj.selectproductobj.onmouseevent(ld(this));
                    }
                });
                ld(this).blur();
            }
        });
        return '';
    }

    obj_select.focus(function () {
        var tip_str = arrJsPopLabel['TIPOFBILL'];
        var filed_name = ld(event.target).attr("name");
        //edit: xll 2023/10/25 避免出现两个对象导致text错误
        var fieldname_txt = ld("#" + popupobj.divid + " td[head_detailfieldname = " + filed_name + "]").text();
        fieldname_txt = fieldname_txt.includes("*") ? fieldname_txt.slice(1) : fieldname_txt;
        var tip_str_fieldname = tip_str.replaceAll("$字段名称$", fieldname_txt);
        tip_str_fieldname = tip_str_fieldname.replaceAll("$field name$", fieldname_txt);
        ld("#" + popupobj.divid + ' [name=kindlyremind]').text(tip_str_fieldname);
        ld("#" + popupobj.divid + ' [name=kindlyremind]').show();
    });
    obj_select.blur(function () {
        ld("#" + popupobj.divid + ' [name=kindlyremind]').hide();
    });
    //Ctrl+Enter设置同列所有字段
    obj_select.bind("keydown",function(event){
        var e = event || window.event;
        var keyCode = e.keyCode || e.which || e.charCode;
        var ctrlKey = e.ctrlKey || e.metaKey;
        if(ctrlKey && (keyCode == 13 || keyCode == 10)){
            var value = ld(this).val();
            var name = ld(this).attr("name");
            //edit: xll 2023/09/21 BUG0072950 CTRL+Enter 仅修改当前行及之后行
            var tabobj =  Tools.getParentobjByChild(ld(this),'table');
            var tmprowindex =  Tools.getParentobjByChild(ld(this),'tr').index();
            var col_inputobj = ld(tabobj).find(" tr:gt("+tmprowindex+") #"+name);
            var trobjs = ld(tabobj).find('tr');
            ld.each(col_inputobj,function(){
                ld(this).val(value);

                //edit: xll BUG0066016 2023/05/09 击ctrl + enter按钮整列数据全部更新，但是对应的折扣额一列数值只自动计算了前两行，其他行没有运算
                //ld(this).change();//change事件绑定可能失效导致触发change不计算数据
            })
            //duan 20230927 使用覆盖列值时,一次性绑定所有行事件
            ld.each(trobjs,function(){
                if (ld(this).attr("havemouseevent") != 'yes' ){
                    popupobj.selectproductobj.onmouseevent(ld(this));
                }
            })
            popupobj.fieldformulaobj.changeRowDatabyColumnname(name);//按公式计算所有数据

            ld(this).blur();
        }
    })
}

/*
edit:xxs
date:2017-03-01
reson:输入折扣率后按快捷键(Ctrl+Enter)，下方行的折扣可统一更改

function SetDiscountPercent(popupobj) {

    ld("#" + popupobj.divid + " input[name^='discount_percent']").on("keydown", function (event) {
        var e = event || window.event || arguments.callee.caller.arguments[0];
        var keyCode = e.keyCode || e.which || e.charCode;
        var ctrlKey = e.ctrlKey || e.metaKey;

        if (ctrlKey && keyCode == 13) {  //F6 117
            self = this;
            ld(self).change();
            ld(this).parent().parent().nextAll("tr").each(function () {
                thisinput = ld(this).find("input[name^='discount_percent']");
                ld(thisinput).val(ld(self).val());
                ld(thisinput).change();
            })
            ld(this).blur();
        }
    });
    if (account_version == 'haige' && popupobj.module == 'Quotes') {
        ld("#" + popupobj.divid + " input[name^='agent_discount']").on("keydown", function (event) {
            var e = event || window.event || arguments.callee.caller.arguments[0];
            var keyCode = e.keyCode || e.which || e.charCode;
            var ctrlKey = e.ctrlKey || e.metaKey;

            if (ctrlKey && keyCode == 13) {  //F6 117
                self = this;
                ld(self).change();
                ld(this).parent().parent().nextAll("tr").each(function () {
                    thisinput = ld(this).find("input[name^='agent_discount']");
                    ld(thisinput).val(ld(self).val());
                    ld(thisinput).change();
                })
                ld(this).blur();
            }
        });
    }
}
*/

/*
edit:xxs
date:2017-03-02
reson:上下移动，切换光标位置
*/
function UpDownPointFocus(popupobj) {
    ld("#" + popupobj.divid + " [name=proTab] input,textarea").on("keydown", function (event) {
        var e = event || window.event || arguments.callee.caller.arguments[0];
        //产品名称input在内层，需另处理
        if (ld(this).hasClass('proName')) {
            var pre_id = 'productname';
            var self = ld(this).closest('.OtherTab');
        } else {
            var rowid = ld(this).closest('tr').attr('id');
            if (rowid == undefined) return;
            var num = rowid.replace(/\D+/g, '');
            var id = ld(this).attr('id');
            var pre_id = id.substring(0, id.length - num.length);

            var self = this;
        }

        var input_textarea = ld("input,textara");
        if (e && e.keyCode == 38) {  //上移
            var next_num = parseInt(num) - 1;
            pre_id = pre_id + next_num;
            ld(self).parent().parent().prevAll("tr:visible:first").find('[id=' + pre_id + ']').focus();
            //ld("div[id^='search_productname']").hide();
        }
        if (e && e.keyCode == 40) {  //下移
            var next_num = parseInt(num) + 1;
            pre_id = pre_id + next_num;
            ld(self).parent().parent().nextAll("tr:visible:first").find('[id=' + pre_id + ']').focus();
            //ld("div[id^='search_productname']").hide();
        }
    });
}

function ShowSequence(popupobj) {
    return false;//设置序号在fnAddProductTdBtn（）
    if (popupobj === undefined) {
        return false;
    }


    if (popupobj.hasOwnProperty('fieldformulaobj') && popupobj.fieldformulaobj.ismasscount === 'yes') {
        return false;
    }
    /*  ld("#"+popupobj.divid+" [name=proTab] tr[name^=row]:visible").each(function(index){
		ld(this).children('td').eq(1).html(index+1);
	});*/
    var tableobj = popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
    var seqno = 1;
    var rowindex = 1;

    ld.each(ld(tableobj).find("tr"), function (tmpindex, obj) {
        //if(ld(obj).hasAttr("detaildeleted"))
        // {
        if (ld(obj).attr("detaildeleted") == 'no' || ld(obj).attr("detaildeleted") == 'yes') {
            ld(obj).attr("rowindex", rowindex);
            ld(obj).attr("row", rowindex);//历史遗留，暂时保留
            ld(obj).attr("name", "row" + rowindex);//历史遗留，暂时保留
            rowindex++;

        }
        if (ld(obj).attr("detaildeleted") == 'no') {
            ld(obj).children('td').eq(1).html(seqno);
            seqno++;
        }
        // }


    })

}

//价格信息弹出层点击价格填充不含税单价
function fillRowListPrice(obj, fldname, rowid) {
    var listprice = ld(obj).next().val();

    var popupobj = CrmPopup.getPopupObj('last');
    ld('#' + popupobj.divid + " [detailcolumnname=listprice]").val(listprice);
    popupobj.fieldformulaobj.changelistprice();//调用公式计算
    popupobj.fieldformulaobj.CountsubTotal();//小计（包括计算合计,整单折扣)
    fninvshnew('selectpricebokksdiv');
}

function showPopupPriceBook(productid, rowId, checkaccven) {
    var popupobj = CrmPopup.getPopupObj('last');
    var fld = 'listprice';
    /*if(rmb_checkRMBProduct() == 'rmb'){
		fld = 'rmbprice';
	}*/
    var currencyid = ld("#" + popupobj.divid + " [name=inventory_currency]").val();// document.getElementById("inventory_currency").value;
    var currentModule = popupobj.module;
//	if(typeof(document.EditView) != 'undefined')
    //	currentModule = document.EditView.module.value;
    var accvenid = '';
    if (ld("#" + popupobj.divid + " [name=vendor_id]").length > 0) {
        var accvenid = ld("#" + popupobj.divid + " [name=vendor_id]").val();// document.EditView.vendor_id.value;
    }
    if (ld("#" + popupobj.divid + " [name=account_id]").length > 0) {
        var accvenid = ld("#" + popupobj.divid + " [name=account_id]").val();// document.EditView.account_id.value;
    }

    var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getPriceBooksinfo=yes';
    urlstring += '&fldname=' + fld + '&checkaccven=' + checkaccven + '&accvenid=' + accvenid + '&currencyid=' + currencyid + '&rowid=' + rowId + '&frommodule=' + currentModule + '&productid=' + productid;


    new Ajax.Request("index.php",
        {
            queue: {
                position: "end",
                scope: "command"
            },
            method: "post",
            postBody: urlstring,
            onComplete: function (response) {
                // if (response.responseText.indexOf('$#NONERECORD#$') >= 0) {//跳转价格表
                    showOtherPopupPriceBook(rowId, fld, productid, currencyid);
                // } else {//弹出价格信息
                //     if (document.getElementById('selectpricebokksdiv') == undefined) {
                //         ld("body").append('<div id="selectpricebokksdiv"></div>');
                //     }

                //     $("status").style.display = "none";
                //     $("selectpricebokksdiv").innerHTML = response.responseText;


                //     $("selectpricebokksdiv").className = 'D_pop_box LdPopWidth600px';
                //     fnvshobj(this, 'selectpricebokksdiv');
                //     ld("#layer").css("z-index", CrmPopup.zIndex + 1)
                //     CrmPopup.zIndex++
                //     ld("#selectpricebokksdiv").css("z-index", CrmPopup.zIndex + 1);
                //     CrmPopup.zIndex++;

                // }

            }
        }
    );

    //window.open("index.php?module=PriceBooks&action=Popup&html=Popup_picker&form=EditView&rowid="+rowId+"&popuptype=inventory_pb&fldname="+fld+rowId+"&productid="+productid+"&currencyid="+currencyid,"priceBookWin","width=840,height=565,resizable=1,scrollbars=1,top=150,left=200");
}

function showOtherPopupPriceBook(rowid, fldname, productid, currencyid) {
    var popupobj = CrmPopup.getPopupObj('lastprev');
    //edit:can 20211210 	0049131: （https://81mis.com/kfbcrm/ [^]）工具->价格表，价格表名称：123455，这个价格表有效期已过，但在销售订单、报价单、销售机会等带产品分录的模块都能选到这个价格表
    var surl = "module=PriceBooks&action=Popup&html=Popup_picker&form=EditView&rowid=" + rowid + "&popuptype=inventory_pb&fldname=" + fldname + "&productid=" + productid + "&popup=yes&page_popup=yes&currencyid=" + currencyid;
    surl += "&frommodule=" + popupobj.module;

    // ls 2022-03-15 【ID1001763】佛山中午电器个性化开发需求（黄杰宗）
    //1、 报价单产品分录 不含税单价的价格表弹窗列表根据所属销售类型来显示，即销售类型名称 等于 价格表名称
    var lastpopupobj = CrmPopup.getPopupObj('last');
    if (account_version == 'zhongwu' && popupobj.module == 'Quotes') {
        if (typeof ld('#' + lastpopupobj.divid + ' [name=cf_4376]').val() != 'undefined') {
            var cf_4376 = ld('#' + lastpopupobj.divid + ' [name=cf_4376]').val();//销售类型
            if (empty(cf_4376)) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '销售类型不能为空，请先选择客户！');
                return false;
            } else if (empty(ld('#' + lastpopupobj.divid + ' [name=account_id]').val())) {
                //选择客户带出销售类型后，又清除客户时，异常处理
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '请先选择客户！');
                return false;
            }
            //2、“销售类型”为按照平台成交价格/按照销售订单价格的这两种类型产品的不含税单价不取价格表的价格（即不需要处理，不用跳转价格表弹窗）
            if (cf_4376 == '按照平台成交价格' || cf_4376 == '按照销售订单价格') {
                return false;
            }
            surl += "&cf_4376=" + encodeURIComponent(cf_4376);
        }
    }
    //duan 20230518 分录选价格表时增加当前页面字段值获取,用于进行通配符取值
    var requestvalues = "{";
    ld.each(lastpopupobj.fields, function (tmpindex, tmpfieldinfo) {
        if (tmpfieldinfo.bigtype == 'longtextarea' || tmpfieldinfo.bigtype == 'textarea')
            return false;
        if (ld("#" + lastpopupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").length > 0)
            requestvalues += '"' + tmpfieldinfo.columnname + '":"' + ld("#" + lastpopupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").val() + '",';

    })
    requestvalues = requestvalues.substr(0, requestvalues.length - 1);//删除“，”
    requestvalues += "}";
    surl += "&requestvalues=" + encodeURIComponent(requestvalues);
    surl += "&curr_row=" + rowid;
    CrmPopupWindow('PriceBooks', surl, 'PriceBooks');
}

function set_return_inventory_pb(listprice, currency_id, fldname, rowid) {
    //edit:can 20221230  60128	做好价格表之后，去入库单新建单据，输入产品：B08410002弹簧（117弹簧），录好之后点不含税单价，选择价格表，然后就点里面的
    fninvshnew('selectpricebokksdiv');
    //价格表赋值
    var popupobj = CrmPopup.getPopupObj('lastprev');
    //@edit:liushuai,2020-12-11,reason 0043681: （https://61mis.com/kfbtest [^]）客户问题（王耀文），合同订单不含税单价选择价格表后，其他分录行的不含税单价都被带出了当前产品的价格（需要补丁）
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = tableobj.find("tr[rowindex=" + rowid + "]");
    ld(rowobj).find(" [name=" + fldname + "]").focus();
    ld(rowobj).find(" [name=" + fldname + "]").val(listprice);

    // ls 2022-03-15 【ID1001763】佛山中午电器个性化开发需求（黄杰宗）
    //需求二：报价单的产品价格分类自动获取价格表的单价报价单的产品价格分类自动获取价格表的单价
    //需求三：取价格时按照“有效期起”最新的价格，即按有效期起字段desc排序后取第一条
    popupobj.RelatedProductToolFieldtriggcols = [];
    getRelatedProductToolFieldPriceCallBack(popupobj, rowid);

    // ld("#"+popupobj.divid+" [name="+fldname+"]").focus();
    //document.EditView.elements[fldname].focus();
    //document.EditView.elements[fldname].value = listprice;

    // ld("#"+popupobj.divid+" [name="+fldname+"]").val(listprice);
    //window.opener.document.EditView.elements[fldname].onblur();
    //42109: （61mis.com/kfbcrm）报价单模块>新建单据界面：选择产品“灵当标准版”，带出单价“800”然后选择价格表“5555”（灵当标准版批发价是“211”），没有生效
    // popupobj.fieldformulaobj.changedatabyColumnname('listprice', rowid);
    ld(rowobj).find(" [name=" + fldname + "]").change();//价格表选完 没计算字段公式
    //0013513: 合同订单的产品选择【产品套餐】，然后币种选择“泰铢”，结果在报表中，合同的金额显示成人民币符号。
    if (ld("#" + popupobj.divid + " [name=inventory_currency]").length > 0)// document.getElementById('inventory_currency') != undefined)
    {
        var objSelect = ld("#" + popupobj.divid + " [name=inventory_currency]").get(0);// document.getElementById('inventory_currency');
        for (var i = 0; i < objSelect.options.length; i++) {
            if (objSelect.options[i].value == currency_id) {
                objSelect.options[i].selected = true;
                break;
            }
        }
    }
    cancelCrmPopup();
}

//不含税单价选择价格表事件
function priceBookPickList(currObj, row_no) {
    var trObj = currObj.parentNode.parentNode
    var rowId = ld(trObj).attr("rowindex");// 拖动行，要重新给row_no赋值 parseInt(trObj.id.substr(trObj.id.indexOf("w")+1,trObj.id.length))
    var popupobj = CrmPopup.getPopupObj('last');
    var tableobj = popupobj.getDetailTableObj();

    var rowobj = ld(tableobj).find("tr[rowindex=" + rowId + "]");

    var productId = popupobj.detaildatavalue_arr[rowId-1].hdnProductId;//  ld(rowobj).find(" [name=hdnProductId]").val() || -1;//getObj("hdnProductId"+rowId).value || -1;
    if(empty(productId))
        productId = ld(rowobj).find(" [name=hdnProductId]").val();

    if (productId == -1) {
        var confirm_str = arrJsPopLabel['PLEASESELECTPRODUCT'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return;
    }

    showPopupPriceBook(productId, rowId, 'false');
}

var isupdateacctrate = 1;

//Method changed as per advice by jon http://forums.lingdang.com/viewtopic.php?t=4162
function roundValue(val) {
    val = parseFloat(val);
    val = Math.round(val * 100) / 100;
    val = val.toString();

    if (val == '' || isNaN(val)) {
        //37121: PC端->合同订单->选择产品->产品套餐：第二次选择产品套餐，弹出层界面无法关闭

        val = "0";
    }

    if (val.indexOf(".") < 0) {
        val += ".00"
    } else {
        var dec = val.substring(val.indexOf(".") + 1, val.length)
        if (dec.length > 2)
            val = val.substring(0, val.indexOf(".")) + "." + dec.substring(0, 2)
        else if (dec.length == 1)
            val = val + "0"
    }

    return val;
}

var setBatch_finished = false;
var productAddFieldLabels;

//This function is used to validate the Inventory modules
function validateInventory(module) {

    var ret = true;
    //模块基本信息验证
    if (!formValidate())
        return false
    var popupobj = CrmPopup.getPopupObj("last");

    var validatasaveobj = new validatasave(popupobj.validatasave, 'js');
    if (!validatasaveobj.producttoolvalidata()) {

        return false;
    }
    var product_info;
    var pur_type = 0;
    var saleorder_type = 0;
    if (module == 'Products' || module == 'Vendors' || module == 'PriceBooks' || module == 'Services') {
        return true;
    }
    //克莱门特：重复发货一定要避免，即发货单源单不能重复
    if (module == 'PurchaseInquiryOrder' && ld('#haveInvenotryOrder') != undefined && ld('#haveInvenotryOrder').val() == 'no' && ld('#selectlistval').val() > 0) {
        alert('源单不能重复发货！');
        return false;
    }
    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;

    /**
     * @edit:chj
     * @date:2014-10-20
     * @reason:库间调拨  判断调出仓库和调入仓库是否一致
     * @description:
     */
    if (module == 'WareHouseTransfer') {
        if (!warehouseValidate()) {
            var confirm_str = arrJsPopLabel['INANDOUTNOTSAME'];
            audioRemindsMsg("", "", module, "", "", confirm_str);
            return false;
        }
    }
    var trobjs = popupobj.getTrObjsByDelType("no");//获取没有删除的行
    //验证产品明细中是否存在同样产品

    if (!FindDuplicate())
        return false;

    //var max_row_count =ld("#"+popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;
    //克莱门特 报价单、报价变更单- 字段是否领取配件”为“是”的时候，要求字段“备件收件人”必填，否则非必填；
    //如维保类型是清包的时候，如果存在产品明细，则不让保存；
    if ((module == 'Quotes' || module == 'QuotesChange') && CrmPopup.findHtmlobj(divid, 'version_account').val() != undefined && CrmPopup.findHtmlobj(divid, 'version_account').val() == 'climaveneta') {
        var is_product_num = 0;
        //for (var i=1;i<=max_row_count;i++)
        ld.each(trobjs, function () {
            var tmprowindex=ld(this).attr("rowindex");
            //if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('hdnProductId'+i).value > 0 && document.getElementById('quantity'+i).value > 0){
            /*if (ld(this).find("#hdnProductId").val() > 0
                && ld(this).find("#quantity").val() > 0) {
                is_product_num = 1;
                return false;
            }*/
            if(popupobj.detaildatavalue_arr[tmprowindex-1].hdnProductId>0&&popupobj.detaildatavalue_arr[tmprowindex-1].quantity>0)
            {
                is_product_num = 1;
                return false;
            }
        });
        var sel_is_needpeijian = 'is_needpeijian';
        var peijian_geter = 'peijian_geter';
        if (module == 'Quotes') {
            sel_is_needpeijian = 'cf_2301';
            peijian_geter = 'cf_2355';
        }
        if (is_product_num == 1) {
            CrmPopup.findHtmlobj(divid, sel_is_needpeijian).val(1);
            CrmPopup.findHtmlobj(divid, 'span_' + sel_is_needpeijian).html(arrJsPopLabel['YES']);
        } else {
            CrmPopup.findHtmlobj(divid, sel_is_needpeijian).val(0);
            CrmPopup.findHtmlobj(divid, 'span_' + sel_is_needpeijian).html(arrJsPopLabel['NO']);
        }
        if (CrmPopup.findHtmlobj(divid, peijian_geter).val() != undefined && CrmPopup.findHtmlobj(divid, peijian_geter).val() == '' && is_product_num == 1) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '备件收件人不能为空！');
            return false;
        }

    }
    // ls 2022-01-17 【1002387】上海微迪加特殊开发（徐昱轩）   如果开户申请单的产品明细中包含产品类别为“软件开发”或者“硬件销售”的产品，则表头的附件为必填字段
    // if (module == 'OutboundOrder' && CrmPopup.findHtmlobj(divid, 'version_account').val() != undefined && CrmPopup.findHtmlobj(divid, 'version_account').val() == 'zhihui') {
    //     var tmp_productcategory_remind = false;
    //     ld.each(trobjs, function () {
    //         var tmp_productcategory = ld(this).find("#productcategory").val().trim();
    //         if (ld(this).find("#hdnProductId").val() > 0 && (tmp_productcategory.indexOf('硬件销售') > -1 || tmp_productcategory.indexOf('软件开发') > -1)) {
    //             tmp_productcategory_remind = true;
    //             return false;//跳出循环
    //         }
    //     });
    //     if (tmp_productcategory_remind && ld("#" + popupobj.divid + " [name=Uploadthelist]").children().length === 0) {
    //         RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '请上传附件！');
    //         return false;
    //     }
    // }

    if (ld(trobjs).length == 0) {
        var confirm_str = arrJsPopLabel['NOLINEITEMSELECT'];
        audioRemindsMsg("", "", module, "", "", confirm_str);
        return false;
    }
    //没有产品模块权限，请联系管理员
    if (ld('#' + popupobj.divid + ' [name=vtlibproducts]').val() != undefined && ld('#' + popupobj.divid + ' [name=vtlibproducts]').val() == 'no') {
        noVtlibProducts();
        return false;
    }

    //出入库：出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）

    /*if(ld("#"+popupobj.divid+" [name=productdeploy]").length>0&&ld("#"+popupobj.divid+" [name=productdeploy]").val()==0)//document.getElementById('productdeploy') != undefined && document.getElementById('productdeploy').value == 0)
    {

    }*/


    /*
    edit:chj
    date:2013-12-17
    reson:判断出入库单是否选择了原单
    */
    if (module == 'Stock' && ld("#" + popupobj.divid + " [name=purchaseorder_id]").length > 0) {
        var purchaseorder_id = ld("#" + popupobj.divid + " [name=purchaseorder_id]").val();// document.getElementsByName("purchaseorder_id")[0].value;
        if (purchaseorder_id != undefined && purchaseorder_id != "" && purchaseorder_id > 0) {
            pur_type = 1;
        }
    }
    if (module == 'OutboundOrder' && ld("#" + popupobj.divid + " [name=salesorder_id]").length > 0) {
        var salesorder_id = ld("#" + popupobj.divid + " [name=salesorder_id]").val();// document.getElementsByName("salesorder_id")[0].value;
        if (salesorder_id != undefined && salesorder_id != "" && salesorder_id > 0) {
            saleorder_type = 1;
        }
    }
    var module_nullfield = ld('#' + popupobj.divid + " [name=module_nullfield]").val();
    if (module == 'WareHouseTransfer') {
        //库间调拨
        var wareid = ld('#' + popupobj.divid + " [name=outwarehouse]").val();
    } else {
        var wareid = ld('#' + popupobj.divid + " [name=wareid]").val();
    }
    //popupobj.fieldformulaobj.savecheckfields=getSaveCheckFields();
    var row = 0;
    var haveproductows = 0;
    var null_row = 0;//空行数
    var batchtexturls = "index.php?module=Products&action=ProductsAjax&file=getbatchquantity&frommodule=" + module;
    var batchtexturl = "";
    var productbatchtexturl = "";
    var pagehavebatchtextrowindex = new Array();//有批次的行号
    var productbatchquantity = new Array();
    var productbatchquantity_string = "";

    var nullfield = module_nullfield.split('##');//空行验证
    //产品自定义字段验证
    if (!empty(module_nullfield)) {
        var tableobj = popupobj.getDetailTableObj();
        //for (var i=1;i<=max_row_count;i++) {
        var trobjs_len = ld(trobjs).length;
        ld.each(popupobj.detaildatavalue_arr, function (tmpvalueindex, tmpvalueinfo) {
            // var rowindex=ld(rowobj).attr("rowindex");
            var rowindex = tmpvalueindex + 1;
            var rowobj = ld(tableobj).find("tr[rowindex=" + rowindex + "]");

            //	if(ld(rowobj).find(" [name=hidden_rowid]").val()==0){//document.getElementById('hidden_rowid_'+i).value == 0){
            row += 1;//有效行，没有被删除的行
            var productid = tmpvalueinfo.productid;//ld(rowobj).find("#hdnProductId").val();
            if (ld.trim(productid) == '' || parseInt(productid) <= 0) {
                return true;
            }

            //使用双向绑定后，批次判断方法修改
            if(tmpvalueinfo.producthave_batchtext!=undefined && tmpvalueinfo.producthave_batchtext=='yes'){
                pagehavebatchtextrowindex.push(rowindex);
                if (tmpvalueindex == trobjs_len) {
                    batchtexturl += trim(tmpvalueinfo.batchtext);
                    productbatchtexturl += productid;
                } else {
                    batchtexturl += trim(tmpvalueinfo.batchtext) + "##";
                    productbatchtexturl += productid + ",";
                }

                if (tmpvalueinfo.batchtext==undefined || tmpvalueinfo.batchtext == '') {
                    if (language == 'zh-cn')
                        audioRemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['LINE'] + rowindex + arrJsPopLabel['row'] + '批次' + arrJsPopLabel['CANOTEMPTY']);
                    else
                        audioRemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['LINE'] + rowindex + " " + '批次' + arrJsPopLabel['CANOTEMPTY']);
                    ret = false;
                }
                var tmpbatchtext = tmpvalueinfo.batchtext;

                if (module == 'OutboundOrder') {
                    //duan 20230801 修复新建界面,判断批次数量时,仓库id错误的问题
                    if(!empty(tmpvalueinfo.wareid_rawvalue)){
                        wareid = tmpvalueinfo.wareid_rawvalue;
                    }else{
                        wareid = tmpvalueinfo.wareid;// ld(rowobj).find(" [detailcolumnname=wareid]").val();
                    }
                }
                var tmpquantiy = 0;
                if(!empty(tmpvalueinfo.quantity)){
                    tmpquantiy = tmpvalueinfo.quantity;
                }
                if (!empty(tmpbatchtext)) {
                    productbatchquantity_string += rowindex + '||%%||' + wareid + '||%%||' + productid + '||%%||' + encodeURIComponent(tmpbatchtext) + '||%%||' + tmpquantiy + '||@@||';
                }
            }

            /*var batchtextobj = ld(rowobj).find("#batchtext");
            if (batchtextobj.length > 0) {

                //不用根据产品是否启用判断，如果产品启用批次管理，但是出入库界面批次字段被关闭，这种情况不做提示
                if (batchtextobj.css("display") != 'none') {
                    pagehavebatchtextrowindex.push(i);
                    if (tmpvalueindex == trobjs_len) {
                        batchtexturl += trim(tmpvalueinfo.batchtext);
                        productbatchtexturl += productid;
                    } else {
                        batchtexturl += trim(tmpvalueinfo.batchtext) + "##";
                        productbatchtexturl += productid + ",";
                    }

                    if (trim(batchtextobj.val()) == '') {
                        if (language == 'zh-cn')
                            audioRemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['LINE'] + rowindex + arrJsPopLabel['row'] + '批次' + arrJsPopLabel['CANOTEMPTY']);
                        else
                            audioRemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['LINE'] + rowindex + " " + '批次' + arrJsPopLabel['CANOTEMPTY']);
                        ret = false;
                    }
                    var tmpbatchtext = trim(batchtextobj.val());
                    if (module == 'OutboundOrder') {
                        wareid = tmpvalueinfo.wareid;// ld(rowobj).find(" [detailcolumnname=wareid]").val();
                    }
                    if (!empty(tmpbatchtext)) {
                        productbatchquantity_string += rowindex + '||%%||' + wareid + '||%%||' + productid + '||%%||' + encodeURIComponent(tmpbatchtext) + '||%%||' + ld(rowobj).find(" [name=quantity]").val() + '||@@||';
                    }
                }
            }*/


            var nullfield_num = 0;//空行基准字段的数量
            //都为空时，则判断为空白行

            for (k = 0; k < nullfield.length; k++) {

                if (nullfield[k] == 'productname') {
                    if (tmpvalueinfo.productid <= 0) {
                        nullfield_num += 1;
                    } else {
                        haveproductows++;
                    }
                } else {
                    if (tmpvalueinfo[nullfield[k]] == '') {
                        nullfield_num += 1;
                    }
                }

            }
            if (nullfield_num == nullfield.length) {
                null_row++;
                return true;
            } else {
                /*	if(!check_productdetailfield(i)){
							return false;
						}*/
            }


            /**
             * edit:chj
             * date:2014-6-30
             * reason:服务合同 产品明细开始日期结束日期判断
             */
            if (module == 'ServiceContracts') {
                // var servicecontracts_start_dateobj=ld(rowobj).find(" [detailcolumnname=servicecontracts_start_date]");
                // var servicecontracts_end_dateobj=ld(rowobj).find("  [detailcolumnname=servicecontracts_end_date]");

                if (tmpvalueinfo.servicecontracts_start_date!=undefined&&tmpvalueinfo.servicecontracts_start_date!=''
                    && tmpvalueinfo.servicecontracts_end_date!=undefined&&tmpvalueinfo.servicecontracts_end_date!='') {
                    if (tmpvalueinfo.servicecontracts_start_date > tmpvalueinfo.servicecontracts_end_date) {
                        var confirm_str = arrJsPopLabel['STARTDATECANNOTBEGERATERTHANTHE'];
                        audioRemindsMsg("", "", module, "", "", confirm_str);
                        var servicecontracts_end_dateobj=ld(rowobj).find("#servicecontracts_end_date");
                        servicecontracts_end_dateobj.focus();
                        //wym BUG0068905 retrun false只会跳出循环，最后函数还是返回true
                        ret = false;
                    }
                }
            }
            //报价变更单
            if (module == 'QuotesChange') {
                var change_type = ld('#' + popupobj.divid + " [name=change_type]").val();
                if (change_type == 'replace') {
                    var pro_idobj = ld('#' + popupobj.divid + " [detailcolumnname=pro_id]");

                    if (pro_idobj.length > 0) {
                        if (pro_idobj.val() == productid) {
                            var alert_mes = arrJsPopLabel['thereisnochangedonline'];
                            alert_mes = alert_mes.replace('{num}', i);
                            audioRemindsMsg("", "", module, "", "", alert_mes);
                            ret = false;
                        }
                    }
                }
            }

            //预算变更单
            if (module == 'BudgetChange') {
                var change_type = ld('#' + popupobj.divid + " [name=change_type]").val();
                if (change_type == 'replace') {
                    var pro_idobj = ld('#' + popupobj.divid + " [detailcolumnname=pro_id]");

                    if (pro_idobj.length > 0) {
                        if (pro_idobj.val() == productid) {
                            var alert_mes = arrJsPopLabel['thereisnochangedonline'];
                            alert_mes = alert_mes.replace('{num}', i);
                            audioRemindsMsg("", "", module, "", "", alert_mes);
                            ret = false;
                        }
                    }
                }
            }

            //	}


        })
    }
    if (!ret) {
        return ret;
    }
    if (haveproductows == 0 && !empty(module_nullfield)) {
        //没有选择产品
        var producttoolfield = ld("#" + popupobj.divid + " [name=productToolField]").val().split(("::"));//document.getElementById('productToolField').value.split('::');
        for (var pi = 0; pi < producttoolfield.length; pi++) {
            colinfos = producttoolfield[pi].split(':');
            columnname = colinfos[0];
            var typeofdata = colinfos[2].split('~');
            if (columnname == "productname" && typeofdata[1] == 'M') {
                //35088: （1.6登录）选择“产品管理” 模块：产品名称为空保存时，没有弹出提示信息直接保存成功（服务合同模块测试）
                fieldlabel = colinfos[3];
                audioRemindsMsg("", "", module, "", "", fieldlabel + arrJsPopLabel['CANOTEMPTY']);
                var tmpobj = ld("#" + popupobj.divid + " [name=productname]");
                emptyCheckObj(tmpobj, 'Text');
                return false;
            }
        }
    }

    //如果空行和有效行一致，则至少选择一个产品行
    if (row == null_row) {
        /*for (var i=1;i<=max_row_count;i++) {
			if(!check_productdetailfield(i)){
				return false;
			}
		}*/
    }
    var tmpobj = ld("#" + popupobj.divid + " [name=adjustment]");
    if (tmpobj.length > 0) {//document.getElementById("adjustment") != undefined){
        var adjustment = tmpobj.val();
        adjustment = parseFloat(adjustment.split(",").join(""));
        //调整金额只可以录入正数
        var temp = /^(0|[1-9]{1}\d{0,})(\.(\d{1}\d{0,}))?$/.test(adjustment);
        if (!temp) {
            var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
            audioRemindsMsg("", "", module, "", "", confirm_str);
            return false;
        }
    }
    //判断批次号的出库数量不能大于批次号入库数量
    var lengthdecimaldigits = ld("#" + popupobj.divid + " [name=lengthdecimaldigits]").val();//document.getElementById("lengthdecimaldigits").value;
    var error_info = "";
    if (productbatchquantity_string != "" && (module == 'OutboundOrder' || module == 'WareHouseTransfer')) {
        batchtexturls += '&productbatchquantity_string=' + productbatchquantity_string + "&id=" + popupobj.record;
        //alert(batchtexturls);
        http_reqfield = createfieldXMLHTTP();
        http_reqfield.open("POST", batchtexturls, false);
        popupobj.setBatch_finished = false;
        http_reqfield.onreadystatechange = setProductBatchQuantity;
        http_reqfield.setRequestHeader("If-Modified-Since", "0");
        http_reqfield.send();
        if (popupobj.setBatch_finished == true) {
            return false;

        }
    }

    //0025416: 产品套餐>新建：点击【保存】失效。
    if (module == 'Productbom' || module == 'Checks') {
        return true;
    }
    var tmpobj = ld("#" + popupobj.divid + " [name=allSingledDiscount]");
    var discount_amountobj = ld("#" + popupobj.divid + " [tag=maintablefield_discount_amount]");
    if (tmpobj.length > 0 && tmpobj.val() == '%' && discount_amountobj.length > 0) {
        var discount_percent = discount_amountobj.val();//document.getElementById("discount_amount").value;
        if (discount_percent < 0 || discount_percent > 100) {
            var confirm_str = arrJsPopLabel['PLEASEENTERNUMBERBETWEEN0AND100'];
            audioRemindsMsg("", "", module, "", "", confirm_str);
            return false;
        } else {
            if (calcTotal()) {
                return true;
            } else {
                return false;
            }
        }
    } else {
        if (calcTotal()) {
            return true;
        } else {
            return false;
        }

    }

}

function setProductBatchQuantity() {
    if (http_reqfield.readyState == 4) {
        if (!empty(http_reqfield.responseText)) {
            var popupobj = CrmPopup.getPopupObj("last");
            popupobj.setBatch_finished = true;
            RemindsMsg("", "LdPopWidth600px", "", "yes", "yes", http_reqfield.responseText);
        }
    }
}

//36287: 出库单-仓库放到表体之后，更改仓库时建议增加一个功能：是否更新下面行的仓库为{当前仓库}
function changeRowWareHouse(rowid) {
    return false;//不需要了，cls_resetcombox.js 通过crl+Enter
    var popupobj = CrmPopup.getPopupObj("last");
    var tableobj = popupobj.getDetailTableObj();//获取单据分录table对象

    var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");

    if (rowid >= 1) {
        //@edit:liushuai,2020-8-4,reason:0042230: （61mis.com/kfbcrm）出库单新增界面>产品信息区块>“仓库”字段：第一个产品切换仓库后，下面的产品没有一起切换仓库。
        var wareid = ld(rowobj).find(" [name=wareid]").val();
        var warename = ld(rowobj).find(" [name=cmb_span_optiontext_wareid]").val();
        var max_row_count = ld('#' + popupobj.divid + " [name=rowcnt]").val();// document.getElementById('rowcnt').value;
        var row_cnt = 0;
        var trobjs = popupobj.getTrObjsByDelType('no');//获取单据分录没有删除的行
        var deltrobjs = popupobj.getTrObjsByDelType("yes");//获取删除的行
        var totalrows = ld(trobjs).length + ld(deltrobjs).length;
        var addrowindex = 1;
        while (rowid < totalrows) {
            var nextrowobj = ld(tableobj).find("tr[rowinex=" + (rowid + addrowindex) + "]");//获取下一行
            if (ld(nextrowobj).length > 0 && ld(nextrowobj).attr("detaildeleted") == 'no') {

                row_cnt = rowidid + addrowindex;
                break;
            }
            addrowindex++;
        }

        /*for(var i = 1; i <= max_row_count; i++){
			if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val() == 0){
				row_cnt++;
			}
		}*/

        if (row_cnt > rowid) {
            var confirm_str = arrJsPopLabel['whethertochangethewarehouse'];
            confirm_str = confirm_str.replace('{warename}', warename);
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                var next_rowid = rowid + 1;
                for (var i = next_rowid; i <= totalrows; i++) {
                    var nextrowobj = ld(tableobj).find("tr[rowinex=" + i + "]");//获取下一行
                    //	if(ld(nextrowobj).find("  [name=hidden_rowid]").val() == 0){
                    ld(nextrowobj).find(" [name=wareid]").val(wareid);
                    ld(nextrowobj).find(" [name=cmb_span_optiontext_wareid]").val(warename);

                    //	}
                }
                return true;
            });
        }
    }
    return false;
}


function checkinputpronum(x, z) {
    var y = document.getElementById(x).value;

    if (parseInt(y) > parseInt(z)) {
        //数量不能超过原合同订单数量！
        var confirm_str = arrJsPopLabel['CANOTEXCEEDORIGINALCONTRACTNUM'];
        audioRemindsMsg("", "", module, "", "", confirm_str);
        document.getElementById(x).value = z;
    }

}

var httpreq = null;

function FindDuplicate() {

    var popupobj = CrmPopup.getPopupObj('last');
    //ls 20231023 XUQIU1001972 库存参数增加“设置单据分录明细录入重复产品时是否需要提示”参数
    if(typeof popupobj.sys_deploy !='undefined' && popupobj.sys_deploy.sys_464 != undefined){
        if (popupobj.sys_deploy.sys_464 == 'no') {
            return true;
        }
    }
    var trobjs = popupobj.getTrObjsByDelType("no");//获取没有删除的行
    var rowcnt = ld(trobjs).length;// document.getElementById('rowcnt').value

    var duplicate = false, iposition = '', positions = '', duplicate_products = '', duplicate_products_array = [],
        pro_i = 0;

    var product_id = {};
    var product_name = {};
    var haigetip = "";
    //product_id[1] = getObj("hdnProductId1").value;
    //product_name[1] = getObj("productname1").value;
    var tiprow = 1;
    //for (var i=1;i<=rowcnt;i++)
    ld.each(popupobj.detaildatavalue_arr, function (tmpvalueindex, tmpvalueinfo) {
        var hdnProductId = tmpvalueinfo.productid;

        if (hdnProductId > 0) {

            if (product_id[hdnProductId + "id"] == undefined) {
                product_id[hdnProductId + "id"] = 1;
            } else {
                //zkt 20230217 BUG0061742kfbcrm 销售机会，新增，单据分录添加一个商品，点击添加行，在空白行点击添加同一个商品，点击保存，无法保存单据
                product_id[hdnProductId + "id"] = 2;
                duplicate_products_array[pro_i] = ld(trobjs[tmpvalueindex]).find("#productname").val();//getObj("productname"+i).value;
                pro_i++;
                duplicate = true;
            }
            if (account_version == 'haige' && popupobj.module == 'Quotes') {
                var haveordercount = ld(this).find(" [name=haveordercount]").val();
                var quantity = tmpvalueinfo.quantity;//ld(this).find("#quantity").val();
                if (eval(quantity) < haveordercount) {
                    haigetip += "第" + tiprow + "行产品“数量”不允许小于“已下单数量<br>";
                }
            }
            tiprow++;

        }

    })

    //朗捷所有带产品分录的模块，去掉“产品重复的提示信息”
    if (CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() != undefined && CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() == 'langjie') {
        duplicate = false;
    }

    //@edit:liushuai,2020-08-31,reason:ID1001039/艾迈柯思“赠品提醒”个性化开发(合同订单模块去掉“产品重复的提示信息”)
    if (CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() != undefined && CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() == 'amks' && popupobj.module == 'SalesOrder') {
        duplicate = false;
    }


    if (duplicate) {
        /**
         * edit:chj
         * date:2014-9-4
         * reason:服务合同选择产品保存、编辑时，不同产品条目数不能超过一次
         * other:011191: 服务合同：保存时，做出判断，若存在相同的产品，希望给出提示“不能录入多个相同的产品”，并且不能保存。
         * des:提出该bug的原因是bug:11185
         *
         if(document.EditView.module.value == 'ServiceContracts')
         {
            alert(arrJsPopLabel['THEFOLLOWINGITEMSHAVEBEENSELECTEDMORETHANONCE']+"\n"+duplicate_products);
            return false;
        }
         else
         {*/

        duplicate_products = duplicate_products_array.join(" \n");
        //海格存在重复记录不允许保存
        if (account_version == 'haige' && popupobj.module == 'Quotes') {
            var haigenosaveremind = arrJsPopLabel['THEFOLLOWINGITEMSHAVEBEENSELECTEDMORETHANONCE'] + arrJsPopLabel['Savefailed'] + "!<br><br>" + duplicate_products;
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", haigenosaveremind);
            return false;
        }
        else if (account_version == 'haige' && popupobj.module == 'Potentials') {
            var haigenosaveremind = arrJsPopLabel['THEFOLLOWINGITEMSHAVEBEENSELECTEDMORETHANONCE'] + arrJsPopLabel['Savefailed'] + "!<br><br>" + duplicate_products;
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", haigenosaveremind);
            return false;
        }
        else if (account_version == 'climaveneta' && popupobj.module == 'CustomForm45') {
            //故障工时单保存时，不需要判断并提示：产品已经选择超过一次，
        } else {
            var duplicate_product = 'permit_remind';
            if(!empty(popupobj.module_setting) && !empty(popupobj.module_setting.duplicate_product)){
                duplicate_product = popupobj.module_setting.duplicate_product;
            }

            if(duplicate_product == 'permit_remind'){
                //允许保存但给出提示,需要手动确认
                var confirm_str = arrJsPopLabel['THEFOLLOWINGITEMSHAVEBEENSELECTEDMORETHANONCE'] + arrJsPopLabel['DOYOUWANTTOCONTINUE'] + "\n\n" + duplicate_products;
                if (!confirm(confirm_str)) {
                    return false;
                }
            }else if(duplicate_product == 'nopermit'){
                //不允许保存给出提示,
                var confirm_str = arrJsPopLabel['THEFOLLOWINGITEMSHAVEBEENSELECTEDMORETHANONCE'] + arrJsPopLabel['NotAllowSave'] + "<br>" + duplicate_products;
                MessagePopup.TipOne_warning(confirm_str);
                return false;
            }else{
                //允许保存
                return true;
            }
        }


    }
    if (haigetip != '') {
        RemindsMsg("", "LdPopWidth400px", "", "yes", "", haigetip);
        return false;
    }
    return true;
}

/*
* reason:控制面板 - 税率设定
*/
function ValidateTax(txtObj) {
    temp = /^\d+(\.\d\d*)*$/.test(document.getElementById(txtObj).value);
    if (temp == false)
        alert(alert_arr.ENTER_VALID_TAX);
}

function loadTaxes_Ajax(curr_row) {
    var popupobj = CrmPopup.getPopupObj("last");
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + curr_row + "]");

    var totalAfterDiscountobj = ld(rowobj).find(" [name=totalAfterDiscount]");
    if (totalAfterDiscountobj.length <= 0)//盘点没有税，gp
    {
        return;
    }
    var lineItemType = ld(rowobj).find(" [name=lineItemType]").val();// document.getElementById("lineItemType"+curr_row).value;
    // var hdnProductIdobj = ld(rowobj).find(" [name=hdnProductId]");//document.getElementById("hdnProductId"+curr_row).value
    var productid=popupobj.detaildatavalue_arr[curr_row-1].hdnProductId
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=' + lineItemType + '&action=' + lineItemType + 'Ajax&file=InventoryTaxAjax&productid=' + productid + '&curr_row=' + curr_row + '&productTotal=' + totalAfterDiscountobj.html(),
            onComplete: function (response) {
                var result = response.responseText;
                if (response.responseText.indexOf("###SUCCESS###") > 0) {
                    var results = response.responseText.split('###SUCCESS###');
                    result = results[1];
                }
                ld(rowobj).find(" [name=tax_div]").html(trim(result));
                //document.getElementById("taxTotal"+curr_row).innerHTML = getObj('hdnTaxTotal'+curr_row).value;
                ld(rowobj).find(" [name=taxTotal]").html(ld(rowobj).find(" [name=hdnTaxTotal]").val());
                // Ajax添加税率文本框后，给税率文本框批量绑定事件 tujt 2014-10-10
                taxinputcls.TaxFldEventBind(curr_row);
            }
        }
    );

}


/*
* reason:控制面板 - 税率设定 - 添加税
*/
function fnAddTaxConfigRow(sh) {

    var table_id = 'add_tax';
    var td_id = 'td_add_tax';
    var label_name = 'addTaxLabel';
    var label_val = 'addTaxValue';
    var add_tax_flag = 'add_tax_type';

    if (sh != '' && sh == 'sh') {
        table_id = 'sh_add_tax';
        td_id = 'td_sh_add_tax';
        label_name = 'sh_addTaxLabel';
        label_val = 'sh_addTaxValue';
        add_tax_flag = 'sh_add_tax_type';
    }
    var tableName = document.getElementById(table_id);
    var prev = tableName.rows.length;
    var count = rowCnt;

    var row = tableName.insertRow(0);

    var colone = row.insertCell(0);
    var coltwo = row.insertCell(1);


    document.getElementById('taxconfig').style.display = 'none';
    colone.className = "taxName";
    //coltwo.className = "cellText";

    colone.innerHTML = "<input type='text' id='" + label_name + "' name='" + label_name + "' value='" + tax_labelarr.TAX_NAME + "' class='txtBox' onclick=\"this.form." + label_name + ".value=''\";/>";
    coltwo.innerHTML = "<input type='text' id='" + label_val + "' name='" + label_val + "' value='" + tax_labelarr.TAX_VALUE + "' class='txtBox' onclick=\"this.form." + label_val + ".value=''\";/>";

    document.getElementById(td_id).innerHTML = "<input type='submit' name='Save' value=' " + arrJsPopLabel['SAVE'] + " ' class='saveauto b_radius3' onclick=\"this.form.action.value='TaxConfig'; this.form." + add_tax_flag + ".value='true'; this.form.parenttab.value='Settings'; return validateNewTaxType('" + label_name + "','" + label_val + "');\">&nbsp;<input type='submit' name='Cancel' value=' " + arrJsPopLabel['CANCEL'] + " ' class='cancelauto b_radius3' onclick=\"puyoungJS_DialogBox.block();this.form.action.value='TaxConfig'; this.form.module.value='Settings'; this.form." + add_tax_flag + ".value='false'; this.form.parenttab.value='Settings';\">";
}

/*
* reason:控制面板 - 税率设定
*/
function validateNewTaxType(fieldname, fieldvalue) {
    if (trim(document.getElementById(fieldname).value) == '') {
        var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECTTAX'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }
    if (trim(document.getElementById(fieldvalue).value) == '') {
        var confirm_str = arrJsPopLabel['ENTERCORRECTTAX'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    } else {
        var temp = /^(0|[1-9]{1}\d{0,})(\.(\d{1}\d{0,}))?$/.test(document.getElementById(fieldvalue).value);
        if (!temp) {
            var confirm_str = arrJsPopLabel['ENTERPOSITIVENUMBER'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return false;
        }
    }
    puyoungJS_DialogBox.block();
    return true;
}

/*
* version:6.1单据分录自定义
* edit:chj
* date:2015/6/5
* reason: 默认给产品明细行的第一列增加上下移动按钮
*/
function fnAddProductTdBtn() {
    var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    var  rowcntobj = popupobj.selectproductobj.rowcntobj;
    var operation_rowobj = popupobj.selectproductobj.operation_rowobj;
    var trobjs = popupobj.getTrObjsByDelType("no");
    var trobjs_len = ld(trobjs).length;

    if (popupobj.module == 'CashBill' || popupobj.module == 'SendCashBill') {

        popupobj.detail2mainformulaobj.changeRowEvent();
    }
    //朗捷 2)空运订单回传不显示新增/删行/移动行的按钮
    if (ld(popupobj.selectproductobj.versionhtmlobj).val()!= undefined && ld(popupobj.selectproductobj.versionhtmlobj).val() == 'langjie' && popupobj.module == 'CustomForm25') {
        return false;
    }

    if (trobjs_len > 0) {
        //明细没有操作列
        if (operation_rowobj.length > 0) {
            if (operation_rowobj.val() == 1) {
                return;
            }
        }
        var sum_row = 0;
        var row_hidden_array = Array();

        var count = rowcntobj.val();
        var module = popupobj.module;

        var k = 0;
        var tableobj = popupobj.getDetailTableObj();

        var CopyRowhtml = '<span class="icon-homeimg icon-copy marR8" title="' + commonLabels.CopyRows + '" onclick="TabDetailCopyRowAfterassingIndex(ld(this))"></span>';

        var Tr;
        var iPrevCount, seqno;
        var rowindex = 1;
        var tdobj_width = "25mm";
        if (trobjs_len > 1) {
            //for(var i = 0; i <sum_row; i++){
            ld.each(trobjs, function () {
                ld(this).attr("rowindex", rowindex);//拖动重新定义行号
                ld(this).attr("row", rowindex);//拖动重新定义行号
                ld(this).attr("name", "row" + rowindex);//拖动重新定义行号

                iPrevCount = ld(this).attr("rowindex");

                seqno = iPrevCount;
                var tr = iPrevCount + 1;
                var tdobj = ld(this).find("td[seqno=yes]");


                if (iPrevCount == 1) {
                    //edit:can 2020-09-24 单据分录明细中增加拖动功能
                    ld(tdobj).html('<span class="ld-text-inner ld-text-inner-first span_seq_no" span_seq_no="yes" style="width:' + tdobj_width + ';display:block">' + seqno + '</span><div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;width:' + tdobj_width + '"> <span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows
                        + '" onclick="TabDetailAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
                        + '" ></a> <span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows
                        + '" style="cursor:move;"></span></div>');

                } else if (iPrevCount == trobjs_len) {
                    ////edit:can 2020-09-24 单据分录明细中增加拖动功能
                    ld(tdobj).html('<span class="ld-text-inner ld-text-inner-first span_seq_no" span_seq_no="yes" style="width:' + tdobj_width + ';display:block">' + seqno + '</span><div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;width:' + tdobj_width + '"><span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows
                        + '"  onclick="TabDetailAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
                        + '" ></a> <span class="drag-handle icon-layout2 icon-layout2-move"  title="' + commonLabels.DragRows
                        + '" style="cursor:move;"></span></div>');
                } else {
                    ////edit:can 2020-09-24 单据分录明细中增加拖动功能
                    ld(tdobj).html('<span class="ld-text-inner ld-text-inner-first span_seq_no" span_seq_no="yes" style="width:' + tdobj_width + ';display:block">' + seqno + '</span><div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;width:' + tdobj_width + '"><span class="icon-layout3 icon-layout3-add" title="'
                        + commonLabels.AddRows + '"  onclick="TabDetailAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="'
                        + commonLabels.DeleteRows + '"></a><span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows
                        + '"  style="cursor:move;"></span></div>');
                }
                ld(tdobj).css('text-align', 'center');
                rowindex++;
            })
            //}
            //克莱门特
            //if(document.getElementById('version_account') != undefined && document.getElementById('version_account').value == 'climaveneta' && module!=undefined && (module == 'PurchaseInquiryOrder' || module == 'OutboundOrder')){
            if (ld('#' + popupobj.divid + ' [name="version_account"]').length > 0 && ld('#' + popupobj.divid + ' [name="version_account"]').get(0).value === 'climaveneta' && module != undefined && (module == 'PurchaseInquiryOrder' || module == 'OutboundOrder')) {
                ld('.icon-sdel2').hide();
            }
        } else if (trobjs_len == 1) {
            var rowobj = ld(tableobj).find("[rowindex=1]");
            var tdobj = ld(rowobj).find("td[seqno=yes]");
            // var tdobj_width=ld(tdobj).css("width");

            ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2) > td[seqno=yes]').html('<span class="ld-text-inner ld-text-inner-first span_seq_no" span_seq_no="yes" style="width:' + tdobj_width + ';display:block">1</span><div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;width:' + tdobj_width + ';"><span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows + '"  onclick="TabDetailAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '</div>');
        } else {
            ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2) > td[seqno=yes]').html('');
        }

        //edit:can 2020-11-24 43388: （https://61mis.com/kfbcrm [^]）（美迪医疗内镜维修）财务管理-收款单-新建；关联多个销售发票保存，之后再一次进行编辑保存，下方的收款信息只会显示一个发票的信息（应该是关联了几个销售发票就显示有几行销售发票的信息）
        ld('#' + popupobj.divid + ' table[name="proTab"]:first').find(" .dragtrrow:first").attr("rowindex", 1);
        ld('#' + popupobj.divid + ' table[name="proTab"]:first').find(" .dragtrrow:first").attr("row", 1);
        ld('#' + popupobj.divid + ' table[name="proTab"]:first').find(" .dragtrrow:first").attr("name", "row" + 1);
        ld('#' + popupobj.divid + ' table[name="proTab"]:first').find(" .dragtrrow:first").find(' td[seqno=yes]').css('text-align', 'center');
    }

}

function addProduct(parentwindow) {
    if (parentwindow.document.getElementById('productdeploy') != undefined && parentwindow.document.getElementById('productdeploy').value == 0) {
        if ((parentwindow.document.getElementById('purchaseorder_id') != undefined && parentwindow.document.getElementById('purchaseorder_id').value != '') || (parentwindow.document.getElementById('salesorder_id') != undefined && parentwindow.document.getElementById('salesorder_id').value != '')) {
            var confirm_str = arrJsPopLabel['SELECTPRODUCTLINEITEM'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return false;
        }
    }
    return true;
}

/*
* version:V6.1：单据分录自定义
* edit:chj
* date:2015/6/5
* reason: 产品明细添加行
*/
var addRow_finished = false;

//分录自定义 - 下拉框
function setInventoryPickListContent(popupobj) {
    var parentwindow = window;


    var rowcnt = ld("#" + popupobj.divid + " [name=rowcnt]").val();// parentwindow.document.getElementById('rowcnt').value;
    var picklistcontent = popupobj.picklistcontent;//eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
    if (picklistcontent != null && picklistcontent != undefined && picklistcontent != "") {
        for (var rowid = 1; rowid <= rowcnt; rowid++) {
            for (var k = 0; k < picklistcontent.length; k++) {
                //下拉框
                var fieldname = picklistcontent[k].fieldname + rowid;
                if (picklistcontent[k].productdetail == 'yes') {
                    popupobj.picklistobjarray[fieldname] = new cls_picklist(fieldname, picklistcontent[k].optionvalue);
                }
            }
        }
    }

}

function TabDetailCopyRowAfterassingIndex(btn_jqueryobj) {
    //多选框导致clone 和html方式无法使用
    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = popupobj.getTrObjByChild(btn_jqueryobj);
    TabDetailAddRowAfterassingIndex(btn_jqueryobj);
    var rowid = parseInt(ld(rowobj).attr("rowindex"));
    var nextrowindex = parseInt(rowid) + 1;
    var copyrowobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]").find("tr[rowindex=" + nextrowindex + "]");


    ld.each(ld(rowobj).find("span"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        ld(copyrowobj).find("#" + detailcolumname).html(ld(this).html());

    })
    ld.each(ld(rowobj).find("textarea"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        ld(copyrowobj).find("#" + detailcolumname).val(ld(this).val());

    })
    ld.each(ld(rowobj).find("[type=text]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        if (detailcolumname != undefined)
            ld(copyrowobj).find("#" + detailcolumname).val(ld(this).val());
        else {
            var tmpid = ld(this).attr("id");
            if (tmpid != undefined)
                ld(copyrowobj).find("#" + tmpid ).val(ld(this).val());
        }

    })
    ld.each(ld(rowobj).find("[type=hidden]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        if (detailcolumname != undefined)
            ld(copyrowobj).find("#" + detailcolumname).val(ld(this).val());
        else {
            var tmpid = ld(this).attr("id");
            if (tmpid != undefined)
                ld(copyrowobj).find("#" + tmpid).val(ld(this).val());
        }

    })
    ld.each(ld(rowobj).find("[type=checkbox]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");

        ld(copyrowobj).find("#" + detailcolumname).prop("checked", ld(this).prop("checked"));


    })
    ld.each(ld(rowobj).find("select"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        var multiple = ld(this).attr("multiple");

        if (multiple == undefined)
            ld(copyrowobj).find("#" + detailcolumname).val(ld(this).val());
        else {
            ld(copyrowobj).find("#" + detailcolumname).val(ld(this).val());
            ld(copyrowobj).find("#" + detailcolumname).select2({
                closeOnSelect: true,
                dropdownParent: ld("#" + popupobj.divid)
            });
        }

    })
    popupobj.fieldformulaobj.CountsubTotal();//小计
    //计算主表公式
    popupobj.detail2mainformulaobj.changeRowEvent();
}

function TabDetailAddRowAfterassingIndex(btn_jqueryobj) {
    var popupobj = CrmPopup.getPopupObj('last');
    //popupobj.selectproductobj.getMethod();
    var rowobj = popupobj.getTrObjByChild(btn_jqueryobj);
    //alert(ld(rowobj).attr("rowindex"));
    var rowid = parseInt(ld(rowobj).attr("rowindex"));
    fnAddTabDetailRow.afterrowindex = rowid;
    fnAddTabDetailRow.webUpload_rowindex = rowid + 1;//根据行号给分录图片字段注入上传事件，“添加行”和“复制行”会调用该方法，“新增”按钮不会调用
    fnAddTabDetailRow(popupobj.module);

    //ShowSequence(popupobj);	/////////////////////////


    //设置明细字段的多选框和单选框
    //zkt 20230330 BUG0063885  付款单->新建，选择源单（没有启用自动带出所选源单的分录明细参数）后，【复制】明细行，没有带出源单明细信息
    popupobj.SetDetailFieldControl(rowid);
    //XUQIU1000651  zxm 20220909
    // 系统设置->单据分录定制，增加“设置冻结前几列”参数
    getJsScript('include/js/freezeEntriesColumns.js', function () {
        var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,'proTab');
        freezeEntriesColumnsobj.freezeTheadAndBody();
    });
    // getJsScript('include/js/freezecolumns.js', function () {
    //     freezecolumnsObj.init('proTab');//冻结列类初始化
    //     freezecolumnsObj.freezeThColumn('set-sticky');
    // });

}

//chj 2021/8/16 费用模块， 清除表体内容
function fnEmptyTabDetailRow(module) {
    var popupobj = CrmPopup.getPopupObj('last');
    var tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");
    var trobjs = popupobj.getTrObjsByDelType('no');

    if (ld(tableobj).find("tr[detaildeleted=no]").length >= 1) {
        //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
        Detaildatachange_byrowindexoperation(popupobj,'before','deleteall');
        ld.each(trobjs, function (tmprowindex, tmprowobj) {
            var rowid = parseInt(tmprowindex) + 1;
            var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
            ld(delrowobj).remove();
        });
        Detaildatachange_byrowindexoperation(popupobj,'after','deleteall');//-分录删除后
        fnAddTabDetailRow(module);
    }
    return;
}

//editor:gyq_161 reason:新增费用报销等源单分录模块明细   2019/11/27 16:21
function fnAddTabDetailRow(module) {
    var parentwindow = window;
    if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }
    var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);

    //获取当前明细总行数
    //var rowcnt = parentwindow.document.getElementById('rowcnt').value;
    //var rowcnt = ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value;
    var trobjs = popupobj.getTrObjsByDelType('no');
    rowcnt = ld(trobjs).length;
    if (isNaN(rowcnt)) {
        rowcnt = 0;
        ld('#' + popupobj.divid + ' [name="rowcnt"]').val(0);
    }
    //parentwindow.document.getElementById('rowcnt').value = eval(rowcnt) + 1;
    //  ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value = eval(rowcnt) + 1;
    var count = eval(rowcnt) + 1;
    if (fnAddTabDetailRow.webUpload_rowindex <= 0)//"新增行"
        var rowindex = count;
    else
        var rowindex = fnAddTabDetailRow.webUpload_rowindex;//“添加行”和“复制行”
    if(popupobj.createdtype == 'create' || popupobj.createdtype == 'quickcreate'){
        var page_mode = 'create';
    }else{
        var page_mode = 'edit';
    }
    var url = 'index.php?module=Users&action=UsersAjax&file=addTabDetailsHtmlRow&frommodule=' + module + '&rowid=' + rowindex + '&pagemode=' + page_mode;
    //zkt 收付款单，获取源单类型，
    if (module == 'CashBill' || module == 'SendCashBill') {
        var selectsource = ld("#" + popupobj.divid).find('select[id=selectsource]').val();
        url += '&sourcemodule=' + selectsource;
    }
    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录添加前
    Detaildatachange_byrowindexoperation(popupobj,'before','add',rowindex-1,rowindex);

    http_reqfield = createfieldXMLHTTP();
    http_reqfield.open("POST", url, false);
    addRow_finished = false;
    http_reqfield.onreadystatechange = AddTabDetailRow;
    http_reqfield.setRequestHeader("If-Modified-Since", "0");
    http_reqfield.send();


    //  ShowSequence(popupobj);
    if (addRow_finished == true) {

        fnAddTabDetailRow.ReSetRow(rowindex);

        //duan 20240926 分录绑定公共切换事件
        if(!empty(popupobj.common_field_event_obj)){
            popupobj.common_field_event_obj.setEntryEvent(rowindex);
        }

        if (popupobj.module == 'CashBill' || popupobj.module == 'SendCashBill') {
            if (popupobj.fieldformulaobj != undefined) {
                popupobj.fieldformulaobj.CountsubTotal();//小计
            }

            //edit:can 20230103  60343 付款单、收款单模块，如果同一个客户，我选择这个客户几张入库单进行付款或者出库单进行收款，比如选
            popupobj.detail2mainformulaobj.setRowEvent(rowindex);
        } else
            popupobj.fieldformulaobj.CountsubTotal();//小计

        //edit:can 20230619 68357  项目汇报模块，分录如果新增一条新的，如果没有填写值，对应表头的字段不会更新为空。如项目风险、项目状况这两个字段对比。项目汇报单：PR2023061553
        popupobj.detail2mainformulaobj.changeRowEvent();
        // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（非产品分录新增行）
        if (!empty(popupobj.detailimage_arr)) {
            for (var i = 0; i < popupobj.detailimage_arr.length; i++) {
                var fileuploader = ld("#" + popupobj.divid + " tr[rowindex=" + rowindex + "] [detailfieldname=" + popupobj.detailimage_arr[i].fieldname + "] div[name=" + popupobj.detailimage_arr[i].fieldname + "]");
                if (fileuploader.length > 0) {
                    var uploadFile = new WebUploadFile();
                    globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                    uploadFile.setDetailEvent(globalWebUploadType, fileuploader, popupobj, i, rowindex);
                }
            }
        }
        fnAddTabDetailRow.webUpload_rowindex = 0;
        //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录添加后
        Detaildatachange_byrowindexoperation(popupobj,'after','add',rowindex-1,rowindex);
        getJsScript('include/js/freezeEntriesColumns.js', function () {
            var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,'proTab');
            //这里不需要重新冻结所有 只需要冻结新增行即可
            var rowobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]").find("tr[rowindex=" + rowindex + "]");
            freezeEntriesColumnsobj.getPositionLeftArr();//获取宽度数组
            var detailfieldname = ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').attr("head_detailfieldname");
            freezeEntriesColumnsobj.freezeTbodyColumn(rowobj,99998);
            if (parseInt(rowindex) == 1)
                freezeEntriesColumnsobj.freezeTbodyColumn(rowobj, ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').css('zIndex'));
            else
                freezeEntriesColumnsobj.freezeTbodyColumn(rowobj, ld(popupobj.getDetailTableObj()).find(" tr[rowindex=" + (rowindex - 1) + "]").find("td[detailfieldname=" + detailfieldname + "]").css('zIndex'));
        });
        // zxm 20241012
        if(popupobj.setObjEventArr){
            ld.each(popupobj.setObjEventArr,function(i,eventfun){
                eventfun();
            })
        }
        return eval(rowcnt) + 1;
    }

    return '';
}

fnAddTabDetailRow.ReSetRow = function (rowindex) {
    var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    var module = popupobj.module;
    popupobj.fieldruleobj.resetDetailColumns();//布局规则，重新设置分录表头的显示和隐藏
    popupobj.fieldformulaobj.setEvent(rowindex);//给新增的行单元格添加事件

    popupobj.SetDetailFieldControl(rowindex);//下拉框
    var rowobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]").find("tr[rowindex=" + rowindex + "]");

    //zkt 20211229 0049407: 【享暨】V8.4.2.8（http://xiaoshou360.com/xs/xjsy [^]）工资表：输入了单价和工天后价格却不出来，先保存后退出再进入就可以输入，例如：ZDYBD21-63（详情见附件和说明）
    //第一行行连续点击新增行图标，则第三行字段公式不计算
    popupobj.fieldformulaobj.setAllRowEvent();


    // 朗捷特殊判断  start
    if (CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() === 'langjie') {
        // 客服下单->空运订单->分单号自动生成
        if (module == 'CustomForm24' && ld("#" + popupobj.divid + " [name=flight_date]").val() != '') {
            // 为新加的一行添加订单号
            getAirOrderNumberadd('add', eval(rowindex));
        }
        // 客服下单->报关单草单->报关类型与单据分录的特殊控制
        if (module == 'CustomForm22') {
            HideDetail();
        }
    }
    // END
    //zxm  2020-1209 库博特殊开发 增加的新行 将上一行的数据复制过来
    if (CrmPopup.findHtmlobj(popupobj.divid, 'version_account').val() === 'kubo' && module == 'Expense') {
        setNewRowValueCopy('add', eval(rowindex));
    }

    if (popupobj.module == 'TimeSheet') {

        onChangeTimeType(rowindex);
    }
    setInventoryPickListContent(popupobj);

    //duan 20240926 整行操作后调用公共变化事件
    popupobj.common_field_event_obj.setAllEntryEvent();
    popupobj.common_field_event_obj.common_all_entry_changefun(rowindex);
}
fnAddTabDetailRow.afterrowindex = 0;
fnAddTabDetailRow.webUpload_rowindex = 0;

function AddTabDetailRow() {
    if (http_reqfield.readyState == 4) {

        var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
        var trobjs = popupobj.getTrObjsByDelType("no");

        var rowcnt = ld(trobjs).length;// ld('#'+popupobj.divid+' [name="rowcnt"]').get(0).value;

        if (isProductClear == 'yes') {
            isProductClear = 'no';
            fnAddProductTdBtn();
        } else {
            //ld("#proTab > tbody > tr:eq("+eval(rowcnt)+")").after(http_reqfield.responseText);
            //  ld('#'+popupobj.divid+' table[name="proTab"]:first > tbody > tr:eq('+eval(rowcnt)+")").after(http_reqfield.responseText);
            var tableobj = popupobj.getDetailTableObj();
            if (fnAddTabDetailRow.afterrowindex <= 0)
                var rowobj = ld(tableobj).find("tr[rowindex=" + rowcnt + "]");
            else
                var rowobj = ld(tableobj).find("tr[rowindex=" + fnAddTabDetailRow.afterrowindex + "]");
            if (ld(rowobj).length <= 0) {
                var rowobj = ld(tableobj).find("tr[tag=trhead]");
                ld(rowobj).after(http_reqfield.responseText);
            } else
                ld(rowobj).after(http_reqfield.responseText);
            // ShowSequence(popupobj);	/////////////////////////

            //BUG20241008-51  	有产品分录的单据比如销售订单--选择产品，点击新增的时候应该定位到最后一行
            ld("#" + popupobj.divid + " [name=productDiv]").scrollTop(ld(tableobj).height());

            fnAddProductTdBtn();
        }
        addRow_finished = true;
        fnAddTabDetailRow.afterrowindex = 0;
    }


}

/*
* version:V6.1：单据分录自定义
* edit:chj
* date:2015/6/5
* reason: 产品明细删除行
*/
function deleteRow(rowid) {
    var event = event || window.event;
    event.stopPropagation();
    //rowid:没有作用，通过点击的删除按钮获取按钮所在行的对象
    var srcElement = event.srcElement || event.target;//获取删除按钮
    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = popupobj.getTrObjByChild(ld(srcElement)) || popupobj.find('#proTab').find(`[rowindex=${rowid}]`);//获取删除按钮所在的行对象

    if(ld(rowobj).attr("rowindex")!=undefined)
    {    //edit:can  20230302 622111 61order 合同订单新建点取消点不动，可以找路总还原bu
        //布局规则
        rowid = ld(rowobj).attr("rowindex");
    }

    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
    Detaildatachange_byrowindexoperation(popupobj,'before','delete',rowid,rowid);

    var tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");
    if (ld(tableobj).find("tr[detaildeleted=no]").length == 1) {//删除最后一行，清空
        fun_selectproduct.btn_clearProductInfo_Row(rowid);
        ld(tableobj).find("[rowindex=" + rowid + "]").find("td:eq(0)").html('');
        return;
    } else if (ld(tableobj).find("tr[rowindex=" + rowid + "]").length > 0) {//document.getElementById("row"+rowid) != undefined)
        var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
        ld(delrowobj).remove();
        if (popupobj.detailfieldmodule == 'Products')//edit:can 2020-10-22 42967: （8.2.7安装包）加班单/请假单新建界面，分录明细中点击添加行+号图标后，再删除行，再点击添加行+号图标界面，分录明细下方报错
        {
            ld(tableobj).find("tr[havemouseevent=yes]").attr("havemouseevent",'no');

            popupobj.selectproductobj.fnAddProductTdBtn();
        }

        else
            fnAddProductTdBtn();
        if (ld("#" + popupobj.divid + " [name=module]").length > 0 && ld("#" + popupobj.divid + " [name=module]").get(0).value === 'TimeSheet') {
            setTimeSheet();
        }
    }
    //edit:can 20230330 63805 费用报销模块，新增分录多行后有了合计金额，再减少一行，合计金额不随之减少；
    if (popupobj.detailfieldmodule == 'Products')
        popupobj.detaildatavalue_arr.splice(rowid - 1, 1);//删除数组的一个值
    popupobj.selectproductobj.changeseqno();//重置分录行号
    popupobj.fieldformulaobj.CountsubTotal();//重新计算小计值 合计值
    popupobj.fieldformulaobj.setAllRowEvent();//重设行事件
    popupobj.detail2mainformulaobj.changeRowEvent();

    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除后
    Detaildatachange_byrowindexoperation(popupobj,'after','delete',rowid,rowid);

    //duan 20240926 整行操作后调用公共变化事件
    popupobj.common_field_event_obj.setAllEntryEvent();
    popupobj.common_field_event_obj.common_all_entry_changefun(rowid);
}

/*
* chj：系统参数：出入库单，不能选择源单以外的产品”
*/
function checkaddpriduct(module, type) {

    if (module == 'Stock' && type != 'Stock') {
        if (document.getElementsByName("purchaseorder_id")[0] != undefined && document.getElementById('purchaseorder_id').value > 0) {
            var pruname = document.getElementById('purchaseorder_name').value;
            //alert("不可以选择"+pruname+"采购订单下的其他产品！");
            var confirm_str = arrJsPopLabel['CANOTCHOOSE'] + pruname + arrJsPopLabel['OTHERPRODUCTSPURCHASEORDER'];
            audioRemindsMsg("", "", module, "", "", confirm_str);
            return false;
        }
    } else if (module == 'OutboundOrder' && type != 'OutboundOrder') {
        if (document.getElementsByName("salesorder_id")[0] != undefined && document.getElementsByName("salesorder_id")[0].value > 0) {
            var salename = document.getElementsByName('salesorder_name')[0].value;
            //alert("不可以选择"+salename+"合同订单下的其他产品！");
            var confirm_str = arrJsPopLabel['CANOTCHOOSE'] + pruname + arrJsPopLabel['OTHERPRODUCTSSALESORDER'];
            audioRemindsMsg("", "", module, "", "", confirm_str);
            return false;
        }
    }

    return true;
}

function changeCurrencyMoney(frommodule, currency_id, before_currency_id) {
    var popupobj = CrmPopup.getPopupObj('last');
    var sourcemodule = '';
    if (CrmPopup.isExistsObj(popupobj.divid, 'selectsource')) {
        sourcemodule = CrmPopup.findHtmlobj(popupobj.divid, 'selectsource').val();
    }


    ld.ajax({
        type: 'post',
        url: 'index.php?module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module=' + frommodule + '&currency_id=' + currency_id + '&before_currency_id=' + before_currency_id + '&sourcemodule=' + sourcemodule

    }).then(function (data) {
        var results = data.split('###SUCCESS###');
        var currencys = results[1].split('|');
        var beforecurrency_rate = parseFloat(currencys[0]);
        var now_currency_rate = parseFloat(currencys[1]);
        var popupobj = CrmPopup.getPopupObj('last');
        var trobjs = popupobj.getTrObjsByDelType("no");

        // var max_row_count =ld("#"+popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;
        // for(var i=1;i<=max_row_count;i++)
        if (frommodule == 'CashBill' || frommodule == 'SendCashBill') {
            //zkt 20220920 BUG0056675收/付款单->页面设置，带产品分录明细，切换单据头的币种字段时，产品分录的币种和单据头保持一致，同时金额应该换算
            BillChangCurrencychangeDetail(popupobj, sourcemodule, now_currency_rate, beforecurrency_rate);
        }
        ld.each(trobjs, function () {
            var that = this;
            if (ld(this).find(" #productcost").length > 0) {
                if (ld.trim(ld(this).find(" #productcost").val()) == '')
                    ld(this).find(" #productcost").val(0)

                var productcost = parseFloat(ld(this).find(" #productcost").val());

                if (parseInt(beforecurrency_rate, 10) == 1)
                    productcost = productcost * now_currency_rate;
                else
                    productcost = parseFloat(productcost / beforecurrency_rate) * now_currency_rate;

                ld(this).find(" #productcost").val(parseFloat(productcost).toFixed(2));
            }
            if (ld(this).find(" #lastlistprice").length > 0) {
                var lastlistprice = parseFloat(ld(this).find(" #lastlistprice").val());

                if (parseInt(beforecurrency_rate, 10) == 1)
                    lastlistprice = lastlistprice * now_currency_rate;
                else
                    lastlistprice = parseFloat(lastlistprice / beforecurrency_rate) * now_currency_rate;
                ld(this).find(" #lastlistprice").val(parseFloat(lastlistprice).toFixed(2));
                ld(this).find(" #span_lastlistprice").html(parseFloat(lastlistprice).toFixed(2));
                //document.getElementById('lastlistprice'+i).value=parseFloat(lastlistprice).toFixed(2);
                // document.getElementById('span_lastlistprice'+i).innerText=parseFloat(lastlistprice).toFixed(2);
            }
            //lasttaxprice
            if (ld(this).find(" #lasttaxprice").length > 0) {
                var lasttaxprice = parseFloat(ld(this).find(" #lasttaxprice").val());

                if (parseInt(beforecurrency_rate, 10) == 1)
                    lasttaxprice = lasttaxprice * now_currency_rate;
                else
                    lasttaxprice = parseFloat(lasttaxprice / beforecurrency_rate) * now_currency_rate;
                ld(this).find(" #lasttaxprice").val(parseFloat(lasttaxprice).toFixed(2));
                ld(this).find(" #lasttaxprice").html(parseFloat(lasttaxprice).toFixed(2));
            }

            /*
				*edit: chj
				*date: 2020/8/27
				*reason: 单据切换币种时，更新单据表体的 换算率 字段
				*/
            if (!empty(currencys[4])) {

                conversion_rate_field = currencys[4].split(',');
                var detaildeleted = ld(this).attr('detaildeleted');
                var hdnProductId = ld(this).find(" [name=hdnProductId]").val();
                //chj 2020/12/21 43816: 易冲（http://171.221.206.240:88/crm/ [^]）新增合同时，选择源单后，来回切换币种，汇率税率出现异常，没有变更。
                if (detaildeleted == 'no' && hdnProductId > 0) {
                    ld.each(conversion_rate_field, function (key, fieldname) {
                        if (ld(that).find(" #span_" + fieldname ).html() != undefined)
                            ld(that).find(" #span_" + fieldname ).html(now_currency_rate);
                        if (ld(that).find(" #" + fieldname ).val() != undefined)
                            ld(that).find(" #" + fieldname).val(now_currency_rate);
                    })
                }
            }

        })
    });
}

//产品明细：币种下拉事件
function updatePrices() {

    var popupobj = CrmPopup.getPopupObj('last');
    //  var System_deploy=ld("#"+popupobj.divid+" [name=SystemArg]").val();//document.getElementById('SYstemArg').value;//判断产品单价是否需要根据客户最近一次购买的产品价格带出，0：是，1：否.
    var prev_cur = ld("#" + popupobj.divid + " [name=prev_selected_currency_id]").get(0);// document.getElementById('prev_selected_currency_id');
    var inventory_currency = ld("#" + popupobj.divid + " [name=inventory_currency]").get(0);// document.getElementById('inventory_currency');
    var before_currency_id = prev_cur.value;
    if (before_currency_id == '' || before_currency_id <= 0.00001) {
        before_currency_id = 1;
    }
    var listprice = ld("#" + popupobj.divid + " [name=hddlistprice]").val();//document.getElementById('hddlistprice').value;
    var accountid = '';
    var frommdoule = '';

    var str = arrJsPopLabel['MSG_CHANGE_CURRENCY_REVISE_UNIT_PRICE'];
    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", str);

    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
        var popupobj = CrmPopup.getPopupObj('last');
        var max_row_count = ld("#" + popupobj.divid + " [name=rowcnt]").val();// document.getElementById('rowcnt').value;
        var trobjs = popupobj.getTrObjsByDelType("no");
        //duan 20240530 切换币种时应该触发字段公式
        if (popupobj.mainfieldformulaobj != undefined) {
            var param = [];
            param['data'] = {'formulafieldname':'currency_id'};
            popupobj.mainfieldformulaobj.startComputer(param);
        }

        var products_list = "";
        var i = 1;
        ld.each(trobjs, function () {
            //if(ld(this).find(" [name=hidden_rowid]").val()==0){//document.getElementById('hidden_rowid_'+i).value == 0
            var productid = ld(this).find(" [name=hdnProductId]").val();// document.getElementById("hdnProductId"+i).value;
            if (i != 1)
                products_list = products_list + "::";
            products_list = products_list + productid;
            i++;
            //}
        })

        if (prev_cur != null && inventory_currency != null)
            prev_cur.value = inventory_currency.value;
        var currency_id = inventory_currency.value;
        var url = 'module=Products&action=ProductsAjax&file=InventoryPriceAjax&currencyid=' + currency_id + '&productsList=' + products_list;

        if (ld("#" + popupobj.divid + " [name=SystemArg]").length > 0) {//document.getElementById('SYstemArg') != undefined
            var System_deploy = ld("#" + popupobj.divid + " [name=SystemArg]").val();//document.getElementById('SYstemArg').value;
            if (System_deploy == 0) {

                if (ld("#" + popupobj.divid + " [name=account_id]").length > 0) {//document.EditView.account_id != undefined
                    accountid = ld("#" + popupobj.divid + " [name=account_id]").val();// document.EditView.account_id.value;
                }

                url += '&accountid=' + accountid;

            }
        }
        //var popupobj=CrmPopup.getPopupObj("last");
        url += '&frommodule=' + popupobj.module;


        //27679: 单据编辑界面产品分录修改币种后不含税单价和含税单价修改后最近价格（未税）和最近价格（含税）也需要修改
        changeCurrencyMoney(popupobj.module, currency_id, before_currency_id);
        ldAjaxHtmlNoProgressobj('index.php',url,function (ajaxhtml) {
            if (trim(ajaxhtml).indexOf('SUCCESS') == 0) {
                var res = trim(ajaxhtml).split("$");
                var res_list = res[1].split("|");
                if (account_version == 'yiwen') {
                    var optionobj_arr = ld("#" + popupobj.divid + " [name=inventory_currency]").find("option");
                    ld.each(optionobj_arr, function () {
                        if (ld(this).val() == before_currency_id) {
                            var before_rate = ld(this).attr("currate");
                            var now_rate = ld("#" + popupobj.divid + " [name=inventory_currency]").find("option:selected").attr("currate");
                            var rowobjs = popupobj.getTrObjsByDelType("no");
                            ld.each(rowobjs, function () {
                                var listpriceobj = ld(this).find("#listprice");
                                var listpricevalue = ld(listpriceobj).val();
                                if (before_rate != 1) {
                                    listpricevalue = listpricevalue / before_rate;

                                }
                                listpricevalue = parseFloat(listpricevalue * now_rate).toFixed(4);
                                ld(listpriceobj).val(listpricevalue);
                            })
                            return false;

                        }
                    })

                    if (popupobj.module == 'Quotes' || popupobj.module == 'SalesOrder') {
                        var rowobj_arr = popupobj.getTrObjsByDelType("no");
                        ld.each(rowobj_arr, function () {
                            CrmPopup.getPopupObj('last').RelatedProductToolFieldtriggcols = [];
                            if (ld(this).find(" #hdnProductId").val() > 0)
                                getRelatedProductToolFieldPriceCallBack(CrmPopup.getPopupObj('last'), ld(this).attr("rowindex"));
                        })
                    }


                } else
                    updatePriceValues(res_list[0], res_list[1]);
                //edit:can reason:16154: 采购退货单>关联创建采购退款单,关于账户关联的问题
                var formobj = document.forms['EditView'];

                if (formobj.bankaccountsetid != undefined) {
                    UpdateBankAccount(formobj.bankaccountsetid, res_list[2]);
                }

                popupobj.fieldformulaobj.changelistprice();//调用公式计算
                popupobj.fieldformulaobj.CountsubTotal();//小计（包括计算合计,整单折扣)

            } else {
                alert(arrJsPopLabel['OPERATION_DENIED']);
            }
        });


    });
    //duan 20240605 点击取消后还原成之前的币种
    ld('input[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
        inventory_currency.value = prev_cur.value;
    });

}

// Function to Update the price for the products in the Inventory Edit View based on the Currency choosen by the User.
function updatePriceValues(pricesList, costlist) {

    if (pricesList == null || pricesList == '') return;
    var prices_list = pricesList.split("::");
    var cost_list = costlist.split("::");
    var have_listPrice_columnname = 'no';
    var popupobj = CrmPopup.getPopupObj('last');
    //var max_row_count =ld("#"+popupobj.divid+ " [name=rowcnt]").val();// document.getElementById('rowcnt').value;
    //var trobjs=
    //max_row_count = eval(max_row_count)-2;//Because the table has two header rows. so we will reduce two from row length
    //zkt 20230512 BUG0066272 修改系统参数基准字段为不含税单价，人民币不含税显示200，切换币种后，如英镑，基准变成含税单价23，应该不含税为基准，不含税23，先选择币种 再选择产品则正常
    for (var i = 0; i < popupobj.fieldformulaobj.objField.length; i++){
        var obj = popupobj.fieldformulaobj.objField[i];
        if (obj.columnname == 'listprice') {
            have_listPrice_columnname = 'yes';
        }
    }

    var products_list = "";
    var trobjs = popupobj.getTrObjsByDelType("no");

    //for(var i=1;i<=max_row_count;i++)
    //edit chj date 2020/11/30 43506: （本地php72，8.3.3版本）销售管理-合同订单-新建（需要补丁）；在订单新建选择产品后，切换 币种 ；点击确定后金额并没有被修正变化
    var i = 0
    ld.each(trobjs, function () {
        //   var hidden_rowidvalue=ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val();
        //	if(hidden_rowidvalue == 0){
        var list_price_elem = ld(this).find(" #listprice");// document.getElementById("listprice"+i);
        var unit_price = prices_list[i]; // Price values index starts from 0
        list_price_elem.val(unit_price);
        if(ld(this).find(" #span_listprice").length>0){
            ld(this).find(" #span_listprice").html(unit_price);
        }
        if (have_listPrice_columnname == 'no')//如果没有不含税单价字段
        {
            //23367: 单据分录自定义中不启用“不含税单价”：明细界面-产品信息 区块，更换币种，单据金额 没有根据 汇率 换算
            //document.getElementById("taxprice"+i).value=unit_price;
            ld(this).find(" #taxprice").val(unit_price);
            //230421 wyt BUG0065115 kfbcrm-自定义表单-新建单据-选择产品后修改币种，含税单价自动修改为0
            popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr.push('taxprice');
            popupobj.fieldformulaobj.finishedcolumncount['taxprice'] = 4;
        }

        // Set Direct Discout amount to 0
        if (ld(this).find(" [name=discount_amount]").length > 0) {// document.getElementById("discount_amount"+i) != undefined){
            var discount_amount = ld(this).find(" [name=discount_amount]");// document.getElementById("discount_amount"+i);

            if (discount_amount != null) discount_amount.val("0");
        }
        i++;
        //taxinputcls.countTaxTotal(i);//计算含税单价（Edit:can);(变量taxinputcls在products.js中)
        //callTaxCalc(i);
        //}
        //38046: （http://www.xiaoshou360.com/KH/suoyu [^]）采购订单模块>选择单据编号为【PO20190905-211】进入编辑界面>产品信息区块：修改币种为美元，修改币种后只将第一行的价格换算成美元。
        //	fieldformulaobj.CountRowFormulaColumn(i);

    })
    //resetSHandAdjValues();
}


/*
edit:chj
2021/9/22
多选模块
*/
function selectMoreModule(module, frommodule, fieldname) {
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = prevpopupobj.divid;
    var formObj = ld("#" + popupobj.divid + " form[name=selectall]");
    var x = formObj.find('input[name="selected_id"]').length;
    var y = 0;
    if (x > 0) {
        var idstring = '';
        var record = '';
        //再次选择时
        if (x === 0) {
            cnt = 2;
            idstring = document.selectall.selected_id.value;
            if (record == '') {
                record = document.selectall.selected_id.getAttribute('billinfo');
            }
            y = 1;
        } else {
            formObj.find('input[name="selected_id"]').each(function (index, element) {
                //获取选中的产品id
                if (ld(this).prop("checked")) {
                    idstring = ld(this).val() + ";" + idstring;
                    record = ld(this).attr('billinfo') + ";" + record;
                    y = y + 1;
                }
            });
            cnt = 1;
        }
    }
    if (y > 0) {
        //alert('index.php?module='+module+'&action='+module+'Ajax&file=getMoreModuleForHref&idstring='+record+"&frommodule="+frommodule);
        ld.ajax({
            url: 'index.php?module=' + module + '&action=' + module + 'Ajax&file=getMoreModuleForHref&idstring=' + record + "&frommodule=" + frommodule,
            type: 'post',
            dataType: 'json',
            success: function (data) {
                CrmPopup.findHtmlobj(divid, fieldname).val(data.result.href_id);
                CrmPopup.findHtmlobj(divid, fieldname + '_label').val(data.result.href_name);
                popupobj.CancelEvent();
            }
        })

    } else {
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }
    return false;
}

/**
 * 收付款单/出库单选择原单
 * @param
 * @returns
 * @author Chj
 */
function selectMoreModuleSource(module) {

    var rowcnt = '';	//原单产品总行数
    var cnt = '';
    var row_array = new Array();
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = prevpopupobj.divid;
    var accvenid = '';
    if (CrmPopup.findHtmlobj(divid, 'vendor_id').val() != undefined && CrmPopup.findHtmlobj(divid, 'module').val() != undefined) {
        var accvenid = CrmPopup.findHtmlobj(divid, 'vendor_id').val();
    }
    if (CrmPopup.findHtmlobj(divid, 'account_id').val() != undefined && CrmPopup.findHtmlobj(divid, 'module').val() != undefined) {
        var accvenid = CrmPopup.findHtmlobj(divid, 'account_id').val();
    }
    var currencyid = '';
    if (CrmPopup.findHtmlobj(divid, 'inventory_currency').val() != undefined) {
        currencyid = CrmPopup.findHtmlobj(divid, 'inventory_currency').val();
    }
    //if(document.selectall.selected_id != undefined){
    var formObj = ld("#" + popupobj.divid + " form[name=selectall]");
    //@edit:ljj,2023-07-25,reason:BUG0069980 kfbcrm-财务管理-收款单-新建-选择源单-停留在未选择单据记录的页面，点击确定不会获取之前页选择的单据记录
    var x = popupobj.chooseSourceInfo_arr.length;
    // if (x > 0) {
    //     var idstring = '';
    //     var record = '';
    //     var rowcnt = 0;
    //     //var wareid =  ld('#warehouse').val();
    //     var wareid = ld("#" + popupobj.divid + " [name=warehouse]").first();
    //     if (CrmPopup.findHtmlobj(divid, 'currencyid').val() != undefined) {
    //         currencyid = CrmPopup.findHtmlobj(divid, 'currencyid').val();
    //     }
    //     if (CrmPopup.findHtmlobj(divid, 'rowcnt').val() != undefined) {
    //         rowcnt = CrmPopup.findHtmlobj(divid, 'rowcnt').val();
    //     }
    //     //editor:gyq_161不确定 reason:带分录模块弹出层   2019/11/25 13:21
    //     //再次选择时
    //     if (x === 0) {
    //         cnt = 2;
    //         idstring = document.selectall.selected_id.value;
    //         if (record == '') {
    //             record = document.selectall.selected_id.getAttribute('billinfo');
    //         }
    //         y = 1;
    //     } else {
    //         formObj.find('input[name="selected_id"]').each(function (index, element) {
    //             //获取选中的产品id
    //             if (ld(this).prop("checked")) {
    //                 if (record === '') {
    //                     record = ld(this).attr('billinfo');
    //                 }
    //                 idstring = ld(this).val() + ";" + idstring;
    //                 y = y + 1;
    //             }
    //         });
    //
    //         cnt = 1;
    //     }
    // }
    //zkt 20230807 BUG0070714  付款单模块，选择源单字段已经选择了对应的采购合同，但是引用的字段不会带出来。如果是从采购合同直接下推付款单就能带出来，如图。
    var record = '';
    if (popupobj.chooseSourceInfo_arr.length > 0) {
        prevpopupobj.selectproductobj.popup_selectsource = true;
        var idstring = '';
        var line_item_ids = new Array();
        var detailid_arr = [];
        var module_record = [];
        ld.each(popupobj.chooseSourceInfo_arr, function (tmpindex, tmpinfo) {
            //idstring= tmpinfo.detailid+";"+idstring;
            detailid_arr.push(tmpinfo.detailid);
            lineitemids = tmpinfo.detailid.split('_');
            line_item_ids.push(lineitemids[0]);
            if (ld.inArray(tmpinfo.record, module_record) == -1) {
                module_record.push(tmpinfo.record);
            }

        })
        prevpopupobj.selectproductobj.sourcemodule_reocrd = module_record.join(",");
        idstring = detailid_arr.join(";");
        if(module_record.length>0){
            record = module_record[0];
        }
    }
    if (popupobj.chooseSourceInfo_arr.length > 0) {

        var id_str = [];
        var ids = idstring.split(';');
        var sourcemodule = formObj.find('input[name="pmodule"]').val();//源单模块tab
        for (var i = 0; i < ids.length; i++) {
            var id_arr = ids[i].split('_');
            id_str[i] = id_arr[0];
        }
        var parentwindow = window;
        //因为一个源单的lineitem_id会存在多个

        var tableName = ld('#' + prevpopupobj.divid + ' table[name="proTab"]').first();
        //var tableName = parentwindow.document.getElementById('proTab');
        var rowcount = tableName.find('tr').length;
        //var rowcount = tableName.rows.length;
        var row_i = 0;
        for (var i = 1; i <= rowcount - 1; i++) {
            //if(parentwindow.ld('#deleterow'+i).val() == 0 || parentwindow.ld('#deleterow'+i).val() == 1){
            var deleterowValue = ld('#' + prevpopupobj.divid + ' input[name="deleterow' + i + '"]').val();
            if (deleterowValue == 0 || deleterowValue == 1) {
                row_i++;
            }
        }
        var urlstring = 'module=' + module + '&action=' + module + 'Ajax&file=EditView&idstring=' + id_str.join(',') + '&sourcemodule=' + sourcemodule + '&before_row=' + row_i + '&Ajax=yes';
        //收付款单选择源单
        if (module == 'CashBill' || module == 'SendCashBill') {
            var urlstring = 'module=' + module + '&action=' + module + 'Ajax&file=getSelectSourceInfo&idstring=' + id_str.join(',') + '&sourcemodule=' + sourcemodule + '&before_row=' + row_i + '&Ajax=yes';
        }
        var currency_id = 1;
        //if(parentwindow.document.EditView.currency_id != undefined){
        if (ld('#' + prevpopupobj.divid + ' [name="currency_id"]').length > 0) {
            currency_id = ld('#' + prevpopupobj.divid + ' [name="currency_id"]').val();
        }
        urlstring += '&currency_id=' + currency_id;


        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                async: false,
                postBody: urlstring,
                onComplete: function (response) {
                    var results = response.responseText.split("$$$$###$$$$");
                    var oldid = CrmPopup.findHtmlobj(prevpopupobj.divid, 'selectlistval').val();
                    var new_id = '';
                    if(!empty(oldid)){
                        new_id = oldid + "," + results[1];
                    }else{
                        new_id = results[1];
                    }

                    CrmPopup.findHtmlobj(prevpopupobj.divid, 'selectlistval').val(new_id);

                    var sourcenos = results[0].split(',');
                    var oldentitytype = CrmPopup.findHtmlobj(prevpopupobj.divid, 'selectlistval_label').val();
                    var oldentitytypes = [];
                    if (oldentitytype != '')
                        oldentitytypes = oldentitytype.split(',');
                    var len = sourcenos.length;

                    for (var i = 0; i < len; i++) {
                        if (ld.inArray(sourcenos[i], oldentitytypes) < 0) {
                            oldentitytypes.push(sourcenos[i]);

                            oldentitytype = oldentitytypes.join(",");
                            CrmPopup.findHtmlobj(prevpopupobj.divid, 'selectlistval_label').val(oldentitytype);

                        }
                    }
                    var result = results[2];
                    if (module == 'CashBill' || module == 'SendCashBill') {
                    } else {
                        addTr('proTab', -4, result)
                    }

                    if (module == 'CashBill' || module == 'SendCashBill') {
                        var popupobj = CrmPopup.getPopupObj("last");
                        popupobj.CancelEvent();
                        //收付款单选择源单带出值
                        var source_array = eval('(' + result + ')') ? eval('(' + result + ')') : JSON.parse(result);
                        var tmpi = 0;

                        ld.each(source_array, function (tmpindex, tmp_tr_dataobj) {
                            var trobjs = prevpopupobj.getTrObjsByDelType("no");
                            var tmptrobj = ld(trobjs).eq(-1);
                            //判断最后一行是否为空行

                            if (ld(tmptrobj).find(' [name=entitytypeid]') != undefined && ld(tmptrobj).find(' [name=entitytypeid]').length > 0) {
                                var tmpenitytypeid = ld(tmptrobj).find(' [name=entitytypeid]').val();

                                if (tmpenitytypeid > 0) {
                                    //最后一行不为空行时增加一行，并重设最后一行对象tmptrobj

                                    fnAddTabDetailRow(module);

                                    trobjs = prevpopupobj.getTrObjsByDelType("no");
                                    tmptrobj = ld(trobjs).eq(-1);


                                }

                            } else {

                                fnAddTabDetailRow(module);

                            }

                            for (var tmpname in tmp_tr_dataobj) {
                                var tmpvalue = tmp_tr_dataobj[tmpname];
                                if (ld(tmptrobj).find(' [name=' + tmpname + ']') != undefined && ld(tmptrobj).find(' [name=' + tmpname + ']').length > 0) {
                                    var tmphtmlobj = ld(tmptrobj).find(' [name=' + tmpname + ']');
                                    var tmphtmtagname = ld(tmphtmlobj).get(0).tagName.toLowerCase();
                                    if (tmphtmtagname == 'span') {
                                        ld(tmphtmlobj).html(tmpvalue);
                                    } else if (tmphtmtagname == 'select') {
                                        ld(tmphtmlobj).find("option[value='" + tmpvalue + "']").attr("selected", "selected");
                                    } else if (tmphtmtagname == 'input') {
                                        ld(tmphtmlobj).val(tmpvalue);
                                    } else if (tmphtmtagname == 'div') {
                                        //wym XUQIU1002029 收/付款单-选择源单-自动带出引用附件字段
                                        var fldname = tmpname;
                                        for(var j=0;j<prevpopupobj.detailfields.length;j++){
                                            if(prevpopupobj.detailfields[j].fieldname==fldname){
                                                if(SaveDataRecord.isfileattachUitype(parseInt(prevpopupobj.detailfields[j].uitype))){
                                                    var fileuploader=ld(tmphtmlobj);
                                                    var rowid=ld(tmptrobj).attr('row');
                                                    if(prevpopupobj.detailfilejsondata[rowid]){
                                                        prevpopupobj.detailfilejsondata[rowid][fldname]=tmpvalue;
                                                    }else{
                                                        prevpopupobj.detailfilejsondata[rowid] = {};
                                                        prevpopupobj.detailfilejsondata[rowid][fldname]=tmpvalue;
                                                    }
                                                    ld(tmphtmlobj).html('');
                                                    ld.each(prevpopupobj.detailimage_arr,function(i,info){
                                                        if(info['columnname']==fldname){
                                                            if(prevpopupobj.detailfilejsondata[rowid][fldname]){
                                                                ld(tmphtmlobj).html('');
                                                                var uploadFile = new WebUploadFile();
                                                                globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                                                                uploadFile.setDetailEvent(globalWebUploadType,fileuploader,prevpopupobj,i,rowid);
                                                            }else{
                                                                ld(tmphtmlobj).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
                                                            }
                                                            return false;
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    } else {
                                        ld(tmphtmlobj).val(tmpvalue);
                                    }
                                }
                            }


                            var tmprowindex = ld(tmptrobj).attr('rowindex');

                            prevpopupobj.fieldformulaobj.CountRowFormulaColumn(tmprowindex);
                            prevpopupobj.detail2mainformulaobj.setRowEvent(ld(tmptrobj).attr("rowindex"));
                        });

                        if (prevpopupobj.fieldformulaobj != undefined) {
                            prevpopupobj.fieldformulaobj.CountsubTotal();
                        }
                        prevpopupobj.detail2mainformulaobj.changeRowEvent();
                    }

                    //updateCashbillSourceNo();
                    parentwindow.getRelatedOrderInformations(module, sourcemodule);
                    parentwindow.ShowSequence(prevpopupobj);

                    //duan 20240926字段变更后触发公共变化事件
                    if(!empty(prevpopupobj.common_field_event_obj) ){
                        prevpopupobj.common_field_event_obj.common_changefun(CrmPopup.findHtmlobj(prevpopupobj.divid, 'selectlistval'),'selectlistval');
                    }

                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData(sourcemodule, record, '', '', module, 'popupselectfield');
                    });
                }
            }
        );
    } else {
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        return false;
    }
}

/**
 * 添加、删除行更新基本信息选择原单
 * @param
 * @returns
 * @author Chj
 */
function updateCashbillSourceNo() {
    var parentwindow = window;
    if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }
    var SourceModuleArray = new Array();
    var SourceModule = new Array();
    var SourceModuleIdArray = new Array();
    var SourceModuleId = new Array();
    var tableName = parentwindow.document.getElementById('proTab');
    var rowcount = tableName.rows.length;
    var k = 0;
    for (var i = 1; i <= rowcount - 1; i++) {
        if (parentwindow.ld('#deleterow' + i).val() == 0) {
            SourceModuleArray[k] = parentwindow.ld('#href_columnname' + i).val();
            k++;
        }
    }
    //去除数组重复的值
    if (SourceModuleArray.length > 0) {
        for (var i = 0; i < SourceModuleArray.length; i++) {
            !RegExp(SourceModuleArray[i], "g").test(SourceModule.join(",")) && (SourceModule.push(SourceModuleArray[i]));
        }
        parentwindow.ld('#selectlistval_label').val(SourceModule.join(','));
    } else {
        parentwindow.ld('#selectlistval_label').val('');
    }
}

function addNewRowAfterTr(trobj, trhtml) {
    ld(trobj).after(trhtml);

}

//editor:gyq_161 reason:弹出层分录添加行   2019/11/25 14:32
//添加行
function addTr(tab, row, trHtml) {
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
    var tableObj = ld('#' + prevpopupobj.divid + ' table[name="proTab"]');
    if (tableObj.length > 0) {
        var tr = tableObj.first().find('tr').eq(row);
        tr.after(trHtml);
    }
    /*var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}
	var tr=parentwindow.ld("#"+tab+" tr").eq(row);
	tr.after(trHtml);*/
}

function set_return_inventory_value(productid, rowid) {
    var parentwindow = window;
    if (window.top != window.self && window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }
    var prod_array = JSON.parse($('popup_product_' + productid).attributes['vt_prod_arr'].nodeValue);
    setproduct_value(productid, prod_array, rowid);
    if (document.getElementById('search_productname' + rowid) != undefined) {
        document.getElementById('search_productname' + rowid).style.display = 'none';
    }

}

//盘点 - 调入即时库存
function InstantInventory(module) {

    var popupobj = CrmPopup.getPopupObj('last');

    wareid = ld("#" + popupobj.divid + ' [name="wareid"]').first().val();
    startInstantInventory(module, 0, wareid, 0);
}

function startInstantInventory(module, startpage, wareid, totalrows) {

    var eachpage = 15;
    var tmppopupobjobj;
    if (startpage == 0) {
        tmppopupobjobj = ProgressPopup.load("", "", "", 500, module, "", "", "", "");

        tmppopupobjobj.show();
        tmppopupobjobj.setPercentWidth('');
    } else
        tmppopupobjobj = CrmPopup.getPopupObj('last');
    var popupobj = CrmPopup.getPopupObj('lastprev');
    if (wareid > 0) {
        new Ajax.Request(
            'index.php',
            {
                queue: {
                    position: 'end',
                    scope: 'command'
                },
                method: 'post',
                postBody: 'module=' + module + '&action=ChecksAjax&file=getWareInstant&wareid=' + wareid + "&startpage=" + startpage + "&eachpage=" + eachpage + "&totalrows=" + totalrows,
                onComplete: function (response) {

                    var results = trim(response.responseText);

                    if (results != '') {
                        var restobj = eval('(' + results + ')') ? eval('(' + results + ')') : JSON.parse(results);


                        ld("#" + tmppopupobjobj.divid + " .E_ptita").html(restobj.title);

                        var maxrows = parseInt(restobj.totalrows);
                        if (maxrows == 0) {
                            //edit:can 20210408 45351: PC端->新账套->导如产品后做盘点单调入即时库存，功能异常
                            tmppopupobjobj.CancelEvent();
                            return false;
                        }
                        var rowid = startpage * eachpage;
                        startpage = startpage + 1;
                        var rows = startpage * eachpage;

                        if (rows > maxrows) {
                            rows = maxrows;
                        }
                        var percent = parseInt(rows / maxrows * 100);

                        tmppopupobjobj.setPercentWidth(percent);
                        tmppopupobjobj.setTotalNum(restobj.totalrows);
                        tmppopupobjobj.setCurNum(rows);

                        tmppopupobjobj.setValidataNum(maxrows);

                        var cnt = 0;
                        var hidden_row_array = new Array();


                        var trobjs = popupobj.getTrObjsByDelType("no");
                        // rowid=ld(trobjs).length;

                        //获取当前有空行的rowid
                        if (ld(trobjs).length > 0) {
                            var row_i = 0;

                            ld.each(trobjs, function (tmpindex, tmprowobj) {

                                if (tmpindex >= rowid) {
                                    hidden_row_array[row_i] = ld(tmprowobj).attr("rowindex");
                                    row_i++;
                                }
                            })
                        }


                        ld.each(restobj.list, function (productid, list) {

                            tmppopupobjobj.setPercentWidth(percent);
                            if (hidden_row_array.length >= 1 && cnt < hidden_row_array.length) {
                                ld.each(list, function (index, tmplist) {
                                    if (hidden_row_array.length >= 1 && cnt < hidden_row_array.length)
                                        setproduct_value(productid, tmplist, hidden_row_array[cnt]);
                                    else {
                                        rowid = popupobj.selectproductobj.fnaddProductRow(module, '');
                                        setproduct_value(productid, tmplist, rowid);
                                    }
                                    cnt++;

                                })
                            } else {
                                ld.each(list, function (index, tmplist) {
                                    rowid = popupobj.selectproductobj.fnaddProductRow(module, '');
                                    setproduct_value(productid, tmplist, rowid);
                                    cnt++;
                                })
                            }
                        });
                        popupobj.center();
                        if (rows >= maxrows) {
                            tmppopupobjobj.CancelEvent();
                        } else {
                            startInstantInventory(module, startpage, wareid, totalrows);
                        }

                    }
                }
            }
        );
    }
}

//15734: 服务合同-新增：产品名称-选择产品窗口快速创建产品后没有带出产品名称
function setproduct_value(productid, prod_array, rowid) {
    //editor:gyq_161 reason:带分录模块弹出层   2019/11/14 17:14
    //var popupobj = CrmPopup.getPopupObj('last');
    var popupobj = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
    var parentwindow = window;

    var havepricestrategy = 'no';

    if (popupobj.pricestrategyobj != undefined && popupobj.pricestrategyobj.modulehaveprice(popupobj.module) == 'yes'
        && prod_array.pricestrategy != undefined && prod_array.pricestrategy.productids.length > 0 && prod_array.pricestrategy.productids[0] > 0) {


        if (popupobj.productstrategyobj == undefined || ld.inArray(productid, popupobj.productstrategyobj.productids) < 0) {
            if (popupobj.productstrategyobj.info == undefined) {
                popupobj.productstrategyobj.info = {};
            }
            popupobj.productstrategyobj.info[productid] = prod_array.pricestrategy.info[productid];//保存有价格策略的产品
            if (popupobj.productstrategyobj.maxfixedbase == null && popupobj.productstrategyobj.maxfixedbase == undefined) {
                popupobj.productstrategyobj.maxfixedbase = new Array();
            }
            popupobj.productstrategyobj.maxfixedbase.push(prod_array.pricestrategy.maxfixedbase[0]);//保存有价格策略的产品
            if (popupobj.productstrategyobj.productids == undefined) {
                popupobj.productstrategyobj.productids = [];
            }
            popupobj.productstrategyobj.productids.push(prod_array.pricestrategy.productids[0]);//保存有价格策略的产品
        }


        if (ld.inArray(productid, popupobj.productstrategyobj.productids) >= 0) {
            havepricestrategy = 'yes';

        }


    }
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");

    var batchmanagement = prod_array.batchmanagement;

    //控制面板>单据分录自定义：新增一个字段设置默认值。新建单据时，选择产品后，默认值没有显示。
    //parentwindow.setInventoryProductClear(rowid, parentwindow.document.forms['EditView'].module,'ProductDetailRow');
    // console.log(rowid);

    for (var columnname in prod_array) {

        if (columnname.toLocaleLowerCase() == 'imagename') {
            //editor:gyq_161不确定 reason:带分录模块弹出层   2019/11/15 10:50
            parentwindow.getproductImageName(productid, rowid);
        } else if ((columnname == 'batchtext' || columnname == 'batchmanagement') && popupobj.havebatchtextcolumnname == 'no') {

        } else if ((columnname == 'batchtext' || columnname == 'batchmanagement') && popupobj.havebatchtextcolumnname == 'yes') {
            if (batchmanagement == 1) {
                popupobj.detaildatavalue_arr[rowid - 1]['producthave_batchtext'] = 'yes';
                ld(rowobj).find(' #batchtext').css("display", 'inline');
                ld(rowobj).find(' #searchbatchtextIcon').css("display", 'inline');
                ld(rowobj).find(' #clearbatch').css("display", 'inline');
                /*ld("#batchtext" + rowid).css("display", 'inline');
                ld("#searchbatchtextIcon" + rowid).css('display', 'inline');
                ld("#clearbatch" + rowid).css('display', 'inline');*/
                //界面输入文字查询和盘点调入即时库存都调用该函数，单是界面输入文字没有batchtext字段
                if (prod_array.batchtext != undefined)
                    //ld("#batchtext" + rowid).val(prod_array['batchtext']);
                    ld(rowobj).find('  #batchtext').val(prod_array['batchtext']);

                if (popupobj.module == "Checks") {
                    //盘点单批次改变后，获取账面数量
                    ld(rowobj).find(' #batchtext').unbind("change").bind("change", function () {

                        var popupobj = CrmPopup.getPopupObj('last');
                        var divid = popupobj.divid;
                        var wareid = ld("#" + divid + " [name=wareid]").val();
                        var tmpproductid = ld(rowobj).find("#hdnProductId").val();// ld("#hdnProductId" + rowid).val();
                        if (tmpproductid <= 0) {
                            return false;
                        }
                        ld.ajax({

                            url: 'index.php?module=Checks&action=ChecksAjax&file=getpageQuantity&productid=' + tmpproductid + "&batchtext=" + encodeURIComponent(ld(this).val()) + "&wareid=" + wareid,
                            type: 'post',
                            dataType: 'json',
                            success: function (data) {
                                ld(rowobj).find("#paperquantity").val(data.result.pagequantity);
                                ld(rowobj).find("#span_paperquantity").html(data.result.pagequantity);
                                fieldformulaobj.cur_input_focus_obj = ld(rowobj).find("#paperquantity");// document.getElementById("paperquantity" + rowid);
                                fieldformulaobj.CountRowFormulaColumn(rowid);

                            }
                        })
                    })
                }
            } else {
                popupobj.detaildatavalue_arr[rowid - 1]['producthave_batchtext'] = 'no';
                ld(rowobj).find(' #batchtext').css("display", 'none');
                ld(rowobj).find(' #batchtext').val("");
                ld(rowobj).find(' #searchbatchtextIcon').css('display', 'none');
                ld(rowobj).find(' #clearbatch').css('display', 'none');
                /* ld("#batchtext" + rowid).css("display", 'none');
                ld("#batchtext" + rowid).val("");
                ld("#searchbatchtextIcon" + rowid).css('display', 'none');
                ld("#clearbatch" + rowid).css('display', 'none');*/
            }
        } else {
            var columnhtmlobj = ld(rowobj).find('#' + columnname)
            if (columnhtmlobj) {
                if (prod_array[columnname] == 'null' || prod_array[columnname] == null) {
                    prod_array[columnname] = '';
                }
                //if (parentwindow.document.getElementById('span_' + columnname + rowid) != undefined) {
                var spancolumnhtmlobj = ld(rowobj).find('#span_' + columnname);
                if (spancolumnhtmlobj) {
                    if (columnname == 'entitytype') {//源单模块
                        if (prod_array['entitytype_transmodule'] == undefined) {
                            prod_array['entitytype_transmodule'] = '';
                        }
                        ld(spancolumnhtmlobj).html(decodeURIComponent(prod_array['entitytype_transmodule']));
                        ld(rowobj).find(' #span_entitytypeid').html(decodeURIComponent(prod_array[columnname]));
                        // parentwindow.document.getElementById('span_' + columnname + rowid).innerHTML = decodeURIComponent(prod_array['entitytype_transmodule'];
                        // parentwindow.document.getElementById('span_entitytypeid' + rowid).innerHTML = decodeURIComponent(prod_array[columnname]);
                    } else if (columnname == 'contractid') {//合同信息
                        if (prod_array['contractid_name'] == undefined) {
                            prod_array['contractid_name'] = '';
                        }
                        ld(spancolumnhtmlobj).html(decodeURIComponent(prod_array['contractid_name']));
                        //parentwindow.document.getElementById('span_' + columnname + rowid).innerHTML = decodeURIComponent(prod_array['contractid_name']);
                    } else {
                        try {
                            ld(spancolumnhtmlobj).html(decodeURIComponent(prod_array[columnname]));
                        } catch (ex) {
                            //单据的导入，导入内容有%
                            ld(spancolumnhtmlobj).html(prod_array[columnname]);
                        }
                        //parentwindow.document.getElementById('span_' + columnname + rowid).innerHTML = decodeURIComponent(prod_array[columnname]);
                    }
                }
                //editor:gyq_20191226 reason:分录导入，仓库默认选中
                // 0038958: (51mis.com/kfbcrm)出库单>产品分录导入：导入数据模板中“仓库”一列录入“其他仓”“赠品仓”，导入成功后产品分录只显示“总仓”
                if (columnname == 'wareid') {
                    ld(rowobj).find(' #wareid').find('option:contains("' + prod_array[columnname] + '")').prop('selected', true);
                } else if (columnname == 'productname') {


                    try {
                        ld(columnhtmlobj).val(decodeURIComponent(prod_array[columnname]));
                    } catch (ex) {
                        //单据的导入，导入内容有%
                        ld(columnhtmlobj).val((prod_array[columnname]));
                    }

                    //parentwindow.document.getElementById(columnname + rowid).value = decodeURIComponent(prod_array[columnname]);
                } else if (columnname == 'entitytype') {
                    if (prod_array['entitytype_module'] == undefined) {
                        prod_array['entitytype_module'] = '';
                    }
                    if (prod_array['selectSourceModuleid'] == undefined) {
                        prod_array['selectSourceModuleid'] = '';
                    }
                    ld(rowobj).find('#' + columnname + '').val(prod_array['entitytype_module']);
                    ld(rowobj).find('#entitytypeid').val(prod_array['selectSourceModuleid']);
                    //parentwindow.document.getElementById(columnname + rowid).value = prod_array['entitytype_module'];
                    //parentwindow.document.getElementById('entitytypeid' + rowid).value = prod_array['selectSourceModuleid'];
                } else {
                    ld(rowobj).find('#' + columnname + '').val(prod_array[columnname]);
                    //parentwindow.document.getElementById(columnname + rowid).value = prod_array[columnname];
                }
            }
            var fieldinfo = popupobj.detailfieldcolumninfo[columnname];
            if (fieldinfo && fieldinfo.uitype == 56) {

                if(prod_array[columnname]==1||prod_array[columnname]=='是')
                {
                    ld(rowobj).find('#' + columnname + '').val(1);
                    ld(rowobj).find('#' + columnname + '').prop("checked",true);
                }
                else{
                    ld(rowobj).find('#' + columnname + '').val(0);
                    ld(rowobj).find('#' + columnname + '').prop("checked",false);
                }
            }
            if (fieldinfo && fieldinfo.uitype == 60) {
                //sf2773
                //eidt:can 20220223 50031: （http://xiaoshou360.com/xs/xjsy [^]）(上海享暨实业有限公司)采购订单导入分录的时候，模板中有单位字段的数据，但是导入到系统里面不显示。模板文件见附件

                ld(columnhtmlobj).val(prod_array[columnname]);
                if(columnname=='wareid')
                    ld(rowobj).find('[name="cmb_span_optiontext_' + columnname + '"]:first').val(prod_array[columnname + "_name"]);
                else
                    ld(rowobj).find('[name="cmb_span_optiontext_' + columnname + '"]:first').val(prod_array[columnname]);

            }

            if (columnname == 'productname') {
                //	parentwindow.document.getElementById('productname'+rowid).disabled  = true;
                //36594: （1.6）合同订单编辑、新增界面>产品分录>产品名称：使用火狐浏览器不能复制产品名称，谷歌和360浏览器是可以复制的。（需要补丁）
                ld(rowobj).find('#productname').attr('ReadOnly', true);
                //ld('#productname' + rowid).attr('ReadOnly', true);
                //ld('#productname'+rowid).attr('unselectable','on')  ;
                ld(rowobj).find('#productname').css('cursor', 'not-allowed');
                //parentwindow.document.getElementById('productname' + rowid).style.cursor = 'not-allowed';
            }
        }
    }
    if (havepricestrategy == 'yes') {

        if (popupobj.module == 'SalesOrder' || popupobj.module == 'ServiceContracts' || popupobj.module == 'Quotes') {
            //editor:gyq_20191223
            popupobj.pricestrategyobj.startcomputer(rowid);
            popupobj.fieldformulaobj.CountsubTotal();//小计
            //有价格策略,且修改的是数量字段，
            // continue;
        }

    }
    //产品单价自动根据客户最近一次购买的产品价格带出。
    setProductPriceTax(rowid);
    //关联带出价格
    getRelatedProductToolFieldPriceCallBack(popupobj, rowid);
    //原单
    //editor:gyq_162不确定 reason:海格产品分录导入   2019/12/11 14:03
    // setModuleEntityName();
    //产品明细 - 选择产品 - 产品套餐
}

/**
 原单信息显示
 销售发票，采购发票
 **/
function getSourceInfoTable() {
    var module = getSourceInfoTable.module;
    var idstring = getSourceInfoTable.entitytypeid;
    var entitytype = getSourceInfoTable.entitytype;
    var parentwindow = window;
    if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }

    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            async: false,
            postBody: 'module=' + module + '&action=' + module + 'Ajax&file=SourceInfo&idstring=' + idstring + "&sourcemodule=" + entitytype,
            onComplete: function (response) {

                var result = response.responseText;

                parentwindow.document.getElementById("relatedorder_div").innerHTML = result;
                window.close();
            }
        }
    );

}

/**
 获取产品明细表格信息
 id_name:表示单元格id表示名称
 needdeleted_row:是否包含是删除行,yes:包含删除行
 return:字符串，以逗号分割
 **/
function getProtabInfo(id_name, needdeleted_row) {
    var parentwindow = window;
    if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }
    var table_obj = popupobj.getDetailTableObj();//ld("#"+popupobj.divid+" table[name=proTab]").get(0);// parentwindow.document.getElementById('ProTab');
    //var max_row=ld("#"+popupobj.divid+" [name=rowcnt]").val();// parentwindow.document.getElementById('rowcnt').value;
    var trobjs = popupobj.getTrObjsByDelType('no');

    var ret_string = "";
    //for(var i=1;i<=max_row;i++)
    ld.each(trobjs, function () {
        /* var hiddenrowobj=ld("#"+popupobj.divid+ " [name=hidden_rowid_"+i+"]");
        if(hiddenrowobj.val()!=0&&needdeleted_row=='no')
        {
            continue;
        }*/

        if (i != max_row)
            ret_string += ld(this).find(' [name=' + id_name + "]").val();//parentwindow.document.getElementById(id_name+i).value+",";
        else
            ret_string += ld(this).find(' [name=' + id_name + "]").val();//parentwindow.document.getElementById(id_name+i).value;
    });
    return ret_string;
}

/**
 * edit:cyb
 * date:2015-08-25
 * reason: 产品单价自动根据客户最近一次购买的产品价格带出。
 **/
//editor:gyq_161 reason:产品单价自动根据客户最近一次购买的产品价格带出。   2019/11/15 11:29
function setProductPriceTax(rowid) {
    //var jquery_obj;
    if (ld) {//jquery_obj=ld;
    } else {
        ld = $;
    }
    //editor:gyq_162 reason:海格产品分录导入   2019/12/11 14:01
    //var popupobj=CrmPopup.getPopupObj('last');
    var popupobj = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");

    var parentwindow = window;
    if (window.opener != undefined && ld("#" + popupobj.divid + ' [name="proTab"]').length > 0) {
        parentwindow = window.opener;
    }
    //if(parentwindow.document.getElementById('SYstemArg') != undefined){
    if (ld("#" + popupobj.divid + ' [name="SYstemArg"]').length > 0) {
        var System_deploy = ld("#" + popupobj.divid + ' [name="SYstemArg"]').val();
        var currency_id;

        //if(parentwindow.document.getElementById('inventory_currency') != undefined){
        if (ld("#" + popupobj.divid + ' [name="inventory_currency"]').length > 0) {
            currency_id = ld("#" + popupobj.divid + ' [name="inventory_currency"]').val();
            //currency_id=parentwindow.document.getElementById('inventory_currency').value;
        }
        if (System_deploy == 0) {     //判断产品单价是否需要根据客户最近一次购买的产品价格带出，0：是，1：否。
            //editor:gyq_161不确定 reason:带分录模块弹出层   2019/11/15 11:52
            //if(parentwindow.document.EditView.account_id != undefined && parentwindow.document.EditView.module != undefined){
            if (ld("#" + popupobj.divid + ' [name="EditView"]').find('input[name="account_id"]').length > 0
                && ld("#" + popupobj.divid + ' [name="EditView"]').first().find('input[name="module"]').length > 0) {
                //var module = parentwindow.document.EditView.module.value;
                var module = ld("#" + popupobj.divid + ' [name="EditView"]').first().find('input[name="module"]').first().val();
                //var account_id = parentwindow.document.EditView.account_id.value;
                var account_id = ld("#" + popupobj.divid + ' [name="EditView"]').first().find('input[name="account_id"]').first().val();
                //var lengthprice = parentwindow.document.EditView.lengthprice.value;
                var lengthprice = ld("#" + popupobj.divid + ' [name="EditView"]').first().find('input[name="lengthprice"]').first().val();
                //if(parentwindow.document.getElementById('hdnProductId'+rowid) != undefined && parentwindow.document.getElementById('hdnProductId'+rowid).value > 0){
                var productid = ld(rowobj).find('#hdnProductId').val();

                //zkt 0048692: （https://kh.xiaoshou360.com/runhe/ [^] ）客户问题（新疆润和）：报价单-新建-产品分录导入分录产品，下载导入模板-填充数量和含税单价-结果显示的含税单价不是模板里的含税单价 ，导入模板见附件
                if (productid > 0 && account_id > 0) {
                    //var productid= parentwindow.document.getElementById('hdnProductId'+rowid).value;
                    //alert('index.php?module=Products&action=ProductsAjax&file=GetSearchInfo&productid='+productid+'&account_id='+account_id+'&frommodule='+module+'&currency_id='+currency_id+'&setProductValue=yes');
                    var href_url = encodeURI('index.php?module=Products&action=ProductsAjax&file=GetSearchInfo&productid=' + productid + '&account_id=' + account_id + '&frommodule=' + module + '&currency_id=' + currency_id + '&setProductValue=yes');
                    if (module == 'SalesOrder' || module == 'Quotes') {
                        ld.ajax({
                                url: href_url,
                                type: 'POST',
                                data: '',
                                dataType: 'json',
                                async: false,
                                timeout: 5000,
                                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                    popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
                                },
                                success: function (data) {
                                    var results = data.entity;

                                    if (results != null && results != '') {
                                        var res_arr = Object.keys(results);
                                        for (var i = 0; i < res_arr.length; i++) {
                                            //if(parentwindow.document.getElementById(res_arr[i]+rowid) != undefined){
                                            if (ld(rowobj).find(' #' + res_arr[i]).length > 0) {
                                                var amount = Number(results[res_arr[i]]).toFixed(lengthprice);
                                                //parentwindow.document.getElementById(res_arr[i]+rowid).value = amount;
                                                ld(rowobj).find(' #' + res_arr[i]).val(amount);
                                            }
                                        }
                                        //不含税单价
                                        //parentwindow.document.getElementById('hddlistprice').value = parentwindow.document.getElementById(res_arr[1]+rowid).value;
                                        ld(rowobj).find(' #hddlistprice').val(ld(rowobj).find(' #' + res_arr[1] ).val());
                                        popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
                                    } else {

                                        popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
                                    }

                                }
                            }
                        );
                    }
                    else{
                        popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
                    }
                }
                //zkt 20240702 BUG20240626-28  报价单和销售订单两个单据导入整单或者只导入产品分录明细，字段设置的公式不参与计算，点重算也不起作用，报价单的导入文件见附件
                else{
                    popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
                }
            } else {

                popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
            }
        } else {
            popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
        }
    } else {
        popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
    }
}

//填写产品分录字段时点击回车键可以切换到下一个输入框。
function setKeyCode(rowid, columnname, event) {
    var e = event || window.event;

    //editor:gyq_161 reason:带分录模块弹出层   2019/11/22 14:23
    var popupobj = CrmPopup.getPopupObj('last');
    var scrElement = e.srcElement || e.target;

    var rowobj = popupobj.getTrObjByChild(ld(scrElement));
    rowid = ld(rowobj).attr("rowindex");//考虑到行可以拖动，则需要重新定义rowid的变量的值

    if (e.keyCode === 13) {
        //var table = document.getElementById("proTab");
        var table = ld("#" + popupobj.divid + " [name=proTab]");

        var rows = table[0].rows;
        var tdnode = rows[1].cells.length;
        var rowObj = ld("#" + popupobj.divid + ' [name="row' + rowid + '"]');
        for (var i = 0; i <= tdnode; i++) {
            //if(ld("#row"+rowid).children("td:eq("+i+")").find("input[type=text],textarea").attr('name') != undefined){
            if (rowObj.children("td:eq(" + i + ")").find("input[type=text]").length > 0) {
                //chj 2021/1/13 44062: （61mis.com/kfbcrm）销售管理-合同订单-新增（客户问题需要补丁）；合同订单分录中，选择产品后，输入含税单价按回车后，没有计算价税合计
                var colname = columnname;
                if (rowObj.children("td:eq(" + i + ")").find("input[type=text]").attr('name') === colname) {
                    var next_row_td = i + 1;
                    for (var j = next_row_td; j <= tdnode; j++) {
                        if (rowObj.children("td:eq(" + j + ")").find("input[type=text]").length > 0) {
                            rowObj.children("td:eq(" + j + ")").find("input[type=text]").focus();
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
}

//当前选择的区域ID
var dropselectField = '';
//匹配项 当前选择行数
var trNum = 0;
//当前匹配区域总行数
var trRowNum;
//滚动条默认TOP位置
var scrollTop = 0;
//默认8行 出现下拉拖动按钮
var scrollTrNum = 8;
//点击空白区域隐藏弹出框(全局)

//@edit:liushuai,2021-03-31,reason: 0045067: （61mis.com/kfbcrm）自定义表单11-新增；在产品分录中，输入关键字查询，产品名称字段处显示查询结果，但界面点击空白处时，查询结果没有收起
ld(document).click(function () {
    var popupobj = CrmPopup.getPopupObj('last');
    if (typeof popupobj != 'undefined' && (popupobj.detailfieldmodule == 'Products' || popupobj.module === 'PricePolicy')) {
        ld("#" + popupobj.divid + " [name=search_productname]").hide();
    }
});

/**
 * edit:chj
 * date:2014-9-2
 * reason:根据关键字模糊匹配、显示产品信息
 **/
getInventoryProductKeyWords.objkeyup_ajax = '';

function getInventoryProductKeyWords(obj, rowid, module, event) {
    //edit:duan 监测输入法当前输入状态
    var event = event || window.event;
    var srcElement = event.srcElement || event.target;
    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = ld(popupobj.getTrObjByChild(ld(srcElement))) || ld(tableobj).find("tr[rowindex=" + rowid + "]");//考虑拖动换行 ，n那么rowId变量要重新赋值
    rowid = ld(rowobj).attr("rowindex") || rowid;
    var selectobjname = obj.name;
    var tableobj = popupobj.getDetailTableObj();

    var productNameObj = ld(rowobj).find(" [name=productname]"),
        popupJqObj = ld("#" + popupobj.divid),
        productSearchObj = rowobj.find(" [name=search_" + selectobjname + "]");
    if(popupobj.module === 'PricePolicy') {
        var editObj = PricePolicy.getInstance(popupobj).getEditInstance();
        productNameObj = editObj.getProductObj();
        rowobj = editObj.getProductParentObj();
        productSearchObj = rowobj.find(" [name=search_" + selectobjname + "]");
    }
    popupobj.selectproductobj.chooseProductRowindex = rowid;

    if (productNameObj.attr("ReadOnly") == true ||
        productNameObj.attr("ReadOnly") == 'readonly') {
        //36594: （1.6）合同订单编辑、新增界面>产品分录>产品名称：使用火狐浏览器不能复制产品名称，谷歌和360浏览器是可以复制的
        return false;
    }


    if (obj.value.replace(/[ ]/g, "") != '') {
        var wareid = 0;//仓库ID
        var e = event || window.event;
        var currentModule = popupobj.module;
        /*	if(typeof(document.EditView) != 'undefined')
			currentModule = document.EditView.module.value;
		else if(typeof(document.QcbomEditView) != 'undefined')
			currentModule = document.QcbomEditView.module.value;
   */
        //盘点 选择产品时，根据当前选择的仓库，只显示仓库下的产品
        /*if(currentModule == 'Checks'){
			if(document.getElementById('wareid') != undefined)
				wareid = document.getElementById('wareid').value;
		}*/
        //获取DIV下拉拖动高度

        var scrollHeight = productSearchObj.get(0).scrollHeight;
        var currencyid = 1; //1默认为人民币
        //多币种
        if (ld("#" + popupobj.divid + " [name=inventory_currency]").length > 0) {
            currencyid = ld("#" + popupobj.divid + " [name=inventory_currency]").val();
        }
        if (e.keyCode == 40 || e.keyCode == 38) {//方向键(下：40，上38)
            var trHeight = scrollHeight / trRowNum;
            if (e.keyCode == 40) {
                if (trNum == trRowNum) {
                    trNum = 0;
                    scrollTop = 0;
                }
                if (trNum < trRowNum)
                    trNum++;
                //alert(scrollTrNum);
                if (eval(trNum) > eval(scrollTrNum)) {

                    scrollTop = scrollTop + trHeight;
                }
            } else {
                if (trNum == 1) {
                    trNum = trRowNum;
                    scrollTop = scrollHeight;
                } else if (trNum > 1) {
                    trNum--;
                    if (eval(trRowNum) - eval(trNum) > eval(scrollTrNum)) {
                        scrollTop = scrollTop - trHeight;
                    }
                }
            }
            productSearchObj.scrollTop = scrollTop;
            //上下移动时，自动获取当前选中行的产品名称
            var searchTableObj = productSearchObj.find('#selectTable_' + selectobjname),
                trList = searchTableObj.find('tr'),
                trRow = trList.eq(trNum),
                rowNum = trRow.attr('id').split('_')[1];
            obj.value = trRow.find('#entityname_'+rowNum).val(); //产品名称
            trList.removeClass('hover');
            trRow.addClass('hover');
            searchTableObj.unbind('onmouseover').one('onmouseover',function () {
                searchTableObj.removeClass('hover');
            })
            //select_trmouseover(trNum);
            return false;
        } else if (e.keyCode == 13) {	 //回车键13
            if (trNum > 0) {
                //上下移动时，自动获取当前选中行的产品名称
                var searchTableObj = productSearchObj.find('#selectTable_' + selectobjname),
                    trRow = searchTableObj.find('tr').eq(trNum),
                    rowNum = trRow.attr('id').split('_')[1];
                getInventoryProductKeyWords.getProductInfo(currentModule, rowNum, wareid, currencyid, rowid, '');
                //scrollTop = 0;
                if (e && e.stopPropagation) {
                    e.stopPropagation();
                    e.preventDefault();
                } else {
                    e.returnValue = false;
                    e.cancelBubble = true;
                }
                return false;
            } else {
                return false;
            }
        }
        var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader';
        dropselectField = obj.name;
        //alert(dropselectField);
        //alert(urlstring);
        var searchText = encodeURIComponent(obj.value);
        trNum = 0;
        trRowNum = 0;
        urlstring += '&wareid=' + wareid + '&currencyid=' + currencyid + '&keywords=' + searchText + '&rowid=' + rowid + '&frommodule=' + currentModule;
        //alert(urlstring);
        productSearchObj.html('');
        isprodsearchajax = 1;
        if (getInventoryProductKeyWords.objkeyup_ajax != '') {

            getInventoryProductKeyWords.objkeyup_ajax.abort();
        }
        if (ld(obj).attr("inputtype") == 'start')
            return;
        var requestvalues = "{";
        ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {
            if (tmpfieldinfo.displaytype == 3 && tmpfieldinfo.bigtype == 'reference' && tmpfieldinfo.columnname == 'pricebooksid') {
                //海格
                urlstring += "&pricebooksid=" + ld("#" + popupobj.divid + " [name=pricebooksid]").val();

            }
            if (ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").length > 0)
                requestvalues += '"' + tmpfieldinfo.columnname + '":"' + ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").val() + '",';

        })
        requestvalues = requestvalues.substr(0, requestvalues.length - 1);//删除“，”
        requestvalues += "}";


        urlstring += "&requestvalues=" + encodeURIComponent(requestvalues);
        getInventoryProductKeyWords.objkeyup_ajax = ld.ajax({
            url: "index.php?" + urlstring,
            type: "post",
            cache: true,
            async: true,
            success: function (response) {
                //if(document.getElementById(obj.id).value == arrJsPopLabel['INPUTAKEYWORDSQUERY']|| isprodsearchajax == 2){
                if (obj.value == '' || isprodsearchajax == 2) {
                    return false;
                }
                var results = trim(response);
                if (results != '') {
                    trRowNum = 0;

                    var restobj = eval('(' + results + ')') ? eval('(' + results + ')') : JSON.parse(results);
                    //海格分录模糊匹配，已存在记录不显示
                    if (account_version == 'haige' && module == 'Products' && popupobj.module == 'Quotes') {
                        var haigeresult = restobj['entries'];
                        for (var index in haigeresult) {
                            var resultproductname = haigeresult[index]['productname'];
                            if (ld(tableobj).find("input[value='" + resultproductname + "']").val() != undefined) {
                                delete restobj['entries'][index];
                            }
                        }
                    }
                    //显示列头信息
                    var len = restobj['header'].length;
                    var entrieskeys =[];
                    if(restobj['entries']!=null)
                        entrieskeys= Object.keys(restobj['entries']);
                    //显示列字段名称(指的是模糊查询动态显示出来的产品下拉信息列)
                    var columnnameLen = restobj['columnname'].length;
                    if (restobj['columnname'].length == 0 || restobj['columnname'].length < 1 || entrieskeys.length == 0) {
                        //无任何记录
                        var info = '<div style="height: 100%;text-align: center;align-items: center;display: grid;">' + arrJsPopLabel['NORECORDSAREFOUND'] + '</div>';
                    } else {
                        //显示模糊查询内容
                        var info = '<table id="selectTable_' + dropselectField + '" class="SelTabPro" width="100%" border="0" cellspacing="0" cellpadding="0">';
                        info += '<input type="hidden" id="returnmodule" name="returnmodule" value="' + currentModule + '" />';
                        //zxm 20230518 显示表头
                        info += '<tr id="selectTable_header" style="position: sticky;top:0;">';
                        ld.each(restobj['header'],function(i,headername){
                            info += '<th style="background-color:var(--ld-bg-list-head-color);"><span title="'+headername+'">'+headername+'</span></th>';
                        });
                        info += '</tr>';
                        for (var i in restobj['entries']) {
                            trRowNum++;
                            info += '<tr height="30" id="trRow_' + i + '_' + dropselectField + '" onclick="getInventoryProductKeyWords.getProductInfo(\'' + currentModule + '\',' + i + ',' + wareid + ',' + currencyid + ',' + rowid + ',\'\')">';
                            //产品关联信息
                            if (module = 'Products') {
                                info += "<input type='hidden' id='popup_product_" + i + "' vt_prod_arr=\"" + restobj['entries'][i]['vt_prod_arr'] + "\" />";
                            }
                            //产品名称
                            info += '<input type="hidden" id="entityname_' + i + '" name="entityname_' + i + '" value="' + restobj['entries'][i]['productname'] + '" />';
                            for (var j = 0; j < columnnameLen; j++) {
                                var columnname = restobj['columnname'][j];
                                //info += '<td>'+(parseInt(i)+1)+'</td>';
                                if (columnname == 'productname')
                                    info += '<td id="selectRow" width="30%"><span title=' + restobj['entries'][i][columnname] + '>' + restobj['entries'][i][columnname] + '</span></td>';
                                else
                                    info += '<td id="selectRow" width="20%"><span title=' + restobj['entries'][i][columnname] + '>' + restobj['entries'][i][columnname] + '</span></td>';
                            }
                            info += '</tr>';
                        }
                        info += '</table>';
                        //alert(info);
                    }

                    //显示数据超过8条时，显示下拉拖动
                    productSearchObj.css('display', '');
                    productSearchObj.css("zIndex", 3000);
                    var position = productSearchObj.position();
                    var tmpheight = parseInt(productSearchObj.css("height"));
                    productSearchObj.css("top", (position.top + tmpheight) + "px");
                    // BUG0058906 kfbcrm 产品分录---当产品名称字段放在开头，可以输入名称搜索----把产品名称放到后面，输入名称就搜索不了
                    // diony 2023-07-28
                    var tmpwidth = parseInt(productNameObj.css("width"));
                    var windowwidth = ld(window).width();
                    if(windowwidth/2 < position.left){
                        productSearchObj.css("right", parseInt(windowwidth)-parseInt(windowwidth)*0.2-parseInt(position.left)-tmpwidth+"px");
                    }
                    if (trRowNum > scrollTrNum) {
                        productSearchObj.css('height', '188px');
                        productSearchObj.css('overflowY', 'auto');
                    } else {
                        productSearchObj.get(0).style.height = '188px';
                        productSearchObj.get(0).style.overflowY = 'auto';
                    }


                    productSearchObj.get(0).style.display = "block";
                    productSearchObj.get(0).innerHTML = info;
                    productSearchObj.get(0).scrollTop = 0;

                    scrollTop = 0;
                    if (trRowNum == 1) {
                        var searchTableObj = productSearchObj.find('#selectTable_' + selectobjname),
                            trRow = searchTableObj.find('tr').eq(1),
                            rowNum = trRow.attr('id').split('_')[1];
                        getInventoryProductKeyWords.getProductInfo(currentModule, rowNum, wareid, currencyid, rowid, '');
                    }
                    //zxm 分录开启冻结列的时候 产品搜索的table显示不完全
                    var objtd = Tools.getParentobjByChild(obj, 'td');
                    var tdposition = objtd.css('position');
                    var search_productname_obj = rowobj.find('[name=search_' + dropselectField + ']');
                    var tmptop = objtd.offset().top;
                    tmptop = parseInt(tmptop) + 42;
                    var tmpleft = productNameObj.offset().left;
                    tmpleft = parseInt(tmpleft);
                    if(tdposition == 'sticky'){
                        rowobj.append(search_productname_obj);//zxm 20221118
                    }
                    if(ld(search_obj).css('position') == 'fixed'){
                        var position = ld(obj).offset();
                        var tmpheight = parseInt(ld(obj).css("height"));
                        ld(search_obj).css("top", (position.top + tmpheight) + "px");
                        var tmpwidth = parseInt(ld(obj).css("width"));
                        var windowwidth = ld(window).width();
                        ld(search_obj).css("left", position.left+"px");
                        /*
                        if(windowwidth/2 < position.left){
                            ld(search_obj).css("right", parseInt(windowwidth)-parseInt(windowwidth)*0.2-parseInt(position.left)-tmpwidth+"px");
                        }else{
                            ld(search_obj).css("left", position.left+"px");
                        }*/
                    }

                    search_productname_obj.show().css('position', 'fixed').css('top', tmptop + 'px').css('left', tmpleft + 'px').css('z-index', '100000').css('background-color', '#fff');
                    ld('#' + popupobj.divid + '_scroll').unbind('scroll').bind('scroll', function () {
                        productSearchObj.hide();
                    });
                }
            }
        })
        trNum = 0;
    } else {
        productSearchObj.css('display', 'none');
    }
}

//根据产品id，带出产品关联信息
getInventoryProductKeyWords.getProductInfo = function (currentModule, productid, wareid, currencyid, rowid, popup) {
    var popupobj = CrmPopup.getPopupObj('last');
    if (wareid == '') wareid = 0;
    if (currencyid == '') currencyid = 1;
    var change_type = '';
    var parentwindow = window;

    var accvenid = '';
    if (ld("#" + popupobj.divid + " [name=vendor_id]").length > 0) {
        var accvenid = ld("#" + popupobj.divid + " [name=vendor_id]").val();// parentwindow.document.EditView.vendor_id.value;
    }
    if (ld("#" + popupobj.divid + " [name=account_id]").length > 0) {// if(parentwindow.document.EditView != undefined && parentwindow.document.EditView.account_id != undefined && parentwindow.document.EditView.module != undefined){
        var accvenid = ld("#" + popupobj.divid + " [name=account_id]").val();// parentwindow.document.EditView.account_id.value;
    }
    if (ld("#" + popupobj.divid + " [name=wareid]").length > 0) {//parentwindow.document.EditView != undefined && parentwindow.document.EditView.wareid != undefined){
        wareid = ld("#" + popupobj.divid + " [name=wareid]").val();// parentwindow.document.EditView.wareid.value;
    }

    var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getProductinfo=yes';
    var requestvalues = "{";
    ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {
        if (ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").length > 0)
            requestvalues += '"' + tmpfieldinfo.columnname + '":"' + ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").val() + '",';
    })
    requestvalues = requestvalues.substr(0, requestvalues.length - 1);//删除“，”
    requestvalues += "}"

    urlstring += "&requestvalues=" + encodeURIComponent(requestvalues);
    urlstring += '&wareid=' + wareid + '&accvenid=' + accvenid + '&currencyid=' + currencyid + '&rowid=' + rowid + '&frommodule=' + currentModule + '&productid=' + productid;
    urlstring += "&currency_id=" + ld("#" + popupobj.divid + " [name=inventory_currency]").val();
    if (currentModule == 'QuotesChange') {
        if (ld("#" + popupobj.divid + " [name=change_type]").length > 0) {//parentwindow.document.EditView != undefined && parentwindow.document.EditView.change_type != undefined){
            change_type = ld("#" + popupobj.divid + " [name=change_type]").val();// parentwindow.document.EditView.change_type.value;
            urlstring += '&change_type=' + change_type;
        }
    }
    //zkt 20230523 BUG0066951 付款单分录，付款单分录模糊查找之后选不到产品，看附件
    //zkt 收付款单，获取源单类型，
    if (currentModule == 'CashBill' || currentModule == 'SendCashBill') {
        var selectsource = ld("#" + popupobj.divid).find('select[id=selectsource]').val();
        urlstring += '&selectmodule=' + selectsource;
    }
    new Ajax.Request("index.php",
        {
            queue: {
                position: "end",
                scope: "command"
            },
            method: "post",
            postBody: urlstring,
            onComplete: function (response) {
                var results = response.responseText;
                var prod_array = eval('(' + results + ')') ? eval('(' + results + ')') : JSON.parse(results);
                if (ld("#" + popupobj.divid + " [name=search_productname]").length > 0) {//      document.getElementById('search_productname'+rowid) != undefined){
                    //document.getElementById('search_productname'+rowid).style.display = 'none';
                    ld("#" + popupobj.divid + " [name=search_productname]").css('display', 'none');
                }
                if(popupobj.module === 'PricePolicy') {
                    PricePolicy.getInstance(popupobj).getEditInstance().addProducts(rowid,prod_array);
                    return ;
                }
                for (productid in prod_array) {

                    var tmpProductInfo = prod_array[productid]
                    // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
                    if(tmpProductInfo.property_status === 'yes') {
                        try {
                            tmpProductInfo = ProductPropertyGroup.setProductPropertyGroup(popupobj, rowid, tmpProductInfo);
                        }
                        catch (e) {
                            console.log(e)
                        }
                    }

                    //setproduct_value(productid,prod_array[productid],rowid);
                    popupobj.selectproductobj.setValue(productid, prod_array[productid], rowid);
                    //zkt 20220927 BUG0057043海格问题，见附件
                    popupobj.selectproductobj.discount_readonly(popupobj, rowid);
                }
                //@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格(像报价单模糊搜索产品时,手动输入数量还得绑定事件，产品id就直接回调)
                getRelatedProductToolFieldPrice(popupobj, rowid);
                popupobj.RelatedProductToolFieldtriggcols = [];
                getRelatedProductToolFieldPriceCallBack(popupobj, rowid);

                //选择产品:设置产品分录中最后一行选择产品后是否自动新增一个空行
                if (popupobj.selectproductobj.popup_selectsource == false) {

                    var addproductrow = 1;
                    var rowcnt = 0;
                    var rec_rowcnt = 0;
                    if (ld("#" + popupobj.divid + " [name=addproductrow]").length > 0) {//parentwindow.document.getElementById('addproductrow') != undefined){
                        addproductrow = ld("#" + popupobj.divid + " [name=addproductrow]").val();// parentwindow.document.getElementById('addproductrow').value;
                    }
                    if (ld("#" + popupobj.divid + " [name=rowcnt]").length > 0) {//parentwindow.document.getElementById('rowcnt') != undefined){
                        rowcnt = ld("#" + popupobj.divid + " [name=rowcnt]").val();// parentwindow.document.getElementById('rowcnt').value;
                    }
                    var trobjs = popupobj.getTrObjsByDelType('no');
                    /*	for(var kk = 1; kk <= rowcnt ; kk++){
						if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+kk+"]").length>0){//parentwindow.document.getElementById('hidden_rowid_'+kk) != undefined && parentwindow.document.getElementById('hidden_rowid_'+kk).value != 1){
							rec_rowcnt++;
						}
					}*/

                    if (addproductrow == 0) {
                        if (rowid >= ld(trobjs).length) {
                            if (change_type != 'replace' && currentModule != 'QuotesChange')	//报价变更单 - 变更时，没有新增行
                                //parentwindow.fnAddProductRow(currentModule,'');
                                popupobj.selectproductobj.fnaddProductRow();
                        }
                    }
                }

            }
        }
    );

}

/**
 * edit:chj
 * date:2014-9-2
 * reason:清除当前产品行信息
 * description:module:模块名、rowid:行数
 **/
var isProductClear = 'no';

function setInventoryProductClear(rowid, module, cleartype) {
    //出库单新增界面：当系统参数控制时，不应该可以选择源单以外的产品
    var popupobj = CrmPopup.getPopupObj('last');

    if ((module == 'Stock' || module == 'OutboundOrder') && cleartype == 'ProductDetailRow') {
        var parentwindow = window;
        if (!addProduct(parentwindow)) return false;
    }
    var protabobj = ld("#" + popupobj.divid + " [name=proTab]").get(0);
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = popupobj.getTrObjsByDelType("no");

    if (protabobj.rows.length <= 2 && trade != 'finance' && trade != 'jijin')
        return;
    //模块所有的自定义字段列
    if (ld("#" + popupobj.divid + " [name=productToolField]").length > 0) {
        var colinfos;
        var typeofdata;
        var mustfield;

        var producttoolfield = ld("#" + popupobj.divid + " [name=productToolField]").val().split('::');// document.getElementById('productToolField').value.split('::');
        var defaultvalue;
        var columnname;
        var uitype;
        var lengthdecimaldigits = ld("#" + popupobj.divid + " [name=lengthdecimaldigits]").val();// ld('#lengthdecimaldigits').val();
        var lengthprice = ld("#" + popupobj.divid + " [name=lengthprice]").val();// ld('#lengthprice').val();
        for (var i = 0; i < producttoolfield.length; i++) {
            defaultvalue = '';
            colinfos = producttoolfield[i].split(':');
            typeofdata = colinfos[2];
            columnname = colinfos[0];
            uitype = colinfos[1];
            mustfield = typeofdata.split('~');
            //zkt 20221110 XUQIU1000804  单据头和单据分录“金额/货币”类型的字段允许自定义小数位数
            var typeofdata_decimal = 2;
            var tmptypeofdata = typeofdata;
            if (uitype >= 25 && uitype <= 50) {
                if (tmptypeofdata != undefined) {
                    var tmptypeofdatas = tmptypeofdata.split(',');
                    if (tmptypeofdatas.length > 1)
                        typeofdata_decimal = tmptypeofdatas[1];
                }
                if (typeofdata_decimal == '') {
                    typeofdata_decimal = 2;
                }
            }
            if (mustfield[0] == 'N' || mustfield[0] == 'NN') {
                defaultvalue = 0;
                if (uitype == 163) {
                    defaultvalue = defaultvalue.toFixed(lengthprice);
                } else if (uitype >= 10 && uitype <= 15) {
                    defaultvalue = defaultvalue.toFixed(lengthdecimaldigits);
                } else {
                    defaultvalue = defaultvalue.toFixed(typeofdata_decimal);
                }
            }
            if (module == 'QuotesChange' && columnname == 'prosheet') continue;
            if (columnname.toLowerCase() == 'imagename')//清除产品图片
            {
                //document.getElementById('span_imagename_'+rowid).innerHTML='';
                //document.getElementById("Carousel_"+rowid).innerHTML='';
                ld(rowobj).find(" [name=span_imagename]").html('');
            }
            if (ld(rowobj).find(" [name=" + columnname + "]").length > 0) {
                //服务开始日期和服务截止日期 不清除
                if (columnname == 'servicecontracts_start_date' || columnname == 'servicecontracts_end_date' || columnname == 'pro_id') {
                    continue;
                }
                if (ld(rowobj).find("#span_" + columnname).length > 0) {
                    ld(rowobj).find("#span_" + columnname).html(defaultvalue);
                }
                //document.getElementById(columnname+rowid).value = defaultvalue;
                ld(rowobj).find("#" + columnname).val(defaultvalue);
            }

            //产品文本输入框变为可输入
            if (columnname == 'productname') {

                ld(rowobj).find("#productname").get(0).style.cursor = '';
                ld(rowobj).find("#productname").get(0).disabled = false;
                //zxm 20230518 提示信息改成placeholder
                //ld(rowobj).find("#productname").get(0).placeholder = arrJsPopLabel['INPUTAKEYWORDSQUERY'];
            }
        }
        //产品ID
        /*if (ld(rowobj).find(" [detailcolumnname=hdnProductId]").length > 0) {
            ld(rowobj).find(" [detailcolumnname=hdnProductId]").val('');
        }*/

        popupobj.detaildatavalue_arr[ld(rowobj).attr("rowindex")-1].hdnProductId=0;
        if ('QuotesChange' != module) {
            //源单列特殊控制

            if (ld(rowobj).find(" #lineitem_id").length > 0) {
                ld(rowobj).find(" #lineitem_id").val('');
            }
            //popupobj.detaildatavalue_arr[ld(rowobj).attr("rowindex")-1].selectSourceModuleid=0;

            /*if (ld(rowobj).find(" [detailcolumnname=selectSourceModuleid]").length > 0) {
                ld(rowobj).find(" [detailcolumnname=selectSourceModuleid]").val('');
            }*/


        }
        isProductClear = 'yes';
        popupobj.selectproductobj.AddRowByRowIndex(0);

        if (document.getElementById('QcBomSave') != undefined) {
            popupobj.fieldformulaobj.CountsubTotal();
        } else {
            popupobj.fieldformulaobj.CountsubTotal();
        }

    }
}

var isprodsearchajax = 1;

function clickOnFoucus(obj) {

    var promptmessage = arrJsPopLabel['INPUTAKEYWORDSQUERY'];
    if (obj.value == "") {
        //obj.value = "";
        isprodsearchajax = 2;
        //fieldname.style.color='#000';
        obj.focus;
    }
}

function clickOnBlur(obj) {
    var fieldname = obj;
    if (fieldname.value == "") {
        //fieldname.placeholder = arrJsPopLabel['INPUTAKEYWORDSQUERY'];
        //fieldname.style.color='#999';
    }
}

//获取源单名称
function setModuleEntityName() {
    var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    var parentwindow = window;
    var tableobj = popupobj.getDetailTableObj();
    var trobjs = popupobj.getTrObjsByDelType("no");//获取没有删除的行
    if (ld(trobjs).length > 0) {
        var entitytye;
        var k = 0;
        var SourceModuleArray = new Array();//存放源单名称的数组
        var SourceModule = new Array();
        var rowcnt = ld("#" + popupobj.divid + " [name=rowcnt]").val();
        //for(var i=1; i<=rowcnt; i++){
        ld.each(trobjs, function () {
            //	if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val() == 0){
            entitytye = ld(this).find(" [name=span_entitytypeid]");// parentwindow.document.getElementById('span_entitytypeid'+i);//源单列
            //edit:can 20210804 47197: （http://xiaoshou360.com/xs/xjsy [^]）(上海享暨实业有限公司)新建采购合同时，选择甲方合同编号（合同订单），选择好之后导入单据分录，保存的时候提示甲方合同编号为空
            if (ld(entitytye).length > 0) {
                if (ld(entitytye).html() != '') {
                    SourceModuleArray[k] = ld(entitytye).html();
                    k++;
                }
            }
            //}
        })

        if (SourceModuleArray.length >= 1) {
            //去除数组重复的值
            for (var i = 0; i < SourceModuleArray.length; i++) {
                !RegExp(SourceModuleArray[i], "g").test(SourceModule.join(",")) && (SourceModule.push(SourceModuleArray[i]));
            }
            if (ld("#" + popupobj.divid + " [name=salesorder_id]").length > 0) {
                ld("#" + popupobj.divid + " [name=salesorder_id]").get(0).value = SourceModule.join(',');
            }
            if (ld("#" + popupobj.divid + " [name=purchaseorder_id]").length > 0) {
                ld("#" + popupobj.divid + " [name=purchaseorder_id]").get(0).value = SourceModule.join(',');
            }
        }
    }
}

//获取产品的供应商
function getProductByVendorid() {
    var parentwindow = window;
    if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
        parentwindow = window.opener;
    }
    if (parentwindow.document.getElementById('rowcnt') != undefined) {
        var productid = '';
        var rowcnt = parentwindow.document.getElementById('rowcnt').value;
        var trobjs = popupobj.getTrObjsByDelType("no");
        ld.each(trobjs, function () {
            productid = ld(this).find(" #hdnProductId").val();//parentwindow.document.getElementById('hdnProductId'+i).value;
            if (ld.trim(productid) != '' && parseInt(productid) > 0) {
                return false;
            }
        })
        /*
		for(var i=1; i<=rowcnt; i++){
			if(!empty(productid)){
				break;
			}
			if(parentwindow.document.getElementById('hidden_rowid_'+i).value == 0){
				if(empty(productid)){
					productid = parentwindow.document.getElementById('hdnProductId'+i).value;
				}
			}
		}*/

        if (!empty(productid)) {
            if (parentwindow.document.EditView.vendor_id != undefined && parentwindow.document.EditView.vendor_id.value == '') {
                var urlstring = 'index.php?module=Products&action=ProductsAjax&file=GetSearchInfo&productid=' + productid + '&getVendorName=yes';
                http_reqfield = createfieldXMLHTTP();
                http_reqfield.open("POST", urlstring, false);
                getVendorName_finished = false;
                http_reqfield.onreadystatechange = getVendorName;
                http_reqfield.setRequestHeader("If-Modified-Since", "0");
                http_reqfield.send();
                if (getVendorName_finished == true) {

                }
            }
        }
    }
}

function getVendorName() {
    if (http_reqfield.readyState == 4) {
        var parentwindow = window;
        if (window.opener != undefined && parentwindow.document.getElementById('proTab') == undefined) {
            parentwindow = window.opener;
        }
        var results = http_reqfield.responseText;
        var prod_array = eval('(' + results + ')') ? eval('(' + results + ')') : JSON.parse(results);
        parentwindow.document.EditView.vendor_id.value = prod_array['vendor_id'];
        parentwindow.document.EditView.vendors_name.value = prod_array['vendorname'];
        getVendorName_finished = true;
    }
}

function calculateTotal() {
    var total = 0;
    var tax_amount = 0;
    var popupobj = CrmPopup.getlastPopupObjByPageType("create_edit_modulepage");//获取最后一个编辑或新增的弹出层界面
    var nullfield =popupobj.selectproductobj.module_nullfieldobj.val();// ld("#" + popupobj.divid + " [name=module_nullfield]").val();// document.getElementById('module_nullfield').value;
    var nullfield_arr = nullfield.split("##");
    var nullfieldname;
    var totalobj =popupobj.selectproductobj.totalobj;// ld("#" + popupobj.divid + " [name=total]");

    //edit:can 2020-11-16 43301: （https://61mis.com/kfbcrm [^]）合同订单新建界面，选择产品后，产品分录中【调整】，合计金额没有改变（需要补丁）
    var adjustmentobj =popupobj.selectproductobj.adjustmentobj;// ld("#" + popupobj.divid + " [tag=maintablefield_adjustment]");
    var discount_amountobj =popupobj.selectproductobj.discount_amountobj;// ld("#" + popupobj.divid + " [tag=maintablefield_discount_amount]");

    if (discount_amountobj.length > 1) {
        //明细有个disacount_amount字段
        //公式账套

        //discount_amountobj==ld("#"+popupobj.divid+" [name=discount_amount]");
        ld.each(ld("#" + popupobj.divid + " [name=discount_amount]"), function () {

            if (ld(this).attr("tag") != undefined && ld(this).attr("tag") == 'maintablefield_discount_amount') {
                ////edit:can 2020-11-03 43168: （61mis.com/kfbcrm/index.php）销售管理-合同订单-编辑/新建（客户问题需
                discount_amountobj = ld(this);
                // alert(discount_amountobj.val());
                return false;
            }

        })


    }

    var adjustmentTypeobj =popupobj.selectproductobj.adjustmentTypeobj;// ld("#" + popupobj.divid + " [name=adjustmentType]");

    //zkt 20221110 XUQIU1000804  单据头和单据分录“金额/货币”类型的字段允许自定义小数位数
    //获取合计字段typeofdata
    var typeofdata_decimal = 2;
    var totalfieldinfo = '';
    if (popupobj.detailfields != undefined) {
        for (var i = 0; i < popupobj.detailfields.length; i++) {
            if (popupobj.detailfields[i].columnname == "total") {
                totalfieldinfo = popupobj.detailfields[i];
                break;
            }
        }
        if (totalfieldinfo != '' && totalfieldinfo != undefined) {
            //金额类型字段，小数位数去typeofdata
            if (totalfieldinfo.uitype >= 25 && totalfieldinfo.uitype <= 50) {
                var tmptypeofdata = totalfieldinfo.typeofdata;
                if (tmptypeofdata != undefined) {
                    var tmptypeofdatas = tmptypeofdata.split(',');
                    if (tmptypeofdatas.length > 1)
                        typeofdata_decimal = tmptypeofdatas[1];
                }
                if (typeofdata_decimal == '') {
                    typeofdata_decimal = 2;
                }
            }
        }

    }

    if (totalobj.length > 0) {
        //基本行业含税金额
        //	var row_cnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;
        var total = 0;
        var trobjs = popupobj.getTrObjsByDelType('no');
        //console.log(popupobj.detaildatavalue_arr)
        if(popupobj.detaildatavalue_arr==undefined)
            return ;
        var len=popupobj.detaildatavalue_arr.length;
        for(var i=0;i<len;i++)
        {
            var nullfield_num = 0;
            for(var k = 0; k<nullfield_arr.length; k++){
                if(nullfield_arr[k] == 'productname'){
                    nullfieldname = 'hdnProductId';
                }else{
                    nullfieldname = nullfield_arr[k];
                }
                var tmpvalue=popupobj.detaildatavalue_arr[i].nullfieldname

                if(popupobj.detaildatavalue_arr[i].nullfieldname!=undefined && (tmpvalue==''||tmpvalue<=0)){
                    nullfield_num++;
                }
            }
            if(nullfield_num == nullfield_arr.length){
                return true;
            }
            var tax_amountvalue=popupobj.detaildatavalue_arr[i].tax_amount //ld(this).find(" [detailcolumnname=tax_amount]");


            if(tax_amountvalue == '')tax_amountvalue = 0;
            //duan 20231019 统计合计时，不统计未选产品的行
            if(popupobj.detaildatavalue_arr[i].productid > 0){
                total +=eval(tax_amountvalue);
            }

        }

        //  var total = parseFloat(ld("#" + popupobj.divid + " [name=subtotal_tax_amount]").html());
        var subtotalobj =popupobj.selectproductobj.subtotalobj;// ld("#" + popupobj.divid + " [name=subtotal]");
        if (subtotalobj.length > 0) {
            //document.getElementById('subtotal').value = total;
            subtotalobj.val(total);
        }

        //外贸行业共计含税含运费RMB总价
        var isRmbProduct = 'bom';// rmb_checkRMBProduct();

        if (isRmbProduct == 'rmb') {
            if (subtotalobj.length > 0) {
                var subtotal = subtotalobj.val();
                if (subtotal == '') {
                    subtotal = 0;
                    subtotalobj.val(0);
                }
                totalobj.val(roundValue(subtotal.toString()));
            }
        }

        //整单折扣

        if (discount_amountobj.length > 0) {


            var discount_amount = discount_amountobj.val();

            if (discount_amount == '') {
                discount_amount = 0;
                discount_amountobj.val('0.00');
            }

            if (isNaN(discount_amount)) {
                //18275: 合同订单、报价单、服务合同、采购订单、销售发票、采购发票新增界面：整单折扣输入非数字字符，点击保存按钮，结果没有反应，没有给出提示信息
                var confirm_str = arrJsPopLabel['INVALIDALLSINGLEDISCOUNT'];
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                return 'false';
            }

            discount_amount = eval(discount_amount);
            var allSingledDiscountobj = ld("#" + popupobj.divid + " [name=allSingledDiscount]");

            //整单折扣根据翻译“直接降价”/“直接加价”判断采用减法还是加法

            if (allSingledDiscountobj.length > 0) {

                var allSingledDiscount = allSingledDiscountobj.val();

                if (allSingledDiscount == '-') {
                    total -= eval(discount_amount);

                } else if (allSingledDiscount == '%') {
                    if (discount_amount < 0 || discount_amount > 100) {
                    } else {
                        total = total * ((100 - discount_amount) / 100);
                    }

                } else if (allSingledDiscount == '+') {

                    if (adjustmentobj.length > 0) {
                        var adjustment = adjustmentobj.val();
                        if (adjustment == '') {
                            adjustment = 0;
                            adjustmentobj.val(0);
                        }

                        var adjustmentType = adjustmentTypeobj.val();
                        if (adjustmentType == '+') {
                            total += eval(adjustment);
                        } else {
                            total -= eval(adjustment);
                        }
                    }

                    total += (JsNumbertoFixed((0 + eval(discount_amount)), typeofdata_decimal));

                } else if (allSingledDiscount == '+%') {


                    //(小计+调整)*(100+百分比)*0.01

                    if (adjustmentobj.length > 0) {
                        var adjustment = adjustmentobj.val();
                        if (adjustment == '') {
                            adjustment = 0;
                            adjustmentobj.val(0);
                        }

                        var adjustmentType = adjustmentTypeobj.val(0);
                        if (adjustmentType == '+') {
                            total += eval(adjustment);
                        } else {
                            total -= eval(adjustment);
                        }
                    }
                    total = total * (JsNumbertoFixed((100 + eval(discount_amount)), typeofdata_decimal)) * 0.01;
                }

            }

            if (allSingledDiscount == '-' || allSingledDiscount == '%') {
                //调整

                if (adjustmentobj.length > 0) {
                    var adjustment = adjustmentobj.val();
                    if (adjustment == '') {
                        adjustment = 0;
                        adjustmentobj.val(0);
                    }

                    var adjustmentType = adjustmentTypeobj.val();
                    if (adjustmentType == '+') {
                        total += eval(adjustment);
                    } else {
                        total -= eval(adjustment);
                    }
                }
            }
        } else if (adjustmentobj.length > 0) {

            var adjustment = adjustmentobj.val();
            if (adjustment == '') {
                adjustment = 0;
                //document.getElementById('adjustment').value = 0
                adjustmentobj.val('0');
            }

            var adjustmentType = adjustmentTypeobj.val();
            if (adjustmentType == '+') {
                total += eval(adjustment);
            } else {
                total -= eval(adjustment);
            }
        }


    }
    popupobj.productLicencePrice = total;
    popupobj.cumulativeBenefits = 0;
    try {
        AjaxJSPage('PricePolicyUse', 'include/js/modules/PricePolicy/PricePolicyUse.js');
        var useObj = PricePolicyUse.getInstance(popupobj);
        if (useObj.getBlockInfo() && useObj.triggerReCalculate) {
            useObj.updateTotal(total);
            // 同步请求 todo 如果没有已选的列表，可以异步
            useObj.updateCards();
            // 更新后重算total
            total = useObj.reCalculateTotal(total);
            useObj.updateTotal(total);
        }
    }
    catch (e) {
        console.log(e);
    }

    total = total.toFixed(typeofdata_decimal);
    popupobj.productLicencePrice = parseFloat(popupobj.productLicencePrice).toFixed(typeofdata_decimal);
    popupobj.cumulativeBenefits = parseFloat(popupobj.cumulativeBenefits).toFixed(typeofdata_decimal);
    return total;
}

//整单折扣、调整回车事件
function setDisCalcTotal(event) {
    var e = event || window.event || arguments.callee.caller.arguments[0];
    var keyCode = e.keyCode || e.which || e.charCode;
    if (keyCode == 13) {
        calcTotal();
    }
}

function calcTotal() {


    var popupobj = CrmPopup.getlastPopupObjByPageType("create_edit_modulepage");//获取最后一个编辑或新增的弹出层界面

    if (popupobj.module == 'CashBill') {
        return caltotal();
    } else if (popupobj.module == 'SendCashBill') {
        return calSendTotal();
    }
    var totalobj =popupobj.selectproductobj.totalobj;// ld("#" + popupobj.divid + " [name=total]");
    if (totalobj.length > 0) {
        var iscomputertotal = 'yes';


        if (popupobj.noprofiledetailfields != undefined)
            ld.each(popupobj.noprofiledetailfields, function (tmpcolname, nofieldinfo) {

                if (tmpcolname == 'tax_amount') {
                    iscomputertotal = 'no';
                    return false;
                }
            })

        if (iscomputertotal == 'no') {
            return true;
        }

        var total = calculateTotal();

        //edit:can 2020-09-16 42911: (https://kehu001.com/weixin/kh36646 [^])订单管理-合同订单(南京瑞源生物客户问题)；在合同订单详情界面，进行编辑修改订单状态字段后，合计会变为0；这个问题不好重现，偶然会出现；远程客户时没有重现，客户说每天都会出现，麻烦处理
        //没有价税合计的字段权限

        if (total != 'false') {
            popupobj.before_totalvalue = ld(totalobj).val();
            totalobj.val(total);
            popupobj.now_totalvalue = ld(totalobj).val();
            var span_totalobj = ld("#" + popupobj.divid + " [name=span_total]");

            if (span_totalobj.length > 0) {
                // document.getElementById('span_total') != undefined){
                //	document.getElementById('span_total').innerHTML = total;
                span_totalobj.html(total);
            }

            var grandTotalobj = popupobj.selectproductobj.grandTotalobj;// ld("#" + popupobj.divid + " [name=grandTotal]");
            if (grandTotalobj.length > 0) {
                //document.getElementById('grandTotal').value = total;
                grandTotalobj.val(total);
            }
            if (popupobj.mainfieldformulaobj.maincolumninfo['total'] != undefined) {
                var param = [];
                param['data'] = {'formulafieldname': popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname};
                popupobj.mainfieldformulaobj.startComputer(param);
            }
            if (popupobj.mainfieldformulaobj.maincolumninfo['total'] != undefined && popupobj.mainfieldformulaobj.computerfieldnamesformula[popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname] == undefined)
                popupobj.fieldruleobj.CheckReLoadPopup();

            return true;
        } else {
            return false;
        }
    } else {
        return true;
    }
}

function setStockPresence(stockid, persence, type) {
    if (type == 0 && persence == 1) {
        window.location.href = "index.php?action=DetailView&module=Stock&parenttab=Stock&record=" + stockid + "&power=false";
        return false;
    }
    if (persence == 1) {
        //var message = window.confirm("确定入库吗？");
        var message = window.confirm(arrJsPopLabel['OKWAREHOUSINGIT']);
    } else {
        //var message = window.confirm("执行后，该入库单将被还原到“未入库”状态，库存数量还原到入库前。确定要撤销入库吗？");
        var message = window.confirm(arrJsPopLabel['INVENTORYQUANTITIESRESTORED']);
    }
    //alert("action=DetailView&module=Stock&parenttab=Stock&record="+stockid+"&salestype=yes&setstock=true");
    //return false;
    if (message) {
        new Ajax.Request("index.php",
            {
                queue: {
                    position: "end",
                    scope: "command"
                },
                method: "post",
                postBody: "action=DetailView&module=Stock&parenttab=Stock&record=" + stockid + "&salestype=yes&setstock=true",
                onComplete: function (response) {
                    window.location.href = "index.php?action=DetailView&module=Stock&parenttab=Stock&record=" + stockid + "&salestype=yes";
                }
            }
        );
    }


}

function calcGrandTotal() {
    var adjustment;
    var objSelectValue;
    var objSelect;
    var total;
    var discount_amount = 0.00;
    var allSingledDiscount;
    var parentwindow = window;
    if (window.opener != undefined) {
        parentwindow = window.opener;
    }
    if (parentwindow.document.getElementById('total') != undefined) {
        total = eval(parentwindow.document.getElementById('total').value);
        var grandTotal = 0;
        if (parentwindow.document.getElementById('subtotal') != undefined) {
            grandTotal = eval(parentwindow.document.getElementById('subtotal').value);
        }
        objSelect = parentwindow.document.getElementById('adjustmentType');
        if (parentwindow.document.getElementById('adjustmentType') != undefined) {
            if (parentwindow.document.getElementById('discount_amount') != undefined) {
                discount_amount = parentwindow.document.getElementById('discount_amount').value;//获取整单折扣金额
                allSingledDiscount = parentwindow.document.getElementById('allSingledDiscount').value;//获取整单折扣类型
                if (allSingledDiscount == '%') {
                    discount_amount = grandTotal * ((100 - discount_amount) / 100);
                }
            }
            var sTotal = total - grandTotal;
            if (parentwindow.document.getElementById('adjustment') != undefined) {
                adjustment = eval(parentwindow.document.getElementById('adjustment').value);
            }
            if (adjustment >= 0) {
                if (discount_amount == 0) {
                    parentwindow.document.getElementById('adjustment').value = roundValue(Math.abs(total - grandTotal));
                    if ((eval(total) - eval(grandTotal)) < 0) {
                        objSelectValue = '-';
                    } else {
                        objSelectValue = '+';
                    }
                } else {
                    if (eval(sTotal) >= 0) {

                        if (objSelect.value == '+') {
                            parentwindow.document.getElementById('adjustment').value = roundValue(eval(total) + eval(discount_amount) - eval(grandTotal));
                        } else {
                            if (sTotal - adjustment - discount_amount >= 0) {
                                parentwindow.document.getElementById('adjustment').value = roundValue(Math.abs(sTotal - adjustment - discount_amount));
                                objSelectValue = '+';
                            } else {
                                objSelectValue = '-';
                            }
                        }
                    } else {
                        if (discount_amount == 0) {
                            parentwindow.document.getElementById('adjustment').value = roundValue(Math.abs(total - grandTotal - adjustment));
                            if ((eval(total) - eval(grandTotal) - eval(adjustment)) < 0) {
                                objSelectValue = '-';
                            } else {
                                objSelectValue = '+';
                            }
                        }
                    }
                }

            } else {
                parentwindow.document.getElementById('adjustment').value = sTotal;
                objSelectValue = '+';
            }

            for (var i = 0; i < objSelect.options.length; i++) {
                if (objSelect.options[i].value == objSelectValue) {
                    objSelect.options[i].selected = true;
                    break;
                }
            }
        }

    }

}

var product_image_obj_array = new Array();
var product_image_obj;
var product_rowid;
var product_Car_NoOfSides;
var product_Car_Image_Sources = new Array();
var product_image_http;

function getproductImageName(productid, rowid, columnname) {
    columnname = !empty(columnname) ? columnname : 'imagename';
    var urlstring = 'index.php?module=Products&action=productImage&id=' + productid + "&rowid=" + rowid + "&columnname=" + columnname + "&ReportHeader=dheader";
    product_Car_Image_Sources = new Array();
    product_image_obj_array = new Array();
    product_image_http = createfieldXMLHTTP();

    product_image_http.open("POST", urlstring, false);
    product_image_http.onreadystatechange = createproductImageanim;
    product_image_http.setRequestHeader("If-Modified-Since", "0");
    product_image_http.send();
}

function createproductImageanim() {
    var parentwindow = window;
    var popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    if (product_image_http.readyState == 4) {
        if (product_image_http.status == 0 || product_image_http.status == 200) {
            var tableobj = popupobj.getDetailTableObj();
            var str = product_image_http.responseText;

            var restobj = eval('(' + str + ')') ? eval('(' + str + ')') : JSON.parse(str);
            //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示
            columnname = restobj.columnname;
            var curproduct_rowid = restobj.product_rowid;
            var rowobj = ld(tableobj).find("tr[rowindex=" + curproduct_rowid + "]");
            if (restobj.total_images > 1) {
                for (var i = 0; i < restobj.images.length; i++) {
                    var imagesplit = restobj.images[i].split(',');
                    for (var j = 0; j < imagesplit.length; j++) {


                        product_Car_Image_Sources.push(imagesplit[j]);
                    }
                }

                product_Car_NoOfSides = restobj.product_Car_NoOfSides;

                //修改宽度不要忘了修改php中编辑和查看图片宽度
                var image_list = '<div name="Carousel_' + columnname + '_' + curproduct_rowid + '" id="Carousel_' + columnname + '_' + curproduct_rowid + '" style="position:relative;vertical-align: middle;"><img src="modules/Products/placeholder.gif" width="370" height="117" style="position:relative;">	</div>';
                ld(rowobj).find(' #span_' + columnname + '_' + curproduct_rowid).get(0).innerHTML = image_list;
                product_image_obj = new product_image_Carousel(product_Car_NoOfSides, product_Car_Image_Sources, curproduct_rowid, columnname);
                product_image_obj.product_image_anim()
            } else if (restobj.total_images == 1) {
                ld(rowobj).find('td[detailfieldname='+columnname+']').find('span').get(0).innerHTML = restobj.images[0];
            }
        }
    }
}

/**
 产品图片动画
 **/
function product_image_Carousel(Car_NoOfSides, Car_Image_Sources, rowid, columnname) {
    this.rowid = rowid;
    this.columnname = columnname || '';
    this.Car_NoOfSides = Car_NoOfSides;
    this.Car_Image_Sources = Car_Image_Sources;
    this.i = 0;
    if (typeof Car_NoOfSides != 'undefined') {
        this.CW_I = new Array(Car_NoOfSides / 2 + 1);
        this.C_ClcW = new Array(Car_NoOfSides / 2);
        this.C_CoefOf = Car_NoOfSides == 4 ? 0 : this.Car_NoOfSides == 6 ? 2 : this.Car_NoOfSides == 8 ? 5 : 9;
    }

    this.C_Coef = new Array(
        3 * Math.PI / 2, 0, 3 * Math.PI / 2, 11 * Math.PI / 6, Math.PI / 6, 3 * Math.PI / 2, 7 * Math.PI / 4, 0,
        Math.PI / 4, 3 * Math.PI / 2, 5 * Math.PI / 3, 11 * Math.PI / 6, 0, Math.PI / 6, Math.PI / 3);
    if (typeof Car_Image_Sources != "undefined")
        this.C_Pre_Img = new Array(Car_Image_Sources.length);
    if (typeof Car_NoOfSides != 'undefined') {

        this.C_Angle = Car_Direction ? Math.PI / (Car_NoOfSides / 2) : 0,
            this.C_CrImg = Car_NoOfSides,
            this.C_MaxW = 0, this.C_TotalW = 0,
            this.C_Stppd = false,
            this.C_LeftOffset = 0,
            this.C_HalfNo = Car_NoOfSides / 2;
    }

}

var Car_Image_Width = 140;
var Car_Image_Height = 80;
var Car_Border = true;		// true or false
var Car_Border_Color = "black";
var Car_Speed = 4;
var Car_Direction = true;		// true or false


product_image_Carousel.prototype.product_image_anim = function () {
    var parentwidow = window;
    var popupobj = CrmPopup.getPopupObj('last');
    if (popupobj.module == 'Productbom' && popupobj.pagetype != "detailview_modulepage") {
        popupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);//分录选产品套餐时，popupobj对象错误。
    }

    if (window.opener != undefined) {
        parentwidow = window.opener;
    }

    if (parentwidow.document.getElementById && typeof this.Car_Image_Sources != "undefined") {
        for (var i = 0; i < this.Car_Image_Sources.length; i += 2) {
            this.C_Pre_Img[i] = new Image();
            this.C_Pre_Img[i].src = this.Car_Image_Sources[i]
        }
        this.C_MaxW = Car_Image_Width / Math.sin(Math.PI / this.Car_NoOfSides) + this.C_HalfNo + 1;
        if (empty(this.columnname)) {
            this.Car_Div = ld("#" + popupobj.divid + " [name=Carousel_" + this.rowid + "]").get(0);//parentwidow.document.getElementById("Carousel_"+this.rowid);
        } else {
            this.Car_Div = ld("#" + popupobj.divid + " [name=Carousel_" + this.columnname + '_' + this.rowid + "]").get(0);
        }
        if (this.Car_Div == undefined) {
            return false;
        }
        this.Car_Div.style.height = Car_Image_Height + 20 + "px";
        //alert(this.C_HalfNo);
        for (i = 0; i < this.C_HalfNo; i++) {
            this.CW_I[i] = parentwidow.document.createElement("img");
            this.Car_Div.appendChild(this.CW_I[i]);
            this.CW_I[i].style.position = "absolute";
            this.CW_I[i].style.top = 0 + "px";
            this.CW_I[i].style.height = Car_Image_Height + "px";
            this.CW_I[i].valign = "middle";
            if (Car_Border) {
                this.CW_I[i].style.borderStyle = "solid";
                this.CW_I[i].style.borderWidth = 1 + "px";
                this.CW_I[i].style.borderColor = Car_Border_Color;
            }
            this.CW_I[i].src = this.Car_Image_Sources[2 * i];
            this.CW_I[i].lnk = this.Car_Image_Sources[2 * i + 1];
            //this.CW_I[i].onclick=this.C_LdLnk;
            this.CW_I[i].onmouseover = this.C_Stp;
            this.CW_I[i].onmouseout = this.C_Rstrt
        }
        product_CarImages(this);

        product_image_Carousel.setInterval(product_CarImages, 50, this);
    }
};
var _product_sto = setInterval;
product_image_Carousel.setInterval = function (callback, timeout, param) {
    var args = Array.prototype.slice.call(arguments, 2);
    var _cb = function () {
        callback.apply(null, args);
    }
    _product_sto(_cb, timeout);
}

function product_CarImages(product_image_obj) {


    if (!product_image_obj.C_Stppd) {
        product_image_obj.C_TotalW = 0;
        for (product_image_obj.i = 0; product_image_obj.i < product_image_obj.C_HalfNo; product_image_obj.i++) {
            product_image_obj.C_ClcW[product_image_obj.i] = Math.round(Math.cos(Math.abs(product_image_obj.C_Coef[product_image_obj.C_CoefOf + product_image_obj.i] + product_image_obj.C_Angle)) * Car_Image_Width);
            product_image_obj.C_TotalW += product_image_obj.C_ClcW[product_image_obj.i];
        }
        product_image_obj.C_LeftOffset = (product_image_obj.C_MaxW - product_image_obj.C_TotalW) / 2;
        for (product_image_obj.i = 0; product_image_obj.i < product_image_obj.C_HalfNo; product_image_obj.i++) {

            product_image_obj.CW_I[product_image_obj.i].style.left = product_image_obj.C_LeftOffset + "px";
            product_image_obj.CW_I[product_image_obj.i].style.width = product_image_obj.C_ClcW[product_image_obj.i] + "px";
            product_image_obj.C_LeftOffset += product_image_obj.C_ClcW[product_image_obj.i];
        }
        product_image_obj.C_Angle += Car_Speed / 720 * Math.PI * (Car_Direction ? -1 : 1);
        if ((Car_Direction && product_image_obj.C_Angle <= 0) || (!Car_Direction && product_image_obj.C_Angle >= Math.PI / product_image_obj.C_HalfNo)) {
            if (product_image_obj.C_CrImg == product_image_obj.Car_Image_Sources.length)
                product_image_obj.C_CrImg = 0;
            if (Car_Direction) {
                product_image_obj.CW_I[product_image_obj.C_HalfNo] = product_image_obj.CW_I[0];
                for (product_image_obj.i = 0; product_image_obj.i < product_image_obj.C_HalfNo; product_image_obj.i++) product_image_obj.CW_I[product_image_obj.i] = product_image_obj.CW_I[product_image_obj.i + 1];
                product_image_obj.CW_I[product_image_obj.C_HalfNo - 1].src = product_image_obj.Car_Image_Sources[product_image_obj.C_CrImg];
                product_image_obj.CW_I[product_image_obj.C_HalfNo - 1].lnk = product_image_obj.Car_Image_Sources[product_image_obj.C_CrImg + 1]
            } else {
                for (product_image_obj.i = product_image_obj.C_HalfNo; product_image_obj.i > 0; product_image_obj.i--)
                    product_image_obj.CW_I[product_image_obj.i] = product_image_obj.CW_I[product_image_obj.i - 1];
                product_image_obj.CW_I[0] = product_image_obj.CW_I[product_image_obj.C_HalfNo];
                product_image_obj.CW_I[0].src = product_image_obj.Car_Image_Sources[product_image_obj.C_CrImg];
                product_image_obj.CW_I[0].lnk = product_image_obj.Car_Image_Sources[product_image_obj.C_CrImg + 1];
            }
            product_image_obj.C_Angle = Car_Direction ? Math.PI / product_image_obj.C_HalfNo : 0;
            product_image_obj.C_CrImg += 2;
        }
    }


};

product_image_Carousel.prototype.C_LdLnk = function () {
    if (this.lnk) window.open(this.lnk, "test", "width=600,height=400,resizable=1,scrollbars=1")
};

product_image_Carousel.prototype.C_Stp = function () {
    this.style.cursor = this.lnk ? "pointer" : "default";
    this.C_Stppd = true;
};
product_image_Carousel.prototype.C_Rstrt = function () {
    this.C_Stppd = false
};
