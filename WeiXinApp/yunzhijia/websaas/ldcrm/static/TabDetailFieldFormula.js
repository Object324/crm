/**
说明：变量后面带有arr字符表示该变量为数据组变量
变量中有obj表示该变量为数组对象或单个对象
**/

function tabDetailFormulaInfo()
{

}
tabDetailFormulaInfo.prototype=
{
    cur_columnname:'',//需要计算的字段
    columnnames:'',//参与计算的字段
    fieldlabel:'',
    letters:{'a':'listprice'},
    typeofdata:'N~O',
    formulastring:''
}

function tabDetailFieldFormula(toolFieldJson,sys_49,sys_93,productField,vueobj){
	if(toolFieldJson==''){
		return false;
	}
	this.haveFinishedFormulaColumnsarr=new Array();
	this.dateformula_bol='no';//公式计算是否为日期类型，如果是：yes
	this.formulaneedColumnarr=new Array();//获取参与计算的字段名称
	this.strfieldTypeofData="{";
	this.strfieldUitype="{";
	this.fieldTypeOfdataarr={'listprice':'NN~O'};//所有字段的typeofdata;
	this.objField=new Array();//明细所有字段属性
	this.fieldneedFormualarr=new Array();//获取需要计算的字段对象
	this.columnneedFormulaarr=new Array();//需要计算的字段数组
	this.toolFieldJson=toolFieldJson;//字段公式json(格式请参考数据库){formulavar:[{'var':'a','column':'taxprice'},{'var':'b','column':'tax1'},{'var':'c','column':'tax2'},{'var':'d','column':'tax3'}]}
	this.subtotalfieldobj=new Array();//需要小计的字段对象
	this.relationColumnnameobj = new Array();//需要自动带出对象字段
	this.lengthDecimaldigits=sys_49;//数量小数位数
	this.lengthPrice=sys_93;//单价小数位数
	this.specialFieldobj = new Array();//特殊处理的字段(单行)
	this.totalFieldobj = new Array();//(小计、合计)
    this.productField = productField;
    this.vueobj = vueobj;
	this.restobj = this.toolFieldJson;

    if(this.restobj && this.restobj.length > 0){
        for(var i=0 ;i<this.restobj.length;i++){
    	   	var toolfield=new tabDetailFormulaInfo();

    		toolfield.columnname=this.restobj[i].columnname;
    		toolfield.fieldlabel=this.restobj[i].fieldlabel;
    		toolfield.typeofdata=this.restobj[i].typedata;
    		toolfield.fieldtype = this.restobj[i].fieldtype;
    		toolfield.relation_columnname = this.restobj[i].relation_columnname;
    		if(this.restobj[i].newline==null){
    			this.restobj[i].newline=0;
    		}
    		toolfield.newline=this.restobj[i].newline;
    		toolfield.uitype=this.restobj[i].uitype;
    		this.strfieldTypeofData+= "'"+toolfield.columnname+"':'"+toolfield.typeofdata+"'";
    		this.strfieldUitype+="'"+toolfield.columnname+"':'"+toolfield.uitype+"'";
    		if(i!=this.restobj.length-1){
    			this.strfieldTypeofData+=",";
    			this.strfieldUitype+=",";
    		}
    		this.objField.push(toolfield);
            if(this.restobj[i].columnstring != '' && this.restobj[i].columnstring != null){
    			var strcolumn= this.html_decode(this.restobj[i].columnstring);//转义单引号，双引号
    			var columnjsonobj=eval('('+ strcolumn+')')?eval('('+strcolumn +')'):JSON.parse(strcolumn);
    			var formulafieldinfo=new tabDetailFormulaInfo();
    			var letterstring="{";
    			formulafieldinfo.columnnames=new Array();//必须重新初始化该数组
    			for(var k=0;k<columnjsonobj.formulavar.length;k++){
    				if(columnjsonobj.formulavar[k].column.toLowerCase().indexOf('none')<=0){//空字段不参与计算
    					formulafieldinfo.columnnames[k]=columnjsonobj.formulavar[k].column;
    					letterstring+= "'"+columnjsonobj.formulavar[k].lettervar+"':'"+columnjsonobj.formulavar[k].column+"'";
    					if(k!=columnjsonobj.formulavar.length-1){
    						letterstring+=",";
    					}
    					if($.inArray(columnjsonobj.formulavar[k].column,this.formulaneedColumnarr)<0){
    						this.formulaneedColumnarr[this.formulaneedColumnarr.length]=columnjsonobj.formulavar[k].column;
    					}
    				}
    			}
    			letterstring+="}";
    			formulafieldinfo.letters=eval('('+ letterstring +')')?eval('('+ letterstring +')'):JSON.parse(letterstring);
                formulafieldinfo.cur_columnname=this.restobj[i].columnname;
                this.columnneedFormulaarr[this.columnneedFormulaarr.length]=formulafieldinfo.cur_columnname;
                formulafieldinfo.formulastring=this.restobj[i].formulastring;
                formulafieldinfo.typeofdata=this.restobj[i].typedata;
    			formulafieldinfo.uitype=this.restobj[i].uitype;
                this.fieldneedFormualarr.push(formulafieldinfo);
            }
        }
    }

	//this.tableobj=document.getElementById('proTab');
	if(this.strfieldTypeofData.substr(this.strfieldTypeofData.length-1,1)==',' ){
	   this.strfieldTypeofData=this.strfieldTypeofData.substr(0,this.strfieldTypeofData.length-1);
	}
	if(this.strfieldUitype.substr(this.strfieldUitype.length-1,1)==',' ){
	   this.strfieldUitype=this.strfieldUitype.substr(0,this.strfieldUitype.length-1);
	}
	this.strfieldTypeofData+="}";
	this.strfieldUitype+="}";

	this.fieldTypeOfdataarr=eval('('+ this.strfieldTypeofData +')')?eval('('+ this.strfieldTypeofData +')'):JSON.parse(this.strfieldTypeofData);
	this.fieldUitypearr=eval('('+ this.strfieldUitype +')')?eval('('+ this.strfieldUitype +')'):JSON.parse(this.strfieldUitype);
	for(var i=0;i<this.objField.length;i++){
		var fieldinfo=this.objField[i];
		//获取需要小计的列
		if(fieldinfo.fieldtype && fieldinfo.fieldtype.toLowerCase() == 'amount'){
			this.subtotalfieldobj.push(fieldinfo);
		}
		//需要自动带出值得字段
		if(fieldinfo.relation_columnname != '' && fieldinfo.relation_columnname != null){
			this.relationColumnnameobj.push(fieldinfo);
		}
        //特殊处理
		if(fieldinfo.columnname.toLowerCase() == 'timetype'){
            this.specialFieldobj.push(fieldinfo);
        }
        if(fieldinfo.columnname.toLowerCase() == 'costtime'){
            this.totalFieldobj.push(fieldinfo);
        }
	}

  if(this.vueobj.productRows >= 0){
    for(let i =0;i<this.fieldneedFormualarr.length;i++){
      for(let j=0;j<this.fieldneedFormualarr[i].columnnames.length;j++){
        if(this.vueobj.viewlist.entry.list[this.vueobj.productRows][this.fieldneedFormualarr[i].columnnames[j]] != undefined) {
          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].columnnames[j]] = this.vueobj.viewlist.entry.list[this.vueobj.productRows][this.fieldneedFormualarr[i].columnnames[j]].value;
        }
      }
      if(this.vueobj.viewlist.entry.list[this.vueobj.productRows][this.fieldneedFormualarr[i].cur_columnname] != undefined){
        this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].cur_columnname] = this.vueobj.viewlist.entry.list[this.vueobj.productRows][this.fieldneedFormualarr[i].cur_columnname].value;
      }
    }
  }

}

tabDetailFieldFormula.prototype.html_decode=function(str)
{
    var retstr='';
    strarr=str.split('&#039;');//目前转义单引号
    for(var k=0;k<strarr.length;k++)
    {
        retstr+=strarr[k];
        if(k!=strarr.length-1)
            retstr+="'";
    }
    return retstr;
}
//费用报销：切换币种
tabDetailFieldFormula.prototype.changeCurrency=function(tag){
    $('#conversion_rate').val(tag);
    $('#conversion_rate').change();
}
//工时
tabDetailFieldFormula.prototype.changeCostTime=function(columnname){
    if(columnname == 'timetype'){
        //切换类型时，计算Direct、Indirect累计工时
        fieldformulaobj.setSpecialFieldEvent('','timetype');
    }
    else{
        //工时选择时，计算Direct、Indirect累计工时
    }
    fieldformulaobj.calculationCostTime('costtime');
}
tabDetailFieldFormula.prototype.changevalue=function(columnname)
{


    if(this.formulaneedColumnarr.includes(columnname))
    {

        this.cur_formula_obj=document.getElementById(columnname);
        this.setValueByFormula('',document.getElementById(columnname),'');

    }
}
/**
edit:can
reason:字段公式设置事件
**/
tabDetailFieldFormula.prototype.setEvent=function(id_rowIndex)
{
    //小计事件
	if(this.subtotalfieldobj != undefined){
		for(var k=0;k<this.subtotalfieldobj.length;k++)
		{
			var fieldinfo=this.subtotalfieldobj[k];
			if($.inArray(fieldinfo.columnname,this.formulaneedColumnarr)<0)//如果需要小计的字段在字段公式中，就把该字段时间放在this.formulaneedColumnarr循环中
			{
				if(fieldinfo.newline!=0)
			    {
				    continue;
				}

				htmlobj=document.getElementById(fieldinfo.columnname+id_rowIndex);

				if(htmlobj==undefined)
				{
					continue;
				}
				if(htmlobj.tagName.toLocaleLowerCase()=='input')
				{
				    //下拉框事件暂不做处理(处理文本框和日期)
					htmlobj.onchange=function(event)
					{
						this.id_rowIndex=id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
						//fieldformulaobj.CountsubTotal();//小计
					}
				}
			}
		}
	}
    //自动带出关联对象事件
    if(this.relationColumnnameobj){
    	for(var k=0;k<this.relationColumnnameobj.length;k++){
            var fieldinfo=this.relationColumnnameobj[k];
    		var relation_fields = fieldinfo.relation_columnname.split(',');
            var htmlobj=document.getElementById(fieldinfo.columnname+id_rowIndex);
    		if(fieldinfo.newline!=0 || htmlobj==undefined||htmlobj=='undefined'){
    			continue;
    		}
    	}
    }
    if(this.formulaneedColumnarr){
        for(var k=0;k<this.formulaneedColumnarr.length;k++){
            var htmlobj=document.getElementById(this.formulaneedColumnarr[k]+id_rowIndex);
            if(htmlobj==undefined||htmlobj=='undefined')
            {
                continue;
            }

            if(htmlobj.tagName.toLocaleLowerCase()=='input')
            {
                htmlobj.blur_finished='no';

                htmlobj.onfocus=function(event)
                {
                    var e=event||window.event;
                    var obj=e.srcElement||e.target;
                    obj.oldvalue=this.value;
                }
                htmlobj.onblur=function(event)
                {
                    var e=event||window.event;
                    var obj=e.srcElement||e.target;
                    obj.blur_finished='yes';
                    /// fieldformulaobj.cur_formula_obj=obj;//获取当前引发计算的元素(用户输入内容的文本框)
                }

                //下拉框事件暂不做处理(处理文本框和日期)
                htmlobj.onchange=function(event)
                {
                    var ee=event||window.event;
                    if(ee!=undefined&&ee!=null)
                    {
                        var obj=ee.srcElement||ee.target;
                        if(obj!=undefined&&obj.id!=undefined)
                        {
    		                fieldformulaobj.cur_formula_obj=obj;
                        }
                    }
                    this.id_rowIndex=id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
                    fieldformulaobj.setValueByFormula(ee,this,id_rowIndex);
                }
            }
        }
    }
}
/**
edit:can
reason:整数判断,true：整数
**/
tabDetailFieldFormula.prototype.isInteger=function(str)
{
    var regu = /^[-]{0,1}[0-9]{1,}$/;
    return regu.test(str);
}

/**
日期类型加减
type:1:表示日期相加，2：日期相减
**/
tabDetailFieldFormula.prototype.setDateValueByFormula=function(event,formulaColumn,id_rowIndex,type)
{
    var datetime=null;
    var prevchar='';
    var strType='';//字符串类型
    var strformula='';

    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        strformula='';
        datetime=null;

        //引发计算的字段在需要计算的字段中
        if($.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
        {
            var formulastring=Tools.trim(this.fieldneedFormualarr[k].formulastring).toLowerCase();//获取字段公式
            if(type==1)
            {
                formulastring=formulastring.split('date_add(');
                formulastring=formulastring[1];
            }
            else if(type==2)
            {
                formulastring=formulastring.split('date_diff(');
                formulastring=formulastring[1];
            }
            else
            {
                return "";
            }

            if(formulastring==''||formulastring==undefined)
            {
                return '';
            }
            var datestr=formulastring.split(',');
            var firstdata=datestr[0];
            if($.inArray(firstdata,letters)>=0)
            {
                datetime=new DateTime(document.getElementById(this.fieldneedFormualarr[k].letters[firstdata]+id_rowIndex).value);
            }
            else
            {
                datetime=new DateTime(firstdata);
            }
            if(type==1)
            {
                for(var i=0;i<datestr[1].length;i++)
                {
                    var onechar=datestr[1].substr(i,1);
                    if($.inArray(onechar,letters)>=0)
                    {
                        if(this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar])=='yes')
                        {

                        }
                        else
                        {
                            if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)!=undefined)
                            {
                                if(Tools.trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value)!="")
                                    strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value;
                                else
                                    strformula+=0;
                            }
                            else
                            {
                                strformula+=0;
                            }
                        }
                    }
                    else
                    {
                        strformula+=onechar;
                    }
                }
                var  dates=eval(strformula);
                datetime.addNumber(dates,datestr[2].substr(0,datestr[2].length-1));
            }
            else if(type==2)
            {
                var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                if($.inArray(datestr[1],letters))
                {
                    datestr[1]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;
                }
                var ret_method= datestr[2].substr(0,datestr[2].length-1);

                if(ret_method=='day')
                    cur_obj.value=datetime.diff(datestr[1]);
                else if(ret_method=='year')
                    cur_obj.value=datetime.diff(datestr[1])/365;
				else if(ret_method == 'days'){	//日期格式相减
					if($.inArray(datestr[0],letters))
                    {
                        datestr[0]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[0]]+id_rowIndex).value;
                    }
                    if(datestr[0] != undefined && datestr[1] != undefined && datestr[0] != '' && datestr[1] != ''){
                        var date_diff = this.DateDiff(datestr[0], datestr[1]);
                        if(date_diff <= 0) date_diff = 1;
                        cur_obj.value = date_diff;
                    }
				}
                if(document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=undefined)
                {
                    document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex).innerHTML=cur_obj.value;
                }
                if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
                {
                    cur_obj.onchange();
                }
                cur_obj.onchange();
                break;
            }

            var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);

            if(this.cur_formula_obj.id==cur_obj.id)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
            {
                continue;
            }

            if($.inArray(cur_obj.id,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
            {
                continue;
            }
            this.haveFinishedFormulaColumnsarr.push(cur_obj.id);
            if(this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname]==52)//日期时间
            {
                cur_obj.value=datetime.FormatDate(DateTime.FormatStr['DateTime']);
            }
            else if(this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname]==51)//日期
            {
                cur_obj.value=datetime.FormatDate(DateTime.FormatStr['Date']);
            }
            else if(this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname]==54)
            {
                cur_obj.value=datetime.FormatDate(DateTime.FormatStr['Time']);
            }
            else if(this.fieldUitypearr[this.fieldneedFormualarr[k].cur_columnname]==53)
            {
                cur_obj.value=datetime.FormatDate(DateTime.FormatStr['ShortTime']);
            }
            if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
            {
                cur_obj.onchange();
            }
        }
    }
    this.haveFinishedFormulaColumnsarr=new Array();
}
tabDetailFieldFormula.prototype.setValueByFormula

/**
event:事件
htmlobj:引发字段公式元素
formulaneedColumn:公式中需要的字段名称
**/
tabDetailFieldFormula.prototype.setValueByFormula=function(event,htmlobj,id_rowIndex)
{
    var strformula='';
    var cur_obj;//需要计算的元素
    var  formula_id=htmlobj.id;
    var that=this;

    var formulaColumn=this.getColumnName(formula_id,id_rowIndex);

    var formula_obj=document.getElementById(formulaColumn+htmlobj.id_rowIndex);//数字改变

    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        strformula='';

        //引发计算的字段在需要计算字段中
        if($.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
        {
            var formulastring=Tools.trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式

            if(this.isDateFormula(formulastring)>0)//判断当前公式是否为日期类型的计算公式
            {
              //  return  this.setDateValueByFormula(event,formulaColumn,id_rowIndex,this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式
            }

            for(var i=0;i<formulastring.length;i++)
            {
                var onechar=formulastring.substr(i,1);
                if(onechar=='')
                {
                    continue;
                }

                if($.inArray(onechar,letters)>=0)//如果是变量
                {

                    if (this.vueobj.hideproductField) {
                      if (this.vueobj.hideproductField[this.fieldneedFormualarr[k].letters[onechar]] != undefined) {
                        if(id_rowIndex != ''){
                          if(this.vueobj.viewlist.entry.list[id_rowIndex-1][this.fieldneedFormualarr[k].letters[onechar]] != undefined){
                            strformula += this.vueobj.viewlist.entry.list[id_rowIndex-1][this.fieldneedFormualarr[k].letters[onechar]].value;
                            continue;
                          }else{
                            strformula += "0";
                            continue;
                          }
                        }else {
                          if (this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].letters[onechar]] == undefined) {
                            strformula += "0";
                            continue;
                          } else {
                            strformula += this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].letters[onechar]];
                            continue;
                          }
                        }
                      }
                    }

                    if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex)==undefined)
                    {
                        strformula+="0";
                        continue;
                    }

                    if(this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar])=='yes')
                    {
                        return "0";
                    }
                    else
                    {
                        if(Tools.trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value)=='')
                        {
                            document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value=0;
                        }
                        //如果计算的值为负数，则计算不成功    如a-b b为负数
                        if(eval(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value) < 0){
                          strformula +='('+eval(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value)+')';
                        }else{
                            strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value;
                        }
                    }
                }
                else if($.inArray(onechar,chineseBrackets)>=0)//如果中文括号
                {
                    if(onechar==chineseleftbracket)//中文左括号
                    {
                        strformula+='(';
                    }
                    else if(onechar==chineserightbracket)
                    {
                        strformula+=')';
                    }
                }
                else
                {
                    // console.log(onechar);
					//与币种的汇率进行换算的公式，特殊处理
					if(onechar == '$'){
					    if($('#conversion_rate'+id_rowIndex) != undefined){
							var conversion_rate = $('#conversion_rate'+id_rowIndex).attr('tag');
                            if(conversion_rate != 1 ){
								onechar = '/';
							}else{
								onechar = '*';
							}
						}
					}
                    strformula+=onechar;
                }
            }
            try{
              if(eval(strformula)+'' == '-Infinity' || eval(strformula)+'' == 'NaN' || eval(strformula)+'' == Infinity){
                strformula = 0;
              }

                cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);

                if(cur_obj==undefined||this.cur_formula_obj.id==cur_obj.id)//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                {
                  if(this.vueobj.hideproductField[this.fieldneedFormualarr[k].cur_columnname] != undefined){
                    if(this.cur_formula_obj.id == this.fieldneedFormualarr[k].cur_columnname){
                      continue;
                    }else{
                      cur_obj={
                        id: this.fieldneedFormualarr[k].cur_columnname
                      }
                    }
                  }else {
                    continue;
                  }
                }
                if($.inArray(cur_obj.id,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
                {
                    continue;
                }
                this.haveFinishedFormulaColumnsarr.push(cur_obj.id);

                var typeofdata_decimal = 2;
                if(this.fieldneedFormualarr[k].fieldtype =='Amount' ||this.fieldneedFormualarr[k].fieldtype =='SourceAmount' ){
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

                var isfind = 'no';
			          var columnindex=0;
                for (var m = 0; m < this.productField.length  ; m++) {
                    if(this.productField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                        columnindex=m;
                        isfind = 'yes';
                        break;
                    }
                }

                if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
                   // cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                    if(isfind == 'no'){
                      this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                    }else{
                      if(id_rowIndex > 0){
                        cur_obj.value = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
                      }else {
                        this.productField[columnindex].text = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
                      }
                    }

                }else{
                   // console.log(eval(strformula));
                  //  cur_obj.value=parseFloat(eval(strformula),10).toFixed(typeofdata_decimal);
                      if(isfind == 'no'){
                        if(id_rowIndex > 0){
                          this.vueobj.viewlist.entry.list[id_rowIndex-1][this.fieldneedFormualarr[k].cur_columnname].hiddenvalue = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                          this.vueobj.viewlist.entry.list[id_rowIndex-1][this.fieldneedFormualarr[k].cur_columnname].value = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                        }else {
                          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                        }
                      }else{
                        if(id_rowIndex > 0){
                          cur_obj.value = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                        }else {
                          this.productField[columnindex].text = parseFloat(eval(strformula), 10).toFixed(typeofdata_decimal);
                        }
                      }
                }


                if(isfind == 'yes' && (isNaN(this.productField[columnindex].text) || this.productField[columnindex].text == 'Infinity')){
                   this.productField[columnindex].text=0;
                }



                if(document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=undefined
                    &&document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=null)
                {

                    //计算合计

                    that.setTotal(that.fieldneedFormualarr[k],this.productField[columnindex].text,this.productField[columnindex].text);

                }


                // console.log(this.fieeldnedFormualarr[k].cur_columnname+'---'+strformula);
                if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
                {
                    fieldformulaobj.cur_formula_obj=cur_obj;
                    cur_obj.onchange();
                }
                //调用分录函数
                var tmp_arr=[];
                tmp_arr['data']={'formulacolumn':this.fieldneedFormualarr[k].cur_columnname};
                that.vueobj.Detail2mainformulaobj.startComputer(tmp_arr);

            }
            catch(ex)
            {

            }
        }
    }
    this.haveFinishedFormulaColumnsarr=new Array();//
    //this.CountsubTotal();//小计行
}
/**
edit:can
reason:通过html元素的ID获取字段名称
id_name:元素id
id_rowIndex:元素所在行-2（2：删除protab前面两行)
**/
tabDetailFieldFormula.prototype.getColumnName=function(id_name,id_rowIndex)
{
    var id_len=Tools.trim((id_rowIndex+"")).length;//添加双引号的目的是把id_rowIndex变为字符串
    var formulaColumn=id_name.substr(0,id_name.length-id_len);
    return formulaColumn;
}
tabDetailFieldFormula.prototype.depthCompueFormula=function(formulaColumn,id_rowIndex)
{
    var strformula='';

    if($.inArray(formulaColumn,this.columnneedFormulaarr)<0)
    {
        return document.getElementById(formulaColumn+id_rowIndex).value;
    }

    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        //引发计算的字段在需要计算字段中
        if( formulaColumn==this.fieldneedFormualarr[k].cur_columnname)
        {
            var formulastring=this.fieldneedFormualarr[k].formulastring;//获取字段公式
            for(var i=0;i<formulastring.length;i++)
            {
                var onechar=formulastring.substr(i,1);

                if(onechar=='')
                {
                    continue;
                }

                if($.inArray(onechar,letters)>=0)//如果是变量
                {
                    if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)==undefined||document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).type=='hidden')
                    {
                        return document.getElementById(formulaColumn+id_rowIndex).value;
                    }
                    strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value;
                }
                else if($.inArray(onechar,chineseBrackets)>=0)//如果中文括号
                {
                    if(onechar==chineseleftbracket)//中文左括号
                    {
                        strformula+='(';
                    }
                    else if(onechar==chineserightbracket)
                    {
                        strformula+=')';
                    }
                }
                else
                {
                    strformula+=onechar;
                }
            }
            break;
        }
    }
    return '('+strformula+')';
}
//工时选择时，计算Direct、Indirect累计工时
tabDetailFieldFormula.prototype.calculationCostTime = function(columnname){
	var sum_direct = 0;
	var sum_indirect = 0;
	var rowcnt = $('#rowcnt').val();
	var hour = 8;//默认8小时
	for(var rowid = 1; rowid <= rowcnt; rowid++){
		if($('#timetype'+rowid) != undefined && $('#costtime'+rowid) != undefined){
			var costtime = document.getElementById('costtime'+rowid).value;
			if(costtime == '')costtime = 0;
			if($('#timetype'+rowid).val() == 'Direct'){
				sum_direct += eval(costtime);
			}else if($('#timetype'+rowid).val() == 'Indirect') {
				sum_indirect += eval(costtime);
			}
		}
	}
	if(sum_direct > hour){
		var str = arrJsPopLabel['YOUIN']+'Direct'+arrJsPopLabel['OVERTIME']+hour+arrJsPopLabel['HOUR']+','+arrJsPopLabel['WHETHERTOCONTINUE'];
		if(!confirm(str)){
			$('#'+columnname).val('');
			return false;
		}
	}
	if(sum_indirect > hour){
		var str = arrJsPopLabel['YOUIN']+'Indirect'+arrJsPopLabel['OVERTIME']+hour+arrJsPopLabel['HOUR']+','+arrJsPopLabel['WHETHERTOCONTINUE'];
		if(!confirm(str)){
			$('#'+columnname).val('');
			return false;
		}
	}
	if($('#sum_direct') != undefined){
		$('#sum_direct').val(sum_direct);
		$('#sum_sum_direct').html(sum_direct);
	}
	if($('#sum_indirect') != undefined){
		$('#sum_indirect').val(sum_indirect);
		$('#sum_sum_indirect').html(sum_indirect);
	}
}
tabDetailFieldFormula.prototype.setSpecialFieldEvent = function(id_rowIndex,columnname){
	if($('#'+columnname) != undefined){
		var sVal = $('#'+columnname).val();
		if(sVal == 'Direct'){
			if($('#projectid'+id_rowIndex+'_name') != undefined){
				$('#projectid'+id_rowIndex+'_name').attr("disabled",false);
				$('#projectid'+id_rowIndex+'_name').css("cursor","");
				$('#select_Project_'+id_rowIndex).show();
			}
			if($('#indirectcharge'+id_rowIndex) != undefined){
				$("#indirectcharge"+id_rowIndex).val("");
				//$("#indirectcharge"+id_rowIndex).find("option[text='']").attr("selected",true);
				$("#indirectcharge"+id_rowIndex).attr("disabled",true);
			}
		}else if(sVal == 'Indirect'){
			if($('#projectid'+id_rowIndex+'_name') != undefined){
				$('#projectid'+id_rowIndex+'_name').val("");
				$('#projectid'+id_rowIndex).val("");
				$('#projectid'+id_rowIndex+'_name').attr("disabled",true);
				$('#select_Project_'+id_rowIndex).hide();
			}
			if($('#indirectcharge'+id_rowIndex) != undefined){
				$("#indirectcharge"+id_rowIndex).attr("disabled",false);
			}
		}else{
			if($('#projectid'+id_rowIndex+'_name') != undefined){
				$('#projectid'+id_rowIndex+'_name').attr("disabled",false);
				$('#projectid'+id_rowIndex+'_name').css("cursor","");
				$('#select_Project_'+id_rowIndex).show();
			}
			if($('#indirectcharge'+id_rowIndex) != undefined){
				$("#indirectcharge"+id_rowIndex).attr("disabled",false);
			}
		}
	}
}
/**
编辑或新增是初始化已有行html元素的事件
**/
tabDetailFieldFormula.prototype.setAllRowEvent=function(rowcnt)
{
    for(var i=1;i<= rowcnt;i++){
        this.setEvent(i);
    }
}
/**
是否为日期类型的公式
1:日期相加
2：日期相减
0：不是日期类型公式
**/
tabDetailFieldFormula.prototype.isDateFormula=function(formulastring)
{
    formulastring=formulastring.toLowerCase();

    if(formulastring.indexOf('date_add(')>=0)
    {
        return 1;
    }
    else if(formulastring.indexOf('date_diff(')>=0)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}
//字段是否为日期类型,是返回yes;
tabDetailFieldFormula.prototype.isDateColumn=function(columnname)
{
    var typeofdata=this.fieldTypeOfdataarr[columnname];
    var datas=typeofdata.split('~');
    if(datas[0].toLocaleLowerCase()=='d'||datas[0].toLocaleLowerCase()=='dt')
    {
        return 'yes'
    }
    return 'no';
}

/**
edit:can
reason:获取字段类型(如果d,dt,nn,n)
**/
tabDetailFieldFormula.prototype.getColumnTypeofData=function(columnname)
{
    var typeofdata=this.fieldTypeOfdataarr[columnname];
    var datas=typeofdata.split('~');
    return datas[0].toLocaleLowerCase();
}
/**
edit:can
reason:调用公式重新计算(所有行)
**/
tabDetailFieldFormula.prototype.CountFormulaColumn=function()
{
	//this.tableobj.rows.length-1;
	var rowcnt = document.getElementById('rowcnt').value;
    for(var i=1;i<=rowcnt;i++)
    {
        this.CountRowFormulaColumn(i);
    }
}
/**
edit:can
reason: 指定行所有字段公式的计算
**/
tabDetailFieldFormula.prototype.CountRowFormulaColumn=function(id_index)
{
    if(id_index >= 0){
      for(let i =0;i<this.fieldneedFormualarr.length;i++){
        for(let j=0;j<this.fieldneedFormualarr[i].columnnames.length;j++){
          if(this.vueobj.viewlist.entry.list[id_index-1][this.fieldneedFormualarr[i].columnnames[j]] != undefined) {
            this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].columnnames[j]] = this.vueobj.viewlist.entry.list[id_index-1][this.fieldneedFormualarr[i].columnnames[j]].value;
          }
        }
        if(this.vueobj.viewlist.entry.list[id_index-1][this.fieldneedFormualarr[i].cur_columnname] != undefined){
          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].cur_columnname] = this.vueobj.viewlist.entry.list[id_index-1][this.fieldneedFormualarr[i].cur_columnname].value;
        }
      }
    }
    for(var k=0;k<this.formulaneedColumnarr.length;k++)
    {
        var htmlobj=document.getElementById(this.formulaneedColumnarr[k]+id_index);
        if(htmlobj==undefined)
        {
            continue;
        }
        fieldformulaobj.cur_formula_obj=htmlobj;
        if(htmlobj.tagName.toLocaleLowerCase()=='input')
        {
            fieldformulaobj.setValueByFormula(null,htmlobj,id_index);
        }
    }
}
//反写小计合计
tabDetailFieldFormula.prototype.setTotal=function(fieldinfo,amount,floatamount){
	//判断当前值否会影响合计、小计
	if($('#sum_'+fieldinfo.columnname) != undefined){
		$('#sum_'+fieldinfo.columnname).html(floatamount);
		//获取合同的columnname属性
		var sum_columnname = $('#sum_'+fieldinfo.columnname).attr("tag");
		if($('#'+sum_columnname) != undefined){
			$('#'+sum_columnname).val(amount);
		}
	}
}
//日期相减
tabDetailFieldFormula.prototype.DateDiff = function(sDate1, sDate2) {  //sDate1和sDate2是yyyy-MM-dd格式

    var aDate, oDate1, oDate2, iDays;
    aDate = sDate1.split(" ");
	if(aDate.length > 1){
		oDate1 = new Date(aDate[0]);
	}else{
		oDate1 = new Date(sDate1);
	}
    aDate = sDate2.split(" ");
	if(aDate.length > 1){
		oDate2 = new Date(aDate[0]);
	}else{
		oDate2 = new Date(sDate2);
	}
    iDays = parseInt(Math.abs(oDate1 - oDate2) / 1000 / 60 / 60 / 24); //把相差的毫秒数转换为天数

    return iDays;  //返回相差天数
}
/**
edit:can
reason:小计（包括计算合计,整单折扣)
**/
tabDetailFieldFormula.prototype.CountsubTotal=function()
{
    var subtotal=0;
    var rowcnt = document.getElementById('rowcnt').value;

    if(this.subtotalfieldobj.length<=0)
        return ;
    for(var j=0;j<this.subtotalfieldobj.length;j++)
    {
        var fieldinfo=this.subtotalfieldobj[j];
        subtotal=0;//不能删除这个语句，具体原因递归了，将来一定不能删除，edit:can
        if(fieldinfo.newline!=0)
        {
            continue;
        }

        for(var i=1;i<=rowcnt;i++)
        {
            if(document.getElementById('hidden_rowid_'+i) != undefined && document.getElementById('hidden_rowid_'+i).value == 0){
                var strid=fieldinfo.columnname+(i);
                var obj=document.getElementById(strid);
                if(obj==undefined)
                {
                    continue;
                }
                if(obj.tagName.toLowerCase()=='td')
                {
                    var value=Tools.trim(obj.innerHTML);//盘点（账面数量)
                }
                else
                {
                    var value=obj.value;
                }

                if(Tools.trim(value)!=""&&!isNaN(value))
                {
                    subtotal+=parseFloat(value,10);
                }
            }
        }

        if(document.getElementById('subtotal_'+fieldinfo.columnname)==undefined)
        {
            continue;
        }
        var typeofdata_decimal = 2;
        if(fieldinfo.fieldtype =='Amount' ||fieldinfo.fieldtype =='SourceAmount' ){
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
        if(fieldinfo.fieldtype == 'Nunber')//数量
        {
            var subTotalToFixed = parseFloat(subtotal,10).toFixed(this.lengthDecimaldigits);
        } else if(fieldinfo.fieldtype=='Price'){//单价
            var subTotalToFixed = parseFloat(subtotal,10).toFixed(this.lengthPrice);
        } else {
            var subTotalToFixed = parseFloat(subtotal,10).toFixed(typeofdata_decimal);
        }
        document.getElementById('subtotal_'+fieldinfo.columnname).innerHTML=subTotalToFixed;
        this.setTotal(fieldinfo,subtotal,subTotalToFixed);
        subtotal=0;
    }
}

var dateoperations=new Array('+','-');
var operations=new Array('+','-','*','/','%');
var Brackets=new Array('(',')','[',']');
var chineseBrackets=new Array('（','）');//支持中文括号，单不支持中文【
var chineseleftbracket='（';
var chineserightbracket='）';
var digits=new Array('0','1','2','3','4','5','6','7','8','9');
var letters=new Array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','w','x','y','z'
,'Z','Y','X','U','V','W','T','S','R','Q','L');
