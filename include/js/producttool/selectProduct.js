/**
 *
 * @param
 * @returns
 * @author Chj
 */
function fun_selectproduct(fieldinfojson) {


    this.popupobj = CrmPopup.getPopupObj('last');
    this.cur_divid = this.popupobj.divid;
    //this.cur_module = CrmPopup.findHtmlobj(this.cur_divid, 'module').val();	//当前模块
    this.cur_module = this.popupobj.module;	//当前模块  zxm 20230203 之前那个写法 获取的module为undefined

    this.addproductrow = 1;	//设置单据分录明细中最后一行录入产品后是否自动新增行

    this.setproductpricefor_accountbuy = 1	//产品单价自动根据客户最近一次购买的产品价格带出

    this.lengthprice = 2;	//价格格式化小数位

    this.lengthdecimaldigits = 2;	//单据明细中数量小数位数

    this.trade = '';	//行业版本

    this.source_other_products = 1;	//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否

    this.isProductClear = 'no';	//清除产品当前行

    this.addRow_finished = false;	//新增行
    this.massrow = 'no';

    this.sourcemodule_reocrd = 0;	//选择源单的record

    this.clear_opertion = 'no';	//是否是清除操作

    this.popup_selectsource = false;	//true:选择源单  false:选择产品
    this.batchselect = false;	//true:选择批次  false:非选择批次
    this.tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");//获取分录所在的表格对象
    this.chooseProductRowindex = 1;//点击选择产品的行号（批量选择产品）
    this.prod_array = {};//GetSearchInfo 产品信息数组 zxm20221228
    this.everyRenderingNums = 9;//GetSearchInfo 产品信息数组每次渲染条数 zxm20221228
    this.rowhtml = '';//行html zxm20221228
    this.setHtmlObj();
    if (!empty(fieldinfojson)) {
        var restobj = fieldinfojson;// eval('('+ fieldinfojson +')')?eval('('+ fieldinfojson +')'):JSON.parse(fieldinfojson);

        this.fields = restobj.fields; //单据分录自定义字段信息

        this.addproductrow = restobj.addproductrow;

        this.setproductpricefor_accountbuy = restobj.SystemArgument;

        this.lengthprice = restobj.lengthprice;

        this.lengthdecimaldigits = restobj.lengthdecimaldigits;

        if (restobj.source_other_products != undefined) {
            this.source_other_products = restobj.source_other_products;
        }

        if (restobj.trade != undefined) {
            this.trade = restobj.trade;
        }
    }
}

//清除批次
fun_selectproduct.clear_batchtext = function (jqueryobj) {
    var popupobj = CrmPopup.getPopupObj('last');
    var tableobj = popupobj.getDetailTableObj();
    var parentnode = ld(jqueryobj).parent();
    var rowid = 0;
    while (ld(parentnode).prop("tagName") !== "TR") {
        parentnode = ld(parentnode).parent();
        rowid = ld(parentnode).attr("rowindex");
    }
    var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");

    ld(parentnode).find(" [name=batchtext]").val("");

    //ls 2022-04-08 【ID1002717】入库单选择批次时带出入库单时所选批次的产品类别采购员等（清除所选批次时）
    popupobj.RelatedProductToolFieldtriggcols = [];
    getRelatedProductToolFieldPriceCallBack(popupobj, rowid);
}

/*
批次复值
*/
fun_selectproduct.setbatchtext = function (batchtext, quantity) {
    var lastpopupobj = CrmPopup.getPopupObj("lastprev");
    var popupobj = CrmPopup.getPopupObj("last");
    var tableobj = lastpopupobj.getDetailTableObj();

    var rowobj = ld(tableobj).find("tr[rowindex=" + popupobj.rowid + "]");
    //editor:gyq_161 reason:带分录模块弹出层   2019/11/14 11:17
    lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['producthave_batchtext'] = 'yes';
    lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['batchtext'] = batchtext;
    //ld(rowobj).find(" [name=batchtext]").val(batchtext);
    //ld("#batchtext"+popupobj.rowid).val(batchtext);
    if (lastpopupobj.module == 'Stock') {
        popupobj.CancelEvent();
        return true;
    }
    if (lastpopupobj.module == "Checks") {
        //chj 2022/6/20 选择批次，批次数量自动覆盖产品数量
        if (ld("#" + popupobj.divid + " [name=select_batch_qty]").is(':checked') === true) {
            ld(rowobj).find(" [name=firmoffer]").val(quantity);
            ld(rowobj).find(" [name=paperquantity]").val(quantity);
            ld(rowobj).find(" [name=span_paperquantity]").html(quantity);
        }

        lastpopupobj.fieldformulaobj.changedatabyColumnname("firmoffer", popupobj.rowid);//调用字段公式
        //ld(rowobj).find(" [name=paperquantity]").val(quantity);
        //ld(rowobj).find(" [name=span_paperquantity]").html(quantity);
        /*ld("#paperquantity"+popupobj.rowid).val(quantity  );
        ld("#span_paperquantity"+popupobj.rowid).html(quantity);*/
    } else {
        //38097: 出库单选择产品批次后，应该带出产品批次数量
        //chj 2022/6/20 选择批次，批次数量自动覆盖产品数量
        if (ld("#" + popupobj.divid + " [name=select_batch_qty]").is(':checked') === true) {
            ld(rowobj).find(" [name=quantity]").val(quantity);
        }

        //ld("#quantity"+popupobj.rowid).val(quantity);
        //不需要考虑价格策略，价格策略有合同（服务，销售），报价单
        lastpopupobj.fieldformulaobj.changedatabyColumnname("quantity", popupobj.rowid);//调用字段公式
    }
    popupobj.CancelEvent();

}

/*
* XUQIU20240719-03 ls 240723 上海益弹新材料个性化开发 （选择批号  弹窗）
*/
fun_selectproduct.prototype.selectbatchtextYitan = function (jqueryobj) {
    // jqueryobj:点击的按钮
    var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或编辑的弹出层
    parentnode = popupobj.getTrObjByChild(jqueryobj);
    var rowid = ld(parentnode).attr("rowindex");
    popupobj.rowid = rowid;

    var rowobj = parentnode;//ld(tableobj).find("tr[rowindex="+this.rowid+"]");
    var productid = ld(rowobj).find(" [name=hdnProductId]").val();

    if (empty(productid)) {
        MessagePopup.TipOne_warning("请先选择产品！");
        return false;
    }

    var href_url = 'index.php?module=Products&action=ProductsAjax&file=getbatchlistSpecial&productid=' + productid + '&frommodule=' + popupobj.module;
    if (ld(rowobj).find(" [detailcolumnname=wareid]").length > 0)
        var wareid = ld(rowobj).find(" [detailcolumnname=wareid]").val();
    else
        var wareid = 0;
    href_url += "&wareid=" + wareid;

    ldAjax(href_url,'',function (data) {
        var popupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth600px", "Products", "", "", "", "");
        popupobj.createScrollDiv();
        popupobj.rowid = rowid;
        popupobj.show(data.result.content);
        popupobj.setScrollDivMaxHeight();
        popupobj.center();
    });


}
//上海益弹  选择“批号”赋值（批号、数量、仓库）
fun_selectproduct.prototype.setbatchtextYitan = function (batchtext, quantity, wareid, warehousename) {
    var lastpopupobj = CrmPopup.getPopupObj("lastprev");
    var popupobj = CrmPopup.getPopupObj("last");
    if (lastpopupobj.module == 'OutboundOrder') {
        lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['sf3080'] = batchtext;

        //BUG20240820-07 ls 240820 需求变更：选择某批号，不要带出该批号的库存数量，数量可编辑。
        // lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['quantity'] = quantity;
        lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['wareid'] = warehousename;
        lastpopupobj.detaildatavalue_arr[popupobj.rowid - 1]['wareid_rawvalue'] = wareid;


        // var tableobj = lastpopupobj.getDetailTableObj();
        // var rowobj = ld(tableobj).find("tr[rowindex=" + popupobj.rowid + "]");
        //或者
        // ld(rowobj).find(" [name=quantity]").val(quantity);
        // ld(rowobj).find(" [name=wareid]").val(wareid);
        // ld(rowobj).find(" [name=cmb_span_optiontext_wareid]").val(warehousename);

        // lastpopupobj.fieldformulaobj.changedatabyColumnname("quantity", popupobj.rowid);//调用字段公式
    }
    popupobj.CancelEvent();

}

fun_selectproduct.setbatchtextmulti = function (batchtext, quantity, rowindex) {
    //出库单选择批次
    var lastpopupobj = CrmPopup.getPopupObj("lastprev");//编辑或新增界面
    var popupobj = CrmPopup.getPopupObj("last");
    var tableobj = lastpopupobj.getDetailTableObj();
    lastpopupobj.selectproductobj.batchselect = true;
    //编辑或新增界面
    //edit:can 2020-12-30 43993: （https://61mis.com/kfbcrm [^]）合同订单（SO176）查看详情界面，相关信息关联创建出库单，选择批次保存后，提示“仓库不能为空”无法保存
    var lastprevrowobj = ld(tableobj).find("tr[rowindex=" + lastpopupobj.rowid + "]");
    var rowobj = ld("#" + popupobj.divid + ' tr[rowindex=' + rowindex + ']');

    //ld("#batchtext"+popupobj.rowid).val(batchtext);
    ld(lastprevrowobj).find(' [name="batchtext"]:first').val(batchtext);
    //ld("#quantity"+popupobj.rowid).val(quantity);
    //chj 2022/6/20 选择批次，批次数量自动覆盖产品数量
    if (ld("#" + popupobj.divid + " [name=select_batch_qty]").is(':checked') === true) {
        ld(lastprevrowobj).find(' [name="quantity"]:first').val(quantity);
    }

    if (lastpopupobj.module == 'OutboundOrder') {
        ld(lastprevrowobj).find(" [name=wareid]").val(ld(rowobj).find("[name=row_wareid]").val());

        //仓库名称

        ld(lastprevrowobj).find(" [name=cmb_span_optiontext_wareid]").val(ld(rowobj).find("[name=row_warehousename]").val());

    }
    //不需要考虑价格策略，价格策略有合同（服务，销售），报价单
    lastpopupobj.fieldformulaobj.changedatabyColumnname("quantity", popupobj.rowid);//调用字段公式
    popupobj.CancelEvent();
    lastpopupobj.selectproductobj.batchselect = false;

    //ls 2022-04-08 【ID1002717】入库单选择批次时带出入库单时所选批次的产品类别采购员等（选择批次时）
    lastpopupobj.RelatedProductToolFieldtriggcols = [];
    getRelatedProductToolFieldPriceCallBack(lastpopupobj, lastpopupobj.rowid);

}
//选择批次，批次数量自动覆盖产品数量
fun_selectproduct.batchqty_settings = function (jqueryobj) {
    var popupobj = CrmPopup.getPopupObj("last");
    var select_batch_qty = 'yes';
    if (ld("#" + popupobj.divid + " [name=select_batch_qty]").is(':checked') === false) {
        select_batch_qty = 'no';
    }
    var prevpopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或编辑的弹出层
    var href_url = 'index.php?module=Products&action=ProductsAjax&file=getbatchlist&setbatchqtysettings=yes&frommodule=' + prevpopupobj.module + "&select_batch_qty=" + select_batch_qty;
    ldAjaxNoProgress(href_url, "", function (data) {
        if (data.code == 1) {

        }
    });
}
//选择批次
fun_selectproduct.selectbatchtext = function (jqueryobj) {
    // jqueryobj:点击的按钮
    var that = this;
    var rowid = 0;
    var parentnode = ld(jqueryobj).parent();
    this.popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或编辑的弹出层
    parentnode = this.popupobj.getTrObjByChild(jqueryobj);
    /*while(ld(parentnode).prop("tagName")!=="TR")
   {

        parentnode=ld(parentnode).parent();

   }*/

    this.rowid = ld(parentnode).attr("rowindex");
    //edit:can 2020-12-30 43993: （https://61mis.com/kfbcrm [^]）合同订单（SO176）查看详情界面，相关信息关联创建出库单，选择批次保存后，提示“仓库不能为空”无法保存
    this.popupobj.rowid = this.rowid;

    var tableobj = this.popupobj.getDetailTableObj();
    var trobjs = this.popupobj.getTrObjsByDelType("no");
    var rowobj = parentnode;//ld(tableobj).find("tr[rowindex="+this.rowid+"]");
    this.getUrl = function () {

        var productid = ld(rowobj).find(" [name=hdnProductId]").val();
        var href_url = 'index.php?module=Products&action=ProductsAjax&file=getbatchlist&productid=' + productid + '&frommodule=' + that.popupobj.module;
        href_url += '&duplicateviewwidth='+ (that.popupobj.module == 'OutboundOrder' ? 868 : 600);
        if (that.popupobj.module == 'WareHouseTransfer') {
            //库间调拨
            var wareid = ld("#" + this.popupobj.divid).find(" [name=outwarehouse]").val();
        } else if (that.popupobj.module == 'Stock') {
            var wareid = ld("#" + this.popupobj.divid).find(" [name=wareid]").val();//ld("#wareid").val();
        } else {
            //edit:can 2020-12-30 43994: （https://61mis.com/kfbcrm [^]）合同订单（SO177）查看详情界面，相关信息关联创建“销售退货单”界面，选择批次时，弹出层中显示没有数据
            if (ld(rowobj).find(" [detailcolumnname=wareid]").length > 0)
                var wareid = ld(rowobj).find(" [detailcolumnname=wareid]").val();//ld("#wareid").val();
            else
                var wareid = 0;
        }


        href_url += "&wareid=" + wareid;
        return href_url;
    }
    //选择批次列表
    this.loadList = function () {

        var href_url = that.getUrl();
        ldAjaxNoProgresssync(href_url,'',function (ajaxdata) {
            that.showlist(ajaxdata);
            that.setEvent();

        });

    }

    this.showlist = function (data) {
        if (data.result.checkbox == 'yes') {

            var popupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth800px", data.result.frommodule, "", "", "", "");

        } else
            var popupobj = CrmPopup.load(data.result.title, "", "", "LdPopWidth600px", data.result.frommodule, "", "", "", "");
        popupobj.createScrollDiv();
        popupobj.rowid = that.rowid;
        popupobj.show(data.result.content);
        popupobj.pop_type = 'selectBatchPopup';
        popupobj.setScrollDivMaxHeight();
        popupobj.center();

        that.setResizeEvent(popupobj);

        if (data.result.checkbox == 'yes') {
            ld("#" + popupobj.divid + " [name=findnow]").unbind("click").bind("click", function () {
                //立即查询
                var tmpobj = new fun_selectproduct.selectbatchtext(jqueryobj);
                tmpobj.first = 'no';
                tmpobj.getUrl = function () {
                    //重载父类
                    var lastprevpopupobj = CrmPopup.getPopupObj('lastprev');
                    var lastpopupobj = CrmPopup.getPopupObj('last');//选择批次的弹出层界面

                    var productid = ld(rowobj).find(" [name=hdnProductId]").val();
                    var href_url = 'index.php?module=Products&action=ProductsAjax&file=getbatchlist&productid=' + productid + '&frommodule=' + lastprevpopupobj.module;
                    href_url += '&duplicateviewwidth='+ (lastpopupobj.module == 'OutboundOrder' ? 868 : 600);

                    wareid = ld("#" + lastpopupobj.divid + " [name=warehouse]").val();
                    href_url += "&wareid=" + wareid;
                    //zkt 0049861: https://www.51mis.com/hy/zhonghong [^] 海南爱恩 库存管理》新建出库单》产品名称选择“地址”，“地址详情”字段（由“批次”改的）查找功能无效
                    href_url += "&searchbatchtext=" + encodeURIComponent(ld.trim(ld("#" + lastpopupobj.divid).find(" [name=batchtext]").val()));
                    href_url += "&query=yes";
                    return href_url;
                }
                tmpobj.showlist = function (data) {
                    //重载父类(重新加载选择批次的内容)
                    var popupobj = CrmPopup.getPopupObj('last');

                    ld("#" + popupobj.divid + " [name=content]").html(data.result.content);
                    that.setResizeEvent(popupobj);


                }
                tmpobj.loadList();
            })
        }
    }

    this.setResizeEvent = function (popupobj){
        var listresizeobj=new List_ResizeTable(popupobj);
        listresizeobj.setPopupResizeTable_Init(popupobj.module);
        popupobj.listresizeobj = listresizeobj;
    }

    //选择批次弹出层事件
    this.setEvent = function () {

        //var lastprevpopupobj= CrmPopup.getlastPopupObjByPageType("create_edit_modulepage")////新增或编辑的弹出层
        var lastprevpopupobj = CrmPopup.getPopupObj('lastprev');//新增或编辑的弹出层
        var popupobj = CrmPopup.getPopupObj('last');
        ld("#" + popupobj.divid + " [name=chkall]").unbind("click").bind("click", function () {
            //chekbox按钮
            //全选
            var selected = ld(this).prop("checked");
            var chkobjs = ld("#" + popupobj.divid + " [name=chkrow]");
            ld.each(chkobjs, function () {

                ld(this).prop("checked", selected);
            })

        });
        ld("#" + popupobj.divid + " [name=btnok]").unbind("click").bind("click", function () {
            //确定按钮(选择批次)
            var popupobj = CrmPopup.getPopupObj('last');
            var startrowindex = that.rowid;
            var prevpopupobj = CrmPopup.getPopupObj('lastprev');
            var lastprevpopupobj = CrmPopup.getPopupObj('lastprev');//新增或编辑的弹出层
            var trobjs = lastprevpopupobj.getTrObjsByDelType('no');

            var startrowobj = ld(tableobj).find("tr[rowindex=" + startrowindex + "]");

            var emptyrowindex_arr = [];//获取当前号和空行
            var tmprowcnt = ld(trobjs).length  ;

            while (tmprowcnt >= 1) {
                var tmprowobj = ld(tableobj).find("tr[rowindex=" + tmprowcnt + "]");
                //标识该行没有删除且已选择产品
                if (ld(tmprowobj).attr("detaildeleted") == 'yes') {
                    tmprowcnt--;
                    continue;
                }
                if (ld(tmprowobj).find("[name=hdnProductId]").val() > 0) {

                    break;
                }

                emptyrowindex_arr.push(tmprowcnt);
                tmprowcnt--;

            }

            emptyrowindex_arr.push(that.rowid);
            var tmpemptyrowlength = emptyrowindex_arr.length;
            var tmpindex = tmpemptyrowlength - 1;

            var computerowindexs = [];
            // var trobjs_len=ld(trobjs).length;
            var oldvalue = lastprevpopupobj.selectproductobj.source_other_products;
            lastprevpopupobj.selectproductobj.batchselect = true;
            lastprevpopupobj.selectproductobj.source_other_products = 1;//038225: 出库单产品选择批次时支持多选 ：从合同订单相关信息处创建出库单，选择批次，提示不能选择源单以为的产品
            var chkobjs = ld("#" + popupobj.divid + " [name=chkrow]");//获取批次弹出层界面checkbox
            ld.each(chkobjs, function () {
                var batchtextrowindex = ld(this).attr("rowindex");
                //获取选择的checkbox所在行
                var batchtexttrobj = ld("#" + popupobj.divid + " tr[rowindex=" + batchtextrowindex + "]");

                var batchtext = ld(batchtexttrobj).find("[name=row_batchtext]").val();//获取选择行的批次号

                var quantity = ld(batchtexttrobj).find("[name=row_quantity]").val();//获取选择行数量
                var wareid = ld(batchtexttrobj).find("[name=row_wareid]").val();//获取选择行的仓库id
                var warehousename = ld(batchtexttrobj).find("[name=row_warehousename]").val();//获取选择行的仓库名称

                if (ld(this).prop("checked")) {
                    //emptyrowindex_arr:的内容值是从大到小(数组最后一个值标识最小行号)
                    var cur_rowindex = 0;
                    if (tmpindex >= 0 && emptyrowindex_arr[tmpindex] > 0) {


                        var tmp_currowindex = emptyrowindex_arr[tmpindex];
                        tmpindex--;
                        cur_rowindex = tmp_currowindex;
                        var cur_rowobj = ld(tableobj).find("tr[rowindex=" + cur_rowindex + "]");
                        setcopyrowvalue(startrowobj, cur_rowobj, lastprevpopupobj, that.rowid, cur_rowindex);
                        //BUG0078393 ls 20240105 出库单选择产品（产品编号等于：PRO89）后，批次/序列号字段选择多条批次后，产品明细中前两个批次号没有显示出来(setcopyrowvalue由于hzx更改了批次的html，导致双向绑定失败，现已注释hzx代码)
                        // lastprevpopupobj.detaildatavalue_arr[cur_rowindex - 1].databind = 'no';
                        // lastprevpopupobj.selectproductobj.setDataBind(cur_rowobj);//重新数据绑定
                    } else {


                        //拷贝行
                        //edit:can 2020-12-15 43699: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），出库单选择产品（产品A），选择批次弹出层中勾选多个批次保存后，产品分录中的批次都默认显示第一个批次（需要补丁）
                        lastprevpopupobj.selectproductobj.fnaddProductRow('yes');

                        var tmparr=[];
                        var tmplen=lastprevpopupobj.detaildatavalue_arr.length;
                        //edit:can 69541  	http://jyrc008.gnway.cc/crm ；四川嘉银；新建入库单>选着源单分录自动带出>填写批次的时候勾选多个批次>保存单据，分录会自动丢失分录（详细步骤看附件截图）
                        ld.each(lastprevpopupobj.detaildatavalue_arr[that.rowid-1],function(tmpdetailkey,tmpdetaildata){

                            lastprevpopupobj.detaildatavalue_arr[tmplen-1][tmpdetailkey]=tmpdetaildata;



                        })

                        var trobjs = lastprevpopupobj.getTrObjsByDelType('no');
                        //  lastprevpopupobj.detaildatavalue_arr[tmplen-1]['span_seq_no']=3;
                        cur_rowindex = ld(trobjs).length  ;

                    }


                    var tmpobjs = ld(rowobj).find("input");

                    var rowidlength = (that.rowid + "").length;
                    var cur_rowobj = ld(tableobj).find("tr[rowindex=" + cur_rowindex + "]");
                    ld(cur_rowobj).find("#batchtext").css("display",'')
                    ld(cur_rowobj).find(("#span_seq_no")).html(cur_rowindex);
                    //选择批次号赋值
                    lastprevpopupobj.detaildatavalue_arr[cur_rowindex - 1]['producthave_batchtext'] = 'yes';
                    lastprevpopupobj.detaildatavalue_arr[cur_rowindex - 1]['batchtext'] = batchtext;
                    //ld(cur_rowobj).find(" [name=batchtext]").val(batchtext);
                    var cur_row_quantity = ld(cur_rowobj).find(" [name=quantity]").val();

                    //chj 2022/6/20 选择批次，批次数量自动覆盖产品数量
                    if (ld("#" + popupobj.divid + " [name=select_batch_qty]").is(':checked') === true) {
                        ld(cur_rowobj).find(" [name=quantity]").val(quantity);
                    }

                    ld(cur_rowobj).find(" [name=wareid]").val(wareid);

                    //仓库名称
                    ld(cur_rowobj).find(" [name=cmb_span_optiontext_wareid]").val(warehousename);

                    //显示批次号选择框
                    ld(cur_rowobj).find(" [name=batchtext]").css("display", 'inline');
                    ld(cur_rowobj).find(" [name=searchbatchtextIcon]").css("display", 'inline');
                    ld(cur_rowobj).find(" [name=clearbatch]").css("display", 'inline');
                    computerowindexs.push(cur_rowindex);
                    //edit:duan 2022-5-31 【ID1002717】入库单选择批次时带出入库单时所选批次的产品类别采购员等（选择批次时）
                    lastprevpopupobj.RelatedProductToolFieldtriggcols = [];
                    getRelatedProductToolFieldPriceCallBack(lastprevpopupobj, cur_rowindex);
                }

            })
            lastprevpopupobj.selectproductobj.batchselect = false;
            var lastprevpopupobj = CrmPopup.getPopupObj('lastprev');//新增或编辑的弹出层
            var lastcreatepagepopupobj = CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);//新增或编辑的弹出层
            if(lastprevpopupobj.divid == lastprevpopupobj.divid){
                lastprevpopupobj.selectproductobj.fnAddProductTdBtn();
                //editor:gyq_161 reason:带分录模块弹出层   2019/11/14 15:24

                lastprevpopupobj.selectproductobj.source_other_products = oldvalue;
                popupobj.CancelEvent();


                ld.each(computerowindexs, function (index, tmprowindex) {

                    if (tmprowindex > 0) {
                        //edit:can 54190  	【演示账套】V8.4.6.6.6（https://www.51mis.com/hy/CESHI10/）从合同订单中创建出库单，出库单产品分录中自动带入合同
                        lastprevpopupobj.fieldformulaobj.setEvent(tmprowindex)
                        lastprevpopupobj.fieldformulaobj.changedatabyColumnname("quantity", tmprowindex);//调用字段公式
                    }
                })
                lastprevpopupobj.fieldformulaobj.CountsubTotal();
            }



        });

    }


}
fun_selectproduct.prototype.getMethod = function () {


    this.wareid = 0; //仓库id

    this.currencyid = 1; //币种id

    this.rowcnt = ""; //当前总行数

    this.accvenid = 0; //单据的客户、联系人ID

    this.recordid = 0; //当前单据的ID

    if (this.wareobj.val() != undefined) {
        this.wareid = ld(this.wareobj).val();
    }


    this.rowcnt =ld(this.rowcntobj).val();


    if (ld(this.inventory_currencyobj).val() != undefined) {
        this.currencyid = ld(this.inventory_currencyobj).val();
    }

    if ( ld(this.vendor_idobj).val() != undefined) {
        this.accvenid =ld(this.vendor_idobj).val();
    }

    if ( ld(this.accountidobj).val() != undefined) {
        this.accvenid = ld(this.accountidobj).val();;
    }


    this.recordid =this.popupobj.record;

}

//选择产品（按钮）列表
fun_selectproduct.getProductPopup = function (rowId) {
    var event = event || window.event;
    var srcElement = event.srcElement || event.target;

    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = popupobj.getTrObjByChild(ld(srcElement));//考虑拖动换行 ，那么rowId变量要重新赋值
    rowId = ld(rowobj).attr("rowindex") || ld(rowobj).attr("row-index") || rowId;
    var tableobj = popupobj.getDetailTableObj();
    // var rowobj=ld(tableobj).find("tr[rowindex="+rowId+"]");

    this.chooseProductRowindex = rowId;//类属性
    popupobj.selectproductobj.chooseProductRowindex = rowId;//对象属性 产品套餐

    popupobj.selectproductobj.popup_selectsource = false;
    //zkt 20240703 BUG20240702-08  标准产品设置了共享规则（倍络得只能看物料归属是倍络得，达立可以看物料归属是倍络得和达立的），数据范围调整了个人，标准产品模块查不到但是在销售订单还是能选到权限外的产品：linjingqi是倍络得的不应该看到1开头的达立的产品 
	var productNameUrl = '&selectrelationfrom=entry&fieldname=productname&searchfieldname=productname&searchvalue=';
    //出库或入库时必须严格参照源单
    if (!popupobj.selectproductobj.sourceOtherProducts()) return false;
    popupobj.selectproductobj.getMethod();
    //产品名称
    if (ld(rowobj).find(" [name=hdnProductId]").val() != undefined && ld(rowobj).find(" [name=hdnProductId]").val() != ''
        && ld(rowobj).find(" [name=hdnProductId]").val() != 0) {
        //edit:can 2020-10-26 43004: （8.2.7PHP7+Redis安装包）报价单查看详情界面，相关信息->报价变更单列表，点击“新建->更换”，选择更换后产品弹出层界面，没有显示产品管理数据
        var productName = ld(rowobj).find(" [name=productname]").val();//
        productNameUrl = productNameUrl + encodeURIComponent(productName);
    }

    //海格未选择报价单类型时不允许选择产品
    if (account_version == 'haige' && popupobj.module == 'Quotes') {
        var haigequotetypeobj = ld('#' + popupobj.divid + ' [name=cmb_span_optiontext_quotetype]');
        if (haigequotetypeobj != undefined && ld(haigequotetypeobj).val() == '') {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['SELECTPRODUCTAFTERSELECTQUOTETYPE']);
            return;
        } else {
            //编辑时报价单类型不可编辑,无cmb_span_optiontext_quotetype
            haigequotetypeobj = ld('#' + popupobj.divid + ' [name=quotetype]');
            if (haigequotetypeobj != undefined && ld(haigequotetypeobj).val() == '') {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "", arrJsPopLabel['SELECTPRODUCTAFTERSELECTQUOTETYPE']);
                return;
            }
        }
    }

    //@edit:liushuai,2020-07-20,reason:义文机电，线索/项目管理模块，2.分录选择“物料名称”时，如果没有选择客户，提示“请先选择客户”；如果选择有客户则只能选择该客户的物料
    //account_version 全局变量
    if (account_version == 'yiwen' && popupobj.selectproductobj.cur_module == 'Potentials') {
        if (CrmPopup.findHtmlobj(popupobj.divid, 'account_id').val() > 0) { //0：没有选择客户
            var account_id = CrmPopup.findHtmlobj(popupobj.divid, 'account_id').val();// == ld("#"+popupobj.divid+" [name=account_id]").val()

        } else {
            var confirm_str = arrJsPopLabel['PLEASESELECTACCOUNT'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return;
        }
    }
    //@edit:liushuai,2020-09-04,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格
    getRelatedProductToolFieldPrice(popupobj, rowId);

    ////金融/基金行业只允许选择一个产品
    var selectenable = "&select=enable";
    if (!empty(popupobj.selectproductobj.trade) && (popupobj.selectproductobj.trade == 'finance' || popupobj.selectproductobj.trade == 'jijin')) {
        selectenable = "";
    }
    if (popupobj.fieldformulaobj.restobj != undefined && popupobj.fieldformulaobj.restobj.hasOwnProperty('trade')) {
        if (popupobj.fieldformulaobj.restobj['trade'] == 'finance' || popupobj.fieldformulaobj.restobj['trade'] == 'jijin')//金融/基金行业只允许选择一个产品
        {
            selectenable = "";
        }
    }
    var popuptype = 'inventory_prod';
    var wintype = 'productWin';
    if ('Productbom' == popupobj.selectproductobj.cur_module) {
        wintype = 'bomproductWin';
    }
    if ('OutboundOrder' == popupobj.selectproductobj.cur_module) {
        popupobj.selectproductobj.wareid = ld(rowobj).find(" [name=wareid]").val();
    }

    var surl = "module=Products&action=Popup&popup=yes&page_popup=yes&html=Popup_picker" + selectenable + "&form=HelpDeskEditView&popuptype=" + popuptype + "&curr_row=" + rowId + "" + productNameUrl + "&return_module=" + popupobj.selectproductobj.cur_module + "&currencyid=" + popupobj.selectproductobj.currencyid + "&frommodule=" + popupobj.selectproductobj.cur_module + "&wareid=" + popupobj.selectproductobj.wareid;
    if (this.accvenid > 0)
        surl += "&relmod_id=" + this.accvenid;
    if (account_version == 'haige' && popupobj.selectproductobj.cur_module == 'Quotes') {
        var trobjs = popupobj.getTrObjsByDelType("no");
        var productid_str = "";
        var tmpproductid = 0;
        var tmprowid = 0;

        ld.each(trobjs, function (tmprowindex, tmprowobj) {
            tmprowid = parseInt(tmprowindex) + 1;
            tmprowobj = ld(tableobj).find("tr[rowindex=" + tmprowid + "]");
            tmpproductid = ld(tmprowobj).find("[detailcolumnname=hdnProductId]").val();
            if (tmpproductid > 0 && tmprowid != rowId) {
                if (productid_str == "") {
                    productid_str += tmpproductid;
                } else {
                    productid_str += ',' + tmpproductid;
                }
            }
        });
        if (productid_str != "") {
            surl += "&productid_str=" + productid_str;
        }
    }
    var requestvalues = "";
    var sensitiverequestfield = "";
    var requestvaluearr = getPageValueByCrmPopupFields(popupobj);
    requestvalues = requestvaluearr['requestvalue'];
    sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
    ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {
        if (tmpfieldinfo.displaytype == 3 && tmpfieldinfo.bigtype == 'reference' && tmpfieldinfo.columnname == 'pricebooksid') {
            //海格
            surl += "&pricebooksid=" + ld("#" + popupobj.divid + " [name=pricebooksid]").val();
            return false;
        }
    })
    surl += "&requestvalues=" + encodeURIComponent(requestvalues);
    surl += "&sensitiverequestfield=" + encodeURIComponent(sensitiverequestfield);

    //zkt 20240625
    var detailrequestrowvalues = getDetailRowValuesarr(popupobj,rowobj);
    surl+="&detailrequestrowvalues="+JSON.stringify(detailrequestrowvalues);
    CrmPopupWindow( popupobj.selectproductobj.cur_module,surl, 'Products');
}

//选择源单和选择产品
fun_selectproduct.selectMoreModuleForProduct = function (selectmodule) {
    if (this.debounceTimer) { //BUG0066750 xxy 2023-8-24 合同订单模块，新建界面，单据分录，添加产品，双击产品进行添加，单据分录出现两行空白
        clearTimeout(this.debounceTimer); //用防抖处理点击过快，给一个200毫秒延迟
    }
    this.debounceTimer = setTimeout(() => {
        //选择单据的弹出层
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        var popupobj = CrmPopup.getPopupObj('last');
        var divid = popupobj.divid;
        //选择源单时分录对象为产品
        if (prevpopupobj.module == 'WorkSheet') {
            var divname = "";
            if (selectmodule != 'Products') {
                prevpopupobj.js_detailtablename = 'newproTab';
                divname = "newproductDiv";
            } else {
                prevpopupobj.js_detailtablename = 'proTab';
                divname = "productDiv";
                ld("#" + prevpopupobj.divid + " [name=LastContent]").show();
            }
            ld("#" + prevpopupobj.divid + " [name=" + divname + "]").show();
        }
        prevpopupobj.selectmodule = selectmodule;
        prevpopupobj.selectproductobj.getMethod();
        //edit:can 20220107 0049551: （https://81mis.com/kfbcrm [^]）合同订单新建界面，选择产品弹出层中搜索“按摩”关键字显示多条记录，不勾选单据点击确定，提示信息中点击确定关闭弹窗，再次点击【确定】按钮时点不动
        CrmPopup.getPopupObj('last').selectproductbtn = 0;
        //console.log(document.selectall);//js DOM
        var selectalldom = ld('#' + divid).find('form[name="selectall"]')[0];//jq对象转js DOM
        //console.log(selectalldom);

        if (selectalldom != undefined) {
            var idstring = '';
            var y = 0;
            //35795: （1.6）出库单新增、编辑界面>选择入库单为源单弹出层>选择一条源单，点击选择源单弹出层>在选择一条跟刚才不是一个供应商的源单>结果：没有弹出提示“您选择的记录包含多个供应商的单据，只允许选择同一个供应商的单据！”（需要补丁）
            var selectentitypeids = prevpopupobj.selectproductobj.getvaluebycolumnname("entitytypeid");//已经选择过的原单
            var x = selectalldom.selected_id.length;
            var sourcemodule_record_string = '';

            if (CrmPopup.getPopupObj('last').selectproductbtn != undefined && CrmPopup.getPopupObj('last').selectproductbtn == 1) {//edit:can 2021020444570: （61mis.com/kfbcrm）销售管理-合同订单-新建；产品分录中，选择2个以上产品时，多次点击确定按钮，除第一个产品，其他产品会在分录中多次录入
                return false;
            }
            CrmPopup.getPopupObj('last').selectproductbtn = 1;
            //再次选择时
            if (x == undefined) {
                cnt = 2;
                idstring = selectalldom.selected_id.value;
                prevpopupobj.selectproductobj.sourcemodule_reocrd = selectalldom.selected_id.getAttribute('billinfo');
                sourcemodule_record_string = prevpopupobj.selectproductobj.sourcemodule_reocrd;
                y = 1;
            } else {
                /*for(i = 0; i < x ; i++) {
                    //获取选中的产品id
                    if(selectalldom.selected_id[i].checked) {
                        idstring = selectalldom.selected_id[i].value+";"+idstring;

                        prevpopupobj.selectproductobj.sourcemodule_reocrd = selectalldom.selected_id[i].getAttribute('billinfo');
                        sourcemodule_record_string = prevpopupobj.selectproductobj.sourcemodule_reocrd+";"+sourcemodule_record_string;
                        y = y + 1;
                    }
                }*/
                cnt = 1;
            }
        }
        if (selectmodule == 'Products') {
            y = popupobj.chooseproductid_arr.length;
        } else {
            //选择原单
            y = popupobj.chooseSourceInfo_arr.length;
        }

        if (y != 0) {


            if (selectmodule == 'Products') {
                // var tmp_chooseproductid_arr = popupobj.chooseproductid_arr.splice(0,10);
                // prevpopupobj.selectproductobj.getProductInfo(this.chooseProductRowindex,tmp_chooseproductid_arr.join(";"));
                //
                // ld("#"+prevpopupobj.divid+" [name="+divname+"]").on('scroll', function() {
                //     if (this.checkSlider()) {
                //         var tmp_chooseproductid_arr = popupobj.chooseproductid_arr.splice(0,10);
                //         prevpopupobj.selectproductobj.getProductInfo(this.chooseProductRowindex,tmp_chooseproductid_arr.join(";"));
                //     }
                // });
                prevpopupobj.selectproductobj.getProductInfo(this.chooseProductRowindex, popupobj.chooseproductid_arr.join(";"));
                prevpopupobj.selectproductobj.popup_selectsource = false;
            }
            else {


                prevpopupobj.selectproductobj.popup_selectsource = true;
                var idstring = '';
                var line_item_ids = new Array();
                var detailid_arr = [];
                var module_record = [];
                ld.each(popupobj.chooseSourceInfo_arr, function (tmpindex, tmpinfo) {
                    //idstring= tmpinfo.detailid+";"+idstring;
                    var tmp_detailid = tmpinfo.detailid;
                    //ljj 20240717 XUQIU20240321-01 当源单列表的分录字段全部隐藏之后，直接以一行显示这个单据，并且带出的时候按要求带出源单产品
                    if (tmp_detailid.indexOf('#') > -1){//选择源单带出分录但列表无分录字段的情况
                        tmp_detailid = tmp_detailid.split('#').join(';')
                    }
                    detailid_arr.push(tmp_detailid);

                    var lineitemids = '';

                    if(tmpinfo.detailid.indexOf('#') > -1){//选择源单带出分录但列表无分录字段的情况
                        lineitemids = tmpinfo.detailid.split('#').join(',')
                    }else {
                        var lineitemids_arr = tmpinfo.detailid.split('_');
                        lineitemids = lineitemids_arr[0]
                    }
                    line_item_ids.push(lineitemids);
                    if (ld.inArray(tmpinfo.record, module_record) == -1) {
                        module_record.push(tmpinfo.record);
                    }
                })
                prevpopupobj.selectproductobj.sourcemodule_reocrd = module_record.join(",");
                idstring = detailid_arr.join(";");

                /**
                 * 判断选择源单客户是否为同一客户
                 * 判断选择源单供应商是否同一供应商
                 * */

                var idstr = line_item_ids.join(',');
                var specialurl = '';
                if (prevpopupobj.selectproductobj.cur_module == 'QuotesChange' || prevpopupobj.selectproductobj.cur_module == 'BudgetChange') {
                    var tmpchange_typeobj = ld("#"+prevpopupobj.divid+' [name=change_type]');
                    if (ld(tmpchange_typeobj).val() != undefined
                        && ld(tmpchange_typeobj).val() == 'replace') {
                        specialurl = '&change_type=replace';
                    }
                }

                if (account_version == 'langjie' && selectmodule == 'Commission') {
                    //edit:can 2020803  郎捷特殊需求
                    idstring = "";
                    var urlstring = 'module=Commission&action=CommissionAjax&file=getCommissionDetailLangjie&ReportHeader=dheader&getProductinfo=yes';
                    var checkedobj = ld("#" + popupobj.divid + " [name=selected_id]:checked");

                    ld.each(checkedobj, function () {
                        //

                        idstring = ld(this).attr("billinfo") + ";" + idstring;

                        prevpopupobj.selectproductobj.sourcemodule_reocrd = ld(this).attr("billinfo");
                        //sourcemodule_record_string = prevpopupobj.selectproductobj.sourcemodule_reocrd+";"+sourcemodule_record_string;
                        y = y + 1;

                    })

                    urlstring += '&selectbillid=' + idstring;

                } else
                    var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getProductinfo=yes';

                urlstring += '&wareid=' + prevpopupobj.selectproductobj.wareid + '&accvenid='
                    + prevpopupobj.selectproductobj.accvenid + '&currencyid=' + prevpopupobj.selectproductobj.currencyid +
                    '&rowid=' + prevpopupobj.selectproductobj.rowcnt + '&frommodule=' + prevpopupobj.selectproductobj.cur_module +
                    '&productid=' + idstring + '&popup_selectsource=' + prevpopupobj.selectproductobj.popup_selectsource + '&cur_record=' + prevpopupobj.selectproductobj.recordid;
                urlstring += '&selectentitytypeids=' + selectentitypeids;
                if (prevpopupobj.sourcemodule_arr != undefined) {
                    ld.each(prevpopupobj.sourcemodule_arr, function (tmpindex, sourcemoduleinfo) {
                        if (sourcemoduleinfo.entitytype == selectmodule) {
                            urlstring += '&withproductdetail=' + sourcemoduleinfo.withdetail;
                            return false;
                        }
                    })
                }
                if (!empty(specialurl)) {
                    urlstring += specialurl;
                }
                urlstring += '&source_idstr=' + idstr + '&agian=yes&selectmodule=' + selectmodule;
                if (account_version == 'langjie' && selectmodule == 'Commission') {
                    //郎捷特殊控制
                    ldAjax("index.php?" + urlstring, {}, function (ajaxdata) {
                        setLangJieDetailTableValue(ajaxdata);


                        DelProgressObjs();
                    })
                } else
                    //edit:can 随便传值 ，选择原单在getValue方法中有判断
                    prevpopupobj.selectproductobj.getValue(1, urlstring);

                if (popupobj.type ==  'selectsearchdetail') {
                    // ljj 20231117 BUG0075667 销售订单选择报价单源单点击确定后，立刻移动端到订单上，弹窗消失但“双击选择或者反选整单”浮显没有消失
                    if (ld("#popupdoubleclick")){
                        ld("#popupdoubleclick").remove();
                    }
                    popupobj.CancelEvent();
                }
                //prevpopupobj.selectproductobj.popup_selectsource = false;//zkt 选择之后参数应改为false
            }
            return true;
        } else {
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return false;
        }
    }, 200);
}
fun_selectproduct.prototype.CopyDetailTableRow = function (copyrowindex, afterrowindex) {
    //copyrowindex:被复制的行 ,表示的rowindex
    //afterrowindex:指定的行后面,表示的rowindex

    var tableobj = this.popupobj.getDetailTableObj();
    //edit:can 2020-12-15 43699: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），出库单选择产品（产品A），选择批次弹出层中勾选多个批次保存后，产品分录中的批次都默认显示第一个批次（需要补丁）

    var rowobj = ld(tableobj).find("tr[rowindex=" + afterrowindex + "]").after(ld(tableobj).find("tr[rowindex=" + copyrowindex + "]").clone());
    //todo：判断是否为最后一行，如果为最后一行则不需要重新设置序号
    return ld(tableobj).find("tr[detaildeleted=no]:last");

}
fun_selectproduct.prototype.getvaluebycolumnname = function (columnname) {
    var tmpstr = '';
    var that = this;
    this.rowcnt = ld("#"+that.cur_divid +' [name=rowcnt]').val();
    var tableobj = this.popupobj.getDetailTableObj();
    var trobjs = this.popupobj.getTrObjsByDelType('no');

    ld.each(trobjs, function () {


        if (ld(this).find(" [name=" + columnname + "]").length <= 0) {
            return '';
        }

        tmpstr += ld(this).find(" [name=" + columnname + "]").val() + ",";
    })

    return tmpstr;
}
fun_selectproduct.prototype.setWorkSheetValue=function(prod_array){
    var  select_rowid = 0;
    var that=this;
    var  tableobj=ld("#" + this.popupobj.divid + " [name=newproTab]");
    var rowcnt=ld(tableobj).find("tr[detaildeleted=no]").length;

    var firstObj = prod_array[Object.keys(prod_array)[0]]; // 取得第一个对象
    that.popupobj.selectproductobj.worksheettablecolumn_arr = Object.keys(firstObj); // 取得该对象的所有键
    that.popupobj.selectproductobj.worksheet_sourcevalue_arr = [];
    var selectlistval_arr=[];;
    var selectlistval_label_arr=[];
    if(ld("#"+this.popupobj.divid+" [name=selectlistval_label]").val()!='')
    {
        selectlistval_label_arr=ld("#"+this.popupobj.divid+" [name=selectlistval_label]").val().split(",");
        selectlistval_arr=ld(that.selectlistvalobj).val().split(",")
    }
    var emptyrow_arr=[];
    ld.each(ld(tableobj).find("tr[detaildeleted=no]"),function(){
        if(ld(this).find("#hdnProductId").val()==''||ld(this).find("#hdnProductId").val()==0)
        {
            emptyrow_arr.push(ld(this).attr("rowindex"));

        }

    })
    var index = 0;
    for (productid in prod_array) {
        select_rowid=0
        var intproductid = parseInt(productid);
        if(emptyrow_arr.length>0)
        {
            select_rowid=emptyrow_arr[0];
            emptyrow_arr.splice(0,1);

        }
        else{

            select_rowid = that.fnaddProductRow();
        }
        var rowobj=ld(tableobj).find("tr[rowindex="+select_rowid+"]");
        var tmp_value = '';
        ld.each(that.popupobj.selectproductobj.worksheettablecolumn_arr,function(tmpindex,tmpcolumnname){
            try {
                tmp_value = decodeURIComponent(prod_array[productid][tmpcolumnname]);//BUG0076748 ls 20231206 带%的文本如果没有经过encode就decode的话程序会停止且控制台不会报错
            } catch (e) {
                tmp_value = prod_array[productid][tmpcolumnname];
            }
            ld(rowobj).find("#"+tmpcolumnname).val(tmp_value);
            if(tmpcolumnname!='productname')
                ld(rowobj).find("#span_"+tmpcolumnname).html(tmp_value)
        })
        ld(rowobj).find("#span_entitytypeid").html(prod_array[productid]['entitytype'])
        ld(rowobj).find("#span_entitytype").html(prod_array[productid]['entitytype_transmodule'])

        that.popupobj.selectproductobj.worksheet_sourcevalue_arr[index]= {
            'lineitem_id' : prod_array[productid]['lineitem_id'],
            'entitytype' : prod_array[productid]['entitytype_module'],
            'entitytypeid' : prod_array[productid]['selectSourceModuleid'],
        };

        ld(rowobj).find("#entitytype").val(prod_array[productid]['entitytype_module'])
        ld(rowobj).find("#entitytypeid").val(prod_array[productid]['selectSourceModuleid'])
        if(!selectlistval_arr.includes(prod_array[productid]['selectSourceModuleid']))
        {
            selectlistval_arr.push(prod_array[productid]['selectSourceModuleid'])
            selectlistval_label_arr.push(prod_array[productid]['entitytype'])
        }
        ld(rowobj).find(" [detailcolumnname=lineitem_id]").val(prod_array[productid]['lineitem_id'])
        ld(rowobj).find("#hdnProductId").val(prod_array[productid]['hdnProductId'])
        rowcnt++
        index++;

        // that.setValue(prod_array[productid]['hdnProductId'], prod_array[productid], select_rowid);
    }
    //    console.log(selectlistval_label_arr)
    ld(that.selectlistvalobj).val(ld.trim( selectlistval_arr.join(",")))
    ld("#"+this.popupobj.divid+" [name=selectlistval_label]").val(ld.trim(selectlistval_label_arr.join(","),','));

    //get
}
fun_selectproduct.prototype.getValue = function (rowid, urlstring) {
    var prevpopupobj = this.popupobj;//新增或编辑弹出层界面
    var that = this;

    var tableobj = prevpopupobj.getDetailTableObj();//获取分录所在的table对象
    ld('#rptContentLoading').show();
    var trobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");//赋值的行对象
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

                if (results.indexOf("$$##error###$$$") >= 0) {
                    var result = results.split("$$##error###$$$");
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", result[1])
                    ld('#rptContentLoading').hide();
                    return false
                }

                var prod_array = that.prod_array = eval('(' + results + ')') ? eval('(' + results + ')') : JSON.parse(results);

                if(prod_array.code == -1)
                    MessagePopup.TipOne_warning(prod_array.msg);

                if(prevpopupobj.module=='WorkSheet'&&that.popup_selectsource)
                {
                    prevpopupobj.selectproductobj.setWorkSheetValue(prod_array);
                    getJsScript('include/js/relatedfield.js', function () {
                        getRelatedFieldData('', prevpopupobj.selectproductobj.sourcemodule_reocrd, '', '', prevpopupobj.selectproductobj.cur_module, 'popupselectfield');
                    });
                    ld('#rptContentLoading').hide();
                    return false;
                }

                var popupobj = CrmPopup.getPopupObj("last");
                // 价格政策产品
                if(prevpopupobj.module === 'PricePolicy')
                {
                    popupobj.CancelEvent();
                    ld('#rptContentLoading').hide();
                    PricePolicyEdit.getInstance(prevpopupobj).addProducts(rowid, prod_array)
                    return false;
                }

                var rowcnt =prevpopupobj.detaildatavalue_arr.length;	//总行
                var rec_rowcnt = 0;	//可用行数
                var k = 1;
                var select_rowid = 0;	//赋值行



                if (that.popup_selectsource == false) {
                    var tmprowid = popupobj.curr_row;// //ID1000410】单据产品明细项， 通过点击“确定”按钮选择产品
                    that.clearProductInfo_Row(popupobj.curr_row);//必须清空当前行，因为当前行有默认值
                }

                if (tmprowid >= 1) {
                    popupobj.CancelEvent();
                }
                var withproductdetail = 'yes';
                if (that.popup_selectsource) {
                    var entitytype_module = 'assssss';

                    for (lineitemid in prod_array) {
                        entitytype_module = prod_array[lineitemid].entitytype_module;
                        break;// false;

                    }

                    //duan 20221117 泰康特殊开发，订单（自定义表单16）选择源单活动套餐（自定义表单17）后清空原有的分录
                    if (account_version == 'taikang' && that.cur_module == 'CustomForm16' && entitytype_module == 'CustomForm17') {
                        var selectlistval = ld("#" + popupobj.divid + ' [name=selectlistval]').val();
                        var trobjs = prevpopupobj.getTrObjsByDelType("no");
                        //如果已选择源单分录则不清空
                        if (empty(selectlistval)) {
                            var tmp_index = ld(trobjs).length;
                            var tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");
                            for (; tmp_index > 0; tmp_index--) {
                                if (tmp_index == 1) {
                                    that.clearProductInfo_Row(tmp_index);
                                } else {
                                    var delrowobj = ld(tableobj).find("tr[rowindex=" + tmp_index + "]");
                                    ld(delrowobj).remove();
                                }
                            }
                            //重新获取分录行数
                            var deltrobjs = prevpopupobj.getTrObjsByDelType("yes");
                            var rowcnt = ld(trobjs).length + ld(deltrobjs).length;
                        }
                    }

                    if (prevpopupobj.sourcemodule_arr != undefined) {
                        ld.each(prevpopupobj.sourcemodule_arr, function (tmpindex, sourcemoduleinfo) {
                            if (sourcemoduleinfo.entitytype == entitytype_module) {
                                withproductdetail = sourcemoduleinfo.withdetail;
                                return false;
                            }
                        })
                    }


                    if (withproductdetail == 'no') {

                        var oldentitytype = ld(that.selectlistval_labelobj).val();
                        var oldentitytypeid = ld(that.selectlistvalobj).val();
                        if(oldentitytypeid==undefined)
                        {
                            oldentitytypeid='';
                        }
                        if(oldentitytype==undefined)
                        {
                            oldentitytype='';
                        }
                        var oldentitytypes = [];
                        var oldentitytypeid_arr = [];
                        if (oldentitytype != ''&&oldentitytype!=undefined) {
                            oldentitytypes = oldentitytype.split(',');
                            oldentitytypeid_arr = oldentitytypeid.split(',');

                        }

                        for (lineitemid in prod_array) {
                            if (ld.inArray(prod_array[lineitemid]['selectSourceModuleid'], oldentitytypeid_arr) < 0) {
                                oldentitytypeid_arr.push(prod_array[lineitemid]['selectSourceModuleid']);
                                oldentitytypes.push(prod_array[lineitemid]['entitytype']);

                            }
                        }



                        ld(that.selectlistval_labelobj).val(oldentitytypes.join(','));
                        ld(that.selectlistvalobj).val(oldentitytypeid_arr.join(','));
                        if (prevpopupobj.selectproductobj.popup_selectsource == true) {
                            getJsScript('include/js/relatedfield.js', function () {
                                getRelatedFieldData('', prevpopupobj.selectproductobj.sourcemodule_reocrd, '', '', prevpopupobj.selectproductobj.cur_module, 'popupselectfield');
                            });
                            ld(that.selectlistvalobj).change();
                        }
                        ld('#rptContentLoading').hide();
                        //选择源单不带出明细
                        return false;
                    }
                }
                prevpopupobj.selectproductobj.AfterchooseSourceHide();////选择源单后隐藏按钮（严格控制选择源单）
                if (ld(trobj).length > 0) {
                    //var hidden_rowid_obj = ld(trobj).find("#hidden_rowid");
                    var hdnProductIdobj = ld(trobj).find("#hdnProductId");
                }

                var emptyrows = [];
                var startemptyrowindex = 0;
                var trlen = prevpopupobj.detaildatavalue_arr.length;

                tableobj = prevpopupobj.getDetailTableObj();//获取分录所在的table对象,不能删除

                for (var tmpi =0; tmpi <=trlen-1; tmpi++) {



                    if (prevpopupobj.detaildatavalue_arr[tmpi].productid==undefined|| prevpopupobj.detaildatavalue_arr[tmpi].productid == '' || prevpopupobj.detaildatavalue_arr[tmpi].productid == 0) {
                        if (prevpopupobj.detaildatavalue_arr[tmpi].databind == undefined ||
                            prevpopupobj.detaildatavalue_arr[tmpi].databind == 'no') {
                            var tmprowobj = ld(tableobj).find("tr[rowindex=" + tmpi + "]");//赋值的行对象
                            that.setDataBind(tmprowobj);
                        }
                        emptyrows.push(tmpi+1)
                    }
                }

                //duan 20230511 提前给源单字段赋值,避免布局规则读不到源单信息
                if(account_version == 'huacanguangdian' && that.cur_module == 'CustomForm37') {}else{
                    var tmp_prod_array = [];
                    for (productid in prod_array) {
                        tmp_prod_array = prod_array[productid];
                        for (var columnname in tmp_prod_array) {
                            var quote_idobj = ld(that.quoteidobj);
                            if (that.cur_module == 'SalesOrder' && quote_idobj != undefined && ld(quote_idobj).val() != undefined) {
                                if (columnname == 'selectSourceModuleid') {
                                    var oldid = ld(quote_idobj).val();
                                    ld(quote_idobj).val(tmp_prod_array[columnname]);
                                }
                            } else {
                                if (columnname == 'selectSourceModuleid') {
                                    var oldid = ld(that.selectlistvalobj).val();
                                    var oldids = [];
                                    if (oldid != '')
                                        oldids = oldid.split(',');

                                    if (ld.inArray(tmp_prod_array[columnname], oldids) < 0) {
                                        oldids.push(tmp_prod_array[columnname]);
                                        oldid = oldids.join(",");
                                        ld(that.selectlistvalobj).val(oldid);
                                    }
                                }
                            }
                        }
                    }
                }

                //zkt 20230406 BUG0063889 （http://42.193.125.39:85/crm）8492版本，工程账套，采购合同PurchaseOrder源单选择成本预算清单CustomForm14，产品分录的明细无法自动带出
                //选择源单

                if (prevpopupobj.selectproductobj.popup_selectsource == true) {
                    getJsScriptCategory('include/js/relatedfield.js', function () {
                        getRelatedFieldData('', prevpopupobj.selectproductobj.sourcemodule_reocrd, '', '', prevpopupobj.selectproductobj.cur_module, 'popupselectfield');
                    });
                    //zkt 20240607 BUG20240605-40  销售合同表头备注字段，做生产订单的时候允许带到生产合同，现通过SQL录入实现，但1、销售合同下推生产订单，备注正常带出，2、生产订单选择源单，备注未正常带出
                    ld(that.selectlistvalobj).change();
                }
                var entmprowslen = emptyrows.length;
                that.popupobj.fieldformulaobj.ismasscount = 'yes';
                var selectrowid_arr = [];
                var tableobj = that.popupobj.getDetailTableObj();

                for (productid in prod_array) {

                    select_rowid = 0;
                    var intproductid = parseInt(productid);

                    if (rowcnt >= 1) {

                        //选择产品

                        if (that.popup_selectsource == false && k == 1 && rowid >= 1
                            && ld(trobj).length > 0) {

                            select_rowid = rowid;
                            startemptyrowindex++;

                        } else if (that.popup_selectsource == false && k == 1 && rowid >= 1
                            && ld(trobj).length > 0
                            && ld(hidden_rowid_obj).val() == 0
                            && ld(hdnProductIdobj).val() > 0) {

                            //	fun_selectproduct.clearProductInfo_Row(rowid);

                            select_rowid = rowid;

                        } else {

                            if (startemptyrowindex < entmprowslen)
                                select_rowid = emptyrows[startemptyrowindex];


                            if (empty(select_rowid)) {

                                select_rowid = that.fnaddProductRow();

                            }

                            startemptyrowindex++;
                        }
                    }

                    var tmpProductInfo = prod_array[productid]
                    // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
                    if(tmpProductInfo.property_status === 'yes') {
                        try {
                            tmpProductInfo = ProductPropertyGroup.setProductPropertyGroup(popupobj, select_rowid, tmpProductInfo);
                        }
                        catch (e) {
                            console.log(e)
                        }
                    }

                    if (k == 1 && that.popup_selectsource == false && tmprowid != undefined)
                        //ID1000410】单据产品明细项， 通过点击“确定”按钮选择产品
                    {

                        that.setValue(intproductid, prod_array[productid], tmprowid);
                        //海格 新增产品后判断是否与现有的产品组相同

                        that.discount_readonly(prevpopupobj, tmprowid);

                        selectrowid_arr.push(tmprowid);
                    } else if (that.popup_selectsource == true) {
                        //ls 2022-07-08 BUG0053704 (http://120.78.11.205/crm/）从报价单详情下推到销售合同界面可以看到产品图片，新建合同之后再选择源单的界面看不到产品图片(选择源单时productid值其实是lineitem_id)
                        that.setValue(prod_array[productid]['hdnProductId'], prod_array[productid], select_rowid);
                        //selectrowid_arr.push(select_rowid);
                    } else {

                        that.setValue(intproductid, prod_array[productid], select_rowid);
                        //selectrowid_arr.push(select_rowid);
                    }
                    k++;
                    //  console.log(k)
                }

                var selecttrobj = ld(tableobj).find("tr[rowindex=" + select_rowid + "]");//赋值的行对象;
                if (ld(selecttrobj).find('[search_productname]').length > 0) {
                    ld(selecttrobj).find('[search_productname]').hide();
                }

                that.popupobj.fieldformulaobj.ismasscount = 'no';
                that.popupobj.fieldruleobj.setTrContent();
                that.popupobj.fieldformulaobj.CountsubTotal();//小计
                that.popupobj.detail2mainformulaobj.changeRowEvent();
                //选择产品:设置产品分录中最后一行选择产品后是否自动新增一个空行

                if (prevpopupobj.selectproductobj.popup_selectsource == false && prevpopupobj.module != 'WorkSheet') {

                    if (prevpopupobj.selectproductobj.addproductrow == 0 && select_rowid >= rowcnt) {
                        var tmpchange_typeobj = ld("#"+prevpopupobj.divid+' [name=change_type]');
                        if (tmpchange_typeobj.val() == undefined ||
                            (ld(tmpchange_typeobj).val() != 'replace' && prevpopupobj.selectproductobj.cur_module != 'QuotesChange' && prevpopupobj.selectproductobj.cur_module != 'BudgetChange')) {	//报价变更单 - 变更时，没有新增行
                            if(prevpopupobj.detailfieldcolumninfo['productname'].defaultvalue>0)
                            {
                                //如果產品有默認值，則不在新增行
                            }
                            else
                                that.fnaddProductRow();
                        }
                    }
                }
                // 销售发票新增界面，选择源单以后，没有显示源单信息；需要也显示源单信息；
                if(prevpopupobj.module == 'Invoice' || prevpopupobj.module == 'PurchaseInvoice'){
                    // 选择源单时
                    if(that.popup_selectsource == true){
                        var relatedorder_obj = ld("#" + popupobj.divid).find('#relatedorder_div');// 源单信息div对象
                        var tmp_urlstring = 'module=' + prevpopupobj.selectproductobj.cur_module + '&action=' + prevpopupobj.selectproductobj.cur_module + 'Ajax&file=SourceInfo';
                        var tmp_sourcemodule_record = ld(that.selectlistvalobj).val();// 获取所有已选源单id
                        tmp_urlstring += '&sourcemodule='+prevpopupobj.selectmodule+'&idstring='+tmp_sourcemodule_record;

                        new Ajax.Request(
                            'index.php',
                            {
                                queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                async: false,
                                postBody: tmp_urlstring,
                                onComplete: function (response) {
                                    var tablehtml = response.responseText;
                                    relatedorder_obj.html(tablehtml);
                                }
                            }
                        );
                    }
                }

                prevpopupobj.selectproductobj.AfterchooseSourceHide();////选择源单后隐藏按钮（严格控制选择源单）
                that.setScrollMoveEvent(prod_array, 3000);
                ld('#rptContentLoading').hide();
                //console.log();
            }
        }
    );

}
//20230103
fun_selectproduct.prototype.setScrollMoveEvent = function (prod_array, everyrows) {
    return false;
    var that = this;
    var lastpopupobj = CrmPopup.getPopupObj('last');
    var tableobj = that.popupobj.getDetailTableObj();
    ld("#" + lastpopupobj.divid + " [name=productDiv]").on('scroll', function () {
        var j = 0;
        ld("#" + lastpopupobj.divid + " [name=productDiv]").unbind('scroll');
        for (var i = 0; i < that.popupobj.detaildatavalue_arr.length; i++) {
            if (that.popupobj.detaildatavalue_arr[i].databind == 'no') {
                if (j >= everyrows) {
                    ld("#" + lastpopupobj.divid + " [name=productDiv]").bind('scroll', function () {
                        that.setScrollMoveEvent(prod_array, everyrows);
                    });
                    break;
                }
                that.setBindProductRow(prod_array, tableobj, i);
                j++;
            }
        }
    });
}
fun_selectproduct.prototype.setBindProductRow = function (prod_array, tableobj, i) {
    var that = this;
    var prevpopupobj = this.popupobj;
    that.getMethod();
    that.isProductClear = 'no';
    //出库或入库时必须严格参照源单
    if (!that.sourceOtherProducts()) return false;
    if (that.cur_module == 'QuotesChange' || that.cur_module == 'BudgetChange') {
        var tmpchange_typeobj = ld("#"+prevpopupobj.divid+' [name=change_type]');
        if (tmpchange_typeobj !=undefined && ld(tmpchange_typeobj).val() != undefined && ld(tmpchange_typeobj).val() == 'replace') {
            return false;
        }
    }
    that.AddRowByRowIndex(eval(i) + 1);//添加行
    if (that.addRow_finished == true) {
        var newrowindex = eval(i) + 1;
        var rowobj = ld(tableobj).find("tr[rowindex=" + newrowindex + "]");

        that.setDataBind(rowobj);//数据绑定
        var tmpproductid = that.popupobj.detaildatavalue_arr[i]['hdnProductId'];
        if (tmpproductid > 0) {
            that.setValue(tmpproductid, prod_array[tmpproductid + "aa"], newrowindex);
        }
        getRelatedProductToolFieldPrice(that.popupobj, newrowindex);
        //DisCountFocusShowMess(that.popupobj);	//光标定位在折扣率字段上，显示温馨提示信息
        //versiontype  yuanmei 特殊控制

        if (that.popupobj.ordertype_onclick != undefined && that.popupobj.ordertype_onclick != '' && that.popupobj.ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined) {
            setProductToolFieldDisplay('create', that.popupobj);
        }
        setInventoryPickListContent(that.popupobj);
        //设置明细字段的多选框和单选框
        that.popupobj.SetDetailFieldControl(i);
    }
}

//根据产品id，获取产品关联信息  (支持单选和多选)
fun_selectproduct.prototype.getProductInfo = function (rowid, productid) {
    var prevpopupobj = this.popupobj;
    prevpopupobj.selectproductobj.getMethod();
    var change_type = '';

    var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&getProductinfo=yes';
    urlstring += '&wareid=' + prevpopupobj.selectproductobj.wareid + '&accvenid=' + prevpopupobj.selectproductobj.accvenid + '&currencyid=' + prevpopupobj.selectproductobj.currencyid + '&rowid=' + rowid + '&frommodule=' + prevpopupobj.selectproductobj.cur_module + '&productid=' + productid;
    urlstring += "&currency_id=" + this.inventory_currencyobj.val();

    if (prevpopupobj.selectproductobj.cur_module == 'QuotesChange' || prevpopupobj.selectproductobj.cur_module == 'BudgetChange') {
        var tmpchange_typeobj = ld("#"+prevpopupobj.divid+' [name=change_type]');
        if (tmpchange_typeobj != undefined && ld(tmpchange_typeobj).val() != undefined) {
            change_type = ld(tmpchange_typeobj).val();
            urlstring += '&change_type=' + change_type;
        }
    }

    ld.each(prevpopupobj.fields, function (tmpindex, tmpfieldinfo) {
        if (tmpfieldinfo.displaytype == 3 && tmpfieldinfo.bigtype == 'reference' && tmpfieldinfo.columnname == 'pricebooksid') {
            //海格
            urlstring += "&pricebooksid=" + ld("#" + prevpopupobj.divid + " [name=pricebooksid]").val();
            return false;
        }
    })
    var requestvalues = "";
    var  sensitiverequestfield="";
    var requestvaluearr = getPageValueByCrmPopupFields(prevpopupobj);
    requestvalues = requestvaluearr['requestvalue'];
    sensitiverequestfield = requestvaluearr['sensitiverequestfield'];


    urlstring += "&requestvalues=" + encodeURIComponent(requestvalues);
    urlstring += "&sensitiverequestfield=" + encodeURIComponent(sensitiverequestfield);

    prevpopupobj.selectproductobj.getValue(rowid, urlstring);
}

//赋值
fun_selectproduct.prototype.setValue = function (productid, prod_array, rowid) {
    var that = this;

    var havepricestrategy = 'no';
    var popupobj = this.popupobj;
    var batchmanagement = prod_array.batchmanagement;
    var sourcemodule_record = 0;
    var sourcemodule_label = '';

    var pricestrategyobj = popupobj.pricestrategyobj;
    var productstrategyobj = popupobj.productstrategyobj;
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");

    if (pricestrategyobj.modulehaveprice(popupobj.module) == 'yes' && prod_array.pricestrategy.productids.length > 0 && prod_array.pricestrategy.productids[0] > 0) {
        if (productstrategyobj.productids == undefined || ld.inArray(productid, productstrategyobj.productids) < 0) {
            if (productstrategyobj.info == undefined) {
                productstrategyobj.info = {};
            }
            productstrategyobj.info[productid] = prod_array.pricestrategy.info[productid];//保存有价格策略的产品

            if (productstrategyobj.maxfixedbase == null && productstrategyobj.maxfixedbase == undefined) {
                productstrategyobj.maxfixedbase = new Array();
            }
            if (productstrategyobj.productids == undefined) {
                productstrategyobj.productids = [];
            }
            productstrategyobj.maxfixedbase.push(prod_array.pricestrategy.maxfixedbase[0]);//保存有价格策略的产品
            productstrategyobj.productids.push(prod_array.pricestrategy.productids[0]);//保存有价格策略的产品
        }


        if (ld.inArray(productid.toString(), productstrategyobj.productids) >= 0) {
            havepricestrategy = 'yes';
        }
    }

    var selectlistval_labeobj=that.selectlistval_labelobj;
    for (var columnname in prod_array) {
        // @edit:dong @date:2021/04/20 @reason: erp分录id不允许带出
        if (columnname == 'erpentryid') continue;

        //chj 2021/12/1 合同订单选择源单：取消只选择一个报价单
        if(account_version == 'huacanguangdian' && that.cur_module == 'CustomForm37'){}else{

            if (that.cur_module == 'SalesOrder' && that.quoteidobj != undefined && ld(that.quoteidobj).val() != undefined) {
                if (columnname == 'entitytype') {
                    var selectlistval_label = ld(selectlistval_labeobj).val();
                    ld(selectlistval_labeobj).val(prod_array[columnname]);
                } else if (columnname == 'selectSourceModuleid') {
                    //合同订单选择原单只能选择一个
                    var oldid = ld(that.quoteidobj).val();
                    ld(that.quoteidobj).val(prod_array[columnname]);
                }
            } else {
                if (columnname == 'selectSourceModuleid') {
                    //chj 20220520 源单选择多个分录的时，再次选择带有布局规则的字段，这个时候，源单会显示多个重复编号
                    var oldid = ld(that.selectlistvalobj).val();
                    var oldids = [];
                    if (oldid != '')
                        oldids = oldid.split(',');
                    if (ld.inArray(prod_array[columnname], oldids) < 0) {
                        oldids.push(prod_array[columnname]);

                        oldid = oldids.join(",");
                        ld(that.selectlistvalobj).val(oldid);
                    }
                }
                if (columnname == 'entitytype') {
                    var oldentitytype = ld(selectlistval_labeobj).val();
                    var oldentitytypes = [];
                    if (oldentitytype != '')
                        oldentitytypes = oldentitytype.split(',');
                    if (ld.inArray(prod_array[columnname], oldentitytypes) < 0) {
                        oldentitytypes.push(prod_array[columnname]);
                        oldentitytype = oldentitytypes.join(",");
                        ld(selectlistval_labeobj).val(oldentitytype);
                    }
                }
            }
        }
        if (columnname == 'currency_id') {
            //alert(prod_array[columnname]);
            ld(that.inventory_currencyobj).val(prod_array[columnname]);
        }
        //zkt 20230927 先注释掉后面卡了再做优化()
        //chj 2021/11/23 48888: 报价单关联创建合同，可代入调整信息，合同新增选报价单无法带入调整。建议能够带入
        if (columnname == 'adjustment') {

            if (prod_array[columnname] > 0) {
                CrmPopup.findHtmlobj(popupobj.divid, 'adjustmentType').find("option[value='+']").attr('selected', true);
                CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val(prod_array[columnname]);
            }
            if (prod_array[columnname] < 0) {
                CrmPopup.findHtmlobj(popupobj.divid, 'adjustmentType').find("option[value='-']").attr('selected', true);
                CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val(Math.abs(prod_array[columnname]));
            }
        }
        //ls 2022-07-28  选择源单带出整单折扣的值
        if (columnname == 'discount_amount') {
            if (prod_array['discount_type'] == 1) {
                ld("#" + popupobj.divid + " [name=proTabTotal]").find("[name=allSingledDiscount]").find("option[value='%']").attr('selected', true);
                ld("#" + popupobj.divid + " [name=proTabTotal]").find("[name=discount_amount]").val(prod_array['maintablefield_discount_percent']);
            } else {
                ld("#" + popupobj.divid + " [name=proTabTotal]").find("[name=allSingledDiscount]").find("option[value='-']").attr('selected', true);
                ld("#" + popupobj.divid + " [name=proTabTotal]").find("[name=discount_amount]").val(prod_array['maintablefield_discount_amount']);
            }
        }

        //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示
        if (ld.inArray(columnname, popupobj.allproductimagefieldname) >= 0) {
            getproductImageName(productid, rowid, columnname);
        }
        else if (columnname.toLocaleLowerCase() == 'batchmanagement' || columnname.toLocaleLowerCase() == 'batchtext') {
            if (that.popupobj.havebatchtextcolumnname == 'yes')//有批次字段
            {
                popupobj.detaildatavalue_arr[rowid - 1][columnname] = decodeURIComponent(prod_array[columnname]);
                if (batchmanagement == 1) {
                    //批次字段增加
                    popupobj.detaildatavalue_arr[rowid - 1]['producthave_batchtext'] = 'yes';
                    ld(rowobj).find(" [name=batchtext]").css("display", 'inline');
                    ld(rowobj).find(" [name=searchbatchtextIcon]").css('display', 'inline');
                    ld(rowobj).find(" [name=clearbatch]").css('display', 'inline');
                    if (popupobj.module == "Checks") {
                        //盘点单批次改变后，获取账面数量
                        ld(rowobj).find("  [name=batchtext]").unbind("change").bind("change", function () {
                            var popupobj = that.popupobj;
                            var divid = popupobj.divid;
                            var wareid = ld("#" + divid + " [name=wareid]").val();
                            var tmpproductid = ld(rowobj).find(" [name=hdnProductId]").val();
                            if (tmpproductid <= 0) {
                                return false;
                            }
                            ldAjaxNoProgress('index.php?module=Checks&action=ChecksAjax&file=getpageQuantity&productid=' + tmpproductid + "&batchtext=" + encodeURIComponent(ld(this).val()) + "&wareid=" + wareid,'',function (data) {
                                popupobj.detaildatavalue_arr[rowid - 1]['paperquantity'] = data.result.pagequantity;
                                //ld(rowobj).find(" [name=paperquantity]").val(data.result.pagequantity);
                                //ld(rowobj).find(" [name=span_paperquantity]").html(data.result.pagequantity);
                                popupobj.fieldformulaobj.cur_input_focus_obj = ld(rowobj).find("  [name=paperquantity]").get(0);
                                popupobj.fieldformulaobj.CountRowFormulaColumn(rowid);

                            });

                        })
                    }
                    //}
                } else {
                    popupobj.detaildatavalue_arr[rowid - 1]['producthave_batchtext'] = 'no';
                    ld(rowobj).find(" [name=batchtext]").css("display", 'none');
                    //ld(rowobj).find(" [name=batchtext]").val("");
                    popupobj.detaildatavalue_arr[rowid - 1]['batchtext'] = '';
                    ld(rowobj).find(" [name=searchbatchtextIcon]").css('display', 'none');
                    ld(rowobj).find(" [name=clearbatch]").css('display', 'none');
                }
            }
        }
        else {
            if (prod_array[columnname] == 'null' || prod_array[columnname] == null) {
                prod_array[columnname] = '';
            }
            var uitype = 0;
            if (popupobj.detailfieldcolumninfo[columnname] != undefined)//产品hdnproductId为undefined
                uitype = popupobj.detailfieldcolumninfo[columnname].uitype;

            var rowindex = rowid;//ld(rowobj).attr(("rowindex"));

            //zkt 20220704 1000143  采购订单、收付款单、出入库单，分录明细增加“合同订单”字段（咏睿）
            if (prod_array[columnname + '_name'] != undefined) {
                //引用关联选择单据，不可编辑时界面赋值
                try {
                    popupobj.detaildatavalue_arr[rowindex - 1][columnname] = decodeURIComponent(prod_array[columnname + '_name']); //   ld(rowobj).find("#"+columnname+"_name]").html(decodeURIComponent(prod_array[columnname+'_name']));
                } catch (ex) {
                    popupobj.detaildatavalue_arr[rowindex - 1][columnname] = prod_array[columnname + '_name'];
                }
            }
            if(popupobj.detailfieldcolumninfo[columnname]!=undefined&&(popupobj.detailfieldcolumninfo[columnname].edit_permission==1||
                popupobj.detailfieldcolumninfo[columnname].edit_permission==3))
            {

                popupobj.detaildatavalue_arr[rowindex - 1][columnname+"_name"] = prod_array[columnname];
            }
            popupobj.detaildatavalue_arr[rowindex - 1]['lineitem_id'] = 0;

            if (columnname == 'entitytype') {

                popupobj.detaildatavalue_arr[rowindex - 1][columnname + "_name"] = decodeURIComponent(prod_array['entitytype_transmodule'])

                popupobj.detaildatavalue_arr[rowindex - 1][columnname] = decodeURIComponent(prod_array['entitytype_module'])
                if (prod_array['entitytype_module'] == undefined) {
                    prod_array['entitytype_module'] = '';
                }
                if (prod_array['selectSourceModuleid'] == undefined) {
                    prod_array['selectSourceModuleid'] = '';
                }

                popupobj.detaildatavalue_arr[rowindex - 1]['parent_lineitem_id'] = prod_array['lineitem_id'];
                popupobj.detaildatavalue_arr[rowindex - 1]['entitytypeid'] = prod_array['selectSourceModuleid'];
                popupobj.detaildatavalue_arr[rowindex - 1]["entitytypeid_name"] = prod_array['entitytype'];

                //ls  20231220  BUG0077502 安装调试模块，计划信息区块，字段：“安装开始日期“sql取值，取不到值  (选择源单隐藏域无法触发change事件,需要主动触发)
                // ld(that.selectlistvalobj).change();
            }
            /* else if (columnname == 'contractid'||columnname=='contractid_name'){
                      //edit:can 202312122 77617 入库单的第二行的采购含税单价错位
                 popupobj.detaildatavalue_arr[rowindex - 1][columnname] = decodeURIComponent(prod_array['contractid'] || '')
                 popupobj.detaildatavalue_arr[rowindex - 1]['contractid_name'] = decodeURIComponent(prod_array['contractid_name'] || '')

             }*/
            else if (uitype == 221){
                //zkt 20230210 BUG0061541收款单，新建，选择原单服务合同，添加源单，单据分录“产品源单类型”字段，显示undefined
                if (prod_array['span_' + columnname] != undefined){
                    popupobj.detaildatavalue_arr[rowindex - 1][columnname+ "_name"] = decodeURIComponent(prod_array['span_' + columnname]);
                }
                popupobj.detaildatavalue_arr[rowindex - 1][columnname] = prod_array[columnname];
            }

            //zkt 20230222 BUG0061979http://101.33.200.27:85/crm ；康名医疗；【外地邮寄】模块中的“确认”这个字段的默认值是“否”，但是在新建单据，选着源单的时候，该字段在新建/编辑页面显示“是”
            else if (uitype == 56){
                popupobj.detaildatavalue_arr[rowindex - 1][columnname] = (prod_array[columnname]==0||prod_array[columnname]==false)?false:true;
                //zkt 20241023 BUG20241009-51 销售订单变更单，选择源单是销售订单，变更单的原“是否赠品”引用的订单的“是否赠品”字段，显示01，保存之后都是否，没有正确引用源单。
                if(popupobj.detailfieldcolumninfo[columnname]!=undefined) {
                    if ((popupobj.detailfieldcolumninfo[columnname].edit_permission==1|| popupobj.detailfieldcolumninfo[columnname].edit_permission==3)){
                        popupobj.detaildatavalue_arr[rowindex - 1][columnname] = (prod_array[columnname]==0||prod_array[columnname]==false)?0:1;
                    }else if (columnname == 'discontinued'){//是否禁用
                        popupobj.detaildatavalue_arr[rowindex - 1][columnname] = prod_array[columnname];
                    }
                }
            }
            else if (columnname == 'productname') {

                popupobj.detaildatavalue_arr[rowindex - 1]['productid'] = prod_array['hdnProductId']
                popupobj.detaildatavalue_arr[rowindex - 1]['productname'] = decodeURIComponent(prod_array['productname']);

                //    console.log(popupobj.detaildatavalue_arr[rowindex-1]);

            }
            else {

                var tmpstr = prod_array[columnname] + "";
                if (ld.trim(prod_array[columnname]) != "" && tmpstr.split("%").length > 2) {
                    //产品属性字段设置为可以编辑
                    //ls 2022-07-25 BUG0053973 含有百分号时decodeURIComponent报错URI malformed
                    prod_array[columnname] = decodeURIComponent(prod_array[columnname].replace(/%/g, '%25'));
                }
                try {
                    //edit:can 2020-11-17 43317: （http://lanniaofire.vicp.io:9085/crm [^]）客户问题（陈修宏），销售发票新建界面，选择出库单（出库单编号：CK2020111634671）源单单据后，带出的产品分录中“含税单价”显示0说明	（http://lanniaofire.vicp.io:9085/crm [^]）客户
                    popupobj.detaildatavalue_arr[rowindex - 1][columnname] = decodeURIComponent(prod_array[columnname]);
                    if (popupobj.detaildatavalue_arr[rowindex - 1][columnname + "_name"] != undefined) {

                        popupobj.detaildatavalue_arr[rowindex - 1][columnname + "_name"] = popupobj.detaildatavalue_arr[rowindex - 1][columnname];
                    }
                } catch (ex) {

                    popupobj.detaildatavalue_arr[rowindex - 1][columnname] = prod_array[columnname];
                }
            }




            if (columnname == 'productname' && ld(rowobj).length > 0) {

                that.clear_bomInfo(rowid);//清空产品套餐信息

                //edit:can 69237 产品套餐，在单据分录里显示不了套餐名称，如何设置显示产品套餐呢？
                // 选择带产品套餐信息的源单, 带出产品套餐信息
                if (prod_array['productbomid'] != '' && parseInt(prod_array['productbomid']) > 0) {

                    //edit:can 2020-09-29 042234: （https://61mis.com/kfbtest [^]）单据新建界面，选择“有产品套餐信息（SO198）”的源单单据后，产品分录中没有显示套餐名称和组合数量（出库单模块测试）
                    ld(rowobj).find("[tag=dv_productbominfo]").css('display', '');
                    ld(rowobj).find("[tag=productbomname]").html(prod_array['productbomname']);
                    ld(rowobj).find("[tag=productbomquantity]").html(prod_array['productbomquantity']);
                    // ld(rowobj).find("#productbomid").val(prod_array['productbomid']);
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomname'] = prod_array['productbomname'];
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomquantity'] = prod_array['productbomquantity'];
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomid'] = prod_array['productbomid'];
                }
                // 直接选择产品套餐, 带出套餐信息
                else if (prod_array['bom_id'] != '' && parseInt(prod_array['bom_id']) > 0) {

                    ld(rowobj).find("[tag=dv_productbominfo]").css('display', '');
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomname'] = prod_array['productbomname'];
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomquantity'] = prod_array['productbomquantity'];
                    popupobj.detaildatavalue_arr[rowindex - 1]['productbomid'] = prod_array['bom_id'];
                }

                ld(rowobj).find("#productname").attr("Readonly", true).removeClass("border_red1").css("cursor", 'not-allowed');
                //20240222 hzx BUG20240220-14 销售退款单--产品分录--产品输入框后面没有按钮也有空白把产品名称挡住了
                ld(rowobj).find("#productname").removeClass("ld-input-inner-add");
            }
            if (uitype == 60) {
                //下拉框 BUG0065864 ls 20230508 相关信息可以带出，直接新建无法带出（已经赋值只是界面看不到）
                //ld(rowobj).find(" [name=cmb_span_optiontext_"+columnname+"]").val(prod_array[columnname]);
                popupobj.detaildatavalue_arr[rowindex - 1][columnname] = prod_array[columnname];

                if (columnname == 'wareid') {
                    //edit:can 2020-12-16 43700: （https://61mis.com/kfbcrm [^]）出库单选择产品（产品A），选择批次弹出层中【仓库】下拉选项没有带出产品分录中【仓库】字段默认显示的值
                    // ld(rowobj).find("#wareid").val(prod_array[columnname+"_rawvalue"]);
                    popupobj.detaildatavalue_arr[rowindex - 1]['wareid_rawvalue'] = prod_array[columnname+"_rawvalue"];

                }

            }
            //wym 231130 BUG0075757 选择原单-自动带出引用原单附件字段
            if((uitype == 69 ||uitype == 1109) && ld(rowobj).length > 0){
                var fldname=columnname;
                if(ld(rowobj).find('#'+fldname).length>0){
                    var fileuploader=ld(rowobj).find('#'+fldname);
                    //wym BUG0076796 这里代码不用改，不然可能会显示两个添加或者带不出添加按钮
                    fileuploader.find('.uploader-list').html('');
                    ld.each(popupobj.detailimage_arr,function(i,info){
                        if(info['columnname']==fldname){
                            if(prod_array[fldname] && prod_array[fldname]!=undefined){
                                //wym 231130 给数组赋空值会报错 所以移到非空判断里面了
                                if(!popupobj.detailfilejsondata[rowid]) {
                                    popupobj.detailfilejsondata[rowid] = [];
                                }
                                popupobj.detailfilejsondata[rowid][fldname]=prod_array[fldname];
                                ld(fileuploader).html('');
                                var uploadFile = new WebUploadFile();
                                globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                                uploadFile.setDetailEvent(globalWebUploadType,fileuploader,popupobj,i,rowid);
                            }else{
                                ld(fileuploader).find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);
                            }
                            return false;
                        }
                    })
                }
            }
        }

    }
    if(prod_array['taxprice']) {
        popupobj.detaildatavalue_arr[rowindex - 1]['tax_price_before_discounted'] = prod_array['taxprice'];
    }

    // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
    if(prod_array['property_status'] === 'yes') {
        try {
            ProductPropertyGroup.showProductProperty(popupobj, rowid, prod_array);
        }
        catch (e) {
            console.log(e)
        }
    }

    //popupobj.SetDetailFieldControl(rowid);

    //fun_selectproduct.setModuleEntityName();

    if (havepricestrategy == 'yes') {

        if (popupobj.module == 'SalesOrder' || popupobj.module == 'ServiceContracts' || popupobj.module == 'Quotes') {
            pricestrategyobj.startcomputer(rowid);
            //有价格策略,且修改的是数量字段，
            // continue;
        } else {
            fun_selectproduct.setProductPriceForAccountBuy(rowid);
        }
        //edit:can 2020-10-15 042856: （https://61mis.com/kfbtest [^]）产品编号“PRO60”使用价格策略，合同订单新建界面选择产品编号“PRO60”后，合计显示0
        // popupobj.fieldformulaobj.CountsubTotal();

    } else {
        that.setProductPriceForAccountBuy(rowid);

    }


    if (that.popup_selectsource) {


        //035959: 捷力星 销售发票新建 选择源单合同订单，带出来的产品合计跟源单的价格不一致，不是所有单据都这样 比如选择合同订单编号JLX18070574 ，JLX18100846，就有问题

        var selectsourcemodule = ld("#" + popupobj.divid + ' [name=selectsource]').val();
        var autobalancecolumn = '';
        var samesourcevalue_arr=[];//原单关联创建哪些字段不需要调用字段公式
        if (popupobj.sourcemodule_arr != undefined) {
            ld.each(popupobj.sourcemodule_arr, function (tmpindex, sourceinfo) {
                if (sourceinfo['entitytype'] == selectsourcemodule) {
                    autobalancecolumn = sourceinfo['autobalancevalue'];
                    if(sourceinfo.samesourcevalue!=''&&sourceinfo.samesourcevalue!=undefined)
                    {
                        samesourcevalue_arr=JSON.parse(sourceinfo.samesourcevalue);

                    }
                    return false;
                }
            })
        }
        popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr = [];
        if(samesourcevalue_arr!=undefined&&samesourcevalue_arr.sametype=='all')
        {

        }
        else if (autobalancecolumn != '' && autobalancecolumn != null) {
            if(autobalancecolumn=='quantity')
            {
                popupobj.fieldformulaobj.haveFinishedFormulaColumnsarr.push(popupobj.fieldformulaobj.baseColumn);
                popupobj.fieldformulaobj.finishedcolumncount[popupobj.fieldformulaobj.baseColumn]=4;

            }
            popupobj.fieldformulaobj.changedatabyColumnname(autobalancecolumn,rowid);
        } else
            popupobj.fieldformulaobj.changedatabyColumnname(popupobj.fieldformulaobj.baseColumn, rowid);
        //edit:can 2020-10-16 42916: （https://61mis.com/kfbtest/ [^]）单据新建界面，选择源单后，产品合计显示0（合同订单模块测试）
        //popupobj.fieldformulaobj.CountsubTotal();
    } else if (havepricestrategy != 'yes')//如果有价格策略//37100: （公司自用账套）合同订单新增界面>选择编号为“08.02”的产品：选择后没有将单价带出来，该产品设置了产品策略。
    {
        popupobj.fieldformulaobj.NoInput_FocusFormula(rowid);
    }

    // 赠品无需重算

        that.popupobj.fieldformulaobj.CountsubTotal();

    // that.showTooltipByTr(rowobj);

    if(typeof that.popupobj.skipRelatedDetailField != 'undefined' && that.popupobj.skipRelatedDetailField == 'yes')
        return;//【广东金瓷三维】 特殊开发带出的值，要求不再调用关联带出了
    //@edit:liushuai,2020-09-18,reason:【ID1001073】销售订单、报价单选择产品，输入数量后自动带出价格（选择多个产品时，在插入行之后并赋完值再调用）
    CrmPopup.getPopupObj('last').RelatedProductToolFieldtriggcols = [];
    CrmPopup.getPopupObj('last').CurRelatedProductToolFieldName="";
    
    getRelatedProductToolFieldPriceCallBack(CrmPopup.getPopupObj('last'), rowid);
    //duan 20240926 整行操作后调用公共变化事件
    popupobj.common_field_event_obj.common_all_entry_changefun(rowid);
    //海格特殊开发，当产品组相同时控制折扣依据组内最大值显示
}
fun_selectproduct.prototype.setValueByRow=function(rowindex,productInfo)
{
    var that=this;
    ld.each(that.popupobj.detaildatavalue_arr[rowindex-1],function(tmpcolumnname,value){
        if(productInfo[tmpcolumnname]!=undefined)
            that.popupobj.detaildatavalue_arr[rowindex-1][tmpcolumnname]=productInfo[tmpcolumnname]
    })
    if(productInfo.is_present === 'yes') {
        that.popupobj.detaildatavalue_arr[rowindex-1]['present'] = productInfo['present'];
    }
}

//产品单价自动根据客户最近一次购买的产品价格带出。
fun_selectproduct.prototype.setProductPriceForAccountBuy = function (rowid) {
    var that = this;
    var rowobj = ld(this.tableobj).find("tr[rowindex=" + rowid + "]");
    // 赠品无需计算金额
    var rowVal = that.popupobj.detaildatavalue_arr ? that.popupobj.detaildatavalue_arr[rowid-1] : undefined;
    if(rowobj.attr('present') !== undefined || (rowVal && rowVal.is_present === 'yes')) {
        return
    }
    if (that.setproductpricefor_accountbuy == 0 && (that.cur_module == 'SalesOrder' || that.cur_module == 'Quotes')) {
        this.getMethod();
        if (that.accvenid > 0 && !empty(that.cur_module)) {
            if (rowVal && rowVal.productid != undefined && rowVal.productid > 0) {
                var productid = rowVal.productid;
                //alert('index.php?module=Products&action=ProductsAjax&file=GetSearchInfo&productid='+productid+'&account_id='+account_id+'&frommodule='+module+'&currency_id='+currency_id+'&setProductValue=yes');

                var href_url = encodeURI('index.php?module=Products&action=ProductsAjax&file=GetSearchInfo&productid=' + productid + '&account_id=' + that.accvenid + '&frommodule=' + that.cur_module + '&currency_id=' + that.currencyid + '&setProductValue=yes');
                ld.ajax({
                    url: href_url,
                    type: 'POST',
                    data: '',
                    dataType: 'json',
                    async: false,
                    timeout: 5000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {

                    },
                    success: function (data) {
                        var results = data.entity;

                        if (results != null && results != '') {
                            var res_arr = Object.keys(results);
                            //edit:can 20210630 046644: （http://1.116.96.45/crm/ [^]）客户问题（王耀文），启用最近价格，销售开单选择“白鹭湖旭日批发”客户，该客户没有历史订单，正常下单客户默认价格应该是0，但是系统会把其他客户最近该产品的价格带出来 ，改为没有历史价就显示价格为0

                            for (var i = 0; i < res_arr.length; i++) {
                                var tmpcolumnname = res_arr[i];
                                if (rowVal[tmpcolumnname] != undefined) {
                                    //edit:can 20210823 47629: (https://www.51mis.com/hy/SCJR/ [^])在客户相关页签中新建报价单的时候，选择多个产品确定后只显示一个产品
                                    var amount = parseFloat(results[tmpcolumnname]).toFixed(that.lengthprice);
                                    rowVal[tmpcolumnname] = amount;
                                    if (rowVal["span_" + tmpcolumnname ] != undefined) {
                                        rowVal["span_" + tmpcolumnname ] = amount;
                                    }
                                }
                            }
                            //不含税单价
                            var hddlistprice = CrmPopup.findHtmlobj(that.popupobj.dvidid, res_arr[1] + rowid).val();
                            ld(rowobj).find(" [name=hddlistprice]").val(amount);

                        }
                    }
                });
            }
        }
    }

}

//如果明细有源单列，则赋值给表单的源单标签
fun_selectproduct.setModuleEntityName = function () {
    return false;
}
//重算行
fun_selectproduct.resetproductrow = function () {
    var popupobj = CrmPopup.getPopupObj('last');
    var trobjs = popupobj.getTrObjsByDelType('no');
    var trlength = ld(trobjs).length;
    if (trlength >= 1) {
        var confirm_str = arrJsPopLabel['areyousouryouwanttorecalcualte'];//提示内容
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            var rowobjs = popupobj.getTrObjsByDelType("no");
            if (!empty(rowobjs)) {
                ld.each(rowobjs, function () {
                    var rowindex = ld(this).attr("rowindex");
                    var hdnProductId = ld(this).find("[name=hdnProductId]");
                    if(ld(this).attr("havemouseevent")!='yes')
                    {
                        //edit:can 2023 0412 BUG0063903
                        popupobj.selectproductobj.setDataBind(ld(this));
                    }
                    if (!empty(hdnProductId)) {
                        if (!empty(popupobj.relatedproducttoolfield) && popupobj.relatedproducttoolfield.length > 0 && popupobj.relatedproducttoolfield[0].trigger_columnname != '') {
                            getRelatedProductToolFieldPriceCallBack(popupobj, rowindex);
                        } else {

                            popupobj.fieldformulaobj.changedatabyColumnname(popupobj.fieldformulaobj.baseColumn, rowindex);
                        }
                    }

                });
                popupobj.fieldformulaobj.CountsubTotal();
            }
        });
    }

}
//清空行
fun_selectproduct.emptyproductrow = function () {
    var popupobj = CrmPopup.getPopupObj('last');
    var trobjs = popupobj.getTrObjsByDelType('no');
    var trlength = ld(trobjs).length;
    if (trlength >= 1) {
        //edit:duan  海格特殊开发,报价单编辑或复制的时候，产品清空时不允许删除有出货记录的产品记录
        if (account_version == 'haige' && popupobj.module == 'Quotes' && popupobj.changequotetype != 'yes') {
            fun_selectproduct.CheckProductDetail();
        } else {
            //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
            Detaildatachange_byrowindexoperation(popupobj,'before','deleteall');

            var tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");
            ld.each(trobjs, function (tmprowindex, tmprowobj) {
                var rowid = parseInt(tmprowindex) + 1;
                var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
                ld(delrowobj).remove();
            });
            this.isProductClear = 'yes';//这个是干嘛的？
            //调整
            if (CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val() != undefined) {
                CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val(0);
            }
            //整单折扣
            if (CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val() != undefined) {
                CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val(0);
            }
            //清空产品数组
            popupobj.detaildatavalue_arr.length = 0;

            //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除后
            Detaildatachange_byrowindexoperation(popupobj,'after','deleteall');

            //增加空行
            this.addproductrow();
            //计算小计
            popupobj.fieldformulaobj.CountsubTotal();
            //duan 20240926 整行操作后调用公共变化事件
            popupobj.common_field_event_obj.common_all_entry_changefun(1);
        }
    }
}
//新增行  是否需要把未加载完的分录加载完 yes是
fun_selectproduct.addproductrow = function (isbindall) {
    var popupobj = CrmPopup.getPopupObj('last');
    //点击新增行的时候 需要把未加载的分录全部加载完
    if (isbindall == 'all') {
        var tableobj = popupobj.getDetailTableObj();
        for (var i = 0; i < popupobj.detaildatavalue_arr.length; i++) {
            if (popupobj.detaildatavalue_arr[i].databind == 'no') {
                popupobj.selectproductobj.setBindProductRow(popupobj.selectproductobj.prod_array, tableobj, i);
            }
        }
    }
    //37940: （http://xiaoshou360.com/KH/lantecp [^]）系统设置>系统参数设置>库存参数>【设置出库单和入库单必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）】设置为是：合同订单相关创建出库单没有受该参数控制。
    popupobj.selectproductobj.popup_selectsource = false;
    var rowcnt = popupobj.selectproductobj.fnaddProductRow('yes');

    for (var i = 0; i < popupobj.detailfields.length; i++) {
        //设置新增行产品的默认值
        if (popupobj.detailfields[i].columnname == 'productname' && popupobj.detailfields[i].defaultvalue > 0) {
            //默认新增多行，所有循环

            fun_selectproduct.setProductDefaultValue(rowcnt, popupobj.detailfields[i].defaultvalue);

            break;
        }
    }

}

//添加一行分录  isbinddata 添加一行绑定数据的分录 yes  添加一行空的分录 no
fun_selectproduct.prototype.fnaddProductRow = function (isbinddata) {
    var prevpopupobj = this.popupobj;
    var that = this;
    this.getMethod();
    this.isProductClear = 'no';
    //出库或入库时必须严格参照源单
    if (!this.sourceOtherProducts()) return false;
    if (this.cur_module == 'QuotesChange' || this.cur_module == 'BudgetChange') {
        var tmpchange_typeobj = ld("#"+prevpopupobj.divid+' [name=change_type]');
        if (tmpchange_typeobj !=undefined && ld(tmpchange_typeobj).val() != undefined && ld(tmpchange_typeobj).val() == 'replace') {
            return false;
        }
    }

    var   rowcnt=eval(this.popupobj.detaildatavalue_arr.length);
    var count = rowcnt+ 1;

    if (count >= 30000 && isbinddata != 'yes') {
        var tmpDetailDataValues = this.getDetailDataValues();
        tmpDetailDataValues.databind = 'no';

        this.popupobj.detaildatavalue_arr.push(tmpDetailDataValues);//添加一行数据绑定
        return count;
    }

    this.AddRowByRowIndex(eval(rowcnt) + 1);//添加空行

    if (this.addRow_finished == true) {
        var tableobj = that.popupobj.getDetailTableObj();
        var newrowindex = eval(rowcnt) + 1;
        var rowobj = ld(tableobj).find("tr[rowindex=" + newrowindex + "]");
        //BUG0073428 lius 20231124 工单管理-新增，选择多个源单，其单据分录中的单据排序有问题  newProTab时排序不对
        // if(that.popupobj.js_detailtablename=='proTab')
        // {
        //工单有两个tab

        this.popupobj.detaildatavalue_arr.push(this.getDetailDataValues());//添加一行数据绑定

        that.setDataBind(rowobj);//数据绑定
        // }
        getRelatedProductToolFieldPrice(this.popupobj, eval(rowcnt) + 1);
        //DisCountFocusShowMess(that.popupobj);	//光标定位在折扣率字段上，显示温馨提示信息
        //versiontype  yuanmei 特殊控制

        if (this.popupobj.ordertype_onclick != undefined && this.popupobj.ordertype_onclick != '' && this.popupobj.ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined) {
            setProductToolFieldDisplay('create', this.popupobj);
        }

        setInventoryPickListContent(this.popupobj);
        //设置明细字段的多选框和单选框

        this.popupobj.SetDetailFieldControl(count);

        return eval(rowcnt) + 1;
    }
    return '';
}
fun_selectproduct.prototype.AddRowByRowIndex = function (rowid) {
    //源单 - 合同信息列是否显示
    var contract_display = 'none';
    var that = this;
    if (this.popupobj.detaildatavalue_arr != undefined && this.popupobj.detaildatavalue_arr[0] != undefined &&this.popupobj.detaildatavalue_arr[0]['contractid'] != undefined) {
        contract_display = 'display';
    }
    //zkt //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录添加前
    Detaildatachange_byrowindexoperation(that.popupobj,'before','add',rowid-1,rowid);
    if (that.rowhtml != undefined && that.rowhtml != ''&&this.popupobj.module!="WorkSheet" ) {
        that.addSuccessRow(rowid);
        return '';
    }
    var tmprowindex = 20000;
    if (this.popupobj.module == "WorkSheet") {
        tmprowindex = rowid;
    }
    else
        ld('[name=row' + tmprowindex + ']').remove();//删除

    if (this.popupobj.createdtype == 'create' || this.popupobj.createdtype == 'quickcreate') {
        var page_mode = 'create';
    } else {
        var page_mode = 'edit';
    }

    var url = 'index.php?module=Users&action=UsersAjax&file=addProductDetailsRow&frommodule=' + this.cur_module + '&rowid='+tmprowindex+'&contract_display=' + contract_display + '&accvenid=' + that.accvenid + '&pagemode=' + page_mode;
    //工单管理特殊分录
    if (this.popupobj.module == 'WorkSheet') {
        if (this.popupobj.js_detailtablename == 'proTab') {
            url += '&producttype=part' + '&related_productid=' + this.popupobj.related_productid;
        } else {
            if (this.popupobj.selectproductobj.popup_selectsource == true) {
                var selected_module = ld("#" + this.popupobj.divid + " select[id=selectsource]").val();
                url += '&producttype=product' + '&selected_module=' + selected_module;
            }
        }
    }
    if (this.cur_module == 'CashBill' || this.cur_module == 'SendCashBill') {
        var selectsource = ld("#" + this.popupobj.divid).find('select[id=selectsource]').val();
        url += '&sourcemodule=' + selectsource;
    }
    ld.ajax({
        url: url,
        type: 'POST',
        data: '',
        async: false,//异步  否
        timeout: 20000,
        success: function (data) {
            if(that.popupobj.module!="WorkSheet")
            {
                ld("body").append(data);
                ld("tr[rowindex=20000]").attr(("id"), "productrow_20000");
                that.rowhtml = ld('#productrow_20000').prop("outerHTML");
            }
            else{
                that.rowhtml =data;
            }
            that.addSuccessRow(rowid);
        }
    });
}
fun_selectproduct.prototype.addSuccessRow = function (rowid) {
    var that = this;
    that.addRow_finished = true;
    var rowhtml = that.rowhtml;
    if(rowid % 2 == 0){
        rowhtml = rowhtml.replace('lvtColData dragtrrow', 'lvtColDataBj dragtrrow');
    }
    else{
        rowhtml = rowhtml.replace('lvtColDataBj dragtrrow', 'lvtColData dragtrrow');
    }
    that.rowhtml = rowhtml;
    that.insertRow(rowid, that.rowhtml);//加载布局规则字段


    //zkt 20230406 产品分录新增行-

    if(that.popupobj.fieldruleobj != undefined&&that.popupobj.detailfieldrulefieldnames!=undefined){
        if(that.popupobj.detailfieldrulefieldnames.length>0&&that.popupobj.detailfieldrulefieldnames[0]!='')
        {
            // that.popupobj.fieldruleobj.resetDetailColumns();//布局规则，重新设置分录表头的显示和隐藏
            if(that.popupobj.fieldformulaobj.ismasscount!='yes')
                that.popupobj.fieldruleobj.setTrContent();
        }

    }

    that.changeseqno();



    //BUG0054260 edit hzx,新建分录滚动条重新定位
    //var trobj = that.popupobj.getTrObjsByDelType('no');
    var rowcnt=eval(this.popupobj.detaildatavalue_arr.length);
    if (rowcnt == rowid) {
        var productdiv = ld("#" + that.popupobj.divid + " [name=productDiv]");
        if (productdiv.length > 0) {
            //zkt BUG0055830产品管理-新增产品出现下拉框时，再点击新增按钮，滚动条应该自动到最底下，而现在是到最上面,同（BUG0054711、BUG0055777、BUG0055064、BUG0055777）
            // productdiv.get(0).scrollTop = productdiv.get(0).scrollHeight;
        }
    }

    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（产品分录新增行）
    if (!empty(that.popupobj.detailimage_arr)) {
        for (var i = 0; i < that.popupobj.detailimage_arr.length; i++) {
            var fileuploader = ld("#" + that.popupobj.divid + " tr[rowindex=" + rowid + "] [detailfieldname=" + that.popupobj.detailimage_arr[i].fieldname + "] div[name=" + that.popupobj.detailimage_arr[i].fieldname + "]");
            // fileuploader.empty();//zxm 20230112 先将div中的内容清空 不然可能会出现多个上传按钮
            if (fileuploader.length > 0) {
                var uploadFile = new WebUploadFile();
                globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                uploadFile.setDetailEvent(globalWebUploadType, fileuploader, that.popupobj, i, rowid);
            }
        }
    }
    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录添加后
    Detaildatachange_byrowindexoperation(popupobj,'after','add',rowid-1,rowid);
    //放到mousemove事件中
    var rowobj = ld("#" + that.popupobj.divid + " [name=" + that.popupobj.js_detailtablename + "]").find("tr[rowindex=" + rowid + "]");
    that.showTooltipByTr(rowobj);
}


fun_selectproduct.prototype.insertRow = function (rowindex, rowhtml) {
    // var popupobj=CrmPopup.getPopupObj('first');
    var popupobj = this.popupobj;
    var that = this;
    popupobj.newrowhtml = rowhtml;
    var table_scrollTop = 0;
    var lasttr = false;
    if (popupobj.js_detailtablename == 'newproTab') {
        ld("#" + popupobj.divid + " [name=newproTab] > tbody > tr:eq(" + eval(rowindex) + ")").after(rowhtml);
        table_scrollTop = ld("#" + popupobj.divid + " [name=newproTab]").height();
        if((ld("#" + popupobj.divid + " [name=newproTab] > tbody > tr").length - 3) > eval(rowindex)){
            lasttr = false
        }else{
            lasttr = true
        }
    } else {
        ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(rowindex) + ")").after(rowhtml);
        table_scrollTop = ld("#" + popupobj.divid + " [name=proTab]").height();
        if((ld("#" + popupobj.divid + " [name=proTab] > tbody > tr").length - 3) > eval(rowindex)){
            lasttr = false
        }else{
            lasttr = true
        }
        var rowobj = ld("#" + popupobj.divid + " [name=proTab]").find("#productrow_20000");
        ld(rowobj).attr("rowindex", rowindex)
            .attr("name", "row" + rowindex).find("#td_seqno").html(rowindex);
        ld(rowobj).attr("id", '');
        // ld("#"+popupobj.divid+" [name=proTab] > tbody").html(ld("#"+popupobj.divid+" [name=proTab] > tbody").html()+rowhtml)
        that.fnAddProductTdBtn();
    }
    //BUG20241008-51  	有产品分录的单据比如销售订单--选择产品，点击新增的时候应该定位到最后一行
    if(lasttr){
        ld("#" + popupobj.divid + " [name=productDiv]").scrollTop(table_scrollTop);
    }


}

function ProductCopyRowAfterassingIndex(btn_jqueryobj) {
    //多选框导致clone 和html方式无法使用
    var popupobj = CrmPopup.getPopupObj('last');
    var iserror = 'no';
    ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {
        if (tmpfieldinfo.bigtype == 'selectsource') {
            var selectsourcemodule = ld("#" + popupobj.divid + ' [name=selectsource]').val();
            //edit:can 20210413 45456: （https://61mis.com/kfbcrm [^]）采购订单新建界面，点击产品分录中的【复制行】图标按钮，提示“请严格参照源单录入数据”
            var selectlistval = ld("#" + popupobj.divid + ' [name=selectlistval]').val();
            if (popupobj.sourcemodule_arr != undefined) {
                ld.each(popupobj.sourcemodule_arr, function (sourcemoduleindex, tmpsourcemoduleinfo) {
                    if (tmpsourcemoduleinfo.entitytype == selectsourcemodule) {
                        //ls 2022-06-27 采购管理》采购询价单，单据分录中复制 一直提示“请严格参照源单录入数据”（strictsourcebillcolums为空null时，判断错误）
                        if (!empty(tmpsourcemoduleinfo.strictsourcebillcolums) && tmpsourcemoduleinfo.strictsourcebillcolums != ',' && selectlistval != "") {
                            iserror = 'yes';
                            RemindsMsg("", "LdPopWidth400px", popupobj.module, "yes", "yes", arrJsPopLabel['StrictReferenceSourceBill']);
                        }
                    }
                })
            }
            return false;
        }
    })
    if (iserror == 'yes')
        return false;

    var rowobj = popupobj.getTrObjByChild(btn_jqueryobj);
    ProductAddRowAfterassingIndex(btn_jqueryobj);
    var rowid = parseInt(ld(rowobj).attr("rowindex"));
    var nextrowindex = parseInt(rowid) + 1;
    var copyrowobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]").find("tr[rowindex=" + nextrowindex + "]");

    if(popupobj.detaildatavalue_arr[rowid].batchtext!=undefined)
    {

        //先这样做，将来如果扩展优化循环td
        copyrowobj.find("#batchtext").css("display",  rowobj.find("#batchtext").css('display'));
        copyrowobj.find("#searchbatchtextIcon").css("display",  rowobj.find("#searchbatchtextIcon").css('display'));
        copyrowobj.find("#clearbatch").css("display",  rowobj.find("#clearbatch").css('display'));

    }

    setcopyrowvalue(rowobj, copyrowobj, popupobj, rowid, nextrowindex);
    popupobj.selectproductobj.setDataBind(copyrowobj);//数据绑定 zxm 空行也需要添加
    popupobj.selectproductobj.setrowobjbutton(rowid, ld(copyrowobj))
    //后台sql事件
    getRelatedProductToolFieldPrice(popupobj, nextrowindex);
    //popupobj.fieldformulaobj.CountsubTotalByRow(copyrowobj);//小计
    popupobj.fieldformulaobj.CountsubTotal();//小计
    //分类计算主表字段
    popupobj.detail2mainformulaobj.changeRowEvent();
    popupobj.SetDetailFieldControl(rowid);
    popupobj.fieldformulaobj.setAllRowEvent();

    //duan 20240926 整行操作后调用公共变化事件
    popupobj.common_field_event_obj.setAllEntryEvent();
    popupobj.common_field_event_obj.common_all_entry_changefun(rowid);
    //DisCountFocusShowMess(popupobj);	//光标定位在折扣率字段上，显示温馨提示信息
}

//分录复制
function setcopyrowvalue(rowobj, copyrowobj, popupobj, rowid, nextrowindex) {
    ld(copyrowobj).attr("havemouseevent", '');
    ld.each(popupobj.detailfields, function (tmpindex, tmpfieldinfo) {
        var tmpfieldname = tmpfieldinfo.fieldname;
        popupobj.detaildatavalue_arr[nextrowindex-1][tmpfieldname] = popupobj.detaildatavalue_arr[rowid-1][tmpfieldname] ;
        //zxm 20230926复制的分录单据没有跟源单分录关联
        if(tmpfieldname=='entitytypeid'){
            popupobj.detaildatavalue_arr[nextrowindex-1]['parent_lineitem_id'] = popupobj.detaildatavalue_arr[rowid-1]['parent_lineitem_id'] ;
        }
        //duan 20231023 不可编辑的字段，需要额外读取_name变量
        if(!empty(popupobj.detaildatavalue_arr[rowid-1][tmpfieldname+'_name'])){
            popupobj.detaildatavalue_arr[nextrowindex-1][tmpfieldname+'_name'] = popupobj.detaildatavalue_arr[rowid-1][tmpfieldname+'_name'];
        }
    });
    popupobj.detaildatavalue_arr[nextrowindex-1]['productid'] = popupobj.detaildatavalue_arr[rowid-1]['productid'] ;
    // hzx 复制批次特殊处理 BUG0073326
    /*if(ld(rowobj).find('input[type=text][detailcolumnname=batchtext]:visible').length > 0){
        var tmp_tdhtml = ld(rowobj).find('input[type=text][detailcolumnname=batchtext]').parent().html();
        ld(copyrowobj).find('td[detailfieldname=batchtext]').html(tmp_tdhtml);
    }*/
    /*ld.each(ld(rowobj).find("span"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        if (detailcolumname != undefined)
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").html(ld(this).html());

    });

    ld.each(ld(rowobj).find("textarea"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").val(ld(this).val());

    })
    ld.each(ld(rowobj).find("[type=text]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        if (detailcolumname != undefined) {
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").val(ld(this).val());
        }
        else {
            var name = ld(this).attr("name");
            if (name != undefined)
                ld(copyrowobj).find("[name=" + name + "]").val(ld(this).val());
        }

    })
    ld.each(ld(rowobj).find("[type=checkbox]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");

        ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").prop("checked", ld(this).prop("checked"));
    })
    ld.each(ld(rowobj).find("[type=hidden]"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        if (detailcolumname != undefined)
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").val(ld(this).val());
        else {
            var name = ld(this).attr("name");
            if (name != undefined)
                ld(copyrowobj).find("[name=" + name + "]").val(ld(this).val());
        }

    })
    ld.each(ld(rowobj).find("select"), function () {
        var detailcolumname = ld(this).attr("detailcolumnname");
        var multiple = ld(this).attr("multiple");

        if (multiple == undefined)
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").val(ld(this).val());
        else {
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").val(ld(this).val());
            ld(copyrowobj).find("[detailcolumnname=" + detailcolumname + "]").select2({
                closeOnSelect: true,
                dropdownParent: ld("#" + popupobj.divid)
            });
        }

    })*/

    //ls 2022/07/19 XUQIU1000474  当产品模块多图片字段时，分录引用产品图片属性，应根据字段区分显示(复制分录行时)
    if (popupobj.allproductimagefieldname != undefined && popupobj.allproductimagefieldname != 'undefined') {
        ld.each(popupobj.allproductimagefieldname, function (key, columnname) {
            // if(ld(rowobj).find("span[name=span_"+columnname+"_"+rowid+"]").length>0)//产品图片
            getproductImageName(ld(rowobj).find("[detailcolumnname=hdnProductId]").val(), nextrowindex, columnname);//无序复制行的时候，可能存在跳号，所以去掉根据rowid行的判断条件。
        })
    }
}

function ProductAddRowAfterassingIndex(btn_jqueryobj) {
    var popupobj = CrmPopup.getPopupObj('last');

    popupobj.selectproductobj.getMethod();
    var rowobj = popupobj.getTrObjByChild(btn_jqueryobj);
    var rowid = parseInt(ld(rowobj).attr("rowindex")) + 1;
    //在指定位置增加一个值  复制的时候需要这么处理
    var tmpprefix_detaildatavalue_arr = popupobj.detaildatavalue_arr.slice(0,rowid-1);
    var tmpsuffix_detaildatavalue_arr = popupobj.detaildatavalue_arr.slice(rowid-1);
    popupobj.detaildatavalue_arr = tmpprefix_detaildatavalue_arr;
    popupobj.detaildatavalue_arr.push(popupobj.selectproductobj.getDetailDataValues());//添加一行数据绑定 zxm 空行也需要添加


    popupobj.selectproductobj.AddRowByRowIndex(rowid);
    //BUG0078361 ls 20240108 运杂费模块设置默认产品只对第一行分录生效，后续分录显示的是数字
    for (var i = 0; i < popupobj.detailfields.length; i++) {
        //设置新增行产品的默认值
        if (popupobj.detailfields[i].columnname == 'productname' && popupobj.detailfields[i].defaultvalue > 0) {
            //默认新增多行，所有循环
            fun_selectproduct.setProductDefaultValue(rowid, popupobj.detailfields[i].defaultvalue);
            break;
        }
    }


    var  newrowobj = popupobj.getDetailTableObj().find("tr[rowindex="+rowid+"]")
    popupobj.selectproductobj.setDataBind(newrowobj);//数据绑定 zxm 空行也需要添加
    if(tmpsuffix_detaildatavalue_arr.length>0){
        for(var i=0;i<tmpsuffix_detaildatavalue_arr.length;i++){
            popupobj.detaildatavalue_arr.push(tmpsuffix_detaildatavalue_arr[i]);
        }
    }
    //给所有行 havemouseevent =no
    //edit:can 20230908 72304 今天又出现一个 单据号XSDD20230824-817，错误如下截图三，有一行就不计算，目前已手工更改为正确的，
    ld(popupobj.getDetailTableObj()).find("tr[havemouseevent=yes]").attr("havemouseevent",'no');

    // popupobj.selectproductobj.fnAddProductTdBtn();
    //popupobj.selectproductobj.changeseqno();

    //第二行连续点击新增按钮，则第四行字段公式不计算
    //popupobj.fieldformulaobj.setAllRowEvent();
    // popupobj.fieldformulaobj.setEvent(rowid);//给新增的行单元格添加事件
    //DisCountFocusShowMess(popupobj);	//光标定位在折扣率字段上，显示温馨提示信息
    //versiontype  yuanmei 特殊控制

    if (this.popupobj.ordertype_onclick != undefined && this.popupobj.ordertype_onclick != '' && this.popupobj.ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined) {
        setProductToolFieldDisplay('create', this.popupobj);
    }

    setInventoryPickListContent(popupobj);
    //设置明细字段的多选框和单选框
    popupobj.SetDetailFieldControl(rowid);


}
fun_selectproduct.prototype.setHtmlObj=function()
{
    if(this.popupobj === undefined) {
        console.error(new Error('popupObj is undefined'));
    }
    var popupObj = this.popupobj,
        popupJqObj = ld("#"+popupObj.divid);
    this.versionhtmlobj= popupJqObj.find(" [name=version_account]");
    this.rowcntobj = popupJqObj.find(" [name=rowcnt]");
    this.operation_rowobj = popupJqObj.find(" [name=operation_row]")
    this.module_nullfieldobj = popupJqObj.find(" [name=module_nullfield]");
    this.totalobj = popupJqObj.find(" [name=total]");
    this.adjustmentTypeobj = popupJqObj.find(" [name=adjustmentType]")
    this.subtotalobj = popupJqObj.find(" [name=subtotal]");
    this.adjustmentobj = popupJqObj.find(" [tag=maintablefield_adjustment]");
    this.discount_amountobj = popupJqObj.find(" [tag=maintablefield_discount_amount]");

    this.grandTotalobj = popupJqObj.find(" [name=grandTotal]");
    this.wareobj = popupJqObj.find(" [name=wareid]");
    this.inventory_currencyobj = popupJqObj.find(" [name=inventory_currency]");
    this.selectlistvalobj = popupJqObj.find(" [name=selectlistval]");
    this.selectlistval_labelobj = popupJqObj.find(" [name=selectlistval_label]");
    this.vendor_idobj = popupJqObj.find(" [name=vendor_id]");
    this.accountidobj = popupJqObj.find(" [name=account_id]");
    this.quoteidobj = popupJqObj.find(" [name=quote_id]");

    this.productLicencePriceObj = popupJqObj.find("[name=product_licence_price]");
    this.productLicencePriceSpanObj = popupJqObj.find("[name=span_product_licence_price]");
    this.cumulativeBenefitsObj = popupJqObj.find("[name=cumulative_benefits]");
    this.cumulativeBenefitsSpanObj = popupJqObj.find("[name=span_cumulative_benefits]");
}
fun_selectproduct.prototype.setPopupobj = function (popupobj) {
    this.popupobj = popupobj;
    this.setHtmlObj();
}
//给行添加操作列   上下移动+删除按钮
fun_selectproduct.prototype.fnAddProductTdBtn = function () {
    var that = this;
    if (that.massaddrow == 'yes')
        return;
    //郎捷开发需求：费用单分录不允许增、删、移动行
    if (that.cur_module == 'CustomForm18'&&ld(this.versionhtmlobj).val() != undefined && ld(this.versionhtmlobj).val() == 'langjie' ) {
        return '';
    }
    var popupobj = that.popupobj;


    //duan 20221116 泰康特殊开发需求，销售订单（自定义表单16）源单选择活动套餐（自定义表单17）时，设置分录不可修改
    if (account_version == 'taikang' && that.cur_module == 'CustomForm16') {
        var selectsourcemodule = ld("#" + popupobj.divid + ' [name=selectsource]').val();
        var selectlistval = ld(that.selectlistvalobj).val();
        var detail_edit = 'yes';
        if (selectsourcemodule == 'CustomForm17' && !empty(selectlistval)) {
            detail_edit = 'no';
            ld("#" + popupobj.divid + " [tag=sourcehidebutton]").hide();
        } else {
            detail_edit = 'yes';
            ld("#" + popupobj.divid + " [tag=sourcehidebutton]").show();
        }
    }

    var isdel = 'no';
    ld.each(popupobj.productfieldinfo['fields'], function (tmpindex, tmpitem) {
        if (tmpitem.edit_permission != 3 && tmpitem.newline != 1) {
            //edit:can 20220320 50655: (https://81mis.com/kfbcrm/index.php [^])设置审批结束后可编辑单据指定字段，指定成员除可编辑指定字段外，还可删除产品
            isdel = 'yes';
            return false;
        }

    })

    if (ld(this.rowcntobj).val() != undefined) {
        //明细没有操作列
        if (ld(this.operation_rowobj).val() != undefined) {
            if (ld(this.operation_rowobj).val() == 1) {
                return;
            }
        }
        var sum_row = 0;
        var row_hidden_array = Array();
        //var count = CrmPopup.findHtmlobj(this.popupobj.divid,'rowcnt').val();
        var trobjs = this.popupobj.getTrObjsByDelType('no');

        var k = 0;

        var Tr;
        var iPrevCount, seqno;

        var CopyRowhtml = '<span class="icon-homeimg icon-copy marR8" title="' + commonLabels.CopyRows + '" onclick="ProductCopyRowAfterassingIndex(ld(this))"></span>';
        //金蝶运行空库存需求
        var SearchProStock = '';
        if (search_stock_view != undefined && search_stock_view != 'undefined' && search_stock_view != 'no') {
            if (search_stock_view == 'CRM+ERP') {
                var SearchProStock = '<span class="icon-homeimg icon-stock marL6 operatetool_more" title="' + arrJsPopLabel['SEARCHINVENTORY'] + '"><ol class="operatetool_more_content"><li onclick="search_pro_stock(this,0)" tag="CRM">CRM' + arrJsPopLabel['INVENTORY'] + '</li><li onclick="search_pro_stock(this,0)" tag="ERP">ERP' + arrJsPopLabel['INVENTORY'] + '</li></ol></span>';
            } else {
                var SearchProStock = '<span class="icon-homeimg icon-stock marL6 operatetool_more" title="' + arrJsPopLabel['SEARCHINVENTORY'] + '" onclick="search_pro_stock(this,0)" tag="' + search_stock_view + '"></span>';
            }
        }
        if(that.popupobj.detaildatavalue_arr != undefined){
            var trlength = that.popupobj.detaildatavalue_arr.length;
        }
        else{
            var trlength = ld(trobjs).length;
        }

        var tdobj_width = "30mm";
        var that=this;

        ld(trobjs).unbind("mouseenter").bind("mouseenter", function () {//mouseenter
            var trobj = ld(this);

            if (ld(this).attr("havemouseevent") == 'yes' ) {
                var rowindex=ld(trobj).attr("rowindex");
                if(ld(trobj).find("#span_seq_no").length>0)
                {

                    if(that.popupobj.detaildatavalue_arr[rowindex - 1].span_seq_no==undefined)
                    {
                        var DataHtmlBindobj = new DataHtmlBind();
                        DataHtmlBindobj.istype='html';
                        DataHtmlBindobj.setJqueryObj(ld(trobj).find("#span_seq_no"));
                        DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'span_seq_no')
                    }
                }
                else{
                    //  that.setrowobjbutton(parseInt(ld(trobj).attr("rowindex")) - 1, ld(trobj))
                }

                if(ld(trobj).find("#td_seqno").length>0&&ld(trobj).find("#span_seq_no").length<=0)
                {

                    if(that.popupobj.detaildatavalue_arr[rowindex - 1].td_seqno==undefined)
                    {
                        var DataHtmlBindobj = new DataHtmlBind();
                        DataHtmlBindobj.istype='html';
                        DataHtmlBindobj.setJqueryObj(ld(trobj).find("#td_seqno"));
                        DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'td_seqno')
                    }
                }
                return;
            }

            that.onmouseevent(ld(this));


        })


        /*})*/

        if (trlength > 1) {
            //zkt 20230315 增加行后第一行不显示添加行复制行按钮
            /*var tmprowobj= ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2)');
           ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2) > td[seqno=yes]').html("<span span_seq_no='yes' id='span_seq_no' style='display:block;'>"+ '1</span><div class="divCursor" dv_operatetool="yes" style="display:none;">' +
           '<span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows + '" onclick="ProductAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
           + '"></a><span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows + '" style="cursor:move;"></span>' + SearchProStock + '</div>');

             if(popupobj.detaildatavalue_arr!=undefined&&popupobj.detaildatavalue_arr[ld(tmprowobj).attr("rowindex")]!=undefined)
               {
                    var DataHtmlBindobj = new DataHtmlBind();
                   DataHtmlBindobj.setJqueryObj(ld(tmprowobj).find("#span_seq_no"));
                   DataHtmlBindobj.setDataBindByJqueryObj(popupobj.detaildatavalue_arr[ld(tmprowobj).attr("rowindex") - 1], 'span_seq_no')
               }*/
        } else if (trlength == 1) {
            /* var tmprowobj= ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2)');
             ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2) > td[seqno=yes]').html('<span span_seq_no="yes" id="span_seq_no" style="display:block">1</span><div class="divCursor" dv_operatetool="yes" style="display:none;"><span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows + '" onclick="ProductAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + SearchProStock + '</div>');
             if (isdel == 'no') {
                 ld('#' + popupobj.divid + ' table[name="proTab"]').find("[tag=btn_del]").css('display', 'none');

             }
             if( popupobj.detaildatavalue_arr!=undefined&&popupobj.detaildatavalue_arr[ld(tmprowobj).attr("rowindex")]!=undefined)
             {
                  var DataHtmlBindobj = new DataHtmlBind();
                 DataHtmlBindobj.setJqueryObj(ld(tmprowobj).find("#span_seq_no"));
                 DataHtmlBindobj.setDataBindByJqueryObj(popupobj.detaildatavalue_arr[ld(tmprowobj).attr("rowindex") - 1], 'span_seq_no')
             }*/
        } else {
            //ld("#" + popupobj.divid + ' [name=proTab] > tbody > tr:eq(2) > td[seqno=yes]').html('');
        }
        var rowobj=ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2)');
        ld(rowobj).attr("rowindex", 1).attr("row",1).attr("name","row"+1);
        //ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2)').attr("row", 1);
        //ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2)').attr("name", "row" + 1);

        ld('#' + popupobj.divid + ' table[name="proTab"]:first > tbody > tr:eq(2) > td[seqno=yes]').css('text-align', 'center');
        //20230608 分录新增行后增加提示信息

    }

    ///SetDiscountPercent(popupobj);
    //
}
fun_selectproduct.prototype.onmouseevent=function(trobj)
{
    var that=this;
    var popupobj = that.popupobj;
    //edit: xll 2023/02/27 XUQIU1000546 Ctrl+Enter快速填充单据同列字段（“整数”、“数字”、“数量”、“单价”、“金额”、“百分比”字段）
    ld.each(popupobj.detailfields,function(tmpindex,tmpinfo){
        //wsh 2024-07-17 XUQIU1001940 单据分录定制，“文本”、“文本区域”、“日期”和“多选框”字段，分录明细行增加快速填充字段功能（史星磊、陈钦帅）
        var bigtype_arr = ['num','currency','int','number','price','amount','multipicklist','textarea','text','date','tax'];
        var columnname_arr = ['discount_percent','tax_added','contractid'];
        if(bigtype_arr.includes(tmpinfo.bigtype) || columnname_arr.includes(tmpinfo.columnname)){
            SetBillData(popupobj,trobj,tmpinfo.columnname);
        }
    })
    ld(trobj).attr("havemouseevent", 'yes');
    var rowindex = parseInt(ld(trobj).attr("rowindex"));
    that.setrowobjbutton(parseInt(ld(trobj).attr("rowindex")) - 1, ld(trobj))
    that.setDataBind(ld(trobj));
    that.showTooltipByTr(ld(trobj));
    //edit:can BUG20241030-60
   // popupobj.SetDetailFieldControl(rowindex)
    UpDownPointFocus(popupobj);
    //edit:can 20230208 61450  	公司自用账套->企业微信服务合同(CustomForm13),编辑时没有调用ld_related_producttoolfield


    getRelatedProductToolFieldPrice(popupobj,rowindex);
    popupobj.RelatedProductToolFieldtriggcols=[];
}
fun_selectproduct.prototype.setDataBind = function (trobj) {

    var that = this;
    var tmpjqueryobj;
    var bindobj_arr = [];
    var rowindex = ld(trobj).attr("rowindex");

    if (that.popupobj.detaildatavalue_arr[rowindex - 1] == undefined || that.popupobj.detaildatavalue_arr[rowindex - 1].databind == 'yes')
        return;

    ld.each(that.popupobj.noprofiledetailfields,function(tmpindex,tmpinfo){

        var DataHtmlBindobj = new DataHtmlBind();
        tmpjqueryobj = ld(trobj).find("#" + tmpinfo.columnname);
        DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
        DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)

    })

    ld.each(that.popupobj.detailfields, function (tmpindex, tmpinfo) {
        var DataHtmlBindobj = new DataHtmlBind();
        if (tmpinfo.savedatabase == 'no') {
            tmpjqueryobj = ld(trobj).find("#span_" + tmpinfo.columnname);
            DataHtmlBindobj.istype='html';

            if(tmpjqueryobj.length>0){
                DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                if(tmpinfo.uitype==220){
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname+'_name')
                }
                else{
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }
            }
            return true;
        }
        if(tmpinfo.columnname == 'entitytype' || tmpinfo.columnname == 'entitytypeid')
        {
            tmpjqueryobj = ld(trobj).find("#span_" + tmpinfo.columnname);
        }
        else
        {
            tmpjqueryobj = ld(trobj).find("#" + tmpinfo.columnname);

        }

        DataHtmlBindobj = new DataHtmlBind();
        if (tmpinfo.columnname == 'productname') {
            tmpjqueryobj = ld(trobj).find("#hdnProductId");
            if(tmpjqueryobj.length>0){
                DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                bindobj_arr.push({"htmlobj": tmpjqueryobj, 'keyname': 'productid'})
                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='hidden';
                DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'productid')
            }
            DataHtmlBindobj = new DataHtmlBind();
            tmpjqueryobj = ld(trobj).find("#productname");
            if(tmpjqueryobj.length>0){
                DataHtmlBindobj.setJqueryObj(tmpjqueryobj);
                //zkt 20231031 BUG0074717 （汇能）云星辰版，合同订单中选择报价单带出产品后，产品名称为空，保存之后才会显示（客户名称：测试用户 可用来测试）
                DataHtmlBindobj.istype='input';
                if(tmpinfo.edit_permission == 1 ||tmpinfo.edit_permission == 3){
                    DataHtmlBindobj.istype='html';
                }
                DataHtmlBindobj.type='text';
                DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'productname')
            }
        } else if (tmpinfo.columnname == 'adjustment' || (tmpinfo.columnname == 'discount_amount'&&tmpinfo.tablename!=that.popupobj.detailtablename)) {

        } else {

            if (tmpinfo.edit_permission == 2) {
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype='input';
                    DataHtmlBindobj.type='hidden';
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }

                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find("#span_" + tmpinfo.columnname);
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype='html';
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_name");
                }

            }
            else  if((tmpinfo.edit_permission==3||tmpinfo.edit_permission==1)&&
                tmpinfo.uitype!=200 &&tmpinfo.uitype!=202&&tmpinfo.uitype!=204 &&tmpinfo.uitype!=201)
            {
                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='hidden';
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }

                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find("#span_" + tmpinfo.columnname);
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'html';

                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_name");
                }

            }
            else  if (tmpinfo.uitype == 100) {
                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='hidden';
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }
                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find("#" + tmpinfo.columnname + "_name");
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'input';
                    DataHtmlBindobj.type = 'text';
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_name")
                }
            }
            else if(tmpinfo.uitype==60 &&tmpinfo.columnname=='wareid')
            {
                //仓库

                DataHtmlBindobj = new DataHtmlBind();
                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='hidden';
                tmpjqueryobj = ld(trobj).find("#" + tmpinfo.columnname );
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_rawvalue")
                }

                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find(" [name=cmb_span_optiontext_wareid]" );

                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='text';
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname )
                }
            }
            //zkt 20230526 BUG0067206  kfbcrm 自定义表单11---新建选择源单 合同----分录 下拉框字段的值没有带出来
            else if(tmpinfo.uitype==60 )
            {
                //下拉框

                DataHtmlBindobj = new DataHtmlBind();
                DataHtmlBindobj.istype='input';
                DataHtmlBindobj.type='hidden';
                tmpjqueryobj = ld(trobj).find("#" + tmpinfo.columnname );
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname);
                }
                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find(" [name=cmb_span_optiontext_"+tmpinfo.columnname+"]" );
                if(tmpjqueryobj.length>0){
                    DataHtmlBindobj.istype='input';
                    DataHtmlBindobj.type='text';

                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    //zkt 20240415 BUG20240415-27  蝶创：分录下拉款输入其他值可以保存
                    //zkt 20240718 BUG20240701-59 点击分录单据中复制行按钮，下拉框的数据没有被复制到新数据中
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname+'_name' )
                }

            }
            else if (tmpinfo.columnname == 'entitytype' || tmpinfo.columnname == 'entitytypeid') {
                //edit:can 20230228 66290 四川中兴；通过【销售合同】相关页签新建【发货通知单】，分录字段”仓库“无法保存!
                //DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                //DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                // alert(that.popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname]);
                if(that.popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname]==undefined)
                    that.popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname]='';
                DataHtmlBindobj = new DataHtmlBind();
                tmpjqueryobj = ld(trobj).find("#span_" + tmpinfo.columnname);
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'html';
                    if(tmpinfo.columnname=='entitytype')
                    {
                        DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_transmodule")
                    }
                    else
                        DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname + "_name")
                }
            }
            else if(tmpinfo.uitype==2 &&tmpinfo.bigtype=='textarea')
            {
                if(tmpjqueryobj.length>0) {
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'textarea';

                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }
            }
            else if(tmpinfo.uitype==63)
            {
                if(tmpjqueryobj.length>0) {
                    //edit can 20230516 65823 检测委托书里面选择产品后，选不到检测项目；
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'select';

                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }
            }
            else if(tmpinfo.uitype==56)
            {
                if(tmpjqueryobj.length>0) {
                    //BUG0075172 lius 成都秦川；发货通知单>新建>选着源单编号：OR15058 ，分录字段"是否赠品"没有被带过来(复选框)
                    DataHtmlBindobj.setDataBindByJqObj(tmpjqueryobj, that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname);
                }
            }
            else{
                if(tmpjqueryobj.length>0) {
                    //edit:can 20230228 66290 四川中兴；通过【销售合同】相关页签新建【发货通知单】，分录字段”仓库“无法保存!
                    DataHtmlBindobj.setJqueryObj(tmpjqueryobj)
                    DataHtmlBindobj.istype = 'input';
                    DataHtmlBindobj.type = 'text';
                    DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], tmpinfo.columnname)
                }
            }
        }
    })
    if (that.popupobj.detaildatavalue_arr[rowindex - 1]['parent_lineitem_id'] == undefined) {
        that.popupobj.detaildatavalue_arr[rowindex - 1]['parent_lineitem_id'] = 0;
    }

    if (that.popupobj.detaildatavalue_arr[rowindex - 1]['lineitem_id'] == undefined) {
        that.popupobj.detaildatavalue_arr[rowindex - 1]['lineitem_id'] = 0;
    }


    if (that.popupobj.detaildatavalue_arr[rowindex - 1]['productbomid'] == undefined) {

    }
    if (that.popupobj.detaildatavalue_arr[rowindex - 1]['productbomquantity'] == undefined) {

        that.popupobj.detaildatavalue_arr[rowindex - 1]['productbomquantity'] = 0;
    }
    if (that.cur_module == 'WorkSheet') {
        /*
        var DataHtmlBindobj = new DataHtmlBind();
        tmpjqueryobj = ld(trobj).find("#relatedProductId");
        if(tmpjqueryobj.length>0) {
            DataHtmlBindobj.setJqueryObj(tmpjqueryobj);
            DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'relatedProductId')
        }
         */
    }

    if(ld(trobj).find("#span_seq_no").length>0)
    {
        var DataHtmlBindobj = new DataHtmlBind();
        DataHtmlBindobj.istype='html';
        tmpjqueryobj = ld(trobj).find("#span_seq_no");
        if(tmpjqueryobj.length>0) {
            DataHtmlBindobj.setJqueryObj(tmpjqueryobj);
            DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'span_seq_no')
        }
    }
    else if(ld(trobj).find("#td_seqno").length>0)
    {
        var DataHtmlBindobj = new DataHtmlBind();
        DataHtmlBindobj.istype='html';
        tmpjqueryobj = ld(trobj).find("#td_seqno");
        if(tmpjqueryobj.length>0) {
            DataHtmlBindobj.setJqueryObj(tmpjqueryobj);
            DataHtmlBindobj.setDataBindByJqueryObj(that.popupobj.detaildatavalue_arr[rowindex - 1], 'td_seqno')
        }
    }
    that.popupobj.detaildatavalue_arr[rowindex - 1].databind = 'yes';

}
fun_selectproduct.prototype.getDetailDataValues = function () {
    var that = this;
    var detaildatavalue = {};
    ld.each(that.popupobj.noprofiledetailfields, function (tmpindex, tmpinfo) {
        //if(tmpinfo.savedatabase=='no' )
        //  return true;

        // detaildatavalue[tmpinfo.columnname] = '';
    })
    ld.each(that.popupobj.detailfields, function (tmpindex, tmpinfo) {
        //if(tmpinfo.savedatabase=='no' )
        //  return true;
        detaildatavalue[tmpinfo.columnname] = '';
    })
    detaildatavalue.parent_lineitem_id = 0;
    detaildatavalue.lineitem_id = 0;
    detaildatavalue.productbomid = 0;
    detaildatavalue.productbomquantity = 0;
    detaildatavalue.htmlisload = 'yes';
    detaildatavalue.trrowindex = that.popupobj.detaildatavalue_arr.length;
    return detaildatavalue;
}
//重置单据分录的行号和rowindex
fun_selectproduct.prototype.changeseqno = function () {

    if (this.popupobj.fieldformulaobj.ismasscount == 'yes') {

        return false;
    }

    var trobjs = this.popupobj.getTrObjsByDelType('no');
    var seqno = 1;
    var len = ld(trobjs).length;
    for (var i = 0; i < len; i++) {
        seqno = parseInt(i) + 1;
        var rowobj = trobjs[i];
        ld(rowobj).attr("rowindex", seqno);
        ld(rowobj).attr("name", "row" + seqno);

        //zkt 20230731 BUG0070319 分录合计计算错误
        if(this.popupobj.detaildatavalue_arr != undefined && this.popupobj.detaildatavalue_arr.length>i)
        {
            ld(rowobj).attr('havemouseevent','no');//序号重新赋值后需要重新添加序号列按钮div

            if(this.popupobj.detaildatavalue_arr[i].span_seq_no!=undefined)
                this.popupobj.detaildatavalue_arr[i].span_seq_no=seqno
            else{
                this.popupobj.detaildatavalue_arr[i].td_seqno=seqno
            }

        }
        else{
            var tdobj = ld(rowobj).find("#td_seqno");
            var spanobj = ld(rowobj).find("#span_seq_no");
            if (ld(spanobj).length == 0) {
                ld(tdobj).html(seqno);
            } else {
                ld(spanobj).html(seqno);
            }
        }
        //BUG0076795 wym 231206 产品分录新增行，需要需改产品图片字段的id和name中的rowid值
        if (this.popupobj.allproductimagefieldname != undefined && this.popupobj.allproductimagefieldname != 'undefined') {
            ld.each(this.popupobj.allproductimagefieldname, function (key, columnname) {
                var imageobj= ld(rowobj).find("[name=productdetails_input_"+columnname+"]");
                if(ld(imageobj).length > 0){
                    var image_span_obj= ld(imageobj).find("span");
                    if(ld(image_span_obj).length > 0){
                        image_span_obj.attr('id','span_'+columnname+'_'+seqno);
                        image_span_obj.attr('name','span_'+columnname+'_'+seqno);
                    }
                }
            })
        }

    }
}
fun_selectproduct.prototype.setrowobjbutton = function (tmprowindex, rowobj) {


    var trobjs = this.popupobj.getTrObjsByDelType('no');
    var trlength = ld(trobjs).length;

    var isdel = 'no';
    ld.each(this.popupobj.productfieldinfo['fields'], function (tmpindex, tmpitem) {
        if (tmpitem.edit_permission != 3 && tmpitem.newline != 1) {
            //edit:can 20220320 50655: (https://81mis.com/kfbcrm/index.php [^])设置审批结束后可编辑单据指定字段，指定成员除可编辑指定字段外，还可删除产品
            isdel = 'yes';
            return false;
        }

    })
    var iPrevCount, seqno;

    var CopyRowhtml = '<span class="icon-homeimg icon-copy marR8" title="' + commonLabels.CopyRows + '" onclick="ProductCopyRowAfterassingIndex(ld(this))"></span>';
    //金蝶运行空库存需求
    var SearchProStock = '';
    if (search_stock_view != undefined && search_stock_view != 'undefined' && search_stock_view != 'no') {
        if (search_stock_view == 'CRM+ERP') {
            var SearchProStock = '<span class="icon-homeimg icon-stock marL6 operatetool_more" title="' + arrJsPopLabel['SEARCHINVENTORY'] + '"><ol class="operatetool_more_content"><li onclick="search_pro_stock(this,0)" tag="CRM">CRM' + arrJsPopLabel['INVENTORY'] + '</li><li onclick="search_pro_stock(this,0)" tag="ERP">ERP' + arrJsPopLabel['INVENTORY'] + '</li></ol></span>';
        } else {
            var SearchProStock = '<span class="icon-homeimg icon-stock marL6 operatetool_more" title="' + arrJsPopLabel['SEARCHINVENTORY'] + '" onclick="search_pro_stock(this,0)" tag="' + search_stock_view + '"></span>';
        }
    }
    var tdobj_width = "30mm";
    var that = this;
    iPrevCount = parseInt(tmprowindex) + 1;
    ld(rowobj).attr("rowindex", iPrevCount);//拖动重新定义行号
    ld(rowobj).attr("row", iPrevCount);//历史遗留，暂时保留
    ld(rowobj).attr("name", "row" + iPrevCount);//历史遗留，暂时保留
    seqno = iPrevCount;

    if (that.cur_module == 'Quotes' && account_version == 'haige') {
        var havaordercountobj = ld(tmprowobj).find(" [name=haveordercount]");
        if (ld(havaordercountobj).length > 0 && ld(havaordercountobj).val() != "" && eval(ld(havaordercountobj).val()) > 0) {
            return true;

        }
    }
    var rowindex = ld(rowobj).attr(("rowindex"));
    that.popupobj.fieldformulaobj.setEvent(rowindex);
    getRelatedProductToolFieldPrice(that.popupobj,rowindex);
    //duan 20240926 分录绑定公共切换事件
    that.popupobj.common_field_event_obj.setEntryEvent(rowindex);


    var tmprowobj = rowobj;
    var tdobj = ld(tmprowobj).find("#td_seqno");
    //duan 20221116 泰康特殊开发需求，销售订单（自定义表单16）源单选择活动套餐（自定义表单17）时，设置分录不可修改
    if (account_version == 'taikang' && that.cur_module == 'CustomForm16') {
        var selectsourcemodule = ld("#" + that.popupobj.divid + ' [name=selectsource]').val();
        var selectlistval = ld("#" + that.popupobj.divid + ' [name=selectlistval]').val();
        var detail_edit = 'yes';
        if (selectsourcemodule == 'CustomForm17' && !empty(selectlistval)) {
            detail_edit = 'no';
            ld("#" + that.popupobj.divid + " [tag=sourcehidebutton]").hide();

            var tdobj = ld(tmprowobj).find("td[seqno=yes]");
            tdobj.html('<span style="width: 30mm; display: block;">' + iPrevCount + '</span>');
            return true;
        } else {
            detail_edit = 'yes';
            ld("#" + that.popupobj.divid + " [tag=sourcehidebutton]").show();
        }
    }

    // var tdobj_width="25mm";//ld(tdobj).css("width");
    //zkt 20230330 BUG0062390  61order “销售订单”新建界面，单据分录添加多行，“序号”列没有对齐 去除width:" + tdobj_width + ";，后续观察
    var styleArr = ['display:block'];
    var rowVal = that.popupobj.detaildatavalue_arr ? that.popupobj.detaildatavalue_arr[iPrevCount-1] : undefined;
    if(rowobj.attr('present') !== undefined || (rowVal && rowVal.is_present === 'yes')) {
        rowobj.find('#td_seqno').css('--span-extralContent','');
        styleArr.push(`--span-extralContent: '（赠品）'`);
    }
    var spanSeqNo = `<span class="ld-text-inner ld-text-inner-first span_seq_no" span_seq_no="yes" id="span_seq_no" style="${styleArr.join(';')}">${seqno}</span>`;
    if (tmprowindex == 0) {
        if(that.popupobj.showproductbtn == 'no'){ //BUG0069554 xxy 2023-7-24 审批流程定制，设置审批结束允许编辑单据时，已批准的单据编辑界面，去掉单据分录明细的“新增、复制、删除、导入明细、清空、重算”操作按钮（移动端同步修改）
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;">'
                + '<span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }else{
            //edit:can 2020-09-24 单据分录明细中增加拖动功能
            //zkt 20211009 0045342: （61mis.com/kfbcrm）销售管理-合同订单-新建；产品分录中，有2行以上分录时，第一行产品分录应显示 “删除行”图标
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;">' +
                '<span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows + '" onclick="ProductAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
                + '"></a><span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }

    } else if (tmprowindex == trlength - 1) {
        if(that.popupobj.showproductbtn == 'no'){
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;">'
                + '<span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows
                + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }else{
            //edit:can 2020-09-24 单据分录明细中增加拖动功能
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;"><span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows
                + '" onclick="ProductAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
                + '" ></a><span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows
                + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }
    } else {
        if(that.popupobj.showproductbtn == 'no'){
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;">'
                + '<span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }else{
            //edit:can 2020-09-24 单据分录明细中增加拖动功能
            ld(tdobj).html(spanSeqNo + '<div class="divCursor ld-text-inner ld-text-inner-first" dv_operatetool="yes" style="display:none;"><span class="icon-layout3 icon-layout3-add" title="' + commonLabels.AddRows + '"  onclick="ProductAddRowAfterassingIndex(ld(this))"></span>' + CopyRowhtml + '<a tag="btn_del" class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(' + iPrevCount + ')" title="' + commonLabels.DeleteRows
                + '"></a><span class="drag-handle icon-layout2 icon-layout2-move" title="' + commonLabels.DragRows + '" style="cursor:move;"></span>' + SearchProStock + '</div>');
        }
    }
    ld(tdobj).css('text-align', 'center');
    ld(this).attr("rowindex", seqno);
    if (isdel == 'no' && ld(tmprowobj).find("#lineitem_id").val() != '') {
        ld('#' + popupobj.divid + ' table[name="proTab"]').find("[tag=btn_del]").css('display', 'none');

    }
    //that.showTooltipByTr(rowobj);
    if (trlength == 2 || trlength == 1) {
        trobjs = this.popupobj.getTrObjsByDelType('no');

        that.fnAddProductTdBtn();

    }
}
//产品行的清除按钮
fun_selectproduct.btn_clearProductInfo_Row = function (rowId) {
    var event = event || window.event;
    if (event == undefined) return;
    var srcElement = event.srcElement || event.target;

    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = popupobj.getTrObjByChild(ld(srcElement));//考虑拖动换行 ，n那么rowId变量要重新赋值
    if(ld(rowobj).attr("rowindex")!=undefined)
        rowId = ld(rowobj).attr("rowindex");
    popupobj.selectproductobj.clearProductInfo_Row(rowId);

    //清空当前行 数据绑定清空
    // var tmpDetailDataValues = popupobj.selectproductobj.getDetailDataValues();
    // tmpDetailDataValues.databind = 'no';
    // popupobj.detaildatavalue_arr[rowId-1] = tmpDetailDataValues;//将该行赋值空行
    // popupobj.selectproductobj.setDataBind(rowobj);

}
//获取产品的在erp中的库存
fun_selectproduct.getErpInventoryQuantity = function (rowId) {
    var that = this;
    var rowobj = ld(that.tableobj).find("tr[rowindex=" + rowId + "]");

    if (ld(rowobj).find('hdnProductId').val() != undefined
        && ld(rowobj).find('hdnProductId').val() == '') {
        audioRemindsMsg("", "", '', "", "", '产品名称不能为空！');
        return false;
    }
    var popupobj=CrmPopup.getPopupObj("last");

    var module = 'Products';
    var pro_id =popupobj.detaildatavalue_arr[rowId-1].hdnProductId;// ld(rowobj).find('#hdnProductId').val();
    var href_url = 'module=Products&action=ProductsAjax&file=getErpInventoryQuantity&pro_id=' + pro_id;
    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth650px", module, "", 'none', "", "");
    crmPopupobj.prevshow();
    ld.ajax({
        url: 'index.php?' + href_url,
        type: 'POST',
        data: '',
        dataType: 'json',
        async: true,//
        timeout: 5000,
        success: function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth650px", module, "", "", "", "");
                crmPopupobj.quickcreatehtml = data.result.content;
                crmPopupobj.show(data.result.content);
            }
        }
    });

}
//edit:can 20200731 清空套餐信息
fun_selectproduct.prototype.clear_bomInfo = function (rowId) {
    var popupobj = this.popupobj;
    var that = this;

    var tableobj = this.popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("[name=row" + rowId + "]");

    ld(rowobj).find('[tag=dv_productbominfo]').css('display', 'none');
    //ld(rowobj).find(("#productbomid")).val("0");
    this.popupobj.detaildatavalue_arr[rowId-1].productbomid=0;
    //ld(rowobj).find(("#productbomquantity")).val("0");
    this.popupobj.detaildatavalue_arr[rowId-1].productbomquantity=0;
}
//清除产品行
fun_selectproduct.prototype.clearProductInfo_Row = function (rowId) {
    //出库或入库时必须严格参照源单
    var popupobj = this.popupobj;
    var that = this;
    //工单管理特殊分录
    if (popupobj.module == 'WorkSheet' && popupobj.js_detailtablename == 'newproTab') {
        return false;
    }
    // 价格政策模块
    if(popupobj.module === 'PricePolicy') {
        PricePolicyEdit.getInstance(popupobj).delProduct(rowId);
        return false;
    }

    if (!that.sourceOtherProducts()) return false;

    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + rowId + "]");

    if (popupobj.detaildatavalue_arr.length < 3
        && (that.trade == 'finance' || that.trade == 'jijin')) {
        return;
    }

    if(rowId!=undefined)
        ld.each(popupobj.detaildatavalue_arr[rowId - 1],function(tmpkey,tmpinfo){
            //zkt 20231107 BUG0074859 销售订单-新建-单据分录位置，选择一个或多个产品后，单据分录序号发生异常，且前面的部分单据分录没有删除等操作按钮。详见重现步骤。
            if(tmpkey == 'databind' ||tmpkey == 'td_seqno'||tmpkey == 'span_seq_no'){
                return true;
            }
            if(that.cur_module=="QuotesChange"&&ld("#"+popupobj.divid+" #change_type").val()=='replace')
            {
                //edit:can 20240321 BUG20240319-55
                if(tmpkey=='pro_id'||tmpkey=='parent_lineitem_id'||tmpkey=='selectSourceModuleid')
                {
                    return true;
                }
            }
            popupobj.detaildatavalue_arr[rowId - 1][tmpkey]='';

        })

    var rowvalueinfo = popupobj.detaildatavalue_arr[rowId - 1];
    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录清除
    Detaildatachange_byrowindexoperation(popupobj,'before','cearlrow',rowId,rowId);

    if (rowvalueinfo!=undefined && that.fields != undefined && that.fields.length > 0) {
        that.clear_bomInfo(rowId);//清空套餐信息

        for (var i = 0; i < that.fields.length; i++) {
            var defaultvalue = '';
            var typeofdata = that.fields[i].typedata;
            var columnname = that.fields[i].columnname;
            var uitype = that.fields[i].uitype;
            //郎捷开发需求：默认值为空的费用项目显示为空值
            if (ld(popupobj.selectproductobj.versionhtmlobj).val() != undefined && ld(popupobj.selectproductobj.versionhtmlobj).val() == 'langjie' && this.cur_module == 'CustomForm18') {
                typeofdata = '';
            }
            if (typeofdata != undefined) {
                var mustfield = typeofdata.split('~');
                if (mustfield[0] == 'N' || mustfield[0] == 'NN') {
                    defaultvalue = 0;
                    if (uitype == 163) {
                        defaultvalue = defaultvalue.toFixed(that.lengthprice);
                    } else if (uitype >= 10 && uitype <= 15) {
                        defaultvalue = defaultvalue.toFixed(that.lengthdecimaldigits);
                    } else {
                        defaultvalue = defaultvalue.toFixed(2);
                    }
                }
            }
            if (columnname == 'prosheet' && (that.cur_module == 'QuotesChange' || that.cur_module == 'BudgetChange')) continue;

            if (columnname.toLowerCase() == 'imagename') {	//清除产品图片
                CrmPopup.findHtmlobj(that.cur_divid, 'span_imagename_' + rowId).html('');
            }
            if (columnname.toLowerCase() == 'entitytype'||columnname.toLowerCase() == 'entitytypeid') {	// 231013 wym BUG0073014 清除源单类型和源单id
                // rowobj.find('span[name=span_'+columnname+']').html('');
            }

            if (rowvalueinfo[columnname] != undefined) {
                //服务开始日期和服务截止日期 不清除

                if (columnname == 'servicecontracts_start_date' || columnname == 'servicecontracts_end_date'
                    || columnname == 'pro_id') {
                    continue;
                }
                rowvalueinfo[columnname] = defaultvalue;
            }
            //产品文本输入框变为可输入
            if (columnname == 'productname') {
                rowvalueinfo['productname'] = '';
                //工单管理清除配件信息时，不需要变为可输入状态 edit:duan
                if (popupobj.module == 'WorkSheet' && popupobj.js_detailtablename == 'proTab') {
                    ld(rowobj).find(" [detailcolumnname=productname]").css('cursor', '');
                    //ld(rowobj).find(" [detailcolumnname=productname]").val("");
                } else {
                    var productnameobj = ld(rowobj).find("#productname");
                    ld(productnameobj).css('cursor', '').attr('ReadOnly', false).attr('disabled', false);

                    ld(rowobj).find("#" + columnname).attr("data-tip", '').attr("data-direction", '').attr("data-type", '');

                }
            }
            rowvalueinfo[columnname] = '';
            //ld(rowobj).find(" #span_" + columnname).html("");
        }

        //产品ID
        if (rowvalueinfo['productid'] != undefined) {
            rowvalueinfo['productid'] = '';

        }
        if ('QuotesChange' != that.cur_module && 'BudgetChange' != that.cur_module) {
            //源单列特殊控制
            //if (ld(rowobj).find(" [detailcolumnname=lineitem_id]").val() != undefined) {
            //ld(rowobj).find(" [detailcolumnname=lineitem_id]").val('');
            rowvalueinfo['lineitem_id'] = '';

            rowvalueinfo['parent_lineitem_id'] = '';
            //}
            if (ld(rowobj).find(" [detailcolumnname=selectSourceModuleid]").val() != undefined) {

                //ld(rowobj).find(" [detailcolumnname=selectSourceModuleid]").val('');
                rowvalueinfo['selectSourceModuleid'] = '';
            }
        }
        that.isProductClear = 'yes';


    }

    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（产品分录清除行）
    if (!empty(popupobj.detailimage_arr)) {
        for (var i = 0; i < popupobj.detailimage_arr.length; i++) {
            ld(rowobj).find(" [detailfieldname=" + popupobj.detailimage_arr[i].fieldname + "]").find(" div[name=" + popupobj.detailimage_arr[i].fieldname + "]").html('');
            var fileuploader = ld(rowobj).find(" [detailfieldname=" + popupobj.detailimage_arr[i].fieldname + "]").find(" div[name=" + popupobj.detailimage_arr[i].fieldname + "]");
            if (fileuploader.length > 0) {
                var uploadFile = new WebUploadFile();
                globalWebUploadType = uploadFile.getScript(globalWebUploadType);
                uploadFile.setDetailEvent(globalWebUploadType, fileuploader, popupobj, i, rowId);
            }
        }
    }
    if(rowvalueinfo != undefined){
        popupobj.detaildatavalue_arr[rowId - 1] = rowvalueinfo;
    }

    //edit:can 20230228 61408 单据分录明细-产品管理，添加多个产品，选择一个产品点击清除，清除后小计、合计区域数值没有跟随变化，点击保存，合计统计已清除产品的金额
    popupobj.fieldformulaobj.CountsubTotal();
    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录清除
    Detaildatachange_byrowindexoperation(popupobj,'after','cearlrow',rowId,rowId);

    //duan 20240926 整行操作后调用公共变化事件
    popupobj.common_field_event_obj.common_all_entry_changefun(rowId);
}

//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
fun_selectproduct.prototype.sourceOtherProducts = function () {
    var that = this;
    //var popupobj=CrmPopup.getPopupObj('first');//选择产品和选择源单，清除产品
    var popupobj = this.popupobj;
    var ishavesourcefield = 'no';
    var fieldname = '';

    if (popupobj.module == 'WorkSheet') {
        return true;
    }

    ld.each(popupobj.fields, function (index, info) {

        if (info.bigtype == 'selectsource') {
            ishavesourcefield = 'yes';
            fieldname = info.fieldname;
            return false;
        }
    })
    var withproductdetail = 'yes';
    var strictsourcebillcolums = '';//严格参照原单
    if (popupobj.sourcemodule_arr != undefined) {
        var trobjs = this.popupobj.getTrObjsByDelType('no');
        var trlength = ld(trobjs).length;
        //BUG20241101-01 ls 241104 销售订单分录的清空有问题，新建先选择源单报价单，再点分录清空，之后再选择同一个源单报价单，分录带不出来了，卡死一直加载（即使严格参照原单，没有空行时应该允许新增空行）
        ld.each(popupobj.sourcemodule_arr, function (tmpindex, sourcemoduleinfo) {

            if (sourcemoduleinfo.entitytype == ld("#" + popupobj.divid + " [name=selectsource]").val() && trlength>0) {
                withproductdetail = sourcemoduleinfo.withdetail;//选择源单是否允许带出分录，yes:允许带出分录
                strictsourcebillcolums = sourcemoduleinfo.strictsourcebillcolums;

                return false;
            }
        })
    }

    //chj 2021/5/24 46046: （61mis.com/kfbcrm）销售管理-合同订单编辑；单据编号SO453，编辑该单据，清除源单，再次选择源单，产品分录没有带过来
    if (fun_selectproduct.clear_opertion != undefined && fun_selectproduct.clear_opertion == 'yes') {
        fun_selectproduct.clear_opertion = 'no';
        return true;
    }
    //49216: （https://www.51mis.com/hy/TY1118/index.php [^]）自定义表单11》没有控制严格参照源单；新建，选择合同源单带出分录后，再添加其他产品时，提示“不能选择源单以外的产品”
    if (strictsourcebillcolums != '' && strictsourcebillcolums != ',' && !this.popup_selectsource && strictsourcebillcolums != null&& this.batchselect==false) {

        //BUG0076831 hzx 销售订单，产品分录里产品选择不了。
        if ((withproductdetail == 'yes' && ld(that.selectlistvalobj).val() != '')) {
            RemindsMsg("", "LdPopWidth400px", this.cur_module, "yes", "yes", arrJsPopLabel['SELECTPRODUCTLINEITEM']);
            //strict = false;
            return false;
        }
    }
    return true;
}
fun_selectproduct.prototype.AfterchooseSourceHide = function () {
    //选择原单后控制字段不允许修改
    var that = this;
    var popupobj = this.popupobj;
    if (this.sourceeditfield != undefined) {

    }
    this.sourceditfield = [];
    if (ld(that.versionhtmlobj).val() != 'aixu')//上海昶艾电子科技有限公司
    {
        return;
    } else if (ld(that.versionhtmlobj).val() == 'aixu' && popupobj.module != 'CustomForm11') {
        return;
    }

    if (that.popup_selectsource == true) {
        var firstrowobj = ld(that.tableobj).find("tr[detaildeleted=no]:first");

        var entitytypeobj =that.popupobj.detaildatavalue_arr[0].entitytypeid;// ld(firstrowobj).find(" [name=entitytypeid]");
        if (entitytypeobj.length > 0 && entitytypeobj.val() != '' && parseInt(entitytypeobj.val()) > 0) {
        } else
            popupobj.selectproductobj.clearProductInfo_Row(1);

    }
    ldAjaxNoProgress("index.php?module=" + popupobj.module + "&action=" + popupobj.module + "Ajax&file=getSourceEditField", {}, function (data) {
        var trobjs = popupobj.getTrObjsByDelType('no');
        var tableobj = popupobj.getDetailTableObj();

        var rowcnt = ld(trobjs).length;//ld("#"+popupobj.divid+ " [name=rowcnt]").val();
        var selectlistval_labelobj = ld(that.selectlistval_labelobj);
        if (that.popup_selectsource == true || selectlistval_labelobj.val() != '') {
            ld("#" + popupobj.divid + " [tag=sourcehidebutton]").css("display", "none");
            ld.each(trobjs, function (tmptrindex, tmptrobj) {
                entitytypeobj = ld(tmptrobj).find(" [name=entitytypeid]");
                if (entitytypeobj.length > 0 && entitytypeobj.val() != '' && parseInt(entitytypeobj.val()) > 0) {

                    ld.each(popupobj.detailfields, function (tmpindex, tmpdetailfieldinfo) {

                        if (ld.inArray(tmpdetailfieldinfo.columnname, data.result.sourceeditfield) >= 0) {

                        } else {
                            ld(tmptrobj).find(" [name=" + tmpdetailfieldinfo.columnname + "]").attr("disabled", "disabled");

                        }
                    })

                } else {

                    if (tmptrindex == 0) {

                    } else {

                        ld(tmptrobj).css('display', 'none');// ld("#"+popupobj.divid+" [name=row"+i+"]").css('display','none');
                        ld(tmptrobj).attr("detaildeleted", 'yes');

                    }

                }

            })

            ld("#" + popupobj.divid + " [name=inventory_currency]").attr("disabled", "disabled");

        } else {
            ld("#" + popupobj.divid + " [tag=sourcehidebutton]").css("display", "");
            ld("#" + popupobj.divid + " [name=inventory_currency]").removeAttr("disabled");
            ld.each(trobjs, function () {

                ld(this).find("[name=" + tmpdetailfieldinfo.columnname + "]").removeAttr("disabled");
            })


        }

    })


}
//重新创建产品明细
fun_selectproduct.prototype.ResetProductTab = function (selectmodule, selectid,adddetails='no') {
    //服务合同选择合同订单，当销售机会有产品明细
    var popupobj = this.popupobj;
    var module = this.popupobj.module;
    var that = this;
    var urlstr = "index.php?module=Products&action=ProductsAjax&file=getResetProductTabDetail&frommodule=" + module + "&selectmodule=" + selectmodule + '&selectid=' + selectid;
    if(adddetails == 'yes'){
        urlstr += "&adddetails=yes";
    }
    ld.ajax({
        url: urlstr,
        dataType: "json",
        timeout: 10000,
        type: "post",
        success: function (data) {
            if (data.code == 1) {

                ld("#" + popupobj.divid + " [name=productdetailtabletd]").html(data.result.content);
                popupobj.detaildatavalue_arr=data.result.detaildatavalues;
                //edit:can 20210329 45169: （http://xiaoshou360.com/xs/httx [^]）（乌鲁木齐市昊天祥泰医疗器械有限公司）合同订单（htxt-2021-2-22-08）编辑时重新选择商机（SJXMMC-130）产品分录信息有四条，但是保存之后只有两条了
                popupobj.ResetgetDetailTableObj();
                //edit:can 2021052646057: （https://61mis.com/kfbcrm [^]）客户问题（刘家云），服务合同新建界面，选择“合同订单”后，带出的产品分录无法拖动位置顺序（需要补丁）
                popupobj.SortDetailTableRow();
                ////chj 2021/5/25 46058: （https://61mis.com/kfbcrm [^]）服务合同新建界面，选择“合同订单”，点击新增行，选择产品时，选择的产品分录信息显示不出来
                //重新初始化下拉框
                var trobjs = popupobj.getTrObjsByDelType("no");
                var rowcnt = ld(trobjs).length;
                for (var tmpi = 1; tmpi <= rowcnt; tmpi++){
                    popupobj.SetDetailFieldControl(tmpi);
                }
                that.tableobj = popupobj.getDetailTableObj();//获取分录所在的表格对象
                setProductDivWidth(popupobj);//设置列宽
                //edit:can 2020-11-23 43381: （https://61mis.com/kfbtest [^]）客户问题（苏宁），服务合同选择合同订单（合同编号：SO307）带出的产品分录中，分录行没有删除图标（需要补丁）
                that.fnAddProductTdBtn();
                popupobj.setDetailAttachmentEvent();
                //zkt 20230410 BUG0064261 销售订单模块，选择“项目机会”字段之后，带出分录的产品产品，但是想要重新清空选择别的产品，是不能选择的，操作步骤为先选择项目机会，然后再去清空对应的产品，重新选择产品。如图
                var trlen = ld(trobjs).length;
                var tableobj = that.tableobj;//获取分录所在的table对象,不能删除

                for (var tmpi =0; tmpi <=trlen-1; tmpi++) {
                    var tmprowobj = ld(tableobj).find("tr[rowindex=" + (tmpi+1) + "]");//赋值的行对象
                    var tmparr = popupobj.detaildatavalue_arr;
                    // if (popupobj.detaildatavalue_arr[tmpi].productid==undefined|| popupobj.detaildatavalue_arr[tmpi].productid == '' || popupobj.detaildatavalue_arr[tmpi].productid == 0) {
                        if (popupobj.detaildatavalue_arr[tmpi].databind == undefined ||
                            popupobj.detaildatavalue_arr[tmpi].databind == 'no') {
                            that.setDataBind(tmprowobj);
                        }
                    // }
                }
                //BUG20240401-58 ls 240407 新建销售订单，选择该销售机会，则带出的信息不含税单价为0未自动算出(tmprowobj对象错误)
                popupobj.fieldformulaobj.CountFormulaColumn();
                //zkt 20230706 BUG0069234  销售订单新建，产品分录的“合计”字段【保存】后显示0（新建界面，编辑保存后是可以正常显示的）
                that.setHtmlObj();
                calcTotal();//计算调整，折扣，函数金额合计

                //duan 20240621 销售机会带出分录后触发布局规则
                if(popupobj.fieldruleobj != undefined&&popupobj.detailfieldrulefieldnames!=undefined){
                    if(popupobj.detailfieldrulefieldnames.length>0&&popupobj.detailfieldrulefieldnames[0]!='')
                    {
                        popupobj.fieldruleobj.resetDetailColumns();//布局规则，重新设置分录表头的显示和隐藏
                    }

                }

            }
        }
    })
}
//获取产品明细adddetails
fun_selectproduct.prototype.ProductTabadddetails = function (selectmodule, selectid) {
    //20230410调用代码移至ResetProductTab
    this.ResetProductTab(selectmodule, selectid,'yes');
    return ;
}
/*
选择产品弹出层的列表点击超链接字段设置产品值
*/
fun_selectproduct.setProductInfo = function (rowid, productid) {
    if (this.debounceTimer) { //BUG0066750 xxy 2023-8-24 合同订单模块，新建界面，单据分录，添加产品，双击产品进行添加，单据分录出现两行空白
        clearTimeout(this.debounceTimer); //用防抖处理点击过快，给一个200毫秒延迟
    }
    this.debounceTimer = setTimeout(() => {

        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        if (prevpopupobj.module == 'WorkSheet') {
            var divname = "productDiv";
            prevpopupobj.js_detailtablename = 'proTab';
            ld("#" + prevpopupobj.divid + " [name=LastContent]").show();
            ld("#" + prevpopupobj.divid + " [name=" + divname + "]").show();
        }

        prevpopupobj.selectproductobj.getProductInfo(rowid, productid);

    }, 200);
}
fun_selectproduct.setProductDefaultValue = function (rowindex, productdefaultvalue) {
    //新增界面设置产品的默认值

    var popupobj = CrmPopup.getPopupObj('last');
    //   var tmpobj=PageRecordPopupobj;
    // tmpobj.curr_row=rowindex;
//       tmpobj.CancelEvent=function(){CrmPopup.global_listPopupObj.pop();}
//       CrmPopup.global_listPopupObj.push(tmpobj);
    popupobj.selectproductobj.getProductInfo(rowindex, productdefaultvalue);
}
//海格特殊开发:复制报价单时，编辑报价单时
//产品选择产品类型后，先判断是否与现有的产品组相同，如果相同，则产品折扣不允许修改
fun_selectproduct.prototype.discount_readonly = function (popupobj, tmprowid) {
    if (account_version != 'haige' || popupobj.module != 'Quotes') {
        return false;
    }
    if (popupobj.record > 0) {
        var record = popupobj.record;
    } else {
        var record = ld("#" + popupobj.divid + " [name=duplicateid]").val();
    }
    //新增时不控制折扣
    if (record <= 0) {
        return false;
    }
    var tableobj = popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find(" tr[rowindex=" + tmprowid + "]");
    var productid =popupobj.detaildatavalue_arr[tmprowid-1].hdnProductId;// ld(rowobj).find(' [name=hdnProductId]').val();
    var surl = 'index.php?module=' + popupobj.module + '&action=' + popupobj.module + 'Ajax&file=HaigeCheckProductDetail';
    surl += '&record=' + record + '&productid=' + productid + '&check_type=discount';
    ldAjax(surl, "", function (data) {
        if (data.code == 1) {
            DelProgressObjs();
            var result = data.result;
            var columnname_arr = new Array();
            columnname_arr[0] = 'discount_percent';
            columnname_arr[1] = 'agent_discount';
            for (i = 0; i < columnname_arr.length; i++) {
                var columnname = columnname_arr[i];
                //折扣不允许编辑，且最大折扣值大于0时，控制折扣不可修改
                if (result.allowedit == 'no' && result[columnname] > 0) {
                    ld(rowobj).find(' [name=span_' + columnname + ']').html(result[columnname]);
                    ld(rowobj).find(' [name=' + columnname + ']').val(result[columnname]);
                    ld(rowobj).find(' [name=' + columnname + ']').attr('readonly', 'readonly');
                    popupobj.RelatedProductToolFieldtriggcols = [];
                    getRelatedProductToolFieldPriceCallBack(popupobj, tmprowid);
                }
            }
        }
    })
}
//海格,编辑、复制报价单批量删除原产品时，需要判断该产品是否有出货记录
fun_selectproduct.CheckProductDetail = function () {
    var popupobj = CrmPopup.getPopupObj('last');
    var record = popupobj.record;
    if (record <= 0 && ld("#" + popupobj.divid + " [name=duplicateid]").val() > 0) {
        record = ld("#" + popupobj.divid + " [name=duplicateid]").val();
    }
    if (record > 0) {
        var surl = 'index.php?module=' + popupobj.module + '&action=' + popupobj.module + 'Ajax&file=HaigeCheckProductDetail';
        surl += '&record=' + record + '&check_type=order';
        ;
        ldAjax(surl, "", function (data) {
            if (data.code == 1) {
                DelProgressObjs();
                //批量删除
                var num = data.result.num_row;
                var tableobj = popupobj.getDetailTableObj();
                var trobjs = popupobj.getTrObjsByDelType('no');
                if (num > 0) {
                    var deal_info = data.result.deal_info;
                    ld.each(trobjs, function (tmprowindex, tmprowobj) {
                        var rowid = parseInt(tmprowindex) + 1;
                        var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
                        var productid =popupobj.detaildatavalue_arr[tmprowindex].hdnProductId;// ld(delrowobj).find("[detailcolumnname=hdnProductId]").val();

                        if (parseInt(deal_info[productid]) > 0) {
                            ld(delrowobj).find("[detailcolumnname=quantity]").val(parseInt(deal_info[productid]));
                            //重算价格
                            popupobj.RelatedProductToolFieldtriggcols = [];
                            getRelatedProductToolFieldPriceCallBack(popupobj, rowid);
                        } else {
                            //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
                            Detaildatachange_byrowindexoperation(popupobj,'before','delete',tmprowindex,tmprowindex);
                            ld(delrowobj).remove();
                            Detaildatachange_byrowindexoperation(popupobj,'after','delete',tmprowindex,tmprowindex);//-分录删除后
                        }
                    });
                } else {
                    //zkt XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据 --- 分录变化时数据操作 -分录删除前
                    Detaildatachange_byrowindexoperation(popupobj,'before','deleteall');
                    ld.each(trobjs, function (tmprowindex, tmprowobj) {
                        var rowid = parseInt(tmprowindex) + 1;
                        var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
                        ld(delrowobj).remove();
                    });
                    //zkt 20240829 BUG20240829-31 报价单产品分录清空后无法填入数据（分赵克听）
                    //清空产品数组
                    popupobj.detaildatavalue_arr.length = 0;
                    Detaildatachange_byrowindexoperation(popupobj,'after','deleteall');//-分录删除后
                    fun_selectproduct.addproductrow();
                    fun_selectproduct.isProductClear = 'yes';
                }
                if (CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val() != undefined) {
                    CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val(num);
                }
                if (CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val() != undefined) {
                    CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val(num);
                }
                popupobj.fieldformulaobj.setAllRowEvent();
                popupobj.fieldformulaobj.CountsubTotal();
            }
        });
    } else {
        var tableobj = ld("#" + popupobj.divid + " [name=" + popupobj.js_detailtablename + "]");
        var trobjs = popupobj.getTrObjsByDelType('no');
        ld.each(trobjs, function (tmprowindex, tmprowobj) {
            var rowid = parseInt(tmprowindex) + 1;
            var delrowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
            ld(delrowobj).remove();
        });
        fun_selectproduct.addproductrow();
        fun_selectproduct.isProductClear = 'yes';
        if (CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val() != undefined) {
            CrmPopup.findHtmlobj(popupobj.divid, 'adjustment').val(0);
        }
        if (CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val() != undefined) {
            CrmPopup.findHtmlobj(popupobj.divid, 'discount_amount').val(0);
        }
        popupobj.fieldformulaobj.CountsubTotal();
    }
}

// wyt_XUQIU1000492【单据新建/编辑/复制界面，单据表体字段内容加title】_220728
fun_selectproduct.prototype.showTooltipByTable = function () {
    //按列循环
    var popupobj = this.popupobj;
    var tableobj = this.popupobj.getTrObjsByDelType("no");
    ld.each(popupobj.detailfields, function (tmpindex, tmpdetailfieldinfo) {
        var columnname = tmpdetailfieldinfo['columnname'];
        ld.each(tableobj, function (tmprowindex, tmprowobj) {
            var rowid = parseInt(tmprowindex) + 1;
            var rowobj = ld(tableobj).find("tr[rowindex=" + rowid + "]");
            var cur_val = ld(tmprowobj).find(" [detailcolumnname=" + columnname + "]").val();

            if (!empty(cur_val) && cur_val.indexOf('%') < 0) {
                cur_val = decodeURIComponent(cur_val);
            }

            if (tmpdetailfieldinfo['uitype'] == 60) {
                //下拉框
                ld(rowobj).find(" [name=cmb_span_optiontext_" + columnname + "]").addClass("dropdown-toggle tip-items");
                ld(rowobj).find(" [name=cmb_span_optiontext_" + columnname + "]").attr("data-tip", cur_val).attr("data-direction", "top").attr("data-type", "position");
            } else if (tmpdetailfieldinfo['uitype'] == 56) {
                ld(rowobj).find(" [name=cmb_span_optiontext_" + columnname + "]").removeClass("dropdown-toggle tip-items");
            } else {
                ld(tmprowobj).find(" [detailcolumnname=" + columnname + "]").addClass("dropdown-toggle tip-items");
                ld(tmprowobj).find(" [detailcolumnname=" + columnname + "]").attr("data-tip", cur_val).attr("data-direction", "top").attr("data-type", "position");
                if (ld(tmprowobj).find(" [detailcolumnname=span_" + columnname + "]").length > 0) {
                    ld(tmprowobj).find(" [detailcolumnname=span_" + columnname + "]").addClass("dropdown-toggle tip-items");
                    ld(tmprowobj).find(" [detailcolumnname=span_" + columnname + "]").attr("data-tip", cur_val).attr("data-direction", "top").attr("data-type", "position");
                }
            }
        });
    })
    tooltip('.tip-items', {transition: true, time: 200});
}

fun_selectproduct.prototype.showTooltipByTr = function (rowobj) {


    //return false;
    var that = this;
    //按行循环
    //ls 20220815 BUG0055108 合同订单模块，导入分录明细时，界面卡住，无法导入产品分录
    var popupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或者编辑界面
    /*  ld.each(popupobj.detailfields,function(tmpindex,tmpdetailfieldinfo){
         var columnname = tmpdetailfieldinfo['columnname'];
         var cur_val = ld(rowobj).find("#"+columnname).val();
         //ls 20220913 直接在合同订单模块选择源单直接选择报价单（报价单的产品有11行左右），源单的产品只带出了一部分的产品（只带出2行），有些产品没有带出来(含有百分号的字符串decodeURIComponent之后程序就停掉了)
         if (!empty(cur_val) && cur_val.indexOf('%') < 0) {
             cur_val = decodeURIComponent(cur_val);
         }
         if(tmpdetailfieldinfo['uitype']==60)
         {
             //下拉框
             ld(rowobj).find(" [name=cmb_span_optiontext_"+columnname+"]").addClass("dropdown-toggle tip-items");
             ld(rowobj).find(" [name=cmb_span_optiontext_"+columnname+"]").attr("data-tip",cur_val).attr("data-direction","top").attr("data-type","position");
         }else if(tmpdetailfieldinfo['uitype']==56)
         {
             ld(rowobj).find(" [name=cmb_span_optiontext_"+columnname+"]").removeClass("dropdown-toggle tip-items");
         }else{

             ld(rowobj).find("#"+columnname).addClass("dropdown-toggle tip-items").attr("data-tip",cur_val).attr("data-direction","top").attr("data-type","position");
             if(ld(rowobj).find(" #span_"+columnname).length>0){
                 ld(rowobj).find(" #span_"+columnname).addClass("dropdown-toggle tip-items").attr("data-tip",cur_val).attr("data-direction","top").attr("data-type","position");
             }
         }
     })
     tooltip('.tip-items', {transition: true, time: 200});*/

    getJsScript('include/js/freezeEntriesColumns.js', function () {
        var tableid = 'proTab';
        if(popupobj.module=='WorkSheet'){
            //zxm 20240821 工单管理 tableid 是newproTab
            tableid = 'newproTab';
        }
        var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,tableid);
        //这里不需要重新冻结所有 只需要冻结新增行即可
        freezeEntriesColumnsobj.getPositionLeftArr();//获取宽度数组
        var rowindex = ld(rowobj).attr("rowindex");
        var detailfieldname = ld(that.popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').attr("head_detailfieldname");

        if (parseInt(rowindex) == 1)
            freezeEntriesColumnsobj.freezeTbodyColumn(rowobj, ld(that.popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').css('zIndex'));
        else
            freezeEntriesColumnsobj.freezeTbodyColumn(rowobj, ld(that.popupobj.getDetailTableObj()).find(" tr[rowindex=" + (rowindex - 1) + "]").find("td[detailfieldname=" + detailfieldname + "]").css('zIndex'));
    });

}

//lius 20231121 XUQIU1002192 【广东金瓷三维】开发报价单中历史产品报价、成交价的弹框显示，并且带出分录信息。
fun_selectproduct.prototype.getEntryPopupJinci = function (rowId) {
    var event = event || window.event;
    var srcElement = event.srcElement || event.target;

    var popupobj = CrmPopup.getPopupObj('last');
    var rowobj = popupobj.getTrObjByChild(ld(srcElement));//考虑拖动换行 ，那么rowId变量要重新赋值
    rowId = ld(rowobj).attr("rowindex");

    var cur_module = popupobj.selectproductobj.cur_module;

    // 客户和产品必须先选
    var account_id = CrmPopup.getHtmlobjval(popupobj.divid,'account_id');
    var productid = ld(rowobj).find(" [name=hdnProductId]").val();
    if(empty(account_id)){
        MessagePopup.TipOne_warning("请先选择客户！");
        return false;
    }else if (empty(productid)){
        MessagePopup.TipOne_warning("请先选择产品！");
        return false;
    }

    popupobj.selectproductobj.popup_selectsource = false;
    popupobj.selectproductobj.getMethod();


    var surl = "module="+cur_module+"&action="+cur_module+"Ajax&file=Popupjinci";
    surl += "&popup=yes&curr_row=" + rowId + "&frommodule=" + cur_module + "&account_id=" + account_id;

    if (cur_module == "Quotes"){//离心铸造报价申请：通过“规格型号“、”材质“字段判断
        var span_productsheet = ld(rowobj).find(" [detailcolumnname=span_productsheet]").text().trim();
        var span_customform03_id = ld(rowobj).find(" [detailcolumnname=customform03_id_name]").text().trim();
        //BUG0077438 ls 20231219 离心铸造报价申请模块>单据编号：QUO26>点击复制按钮>点击产品名称旁边的，查历史分录按钮>发现没有找到数据(材质以前是单选字段可编辑,被史文龙改成了文本不可编辑)
        if (empty(span_customform03_id)){
            span_customform03_id = ld(rowobj).find(" [detailcolumnname=span_customform03_id]").text().trim();//字段不可编辑状态时
        }
        surl += "&productsheet=" + encodeURIComponent(span_productsheet) + "&caizhi=" + encodeURIComponent(span_customform03_id);

    }else if(cur_module == "CustomForm13"){//砂型铸造报价申请：通过“产品名称”、“用户物料识别信息”、“材质”字段判断
        var productname = ld(rowobj).find(" [detailcolumnname=productname]").val();
        var span_cf_7482 = ld(rowobj).find(" [detailcolumnname=span_cf_7482]").text().trim();//用户物料识别信息
        var span_customform03_id = ld(rowobj).find(" [detailcolumnname=customform03_id_name]").text().trim();
        if (empty(span_customform03_id)){
            span_customform03_id = ld(rowobj).find(" [detailcolumnname=span_customform03_id]").text().trim();//字段不可编辑状态时
        }
        surl += "&productname=" + encodeURIComponent(productname) + "&jiaohuo=" + encodeURIComponent(span_cf_7482) + "&caizhi=" + encodeURIComponent(span_customform03_id);
    }

    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth1300px", cur_module, "", 'none', "", "");
    crmPopupobj.prevshow();
    ldAjax('index.php?'+surl,'',function(data){
        if(data.code==1){
            ld('#rptContentLoading').hide();
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth1300px",cur_module,"","","","");
            crmPopupobj.show(data.result.content);
        }
    })

    /* var requestvalues = "{";
     ld.each(popupobj.fields, function (tmpindex, tmpfieldinfo) {

         //edit:can 57455 http://121.36.206.222:85/muse（上海缪斯建筑装饰）采购订单，“备注”文本框敲回车或者空格，下面的单据分录明细就选不到东西了。详情见附件。
         if (tmpfieldinfo.bigtype == 'longtextarea' || tmpfieldinfo.bigtype == 'textarea')
             return false;
         if (ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").length > 0)
             requestvalues += '"' + tmpfieldinfo.columnname + '":"' + ld("#" + popupobj.divid + " [name=" + tmpfieldinfo.fieldname + "]").val() + '",';

     })

     requestvalues = requestvalues.substr(0, requestvalues.length - 1);//删除“，”
     requestvalues += "}";
     surl += "&requestvalues=" + encodeURIComponent(requestvalues);
     CrmPopupWindow( popupobj.selectproductobj.cur_module,surl, 'Products');*/
}

fun_selectproduct.prototype.setEntryInfojinci = function (rowid,selectmodule,recordid,lineitem_id) {
    var that = this;
    if (this.debounceTimer) {
        clearTimeout(this.debounceTimer);
    }
    this.debounceTimer = setTimeout(() => {
        var prevpopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//新增或编辑的弹出层
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();

        that.popupobj = prevpopupobj;
        that.popupobj.skipRelatedDetailField = 'yes';

        var cur_module = prevpopupobj.selectproductobj.cur_module;
        prevpopupobj.selectproductobj.getMethod();

        var urlstring = "module="+cur_module+"&action="+cur_module+"Ajax&file=Popupjinci&operation=getentryinfo";
        urlstring += '&currencyid=' + prevpopupobj.selectproductobj.currencyid +
            '&rowid=' + rowid + '&frommodule=' + cur_module+ '&selectmodule=' + selectmodule + '&recordid=' + recordid + '&lineitem_id=' + lineitem_id
        // urlstring += "&requestvalues=" + getPageValueByCrmPopupFields(prevpopupobj);

        ldAjax('index.php?'+urlstring,'',function(data){
            if(data.code==1){
                ld('#rptContentLoading').hide();
                // that.setValue(data.result.productid, data.result, rowid);
                fun_selectproduct.prototype.setValue(data.result.productid, data.result, rowid);
            }
        })

    }, 200);

}

