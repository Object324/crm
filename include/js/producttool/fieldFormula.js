/**
 说明：变量后面带有arr字符表示该变量为数据组变量
 变量中有obj表示该变量为数组对象或单个对象
 **/

function formulaInfo() {

}

formulaInfo.prototype =
    {
        cur_columnname: '',//需要计算的字段
        columnnames: '',//参与计算的字段
        fieldlabel: '',
        letters: {'a': 'listprice'},
        typeofdata: 'N~O',
        formulastring: ''
    }


function fieldFormula(toolFieldJson) {
    if (toolFieldJson == '') {
        return false;
    }
    this.beforerowvalue_arr = [];
    var that = this;
    this.popupobj = CrmPopup.getPopupObj('last');
    this.cur_fieldformualobjids = [];//本次引发字段公式的字段得id
    this.baseColumn = this.popupobj.baseColumn;//字段公式基准字段
    this.havestartpricestrategyproduct = [];
    this.listprice_hidden = 'yes';//不含税单价字段是否隐藏

    this.hadtrigger_column_arr=[];//已经触发字段公式过字段公式的字段
    this.baseInverseColumn = "";
    this.version_trade = ld('#version_trade').val();
    this.version_account = ld('#version_account').val();
    this.haveFinishedFormulaColumnsarr = new Array();
    this.finishedcolumncount = [];
    this.dateformula_bol = 'no';//公式计算是否为日期类型，如果是：yes
    this.formulaneedColumnarr = new Array();//获取参与计算的字段名称
    this.computercolumnsformula = [];//查看当前被计算的字段，参与了哪些字段公式计算
    this.strfieldTypeofData = "{";
    this.strfieldUitype = "{";
    this.fieldTypeOfdataarr = {'listprice': 'NN~O'};//所有字段的typeofdata;
    this.objField = new Array();//明细所有字段属性
    this.fieldneedFormualarr = new Array();//获取需要计算的字段对象
    this.columnneedFormulaarr = new Array();//需要计算的字段数组
    this.toolFieldJson = toolFieldJson;//字段公式json(格式请参考数据库){formulavar:[{'var':'a','column':'taxprice'},{'var':'b','column':'tax1'},{'var':'c','column':'tax2'},{'var':'d','column':'tax3'}]}
    this.subtotalfieldobj = new Array();//需要小计的字段对象
    this.lengthDecimaldigits = ld("#" + that.popupobj.divid + " [name=lengthdecimaldigits]").val();//document.getElementById('lengthdecimaldigits').value;//数量小数位数
    this.lengthPrice = ld("#" + that.popupobj.divid + " [name=lengthprice]").val();//document.getElementById('lengthprice').value;//单价小数位数
    this.module_nullfield = ld("#" + that.popupobj.divid + " [name=module_nullfield]").val();// document.getElementById('module_nullfield').value;//空行基准字段
    this.taxamount_relationfield = [];// ['',"taxprice","listprice","discount_amount","list_amount","tax_total"];//价税合计反写时，该数组中字段不再进行公式计算
    this.reversecolumns = [];//输入后需要反算的字段，目前只有价税合计
    this.reversecolumnformula = [];//反算的字段公式
    this.changevaluefield_arr = [];//本次计算修改的字段
    this.restobj = toolFieldJson;// eval('('+ this.toolFieldJson +')')?eval('('+ this.toolFieldJson +')'):JSON.parse(this.toolFieldJson);
    //this.formulaneedColumnarr[0]=this.baseColumn;
    var listpricecolumnname = '';
    var taxpricecolumnname = '';
    var fieldlen = this.restobj.fields.length;
     var formulaneedcolumnlen=0;
    for (var i = 0; i < fieldlen; i++) {

        var toolfield = new toolFieldInfo();
        toolfield.columnname = this.restobj.fields[i].columnname;
        if (toolfield.columnname == 'listprice') {
            that.listprice_hidden = 'no';
            listpricecolumnname = toolfield.columnname;
        } else if (toolfield.columnname == 'taxprice') {
            taxpricecolumnname = toolfield.columnname;
        }
        toolfield.fieldlabel = this.restobj.fields[i].fieldlabel;
        toolfield.typeofdata = this.restobj.fields[i].typedata;
        toolfield.tablename = this.restobj.fields[i].tablename;

        if (this.restobj.fields[i].typedata == null || this.restobj.fields[i].typedata == '') {
            toolfield.typeofdata = "V~O";
        }
        if (this.restobj.fields[i].newline == null) {
            this.restobj.fields[i].newline = 0;
        }
        toolfield.newline = this.restobj.fields[i].newline;
        toolfield.uitype = this.restobj.fields[i].uitype;
        toolfield.subtotal_attr = this.restobj.fields[i].subtotal_attr;
        this.strfieldTypeofData += "'" + toolfield.columnname + "':'" + toolfield.typeofdata + "'";
        this.strfieldUitype += "'" + toolfield.columnname + "':'" + toolfield.uitype + "'";
        if (i != this.restobj.length - 1) {
            this.strfieldTypeofData += ",";
            this.strfieldUitype += ",";
        }
        this.objField.push(toolfield);
        if (toolfield.columnname == 'tax_amount') {
            //价税合计反算公式

            if (this.restobj.fields[i].reverseformula != 'none') {
                that.taxamount_relationfield = [''];
                that.reversecolumns.push(toolfield.columnname);
                that.reversecolumnformula[toolfield.columnname] = this.restobj.fields[i].reverseformula;

                ld.each(this.restobj.fields[i].reverseformula, function (index, tmpreverseformulainfo) {
                    that.taxamount_relationfield.push(tmpreverseformulainfo.columnname);
                })

            }
        }
        if (!empty(this.restobj.fields[i].columnstring)) {

            var strcolumn = this.html_decode(this.restobj.fields[i].columnstring);//转义单引号，双引号

            var columnjsonobj = eval('(' + strcolumn + ')') ? eval('(' + strcolumn + ')') : JSON.parse(strcolumn);

            var formulafieldinfo = new formulaInfo();
            var letterstring = "{";
            formulafieldinfo.columnnames = new Array();//必须重新初始化该数组
            var tmpvarlen = columnjsonobj.formulavar.length;

            for (var k = 0; k < tmpvarlen; k++) {
                if (columnjsonobj.formulavar[k].column.toLowerCase().indexOf('none') <= 0)//空字段不参与计算
                {

                    formulafieldinfo.columnnames[k] = columnjsonobj.formulavar[k].column;
                    letterstring += "'" + columnjsonobj.formulavar[k].lettervar + "':'" + columnjsonobj.formulavar[k].column + "'";
                    if (k != columnjsonobj.formulavar.length - 1) {
                        letterstring += ",";
                    }
                    if (this.formulaneedColumnarr.indexOf(columnjsonobj.formulavar[k].column)   < 0) {
                        this.formulaneedColumnarr[this.formulaneedColumnarr.length] = columnjsonobj.formulavar[k].column;
                    }
                    if (that.computercolumnsformula[columnjsonobj.formulavar[k].column] == undefined) {
                        that.computercolumnsformula[columnjsonobj.formulavar[k].column] = [];
                    }
                    that.computercolumnsformula[columnjsonobj.formulavar[k].column].push(toolfield.columnname);
                }

            }
            letterstring += "}";

            formulafieldinfo.letters = eval('(' + letterstring + ')') ? eval('(' + letterstring + ')') : JSON.parse(letterstring);
            formulafieldinfo.cur_columnname = this.restobj.fields[i].columnname;
            this.columnneedFormulaarr[this.columnneedFormulaarr.length] = formulafieldinfo.cur_columnname;
            formulafieldinfo.formulastring = this.restobj.fields[i].formulastring;

            formulafieldinfo.typeofdata = this.restobj.fields[i].typedata;
            if (this.restobj.fields[i].typedata == null || this.restobj.fields[i].typedata == '') {
                formulafieldinfo.typeofdata = "V~O";
            }
            formulafieldinfo.uitype = this.restobj.fields[i].uitype;
            this.fieldneedFormualarr.push(formulafieldinfo);
        }


    }
     
    if (that.baseColumn == '') {
        //如果价税合计公式没有使用（含税单价和不含税单价字段）
        if (ld.trim(taxpricecolumnname) != '') {
            that.baseColumn = taxpricecolumnname;
        } else {
            that.baseColumn = listpricecolumnname;
        }
    }

    if (this.baseColumn == 'taxprice') {
        this.baseInverseColumn = 'listprice';
    } else {
        this.baseInverseColumn = 'taxprice';
    }
    //this.tableobj=document.getElementById('tmpproTab');
    if (this.strfieldTypeofData.substr(this.strfieldTypeofData.length - 1, 1) == ',') {
        this.strfieldTypeofData = this.strfieldTypeofData.substr(0, this.strfieldTypeofData.length - 1);
    }
    if (this.strfieldUitype.substr(this.strfieldUitype.length - 1, 1) == ',') {
        this.strfieldUitype = this.strfieldUitype.substr(0, this.strfieldUitype.length - 1);
    }
    this.strfieldTypeofData += "}";
    this.strfieldUitype += "}";

    this.fieldTypeOfdataarr = eval('(' + this.strfieldTypeofData + ')') ? eval('(' + this.strfieldTypeofData + ')') : JSON.parse(this.strfieldTypeofData);
    this.fieldUitypearr = eval('(' + this.strfieldUitype + ')') ? eval('(' + this.strfieldUitype + ')') : JSON.parse(this.strfieldUitype);
    //获取需要小计的列

    for (var i = 0; i < this.objField.length; i++) {
        var fieldinfo = this.objField[i];

        //uitype=16:百分比，15:折扣率，17：税,163:单价,730,731,810,811
        if (fieldinfo.typeofdata.toLowerCase().indexOf('n') >= 0 && fieldinfo.uitype != 16 && fieldinfo.uitype != 26
            && fieldinfo.uitype != 27 && fieldinfo.uitype != 15 && fieldinfo.uitype != 17
            && fieldinfo.uitype != 163 && fieldinfo.uitype != 810 && fieldinfo.uitype != 811
            && fieldinfo.uitype != 730 && fieldinfo.uitype != 731) {

            this.subtotalfieldobj.push(fieldinfo);
        }
    }

}

fieldFormula.prototype.setPopupobj = function (popupobj) {
    this.popupobj = popupobj;
}
fieldFormula.prototype.html_decode = function (str) {
    var retstr = '';
    strarr = str.split('&#039;');//目前转义单引号
    for (var k = 0; k < strarr.length; k++) {

        retstr += strarr[k];
        if (k != strarr.length - 1)
            retstr += "'";
    }

    return retstr;
}
/**
 设置GP公式事件
 **/
fieldFormula.prototype.setHtmlEventWhenShowGP = function (id_rowIndex) {
    var that = this;
    var tmpobj = ld("#" + that.popupobj.divid + " [name=grossprofit" + id_rowIndex).get(0);

    tmpobj.onchange = function (event) {
        that.popupobj.fieldformulaobj.cur_formula_obj = this;
        that.popupobj.fieldformulaobj.cur_input_focus_obj = this;
        var e = event || window.event;
        that.popupobj.fieldformulaobj.setHtmlValeWhenShowGP(e, id_rowIndex);
    }

    var tmpobj_productcost = ld("#" + that.popupobj.divid + " [name=productcost" + id_rowIndex);
    if (ld.inArray('productcost', this.formulaneedColumnarr) < 0 && tmpobj_productcost.length > 0) {
        tmpobj_productcost.get(0).onchange = function (event) {
            var e = event || window.event;
            that.popupobj.fieldformulaobj.cur_formula_obj = this;

            that.popupobj.fieldformulaobj.cur_input_focus_obj = this;
            that.popupobj.fieldformulaobj.setHtmlValeWhenShowGP(e, id_rowIndex);
        }
    }
    var tmpobj_discount_percent = ld("#" + that.popupobj.divid + " [name=discount_percent" + id_rowIndex);
    if (ld.inArray('discount_percent', this.formulaneedColumnarr) < 0 && tmpobj_discount_percent.length > 0) {
        tmpobj_discount_percent.get(0).onchange = function (event) {


            that.popupobj.fieldformulaobj.cur_formula_obj = this;
            that.popupobj.fieldformulaobj.cur_input_focus_obj = this;
            var e = event || window.event;
            that.popupobj.fieldformulaobj.setHtmlValeWhenShowGP(e, id_rowIndex);
        }
    }

}

//格式化对应字段的小数位
fieldFormula.prototype.setFieldLenDecimal = function (column, strformula) {
    var len = this.objField.length;
    for (var k = 0; k < len; k++) {
        var tmpcolumn = this.objField[k].columnname;
        var tmpuiytpe = this.objField[k].uitype;
        /*
		*edit:chj
		*date:2020-07-13
		*reason:41972: （http://120.92.51.31:85/kaiyuan [^]）销售订单模块新增界面>产品信息区块：“单价”等于铜价+加工费+超额加工费，填写值后第三位小数没有计算（如图，需要补丁）
		*/
        if (tmpcolumn == column) {
            if (tmpcolumn == 'taxprice' || tmpcolumn == 'listprice' || tmpuiytpe == 163) {
                return parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
            } else {
                if (column == 'quantity' && empty(eval(strformula))) {
                    strformula = 0;//数量允许录入零
                }
                if (tmpuiytpe >= 10 && tmpuiytpe < 15) {

                    return JsNumbertoFixed(eval(strformula), this.lengthDecimaldigits);
                } else if (tmpuiytpe == 20 || tmpuiytpe == 15) {//数字类型字段根据小数位数控制
                    var stypeofdata = this.objField[k].typeofdata.split(',');

                    return JsNumbertoFixed(eval(strformula), stypeofdata[1]);
                } else if (tmpuiytpe == 24) {
                    return parseFloat(eval(strformula));
                } else {
                    var typeofdata = this.objField[k].typeofdata;
                    var tmplen = 2;
                    if (typeofdata != undefined) {

                        //字段公式中使用产品中数字类型字段，且数字类型字段的小数位数不等于2
                        var typeofdatas = typeofdata.split(',');
                        if (typeofdatas.length > 1)
                            tmplen = typeofdatas[1];
                    }
                    return JsNumbertoFixed(eval(strformula), tmplen);
                }
            }
        }
    }
}
//设置金额、数字、单价 小数位数
fieldFormula.prototype.setFieldHtmlForValue = function (column, strformula, id_rowIndex) {
    if (!empty(column)) {
        //zkt 20230615 zkt 20230615 去除产品分录隐藏域
        if(this.popupobj.detaildatavalue_arr != undefined && !empty(this.popupobj.detaildatavalue_arr[id_rowIndex-1])&&!empty(this.popupobj.detaildatavalue_arr[id_rowIndex-1][column])){
            this.popupobj.detaildatavalue_arr[id_rowIndex-1][column] = this.setFieldLenDecimal(column, strformula);
        }
        
        /*var tmp_cur_obj = ld("#" + this.popupobj.divid + " [name=" + column + id_rowIndex + "]");// document.getElementById(column+id_rowIndex);
        if (tmp_cur_obj.length > 0) {
            tmp_cur_obj.val(this.setFieldLenDecimal(column, strformula));
            //cur_obj.value = this.setFieldLenDecimal(column,strformula);
        }
        tmp_span_cur_obj = ld("#" + this.popupobj.divid + " [name=span_" + column + id_rowIndex + "]")
        if (tmp_span_cur_obj.length > 0) {
            tmp_span_cur_obj.get(0).innerHTML = tmp_cur_obj.val();
        }*/
    }
}
/**
 edit:can
 reason:字段公式设置事件
 **/
fieldFormula.prototype.setEvent = function (id_rowIndex) {


    var tableobj = this.popupobj.getDetailTableObj();

    var rowobj = ld(tableobj).find("tr[rowindex=" + id_rowIndex + ']');
    ld(rowobj).find("#productname").unbind('compositionstart').bind('compositionstart', function () { //开始输入
        ld(this).attr('inputtype', 'start');
    })
    ld(rowobj).find("#productname").unbind('compositionend').bind('compositionend', function () { //结束输入
        ld(this).attr('inputtype', 'finish');
    })
    // if(rmb_checkRMBProduct()=='rmb'){
    // 	rmb_productEventBind(id_rowIndex);
    // 	return ;
    //  }
    var that = this;
    var len = this.subtotalfieldobj.length;
    for (var k = 0; k < len; k++) {
        var fieldinfo = this.subtotalfieldobj[k];
        if (ld.inArray(fieldinfo.columnname, this.formulaneedColumnarr) < 0)//如果需要小计的字段在字段公式中，就把该字段时间放在this.formulaneedColumnarr循环中
        {
            if (fieldinfo.newline != 0) {
                continue;
            }

            var htmlobj = ld(rowobj).find("#" + fieldinfo.columnname);//document.getElementById(fieldinfo.columnname+id_rowIndex);
            //edit:can 52916 【大陆智源机器人】V8.4.5.8.5（http://dlznjqrkj.gnway.vip/crm/）带产品分录的模块，新增字段类型为数字或者金额的字段，
            if (ld(htmlobj).length <= 0) {
                continue;
            }
            //下拉框事件暂不做处理(处理文本框和日期)
            //没有字段公式的小计
            if (ld(htmlobj).prop("tagName").toLocaleLowerCase() == 'input') {
                ld(htmlobj).unbind("change").bind("change", function () {
                    that.id_rowIndex = id_rowIndex;
                    that.popupobj.fieldformulaobj.CountsubTotal();//小计
                })

            }
        }
    }
    if (document.getElementById('grossprofit' + id_rowIndex) != undefined)
        this.setHtmlEventWhenShowGP(id_rowIndex);
    if (that.popupobj.module.toLowerCase() == 'productbom') {
        var htmlobj = ld(rowobj).find("#tax_amount");
        if (htmlobj.length > 0) {
            ld(htmlobj).unbind("blur").bind("blur", function () {
                that.id_rowIndex = id_rowIndex;
                that.popupobj.fieldformulaobj.reverseformual_fun(id_rowIndex, 'tax_amount');
                that.CountsubTotal();//小计
            })
            ld(htmlobj).unbind("keyup").bind("keyup", function (event) {
                if (event.keyCode == 13) {
                    that.id_rowIndex = id_rowIndex;
                    that.popupobj.fieldformulaobj.reverseformual_fun(id_rowIndex, 'tax_amount');
                    that.CountsubTotal();//小计
                }
            })
        }
    }
    //浩辰 合同拆分 分录：拆分后总价 反算  拆分后单价
    if (this.version_account == 'haochen' && this.popupobj.module == 'CustomForm16') {
        var tmp_htmlobj_sf = ld(rowobj).find(" [name=sf4660]");
        ld(tmp_htmlobj_sf).unbind("blur").bind("blur", function (event) {
            var sf4660 = ld(rowobj).find(" [name=sf4660]").val();	//拆分后总价
            var quantity = ld(rowobj).find(" [name=quantity]").val();	//数量
            var sf4240 = ld(rowobj).find(" [name=sf4240]").val();	//免费升级次数
            if (empty(sf4240) || eval(sf4240) == 0) sf4240 = 1;
            var temp_chaifen_danjia = JsNumbertoFixed(eval(sf4660 / quantity / sf4240), 2);
            ld(rowobj).find(" [name=sf4450]").val(temp_chaifen_danjia);
            ld(rowobj).find(" [name=span_sf4450]").html(temp_chaifen_danjia);
            that.popupobj.fieldformulaobj.CountsubTotal();

        });
    }
    //呼博士，订单分录是否赠品，是。 金额为0
    if (this.version_account == 'huboshi' && this.popupobj.module == 'SalesOrder') {
        var tmp_htmlobj_sf = ld(rowobj).find(" [name=sf2246]");
        if (tmp_htmlobj_sf.length > 0) {
            var tmp_htmlobj_sf_obj = tmp_htmlobj_sf.get(0);
            tmp_htmlobj_sf_obj.onclick = function (event) {

                var tmp_htmlobj_sf_val = ld(rowobj).find(" [name=sf2246]").prop('checked');
                if (tmp_htmlobj_sf_val) {

                    ld(rowobj).find(" [name=span_tax_amount]").html(0);
                    ld(rowobj).find(" [name=taxprice]").val(0);
                    ld(rowobj).find(" [name=span_taxprice]").html(0);
                    that.popupobj.fieldformulaobj.NoInput_FocusFormula(id_rowIndex);
                    that.popupobj.fieldformulaobj.CountsubTotal();
                }
            }
        }
    }
    //2022/1/13 chj 东莞贺桃：滤芯的数量计算开发：在产品类别为“饮水机”的服务周期内，能根据不同滤芯的保养周期自动计算出所需要的滤芯数量
    /*
    if (this.version_account == 'hetao' && this.popupobj.module == 'CustomForm17') {
        var tmp_htmlobj_quantity = ld(rowobj).find(" [name=baoyang_zhouqi]");
        ld(tmp_htmlobj_quantity).unbind("blur").bind("blur", function (event) {
            setProductDetailQuantityForHetao();
        });
        var tmp_htmlobj_sf4987 = ld(rowobj).find(" [name=sf4987]");
        if (tmp_htmlobj_sf4987.length > 0) {
            ld(tmp_htmlobj_sf4987).unbind("blur").bind("blur", function (event) {
                setProductDetailQuantityForHetao();
            });
        }

        var tmp_htmlobj_quantity = ld(rowobj).find(" [name=quantity]");
        if (tmp_htmlobj_quantity.length > 0) {
            ld(tmp_htmlobj_quantity).unbind("blur").bind("blur", function (event) {
                if (ld(rowobj).find(" [name=productcategory]").val() == '饮水机') {
                    setProductDetailQuantityForHetao();
                    setProductDetailBatchesForHetao();
                } else if (ld(rowobj).find(" [name=productcategory]").val() == '滤芯') {
                    setProductDetailBatchesForHetao();
                }

            });
        }
    }
    */
    if (this.version_trade == 'yangduan') {
        //杨锻：订单中产品分录字段"是否延期"自动取值,  算法: 当订单中的""实际交货日期"">订单中的"预计交货日期2"的时候,将"是否延期"字段赋值为是,反之为否.
        var tmp_htmlobj_date = ld(rowobj).find(" [name=sf2281]");//document.getElementById('sf2281'+id_rowIndex);	//实际交货日期
        var tmp_htmlobj_dates = ld(rowobj).find(" [name=sf3311]");//document.getElementById('sf3311'+id_rowIndex);	//预计交货日期2
        if (tmp_htmlobj_date.length > 0 && tmp_htmlobj_dates.length > 0) {
            var htmlobj_date = tmp_htmlobj_date.get(0);
            var htmlobj_dates = tmp_htmlobj_dates.get(0);
            htmlobj_date.onchange = function (event) {
                var htmlobj_date = tmp_htmlobj_date.get(0);
                var htmlobj_dates = tmp_htmlobj_dates.get(0);
                var tmp_htmlobj_radio_date = ld(rowobj).find(" [name=sf6195]");// document.getElementById('sf6195'+id_rowIndex);
                if (!empty(htmlobj_date.value) && !empty(htmlobj_dates.value) && tmp_htmlobj_radio_date.length > 0) {
                    var htmlobj_radio_date = tmp_htmlobj_radio_date.get(0);

                    if (htmlobj_date.value > htmlobj_dates.value) {
                        htmlobj_radio_date.checked = true;
                        htmlobj_radio_date.value = 1;
                    } else {
                        htmlobj_radio_date.checked = false;
                        htmlobj_radio_date.value = 0;
                    }
                }
            }
            htmlobj_dates.onchange = function (event) {
                var htmlobj_date = tmp_htmlobj_date.get(0);
                var htmlobj_dates = tmp_htmlobj_dates.get(0);
                var tmp_htmlobj_radio_date = ld(rowobj).find(" [name=sf6195]");
                ;// document.getElementById('sf6195'+id_rowIndex);
                if (!empty(htmlobj_date.value) && !empty(htmlobj_dates.value) && tmp_htmlobj_radio_date.length > 0) {
                    var htmlobj_radio_date = tmp_htmlobj_radio_date.get(0);
                    if (htmlobj_date.value > htmlobj_dates.value) {
                        htmlobj_radio_date.checked = true;
                        htmlobj_radio_date.value = 1;
                    } else {
                        htmlobj_radio_date.checked = false;
                        htmlobj_radio_date.value = 0;
                    }
                }
            }
        }
    }
    var typeofdata = '';
    for (var k = 0; k < this.formulaneedColumnarr.length; k++) {
        if (this.formulaneedColumnarr[k] == '')
            continue;
        var tmp_htmlobj = ld(rowobj).find("#" + this.formulaneedColumnarr[k] + "");//document.getElementById(this.formulaneedColumnarr[k]+id_rowIndex);

        if (tmp_htmlobj.length <= 0) {

            continue;
        }
        var htmlobj = tmp_htmlobj;
        typeofdata = '';
        var fieldinfo = that.popupobj.detailfieldcolumninfo[this.formulaneedColumnarr[k]];
        if (fieldinfo != undefined)
            typeofdata = fieldinfo.typeofdata;

        if (htmlobj.prop("tagName").toLocaleLowerCase() == 'input') {
            if (typeofdata.toLocaleLowerCase().indexOf("d~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("dt~") >= 0) {

                ld(htmlobj).unbind("blur").bind("blur", function () {
                    var tmpname = ld(this).attr("name");
                    that.haveFinishedFormulaColumnsarr.push(tmpname);
                    that.finishedcolumncount[tmpname] = 4;
                    /*if (that.finishedcolumncount[tmpname] == undefined) {
                        that.finishedcolumncount[tmpname] = 1;
                    } else {
                        that.finishedcolumncount[tmpname] = parseInt(that.finishedcolumncount[tmpname]) + 1;
                    }*/
                    that.popupobj.fieldformulaobj.setValueByFormula(tmpname, id_rowIndex);
                    that.haveFinishedFormulaColumnsarr = [];

                    that.finishedcolumncount = [];

                    that.popupobj.detail2mainformulaobj.CheckisComputer(that.changevaluefield_arr);
                    that.changevaluefield_arr = [];
                    that.CountsubTotal();//小计
                })
                continue;
            }
            //duan 20240927 产品分录取消绑定后，需要判断公共事件重新绑定
            if(htmlobj.length>0){
                htmlobj[0].have_common_event = 'no';
            }


            ld(htmlobj).unbind("change").bind("change", function () {

                that.popupobj.fieldformulaobj.cur_formula_obj = ld(this);//引发计算的字段
                that.id_rowIndex = id_rowIndex;
                
                var popupobj = that.popupobj;
                var tmpname = ld(this).attr("name");
                //zkt 20230309 整数字段需要格式化 
                if(popupobj.fieldformulaobj.fieldUitypearr[tmpname] != undefined && popupobj.fieldformulaobj.fieldUitypearr[tmpname]==24){
                    ld(this).val(parseFloat(eval(ld(this).val()), 10).toFixed(0));
                }
                var productid = ld(rowobj).find("#hdnProductId").val();

                var havepricestrategy = 'no';
                if (ld.inArray(productid, that.popupobj.productstrategyobj.productids) >= 0) {
                    havepricestrategy = 'yes';

                }
                var tmpstr = 'quantity';
                that.popupobj.fieldformulaobj.havestartpricestrategyproduct = [];
                if (ld(this).attr('detailcolumnname') == tmpstr && productid > 0 && havepricestrategy == 'yes') {
                    if (ld.inArray(productid, that.popupobj.fieldformulaobj.havestartpricestrategyproduct) >= 0) {
                        return false;
                    }
                    that.popupobj.fieldformulaobj.havestartpricestrategyproduct.push(productid);
                    if (that.popupobj.pricestrategyobj.modulehaveprice(popupobj.module) == 'yes') {

                        //edit:can 2020-10-27 43034: （8.2.8升级包测试）产品管理使用定价策略“固定基数+固定增量”，合同订单选择产品后，输入数量，合计没有计算
                        that.popupobj.pricestrategyobj.startcomputer(id_rowIndex);//startcomputer：已经调用字段公式
                        that.CountsubTotal();//小计
                        return false;

                    }

                }

                that.cur_input_focus_obj = this;

                that.haveFinishedFormulaColumnsarr.push(tmpname);
                that.finishedcolumncount[tmpname] = 4;
                /*if (that.finishedcolumncount[tmpname] == undefined) {
                    that.finishedcolumncount[tmpname] = 1;
                } else {
                    that.finishedcolumncount[tmpname] = parseInt(that.finishedcolumncount[tmpname]) + 1;
                }*/
                that.popupobj.fieldformulaobj.setValueByFormula(tmpname, id_rowIndex);

                that.CountsubTotal();
                //计算主表字段 公式（先这样 吧 ）一定要添加因为 有可能分类 的函数 需要经过公式计算 得到

                that.popupobj.detail2mainformulaobj.CheckisComputer(that.changevaluefield_arr);
                that.haveFinishedFormulaColumnsarr = [];
                that.finishedcolumncount = [];
                that.changevaluefield_arr = [];

            })


        }

    }
    if (ld.inArray('tax_amount', this.formulaneedColumnarr) >= 0) {

    } else {
        var tmp_htmlobj = ld(rowobj).find("#tax_amount");//document.getElementById(this.formulaneedColumnarr[k]+id_rowIndex);

        if (ld(tmp_htmlobj).length <= 0) {

            return;
        }
        var htmlobj = tmp_htmlobj;
        ld(htmlobj).unbind("change").bind("change", function () {
            that.reverseformual_fun(id_rowIndex, 'tax_amount');
            that.CountsubTotal();//小计
            //计算主表字段 公式

            that.popupobj.detail2mainformulaobj.CheckisComputer(that.changevaluefield_arr);
            that.changevaluefield_arr = [];
        })
        /*htmlobj.onchange=function(event)
         {

            that.reverseformual_fun(id_rowIndex,'tax_amount');
            that.CountsubTotal();//小计

         }*/
    }
    if (that.version_account == 'langjie') {
        //朗捷 合同（报价单）->相关信息->出口空运特殊字段公式

        if (that.popupobj.module == 'CustomForm18') {

            //应收费用单
            var needColumn = ['sf9995', 'sf10131', 'sf10267', 'sf10403', 'sf10539', 'sf10675', 'sf10811', 'taxprice', 'quantity'];
            ld.each(needColumn, function (index, value) {

                ld("#" + that.popupobj.divid + " [name=" + value + id_rowIndex + "]").unbind("change").bind("change", function () {

                    autoTotalPrice(this, id_rowIndex);
                });
            })


        }
        if (that.popupobj.module == 'CustomForm19') {

            //应付费用单
            var needColumn = ['sf9995', 'sf10131', 'sf10267', 'sf10403', 'sf10539', 'sf10675', 'sf10811', 'taxprice', 'quantity'];
            ld.each(needColumn, function (index, value) {

                ld("#" + that.popupobj.divid + " [name=" + value + id_rowIndex + "]").unbind("change").bind("change", function () {

                    autoTotalPriceCustomForm19(this, id_rowIndex);
                });
            })


        }


    }


    this.popupobj.detail2mainformulaobj.setRowEvent(id_rowIndex);


}
fieldFormula.prototype.getBeforeRowValue_arr = function (rowobj) {


    return false;
    var that = this;
    var subtotallen = that.subtotalfieldobj.length;

    for (var k = 0; k < subtotallen; k++) {
        var fieldinfo = that.subtotalfieldobj[k];
        var tmpobj = ld(rowobj).find("#" + fieldinfo.columnname);
        if (ld(tmpobj).is("td")) {
            that.beforerowvalue_arr[fieldinfo.columnname] = ld(tmpobj).html();
        } else {
            that.beforerowvalue_arr[fieldinfo.columnname] = ld(tmpobj).val();
        }
    }
}
/**
 edit:can
 reason:整数判断,true：整数
 **/
fieldFormula.prototype.isInteger = function (str) {
    var regu = /^[-]{0,1}[0-9]{1,}$/;
    return regu.test(str);
}

/**
 日期类型加减
 type:1:表示日期相加，2：日期相减
 **/
fieldFormula.prototype.setDateValueByFormula = function (formulaColumn, id_rowIndex, type) {
    var that = this;

    var datetime = null;
    var prevchar = '';
    var strType = '';//字符串类型
    var strformula = '';
    var fieldformulaobj = that.popupobj.fieldformulaobj;
    var tableobj = that.popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + id_rowIndex + "]");
    var tmp_computercolumn_arr = [];
    var tmp_cur_input_focus_name =ld(this.cur_input_focus_obj).attr("name");
    for (var k = 0; k < this.fieldneedFormualarr.length; k++) {

        strformula = '';
        datetime = null;

        //引发计算的字段在需要计算的字段中
        if (ld.inArray(formulaColumn, this.fieldneedFormualarr[k].columnnames) >= 0) {
            var formulastring = trim(this.fieldneedFormualarr[k].formulastring).toLowerCase();//获取字段公式

            if (type == 1) {
                formulastring = formulastring.split('date_add(');
                formulastring = formulastring[1];
            } else if (type == 2) {
                formulastring = formulastring.split('date_diff(');
                formulastring = formulastring[1];

            } else {
                return "";
            }

            if (formulastring == '' || formulastring == undefined) {
                return '';
            }

            var datestr = formulastring.split(',');
            var firstdata = datestr[0];
            var tmpfirstdata = "";
            if (trim(firstdata).length > 1) {
                var tmpfirstdata = trim(firstdata);
                //36649: pc端：服务合同服务到期日 ，一年的服务现在都是差一天。
                //说明还有日期公式
                var firstdata = trim(firstdata).substr(0, 1);


            }

            if (ld.inArray(firstdata, letters) >= 0) {
                //	0022634: 服务合同：新增服务合同选择产品，勾选产品后，弹出层没有关闭
                var tmp_cur_obj = ld(rowobj).find(" [name=" + this.fieldneedFormualarr[k].letters[firstdata] + "]");

                /*if(tmp_cur_obj.length>0)//document.getElementById(this.fieldneedFormualarr[k].letters[firstdata]+id_rowIndex).value=='')
                 {
                    导致服务到期无法计算
                    //21557: (怡家下推功能改进)”采购申请单“关联创建“询价单”，询价单【产品】区块的【服务到期日】时间格式显示“NaN-NaN-Na”
                    return '';
                 }*/
                var tmpvalue = tmp_cur_obj.val();
                if (tmpvalue == '' || tmpvalue == undefined) {
                    var myDate = new Date();
                    tmp_cur_obj.val(myDate.toLocaleDateString());
                    tmpvalue = myDate.toLocaleDateString();
                }
                datetime = new DateTime(tmpvalue);//(document.getElementById(this.fieldneedFormualarr[k].letters[firstdata]+id_rowIndex).value);

            } else {

                datetime = new DateTime(firstdata);
            }

            if (type == 1) {

                for (var i = 0; i < datestr[1].length; i++) {

                    var onechar = datestr[1].substr(i, 1);
                    if (ld.inArray(onechar, letters) >= 0) {
                        if (this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar]) == 'yes') {

                        } else {
                            var tmp_cur_obj = ld(rowobj).find("#" + this.fieldneedFormualarr[k].letters[onechar]);
                            if (tmp_cur_obj.length > 0)//document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)!=undefined)
                            {
                                if (ld.trim(tmp_cur_obj.val()) != "")//trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value)!="")
                                    strformula += tmp_cur_obj.val();
                                else
                                    strformula += 0;
                            } else {
                                strformula += 0;
                            }
                        }

                    } else {
                        strformula += onechar;
                    }
                }

                var dates = eval(strformula);

                datetime.addNumber(dates, datestr[2].substr(0, datestr[2].length - 1));
            } else if (type == 2) {
                var cur_obj = ld(rowobj).find("#" + this.fieldneedFormualarr[k].cur_columnname);


                if (ld.inArray(datestr[1], letters)) {
                    //var tmp_cur_obj=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;

                    datestr[1] = ld(rowobj).find("#" + this.fieldneedFormualarr[k].letters[datestr[1]]).val();//document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;

                }
                var ret_method = datestr[2].substr(0, datestr[2].length - 1);

                if (ret_method == 'day')
                    ld(cur_obj).val(datetime.diff(datestr[1]));
                else if (ret_method == 'year')
                    ld(cur_obj).val(datetime.diff(datestr[1]) / 365);
                else if (ret_method == 'days') {	//日期格式相减
                    if (ld.inArray(datestr[0], letters)) {
                        datestr[0] = ld(rowobj).find("#" + this.fieldneedFormualarr[k].letters[datestr[0]]).val();//document.getElementById(this.fieldneedFormualarr[k].letters[datestr[0]]+id_rowIndex).value;
                    }
                    if (datestr[0] != undefined && datestr[1] != undefined && !empty(datestr[0]) && !empty(datestr[1])) {
                        var date_diff = this.DateDiff(datestr[0], datestr[1]);
                        if (empty(date_diff)) date_diff = 1;
                        ld(cur_obj).val(date_diff);
                    }
                }
                var tmp_cur_obj = ld(rowobj).find(" [name=span_" + this.fieldneedFormualarr[k].cur_columnname + "]");
                if (tmp_cur_obj.length > 0)//document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=undefined)
                {

                    tmp_cur_obj.get(0).innerHTML = ld(cur_obj).val();
                }

                /*if(ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
                {

                        cur_obj.onchange();
                }
                cur_obj.onchange();*/

                break;
            }
            var cur_obj = ld(rowobj).find(" #" + this.fieldneedFormualarr[k].cur_columnname);
            var tmp_cur_name = ld(cur_obj).attr("name");

            if (tmp_cur_input_focus_name  == tmp_cur_name)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
            {

                continue;
            }


            if (ld.inArray(tmp_cur_name, this.haveFinishedFormulaColumnsarr) >= 0)//已经计算过的字段不需要计算了
            {

                continue;
            }

            this.haveFinishedFormulaColumnsarr.push(tmp_cur_name);
            if (this.finishedcolumncount[tmp_cur_name] == undefined) {
                this.finishedcolumncount[tmp_cur_name] = 1;
            } else {
                this.finishedcolumncount[tmp_cur_name] = parseInt(this.finishedcolumncount[tmp_cur_name]) + 1;
            }
            this.changevaluefield_arr.push(tmp_cur_name)
            if (tmpfirstdata.length > 1) {

                datetime = new DateTime(datetime.FormatDate(DateTime.FormatStr['Date']));

                if (tmpfirstdata.indexOf("-") >= 0) {
                    var tmpfirstdatas = tmpfirstdata.split('-');

                    datetime.addNumber("-" + parseInt(tmpfirstdatas[1]), trim(tmpfirstdatas[1].substr(parseInt(tmpfirstdatas[1]).toFixed(0).length)));
                } else {
                    var tmpfirstdatas = tmpfirstdata.split('+');
                    datetime.addNumber(parseInt(tmpfirstdatas[1]), trim(tmpfirstdatas[1].substr(parseInt(tmpfirstdatas[1]).toFixed(0).length)));
                }


            }
            if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 52)//日期时间
            {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['DateTime']));

            } else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 51)//日期
            {

                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['Date']));

            } else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 54) {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['Time']));

            } else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 53) {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['ShortTime']));

            }

            tmp_computercolumn_arr.push(this.fieldneedFormualarr[k].cur_columnname);


            /*if(ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
            {
                   //暂时不做递归处理
                    cur_obj.onchange();
            }*/

        }
    }

    /* ld.each(tmp_computercolumn_arr,function(tmpindex,tmpcolumn){
        var  param=[];
        param['data']={'formulacolumn':tmpcolumn};

        that.popupobj.detail2mainformulaobj.startComputer(param);


    })*/


    // this.haveFinishedFormulaColumnsarr=new Array();


}

/**
 当界面显示GP字段的公式计算
 **/
fieldFormula.prototype.setHtmlValeWhenShowGP = function (event, id_rowIndex) {
    //含税单价=成本价/[(1－GP/100) *(1-折扣/100+sum(税)/100)]
    //GP=[1－成本价/(含税单价*（1-折扣/100+sum(税)/100)）]*100

    if (event == undefined) {
        return false;
    }
    var needFormulaobj;
    var e = event || window.event;
    var obj = e.srcElement || e.target;
    if (obj == undefined) {
        return false;
    }
    var cur_columnname = this.getColumnName(obj.name, id_rowIndex);

    var productcost;
    if (document.getElementById('productcost' + id_rowIndex) != undefined) {
        productcost = document.getElementById('productcost' + id_rowIndex).value;
    }
    var gp;
    if (document.getElementById('grossprofit' + id_rowIndex) != undefined) {
        gp = document.getElementById('grossprofit' + id_rowIndex).value;
    }
    var discount_percent = 0;
    if (document.getElementById('discount_percent' + id_rowIndex) != undefined)
        discount_percent = document.getElementById('discount_percent' + id_rowIndex).value;
    var sumtax = 0;//求税的合计
    var tax_array = new Array();
    for (var i = 0; i < this.objField.length; i++) {
        var fieldinfo = this.objField[i];
        if (fieldinfo.uitype == 17) {
            if (document.getElementById(fieldinfo.columnname + id_rowIndex) == undefined) {
                continue;
            }
            if (trim(document.getElementById(fieldinfo.columnname + id_rowIndex).value) == '') {
                continue;
            }
            if (!isNaN(document.getElementById(fieldinfo.columnname + id_rowIndex).value)) {
                continue;
            }
            sumtax += document.getElementById(fieldinfo.columnname + id_rowIndex).value;
            tax_array.push(fieldinfo.columnname.toLowerCase());
        }
    }
    try {

        if (ld.inArray(cur_columnname.toLowerCase(), tax_array) >= 0) {

            var gpvalue = [1 - obj.value / (taxprice * (1 - discount_percent / 100 + sumtax / 100))] * 100;
            needFormulaobj = document.getElementById('grossprofit' + id_rowIndex);
            document.getElementById('grossprofit' + id_rowIndex).value = gpvalue;
            return;
        }
        switch (cur_columnname.toLowerCase()) {
            case 'productcost':
            case 'discount_percent':
            case 'taxprice':
                needFormulaobj = document.getElementById('grossprofit' + id_rowIndex);
                var taxprice = document.getElementById('taxprice' + id_rowIndex).value
                var tmp = (taxprice * (1 - discount_percent / 100 + sumtax / 100));
                if (tmp == 0) {
                    document.getElementById('grossprofit' + id_rowIndex).value = "0.00";

                    break;
                }
                var gpvalue = [1 - obj.value / tmp] * 100;

                if (!isNaN(gpvalue)) {
                    gpvalue = parseFloat(gpvalue, 10).toFixed(2);
                    if (document.getElementById('grossprofit' + id_rowIndex) != 'undefined') {
                        document.getElementById('grossprofit' + id_rowIndex).value = gpvalue;
                    } else {
                        document.getElementById('span_grossprofit' + id_rowIndex).value = gpvalue;
                    }

                } else {
                    if (document.getElementById('grossprofit' + id_rowIndex) != 'undefined') {
                        document.getElementById('grossprofit' + id_rowIndex).value = "0.00";
                    } else {
                        document.getElementById('span_grossprofit' + id_rowIndex).value = "0.00";
                    }
                }


                break;
            case 'grossprofit':
                needFormulaobj = document.getElementById('listprice' + id_rowIndex);

                var taxprice = obj.value / [(1 - gp / 100) * (1 - discount_percent / 100 + sumtax / 100)];
                taxprice = parseFloat(taxprice, 10).toFixed(2);
                document.getElementById('taxprice' + id_rowIndex).value = taxprice;
                document.getElementById('taxprice' + id_rowIndex).onchange();
                break;
        }
    } catch (e) {
        if (needFormulaobj == undefined) {
            //edit:can 2020-09-14 42654: （http://51mis.com.cn/XS/banpu/ [^]）客户问题（班普）合同订单模块>新建单据界面：选择产品“金蝶KIS”，“价税合计”，“不含税单价”字段没有自动计算
        } else {
            needFormulaobj.value = 0;

            if (needFormulaobj.name == ('taxprice' + id_rowIndex)) {
                needFormulaobj.onchange();
            }
        }

    }
}

/**
 event:事件
 htmlobj:引发字段公式元素
 formulaneedColumn:公式中需要的字段名称
 **/
fieldFormula.prototype.setValueByFormula = function (formulaColumn, id_rowIndex) {
 
 
    var that = this;
    var strformula = '';
    //var tableobj = this.popupobj.getDetailTableObj();
   // var rowobj = ld(tableobj).find("tr[rowindex=" + id_rowIndex + "]");
    var tmpneedcomputercols = [];
    var cur_obj;//需要计算的元素
    //alert(this.baseColumn);
    var cur_columnname;
    var popupobj = this.popupobj;
    if (empty(cur_columnname)) {
        cur_columnname = formulaColumn;
    }
    this.cur_formula_obj = formulaColumn;
    //var formula_obj=ld(rowobj).find("#"+formulaColumn+"");//document.getElementById(formulaColumn+htmlobj.id_rowIndex);//数字改变


    if (this.cur_input_focus_obj != undefined && ld(this.cur_input_focus_obj).length > 0) {
        var fieldformulaColumn = ld(this.cur_input_focus_obj).attr("name");
    }
    
    var rowvalueinfo = popupobj.detaildatavalue_arr[id_rowIndex - 1];
    var productid = popupobj.detaildatavalue_arr[id_rowIndex - 1].productid;// ld(rowobj).find("#hdnProductId").val();
    var len = this.fieldneedFormualarr.length;
    var module = that.popupobj.module;
    var noprofiledetailfields_arr=that.popupobj.noprofiledetailfields;
     var strategyproductidlen=popupobj.productstrategyobj.productids.length;
     if (strategyproductidlen>0&&popupobj.productstrategyobj.productids[0].length>0&&popupobj.productstrategyobj.productids.indexOf(productid)   >= 0) {
            havepricestrategy = 'yes';
            
     } 
     
     var curinputname=ld(this.cur_input_focus_obj).attr("name");
    for (var k = 0; k < len; k++) {

        var quantitytmp = 'quantity';
        var havepricestrategy = 'no';
        var fieldneedcur_columnname = this.fieldneedFormualarr[k].cur_columnname;
        if (fieldneedcur_columnname == 'tax_amount' && this.cur_input_focus_obj != null
            && curinputname == quantitytmp) {

            if (havepricestrategy == 'yes' && (popupobj.module == 'SalesOrder' || popupobj.module == 'ServiceContracts'
                || popupobj.module == 'Quotes')) {

                //有价格策略,，则不计算价税合计
                continue;
            }

        }

        strformula = '';
        var fieldneedcolumnnames = this.fieldneedFormualarr[k].columnnames;
        //引发计算的字段在需要计算字段中
            
        if (fieldneedcolumnnames.includes(formulaColumn)) {

            var formulastring = trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式

            if (productid <= 0) {
                continue;
            }

            if (this.isDateFormula(formulastring) > 0)//判断当前公式是否为日期类型的计算公式
            {
                return this.setDateValueByFormula(formulaColumn, id_rowIndex, this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式
            }


            //@chj mantis: 41957: (https://61mis.com/KH/kh39995/ [^])报价单模块>新建单据界面：产品分录“价税合计”字段（价税合计字段公式：总重量*含税单价*折扣率/100），计算金额不正确（销售发票也有此问题）
            if (this.cur_input_focus_obj != undefined && ld(this.cur_input_focus_obj).length > 0) { //// @edit:dong @date:2020/08/06 @reason: bug0042273 盘点单新建界面 批次无法关闭


                if (rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] == undefined || curinputname  == this.fieldneedFormualarr[k].cur_columnname)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                {
                     
                    continue;
                }
            }


            //价税合计反写时，taxamount_relationfield数组中字段不再进行计算
            //editor:gyq_161 reason:带分录模块弹出层   2019/11/22 18:04
            if (ld(this.cur_input_focus_obj).length > 0
                && curinputname.toLowerCase() == 'tax_amount'
                && ld.inArray(fieldneedcur_columnname, this.taxamount_relationfield) > 0) {
                continue;
            }

            var isundefined = 'no';
            var formulastringlen = formulastring.length;

            for (var i = 0; i < formulastringlen; i++) {
                var onechar = formulastring.substr(i, 1);
                if (onechar == '') {
                    continue;
                }

                if (letters.includes(onechar))//如果是变量
                {
                     that.hadtrigger_column_arr[this.fieldneedFormualarr[k].letters[onechar]]=1;
                     // if(noprofiledetailfields_arr[this.fieldneedFormualarr[k].letters[onechar]]!=undefined)
                     // {
                     //        rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]=0;
                     // }
                    if (rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]] == undefined) {
                        rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]] = 0;
                        if (this.fieldneedFormualarr[k].letters[onechar] == 'listprice')
                            strformula += "1";//含税单价计算时，如果不含税单价字段隐藏，则含税单价不进行计算
                        else
                            strformula += "0";
                        continue;
                    }
                    if (this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar]) == 'yes') {

                        return "0";
                    } else {
                        if (ld.trim(rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]] + "") == '') {
                            rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]] = 0;
                        }
                        if (this.fieldneedFormualarr[k].letters[onechar] == formulaColumn || (this.fieldneedFormualarr[k].letters[onechar] == this.baseColumn
                            && formulaColumn.toLowerCase() != this.baseInverseColumn)) {
                            //如果计算的值为负数，则计算不成功    如a-b b为负数

                            if (eval(rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]) < 0) {
                                strformula += '(' + eval(this.setFieldLenDecimal(this.fieldneedFormualarr[k].letters[onechar], rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]])) + ')';
                            } else {

                                strformula += this.setFieldLenDecimal(this.fieldneedFormualarr[k].letters[onechar], rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]);
                            }

                        } else {
                           
                            if (rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]] == '' && rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]!=0) {
                                strformula += this.depthCompueFormula(this.fieldneedFormualarr[k].letters[onechar], id_rowIndex);
                            }
                            //zkt 20240529 BUG20240524-26  收款单，明细公式计算结果不对，单号：SKD-20240523-004  负数应该加个括号
                            else if (!isNaN(parseFloat(rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]])) && eval(rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]) < 0) {
                                strformula += '(' + eval(this.setFieldLenDecimal(this.fieldneedFormualarr[k].letters[onechar], rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]])) + ')';
                            }else
                                strformula += rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]];//ld(rowobj).find( '#' + this.fieldneedFormualarr[k].letters[onechar]+"").val();//this.depthCompueFormula(this.fieldneedFormualarr[k].letters[onechar],id_rowIndex);

                        }
                    }

                } else if (chineseBrackets.includes(onechar))//如果中文括号
                {
                    if (onechar == chineseleftbracket)//中文左括号
                    {
                        strformula += '(';
                    } else if (onechar == chineserightbracket) {
                        strformula += ')';
                    }
                } else {
                    strformula += onechar;
                }
            }

            try {
                
             
                var cur_columnname = this.fieldneedFormualarr[k].cur_columnname;
                if (this.cur_input_focus_obj != undefined) {
                    if (curinputname == cur_columnname) {
                        continue;
                    }
                }

                if (this.haveFinishedFormulaColumnsarr.includes(cur_columnname))//已经计算过的字段不需要计算了
                {
                    continue;
                }

                if (this.cur_input_focus_obj != undefined &&curinputname == 'tax_amount' && cur_columnname == 'tax_amount' && module.toLowerCase() != 'productbom') {
                    continue;
                }

                //价税合计反写时，taxamount_relationfield数组中字段不再进行计算
                if (this.cur_input_focus_obj != undefined &&curinputname == 'tax_amount' && this.taxamount_relationfield.indexOf(this.fieldneedFormualarr[k].cur_columnname) > 0 && module.toLowerCase() != 'productbom') {
                    continue;
                }


                this.haveFinishedFormulaColumnsarr.push(cur_columnname);
                if (this.finishedcolumncount[cur_columnname] == undefined) {
                    this.finishedcolumncount[cur_columnname] = 1;
                } else {
                    this.finishedcolumncount[cur_columnname] = parseInt(this.finishedcolumncount[cur_columnname]) + 1;
                }
                this.changevaluefield_arr.push(cur_columnname);
                /*  if(strformual=='2.00*1.000')
               {

               }*/
                if (module.toLowerCase() != 'productbom' && this.fieldneedFormualarr[k].cur_columnname == this.baseColumn + "aaaaaaa" && ld(this.cur_input_focus_obj).attr("name").toLowerCase() != this.baseInverseColumn) {
                    //如果需要计算的字段为含税单价，且当前引起计算的字段不是“不含税单价",那么就不需要计算含税单价
                } else {
                    if (this.fieldneedFormualarr[k].cur_columnname == 'taxprice' || this.fieldneedFormualarr[k].cur_columnname == 'listprice' || this.fieldneedFormualarr[k].uitype == 163) {
                        rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = (parseFloat(eval(strformula), 10).toFixed(this.lengthPrice));
                    } else {
                        if (this.fieldneedFormualarr[k].uitype >= 10 && this.fieldneedFormualarr[k].uitype < 15) {
                            rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = (parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits));
                        } else if (this.fieldneedFormualarr[k].uitype == 20 || this.fieldneedFormualarr[k].uitype == 15) {
                            //数字类型字段根据小数位数控制,折扣率
                            var stypeofdata = this.fieldneedFormualarr[k].typeofdata.split(',');

                            rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = (parseFloat(eval(strformula), 10).toFixed(stypeofdata[1]));
                        } else if (this.fieldneedFormualarr[k].uitype == 24) {
                            // date:2021-9-10 edit:duan reason:在使用字段公式时，整数类型没有控制小数位
                            rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = (parseFloat(eval(strformula)).toFixed(0));
                        } else {
                            //toFixed
                            //含税单价47245.7x0.05=2362.285，四舍五入应该是2362.29，
                            var typeofdata_decimal = 2;
                            if (this.fieldneedFormualarr[k].uitype >= 25 && this.fieldneedFormualarr[k].uitype <= 50) {
                                var tmptypeofdata = this.fieldneedFormualarr[k].typeofdata;
                                if (tmptypeofdata != undefined) {
                                    var tmptypeofdatas = tmptypeofdata.split(',');
                                    if (tmptypeofdatas.length > 1)
                                        typeofdata_decimal = tmptypeofdatas[1];
                                }
                                if (typeofdata_decimal == '') {
                                    typeofdata_decimal = 2;
                                }
                            }
                             
                            rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = (JsNumbertoFixed(parseFloat(eval(strformula), 10), typeofdata_decimal));
                        }

                    }
                }
              

                if (isNaN(rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname]) || rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] == 'Infinity' || rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] == '-Infinity') {
                    rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname] = 0;
                }
                //zkt 20240613 BUG20240611-61  采购订单模块，新建单据时选择产品，填写含税单价不含税金额显示异常（小计数据正常）
                if(that.popupobj.detailfieldcolumninfo[this.fieldneedFormualarr[k].cur_columnname].edit_permission==1
                ||that.popupobj.detailfieldcolumninfo[this.fieldneedFormualarr[k].cur_columnname].edit_permission==2
                ||that.popupobj.detailfieldcolumninfo[this.fieldneedFormualarr[k].cur_columnname].edit_permission==3)
                {
                    rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname+"_name"]=rowvalueinfo[this.fieldneedFormualarr[k].cur_columnname]
                }
                
                tmpneedcomputercols.push(this.fieldneedFormualarr[k].cur_columnname);
                //分录调用字段公式后,触发公共事件
                popupobj.common_field_event_obj.common_entry_changefun('',this.fieldneedFormualarr[k].cur_columnname,id_rowIndex);


            } catch (ex) {
                //console.log(ex);
            }
        }
    }
       

    ld.each(tmpneedcomputercols, function (index, tmpcol) {
        if (tmpcol != '' && that.formulaneedColumnarr.includes(tmpcol))//判断是否参与计算
        {

            var tmp_formulainfo = that.computercolumnsformula[tmpcol];//查看当前被计算的字段，参与了哪些字段公式计算

            ld.each(tmp_formulainfo, function (tmpindex, tmpcolumnname) {
                //  if(tmpcolumnname=='listprice'||tmpcolumnname=='taxprice')
                //    return true;//防止死循环，先这样，将来有时间修改为添加每个字段总计算次数判断的变量
                if (account_version == 'ytuolai' && (tmpcolumnname == 'sf8892'
                    || tmpcolumnname == 'sf3346'))
                    return true;
                //edit:can 20230104 60418 订单分录，选择产品后，先录入折扣，再录入数量，得到的价税合计和税额、不含税数据不对
                if (that.finishedcolumncount[tmpcolumnname] != undefined && that.finishedcolumncount[tmpcolumnname] > 3) {
                    return true;
                }
                var tmp_arr_index =that.haveFinishedFormulaColumnsarr.indexOf(tmpcolumnname);// ld.inArray(tmpcolumnname, that.haveFinishedFormulaColumnsarr);

                if (tmp_arr_index >= 0) {
                    //已经计算的过的字段，但是其中参与计算的字段值改变，那么已经计算的字段需要重新计算
                    //例如导入

                    that.haveFinishedFormulaColumnsarr.splice(tmp_arr_index, 1);
                }
            })

            that.setValueByFormula(tmpcol, id_rowIndex);
        }
    })
      // console.log('aa')

    //合计反算

    if (this.cur_input_focus_obj != undefined &&
        (curinputname== 'tax_amount' ||
            (curinputname == this.baseColumn
                && global_js_version == "jijin"))) {
        //	fieldformulaobj.setHtmlEventWhenTaxAmount(id_rowIndex);

        popupobj.fieldformulaobj.reverseformual_fun(id_rowIndex, 'tax_amount');
    }


    //38175: 合同订单->新增自定义字段并增加反选规则，新增合同订单录入价税合计的时候，反算规则生效了也进行了反算，但是下面的小计计算不正确
    //this.CountsubTotal();//小计行
}
/**
 edit:can
 reason:通过html元素的ID获取字段名称
 id_name:元素id
 id_rowIndex:元素所在行-2（2：删除protab前面两行)

 fieldFormula.prototype.getColumnName=function(id_name,id_rowIndex)
 {
     var id_len=trim((id_rowIndex+"")).length;//添加双引号的目的是把id_rowIndex变为字符串
	 if(id_name == undefined){
		return '';
	 }else{
		var formulaColumn=id_name.substr(0,id_name.length-id_len);
		return formulaColumn;
	 }
}**/
fieldFormula.prototype.depthCompueFormula = function (formulaColumn, id_rowIndex) {

    //rowvalueinfo[this.fieldneedFormualarr[k].letters[onechar]]

    var strformula = '';
    var strformulavalue = '';
    var popupobj = this.popupobj;
    var rowvalueinfo = popupobj.detaildatavalue_arr[id_rowIndex - 1]
    if(this.popupobj.noprofiledetailfields[formulaColumn]!=undefined)
     {
            rowvalueinfo[formulaColumn]=0;
     }
    if (this.columnneedFormulaarr.indexOf(formulaColumn)  < 0) {


        return this.setFieldLenDecimal(formulaColumn, rowvalueinfo[formulaColumn]);
    }
     if (popupobj.productstrategyobj.productids.indexOf(productid)  >= 0) {
        havepricestrategy = 'yes';

    }
    var productid = rowvalueinfo.productid;
     
    var fieldneedformulalen = this.fieldneedFormualarr.length;
    for (var k = 0; k < fieldneedformulalen; k++) {
        var quantitytmp = 'quantity' + id_rowIndex;
        var havepricestrategy = 'no';
        var fieldneedcur_columnname = this.fieldneedFormualarr[k].cur_columnname;

        if (fieldneedcur_columnname == 'tax_amount' && this.cur_input_focus_obj.name == quantitytmp) {

          


            if (havepricestrategy == 'yes' && (popupobj.module == 'SalesOrder' || popupobj.module == 'ServiceContracts' || popupobj.module == 'Quotes')) {


                return rowvalueinfo['tax_amount']

            }

        }

        //引发计算的字段在需要计算字段中
        if (formulaColumn == fieldneedcur_columnname) {
            var formulastring = this.fieldneedFormualarr[k].formulastring;//获取字段公式

            var formuulastringlen = formulastring.length;
            for (var i = 0; i < formuulastringlen; i++) {

                var onechar = formulastring.substr(i, 1);

                if (onechar == '') {

                    continue;
                }

                if (ld.inArray(onechar, letters) >= 0)//如果是变量
                {
                    var fieldformlahtmlobj = ld("#" + popupobj.divid + "#" + this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex);

                    if (fieldformlahtmlobj.length <= 0 || fieldformlahtmlobj.attr("type").toLowerCase() == 'hidden') {
                        if (fieldformlahtmlobj.length <= 0) {
                            return this.setFieldLenDecimal(formulaColumn, 0);
                        }
                        // alert(formulastring);
                        //alert(formulaColumn);

                        return this.setFieldLenDecimal(rowvalueinfo[formulaColumn], fieldformlahtmlobj.val());
                    }

                    strformula += this.setFieldLenDecimal(this.fieldneedFormualarr[k].letters[onechar], fieldformlahtmlobj.val());
                } else if (ld.inArray(onechar, chineseBrackets) >= 0)//如果中文括号
                {
                    if (onechar == chineseleftbracket)//中文左括号
                    {
                        strformula += '(';
                    } else if (onechar == chineserightbracket) {
                        strformula += ')';
                    }
                } else {

                    strformula += onechar;

                }
            }

            //价税合计=数量*函数单价，销售税：13，输入数量200，然后输入含税单价1,则价税合计为198的错
            //基准字段：含税单价。不含税单价启用
            /* var tmp_cur_obj=ld("#"+popupobj.divid+"#"+fieldneedcur_columnname+id_rowIndex+"");

				if(tmp_cur_obj.length<=0)
				{

					continue;
				}
                var cur_obj=tmp_cur_obj.get(0);*/
            if (this.cur_input_focus_obj != undefined) {
                if (this.cur_input_focus_obj.name == fieldneedcur_columnname) {
                    return rowvalueinfo[fieldneedcur_columnname]
                }
            }


            if (fieldneedcur_columnname == 'taxprice' || fieldneedcur_columnname == 'listprice' || this.fieldneedFormualarr[k].uitype == 163) {
                strformulavalue = parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
            } else {
                if (this.fieldneedFormualarr[k].uitype >= 10 && this.fieldneedFormualarr[k].uitype < 15) {
                    strformulavalue = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
                } else if (this.fieldneedFormualarr[k].uitype == 20 || this.fieldneedFormualarr[k].uitype == 15) {
                    //数字类型字段根据小数位数控制,折扣率
                    var stypeofdata = this.fieldneedFormualarr[k].typeofdata.split(',');

                    strformulavalue = parseFloat(eval(strformula), 10).toFixed(stypeofdata[1]);
                } else if (this.fieldneedFormualarr[k].uitype == 24) {
                    strformulavalue = parseFloat(eval(strformula));
                } else {
                    var typeofdata_decimal = 2;
                    if (this.fieldneedFormualarr[k].uitype >= 25 && this.fieldneedFormualarr[k].uitype <= 50) {
                        var tmptypeofdata = this.fieldneedFormualarr[k].typeofdata;
                        if (tmptypeofdata != undefined) {
                            //字段公式中使用产品中数字类型字段，且数字类型字段的小数位数不等于2
                            var tmptypeofdatas = tmptypeofdata.split(',');
                            if (tmptypeofdatas.length > 1)
                                typeofdata_decimal = tmptypeofdatas[1];
                        }
                        if (typeofdata_decimal == '') {
                            typeofdata_decimal = 2;
                        }
                    }
                    strformulavalue = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                }

            }
            break;
        }
    }

    return '(' + strformulavalue + ')';
}
/**
 编辑或新增是初始化已有行html元素的事件
 **/
fieldFormula.prototype.setAllRowEvent = function () {
    var that = this;
    /*var rowcnt =ld("#"+this.popupobj.divid+" [name=rowcnt]").val();//  document.getElementById('rowcnt').value;

	for(var i=1;i<= rowcnt;i++){

		this.setEvent(i);

	}*/
    var trobjs = this.popupobj.getTrObjsByDelType("no");
    ld.each(trobjs, function () {
        var rowindex = ld(this).attr("rowindex");
        that.setEvent(rowindex);
        if (that.popupobj.detailfieldmodule == 'Products') {
            getRelatedProductToolFieldPrice(that.popupobj, rowindex);
        }
    })
}
/**
 是否为日期类型的公式
 1:日期相加
 2：日期相减
 0：不是日期类型公式
 **/
fieldFormula.prototype.isDateFormula = function (formulastring) {
    formulastring = formulastring.toLowerCase();

    if (formulastring.indexOf('date_add(') >= 0) {

        return 1;
    } else if (formulastring.indexOf('date_diff(') >= 0) {
        return 2;
    } else {
        return 0;
    }
}
//字段是否为日期类型,是返回yes;
fieldFormula.prototype.isDateColumn = function (columnname) {

    var typeofdata = this.fieldTypeOfdataarr[columnname];
    if (typeofdata == null)
        typeofdata = "V-O";
    var datas = typeofdata.split('~');
    if (datas[0].toLocaleLowerCase() == 'd' || datas[0].toLocaleLowerCase() == 'dt') {
        return 'yes'
    }
    return 'no';
}

/**
 edit:can
 reason:获取字段类型(如果d,dt,nn,n)
 **/
fieldFormula.prototype.getColumnTypeofData = function (columnname) {

    var typeofdata = this.fieldTypeOfdataarr[columnname];

    var datas = typeofdata.split('~');

    return datas[0].toLocaleLowerCase();
}
/***
 选择产品
 ***/
fieldFormula.prototype.NoInput_FocusFormula = function (id_index) {
    var that = this;
    //var tableobj=this.popupobj.getDetailTableObj();
    //  var rowobj=ld(tableobj).find("tr[rowindex="+id_index+']');


    if (this.version_trade == 'jiangjing' && (this.popupobj.module.toLowerCase() == 'salesorder' || this.popupobj.module.toLowerCase() == 'outboundorder' || this.popupobj.module.toLowerCase() == 'quotes')) {
        this.popupobj.fieldformulaobj.cur_input_focus_obj = "discount_percent";//ld(rowobj).find(" [name=discount_percent]");
    } else {
        //40422: （http://51mis.com/demo/panlulu005/演示账套 [^]）课程管理->课程管理，新建界面，直接选择书籍信息，勾选单据点击确定按钮后，界面显示系统奔溃
        //教育行业
        this.popupobj.fieldformulaobj.cur_input_focus_obj = this.baseColumn;//ld(rowobj).find("#"+this.baseColumn+"");
    }
    //zkt 20230407 BUG0064226 做合同的时候选择产品，产品的报价带出过来 
    that.haveFinishedFormulaColumnsarr.push(this.popupobj.fieldformulaobj.cur_input_focus_obj);
    that.finishedcolumncount[this.popupobj.fieldformulaobj.cur_input_focus_obj] =4;
    this.CountRowFormulaColumn(id_index);
    //  if(this.popupobj.fieldformulaobj.ismasscount!='yes')
    this.CountsubTotal();//小计
}
/**
 edit:can
 reason:不含税单价改变(例如改变币种)
 **/
fieldFormula.prototype.changelistprice = function () {
    /*var rowcnt =ld("#"+this.popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;
     for(var i=1;i<=rowcnt;i++)
     {
        var htmlobj=ld("#"+this.popupobj.divid+" [name=listprice"+i+"]").get(0);
        this.cur_input_focus_obj=htmlobj;

        this.CountRowFormulaColumn(i);
     }*/
    var that = this;
    /*var trobjs=this.popupobj.getTrObjsByDelType('no');
     ld.each(trobjs,function(){
             var rowindex=ld(this).attr("rowindex");
            that.cur_input_focus_obj='listprice';//ld(this).find(" [name=listprice]") ;
            that.CountRowFormulaColumn(rowindex);
     })*/
    ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpinfo) {
        that.cur_input_focus_obj = 'listprice';
        that.haveFinishedFormulaColumnsarr.push('listprice');
        that.finishedcolumncount['listprice'] =4;
        that.CountRowFormulaColumn(tmpindex + 1);
    })
    this.CountsubTotal();
}
fieldFormula.prototype.changeAllDatabyColumnname = function (columnname) {

    var fieldformulaobj = this.popupobj.fieldformulaobj;

    var that = this;

    var tmpflag = 'no';
    //  var trobjs=this.popupobj.getTrObjsByDelType('no');
    if (that.formulaneedColumnarr.includes(that.baseColumn))//判断是否参与计算
    {
        var tmp_formulainfo = that.computercolumnsformula[that.baseColumn];
        ld.each(tmp_formulainfo, function (tmpindex, tmpcolumnname) {
            //baseColumn参与columnname字段计算，参与计算时需要参与计算
            if (tmpcolumnname == columnname) {
                tmpflag = 'yes';
                return false;
            }
        })
    }
    //zkt 20240813 BUG20240625-02 自定义表单16（ZDYBD16-1）单据查看详情界面，相关信息关联创建收款单时，“实际收款金额”没有计算
    if (columnname != that.baseColumn && that.computercolumnsformula[columnname] != undefined && that.computercolumnsformula[columnname].includes(that.baseColumn)) {
        tmpflag = 'yes';
    }
    ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpinfo) {
        if (tmpflag == 'no') {
            //zkt 20221205 BUG0059250从销售订单中选择报价单，产品会重新计算税额从报价单详情见面下推销售订单才显示正常
            that.haveFinishedFormulaColumnsarr.push(that.baseColumn);
            that.finishedcolumncount[that.baseColumn] =4;

        }
        that.changedatabyColumnname(columnname, tmpindex + 1);
    })
    /* ld.each(trobjs,function(){

             var rowindex=ld(this).attr("rowindex");


            if(tmpflag == 'no'){
                //zkt 20221205 BUG0059250从销售订单中选择报价单，产品会重新计算税额从报价单详情见面下推销售订单才显示正常
                that.haveFinishedFormulaColumnsarr.push(that.baseColumn);
                that.finishedcolumncount[that.baseColumn]=2;

            }
            that.changedatabyColumnname(columnname,rowindex);


     })*/

    this.CountsubTotal();

}
fieldFormula.prototype.changedatabyColumnname = function (columnname, rowindex) {
    /*var tableobj=this.popupobj.getDetailTableObj();

         var rowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");

         var htmlobj=ld(rowobj).find(" [name="+columnname+"]");  //document.getElementById(columnname+rowindex);
         if(ld(htmlobj).length<=0)
         {
            //edit:can  2021-01-04 44079: （http://xiaoshou360.com/xs/hzhengqi [^]）销售-合同订单（王杰客户问题）；合同订单新增时，产品分录中选择产品后，界面一直转圈
            return ;
         }*/
    if (this.popupobj.detaildatavalue_arr[rowindex - 1] == undefined||this.popupobj.detaildatavalue_arr[rowindex - 1][columnname] == undefined) {
        return;
    }
    this.cur_input_focus_obj = columnname;
    this.haveFinishedFormulaColumnsarr.push(columnname);
    this.finishedcolumncount[columnname] =4;//columnname 应该不计算对应值设置为4

    this.CountRowFormulaColumn(rowindex);
    
 
  


}

/**
 edit:can
 reason:折扣价改变(例如改变币种)
 **/
fieldFormula.prototype.changediscountpercent = function () {
    var tableobj = this.popupobj.getDetailTableObj();
    var trobjs = this.popupobj.getTrObjsByDelType('no');
    ld.each(trobjs, function () {
        var rowindex = ld(this).attr("rowindex");

        var htmlobj = ld(this).find(" [name=discount_percent]");
        that.haveFinishedFormulaColumnsarr.push('discount_percent');
        if (that.finishedcolumncount['discount_percent'] == undefined) {
            that.finishedcolumncount['discount_percent'] = 1;
        } else {
            that.finishedcolumncount['discount_percent'] = parseInt(that.finishedcolumncount['discount_percent']) + 1;
        }
        that.cur_input_focus_obj = 'discount_percent';
        that.CountRowFormulaColumn(rowindex);
        that.haveFinishedFormulaColumnsarr = [];
        that.finishedcolumncount = [];

    })
    that.CountsubTotal();//小计
    /*var rowcnt =ld("#"+this.popupobj.divid+" [name=rowcnt]").val();// document.getElementById('rowcnt').value;
     for(var i=1;i<=rowcnt;i++)
     {

        var htmlobj=ld("#"+this.popupobj.divid+" [name=discount_percent"+i+"]").get(0); //document.getElementById('discount_percent'+i);
          this.cur_input_focus_obj=htmlobj;
           this.CountRowFormulaColumn(i);
     }*/

}

/**
 edit:can
 reason:不含税单价改变(例如改变币种)
 **/
fieldFormula.prototype.changetaxprice = function () {
    var that = this;
    var tableobj = this.popupobj.getDetailTableObj();
    var trobjs = this.popupobj.getTrObjsByDelType('no');

    ld.each(trobjs, function () {
        var rowindex = ld(this).attr("rowindex");

        var htmlobj = ld(this).find(" [name=taxprice]:first");

        that.haveFinishedFormulaColumnsarr.push(ld(htmlobj).attr("name"));
        if (that.finishedcolumncount[ld(htmlobj).attr("name")] == undefined) {
            that.finishedcolumncount[ld(htmlobj).attr("name")] = 1;
        } else {
            that.finishedcolumncount[ld(htmlobj).attr("name")] = parseInt(that.finishedcolumncount[ld(htmlobj).attr("name")]) + 1;
        }
        that.cur_input_focus_obj = "taxprice";

        that.CountRowFormulaColumn(rowindex);

        that.haveFinishedFormulaColumnsarr = [];
        that.finishedcolumncount = [];
    })


    /*var rowcnt =ld("#"+this.popupobj.divid+" [name=rowcnt]").val();
     for(var i=1;i<=rowcnt;i++)
     {
        var htmlobj=ld("#"+this.popupobj.divid+" [name=taxprice"+i+"]").get(0);//document.getElementById('taxprice'+i);
          this.cur_input_focus_obj=htmlobj;

           this.CountRowFormulaColumn(i);
     }*/

}
/**
 edit:can
 reason:调用公式重新计算(所有行)
 **/
fieldFormula.prototype.CountFormulaColumn = function () {
    var that = this;
    // var tableobj=this.popupobj.getDetailTableObj();

    var trobjs = this.popupobj.getTrObjsByDelType('no');
    
    ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpinfo) {

        that.haveFinishedFormulaColumnsarr.push(that.baseColumn);
        that.finishedcolumncount[that.baseColumn] = 4;
        that.cur_input_focus_obj = that.baseColumn;

        that.CountRowFormulaColumn(tmpindex + 1);

        //CountRowFormulaColumn中包含下面值的清空
        /*that.haveFinishedFormulaColumnsarr = [];
        that.finishedcolumncount = [];*/

    })
    /*
     ld.each(trobjs,function(){
        var rowindex=ld(this).attr("rowindex");

        var htmlobj=ld(this).find(" [name="+that.baseColumn+"]");
        that.haveFinishedFormulaColumnsarr.push(ld(htmlobj).attr("name"));
        if(that.finishedcolumncount[ld(htmlobj).attr("name")]==undefined)
        {
            that.finishedcolumncount[ld(htmlobj).attr("name")]=1;
        }
        else{
            that.finishedcolumncount[ld(htmlobj).attr("name")]=parseInt(that.finishedcolumncount[ld(htmlobj).attr("name")])+1;
        }
        that.cur_input_focus_obj=that.baseColumn;
          that.getBeforeRowValue_arr(ld(this))
        that.CountRowFormulaColumn(rowindex);


        that.haveFinishedFormulaColumnsarr=[];
        that.finishedcolumncount=[];
     })*/


    that.CountsubTotal();//小计行
    //this.tableobj.rows.length-1;
    /*  var rowcnt =ld("#"+this.popupobj.divid+" [name=rowcnt]").val();

     for(var i=1;i<=rowcnt;i++)
     {
        //22810: 合同订单>明细：当税率为17，含税单价为720时，关联创建采购订单。结果：采购订单的不含税单价显示为719.99.
        //
          this.popupobj.fieldformulaobj.cur_input_focus_obj=ld("#"+this.popupobj.divid+" [name="+this.baseColumn+i+"]").get(0);//document.getElementById(this.baseColumn+i);

          this.CountRowFormulaColumn(i);
     }*/

}
fieldFormula.prototype.setIntervalFormula = function (prevrowindex, lastrowindex) {

    var that = this;
    var tableobj = this.popupobj.getDetailTableObj();
    var trobjs = this.popupobj.getTrObjsByDelType('no');
    ld.each(trobjs, function () {
        var rowindex = ld(this).attr("rowindex");

        var htmlobj = ld(this).find(" [name=" + that.baseColumn + "]");
        that.haveFinishedFormulaColumnsarr.push(ld(htmlobj).attr("name"));
        if (that.finishedcolumncount[ld(htmlobj).attr("name")] == undefined) {
            that.finishedcolumncount[ld(htmlobj).attr("name")] = 1;
        } else {
            that.finishedcolumncount[ld(htmlobj).attr("name")] = parseInt(that.finishedcolumncount[ld(htmlobj).attr("name")]) + 1;
        }
        that.cur_input_focus_obj = htmlobj;
        that.CountRowFormulaColumn(rowindex);

    })

    /*
    var rowcnt =parseInt(ld("#"+this.popupobj.divid+" [name=rowcnt]").val(),10);
        prevrowindex+=1;


     for(var i=prevrowindex;i<=lastrowindex&&i<=rowcnt;i++)
     {
        //22810: 合同订单>明细：当税率为17，含税单价为720时，关联创建采购订单。结果：采购订单的不含税单价显示为719.99.

          fieldformulaobj.cur_input_focus_obj=ld("#"+this.popupobj.divid+" [name="+this.baseColumn+i+"]").get(0);//document.getElementById(this.baseColumn+i);
          this.CountRowFormulaColumn(i);
     }*/


}
//日期相减
fieldFormula.prototype.DateDiff = function (sDate1, sDate2) {  //sDate1和sDate2是yyyy-MM-dd格式

    var aDate, oDate1, oDate2, iDays;
    aDate = sDate1.split(" ");
    if (aDate.length > 1) {
        oDate1 = new Date(aDate[0]);
    } else {
        oDate1 = new Date(sDate1);
    }
    aDate = sDate2.split(" ");
    if (aDate.length > 1) {
        oDate2 = new Date(aDate[0]);
    } else {
        oDate2 = new Date(sDate2);
    }
    iDays = parseInt(Math.abs(oDate1 - oDate2) / 1000 / 60 / 60 / 24); //把相差的毫秒数转换为天数

    return iDays;  //返回相差天数
}
/**
 edit:can
 reason: 指定行所有字段公式的计算
 **/
fieldFormula.prototype.CountRowFormulaColumn = function (id_index) {

    var that = this;
 
    
        if(this.popupobj.detaildatavalue_arr.length>=id_index)
        {
             var productid = this.popupobj.detaildatavalue_arr[id_index - 1].productid;
             if(productid<=0||productid==undefined)
                return;
        }
        else
            return ;
   
    
    var fieldformulaobj = this.popupobj.fieldformulaobj;
    var len = this.formulaneedColumnarr.length;
    //console.log(this.formulaneedColumnarr)
    var haveformulacolumn_arr = [];
    
   /* setTimeout(function(){
              
           
        
    },100)*/
   for (var k = 0; k < len; k++) {
    
            if (that.formulaneedColumnarr[k] == '')
                continue;
    
            if (that.popupobj.detaildatavalue_arr[id_index - 1][that.formulaneedColumnarr[k]] == undefined)
                continue;
           /* duan 20230720 BUG0069813:修复分录选择产品后,部分字段公式不计算的问题
           if (that.hadtrigger_column_arr[that.formulaneedColumnarr[k]] != undefined ) {
                     continue
           }
           */
            fieldformulaobj.cur_formula_obj = that.formulaneedColumnarr[k];
            fieldformulaobj.setValueByFormula(that.formulaneedColumnarr[k], id_index);
    
        }
        
            that.popupobj.detail2mainformulaobj.changeRowEvent();
        that.haveFinishedFormulaColumnsarr = [];
        that.finishedcolumncount = [];
        that.changevaluefield_arr = [];
        that.hadtrigger_column_arr=[];



}
/**
 edit:zkt
 reason: 根据触发字段计算所在行对应字段公式
 **/
fieldFormula.prototype.changeRowDatabyColumnname = function (columnname) {

    var fieldformulaobj = this.popupobj.fieldformulaobj;
    var that = this;
    var tmpflag = 'no';
    ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpinfo) {
        if (that.popupobj.detaildatavalue_arr[tmpindex] == undefined||that.popupobj.detaildatavalue_arr[tmpindex][columnname] == undefined) {
            return;
        }
        that.cur_input_focus_obj = columnname;
        that.haveFinishedFormulaColumnsarr.push(columnname);
        that.finishedcolumncount[columnname] =4;//columnname 应该不计算对应值设置为4
        that.CountRowFormulaColumnbycolumn(columnname, tmpindex + 1);
    })

    this.CountsubTotal();

}
/**
 edit:zkt
 reason: 指定行指定字段-字段公式的计算
 **/
fieldFormula.prototype.CountRowFormulaColumnbycolumn = function (columnname,id_index) {

    var that = this;

    if(this.popupobj.detaildatavalue_arr.length>=id_index)
    {
        var productid = this.popupobj.detaildatavalue_arr[id_index - 1].productid;
        if(productid<=0||productid==undefined)
            return;
    }
    else
        return ;

    var fieldformulaobj = this.popupobj.fieldformulaobj;

    var tmpcomputercolumnsformula = that.computercolumnsformula;

    var computercolumnsarr = new Array();
    computercolumnsarr.push(columnname);

    if(that.computercolumnsformula[columnname] != undefined&&that.computercolumnsformula[columnname].length>0){
        var tmpcomputercolumnsformula = that.computercolumnsformula[columnname];
        for(var i=0;i<tmpcomputercolumnsformula.length;i++){
            var tmpcolumnname = tmpcomputercolumnsformula[i]
            if(!computercolumnsarr.includes(tmpcolumnname)){
                computercolumnsarr.push(tmpcolumnname);
            }
        }
    }

    var len = computercolumnsarr.length;

    for (var k = 0; k < len; k++) {

        if (computercolumnsarr[k] == '')
            continue;

        if (that.popupobj.detaildatavalue_arr[id_index - 1][computercolumnsarr[k]] == undefined)
            continue;
        fieldformulaobj.cur_formula_obj = computercolumnsarr[k];
        fieldformulaobj.setValueByFormula(computercolumnsarr[k], id_index);

    }

    that.popupobj.detail2mainformulaobj.changeRowEvent();
    that.haveFinishedFormulaColumnsarr = [];
    that.finishedcolumncount = [];
    that.changevaluefield_arr = [];
    that.hadtrigger_column_arr=[];
}
 
 
fieldFormula.prototype.CountsubTotalByRow = function (rowobj) {
    var that = this;
    that.CountsubTotal();
    return false;
    var that = this;


    var subtotal = 0;


    if (this.subtotalfieldobj.length <= 0)
        return;
    var nullfield = this.module_nullfield.split('##');
    var len = this.subtotalfieldobj.length;
 
    var nullfield_num = 0;
    var nullfieldname;

    for (var j = 0; j < len; j++) {

        //循环列
        var fieldinfo = this.subtotalfieldobj[j];
        subtotal = 0;//不能删除这个语句，具体原因递归了，将来一定不能删除，edit:can
        if (fieldinfo.newline != 0) {
            continue;
        }
        //   if(fieldinfo.columnname!="quantity")
        //continue;
        if (fieldinfo.columnname == 'unit_price' && fieldinfo.tablename == 'ld_products') {
            continue;
        }
        var strid = fieldinfo.columnname;
        var tmpobjsubtotal = ld("#" + this.popupobj.divid + " [name=subtotal_" + strid + "]");

        if (tmpobjsubtotal.length <= 0)
            continue;

        subtotal = parseFloat(ld(tmpobjsubtotal).html(), 10);


        var objs = ld(rowobj).find("#" + strid);


        if (ld(objs).is("td")) {
            var value = trim(ld(objs).html());//盘点（账面数量)
        } else {
            var value = ld(objs).val();
        }

        //  subtotal=subtotal-parseFloat(that.beforerowvalue_arr[fieldinfo.columnname]);
        if (trim(subtotal + "") == '' || isNaN(subtotal)) {
            subtotal = 0;
        }

        if (trim(value) == "" || isNaN(value)) {

            value = 0;

        }
        subtotal += parseFloat(value, 10) - parseFloat(that.beforerowvalue_arr[fieldinfo.columnname]);
        //30467: 合同订单新增界面：产品信息中-总库存数量、最低库存、参考成本价字段值小数位数不正确
        if ((fieldinfo.uitype >= 10 && fieldinfo.uitype <= 15) || (fieldinfo.columnname == 'qtyinstock' || fieldinfo.columnname == 'qtyearly'))//数量
        {

            tmpobjsubtotal.html(parseFloat(subtotal, 10).toFixed(this.lengthDecimaldigits))
        } else if (fieldinfo.uitype == 20 || ((fieldinfo.tablename == 'ld_products' || fieldinfo.tablename == 'ld_productcf') && fieldinfo.uitype == 7)) {
            var stypeofdata = fieldinfo.typeofdata.split(',');
            //	tmpobjsubtotal.get(0).innerHTML=parseFloat(subtotal,10).toFixed(stypeofdata[1]);
            tmpobjsubtotal.html(parseFloat(subtotal, 10).toFixed(stypeofdata[1]))
        } else if (fieldinfo.uitype == 163 || fieldinfo.columnname == 'costprice') {//单价
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(this.lengthPrice);

        } else if (fieldinfo.uitype == 24) {//整数
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10);

        } else if (fieldinfo.uitype == 37) {
            var stypeofdata = fieldinfo.typeofdata.split(',');
            var typeofdata_decimal = stypeofdata[1];
            if (typeofdata_decimal == '' || typeofdata_decimal == undefined) {
                typeofdata_decimal = 2;
            }
            var tmpobjsubtotal_detail = ld("#" + this.popupobj.divid + " [name=subtotal_productdetail_" + fieldinfo.columnname + "]");//document.getElementById('subtotal_productdetail_'+fieldinfo.columnname);
            //折扣额
            if (fieldinfo.uitype == 37) {
                if (tmpobjsubtotal_detail.length <= 0)
                    continue;
            }
            tmpobjsubtotal_detail.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(typeofdata_decimal);
        } else {

            tmpobjsubtotal.html(parseFloat(subtotal, 10).toFixed(2));
        }

        subtotal = 0;
    }
//	 if(this.popupobj.module.toLowerCase() !== 'productbom'){

    calcTotal();//计算调整，折扣，函数金额合计
}
/**
 edit:can
 reason:小计（包括计算合计,整单折扣)
 **/
fieldFormula.prototype.CountsubTotal = function () {
    var that = this;
    var subtotal = 0;
    var parentobj = ld("#" + this.popupobj.divid);
    if (this.ismasscount == 'yes') {
        return false;
    }

    var typeofdata_decimal = 2;
    ld.each(that.subtotalfieldobj, function (subtotalindex, fieldinfo) {
        subtotal = 0;//不能删除这个语句，具体原因递归了，将来一定不能删除，edit:can
        if (fieldinfo.newline != 0) {
            return true;
        }
        if (fieldinfo.columnname == 'unit_price' && fieldinfo.tablename == 'ld_products') {
            return true;
        }
        var strid = fieldinfo.columnname;
        //zkt 20230720 BUG0069585 折扣额小计未计算
        var subtotalname = strid;
        if (fieldinfo.uitype == 37) {
            //zkt 20230720 折扣额字段对应小计值为fieldname值
            var subtotalname = 'productdetail_'+strid;
        }
        var tmpobjsubtotal = ld(parentobj).find(" [name=subtotal_" + subtotalname + "]:first");
        
        //税率不做小计
        if (tmpobjsubtotal.length <= 0||fieldinfo.uitype ==21)
            return true;
        if (fieldinfo.uitype >= 25 && fieldinfo.uitype <= 50) {
            var tmptypeofdata = fieldinfo.typeofdata;
            if (tmptypeofdata != undefined) {
                var tmptypeofdatas = tmptypeofdata.split(',');
                if (tmptypeofdatas.length > 1)
                    typeofdata_decimal = tmptypeofdatas[1];
            }
        }
        if (typeofdata_decimal == '') {
            typeofdata_decimal = 2;
        }
        ld.each(that.popupobj.detaildatavalue_arr, function (tmpvalueindex, tmpvalueinfo) {
            //空行不计算小计  有产品id的才计算小计
            if (!isNaN(tmpvalueinfo[strid]) && tmpvalueinfo[strid] != '' && tmpvalueinfo.productid > 0)
                subtotal += Number(tmpvalueinfo[strid]);
        })
        if(fieldinfo.subtotal_attr != 'yes'){
            return true;
        }
        //30467: 合同订单新增界面：产品信息中-总库存数量、最低库存、参考成本价字段值小数位数不正确
        if ((fieldinfo.uitype >= 10 && fieldinfo.uitype <= 15) || (fieldinfo.columnname == 'qtyinstock' || fieldinfo.columnname == 'qtyearly'))//数量
        {

            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(that.lengthDecimaldigits);
        } else if (fieldinfo.uitype == 37) {
            //折扣额
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(typeofdata_decimal);
        } else if (fieldinfo.uitype == 20 || (fieldinfo.uitype >= 25 && fieldinfo.uitype <= 50) || ((fieldinfo.tablename == 'ld_products' || fieldinfo.tablename == 'ld_productcf') && fieldinfo.uitype == 7)) {
            var stypeofdata = fieldinfo.typeofdata.split(',');
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(stypeofdata[1]);
        } else if (fieldinfo.uitype == 163 || fieldinfo.columnname == 'costprice') {//单价
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10).toFixed(that.lengthPrice);

        } else if (fieldinfo.uitype == 24) {//整数
            tmpobjsubtotal.get(0).innerHTML = parseFloat(subtotal, 10);

        }  else {

            tmpobjsubtotal.html(parseFloat(subtotal, 10).toFixed(typeofdata_decimal));
        }

    })
    calcTotal();//计算调整，折扣，函数金额合计
    return;


    /*
     var trobjs=this.popupobj.getTrObjsByDelType('no');
    var tableobj=this.popupobj.getDetailTableObj();

     if(this.subtotalfieldobj.length<=0)
                return ;
     var nullfield = this.module_nullfield.split('##');
    var len=this.subtotalfieldobj.length;
    var nullfield_num = 0;
    var nullfieldname;

    var rowcnt=trobjs.length;
     for(var j=0;j<4;j++)
     {
            //循环列
             var fieldinfo=this.subtotalfieldobj[j];
             subtotal=0;//不能删除这个语句，具体原因递归了，将来一定不能删除，edit:can
             if(fieldinfo.newline!=0)
             {
                continue;
             }
             if(fieldinfo.columnname=='unit_price'&&fieldinfo.tablename=='ld_products'){
                continue;
             }
           	 var strid=fieldinfo.columnname;
		     var tmpobjsubtotal=ld(parentobj).find(" [name=subtotal_"+strid+"]:first");

            if(tmpobjsubtotal.length<=0)
                continue;


              for(var i=0;i<rowcnt;i++)

            {
                //循环行

					 var tmprowobj=trobjs[i];

					 var objs=ld(tmprowobj).find("#"+strid);

					 if(ld(objs).length<=0)
					 {
					   objs=ld(this).find("#"+strid);
						var value=trim(objs.innerHTML);//盘点（账面数量)
					 }
					 else
					 {
						var value=ld(objs).val();
					 }

					 if(trim(value)!="")
					 {

						subtotal+=Number(value);
					 }
				 //}
             }



            var typeofdata_decimal = 2;
           if(fieldinfo.uitype >=25 && fieldinfo.uitype<=50 ){
                var tmptypeofdata = fieldinfo.typeofdata;
                if(tmptypeofdata!=undefined)
                {
                    var tmptypeofdatas=tmptypeofdata.split(',');
                    if(tmptypeofdatas.length>1)
                       typeofdata_decimal=tmptypeofdatas[1];
                }
           }
           if(typeofdata_decimal == ''){
                typeofdata_decimal = 2;
            }
            if(isNaN(subtotal))
            {
                subtotal=0;
            }
             //30467: 合同订单新增界面：产品信息中-总库存数量、最低库存、参考成本价字段值小数位数不正确
             if((fieldinfo.uitype>=10&&fieldinfo.uitype<=15)||(fieldinfo.columnname=='qtyinstock'||fieldinfo.columnname=='qtyearly'))//数量
             {

                tmpobjsubtotal.get(0).innerHTML=parseFloat(subtotal,10).toFixed(this.lengthDecimaldigits);
             }else if(fieldinfo.uitype == 20||(fieldinfo.uitype >= 25&&fieldinfo.uitype <= 50)||((fieldinfo.tablename=='ld_products'||fieldinfo.tablename=='ld_productcf')&&fieldinfo.uitype==7)){
				var stypeofdata = fieldinfo.typeofdata.split(',');
				tmpobjsubtotal.get(0).innerHTML=parseFloat(subtotal,10).toFixed(stypeofdata[1]);
			 }else if(fieldinfo.uitype==163||fieldinfo.columnname=='costprice'){//单价
                tmpobjsubtotal.get(0).innerHTML=parseFloat(subtotal,10).toFixed(this.lengthPrice);

             }else if(fieldinfo.uitype==24){//整数
                tmpobjsubtotal.get(0).innerHTML=parseFloat(subtotal,10);

             }
             else if(fieldinfo.uitype==37)
             {
                  var tmpobjsubtotal_detail=ld("#"+this.popupobj.divid+" [name=subtotal_productdetail_"+fieldinfo.columnname+"]");//document.getElementById('subtotal_productdetail_'+fieldinfo.columnname);
                    //折扣额
                    if(fieldinfo.uitype==37)
                      {
                        if(tmpobjsubtotal_detail.length<=0)
                            continue;
                      }
                    tmpobjsubtotal_detail.get(0).innerHTML=parseFloat(subtotal,10).toFixed(typeofdata_decimal);
             }
             else
             {

                tmpobjsubtotal.html(parseFloat(subtotal,10).toFixed(typeofdata_decimal));
             }

             subtotal=0;
     }*/

//	 if(this.popupobj.module.toLowerCase() !== 'productbom'){

    //calcTotal();//计算调整，折扣，函数金额合计
    /*	 }else{
		calcBomTotal();//套餐售价
	 }*/
}
//反算公式计算
fieldFormula.prototype.reverseformual_fun = function (id_rowIndex, cur_columnname) {

    //  return false;
    var tableobj = this.popupobj.getDetailTableObj();
    var rowobj = ld(tableobj).find("tr[rowindex=" + id_rowIndex + "]");
    var rowvalueinfo = this.popupobj.detaildatavalue_arr[id_rowIndex - 1];
    if (this.reversecolumnformula == undefined || this.reversecolumnformula[cur_columnname] == undefined) {
        return false;
    }
    var popupobj = this.popupobj;

    if (ld(rowobj).find("#hdnProductId").val() <= 0) {
        return false;
    }
    var reverseformulalen = this.reversecolumnformula[cur_columnname].length;

    for (var k = 0; k < reverseformulalen; k++) {


        strformula = '';
        //引发计算的字段在需要计算字段中
        if (this.reversecolumns.includes(cur_columnname)) {

            var formulastring = ld.trim(this.reversecolumnformula[cur_columnname][k].formulastring);//获取字段公式
            var reverseobj = this.reversecolumnformula[cur_columnname][k];

            var formulastringlen = formulastring.length;
            for (var i = 0; i < formulastringlen; i++) {
                var onechar = formulastring.substr(i, 1);
                if (onechar == '') {
                    continue;
                }

                if (letters.includes(onechar))//如果是变量
                {
                    var fieldhtmlobj = ld(rowobj).find("#" + reverseobj.letters[onechar]);//document.getElementById(reverseobj.letters[onechar]+""+id_rowIndex);

                    if (fieldhtmlobj.length <= 0) {

                        strformula += "0";
                        continue;
                    }
                    if (this.isDateColumn(reverseobj.letters[onechar]) == 'yes') {

                        return "0";
                    } else {
                        if (ld.trim(fieldhtmlobj.val()) == '') {
                            fieldhtmlobj.val(0);
                        }

                        //如果计算的值为负数，则计算不成功    如a-b b为负数
                        //var tmpobj = ld(rowobj).find("#" + reverseobj.letters[onechar]);// document.getElementById(this.reversecolumnformula[cur_columnname][k].letters[onechar]+""+id_rowIndex)
                        if (eval(rowvalueinfo[reverseobj.letters[onechar]]==undefined)) {
                            strformula += '(' + eval(this.setFieldLenDecimal(reverseobj.letters[onechar], 0)) + ')';
                        } else {

                            strformula += this.setFieldLenDecimal(reverseobj.letters[onechar], rowvalueinfo[reverseobj.letters[onechar]]);
                        }

                    }

                } else if (ld.inArray(onechar, chineseBrackets) >= 0)//如果中文括号
                {
                    if (onechar == chineseleftbracket)//中文左括号
                    {
                        strformula += '(';
                    } else if (onechar == chineserightbracket) {
                        strformula += ')';
                    }
                } else {
                    strformula += onechar;
                }
            }

            try {

               // var tmp_cur_obj = ld(rowobj).find("#" + reverseobj.columnname);


                //if (tmp_cur_obj.length <= 0) {
                    //如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                  //  continue;
                //}
                if(rowvalueinfo[reverseobj.columnname]==undefined)
                    continue;
                var typeofdata_decimal = 2;
                if (reverseobj.uitype >= 25 && reverseobj.uitype <= 50) {
                    var tmptypeofdata = reverseobj.typeofdata;
                    if (tmptypeofdata != undefined) {
                        var tmptypeofdatas = tmptypeofdata.split(',');
                        if (tmptypeofdatas.length > 1)
                            typeofdata_decimal = tmptypeofdatas[1];
                    }

                }
                if (typeofdata_decimal == '') {
                    typeofdata_decimal = 2;
                }
              //  cur_obj = tmp_cur_obj.get(0);
                if (reverseobj.columnname == 'taxprice' || reverseobj.columnname == 'listprice' || reverseobj.uitype == 163) {
                    rowvalueinfo[reverseobj.columnname] = parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
                } else {
                    if (reverseobj.uitype >= 10 && reverseobj.uitype < 15) {
                        rowvalueinfo[reverseobj.columnname] = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
                    } else if (reverseobj.uitype == 20 || reverseobj.uitype == 15) {
                        //数字类型字段根据小数位数控制,折扣率
                        var stypeofdata = reverseobj.typeofdata.split(',');

                        rowvalueinfo[reverseobj.columnname] = parseFloat(eval(strformula), 10).toFixed(stypeofdata[1]);
                    } else if (reverseobj.uitype == 24) {
                        rowvalueinfo[reverseobj.columnname]= parseFloat(eval(strformula));
                    } else {
                        //toFixed
                        //含税单价47245.7x0.05=2362.285，四舍五入应该是2362.29，
                        rowvalueinfo[reverseobj.columnname] = JsNumbertoFixed(parseFloat(eval(strformula), 10), typeofdata_decimal);
                    }

                }


                if (isNaN(rowvalueinfo[reverseobj.columnname]) || rowvalueinfo[reverseobj.columnname] == 'Infinity' ||rowvalueinfo[reverseobj.columnname] == '-Infinity') {
                    rowvalueinfo[reverseobj.columnname] = 0;
                }
                //zkt 20240626 BUG20240619-18  明细行选择产品并填写价税合计后不能正常在表头计算未税合计（kfbcrm也有问题，选产品后输入价税合计）
                this.changevaluefield_arr.push(reverseobj.columnname);
                tmp_cur_obj = ld(rowobj).find("#span_" + reverseobj.columnname);
                if (tmp_cur_obj.length > 0) {
                  rowvalueinfo[reverseobj.columnname+"_name"]=rowvalueinfo[reverseobj.columnname]
                }

                //分录调用字段公式后,触发公共事件
                popupobj.common_field_event_obj.common_entry_changefun('',reverseobj.columnname,id_rowIndex);

            } catch (ex) {

            }
        }
    }
}
/*if(fieldinfojson!=undefined)
{

    var fieldformulaobj=new fieldFormula(fieldinfojson);

}*/

var dateoperations = new Array('+', '-');
var operations = new Array('+', '-', '*', '/', '%');
var Brackets = new Array('(', ')', '[', ']');
var chineseBrackets = new Array('（', '）');//支持中文括号，单不支持中文【
var chineseleftbracket = '（';
var chineserightbracket = '）';
var digits = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
var letters = new Array('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'w', 'x', 'y', 'z'
    , 'Z', 'Y', 'X', 'U', 'V', 'W', 'T', 'S', 'R', 'Q', 'L');


