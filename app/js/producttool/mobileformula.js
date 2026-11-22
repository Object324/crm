/**
说明：变量后面带有arr字符表示该变量为数据组变量
变量中有obj表示该变量为数组对象或单个对象
**/

function formulaInfo()
{
    
}
formulaInfo.prototype=
{
    cur_columnname:'',//需要计算的字段
    columnnames:'',//参与计算的字段
    fieldlabel:'',
    letters:{'a':'listprice'},
    typeofdata:'N~O',
    formulastring:''
}

function fieldFormula(toolFieldJson,sys_49,sys_93)
{
	if(toolFieldJson=='')
	{
		return false;
	}
	this.baseColumn=toolFieldJson.basecolumn;//字段公式基准字段
	//反算字段
	if(this.baseColumn == 'taxprice'){
		this.baseInverseColumn = 'listprice';
	}else{
		this.baseInverseColumn = 'taxprice';
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
    this.lengthDecimaldigits=sys_49;//数量小数位数
    this.lengthPrice=sys_93;//单价小数位数
	this.taxamount_relationfield = ['',"taxprice","listprice","discount_amount","list_amount","tax_total"];//价税合计反写时，该数组中字段不再进行公式计算

    this.restobj = this.toolFieldJson;
    for(var i=0 ;i<this.restobj.fields.length;i++)
    {
        var toolfield=new toolFieldInfo();
        toolfield.columnname=this.restobj.fields[i].columnname;
        toolfield.fieldlabel=this.restobj.fields[i].fieldlabel;
        toolfield.typeofdata=this.restobj.fields[i].typedata;
        if(this.restobj.fields[i].newline==null)
        {
            this.restobj.fields[i].newline=0;
        }
        toolfield.newline=this.restobj.fields[i].newline;
        toolfield.uitype=this.restobj.fields[i].uitype;
        this.strfieldTypeofData+= "'"+toolfield.columnname+"':'"+toolfield.typeofdata+"'";
        this.strfieldUitype+="'"+toolfield.columnname+"':'"+toolfield.uitype+"'";
        if(i!=this.restobj.length-1)
        {
            this.strfieldTypeofData+=",";
            this.strfieldUitype+=",";
        }
        this.objField.push(toolfield);
        
        if(!empty(this.restobj.fields[i].columnstring))
        {
            var strcolumn= this.html_decode(this.restobj.fields[i].columnstring);//转义单引号，双引号           
            var columnjsonobj=eval('('+ strcolumn+')')?eval('('+strcolumn +')'):JSON.parse(strcolumn);
        
            var formulafieldinfo=new formulaInfo();
            var letterstring="{";
            formulafieldinfo.columnnames=new Array();//必须重新初始化该数组
            for(var k=0;k<columnjsonobj.formulavar.length;k++)
            {
                if(columnjsonobj.formulavar[k].column.toLowerCase().indexOf('none')<=0)//空字段不参与计算
                {
                    formulafieldinfo.columnnames[k]=columnjsonobj.formulavar[k].column;
                    letterstring+= "'"+columnjsonobj.formulavar[k].lettervar+"':'"+columnjsonobj.formulavar[k].column+"'";
                    if(k!=columnjsonobj.formulavar.length-1)
                    {
                        letterstring+=",";
                    }
                    if(ld.inArray(columnjsonobj.formulavar[k].column,this.formulaneedColumnarr)<0)
                    {
                        this.formulaneedColumnarr[this.formulaneedColumnarr.length]=columnjsonobj.formulavar[k].column;
                    }
                }                
            }
            letterstring+="}";
            formulafieldinfo.letters=eval('('+ letterstring +')')?eval('('+ letterstring +')'):JSON.parse(letterstring);
            formulafieldinfo.cur_columnname=this.restobj.fields[i].columnname;
            this.columnneedFormulaarr[this.columnneedFormulaarr.length]=formulafieldinfo.cur_columnname;
            formulafieldinfo.formulastring=this.restobj.fields[i].formulastring;
            formulafieldinfo.typeofdata=this.restobj.fields[i].typedata;
            this.fieldneedFormualarr.push(formulafieldinfo);
        }       
    }
  
    //this.tableobj=document.getElementById('proTab');
    this.strfieldTypeofData+="}";
    this.strfieldUitype+="}";
    this.fieldTypeOfdataarr=eval('('+ this.strfieldTypeofData +')')?eval('('+ this.strfieldTypeofData +')'):JSON.parse(this.strfieldTypeofData);
    this.fieldUitypearr=eval('('+ this.strfieldUitype +')')?eval('('+ this.strfieldUitype +')'):JSON.parse(this.strfieldUitype);
    //获取需要小计的列
    for(var i=0;i<this.objField.length;i++)
    {
        var fieldinfo=this.objField[i];
        //uitype=16:百分比,26:含税单价,27:不含税单价,20:GP毛利率，15:折扣率，17：税,163:单价
        if(fieldinfo.typeofdata.toLowerCase().indexOf('n')>=0&&fieldinfo.uitype!=16
            &&fieldinfo.uitype!=26&&fieldinfo.uitype!=27&&fieldinfo.uitype!=20
            &&fieldinfo.uitype!=15&&fieldinfo.uitype!=17&&fieldinfo.uitype!=163
            &&fieldinfo.uitype!=730&&fieldinfo.uitype!=731&&fieldinfo.uitype!=810&&fieldinfo.uitype!=811)
        {            
            this.subtotalfieldobj.push(fieldinfo);
        }
    }
}
fieldFormula.prototype.html_decode=function(str)   
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
/**
设置GP公式事件
**/
fieldFormula.prototype.setHtmlEventWhenShowGP=function(id_rowIndex)
{
    document.getElementById('grossprofit'+id_rowIndex).onchange=function(event)
    {
        fieldformulaobj.cur_formula_obj=this;
        var e=event||window.event;
        fieldformulaobj.setHtmlValeWhenShowGP(e,id_rowIndex);
    }   
   
    if(ld.inArray('productcost',this.formulaneedColumnarr)<0)
    {
        if(document.getElementById('productcost'+id_rowIndex) != undefined){
            document.getElementById('productcost'+id_rowIndex).onchange=function(event)
            {
                var e=event||window.event;
                fieldformulaobj.cur_formula_obj=this;
                fieldformulaobj.setHtmlValeWhenShowGP(e,id_rowIndex);
            }
        }
    }
    
    if(ld.inArray('discount_percent',this.formulaneedColumnarr)<0)
    {
        document.getElementById('discount_percent'+id_rowIndex).onchange=function(event)
        {        
            fieldformulaobj.cur_formula_obj=this;
            var e=event||window.event;
            fieldformulaobj.setHtmlValeWhenShowGP(e,id_rowIndex);
        }
    }    
}
/**
edit:can
reason:字段公式设置事件
**/
fieldFormula.prototype.setEvent=function(id_rowIndex)
{
    /*
    if(rmb_checkRMBProduct()=='rmb'){
        rmb_productEventBind(id_rowIndex);
        return ;
    }
    */
     
    for(var k=0;k<this.subtotalfieldobj.length;k++)
    {
        var fieldinfo=this.subtotalfieldobj[k];
        if(ld.inArray(fieldinfo.columnname,this.formulaneedColumnarr)<0)//如果需要小计的字段在字段公式中，就把该字段时间放在this.formulaneedColumnarr循环中
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
                }   
            }
        }
    }
    if(document.getElementById('grossprofit'+id_rowIndex)!=undefined)
        this.setHtmlEventWhenShowGP(id_rowIndex);
    
    // for(var k=0;k<this.formulaneedColumnarr.length;k++)
    // {  
    //     var htmlobj=document.getElementById(this.formulaneedColumnarr[k]+id_rowIndex);
    //     if(this.formulaneedColumnarr[k] != 'tax_amount' && htmlobj !=undefined && htmlobj !='undefined' && htmlobj != 'none'){
    //         console.log(k+'2:'+this.formulaneedColumnarr[k]);
    //         var htmlobj=document.getElementById(this.formulaneedColumnarr[k]+id_rowIndex);
    //         if(htmlobj.tagName.toLocaleLowerCase()=='input')
    //         {
    //             htmlobj.blur_finished='no';
    //             htmlobj.onfocus=function(event)
    //             {
    //                 var e=event||window.event;
    //                 var obj=e.srcElement||e.target;
    //                 obj.oldvalue=this.value;
    //             }
    //             htmlobj.onblur=function(event)
    //             {
    //                 var e=event||window.event;
    //                 var obj=e.srcElement||e.target;
    //                 obj.blur_finished='yes';
    //             }
    //             //下拉框事件暂不做处理(处理文本框和日期)
    //             htmlobj.onchange=function(event)
    //             {
    //                 var ee=event||window.event;                
    //                 if(ee!=undefined&&ee!=null)
    //                 {
    //                     var obj=ee.srcElement||ee.target;
    //                     if(obj!=undefined && obj.id != undefined)
    //                     {
    //                         fieldformulaobj.cur_formula_obj=obj;
    //                     }
    //                 }
    //                 this.id_rowIndex=id_rowIndex;//htmlobj的属性，不是fieldformualobj的属性
    //                 fieldformulaobj.setValueByFormula(ee,this,id_rowIndex);
    //             }
    //         } 
    //     }
    // } 

    for(var k=0;k<this.formulaneedColumnarr.length;k++)
    {  
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
                    if(obj!=undefined && obj.id != undefined)
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
/**
edit:can
reason:整数判断,true：整数
**/
fieldFormula.prototype.isInteger=function(str)
{
    var regu = /^[-]{0,1}[0-9]{1,}$/;
    return regu.test(str);
}

/**
日期类型加减
type:1:表示日期相加，2：日期相减
**/
fieldFormula.prototype.setDateValueByFormula=function(event,formulaColumn,id_rowIndex,type)
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
        if( ld.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
        {
            var formulastring=trim(this.fieldneedFormualarr[k].formulastring).toLowerCase();//获取字段公式
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
            if(ld.inArray(firstdata,letters)>=0)
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
                    if(ld.inArray(onechar,letters)>=0)
                    {
                        if(this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar])=='yes')
                        {
                            
                        }
                        else
                        {
                            if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)!=undefined)
                            {
                                if(trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value)!="")
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
              
                var dates=eval(strformula);
                datetime.addNumber(dates,datestr[2].substr(0,datestr[2].length-1));
            }
            else if(type==2)
            {
                var cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                if(ld.inArray(datestr[1],letters))
                {
                    datestr[1]=document.getElementById(this.fieldneedFormualarr[k].letters[datestr[1]]+id_rowIndex).value;
                }
                var ret_method= datestr[2].substr(0,datestr[2].length-1);
               
                if(ret_method=='day')
                    cur_obj.value=datetime.diff(datestr[1]);
                else if(ret_method=='year')
                    cur_obj.value=datetime.diff(datestr[1])/365;
                if(ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
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
            
            if(ld.inArray(cur_obj.id,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
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
            if(ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
            {
                cur_obj.onchange();
            }
        }
    }
    this.haveFinishedFormulaColumnsarr=new Array();    
}
/**
时间类型加减(分钟)
**/
fieldFormula.prototype.setTimeValueByFormula=function(event,formulaColumn,id_rowIndex)
{
   
}
/**
当界面显示GP字段的公式计算
**/
fieldFormula.prototype.setHtmlValeWhenShowGP=function(event,id_rowIndex)
{
    //含税单价=成本价/[(1－GP/100) *(1-折扣/100+sum(税)/100)]
    //GP=[1－成本价/(含税单价*（1-折扣/100+sum(税)/100)）]*100
   
    if(event==undefined)
    {
        return false;
    }
    var needFormulaobj;
    var e=event||window.event;
    var obj=e.srcElement||e.target;
    if(obj==undefined)
    {
        return false;
    }
    var cur_columnname=this.getColumnName(obj.id,id_rowIndex);   
    var productcost=0;
    if(document.getElementById('productcost'+id_rowIndex) != undefined){
        productcost=document.getElementById('productcost'+id_rowIndex).value;    
    } 
    var gp=0;  
    if(document.getElementById('grossprofit'+id_rowIndex) != undefined){
        gp=document.getElementById('grossprofit'+id_rowIndex).value;    
    }      
    var discount_percent=0;
    if(document.getElementById('discount_percent'+id_rowIndex)!=undefined){
        discount_percent=document.getElementById('discount_percent'+id_rowIndex).value;
    }
    var sumtax=0;//求税的合计
    var tax_array=new Array();
    for(var i=0;i<this.objField.length;i++)
    {
        var fieldinfo=this.objField[i];
        if(fieldinfo.uitype==17)
        {
            if(trim(document.getElementById(fieldinfo.columnname+id_rowIndex).value)=='')
            {
                continue;
            }
            if(!isNaN(document.getElementById(fieldinfo.columnname+id_rowIndex).value))
            {
                continue;
            }
            sumtax+=document.getElementById(fieldinfo.columnname+id_rowIndex).value;
            tax_array.push(fieldinfo.columnname.toLowerCase());
        }
    }
    try
    {    
        if(ld.inArray(cur_columnname.toLowerCase(),tax_array)>=0)
        {
            var gpvalue=[1-obj.value/(taxprice*(1-discount_percent/100+sumtax/100))]*100;
            needFormulaobj=document.getElementById('grossprofit'+id_rowIndex);
            document.getElementById('grossprofit'+id_rowIndex).value=gpvalue;
            return ;
        }
        switch(cur_columnname.toLowerCase())
        {
            case 'productcost':
            case 'discount_percent':
            case 'taxprice':
                needFormulaobj=document.getElementById('grossprofit'+id_rowIndex);
                var taxprice=document.getElementById('taxprice'+id_rowIndex).value
                var tmp=(taxprice*(1-discount_percent/100+sumtax/100));
                if(tmp==0)
                {
                    document.getElementById('grossprofit'+id_rowIndex).value="0.00";
                    break;
                }
                var gpvalue=[1-obj.value/tmp]*100;

                if(!isNaN(gpvalue))
                {
                    gpvalue=parseFloat(gpvalue,10).toFixed(2);
                    if(document.getElementById('grossprofit'+id_rowIndex)!='undefined')
                    {
                        document.getElementById('grossprofit'+id_rowIndex).value=gpvalue;
                    }
                    else
                    {
                        document.getElementById('span_grossprofit'+id_rowIndex).value=gpvalue;
                    }
                }
                else
                {
                    if(document.getElementById('grossprofit'+id_rowIndex)!='undefined')
                    {
                        document.getElementById('grossprofit'+id_rowIndex).value="0.00";
                    }
                    else
                    {
                        document.getElementById('span_grossprofit'+id_rowIndex).value="0.00";
                    }
                }
                break;
            case 'grossprofit':
                needFormulaobj=document.getElementById('listprice'+id_rowIndex);
                
                var taxprice=obj.value/[(1-gp/100) *(1-discount_percent/100+sumtax/100)];
                taxprice=parseFloat(taxprice,10).toFixed(2);
                document.getElementById('taxprice'+id_rowIndex).value=taxprice;
                document.getElementById('taxprice'+id_rowIndex).onchange();
                break;   
        }
    }
    catch(e)
    {
        needFormulaobj.value=0;
        if(needFormulaobj.id==('taxprice'+id_rowIndex))
        {
            needFormulaobj.onchange();
        }
    }
}
/**
edit:chj
reason:价税合计允许手动录入，以及触发反算其他信息
**/
fieldFormula.prototype.setHtmlEventWhenTaxAmount = function(id_rowIndex){
	var _tax_amount_formulastring,_tax_amount_columnstring;
	for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
		if(this.fieldneedFormualarr[k].cur_columnname == 'tax_amount'){
			_tax_amount_formulastring=trim(this.fieldneedFormualarr[k].formulastring).toLowerCase();//获取价税合计字段公式
            break;
		}
	}
	for(var i=0 ;i<this.restobj.fields.length;i++)
    {
         if(this.restobj.fields[i].columnname == 'tax_amount'){
			_tax_amount_columnstring = this.html_decode(this.restobj.fields[i].columnstring);
             _tax_amount_formulastring=this.html_decode(this.restobj.fields[i].formulastring);
            break;
		 }
	}
  //alert(_tax_amount_columnstring);
	//价格合计的计算公式如果变更，是否考虑不反写计算
	if(_tax_amount_columnstring.indexOf('quantity')>0&&(_tax_amount_columnstring.indexOf('listprice')>0||_tax_amount_columnstring.indexOf('taxprice')>0 ))
    {
       
		fieldformulaobj.cur_formula_obj=this;
		fieldformulaobj.cur_input_focus_obj=this;
		this.cur_formula_obj.id = 'tax_amount';
		//税
		var _tax= 0;
		//价税合计
		var _tax_amount = document.getElementById('tax_amount'+id_rowIndex).value;
		//数量
		var quantity = document.getElementById('quantity'+id_rowIndex).value;
		if(empty(eval(quantity)))quantity = 1;
		//折扣率
		if(document.getElementById('discount_percent'+id_rowIndex) != undefined){
			var _discount_percent = document.getElementById('discount_percent'+id_rowIndex).value;
		}else{
			var _discount_percent = 0;
		}
		if(document.getElementById('tax1'+id_rowIndex) != undefined){
			_tax += eval(document.getElementById('tax1'+id_rowIndex).value);
		}
		if(document.getElementById('tax2'+id_rowIndex) != undefined){
			_tax += eval(document.getElementById('tax2'+id_rowIndex).value);
		}
		if(document.getElementById('tax3') != undefined){
			_tax += eval(document.getElementById('tax3'+id_rowIndex).value);
		}
		var _discount_presence_amount = _discount_percent/(100-_discount_percent);
		if(isNaN(_discount_presence_amount) || _discount_presence_amount == 'Infinity'){
			_discount_presence_amount = 0;
		}
		var _discount_presence_amount1 = 100/(100-_discount_percent);
		if(isNaN(_discount_presence_amount1) || _discount_presence_amount1 == 'Infinity'){
			_discount_presence_amount1 = 0;
		}
		 if(this.restobj.system_deploy.systems_deploy_140=='listprice'||this.restobj.system_deploy.systems_deploy_140=='')
         {
            // 折扣额
    		if(document.getElementById('discount_amount'+id_rowIndex) != undefined){
    			var _discount_amount = _tax_amount*_discount_presence_amount;
    			fieldformulaobj.setFieldHtmlForValue('discount_amount',_discount_amount,id_rowIndex);
    		}
    		//含税单价
    		if(document.getElementById('taxprice'+id_rowIndex) != undefined){
    			var _taxprice = [_tax_amount*_discount_presence_amount1]/quantity;
    			fieldformulaobj.setFieldHtmlForValue('taxprice',_taxprice,id_rowIndex);
    		}
    		//不含税单价
    		if(document.getElementById('listprice'+id_rowIndex) != undefined){
    			var _listprice = [_tax_amount*_discount_presence_amount1]/quantity*(100/(100+_tax));
    			fieldformulaobj.setFieldHtmlForValue('listprice',_listprice,id_rowIndex);
    		}
    		//不含税金额
    		if(document.getElementById('list_amount'+id_rowIndex) != undefined){
    			var _list_amount = [_tax_amount*_discount_presence_amount1]*(100/(100+_tax));
    			fieldformulaobj.setFieldHtmlForValue('list_amount',_list_amount,id_rowIndex);
    		}
    		//税额
    		if(document.getElementById('tax_total'+id_rowIndex) != undefined){
    			var _tax_total = [_tax_amount*_discount_presence_amount1]*[1-100/(100+_tax)];
    			fieldformulaobj.setFieldHtmlForValue('tax_total',_tax_total,id_rowIndex);
    		}
    	
         }
         else
         {
            //	增加参数：单据分录明细中录入价税合计重算的字段
            var taxprice=document.getElementById('taxprice'+id_rowIndex).value;//含税单价
            
            // 折扣额
    		if(document.getElementById('discount_amount'+id_rowIndex) != undefined){
    			var _discount_amount = quantity*taxprice-_tax_amount;
    			fieldformulaobj.setFieldHtmlForValue('discount_amount',_discount_amount,id_rowIndex);
    		}
            var columnjsonobj=eval('('+ _tax_amount_columnstring+')')?eval('('+_tax_amount_columnstring +')'):JSON.parse(_tax_amount_columnstring);
            var discount_percent=0;
              for(var i=0;i<columnjsonobj.formulavar.length;i++)
              {
                    if(columnjsonobj.formulavar[i].column=='discount_percent')
                    {
                        var letter=columnjsonobj.formulavar[i].lettervar;
                        var strformula='(1-'+letter+'/100)';
                        var tmpformula='(1-('+letter+'/100))';
                        
                        var tmp=_tax_amount_formulastring.replace(/\s+/g, "");
                     
                         if(tmp.indexOf(strformula)>=0||tmp.indexOf(tmpformula)>=0)
                         {
                                
                             if(quantity*taxprice!=0)
                             {
                              
                                 discount_percent=100-(_tax_amount*100)/(quantity*taxprice);
                             }
                             
                            
                         }
                         else
                         {
                            if(quantity*taxprice!=0)
                             {
                             
                                var discount_percent=(_tax_amount*100)/(quantity*taxprice);
                             }
                             else
                             {
                                discount_percent=100;
                             }
                         }
                        break;
                    }
                    
              }
              //折扣率
              if(document.getElementById('discount_percent'+id_rowIndex) != undefined){
    			
    			fieldformulaobj.setFieldHtmlForValue('discount_percent',discount_percent,id_rowIndex);
    		  }
              
         }
		
	}
	return false;
	
}
//设置金额、数字、单价 小数位数
fieldFormula.prototype.setFieldHtmlForValue = function(column,strformula,id_rowIndex){
	if(!empty(column)){
		var cur_obj = document.getElementById(column+id_rowIndex);
		if( cur_obj != undefined){
			cur_obj.value = this.setFieldLenDecimal(column,strformula);
		}
		if(document.getElementById('span_'+column+id_rowIndex) != undefined){
			document.getElementById('span_'+column+id_rowIndex).innerHTML = cur_obj.value;
		}
	}
}
//格式化对应字段的小数位
fieldFormula.prototype.setFieldLenDecimal = function(column,strformula){
	for(var k=0;k<this.objField.length;k++){
		if(this.objField[k].columnname == column){
			if(this.objField[k].columnname=='taxprice'||this.objField[k].columnname=='listprice'){
				return parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
			}else{
				if(column == 'quantity' && empty(eval(strformula))){
					strformula = 1;
				}
				if(this.objField[k].uitype>=10&&this.objField[k].uitype<=15){
					return parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
				}else if(this.objField[k].uitype ==20){//数字类型字段根据小数位数控制
                    var stypeofdata =this.objField[k].typeofdata.split(',');
					return parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
				}else if(this.objField[k].uitype ==24){
					return parseFloat(eval(strformula));
				}else{
					return parseFloat(eval(strformula),10).toFixed(2);
				}
			}
		}
	}
}
/**
event:事件
htmlobj:引发字段公式元素
formulaneedColumn:公式中需要的字段名称
**/
fieldFormula.prototype.setValueByFormula=function(event,htmlobj,id_rowIndex)
{
    var strformula='';
    var cur_obj;//需要计算的元素
    var  formula_id=htmlobj.id;
    var formulaColumn=this.getColumnName(formula_id,id_rowIndex);     
    var formula_obj=document.getElementById(formulaColumn+htmlobj.id_rowIndex);//数字改变
      
    if(document.getElementById('grossprofit'+id_rowIndex)!=undefined&&event!=undefined&&event!=null)
    {
        this.setHtmlValeWhenShowGP(event,id_rowIndex);//GP公式计算(事件)
    }
    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        strformula='';
      
        //引发计算的字段在需要计算字段中
        if( ld.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
        {
            var formulastring=trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式

            if(this.isDateFormula(formulastring)>0)//判断当前公式是否为日期类型的计算公式
            {
                return this.setDateValueByFormula(event,formulaColumn,id_rowIndex,this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式
            } 

            //产品套餐：含税单价特殊
			if(module.toLowerCase()!='productbom'&&this.fieldneedFormualarr[k].cur_columnname==this.baseColumn&&this.getColumnName(this.cur_formula_obj.id,id_rowIndex).toLowerCase()!=this.baseInverseColumn)
            {
                continue;//
            }
            //含税单价计算时，如果不含税单价字段隐藏，则含税单价不进行计算
            if(module.toLowerCase()!='productbom'&&this.fieldneedFormualarr[k].cur_columnname=='taxprice'&&ViewObj.rootScope.hiddenlistprice=='yes'){
                continue;
            }
            //价税合计反写时，taxamount_relationfield数组中字段不再进行计算
			if(this.cur_formula_obj != undefined && this.cur_formula_obj.id =='tax_amount' && ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.taxamount_relationfield)>0){
			    
				continue;
			}
            for(var i=0;i<formulastring.length;i++)
            {   
                var onechar=formulastring.substr(i,1);
                if(onechar=='')
                {
                    continue;
                }
                
                if(ld.inArray(onechar,letters)>=0)//如果是变量
                { 
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
                        if(trim(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value)=='')
                        {
                            document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value=0;
                        }

                        if(this.fieldneedFormualarr[k].letters[onechar]==this.getColumnName(this.cur_formula_obj.id,id_rowIndex)||(this.fieldneedFormualarr[k].letters[onechar]==this.baseColumn&&this.getColumnName(this.cur_formula_obj.id,id_rowIndex).toLowerCase()!=this.baseInverseColumn))
                        {
                            //如果计算的值为负数，则计算不成功    如a-b b为负数
                            if(eval(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value) < 0){
                                strformula +='('+eval(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value)+')';
                            }else{
                                strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex).value;
                            }
                        }  
                        else
                            strformula+=this.depthCompueFormula(this.fieldneedFormualarr[k].letters[onechar],id_rowIndex);
                    }
                   
                }
                else if(ld.inArray(onechar,chineseBrackets)>=0)//如果中文括号
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
            try{
                cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                  
                if(cur_obj==undefined)
                {
                    //如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                    continue;
                }
                
                if(ld.inArray(cur_obj.id,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
                {
                    continue;
                }
                if(this.cur_formula_obj.id == 'tax_amount' && this.getColumnName(cur_obj.id,id_rowIndex) == 'tax_amount'){
					continue;
				}
				//价税合计反写时，taxamount_relationfield数组中字段不再进行计算
				if(this.cur_formula_obj.id =='tax_amount' && ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.taxamount_relationfield)>0){
					continue;
				}
                this.haveFinishedFormulaColumnsarr.push(cur_obj.id);
                if(module.toLowerCase()!='productbom'&&this.fieldneedFormualarr[k].cur_columnname==this.baseColumn&&this.getColumnName(this.cur_formula_obj.id,id_rowIndex).toLowerCase()!=this.baseInverseColumn)
                    {
                        
                        //如果需要计算的字段为含税单价，且当前引起计算的字段不是“不含税单价",那么就不需要计算含税单价
                    }
                    else
                    {
                        if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'||this.fieldneedFormualarr[k].cur_columnname=='listprice'){
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
                        }else{
                            /*
                            if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
                                cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                            }else{
                                cur_obj.value=parseFloat(eval(strformula),10).toFixed(2);
                            }
                            */
                            if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
                                cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                            }else if(this.fieldneedFormualarr[k].uitype ==20){//数字类型字段根据小数位数控制
                                var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');
                                cur_obj.value=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                            }else if(this.fieldneedFormualarr[k].uitype ==24){
                                cur_obj.value=parseFloat(eval(strformula));
                            }else{
                                cur_obj.value=parseFloat(eval(strformula),10).toFixed(2);
                        }
                    }
                }
                     
                if(isNaN(cur_obj.value) || cur_obj.value == 'Infinity'){
                    cur_obj.value = 0;
                }
                if(document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex)!=undefined)
                {
                    document.getElementById("span_"+this.fieldneedFormualarr[k].cur_columnname+id_rowIndex).innerHTML=cur_obj.value;
                }
                 
                if(ld.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
                {   
                    cur_obj.onchange();
                }
            }
            catch(ex)
            {
               
            }
        }
    }
    this.haveFinishedFormulaColumnsarr=new Array();//
	//合计反算
	if(this.cur_formula_obj.id == 'tax_amount'+id_rowIndex){
		fieldformulaobj.setHtmlEventWhenTaxAmount(id_rowIndex);
	}
}
/**
edit:can
reason:通过html元素的ID获取字段名称
id_name:元素id
id_rowIndex:元素所在行-2（2：删除protab前面两行)
**/
fieldFormula.prototype.getColumnName=function(id_name,id_rowIndex)
{
    var id_len=trim((id_rowIndex+"")).length;//添加双引号的目的是把id_rowIndex变为字符串
    var formulaColumn=id_name.substr(0,id_name.length-id_len);
    return formulaColumn;
}
fieldFormula.prototype.depthCompueFormula=function(formulaColumn,id_rowIndex)
{ 
    var strformula='';
    
    if(ld.inArray(formulaColumn,this.columnneedFormulaarr)<0)
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
               
                if(ld.inArray(onechar,letters)>=0)//如果是变量
                {
                    if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex)==undefined||document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).type=='hidden')
                    {
                        return document.getElementById(formulaColumn+id_rowIndex).value;
                    }                   
                    strformula+=document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value;
                }
                else if(ld.inArray(onechar,chineseBrackets)>=0)//如果中文括号
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
/**
编辑或新增是初始化已有行html元素的事件
**/
fieldFormula.prototype.setAllRowEvent=function(rowcnt)
{
    for(var i=1;i<= rowcnt;i++){
        this.setEvent(i);
    }
}

//字段是否为日期类型,是返回yes;
fieldFormula.prototype.isDateColumn=function(columnname)
{
    var typeofdata=this.fieldTypeOfdataarr[columnname];
    if(typeofdata==null || typeofdata==undefined)
        typeofdata="V-O";
    var datas=typeofdata.split('~');
    if(datas[0].toLocaleLowerCase()=='d'||datas[0].toLocaleLowerCase()=='dt')
    {
        return 'yes'
    }
    return 'no';
}
/**
是否为日期类型的公式
1:日期相加
2：日期相减
0：不是日期类型公式
**/
fieldFormula.prototype.isDateFormula=function(formulastring)
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
/**
edit:can
reason:获取字段类型(如果d,dt,nn,n)
**/
fieldFormula.prototype.getColumnTypeofData=function(columnname)
{
    var typeofdata=this.fieldTypeOfdataarr[columnname];
    if(typeofdata==null || typeofdata==undefined)
        typeofdata="V-O";
    var datas=typeofdata.split('~');
    return datas[0].toLocaleLowerCase();
}
/**
edit:can
reason:不含税单价改变(例如改变币种)
**/
fieldFormula.prototype.changelistprice=function()
{
    for(var i=2;i<this.tableobj.rows.length-1;i++)
    {
        var htmlobj=document.getElementById('listprice'+id_rowIndex); 
        this.cur_formula_obj=htmlobj;
		this.cur_input_focus_obj=htmlobj;
        fieldformulaobj.setValueByFormula(null,htmlobj,id_rowIndex);
    }
}
/**
edit:can
reason:调用公式重新计算(所有行)
**/
fieldFormula.prototype.CountFormulaColumn=function()
{ 
    for(var i=2;i<this.tableobj.rows.length-1;i++)
    {        
        //this.CountRowFormulaColumn(i-1);
        var htmlobj=document.getElementById(this.baseColumn+id_rowIndex); 
        this.cur_formula_obj=htmlobj;
        fieldformulaobj.setValueByFormula(null,htmlobj,id_rowIndex);    
    }
}
/**
edit:can
reason: 指定行所有字段公式的计算
**/
fieldFormula.prototype.CountRowFormulaColumn=function(id_index)
{    
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
    if(document.getElementById('grossprofit'+id_index)!=undefined)
    {
        if(document.getElementById('productcost'+id_index)!=undefined)
        {
            var event=function(){};
            event.srcElement=document.getElementById('productcost'+id_index);
            fieldformulaobj.setHtmlValeWhenShowGP(event,id_index);//GP公式计算(事件)
        }
    }  
}

/*var fieldformulaobj=new fieldFormula(fieldinfojson);*/
var dateoperations=new Array('+','-');
var operations=new Array('+','-','*','/','%');
var Brackets=new Array('(',')','[',']');
var chineseBrackets=new Array('（','）');//支持中文括号，单不支持中文【
var chineseleftbracket='（';
var chineserightbracket='）';
var digits=new Array('0','1','2','3','4','5','6','7','8','9');
var letters=new Array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','w','x','y','z'
,'Z','Y','X','U','V','W','T','S','R','Q','L');