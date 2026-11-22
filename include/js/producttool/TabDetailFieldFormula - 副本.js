/**
 说明：变量后面带有arr字符表示该变量为数据组变量
 变量中有obj表示该变量为数组对象或单个对象
 **/

function tabDetailFormulaInfo() {
 
}

tabDetailFormulaInfo.prototype =
    {
        cur_columnname: '',//需要计算的字段
        columnnames: '',//参与计算的字段
        fieldlabel: '',
        letters: {'a': 'listprice'},
        typeofdata: 'N~O',
        formulastring: ''
    }

function tabDetailFieldFormula(toolFieldObj) {
    //editor:gyq_161 reason:源单分录字段公式   2019/12/2 15:33
    var popupobj = CrmPopup.getPopupObj('last');
    this.popupobj = popupobj;
    if (toolFieldObj == undefined) { 
        return false;
    }
   
    var that=this;
    this.haveFinishedFormulaColumnsarr = new Array();
    this.finishedcolumncount = [];
    this.dateformula_bol = 'no';//公式计算是否为日期类型，如果是：yes
    this.formulaneedColumnarr = new Array();//获取参与计算的字段名称
    this.computercolumnsformula=[];//查看当前被计算的字段，参与了哪些字段公式计算
    this.strfieldTypeofData = "{";
    this.strfieldUitype = "{";
    this.fieldTypeOfdataarr = {'listprice': 'NN~O'};//所有字段的typeofdata;
    this.objField = new Array();//明细所有字段属性
    this.objFieldType = new Array();//明细所有字段的uitype
    this.fieldneedFormualarr = new Array();//获取需要计算的字段对象
    this.columnneedFormulaarr = new Array();//需要计算的字段数组
    this.toolFieldJson = JSON.stringify(toolFieldObj);//字段公式json(格式请参考数据库){formulavar:[{'var':'a','column':'taxprice'},{'var':'b','column':'tax1'},{'var':'c','column':'tax2'},{'var':'d','column':'tax3'}]}
    this.subtotalfieldobj = new Array();//需要小计的字段对象
    this.subtotalfieldname = new Array();//需要小计的字段name
    this.relationColumnnameobj = new Array();//需要自动带出对象字段
    //this.lengthDecimaldigits=document.getElementById('lengthdecimaldigits').value;//数量小数位数

    if(ld('#' + popupobj.divid + ' [name="lengthdecimaldigits"]').length>0)
     {
        this.lengthDecimaldigits = ld('#' + popupobj.divid + ' [name="lengthdecimaldigits"]').get(0).value;//数量小数位数
         this.lengthPrice = ld('#' + popupobj.divid + ' [name="lengthprice"]').get(0).value;//单价小数位数
         this.nullfield = ld('#' + popupobj.divid + ' [name="nullfield"]').get(0).value;//模块空行基准字段
     }
    else
    {
        this.lengthDecimaldigits=2;
        this.lengthPrice=2;
        this.nullfield='';
    }

     
    this.specialFieldobj = new Array();//特殊处理的字段(单行)
    this.totalFieldobj = new Array();//(小计、合计)
    this.baseColumn = '';
    //this.nullfield = document.getElementById('nullfield').value;//模块空行基准字段
 
 
    var module=this.popupobj.module;
    this.restobj = toolFieldObj;
    this.sumtotalcolumnname='';//计算合计的列名称
    this.totalcolumnname='';//合计列名称
    for (var i = 0; i < this.restobj.fields.length; i++) {
        var toolfield = new toolFieldInfo();
        toolfield.columnname = this.restobj.fields[i].columnname;
        toolfield.fieldlabel = this.restobj.fields[i].fieldlabel;
        toolfield.typeofdata = this.restobj.fields[i].typedata;
        toolfield.fieldtype = this.restobj.fields[i].fieldtype;
        toolfield.relation_columnname = this.restobj.fields[i].relation_columnname;
        if (this.restobj.fields[i].newline == null) {
            this.restobj.fields[i].newline = 0;
        }
        toolfield.newline = this.restobj.fields[i].newline;
        toolfield.uitype = this.restobj.fields[i].uitype;
        this.strfieldTypeofData += "'" + toolfield.columnname + "':'" + toolfield.typeofdata + "'";
        this.strfieldUitype += "'" + toolfield.columnname + "':'" + toolfield.uitype + "'";
        if (i != this.restobj.length - 1) {
            this.strfieldTypeofData += ",";
            this.strfieldUitype += ",";
        }
        this.objField.push(toolfield);
        if (!empty(this.restobj.fields[i].columnstring)) {
            var strcolumn = this.html_decode(this.restobj.fields[i].columnstring);//转义单引号，双引号
            
            var columnjsonobj = eval('(' + strcolumn + ')') ? eval('(' + strcolumn + ')') : JSON.parse(strcolumn);
            var formulafieldinfo = new tabDetailFormulaInfo();
            var letterstring = "{";
            formulafieldinfo.columnnames = new Array();//必须重新初始化该数组
            for (var k = 0; k < columnjsonobj.formulavar.length; k++) {
                if (columnjsonobj.formulavar[k].column.toLowerCase().indexOf('none') <= 0) {//空字段不参与计算
                    formulafieldinfo.columnnames[k] = columnjsonobj.formulavar[k].column;
                    letterstring += "'" + columnjsonobj.formulavar[k].lettervar + "':'" + columnjsonobj.formulavar[k].column + "'";
                    if (k != columnjsonobj.formulavar.length - 1) {
                        letterstring += ",";
                    }
                    if (ld.inArray(columnjsonobj.formulavar[k].column, this.formulaneedColumnarr) < 0) {
                        this.formulaneedColumnarr[this.formulaneedColumnarr.length] = columnjsonobj.formulavar[k].column;
                    }
                    if(that.computercolumnsformula[columnjsonobj.formulavar[k].column]==undefined)
                    {
                        that.computercolumnsformula[columnjsonobj.formulavar[k].column]=[];
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
            formulafieldinfo.uitype = this.restobj.fields[i].uitype;
            formulafieldinfo.fieldtype = this.restobj.fields[i].fieldtype;
            this.fieldneedFormualarr.push(formulafieldinfo);
        }
    }
    //this.tableobj=document.getElementById('proTab');
  //  this.tableobj = ld('#' + popupobj.divid + ' [name="proTab"]').get(0);
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
    var module=this.popupobj.module;
   
    for (var i = 0; i < this.objField.length; i++) {
        var fieldinfo = this.objField[i];
        //获取需要小计的列
        if(fieldinfo.fieldtype==undefined)
            continue;
        //38211: 佣金单、费用报销单、自定义表单21-25，自定义单价字段，不应该显示小计
        if (fieldinfo.fieldtype.toLowerCase() == 'amount' || fieldinfo.fieldtype.toLowerCase() == 'num' || fieldinfo.fieldtype.toLowerCase() == 'number' || fieldinfo.fieldtype.toLowerCase() == 'int' || fieldinfo.fieldtype.toLowerCase() == 'rmb_amount') {
            this.subtotalfieldobj.push(fieldinfo);
            this.subtotalfieldname[fieldinfo.columnname.toLowerCase()] = fieldinfo.fieldtype.toLowerCase();
        }
        //需要自动带出值得字段
        if (fieldinfo.relation_columnname != '' && fieldinfo.relation_columnname != null) {
            this.relationColumnnameobj.push(fieldinfo);
        }
        //特殊处理
        if (module.toLowerCase() == 'timesheet' || module.toLowerCase() == 'expense') {
            if (fieldinfo.columnname.toLowerCase() == 'timetype') {
                this.specialFieldobj.push(fieldinfo);
            }
            if (fieldinfo.columnname.toLowerCase() == 'mileage') {
                this.specialFieldobj.push(fieldinfo);
            }
            if (fieldinfo.columnname.toLowerCase() == 'reimburserate') {
                this.specialFieldobj.push(fieldinfo);
            }
            if (fieldinfo.columnname.toLowerCase() == 'costtime') {
                this.totalFieldobj.push(fieldinfo);
            }
        }
        this.objFieldType[fieldinfo.columnname.toLowerCase()] = fieldinfo.fieldtype.toLowerCase();
    }
   
    if (module == 'Commission'||module=='Expense')
        this.baseColumn = 'rate';//字段公式基准字段
}
 tabDetailFieldFormula.prototype.setPopupobj=function(popupobj)
{
    this.popupobj=popupobj;
}
tabDetailFieldFormula.prototype.html_decode = function (str) {
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
 edit:can
 reason:字段公式设置事件
 **/
tabDetailFieldFormula.prototype.setEvent = function (id_rowIndex) {
    var popupobj = this.popupobj;
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+id_rowIndex+"]");
    var that=this;
   
    //editor:gyq_20200311 reason:14:38
    // 0039525: （51mis.com/kfbtest）项目管理>项目工时>新建单据界面：明细处录入“工时”，没有自动计算合计
    var module=popupobj.module;
    //小计事件
    if (this.subtotalfieldobj != undefined) {
        for (var k = 0; k < this.subtotalfieldobj.length; k++) {
            var fieldinfo = this.subtotalfieldobj[k];
            if (ld.inArray(fieldinfo.columnname, this.formulaneedColumnarr) < 0)//如果需要小计的字段在字段公式中，就把该字段时间放在this.formulaneedColumnarr循环中
            {
                if (fieldinfo.newline != 0) {
                    continue;
                }
                //htmlobj=document.getElementById(fieldinfo.columnname+id_rowIndex);
                htmlobj = ld(rowobj).find(' #' + fieldinfo.columnname );
                if (htmlobj.length == undefined) {
                    continue;
                }
                if (ld(htmlobj).prop("tagName").toLocaleLowerCase() == 'input') {

                    //下拉框事件暂不做处理(处理文本框和日期)
                    ld(htmlobj).unbind("change").bind("change",function(){
                        popupobj.fieldformulaobj.id_rowIndex = id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
                        popupobj.fieldformulaobj.CountsubTotal();//小计
                    })
                    /*htmlobj.onchange = function (event) {
                        this.id_rowIndex = id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
                        popupobj.fieldformulaobj.CountsubTotal();//小计
                    }*/
                }
            }
        }
    }
    //自动带出关联对象事件
    if (this.relationColumnnameobj != undefined) {
        for (var k = 0; k < this.relationColumnnameobj.length; k++) {
            var fieldinfo = this.relationColumnnameobj[k];
            var relation_fields = fieldinfo.relation_columnname.split(',');
            //var htmlobj=document.getElementById(fieldinfo.columnname+id_rowIndex);
            var htmlobj = ld(rowobj).find( ' #' + fieldinfo.columnname );
            if (fieldinfo.newline != 0 || ld(htmlobj).length<=0) {
                continue;
            }
            ld(htmlobj).unbind("change").bind("change",function(){
                    for (var i = 0; i < relation_fields.length; i++) {
                 
                    var tag = ld(rowobj).find(' [name="currency_id"]').first().find("option:selected").attr("tag");
                    var rel_columnname = relation_fields[i];
                    if(ld('#' + popupobj.divid + ' #' + rel_columnname ).length>0){
                        var tmpobj = ld('#' + popupobj.divid + ' #' + rel_columnname );
                    }
                    else{
                        var tmpobj = ld('#' + popupobj.divid + ' [name="' + rel_columnname + '"]');
                    }
                    
                    
                    ld(tmpobj).first().val(tag);
                    
                    ld(tmpobj).first().change();
                }
                popupobj.fieldformulaobj.CountsubTotal();//小计
            })
            

        }
    }
    //特殊处理事件(单行)
    if (this.specialFieldobj != undefined) {
        for (var k = 0; k < this.specialFieldobj.length; k++) {
            var fieldinfo = this.specialFieldobj[k];
            var columnname = fieldinfo.columnname ;
            //公式模块  类型字段控制 - 项目、非项目是否可选
            if ((module.toLowerCase() == 'timesheet' || module.toLowerCase() == 'expense') && fieldinfo.columnname == 'timetype') {
                //var htmlobj = document.getElementById(columnname);
                var htmlobj = ld(rowobj).find( ' #' + columnname).get(0);
                if (htmlobj != undefined) {
                    htmlobj.onchange = function (event) {
                        this.id_rowIndex = id_rowIndex;
                        popupobj.fieldformulaobj.setSpecialFieldEvent(id_rowIndex, columnname);
                        //切换类型时，计算Direct、Indirect累计工时
                        popupobj.fieldformulaobj.calculationCostTime(columnname, id_rowIndex);
                    }
                }
            }
            if ((module.toLowerCase() == 'expense') && (fieldinfo.columnname == 'mileage' || fieldinfo.columnname == 'reimburserate')) {
                //var htmlobj = document.getElementById(columnname);
                var htmlobj =ld(rowobj).find( ' #' + columnname ).get(0);
                if (htmlobj != undefined) {
                    htmlobj.onchange = function (event) {
                        this.id_rowIndex = id_rowIndex;
                        setExpenseAmount(id_rowIndex);
                        popupobj.fieldformulaobj.CountsubTotal();//小计
                    }
                }

            }
        }
    }

    if (this.totalFieldobj != undefined) {
        for (var k = 0; k < this.totalFieldobj.length; k++) {
            var fieldinfo = this.totalFieldobj[k];
            //var htmlobj = document.getElementById(fieldinfo.columnname + id_rowIndex);
            var htmlobj = ld(rowobj).find( ' #' + fieldinfo.columnname );
                
            if (htmlobj != undefined) {
                ld(htmlobj).unbind("change").bind("change",function(){
                    //工时选择时，计算Direct、Indirect累计工时
                    if (fieldinfo.columnname == 'costtime') {
                        this.id_rowIndex = id_rowIndex;
                        var columnname = fieldinfo.columnname;
                        popupobj.fieldformulaobj.CountsubTotal();//小计
                        popupobj.fieldformulaobj.calculationCostTime(columnname, id_rowIndex);
                    }
                })
                 
            }
        }
    }
    if (this.formulaneedColumnarr != undefined) {
        for (var k = 0; k < this.formulaneedColumnarr.length; k++) {

            //var htmlobj = document.getElementById(this.formulaneedColumnarr[k] + id_rowIndex);
           
            var htmlobj = ld(rowobj).find(' #' + this.formulaneedColumnarr[k]);
              if(htmlobj.length>0)
              {
              
              }
              else
                {
                continue;
                }
              
            if (ld(htmlobj).prop('tagName').toLocaleLowerCase() == 'input') {
               
                ld(htmlobj).unbind("change").bind("change",function(){
                    popupobj.fieldformulaobj.cur_input_focus_obj = ld(this);//获取当前引发计算的元素(用户输入内容的文本框)
                    popupobj.fieldformulaobj.cur_formula_obj = ld(this);
                    popupobj.fieldformulaobj.id_rowIndex = id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
                    var tmphtmlobj_name = ld(this).attr("name");
                    //zkt 20230309 整数字段需要格式化 
                    if(popupobj.fieldformulaobj.objFieldType[tmphtmlobj_name] != undefined && popupobj.fieldformulaobj.objFieldType[tmphtmlobj_name].toLowerCase()=='int'){
                        ld(this).val( parseFloat(eval(ld(this).val()), 10).toFixed(0));
                    }
                    that.haveFinishedFormulaColumnsarr.push(ld(this).attr("name"));
                    if(that.finishedcolumncount[tmphtmlobj_name]==undefined)
                    {
                        that.finishedcolumncount[tmphtmlobj_name]=1;
                    }
                    else{
                        that.finishedcolumncount[tmphtmlobj_name]=parseInt(that.finishedcolumncount[tmphtmlobj_name])+1;
                    }
                    
                    popupobj.fieldformulaobj.setValueByFormula( ld(this), id_rowIndex);
                    that.haveFinishedFormulaColumnsarr=[];
                    that.finishedcolumncount=[];
                    that.CountsubTotal();//小计
                })

                
            }

        }
    }
    var module=this.popupobj.module;
    if (module.toLowerCase() == 'timesheet') {
        setTimeSheet();
    }
      this.popupobj.detail2mainformulaobj.setRowEvent(id_rowIndex);
}
tabDetailFieldFormula.prototype.setNullFieldValue = function (id_rowIndex) {
    var tableobj=this.popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+id_rowIndex+"]");
    
    let that = this;
    if (empty(this.nullfield)) {
        return 'no nullfield';
    } else {
        var nullfield_arr = this.nullfield.split('##');
        var nullfield_num = 0;
        var len=nullfield_arr.length;
       
        for (var kt = 0; kt <len; kt++) {
            var columnname = nullfield_arr[kt];
            if (this.formulaneedColumnarr.length > 0) {
                if (ld.inArray(columnname, this.formulaneedColumnarr) >= 0) {
                    nullfield_arr.splice(ld.inArray(columnname, this.formulaneedColumnarr), 1);
                }
            }
            if (this.subtotalfieldname.length > 0) {
                if (ld.inArray(columnname, this.subtotalfieldname) >= 0) {
                    nullfield_arr.splice(ld.inArray(columnname, this.subtotalfieldname), 1);
                }
            }
            let columnnameRowIndex = ld(rowobj).find( ' #' + columnname ).first();
            if (this.objFieldType[columnname] == 'text' || this.objFieldType[columnname] == 'textarea') {
                if (columnnameRowIndex.val() != undefined && columnnameRowIndex.val() == '') {
                    nullfield_num++;
                }
            } else if (this.objFieldType[columnname] == 'amount' || this.objFieldType[columnname] == 'num') {
                if (columnnameRowIndex.val() != undefined && columnnameRowIndex.val() <= 0) {
                    nullfield_num++;
                }
            }
        }
        if (nullfield_num == nullfield_arr.length) {
            return 'empty row';
        } else {
            //alert('no empty row');
            return 'no empty row';
        }
    }
}
/**
 edit:can
 reason:整数判断,true：整数
 **/
tabDetailFieldFormula.prototype.isInteger = function (str) {
    var regu = /^[-]{0,1}[0-9]{1,}$/;
    return regu.test(str);
}

/**
 日期类型加减
 type:1:表示日期相加，2：日期相减
 **/
tabDetailFieldFormula.prototype.setDateValueByFormula = function ( formulaColumn, id_rowIndex, type) {
    let popupobj = this.popupobj;
     var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+id_rowIndex+"]");
    var datetime = null;
    var prevchar = '';
    var strType = '';//字符串类型
    var strformula = '';

    for (var k = 0; k < this.fieldneedFormualarr.length; k++) {
        strformula = '';
        datetime = null;

        //引发计算的字段在需要计算的字段中
        if (ld.inArray(formulaColumn, this.fieldneedFormualarr[k].columnnames) >= 0) {
            var formulastring = trim(this.fieldneedFormualarr[k].formulastring).toLowerCase();//获取字段公式

            if (type == 1) {
                formulastring = formulastring.split('date_add(');
                formulastring = formulastring[1];
            }
            else if (type == 2) {
                formulastring = formulastring.split('date_diff(');
                formulastring = formulastring[1];

            }
            else if (type == 3) {
                formulastring = formulastring.split('time_diff(');
                formulastring = formulastring[1];

            }
            else {
                return "";
            }

            if (formulastring == '' || formulastring == undefined) {
                return '';
            }
            var datestr = formulastring.split(',');
            var firstdata = datestr[0];

            if (ld.inArray(firstdata, letters) >= 0) {
                //datetime=new DateTime(document.getElementById(this.fieldneedFormualarr[k].letters[firstdata]+id_rowIndex).value);
                datetime = ld(rowobj).find( ' #' + this.fieldneedFormualarr[k].letters[firstdata]).val();
            }
            else {
                datetime = new DateTime(firstdata);
            }

            if (type == 1) {
                for (var i = 0; i < datestr[1].length; i++) {

                    var onechar = datestr[1].substr(i, 1);
                    if (ld.inArray(onechar, letters) >= 0) {
                        if (this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar]) == 'yes') {

                        }
                        else {
                            //if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)!=undefined)
                            let lettersRowIndex = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[onechar] );
                            if (lettersRowIndex.size() > 0) {
                                if (trim(lettersRowIndex.get(0).value) != "")
                                //strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value;
                                    strformula += lettersRowIndex.get(0).value;
                                else
                                    strformula += 0;
                            }
                            else {
                                strformula += 0;
                            }
                        }

                    }
                    else {
                        strformula += onechar;
                    }
                }

                var dates = eval(strformula);

                datetime.addNumber(dates, datestr[2].substr(0, datestr[2].length - 1));
            }
            else if (type == 2) {
                //var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                var cur_obj = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].cur_columnname);
                if (ld.inArray(datestr[1], letters)) {
                    //datestr[1]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;
                    datestr[1] = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[datestr[1]]).val();
                }
                var ret_method = datestr[2].substr(0, datestr[2].length - 1);
                if (ret_method == 'day')
                    ld(cur_obj).val(datetime.diff(datestr[1])) ;
                else if (ret_method == 'year')
                     ld(cur_obj).val( datetime.diff(datestr[1]) / 365) ;
                    //cur_obj.value =;
                else if (ret_method == 'days') {	//日期格式相减
                    if (ld.inArray(datestr[0], letters)) {
                        //datestr[0]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[0]]+id_rowIndex).value;
                        datestr[0] = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[datestr[0]]).val();
                    }
                    if (datestr[0] != undefined && datestr[1] != undefined && !empty(datestr[0]) && !empty(datestr[1])) {
                        var date_diff = this.DateDiff(datestr[0], datestr[1]);
                        if (empty(date_diff)) date_diff = 1;
                            ld(cur_obj).val(date_diff) ;
                    }
                }
                // if(document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=undefined)
                if (ld(rowobj).find(' #span_' + this.fieldneedFormualarr[k].cur_columnname).size() > 0) {
                    //document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex).innerHTML=cur_obj.value;
                    ld(rowobj).find(' #span_' + this.fieldneedFormualarr[k].cur_columnname).html(ld(cur_obj).val());
                }
            }
            else if (type == 3) {
                //var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                var cur_obj = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].cur_columnname);
                if (ld.inArray(datestr[1], letters)) {
                    //datestr[1]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;
                    datestr[1] = ld(rowobj).find( ' #' + this.fieldneedFormualarr[k].letters[datestr[1]]).val();
                }
                var ret_method = datestr[2].substr(0, datestr[2].length - 1);
                ld(cur_obj).val(datetime.timeHourdiff(datestr[1])) ;

                if (ld(rowobj).find( ' #span_"' + this.fieldneedFormualarr[k].cur_columnname).size() > 0) {
                    //document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex).innerHTML=cur_obj.value;
                    ld(rowobj).find( ' #span_"' + this.fieldneedFormualarr[k].cur_columnname).html(ld(cur_obj).val());// = .value;
                }
            }
            //var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
            var cur_obj = ld(rowobj).find( ' #' + this.fieldneedFormualarr[k].cur_columnname);
            var tmpcur_obj_name = ld(cur_obj).attr("name");
            if (ld(this.cur_formula_obj).attr('name')== tmpcur_obj_name)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
            {
                continue;
            }

            if (ld.inArray(tmpcur_obj_name, this.haveFinishedFormulaColumnsarr) >= 0)//已经计算过的字段不需要计算了
            {
                continue;
            }
            this.haveFinishedFormulaColumnsarr.push(tmpcur_obj_name);
            if(this.finishedcolumncount[tmpcur_obj_name]==undefined)
            {
                this.finishedcolumncount[tmpcur_obj_name]=1;
            }
            else{
                this.finishedcolumncount[tmpcur_obj_name]=parseInt(this.finishedcolumncount[tmpcur_obj_name])+1;
            }
            if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 52)//日期时间
            {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['DateTime'])) ;

            }
            else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 51)//日期
            {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['Date'])) ;
                //cur_obj.value = datetime.FormatDate(DateTime.FormatStr['Date']);

            }
            else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 54) {
                 ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['Time'])) ;
                //cur_obj.value = datetime.FormatDate(DateTime.FormatStr['Time']);

            }
            else if (this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname] == 53) {
                ld(cur_obj).val(datetime.FormatDate(DateTime.FormatStr['ShortTime'])) ;
               // cur_obj.value = datetime.FormatDate(DateTime.FormatStr['ShortTime']);

            }

            
            
        }
    }
    this.haveFinishedFormulaColumnsarr = new Array();
    this.finishedcolumncount=[];
}
/**
 event:事件
 htmlobj:引发字段公式元素
 formulaneedColumn:公式中需要的字段名称
 **/
tabDetailFieldFormula.prototype.setValueByFormula = function ( htmlobj, id_rowIndex) {
    var  popupobj = this.popupobj;
    var tableobj=popupobj.getDetailTableObj('no');
    var rowobj=ld(tableobj).find("tr[rowindex="+id_rowIndex+']');
    var that=this;
    var strformula = '';
    var cur_obj;//需要计算的元素
  var tmpneedcomputercols=[];

    var formulaColumn = ld(htmlobj).attr('name');
    //var formula_obj=document.getElementById(formulaColumn+htmlobj.id_rowIndex);//数字改变
    var formula_obj = ld(rowobj).find( ' #' + formulaColumn);//数字改变
    
    for (var k = 0; k < this.fieldneedFormualarr.length; k++) {
        strformula = '';
      
        //引发计算的字段在需要计算字段中
        if (ld.inArray(formulaColumn, this.fieldneedFormualarr[k].columnnames) >= 0) {
            var formulastring = trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式
            
            if (this.isDateFormula(formulastring) > 0)//判断当前公式是否为日期类型的计算公式
            {

                return this.setDateValueByFormula( formulaColumn, id_rowIndex, this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式

            }
            if (this.isSum(formulastring) == 'yes')//判断当前公式是求和公式
            {

                //28442: OA表单字段公式的问题
                this.SumTotal(formulaColumn, this.fieldneedFormualarr[k]);//如果需要计算的字段为日期字段，则调用日期字段公式
                continue;
            }
          
            for (var i = 0; i < formulastring.length; i++) {

                var onechar = formulastring.substr(i, 1);
                if (onechar == '') {
                    continue;
                }

                if (ld.inArray(onechar, letters) >= 0)//如果是变量
                {
                    //if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex)==undefined)
                    if (ld(rowobj).find( ' #' + this.fieldneedFormualarr[k].letters[onechar]).size() === 0) {
                        strformula += "0";
                        continue;
                    }
                    if (this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar]) == 'yes') {

                        return "0";
                    }
                    else {
                        //if (trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex).value) == '') {
                        //    document.getElementById(this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex).value = 0;
                        //}
                        if (trim(ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[onechar]).val()) == '') {
                            ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[onechar]).val(0) ;
                        }
                       
                        var  lettersRowIndex = ld(rowobj).find(' #' + this.fieldneedFormualarr[k].letters[onechar]);
                        if (eval(lettersRowIndex.get(0).value) < 0) {
                            strformula += '(' + eval(lettersRowIndex.get(0).value) + ')';
                        } else {
                            strformula += lettersRowIndex.get(0).value;
                        }
                    }

                }
                else if (ld.inArray(onechar, chineseBrackets) >= 0)//如果中文括号
                {
                    if (onechar == chineseleftbracket)//中文左括号
                    {
                        strformula += '(';
                    }
                    else if (onechar == chineserightbracket) {
                        strformula += ')';
                    }
                }
                else {
                    //与币种的汇率进行换算的公式，特殊处理
                    if (onechar == '$') {
                        //if (ld('#currency_id' + id_rowIndex) != undefined) {
                        if (ld(rowobj).find(' [name="currency_id"]').size() > 0) {
                            var currency_id = ld(rowobj).find(' [name="currency_id"]').first().val();
                            if (currency_id > 1) {
                                onechar = '/';
                            } else {
                                onechar = '*';
                            }
                        }
                    }
                    strformula += onechar;
                }
            }
          
            try {
              
                //cur_obj = document.getElementById(this.fieldneedFormualarr[k].cur_columnname + id_rowIndex);
                cur_obj = ld(rowobj) .find( ' #' + this.fieldneedFormualarr[k].cur_columnname);
                
               if(ld(cur_obj).length<=0)
               {
                continue;
               }
               var tmpcur_obj_name = ld(cur_obj).attr('name');
                if (ld(this.cur_input_focus_obj).attr("name") == tmpcur_obj_name)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                {
                    continue;
                }
                if (ld(this.cur_formula_obj).attr("name") == tmpcur_obj_name)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                {

                    continue;
                }

                if (ld.inArray(tmpcur_obj_name, this.haveFinishedFormulaColumnsarr) >= 0)//已经计算过的字段不需要计算了
                {
                    continue;
                }

                    //console.log(strformula);
                    
                this.haveFinishedFormulaColumnsarr.push(tmpcur_obj_name);
                if(this.finishedcolumncount[tmpcur_obj_name]==undefined)
                {
                    this.finishedcolumncount[tmpcur_obj_name]=1;
                }
                else{
                    this.finishedcolumncount[tmpcur_obj_name]=parseInt(this.finishedcolumncount[tmpcur_obj_name])+1;
                }
                  
                 var typeofdata_decimal = 2;
                   if(this.fieldneedFormualarr[k].fieldtype =='Amount'||this.fieldneedFormualarr[k].fieldtype =='SourceAmount' ||this.fieldneedFormualarr[k].fieldtype =='RMB_Amount' ){
                        var tmptypeofdata = this.fieldneedFormualarr[k].typeofdata;
                        if(tmptypeofdata!=undefined)
                        {
                            var tmptypeofdatas=tmptypeofdata.split(',');
                            if(tmptypeofdatas.length>1)
                               typeofdata_decimal=tmptypeofdatas[1];
                        }
                        if(typeofdata_decimal == ''){
                            typeofdata_decimal = 2;
                        }
                   }
                 if (this.fieldneedFormualarr[k].fieldtype=='Num') {
                     var typeofdatas=this.fieldneedFormualarr[k].typeofdata.split((","));
                     if(typeofdatas.length>1&&typeofdatas[1]!=''){
                        ld(cur_obj).val( parseFloat(eval(strformula), 10).toFixed(typeofdatas[1]));
                     }
                    else{
                         ld(cur_obj).val( parseFloat(eval(strformula), 10).toFixed(2));
                        //cur_obj.value = parseFloat(eval(strformula), 10).toFixed(2);
                    }
                }
                else if (this.fieldneedFormualarr[k].fieldtype.toLowerCase()=='int') {
                         ld(cur_obj).val( parseFloat(eval(strformula), 10).toFixed(0));
                }
                else if (this.fieldneedFormualarr[k].uitype >= 10 && this.fieldneedFormualarr[k].uitype <= 15) {
                     ld(cur_obj).val( parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits));
                    //cur_obj.value = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
                } else {
                   // cur_obj.value = parseFloat(eval(strformula), 10).toFixed(2);
                    ld(cur_obj).val( parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal));
                }
       
                    
                
                //zkt 20230414 BUG0064477 费用报销单，报销金额输入负数，比例字段显示英文
                if (isNaN(ld(cur_obj).val()) || ld(cur_obj).val() == 'Infinity' || ld(cur_obj).val() == '-Infinity') {
                    ld(cur_obj).val(0);
                }

                if (ld(rowobj).find(' #span_' + this.fieldneedFormualarr[k].cur_columnname ).size() > 0) {
                    //document.getElementById("span_" + this.fieldneedFormualarr[k].cur_columnname + id_rowIndex).innerHTML = cur_obj.value;
                    ld(rowobj).find(' #span_' + this.fieldneedFormualarr[k].cur_columnname ).get(0).innerHTML = ld(cur_obj).val();
                    //计算合计
                    this.setTotal(this.fieldneedFormualarr[k].cur_columnname, ld(cur_obj).val(), ld(cur_obj).val());
                }
                tmpneedcomputercols.push(this.fieldneedFormualarr[k].cur_columnname);
                //duan 20221227 字段公式计算后触发分录函数
                if(popupobj.detail2mainformulaobj.computercolumnfunctiontype_arr[this.fieldneedFormualarr[k].cur_columnname]!=undefined)
                {
                    var  param=[];
                    param['data']={'formulacolumn':this.fieldneedFormualarr[k].cur_columnname};
                    popupobj.detail2mainformulaobj.startComputer(param);
                }


            }
            catch (ex) {

            }
        }
    }
    ld.each(tmpneedcomputercols,function(index,tmpcol){
            if(tmpcol!=''&&ld.inArray(tmpcol,that.formulaneedColumnarr)>=0)//判断是否参与计算
            {
              
                 var tmp_formulainfo= that.computercolumnsformula[tmpcol];//查看当前被计算的字段，参与了哪些字段公式计算
                 ld.each(tmp_formulainfo,function(tmpindex,tmpinfo){
                        var tmp_arr_index=ld.inArray(tmpinfo.columnname,that.haveFinishedFormulaColumnsarr);
                        if(tmp_arr_index>=0){
                            //已经计算的过的字段，但是其中参与计算的字段值改变，那么已经计算的字段需要重新计算
                            //例如导入
                            that.haveFinishedFormulaColumnsarr.splice(tmp_arr_index,1);
                        }
                 })
                 
                that.setValueByFormula(ld(rowobj).find("#"+tmpcol),id_rowIndex);
            }
        })
        //edit:can 58716 【佣金信息】模块的分录字段设置好计算公式之后不管用 
    //this.haveFinishedFormulaColumnsarr = new Array();//
    this.finishedcolumncount=[];
    //this.CountsubTotal();//小计行

}
/**
 edit:can
 reason:通过html元素的ID获取字段名称
 id_name:元素id
 id_rowIndex:元素所在行-2（2：删除protab前面两行)
 
tabDetailFieldFormula.prototype.getColumnName = function (id_name, id_rowIndex) {
    var id_len = trim((id_rowIndex + "")).length;//添加双引号的目的是把id_rowIndex变为字符串
    var formulaColumn = id_name.substr(0, id_name.length - id_len);
    return formulaColumn;
}
**/

tabDetailFieldFormula.prototype.depthCompueFormula = function (formulaColumn, id_rowIndex) {
    let popupobj = this.popupobj;
    var strformula = '';

    if (ld.inArray(formulaColumn, this.columnneedFormulaarr) < 0) {
        //return document.getElementById(formulaColumn + id_rowIndex).value;
        return ld('#' + popupobj.divid + ' [name="' + formulaColumn + id_rowIndex + '"]').get(0).value;
    }

    for (var k = 0; k < this.fieldneedFormualarr.length; k++) {

        //引发计算的字段在需要计算字段中
        if (formulaColumn == this.fieldneedFormualarr[k].cur_columnname) {
            var formulastring = this.fieldneedFormualarr[k].formulastring;//获取字段公式
            for (var i = 0; i < formulastring.length; i++) {

                var onechar = formulastring.substr(i, 1);

                if (onechar == '') {

                    continue;
                }

                if (ld.inArray(onechar, letters) >= 0)//如果是变量
                {
                    let lettersRowIndex  = ld('#' + popupobj.divid + ' [name="' + this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex + '"]');
                    //if (document.getElementById(this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex) == undefined || document.getElementById(this.fieldneedFormualarr[k].letters[onechar] + id_rowIndex).type == 'hidden') {
                    if (lettersRowIndex.size() === 0 || lettersRowIndex.get(0).type == 'hidden') {
                        //return document.getElementById(formulaColumn + id_rowIndex).value;
                        return ld('#' + popupobj.divid + ' [name="' + formulaColumn + '"]').get(0).value;
                    }
                    strformula += lettersRowIndex.get(0).value;
                }
                else if (ld.inArray(onechar, chineseBrackets) >= 0)//如果中文括号
                {
                    if (onechar == chineseleftbracket)//中文左括号
                    {
                        strformula += '(';
                    }
                    else if (onechar == chineserightbracket) {
                        strformula += ')';
                    }
                }
                else {

                    strformula += onechar;

                }
            }

            break;
        }
    }

    return '(' + strformula + ')';
}
//工时选择时，计算Direct、Indirect累计工时
tabDetailFieldFormula.prototype.calculationCostTime = function (columnname, id_rowIndex) {
  
    if (getTimeSheetHour(id_rowIndex)) {
        setTimeSheet();
        this.popupobj.fieldformulaobj.CountsubTotal();//小计
    }
}
tabDetailFieldFormula.prototype.setSpecialFieldEvent = function (id_rowIndex, columnname) {
    let popupobj = this.popupobj;
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+id_rowIndex+"]");
    
    //if (document.getElementById(columnname) != undefined) {
    if (ld(rowobj).find(' #' + columnname).size() > 0) {
       // var sVal = ld('#' + columnname).val();
        var sVal = ld(rowobj).find(' #' + columnname ).first().val();
        let entitytypeid = ld(rowobj).find( ' #entitytypeid_name');
        let clear_entitytypeid = ld(rowobj).find(' #clear_entitytypeid');
        let indirectcharge = ld(rowobj).find(' [name="indirectcharge"]');
        let select_entitytypeid = ld(rowobj).find(' #select_entitytypeid');
      
        if (sVal === 'Direct') {
            if (entitytypeid.size() > 0) {
                entitytypeid.first().attr("disabled", false);
                entitytypeid.first().css("cursor", "");
                //ld('#entitytypeid'+id_rowIndex+'_name').val(arrJsPopLabel['INPUTAKEYWORDSQUERY']);
                clear_entitytypeid.first().show();
            }
            if (indirectcharge.size() > 0) {
                indirectcharge.first().val("");
                //ld("#indirectcharge"+id_rowIndex).find("option[text='']").attr("selected",true);
                indirectcharge.first().attr("disabled", true);
            }
            if (select_entitytypeid.size() > 0) {
                select_entitytypeid.first().attr("disabled", false);
            }
        } else if (sVal === 'Indirect') {
            if (entitytypeid.size() > 0) {
                entitytypeid.first().val("");
                //ld('#entitytypeid' + id_rowIndex).val("");
                ld(rowobj).find(' #entitytypeid').first().val("");
                entitytypeid.first().attr("disabled", true);
                clear_entitytypeid.first().hide();
            }
            if (indirectcharge.size() > 0) {
                indirectcharge.first().attr("disabled", false);
            }
            if (select_entitytypeid.size() > 0) {
                select_entitytypeid.first().attr("disabled", true);
                select_entitytypeid.first().find("option[value='']").attr("selected", true);
            }
        } else {
            if (entitytypeid.size() > 0) {
                entitytypeid.first().attr("disabled", false);
                entitytypeid.first().css("cursor", "");
                clear_entitytypeid.first().show();
            }
            if (indirectcharge.size() > 0) {
                indirectcharge.first().attr("disabled", false);
            }
            if (select_entitytypeid.size() > 0) {
                select_entitytypeid.first().attr("disabled", false);
            }
        }
    }
}
/**
 编辑或新增是初始化已有行html元素的事件
 **/
tabDetailFieldFormula.prototype.setAllRowEvent = function () {
    var popupobj = this.popupobj;
    var that=this;
    var tableobj=popupobj.getDetailTableObj();
    var trobjs=popupobj.getTrObjsByDelType('no');
    ld.each(trobjs,function(){
        var rowindex=ld(this).attr("rowindex");
        
        that.setEvent(rowindex);
    })
    /*var rowcnt = 0;
    //if(document.getElementById('rowcnt') != undefined){
    if (ld('#' + popupobj.divid + ' [name="rowcnt"]').size() > 0) {
        //rowcnt =  document.getElementById('rowcnt').value;
        rowcnt = ld('#' + popupobj.divid + ' [name="rowcnt"]').get(0).value;
    }
    for (var i = 1; i <= rowcnt; i++) {

        this.setEvent(i);

    }*/
}
tabDetailFieldFormula.prototype.getFieldInfoByColumnName = function (columnname) {
    for (var i = 0; i < this.objField.length; i++) {
        if (this.objField[i].columnname == columnname) {
            return this.objField[i];
        }
    }
}

/**
 是否为日期类型的公式
 1:日期相加
 2：日期相减
 0：不是日期类型公式
 **/
tabDetailFieldFormula.prototype.isDateFormula = function (formulastring) {
    formulastring = formulastring.toLowerCase();

    if (formulastring.indexOf('date_add(') >= 0) {

        return 1;
    }
    else if (formulastring.indexOf('date_diff(') >= 0) {
        return 2;
    }
    else if (formulastring.indexOf('time_diff(') >= 0) {

        return 3;
    }
    else {
        return 0;
    }
}
//字段是否为日期类型,是返回yes;
tabDetailFieldFormula.prototype.isDateColumn = function (columnname) {

    var typeofdata = this.fieldTypeOfdataarr[columnname];
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
tabDetailFieldFormula.prototype.getColumnTypeofData = function (columnname) {

    var typeofdata = this.fieldTypeOfdataarr[columnname];

    var datas = typeofdata.split('~');

    return datas[0].toLocaleLowerCase();
}
/**
 edit:can
 reason:调用公式重新计算(所有行)
 **/
tabDetailFieldFormula.prototype.CountFormulaColumn = function () {
    //this.tableobj.rows.length-1;
    let popupobj = this.popupobj;
    var that=this;
    var tableobj=popupobj.getDetailTableObj();
    var trobjs=popupobj.getTrObjsByDelType('no');
    ld.each(trobjs,function(){
        var rowindex=ld(this).attr("rowindex");
        
         if (this.baseColumn != ''){
                //this.cur_input_focus_obj = document.getElementById(this.baseColumn + i);
                this.cur_input_focus_obj = ld(this).find(' #'+this.baseColumn );
                that.haveFinishedFormulaColumnsarr.push(this.baseColumn);
                if(that.finishedcolumncount[this.baseColumn]==undefined)
                {
                    that.finishedcolumncount[this.baseColumn]=1;
                }
                else{
                    that.finishedcolumncount[this.baseColumn]=parseInt(that.finishedcolumncount[this.baseColumn])+1;
                }
            }
            
            that.CountRowFormulaColumn(rowindex);
    })
    
    
}
/**
 edit:can
 reason: 指定行所有字段公式的计算
 **/
tabDetailFieldFormula.prototype.CountRowFormulaColumn = function (id_index) {
    let popupobj = this.popupobj;
    var that=this;
    var tableobj=this.popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+id_index+"]");
    
    if (this.formulaneedColumnarr != undefined) {
        for (var k = 0; k < this.formulaneedColumnarr.length; k++) {
            this.cur_input_focus_obj = ld(rowobj).find(' #'+this.formulaneedColumnarr[k]);
            var htmlobj = ld(rowobj).find(' #'+this.formulaneedColumnarr[k] );
            if (ld(htmlobj).length<=0) {
                continue;
            }
            
            popupobj.fieldformulaobj.cur_formula_obj = htmlobj;
            
            if (ld(htmlobj).prop("tagName").toLocaleLowerCase() == 'input') {
                that.haveFinishedFormulaColumnsarr.push(this.formulaneedColumnarr[k] );
                if(that.finishedcolumncount[this.formulaneedColumnarr[k]]==undefined)
                {
                    that.finishedcolumncount[this.formulaneedColumnarr[k]]=1;
                }
                else{
                    that.finishedcolumncount[this.formulaneedColumnarr[k]]=parseInt(that.finishedcolumncount[this.formulaneedColumnarr[k]])+1;
                }
                
                popupobj.fieldformulaobj.setValueByFormula( htmlobj, id_index);
            }
        }
    }
}
//反写小计合计
tabDetailFieldFormula.prototype.setTotal = function (columnname, amount, floatamount) {
    //判断当前值否会影响合计、小计
    var  popupobj = this.popupobj;
    if(popupobj.module=='Expense'&&columnname=='total')
    {
        //45605: （http://210.13.216.146:85/crm [^]）（福建省闽发铝业股份有限公司）营销管理-销售费用单（费用报销单）新建然后添加多行产品，再将产品整行删除，小计发生变更，但是合计没有改变
        ld("#"+popupobj.divid+" [name=sum_rmb_total]").html(floatamount);
        popupobj.before_totalvalue=ld("#"+popupobj.divid+" [name=total]").val( );
		 
          
        ld("#"+popupobj.divid+" [name=total]").val(amount);
        popupobj.now_totalvalue=amount;
    }
        
    if (ld('#'+popupobj.divid+' [name="sum_'+columnname+'"]').size() > 0) {
        
        ld('#'+popupobj.divid+' [name="sum_'+columnname+'"]').html(floatamount);
        //获取合同的columnname属性
        
        var sum_columnname = ld('#'+popupobj.divid+' [name="sum_'+columnname+'"]').first().attr("tag");
        
        if (ld('#'+popupobj.divid+' [name="'+sum_columnname+'"]').size() > 0) {
             popupobj.before_totalvalue= ld('#'+popupobj.divid+' [name="'+sum_columnname+'"]').val( );
            ld('#'+popupobj.divid+' [name="'+sum_columnname+'"]').val(amount);
        }
         popupobj.now_totalvalue=amount;
    }
    if(popupobj.mainfieldformulaobj.maincolumninfo['total']!=undefined)
    {
        var  param=[];
        param['data']={'formulafieldname':popupobj.mainfieldformulaobj.maincolumninfo['total'].fieldname};
        popupobj.mainfieldformulaobj.startComputer(param);
        popupobj.fieldruleobj.CheckReLoadPopup();
    }
    
}
//formualcolumnname:引发计算的字段
//引发计算的字段公式对象
tabDetailFieldFormula.prototype.SumTotal = function (formualcolumnname, fieldformualobj) {
    var  popupobj = this.popupobj;
    var trobjs=popupobj.getTrObjsByDelType('no');
    this.sumtotalcolumnname=formualcolumnname;//获取合计列的字段名称
    var module=popupobj.module;
    
    var typeofdata = this.fieldTypeOfdataarr[formualcolumnname];
    var fieldinfo = this.getFieldInfoByColumnName(formualcolumnname);
    var decimallength = 2;
    if (fieldinfo.fieldtype.toLowerCase() == 'num') {
        var strsplit = fieldinfo.typeofdata.split(',');
        decimallength = strsplit[strsplit.length - 1];

    }

    var total = 0;
    ld.each(trobjs,function(){
        
         var value = ld(this).find(' #'+formualcolumnname).get(0).value;
         if (!isNaN(value) && trim(value) != '')
                total = parseFloat(total) + parseFloat(value);
    })
   
    if( ld('#'+popupobj.divid+' [name="'+fieldformualobj.cur_columnname+'"]').size>0)
        ld('#'+popupobj.divid+' [name="'+fieldformualobj.cur_columnname+'"]').get(0).value = parseFloat(total).toFixed(decimallength);
    if (module == 'Expense') {
        //ld('#sum_rmb_total').html(parseFloat(total).toFixed(decimallength));
        ld('#'+popupobj.divid+' [name="sum_rmb_total"]').first().html(parseFloat(total).toFixed(decimallength));
    }
    else{
        //ld('#sum_' + fieldformualobj.cur_columnname).html(parseFloat(total).toFixed(decimallength));
        ld('#'+popupobj.divid+' [name="sum_'+fieldformualobj.cur_columnname+'"]').first().html(parseFloat(total).toFixed(decimallength));
    }
    this.CountsubTotal();//小计行
}
tabDetailFieldFormula.prototype.isSum = function (formulastring) {
    formulastring = formulastring.toLowerCase();

    if (formulastring.indexOf('sum(') >= 0) {

        return 'yes';
    }
}
//日期相减
tabDetailFieldFormula.prototype.DateDiff = function (sDate1, sDate2) {  //sDate1和sDate2是yyyy-MM-dd格式

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
 edit:chj
 reason:小计（包括计算合计,整单折扣)
 **/
tabDetailFieldFormula.prototype.CountsubTotal = function () {
    //editor:gyq_161 reason:带分录模块弹出层   2019/12/2 14:11
    var popupobj = this.popupobj;
    
    var trobjs=popupobj.getTrObjsByDelType('no');
    
    if(this.sumtotalcolumnname==''||this.totalcolumnname=='')
    {
        for(var k=0;k<this.fieldneedFormualarr.length;k++)
        {
            var formulastring=this.fieldneedFormualarr[k].formulastring;
            if(this.isSum(formulastring))
            {
                this.sumtotalcolumnname=this.fieldneedFormualarr[k].columnnames[0];
                 this.totalcolumnname=this.fieldneedFormualarr[k].cur_columnname;
                 
                break;
            }
        }
    }
    var subtotal = 0;
   
    if (this.subtotalfieldobj.length <= 0)
        return;
    var that=this;
    ld.each(this.subtotalfieldobj,function(tmpindex,fieldinfo){
        
    
        subtotal = 0;//不能删除这个语句，具体原因递归了，将来一定不能删除，edit:can
        if (fieldinfo.newline != 0) {
            return true;
        }

     
            //如果当前行为空行则不进行小计处理
          ld.each(trobjs,function(){
                var rowindex=ld(this).attr("rowindex");
                //edit:can 20220114 0049674: 【益尔高】V8.4.4.1（http://121.4.108.97:85/crm/ [^]）服务-日报-单据新增分录时，异常卡顿，响应很慢，特别是条目多的日报，例如：CC2226（详情见附件和说明
                 /*if ('empty row' == popupobj.fieldformulaobj.setNullFieldValue(rowindex)) {
                    return true;
                }*/
              
                var strid = fieldinfo.columnname ;
                
                var  obj = ld(this).find( ' #' + strid );
                if (obj.length<=0) {
                    return true;
                }
                if (ld(obj).prop("tagName").toLowerCase() == 'td') {
                    var value = trim(ld(obj).html());//盘点（账面数量)
                }
                else {
                    var value =ld(obj).val();
                }
                if (trim(value) != "" && !isNaN(value)) {

                    subtotal += parseFloat(value, 10);
                }
                
          })
           
      
        if (ld('#' + popupobj.divid + ' [name="subtotal_' + fieldinfo.columnname + '"]').size() === 0) {
            return true;
        }
        var typeofdata_decimal = 2;
        //zkt 20230404 BUG0064095 kfbcrm 新增费用报销单----分录“报销金额”小数位3位---选择源单后，就变成2位了 
       if(fieldinfo.fieldtype =='Amount' ||fieldinfo.fieldtype =='SourceAmount'||fieldinfo.fieldtype =='RMB_Amount' ){
            var tmptypeofdata = fieldinfo.typeofdata;
            if(tmptypeofdata!=undefined)
            {
                var tmptypeofdatas=tmptypeofdata.split(',');
                if(tmptypeofdatas.length>1)
                   typeofdata_decimal=tmptypeofdatas[1];
            }
            if(typeofdata_decimal == ''){
                typeofdata_decimal = 2;
            }
       }
        
        if (fieldinfo.fieldtype == 'Num')//数量
        {
            // console.log(fieldinfo.columnname);
            if(fieldinfo.typeofdata==undefined ||fieldinfo.typeofdata=='')
            {
                fieldinfo.typeofdata='N~O~25,2';
            }
            var strs = fieldinfo.typeofdata.split(',');//根据字段小数点位数获取小计的小数点位数

            var subTotalToFixed = parseFloat(subtotal, 10).toFixed(strs[strs.length - 1]);
        } else if (fieldinfo.fieldtype == 'Int') {
            var subTotalToFixed = parseFloat(subtotal, 10).toFixed(0);
        } else {
            var subTotalToFixed = parseFloat(subtotal, 10).toFixed(typeofdata_decimal);
        }
       
        ld('#' + popupobj.divid + ' [name="subtotal_' + fieldinfo.columnname + '"]').get(0).innerHTML = subTotalToFixed;
        if(that.sumtotalcolumnname==fieldinfo.columnname)
        {
        
            that.setTotal(that.totalcolumnname, subtotal, subTotalToFixed);
        }
        else
            that.setTotal(fieldinfo.columnname, subtotal, subTotalToFixed);
        subtotal = 0;
    })
    
    var module=this.popupobj.module;
    if (module.toLowerCase() == 'commission') {
        caltotal_Detail();
    }
    if(module == 'CashBill'){
        caltotal();
    }
    else if(module == 'SendCashBill'){
        calSendTotal();
    }
}
//editor:gyq_161不确定 reason:老的赋值方式，不确定会不会被调用,先注释观察   2019/11/27 17:32
/*if(tabdetailfieldinfojson!=undefined)
{
    var fieldformulaobj=new tabDetailFieldFormula(tabdetailfieldinfojson);
    if(this.baseColumn!='')
        fieldformulaobj.cur_input_focus_obj=document.getElementById(this.baseColumn+"1");
}*/
var dateoperations = new Array('+', '-');
var operations = new Array('+', '-', '*', '/', '%');
var Brackets = new Array('(', ')', '[', ']');
var chineseBrackets = new Array('（', '）');//支持中文括号，单不支持中文【
var chineseleftbracket = '（';
var chineserightbracket = '）';
var digits = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
var letters = new Array('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'w', 'x', 'y', 'z');

