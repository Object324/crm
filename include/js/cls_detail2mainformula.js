function cls_detail2mainformula(formulainfo) {
    this.popupobj = CrmPopup.getPopupObj('last');
    this.computerdetailcolumn_arr = [];
    this.computercolumnfunctiontype_arr = [];
    var that = this;
    this.setPopupobj = function (popupobj) {
        this.popupobj = popupobj;
    }
    that.maincolumninfo = [];
    this.detailtableobj;
    this.formulainfo = formulainfo;
    this.init = function () {
        //if(this.popupobj.module!='ServiceContracts')
        // return false;
        this.detailtableobj = this.popupobj.getDetailTableObj();
        ld.each(that.popupobj.fields, function (detailindex, detailfieldinfo) {

            that.maincolumninfo[detailfieldinfo.columnname] = detailfieldinfo;
        });
        console.log(this.formulainfo);
        if (this.formulainfo != undefined)
            ld.each(this.formulainfo, function (tmpindex, tmpinfo) {
                if (tmpinfo.functiontype == '' || tmpinfo.functiontype == 'sql'||tmpinfo.functiontype==undefined)
                    return true;
                if (that.computercolumnfunctiontype_arr[ld.trim(tmpinfo.columnstring)] == undefined)
                    that.computercolumnfunctiontype_arr[ld.trim(tmpinfo.columnstring)] = [];
                that.computercolumnfunctiontype_arr[ld.trim(tmpinfo.columnstring)].push(tmpinfo);
                that.computerdetailcolumn_arr.push(ld.trim(tmpinfo.columnstring))
            });
    }

    this.setEvent = function () {
        // if(this.popupobj.module!='ServiceContracts')
        // return false;
        var trobjs = this.popupobj.getTrObjsByDelType('no');
        that.trobjs = trobjs;
        ld.each(trobjs, function () {
            var trobj = ld(this);
            that.setRowEvent(ld(trobj).attr("rowindex"));


        });

    }
    this.changeRowEvent = function () {
        //分录新增行，删除行

        //  if(this.popupobj.module!='ServiceContracts')
        // return false;

        ld.each(that.computerdetailcolumn_arr, function (tmpindex, tmpcolumn) {
            var param = [];
            param['data'] = {'formulacolumn': tmpcolumn};
            that.startComputer(param);

        });

    }
    this.setRowEvent = function (idrow_index) {

        // if(this.popupobj.module!='ServiceContracts')
        //  return false;

        var trobj = $(this.detailtableobj).find("tr[rowindex=" + idrow_index + "]");
        var typeofdata = '';

        ld.each(that.computerdetailcolumn_arr, function (tmpindex, tmpcolumn) {

            typeofdata = '';
            var tmpobj = ld(trobj).find(' #' + tmpcolumn);////ld("#"+that.popupobj.divid+" [name="+tmpcolumn+rowindex+"]")
            var fieldinfo = that.popupobj.detailfieldcolumninfo[tmpcolumn];
            if (fieldinfo != undefined)
                typeofdata = fieldinfo.typeofdata;

            if (typeofdata.toLocaleLowerCase().indexOf("d~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("dt~") >= 0) {
                //edit:can 57660:、服务合同增加字段“最晚服务到期日”，字段属性取分录“服务截止日期”最大值。选择产品后，修改“服务截止日期”，“最晚服务到期日”没有重算
                tmpobj.unbind("blur", that.startComputer)

                tmpobj.bind("blur", {formulacolumn: tmpcolumn, rowindex: idrow_index}, that.startComputer);
            } else {
                tmpobj.unbind("change", that.startComputer)

                tmpobj.bind("change", {formulacolumn: tmpcolumn, rowindex: idrow_index}, that.startComputer);
            }

        })
    }
    this.CheckisComputer = function (column_arr) {
        //  if(this.popupobj.module!='ServiceContracts')
        //return false;
        arr = column_arr.sort()

        var arrry = [arr[0]];

        for (var i = 1; i < arr.length; i++) {

            if (arr[i] !== arr[i - 1]) {

                arrry.push(arr[i]);

            }

        }
        column_arr = arrry;
        // console.log(column_arr);
        ld.each(column_arr, function (tmpindex, tmpcolumn) {

            var param = [];
            param['data'] = {'formulacolumn': tmpcolumn};
            that.startComputer(param);
        })
    }
    this.startComputer = function (event) {
        var formulacolumn = event.data.formulacolumn;

        if (that.computercolumnfunctiontype_arr[formulacolumn] == undefined)
            return;
        that.trobjs = that.popupobj.getTrObjsByDelType('no');
        
        //zkt 20230427 带有分录函数，编辑界面js报错 BUG0065706 新建一个回款与回款拆分单据保存后，再编辑，点击保存就没有反应。 
        if(that.popupobj.fieldformulaobj != undefined){
            if (that.popupobj.fieldformulaobj.ismasscount == 'yes')
                return;
        }
        var fieldinfoobj = new fieldinfo(that.popupobj);
        var needcomputedfieldname_arr = [];
        var need_NumbertoFixed = 'no';
        ld.each(that.computercolumnfunctiontype_arr[formulacolumn], function (tmpindex, tmpinfo) {
            var needcomputedfieldname = tmpinfo.fieldname;


            if (ld("#" + that.popupobj.divid + " [name=" + needcomputedfieldname + "]").length <= 0)
                return true;

            need_NumbertoFixed = 'no';
            switch (tmpinfo.functiontype.toLowerCase()) {
                case 'avg':
                    var value = that.getAvg(formulacolumn);
                    need_NumbertoFixed = 'yes';
                    break;
                case 'max':

                    var value = that.getmax(formulacolumn);
                    break;
                case 'min':
                    var value = that.getmin(formulacolumn);
                    break;
                case  'sum':
                    var value = that.getSum(formulacolumn);
                    need_NumbertoFixed = 'yes';
                    break;
                case 'count':
                    var value = that.getCount(formulacolumn);
                    break;
                case 'first':
                    var value = that.getFirst(formulacolumn);
                    break;
                case  'last':
                    var value = that.getLast(formulacolumn);
                    break;
                case 'countdistinct':
                    var value = that.getCountDistinct(formulacolumn);
                    break;

            }
            //ls 20220920 BUG0056770 单据分录新增字段整数，单据头新增字段0位小数，取分录新增字段的最新值。结果单据头取到的字段小数位数显示2为，导致单据无法保存(默认小数长度为2的原因)
            var tmpobj = ld("#" + that.popupobj.divid + " [name=" + needcomputedfieldname + "]");
            var needcomputedtypeofdata = that.maincolumninfo[needcomputedfieldname].typeofdata;

            if (needcomputedtypeofdata.indexOf(',') > -1) {
                var tmplen = needcomputedtypeofdata.split(",")[1];
            } else {
                var tmplen = 2;
            }
            //edit:can 20230619 68357  项目汇报模块，分录如果新增一条新的，如果没有填写值，对应表头的字段不会更新为空。如项目风险、项目状况这两个字段对比。项目汇报单：PR2023061553如图
            var tmphavesetvalue = false;
            if ( value != '-99999999' && value != '99999999999') {
                var tmpvalue = value;
                // 2024-12-03 xxy need_NumbertoFixed另加参数表示需要数字格式化，有文本字段但是使用求和函数等情况
                if((fieldinfoobj.isFldNumOrMoney(that.maincolumninfo[needcomputedfieldname]) || need_NumbertoFixed == 'yes') && value != ''){//zkt 获取到的值不为空才格式化,否则界面显示NAN
                    //20230612 duan 判断表头字段为数字或金额字段时,才进行小数位转化
                    tmpvalue = JsNumbertoFixed(value, tmplen);
                }

                if(that.popupobj.fieldSensitiveruleobj != undefined){
                    var fieldSensitiveruleobj = that.popupobj.fieldSensitiveruleobj;
                    var needcomputedfieldinfo = fieldSensitiveruleobj.getFieldInfoByfieldname(needcomputedfieldname);
                    if(needcomputedfieldinfo && needcomputedfieldinfo.havesensitivevalue == 'yes')
                    {
                        //设置值和设置小数位数是分开的
                        var tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpvalue,false,needcomputedfieldinfo);//加密字段
                        fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                        tmpEncryptytvalue = that.popupobj.mainfieldformulaobj.setFieldLenDecimal(needcomputedfieldinfo);
                        tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpEncryptytvalue,false,needcomputedfieldinfo);//加密字段
                        fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                        tmphavesetvalue = true;
                    }
                }
                if(!tmphavesetvalue){
                    ld(tmpobj).val(tmpvalue);
                }
            }
            if(!tmphavesetvalue){
                that.popupobj.mainfieldformulaobj.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]);
                if (that.popupobj.fieldname_fields[needcomputedfieldname].allowedit == 'no') {
                    ld("#" + that.popupobj.divid + " [name=span_" + needcomputedfieldname + "]").html(ld(tmpobj).val());
                }
                needcomputedfieldname_arr.push(needcomputedfieldname);

                //duan 20240926字段变更后触发公共变化事件
                if(!empty(that.popupobj.common_field_event_obj)){
                    that.popupobj.common_field_event_obj.common_changefun(tmpobj,needcomputedfieldname);
                }
            }

        })
        //detailfieldcolumninfo

        //反向  计算公式
        that.popupobj.mainfieldformulaobj.hadcomputerfieldnames = [];
        ld.each(needcomputedfieldname_arr, function (tmpindex, needcomputedfieldname) {
            that.popupobj.mainfieldformulaobj.setvaluebyformula(needcomputedfieldname);

        })
        if(that.popupobj.fieldSensitiveruleobj != undefined && that.popupobj.fieldSensitiveruleobj.HaveSenditivefieldname(that.popupobj.mainfieldformulaobj.hadcomputerfieldnames)){
            that.popupobj.fieldSensitiveruleobj.getAllSensitiveData('');
        }
        that.popupobj.mainfieldformulaobj.hadcomputerfieldnames = [];
        that.popupobj.fieldruleobj.CheckReLoadPopup();

    }
    this.getAvg = function (detailcolumnname) {
        //平均值
        var total = 0;
        var realrows = 0;
        var strformula = '0';
        //zkt 20230404 BUG0064130 费用报销单“数字之和”（分录函数“数字”求和）字段没有计算
        if(that.popupobj.detailfieldmodule == 'Products'){
            //zkt 20230511 BUG0066252 报价单（货币）字段没有计算（货币是分录价税合计求取平均值）
            if (that.popupobj.detaildatavalue_arr == undefined || that.popupobj.detaildatavalue_arr[0][detailcolumnname] == undefined)
                return 0;
            ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpvalueinfo) {
                if (that.CheckisEmptyRow(that.trobjs[tmpindex]) == 'yes') {
                    return true;
                }
                if (ld.trim(tmpvalueinfo[detailcolumnname]) != '') {
                    strformula = strformula + "+" + tmpvalueinfo[detailcolumnname];

                }
                realrows += 1;

            })
            var total = eval(strformula);

            if (realrows > 0)
                total = total / realrows;
            return total;
        }

        ld.each(that.trobjs, function () {


            if (ld(this).find(" #" + detailcolumnname ).length <= 0) {
                return false;
            } else {
                if (that.CheckisEmptyRow(ld(this)) == 'yes') {
                    return true;
                }
            }
            var tmpcolumnobj = ld(this).find("#" + detailcolumnname );
            if (ld.trim(ld(tmpcolumnobj).val()) != '') {
                strformula = strformula + "+" + ld(tmpcolumnobj).val();

            }
            realrows += 1;

        })
        var total = eval(strformula);

        if (realrows > 0)
            total = total / realrows;
        return total;

    }
    this.getCount = function (detailcolumnname) {
        //计数
        var realrows = 0;

        ld.each(that.trobjs, function () {

            /*if(ld(this).find(" [detailcolumnname="+detailcolumnname+"]").length<=0)
            {
                //不需要判断
               return false;
            }
            else{*/
            if (that.CheckisEmptyRow(ld(this)) == 'yes') {
                return true;
            }
            //}

            realrows += 1;
        });
        return realrows;

    }
    this.getCountDistinct = function (detailcolumnname) {
        //去重计数
        var fieldvalue = '';
        var fieldvalue_arr = new Array();
        var realrows = 0;
        ld.each(that.trobjs, function () {
            if (that.CheckisEmptyRow(ld(this)) == 'yes')
                return true;
            edit_permission = that.popupobj.detailfieldcolumninfo[detailcolumnname].edit_permission;
            if (edit_permission === 1 || edit_permission == 2) {
                fieldvalue = ld(this).find(" span#span_" + detailcolumnname).html();
            } else
                fieldvalue = ld(this).find(" #" + detailcolumnname ).val();
            if(!empty(fieldvalue) && ! fieldvalue_arr.includes(fieldvalue)){
                fieldvalue_arr.push(fieldvalue);
                realrows += 1;
            }
        })
        return realrows;
    }
    this.getFirst = function (detailcolumnname) {
        //取第一行
        var firstvalue = '';

        ld.each(that.trobjs, function () {
            if (that.CheckisEmptyRow(ld(this)) == 'yes')
                return true;
            var edit_permission = 1;
            if(!empty(that.popupobj.detailfieldcolumninfo[detailcolumnname])){
                edit_permission = that.popupobj.detailfieldcolumninfo[detailcolumnname].edit_permission;
            }

            if (edit_permission === 1 || edit_permission == 2) {
                firstvalue = ld(this).find(" span#span_" + detailcolumnname ).html();
                // console.log(detailcolumnname);

            } else
                firstvalue = ld(this).find(" #" + detailcolumnname).val();
            return false;
        })

        return firstvalue;
    }
    this.getLast = function (detailcolumnname) {
        //取最后一行
        var len = that.trobjs.length;
        var lastvalue = '';
        for (var i = len; i > 0; i--) {
            //ls 20220920 BUG0056778 单据分录新增字段整数，单据头新增字段取分录新增字段的最新值。结果录入第一行产品，单据头没有计算（that.trobjs 下标从0开始，因此需要len-1）
            if (that.CheckisEmptyRow(ld(that.trobjs[i - 1])) == 'yes')
                continue;
            var edit_permission = 1;
            if(!empty(that.popupobj.detailfieldcolumninfo[detailcolumnname])){
                edit_permission = that.popupobj.detailfieldcolumninfo[detailcolumnname].edit_permission;
            }

            if (edit_permission === 1 || edit_permission == 2) {
                lastvalue = ld(that.trobjs[i - 1]).find(" span#span_" + detailcolumnname ).html();
            } else
                lastvalue = ld(that.trobjs[i - 1]).find("  #" + detailcolumnname ).val();
            break;
        }
        return lastvalue;
    }
    this.getmax = function (detailcolumnname) {
        //获取最大值或最小值
        var bigtype = that.popupobj.detailfieldcolumninfo[detailcolumnname].bigtype;

        var arr = [];

        if (bigtype == 'date')
            var maxvalue = "";//ls BUG0066203 年维合同模块，最晚服务到期日这个字段感觉有点奇怪，一开始就是显示1600-01-01
        else
            var maxvalue = -99999999;
        //   console.log(that.trobjs.length+"aa")

        ld.each(that.trobjs, function () {
            //取最大值时，空行也参与了取值计算
            if (that.CheckisEmptyRow(ld(this)) == 'yes')
                return true;
            var tmpobj = ld(this).find("  #" + detailcolumnname );


            if (ld(tmpobj).length <= 0) {
                maxvalue = '';
                return false;
            }
            if (bigtype == 'date') {
                if (ld(tmpobj).val() > maxvalue)
                    maxvalue = ld(tmpobj).val()
            } else if (ld(tmpobj).val() * 1.00 > maxvalue) {
                maxvalue = ld(tmpobj).val()
            }


        })
        ;


        return maxvalue;
    }


    this.getmin = function (detailcolumnname) {
        //获取最小值
        //zkt 20240729 BUG20240729-19 直接创建销售订单，选择产品：海尔339升商用冷藏柜，直接在产品名称上面进行模糊搜索，带出来内容，去直接修改数量不会重算合计金额。
        var bigtype = '';
        if(that.popupobj.detailfieldcolumninfo[detailcolumnname]!=undefined){
            bigtype = that.popupobj.detailfieldcolumninfo[detailcolumnname].bigtype
        }

        var arr = [];

        if (bigtype == 'date')
            var minvalue = "2100-12-01";
        else
            var minvalue = 99999999999;

        ld.each(that.trobjs, function () {

            var tmpobj = ld(this).find("  #" + detailcolumnname);
            if (that.CheckisEmptyRow(ld(this)) == 'yes')
                return true;

            if (ld(tmpobj).length <= 0) {
                minvalue = '';
                return false;
            }
            if (bigtype == 'date') {
                if (ld(tmpobj).val() < minvalue)
                    minvalue = ld(tmpobj).val()
            } else if (ld(tmpobj).val() * 1.00 < minvalue) {
                minvalue = ld(tmpobj).val()
            }


        })
        ;


        return minvalue;
    }
    this.getSum = function (detailcolumnname) {
        var total = 0;
        var strformula = '0';

        if(that.popupobj.detailfieldmodule=="Products")
        {
            
             if (that.popupobj.detaildatavalue_arr == undefined || that.popupobj.detaildatavalue_arr[0][detailcolumnname] == undefined)
                return 0;
            ld.each(that.popupobj.detaildatavalue_arr, function (tmpindex, tmpvalueinfo) {
                if (that.CheckisEmptyRow(that.trobjs[tmpindex]) == 'yes') {
                    return true;
                }
                if (ld.trim(tmpvalueinfo[detailcolumnname]) != '') {
                    strformula = strformula + "+" + tmpvalueinfo[detailcolumnname];
    
                }
               
    
            })
        }
        else
        {
            
             ld.each(that.trobjs, function () {
    
                if (ld(this).find(" #" + detailcolumnname ).length <= 0) {
                    return false;
                } else {
                    if (that.CheckisEmptyRow(ld(this)) == 'yes') {
                        return true;
                    }
                }
             
                var temp_val = ld(this).find(" #" + detailcolumnname ).val();
                if (empty(temp_val)) {
                    temp_val = 0;
                }
                strformula = strformula + "+" + temp_val;
    
    
            })
        }
    
        total = eval(strformula);

        return total;
    }
    this.CheckisEmptyRow = function (rowobj) {

    var rowindex=ld(rowobj).attr("rowindex")
        if (that.popupobj.detailfieldmodule == 'Products') {
            //zkt 20230707 BUG0069314 字段公式不自动计算  复制和编辑时没有传参 hdnProductId
            var productid =that.popupobj.detaildatavalue_arr[rowindex-1].productid;// ld(rowobj).find("#hdnProductId").val();

            if (ld.trim(productid) == '' || parseInt(productid) <= 0) {
                //判断是否为空行
                return 'yes';
            }

        } else {
            var ret = 'no';
            ld.each(that.popupobj.detailfields, function (tmpindex, tmpinfo) {

                if (tmpinfo.typeofdata.indexOf("~M") > 0) {
                    if (ld.trim(ld(rowobj).find(" #" + tmpinfo.columnname ).val()) == '') {
                        //zkt 20230404 BUG0064004 销售管理->月度目标分解，表头的“月度目标合计”做了对分录的“月度目标（元）”字段求和函数，但计算出来的值不正确。例如：YDJH230401 
                        //ret = 'yes';
                        //return false;
                    }
                }

            })

            return ret;
        }
        return 'no';
    }

}