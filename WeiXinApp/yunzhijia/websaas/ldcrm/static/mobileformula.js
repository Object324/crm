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

function fieldFormula(toolFieldJson,sys_49,sys_93,hiddenlistprice,ProductField,FormulaParam,vueobj)
{
    // console.log(sys_49+'---'+sys_93+'---'+hiddenlistprice);
    this.hiddenlistprice=hiddenlistprice;//后台传值
    this.baseColumn=FormulaParam.basecolumn;//字段公式基准字段
    //反算字段
    /*if(this.baseColumn == 'taxprice'){
        this.baseInverseColumn = 'listprice';
    }else{
        this.baseInverseColumn = 'taxprice';
    }*/
   // console.log(ProductField);
  this.vueobj = vueobj;
    //系统参数[单据分录明细中录入价税合计重算的字段]
    this.systems_deploy_140=FormulaParam.system_deploy.systems_deploy_140;
    this.haveFinishedFormulaColumnsarr=new Array();
    this.finishedcolumncount=new Array();
    this.dateformula_bol='no';//公式计算是否为日期类型，如果是：yes
    this.formulaneedColumnarr=new Array();//获取参与计算的字段名称
    this.computercolumnsformula=[];//查看当前被计算的字段，参与了哪些字段公式计算
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
    this.ProductField=ProductField;
	this.reversecolumns=[];//输入后需要反算的字段，目前只有价税合计
     this.reversecolumnformula=[];//反算的字段公式
    this.taxamount_relationfield =[];// ['',"taxprice","listprice","discount_amount","list_amount","tax_total"];//价税合计反写时，该数组中字段不再进行公式计算
    //edit:can 2020-10-12 产品分录明细：系统参数“价格和金额计算时的基准字段”设置为“不含税单价”，录入“税率”应反算“含税单价”
     //this.baseColumn='';//字段公式基准字段
    this.restobj = this.toolFieldJson;
	var that=this;
	var listpricecolumnname='';
    var taxpricecolumnname='';

    for(var i=0 ;i<this.restobj.length;i++)
    {
        var toolfield=new toolFieldInfo();
        toolfield.columnname=this.restobj[i].columnname;
		 if(toolfield.columnname=='listprice')
         {
            listpricecolumnname=toolfield.columnname;
         }
         else if(toolfield.columnname=='taxprice')
         {
            taxpricecolumnname=toolfield.columnname;
         }
        toolfield.fieldlabel=this.restobj[i].fieldlabel;
        toolfield.typeofdata=this.restobj[i].typedata;
        if(this.restobj[i].newline==null)
        {
            this.restobj[i].newline=0;
        }
        toolfield.newline=this.restobj[i].newline;
        toolfield.uitype=this.restobj[i].uitype;
        this.strfieldTypeofData+= "'"+toolfield.columnname+"':'"+toolfield.typeofdata+"'";
        this.strfieldUitype+="'"+toolfield.columnname+"':'"+toolfield.uitype+"'";
        if(i!=this.restobj.length-1)
        {
            this.strfieldTypeofData+=",";
            this.strfieldUitype+=",";
        }
        this.objField.push(toolfield);

        if(this.restobj[i].columnstring != '' && this.restobj[i].columnstring != null)
        {
            var strcolumn= html_decode(this.restobj[i].columnstring);//转义单引号，双引号
            var columnjsonobj=eval('('+ strcolumn+')')?eval('('+strcolumn +')'):JSON.parse(strcolumn);
			if(toolfield.columnname=='tax_amount'){
                //价税合计反算公式
                if(this.restobj[i].reverseformula!='none'){
                    that.taxamount_relationfield=[''];
                    that.reversecolumns.push(toolfield.columnname);
                    that.reversecolumnformula[toolfield.columnname]=this.restobj[i].reverseformula;

                    if(this.restobj[i].reverseformula){
                        $.each(this.restobj[i].reverseformula,function(index,tmpreverseformulainfo){
                            that.taxamount_relationfield.push(tmpreverseformulainfo.columnname);
                        })
                    }
                }
                $.each(columnjsonobj.formulavar,function(index,tmpformulainfo){
                    if(tmpformulainfo.columnname=='taxprice'){
                        //以不含税单价为优先的基准字段
                        //that.baseColumn='taxprice';
                        return false;
                    }
                    if(tmpformulainfo.columnname=='listprice'){
                        //that.baseColumn='listprice';
                    }
                })
            }
            var formulafieldinfo=new formulaInfo();
            var letterstring="{";
            formulafieldinfo.columnnames=new Array();//必须重新初始化该数组
            for(var k=0;k<columnjsonobj.formulavar.length;k++)
            {
                if(columnjsonobj.formulavar[k].column.toLowerCase().indexOf('none')<=0)//空字段不参与计算
                {
                    formulafieldinfo.columnnames[k]=columnjsonobj.formulavar[k].column;
                    letterstring+= "'"+columnjsonobj.formulavar[k].lettervar+"':'"+columnjsonobj.formulavar[k].column+"'";
                    if(k!=columnjsonobj.formulavar.length-1){
                        letterstring+=",";
                    }
                    if($.inArray(columnjsonobj.formulavar[k].column,this.formulaneedColumnarr)<0){
                        this.formulaneedColumnarr[this.formulaneedColumnarr.length]=columnjsonobj.formulavar[k].column;
                    }

                    if(this.computercolumnsformula[columnjsonobj.formulavar[k].column]==undefined)
                    {
                        this.computercolumnsformula[columnjsonobj.formulavar[k].column]=[];
                    }
                    this.computercolumnsformula[columnjsonobj.formulavar[k].column].push(toolfield.columnname);

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
	  if(that.baseColumn=='')
		{
				//如果价税合计公式没有使用（含税单价和不含税单价字段）
				 if($.trim(taxpricecolumnname)!='')
				 {
					that.baseColumn=taxpricecolumnname;
				 }
				 else
				 {
					that.baseColumn=listpricecolumnname;
				 }
		}

		 if(this.baseColumn == 'taxprice'){
			this.baseInverseColumn = 'listprice';
		 }else{
			this.baseInverseColumn = 'taxprice';
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
            &&fieldinfo.uitype!=15&&fieldinfo.uitype!=17&&fieldinfo.uitype!=163)
        {
            this.subtotalfieldobj.push(fieldinfo);
        }
    }
}

function html_decode(str){
    var retstr='';
    var strarr=str.split('&#039;');//目前转义单引号
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
    if($.inArray('productcost',this.formulaneedColumnarr)<0)
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
    if($.inArray('discount_percent',this.formulaneedColumnarr)<0)
    {
        document.getElementById('discount_percent'+id_rowIndex).onchange=function(event)
        {
            fieldformulaobj.cur_formula_obj=this;
            var e=event||window.event;
            fieldformulaobj.setHtmlValeWhenShowGP(e,id_rowIndex);
        }
    }
}
fieldFormula.prototype.setVueObj=function(vueobj)
{
    this.vueobj=vueobj;
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
    var that=this;
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
                }
            }
        }
    }
    if(document.getElementById('grossprofit'+id_rowIndex)!=undefined)
        this.setHtmlEventWhenShowGP(id_rowIndex);
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
                        fieldformulaobj.cur_input_focus_obj=obj;//获取当前引发计算的元素(用户输入内容的文本框)
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
fieldFormula.prototype.isInteger=function(str){
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
        if( $.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
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
            var tmpfirstdata="";
            if(firstdata.length>1)
            {
                var tmpfirstdata=firstdata;
                //36649: pc端：服务合同服务到期日 ，一年的服务现在都是差一天。
                //说明还有日期公式
                var firstdata=firstdata.substr(0,1);
            }
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
                var dates=eval(strformula);
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
            if(this.finishedcolumncount[cur_obj.id]==undefined)
            {
                this.finishedcolumncount[cur_obj.id]=1;
            }
            else{
                this.finishedcolumncount[cur_obj.id]=parseInt(this.finishedcolumncount[cur_obj.id])+1;
            }
            if(tmpfirstdata.length>1)
            {
                datetime=new DateTime(datetime.FormatDate(DateTime.FormatStr['Date']));
                if(tmpfirstdata.indexOf("-")>=0)
                {
                    var tmpfirstdatas= tmpfirstdata.split('-');
                    datetime.addNumber("-"+parseInt(tmpfirstdatas[1]),tmpfirstdatas[1].substr(parseInt(tmpfirstdatas[1]).toFixed(0).length));
                }
                else
                {
                    var tmpfirstdatas= tmpfirstdata.split('+');
                    datetime.addNumber(parseInt(tmpfirstdatas[1]),tmpfirstdatas[1].substr(parseInt(tmpfirstdatas[1]).toFixed(0).length));
                }
            }
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
            for (var m = 0; m < this.ProductField.length - 1; m++) {
                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                    this.ProductField[m]['text'] = cur_obj.value;;
                }
            }
            if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
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
            if(Tools.trim(document.getElementById(fieldinfo.columnname+id_rowIndex).value)=='')
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

        if($.inArray(cur_columnname.toLowerCase(),tax_array)>=0)
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

//设置金额、数字、单价 小数位数
fieldFormula.prototype.setFieldHtmlForValue = function(column,strformula,id_rowIndex){
    if(column != ''){
        var cur_obj = document.getElementById(column+id_rowIndex);
        if( cur_obj != undefined){
            cur_obj.value = this.setFieldLenDecimal(column,strformula);
        }
        if(document.getElementById('span_'+column+id_rowIndex) != undefined){
            document.getElementById('span_'+column+id_rowIndex).innerHTML = cur_obj.value;
        }
        //cur_obj.value=parseFloat(eval(strformula),10).toFixed(2);
        for (var m = 0; m < this.ProductField.length - 1; m++) {
            if(this.ProductField[m]['columnname'] == column){
                this.ProductField[m]['text'] = cur_obj.value;;
            }
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
                if(column == 'quantity' && (eval(strformula)==''||eval(strformula)=='0')){
                    strformula = 1;
                }
                if(this.objField[k].uitype>=10&&this.objField[k].uitype<=15){
                    return parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                }else if(this.objField[k].uitype>=25&&this.objField[k].uitype<=50){//单据头和单据分录“金额/货币”类型
                    var stypeofdata =this.objField[k].typeofdata.split(',');
                    if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
                        stypeofdata[1] = 2;
                    }
                    return parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
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
   // console.log(this.baseColumn);
    var strformula='';
    var cur_obj;//需要计算的元素
    var formula_id=htmlobj.id;
    var formulaColumn=this.getColumnName(formula_id,id_rowIndex);
    var formula_obj=document.getElementById(formulaColumn+htmlobj.id_rowIndex);//数字改变
    if(document.getElementById('grossprofit'+id_rowIndex)!=undefined&&event!=undefined&&event!=null)
    {
        this.setHtmlValeWhenShowGP(event,id_rowIndex);//GP公式计算(事件)
    }
    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        if(this.fieldneedFormualarr[k].cur_columnname=='tax_amount' && htmlobj.id=='quantity')
        {
            //有价格策略
            if(wx_havepricestrategy=='yes')
            {
                var quantity = parseFloat(document.getElementById('quantity').value);
                var price_maxcount = parseFloat(wx_pricestrategy.maxfixedbase[0].count_to);
                var price_productid = wx_pricestrategy.maxfixedbase[0].productid;
                // console.log(quantity+'---'+price_maxcount+'---'+price_productid);
                if(quantity > price_maxcount){
                    var price_info = wx_pricestrategy.info[price_productid];
                    var type = price_info[price_info.length-1].type;
                    if(type == 1){//固定基数
                        money = price_info[price_info.length-1].money;
                    }
                    else if(type == 2){//固定基数+固定增量
                        for (var i = 0; i < price_info.length; i++) {
                            if(price_info[i].type == 1){
                                money = price_info[i].money;
                            }
                        }
                        money = parseFloat(money) + parseFloat((quantity - price_maxcount)*parseFloat(price_info[price_info.length-1].money));
                    }
                    else if(type == 3){//固定基数+阶梯增量
                        for (var i = 0; i < price_info.length; i++) {
                            if(price_info[i].type == 1){
                                money = parseFloat(price_info[i].money);
                            }
                        }
                        var startloopindex=0;
                        var mimumquantity=9999999999;
                        for(var i = price_info.length-1;i >= 0;i--){
                            var count_to=price_info[i].count_to;
                            var count_from=price_info[i].count_from;
                            var type=price_info[i].type;

                            if(type<3){
                                break;
                            }
                            if(Math.abs(count_to-quantity)<mimumquantity){
                                //考虑断数
                                mimumquantity=Math.abs(count_to-quantity+1);
                                startloopindex=i;//阶梯增量的断数按照上一行
                            }
                            if(count_from<=quantity&&quantity<=count_to){
                                startloopindex=i;
                                break;
                            }
                        }
                        for(var i = startloopindex; i >= 0; i--){
                            var count_to = price_info[i].count_to;
                            var count_from = price_info[i].count_from;
                            var type=price_info[i].type;
                            if(type<3){
                                break;
                            }
                            if(i < startloopindex){
                                money += parseFloat((count_to-count_from+1)*price_info[i].money);
                            }
                            else{
                                money += parseFloat((quantity-count_from+1)*price_info[i].money);
                            }
                        }
                    }
                }
                else{
                    var sectionFlag = false;
                    var price_info = wx_pricestrategy.info[price_productid];
                    var type = price_info[price_info.length-1].type;
                    var min_count_from = parseFloat(price_info[0].count_from);
                    if(quantity < min_count_from){
                        money = 0;
                    }
                    else{
                        for (var i = 0; i < price_info.length; i++) {
                            if(price_info[i].type == 1){
                                var count_from = parseFloat(price_info[i].count_from);
                                var count_to = parseFloat(price_info[i].count_to);
                                if(quantity>=count_from && quantity<=count_to){
                                    sectionFlag = true;
                                    money = price_info[i].money;
                                }
                            }
                        }
                        if(!sectionFlag){
                            for (let i = 0; i < price_info.length; i++) {
                                if(price_info[i].type == 1){
                                    let count_from = parseFloat(price_info[i].count_from);
                                    if(quantity<count_from){
                                        money = price_info[i].money;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                // console.log(quantity+'---'+money);
                for (var m = 0; m < this.ProductField.length; m++) {
                    if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                        this.ProductField[m]['text'] = parseFloat(money);
                    }
                }
                setTimeout(() => {
					fieldformulaobj.reverseformual_fun('','tax_amount');
                   // fieldformulaobj.setHtmlEventWhenTaxAmount('');// 传参类型
                }, 150);

                //有价格策略,，则不计算价税合计
                continue;
            }
        }
        strformula='';
        //引发计算的字段在需要计算字段中
        if( $.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
        {
            var formulastring=Tools.trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式
            if(this.isDateFormula(formulastring)>0)//判断当前公式是否为日期类型的计算公式
            {
                return  this.setDateValueByFormula(event,formulaColumn,id_rowIndex,this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式
            }

            //产品套餐：含税单价特殊
            if(this.fieldneedFormualarr[k].cur_columnname==this.baseColumn+'aaaaa'&&this.getColumnName(this.cur_formula_obj.id,id_rowIndex).toLowerCase()!=this.baseInverseColumn)
            {
                continue;//
            }
            //含税单价计算时，如果不含税单价字段隐藏，则含税单价不进行计算
            // if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'&&this.hiddenlistprice=='yes'){
            //     continue;
            // }
            //价税合计反写时，taxamount_relationfield数组中字段不再进行计算

            if(this.cur_formula_obj != undefined && this.cur_formula_obj.id =='tax_amount' && $.inArray(this.fieldneedFormualarr[k].cur_columnname,this.taxamount_relationfield)>0){

                continue;
            }
            var tmp_hideproductField_array = [];
            if(this.vueobj.hideproductField){
                for(let hideindex = 0;hideindex<this.vueobj.hideproductField.length;hideindex++){
                    tmp_hideproductField_array.push(this.vueobj.hideproductField[hideindex].columnname);
                }
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
                    if($.inArray(this.fieldneedFormualarr[k].letters[onechar],tmp_hideproductField_array)>=0){
                        if(this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].letters[onechar]]==undefined){
                            strformula+="0";
                            continue;
                        }else{
                            strformula+=this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].letters[onechar]];
                            continue;
                        }
                    }
                    if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+""+id_rowIndex)==undefined){
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
            try{
                if(eval(strformula)+'' == '-Infinity' || eval(strformula)+'' == 'NaN' || eval(strformula)+'' == Infinity){
                  strformula = 0;
                }
                cur_obj=document.getElementById(this.fieldneedFormualarr[k].cur_columnname+id_rowIndex);
                if(cur_obj==undefined)
                {

                    //如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                    continue;
                }
                if(this.cur_input_focus_obj != undefined){
                    if(this.cur_input_focus_obj.id==cur_obj.id){
                        continue;
                    }
                }

                if($.inArray(cur_obj.id,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
                {
                    continue;
                }

                if(this.cur_formula_obj.id == 'tax_amount' && this.getColumnName(cur_obj.id,id_rowIndex) == 'tax_amount'){
                    continue;
                }

                //价税合计反写时，taxamount_relationfield数组中字段不再进行计算
                if(this.cur_formula_obj.id =='tax_amount' && $.inArray(this.fieldneedFormualarr[k].cur_columnname,this.taxamount_relationfield)>0){
                    continue;
                }


                this.haveFinishedFormulaColumnsarr.push(cur_obj.id);
                if(this.finishedcolumncount[cur_obj.id]==undefined)
                {
                    this.finishedcolumncount[cur_obj.id]=1;
                }
                else{
                        this.finishedcolumncount[cur_obj.id]=1+parseInt(this.finishedcolumncount[cur_obj.id]);
                }
                if(this.fieldneedFormualarr[k].cur_columnname==this.baseColumn+'aaaaaa'&&this.getColumnName(this.cur_formula_obj.id,id_rowIndex).toLowerCase()!=this.baseInverseColumn)
                {
                    //如果需要计算的字段为含税单价，且当前引起计算的字段不是“不含税单价",那么就不需要计算含税单价
                }
                else
                {
                    var isfind='no';
                    if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'||this.fieldneedFormualarr[k].cur_columnname=='listprice'){
                        cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
                        for (var m = 0; m < this.ProductField.length; m++) {
                            if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                this.ProductField[m]['text'] = parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
                                isfind='yes';
                                break;
                            }
                        }
                        if(isfind=='no') {
                          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
                        }
                    }else{
                        /*
                        if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                        }else{
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(2);
                        }
                        */
                       // console.log(this.fieldneedFormualarr[k] );
                        if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                            for (var m = 0; m < this.ProductField.length; m++) {
                                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                    this.ProductField[m]['text'] = parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                                    isfind='yes';
                                    break;
                                }
                            }
                            if(isfind=='no') {
                              this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
                            }
                        }else if(this.fieldneedFormualarr[k].uitype>=25&&this.fieldneedFormualarr[k].uitype<=50){//单据头和单据分录“金额/货币”类型
                            var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');
                            if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
                               stypeofdata[1] = 2;
                            }
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                            for (var m = 0; m < this.ProductField.length; m++) {
                                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                    this.ProductField[m]['text'] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                                    isfind='yes';
                                    break;
                                }
                            }
                            if(isfind=='no') {
                              this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                            }
                        }else if(this.fieldneedFormualarr[k].uitype ==20){//数字类型字段根据小数位数控制
                            var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');

                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                            for (var m = 0; m < this.ProductField.length; m++) {
                                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                    this.ProductField[m]['text'] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                                    isfind='yes';
                                    break;
                                }
                            }
                            if(isfind=='no') {
                              this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                            }
                        }else if(this.fieldneedFormualarr[k].uitype ==24){
                            cur_obj.value=parseFloat(eval(strformula));
                            for (var m = 0; m < this.ProductField.length; m++) {
                                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                    this.ProductField[m]['text'] = parseFloat(eval(strformula));
                                    isfind='yes';
                                    break;
                                }
                            }
                            if(isfind=='no') {
                              this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula));
                            }
                        }else{
                            cur_obj.value=parseFloat(eval(strformula),10).toFixed(2);
                            for (var m = 0; m < this.ProductField.length; m++) {
                                if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
                                    var text5 = parseFloat(eval(strformula),10).toFixed(2);
                                    if(text5 == 'NaN'){
                                        text5 = parseFloat(0).toFixed(2);
                                    }
                                    this.ProductField[m]['text'] = text5;
                                    isfind='yes';
                                    break;
                                }
                            }
                            if(isfind=='no') {
                              this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[k].cur_columnname] = parseFloat(eval(strformula),10).toFixed(2);
                            }
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

                if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
                {
                //console.log(this.formulaneedColumnarr);
                    if(this.formulaneedColumnarr.includes(this.fieldneedFormualarr[k].cur_columnname))
                      {
                            var  tmpcol=this.fieldneedFormualarr[k].cur_columnname;

                            var tmp_formulainfo= this.computercolumnsformula[tmpcol];

                            var intersect = tmp_formulainfo.filter(v =>
                                 this.haveFinishedFormulaColumnsarr.includes(v)
                                 );//获取需要重新计算的字段
                            if(this.fieldneedFormualarr[k].cur_columnname=='tax_amount')
                            {
                                for(var tmpi=0;tmpi<intersect.length;tmpi++)
                                {
                                    var tmpcolumnname=intersect[tmpi];
                                    if(this.finishedcolumncount[tmpcolumnname]!=undefined&&
                                        this.finishedcolumncount[tmpcolumnname]>2)
                                     {
                                        continue;
                                     }
                                   this.haveFinishedFormulaColumnsarr.splice(this.haveFinishedFormulaColumnsarr.indexOf(tmpcolumnname),1) ;
                                }
                            }
                      }
                   this.setValueByFormula(event,cur_obj,id_rowIndex);
                    // cur_obj.onchange();

                }
            }
            catch(ex)
            {

            }
        }
    }
     this.haveFinishedFormulaColumnsarr=new Array();//
  //console.log(this.haveFinishedFormulaColumnsarr);
    this.finishedcolumncount=[];
    //合计反算
    if(this.cur_input_focus_obj != undefined && this.cur_input_focus_obj.id == 'tax_amount'+id_rowIndex){
       // fieldformulaobj.setHtmlEventWhenTaxAmount(id_rowIndex);
	   fieldformulaobj.reverseformual_fun(id_rowIndex,'tax_amount');
    }
}

/**
 多选产品后，计算所有行的计算公式
 **/
fieldFormula.prototype.countFormulaColumn=function(){
    let listlen = this.vueobj.viewlist.entry.list.length;
    if(listlen>0){
        for(let i = 0;i < listlen;i++){
            this.haveFinishedFormulaColumnsarr = [];

            this.finishedcolumncount = [];
            for(var k=0;k<this.formulaneedColumnarr.length;k++)
            {
                this.setValueByFormula_vue(null,this.formulaneedColumnarr[k],i);
            }
        }
    }
}

fieldFormula.prototype.setValueByFormula_vue=function(event,columnname,id_rowIndex)
{

  var strformula='';
  var cur_obj;//需要计算的元素
  var formulaColumn=columnname;

  for(var k=0;k<this.fieldneedFormualarr.length;k++)
  {
    if(this.fieldneedFormualarr[k].cur_columnname=='tax_amount' && formulaColumn=='quantity')
    {
      //有价格策略
      if(wx_havepricestrategy=='yes')
      {
        var quantity = parseFloat(this.vueobj.viewlist.entry.list[id_rowIndex]['quantity'].value);
        var price_maxcount = parseFloat(wx_pricestrategy.maxfixedbase[0].count_to);
        var price_productid = wx_pricestrategy.maxfixedbase[0].productid;

        if(quantity > price_maxcount){
          var price_info = wx_pricestrategy.info[price_productid];
          var type = price_info[price_info.length-1].type;
          if(type == 1){//固定基数
            money = price_info[price_info.length-1].money;
          }
          else if(type == 2){//固定基数+固定增量
            for (var i = 0; i < price_info.length; i++) {
              if(price_info[i].type == 1){
                money = price_info[i].money;
              }
            }
            money = parseFloat(money) + parseFloat((quantity - price_maxcount)*parseFloat(price_info[price_info.length-1].money));
          }
          else if(type == 3){//固定基数+阶梯增量
            for (var i = 0; i < price_info.length; i++) {
              if(price_info[i].type == 1){
                money = parseFloat(price_info[i].money);
              }
            }
            var startloopindex=0;
            var mimumquantity=9999999999;
            for(var i = price_info.length-1;i >= 0;i--){
              var count_to=price_info[i].count_to;
              var count_from=price_info[i].count_from;
              var type=price_info[i].type;

              if(type<3){
                break;
              }
              if(Math.abs(count_to-quantity)<mimumquantity){
                //考虑断数
                mimumquantity=Math.abs(count_to-quantity+1);
                startloopindex=i;//阶梯增量的断数按照上一行
              }
              if(count_from<=quantity&&quantity<=count_to){
                startloopindex=i;
                break;
              }
            }
            for(var i = startloopindex; i >= 0; i--){
              var count_to = price_info[i].count_to;
              var count_from = price_info[i].count_from;
              var type=price_info[i].type;
              if(type<3){
                break;
              }
              if(i < startloopindex){
                money += parseFloat((count_to-count_from+1)*price_info[i].money);
              }
              else{
                money += parseFloat((quantity-count_from+1)*price_info[i].money);
              }
            }
          }
        }
        else{
          var sectionFlag = false;
          var price_info = wx_pricestrategy.info[price_productid];
          var type = price_info[price_info.length-1].type;
          var min_count_from = parseFloat(price_info[0].count_from);
          if(quantity < min_count_from){
            money = 0;
          }
          else{
            for (var i = 0; i < price_info.length; i++) {
              if(price_info[i].type == 1){
                var count_from = parseFloat(price_info[i].count_from);
                var count_to = parseFloat(price_info[i].count_to);
                if(quantity>=count_from && quantity<=count_to){
                  sectionFlag = true;
                  money = price_info[i].money;
                }
              }
            }
            if(!sectionFlag){
              for (let i = 0; i < price_info.length; i++) {
                if(price_info[i].type == 1){
                  let count_from = parseFloat(price_info[i].count_from);
                  if(quantity<count_from){
                    money = price_info[i].money;
                    break;
                  }
                }
              }
            }
          }
        }
        // console.log(quantity+'---'+money);
        for (var m = 0; m < this.ProductField.length; m++) {
          if(this.ProductField[m]['columnname'] == this.fieldneedFormualarr[k].cur_columnname){
            this.ProductField[m]['text'] = parseFloat(money);
          }
        }
        setTimeout(() => {
          fieldformulaobj.reverseformual_fun('','tax_amount');
          // fieldformulaobj.setHtmlEventWhenTaxAmount('');// 传参类型
        }, 150);

        //有价格策略,，则不计算价税合计
        continue;
      }
    }
    strformula='';
    //引发计算的字段在需要计算字段中
    if( $.inArray(formulaColumn,this.fieldneedFormualarr[k].columnnames)>=0)
    {
      var formulastring=Tools.trim(this.fieldneedFormualarr[k].formulastring);//获取字段公式
      /*if(this.isDateFormula(formulastring)>0)//判断当前公式是否为日期类型的计算公式
      {
        return  this.setDateValueByFormula(event,formulaColumn,id_rowIndex,this.isDateFormula(formulastring));//如果需要计算的字段为日期字段，则调用日期字段公式
      }*/

      if(this.vueobj.viewlist.entry.list[id_rowIndex][columnname] != undefined && columnname =='tax_amount' && $.inArray(this.fieldneedFormualarr[k].cur_columnname,this.taxamount_relationfield)>0){
        continue;
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
          if(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]]==undefined){
            strformula+="0";
            continue;
          }
          if(this.isDateColumn(this.fieldneedFormualarr[k].letters[onechar])=='yes')
          {
            return "0";
          }
          else
          {
            if(Tools.trim(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value)=='')
            {
              this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value = 0;
            }
            if(this.fieldneedFormualarr[k].letters[onechar]==columnname||(this.fieldneedFormualarr[k].letters[onechar]==this.baseColumn&&columnname.toLowerCase()!=this.baseInverseColumn))
            {
              //如果计算的值为负数，则计算不成功    如a-b b为负数
              if(eval(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value) < 0){
                strformula +='('+eval(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value)+')';
              }else{
                strformula+=this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value;
              }
            }
            else
              strformula+=this.depthCompueFormula_vue(this.fieldneedFormualarr[k].letters[onechar],id_rowIndex);
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
          strformula+=onechar;
        }
      }
      try{
        if(eval(strformula)+'' == '-Infinity' || eval(strformula)+'' == 'NaN' || eval(strformula)+'' == Infinity){
          strformula = 0;
        }
        cur_obj=this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname];
        if(cur_obj==undefined)
        {
          //如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
          continue;
        }


        if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.haveFinishedFormulaColumnsarr)>=0)//已经计算过的字段不需要计算了
        {
          continue;
        }

        this.haveFinishedFormulaColumnsarr.push(cur_obj.id);
        if(this.finishedcolumncount[this.fieldneedFormualarr[k].cur_columnname]==undefined)
        {
          this.finishedcolumncount[this.fieldneedFormualarr[k].cur_columnname]=1;
        }
        else{
          this.finishedcolumncount[this.fieldneedFormualarr[k].cur_columnname]=1+parseInt(this.finishedcolumncount[this.fieldneedFormualarr[k].cur_columnname]);
        }

        if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'||this.fieldneedFormualarr[k].cur_columnname=='listprice'){
          this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
        }else{
          if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<=15){
            this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
          }else if(this.fieldneedFormualarr[k].uitype>=25&&this.fieldneedFormualarr[k].uitype<=50){//单据头和单据分录“金额/货币”类型
            var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');
            if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
              stypeofdata[1] = 2;
            }
            this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
          }else if(this.fieldneedFormualarr[k].uitype ==20){//数字类型字段根据小数位数控制
            var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');

            this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);

          }else if(this.fieldneedFormualarr[k].uitype ==24){
            this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula));
          }else{
            this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].cur_columnname].value=parseFloat(eval(strformula),10).toFixed(2);
          }
        }


        if(isNaN(cur_obj.value) || cur_obj.value == 'Infinity'){
          this.vueobj.viewlist.entry.list[id_rowIndex][columnname].value = 0;
        }


        if($.inArray(this.fieldneedFormualarr[k].cur_columnname,this.formulaneedColumnarr)>=0)//如果当前字段参与了字段公式的计算
        {
          //console.log(this.formulaneedColumnarr);
          if(this.formulaneedColumnarr.includes(this.fieldneedFormualarr[k].cur_columnname))
          {
            var  tmpcol=this.fieldneedFormualarr[k].cur_columnname;

            var tmp_formulainfo= this.computercolumnsformula[tmpcol];

            var intersect = tmp_formulainfo.filter(v =>
              this.haveFinishedFormulaColumnsarr.includes(v)
            );//获取需要重新计算的字段
            if(this.fieldneedFormualarr[k].cur_columnname=='tax_amount')
            {
              for(var tmpi=0;tmpi<intersect.length;tmpi++)
              {
                var tmpcolumnname=intersect[tmpi];
                if(this.finishedcolumncount[tmpcolumnname]!=undefined&&
                  this.finishedcolumncount[tmpcolumnname]>2)
                {
                  continue;
                }
                this.haveFinishedFormulaColumnsarr.splice(this.haveFinishedFormulaColumnsarr.indexOf(tmpcolumnname),1) ;
              }
            }
          }
          //this.setValueByFormula_vue(event,columnname,id_rowIndex);

        }
      }
      catch(ex)
      {

      }
    }
  }
  //this.haveFinishedFormulaColumnsarr=new Array();//
  //console.log(this.haveFinishedFormulaColumnsarr);
  this.finishedcolumncount=[];
  //合计反算
  if(this.cur_input_focus_obj != undefined && this.cur_input_focus_obj.id == 'tax_amount'+id_rowIndex){
    // fieldformulaobj.setHtmlEventWhenTaxAmount(id_rowIndex);
    //fieldformulaobj.reverseformual_fun(id_rowIndex,'tax_amount');
  }
}
fieldFormula.prototype.depthCompueFormula_vue=function(formulaColumn,id_rowIndex)
{
  var strformula='';
  var strformulavalue = '';
  if($.inArray(formulaColumn,this.columnneedFormulaarr)<0)
  {
    return this.vueobj.viewlist.entry.list[id_rowIndex][formulaColumn].value;
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
          if(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]]==undefined)
          {
            return this.vueobj.viewlist.entry.list[id_rowIndex][formulaColumn].value;
          }
          if(this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value == '')
            strformula+=0;
          else
            strformula+=this.vueobj.viewlist.entry.list[id_rowIndex][this.fieldneedFormualarr[k].letters[onechar]].value;
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
      if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'||this.fieldneedFormualarr[k].cur_columnname=='listprice'){
        strformulavalue =parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
      }else{
        if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<15){
          strformulavalue=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
        }else if(this.fieldneedFormualarr[k].uitype>=25&&this.fieldneedFormualarr[k].uitype<=50){
          //单据头和单据分录“金额/货币”类型
          var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');
          if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
            stypeofdata[1] = 2;
          }
          strformulavalue=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
        }else if(this.fieldneedFormualarr[k].uitype ==20||this.fieldneedFormualarr[k].uitype==15){
          //数字类型字段根据小数位数控制,折扣率
          var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');

          strformulavalue=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
        }else if(this.fieldneedFormualarr[k].uitype ==24){
          strformulavalue=parseFloat(eval(strformula));
        }else{
          strformulavalue=parseFloat(eval(strformula),10).toFixed(2);
        }

      }
      break;
    }
  }
  return '('+strformulavalue+')';
}
/**
edit:can
reason:通过html元素的ID获取字段名称
id_name:元素id
id_rowIndex:元素所在行-2（2：删除protab前面两行)
**/
fieldFormula.prototype.getColumnName=function(id_name,id_rowIndex)
{
    var id_len=Tools.trim((id_rowIndex+"")).length;//添加双引号的目的是把id_rowIndex变为字符串
    var formulaColumn=id_name.substr(0,id_name.length-id_len);
    return formulaColumn;
}
fieldFormula.prototype.depthCompueFormula=function(formulaColumn,id_rowIndex)
{
    var strformula='';
	var strformulavalue = '';
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
                    if(document.getElementById(this.fieldneedFormualarr[k].letters[onechar]+id_rowIndex).value == '')
                        strformula+=0;
                    else
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
			if(this.fieldneedFormualarr[k].cur_columnname=='taxprice'||this.fieldneedFormualarr[k].cur_columnname=='listprice'){
				strformulavalue =parseFloat(eval(strformula),10).toFixed(this.lengthPrice);
			}else{
				if(this.fieldneedFormualarr[k].uitype>=10&&this.fieldneedFormualarr[k].uitype<15){
					strformulavalue=parseFloat(eval(strformula),10).toFixed(this.lengthDecimaldigits);
				}else if(this.fieldneedFormualarr[k].uitype>=25&&this.fieldneedFormualarr[k].uitype<=50){
                      //单据头和单据分录“金额/货币”类型
                    var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');
                    if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
                        stypeofdata[1] = 2;
                    }
                    strformulavalue=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                }else if(this.fieldneedFormualarr[k].uitype ==20||this.fieldneedFormualarr[k].uitype==15){
					  //数字类型字段根据小数位数控制,折扣率
					var stypeofdata =this.fieldneedFormualarr[k].typeofdata.split(',');

					strformulavalue=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
				}else if(this.fieldneedFormualarr[k].uitype ==24){
					strformulavalue=parseFloat(eval(strformula));
				}else{
					strformulavalue=parseFloat(eval(strformula),10).toFixed(2);
				}

			}
            break;
        }
    }
    return '('+strformulavalue+')';
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
    if(typeofdata != undefined && typeofdata != 'undefined'){
        var datas=typeofdata.split('~');
        if(datas[0].toLocaleLowerCase()=='d'||datas[0].toLocaleLowerCase()=='dt')
        {
            return 'yes'
        }
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
    var datas=typeofdata.split('~');
    return datas[0].toLocaleLowerCase();
}
/**
edit:can
reason:不含税单价改变(例如改变币种)
**/
fieldFormula.prototype.changelistprice=function(id_index)
{
    var htmlobj=document.getElementById('listprice'+id_index);
    this.cur_input_focus_obj=htmlobj;
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
//日期相减
fieldFormula.prototype.DateDiff = function(sDate1, sDate2) {  //sDate1和sDate2是yyyy-MM-dd格式

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
reason: 指定行所有字段公式的计算
**/
fieldFormula.prototype.CountRowFormulaColumn=function(id_index)
{

    if(id_index >= 0 && this.vueobj.viewlist.entry.list.length > 0 && this.vueobj.viewlist.entry.list[id_index]){
      for(let i =0;i<this.fieldneedFormualarr.length;i++){
        for(let j=0;j<this.fieldneedFormualarr[i].columnnames.length;j++){
          if(this.vueobj.viewlist.entry.list[id_index][this.fieldneedFormualarr[i].columnnames[j]] != undefined) {
            this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].columnnames[j]] = this.vueobj.viewlist.entry.list[id_index][this.fieldneedFormualarr[i].columnnames[j]].value;
          }
        }
        if(this.vueobj.viewlist.entry.list[id_index][this.fieldneedFormualarr[i].cur_columnname] != undefined){
          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].cur_columnname] = this.vueobj.viewlist.entry.list[id_index][this.fieldneedFormualarr[i].cur_columnname].value;
        }
      }
    }
    //if(this.hiddenlistprice == 'yes'){
        var htmlobj=document.getElementById(this.baseColumn+id_index);
    /*}
    else{
        var htmlobj=document.getElementById('listprice'+id_index);
    }*/
    fieldformulaobj.cur_input_focus_obj=htmlobj;
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
fieldFormula.prototype.changedatabyColumnname=function(columnname,rowindex)
{
    if(rowindex >= 0){
      for(let i =0;i<this.fieldneedFormualarr.length;i++){
        for(let j=0;j<this.fieldneedFormualarr[i].columnnames.length;j++){
          if(this.vueobj.viewlist.entry.list[rowindex-1][this.fieldneedFormualarr[i].columnnames[j]] != undefined) {
            this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].columnnames[j]] = this.vueobj.viewlist.entry.list[rowindex-1][this.fieldneedFormualarr[i].columnnames[j]].value;
          }
        }
        if(this.vueobj.viewlist.entry.list[rowindex-1][this.fieldneedFormualarr[i].cur_columnname] != undefined){
          this.vueobj.hiddenfieldvalue_arr[this.fieldneedFormualarr[i].cur_columnname] = this.vueobj.viewlist.entry.list[rowindex-1][this.fieldneedFormualarr[i].cur_columnname].value;
        }
      }
    }
         var htmlobj=document.getElementById(columnname+rowindex);   //document.getElementById(columnname+rowindex);
         if(htmlobj==undefined)
        {
            return ;
        }
          fieldformulaobj.cur_input_focus_obj=htmlobj;
          fieldformulaobj.haveFinishedFormulaColumnsarr.push(columnname+rowindex);
          fieldformulaobj.cur_formula_obj=htmlobj;
          /*if(columnname=='tax_amount')
          {
                this.reverseformual_fun(rowindex,'tax_amount');

          }
          else*/
            fieldformulaobj.setValueByFormula(null,htmlobj,rowindex);


}
//反算公式计算
fieldFormula.prototype.reverseformual_fun=function(id_rowIndex,cur_columnname){
    var columnnameproductindex_arr=[];
    for (var m = 0; m < this.ProductField.length; m++) {
        columnnameproductindex_arr[this.ProductField[m]['columnname']]=m;
    }
    // 没有反算直接return
    if(this.reversecolumnformula[cur_columnname] == undefined){
        return;
    }
    for(var k=0;k<this.reversecolumnformula[cur_columnname].length;k++){
    	strformula='';
		//引发计算的字段在需要计算字段中
        if( $.inArray(cur_columnname,this.reversecolumns)>=0){
            var formulastring=$.trim(this.reversecolumnformula[cur_columnname][k].formulastring);//获取字段公式
            var reverseobj=this.reversecolumnformula[cur_columnname][k];

			// if(this.ProductField[columnnameproductindex_arr['productname']]['text'] <= 0){
			// 	continue;
			// }
            let productcolumnindex=-1;
            for(var i=0;i<formulastring.length;i++){
                var onechar=formulastring.substr(i,1);
                if(onechar==''){
                    continue;
                }

                //如果是变量
                if($.inArray(onechar,letters)>=0){
                    productcolumnindex=columnnameproductindex_arr[reverseobj.letters[onechar]];
                    if(this.ProductField[productcolumnindex] == undefined){
                        var tmp_hideproductField_array = [];
                        if(this.vueobj.hideproductField){
                            for(let hideindex = 0;hideindex<this.vueobj.hideproductField.length;hideindex++){
                                tmp_hideproductField_array.push(this.vueobj.hideproductField[hideindex].columnname);
                            }
                        }
                        if($.inArray(tmp_hideproductField_array,tmp_hideproductField_array) >= 0){
                          if(this.vueobj.hiddenfieldvalue_arr[reverseobj.letters[onechar]] != undefined){
                            strformula+=this.vueobj.hiddenfieldvalue_arr[reverseobj.letters[onechar]];
                            continue;
                          }else{
                            return;
                          }
                        }else{
                          return;
                        }
                    }
					if(this.ProductField[productcolumnindex]['text']==undefined||this.ProductField[productcolumnindex]['text']==null){
						strformula+="0";
						continue;
					}
					if(this.isDateColumn(reverseobj.letters[onechar])=='yes'){
						return "0";
					}
					else{
						if($.trim(this.ProductField[productcolumnindex]['text'])==''){
							this.ProductField[productcolumnindex]['text']=0;
						}
						//如果计算的值为负数，则计算不成功    如a-b b为负数
					    if(eval(this.ProductField[productcolumnindex]['text']) < 0){
							strformula +='('+eval(this.setFieldLenDecimal(reverseobj.letters[onechar],this.ProductField[productcolumnindex]['text']))+')';
						}
                        else{
							strformula+=this.setFieldLenDecimal(reverseobj.letters[onechar],this.ProductField[productcolumnindex]['text']);
					    }
					}
                }
                else if($.inArray(onechar,chineseBrackets)>=0){//如果中文括号
                    //中文左括号
                    if(onechar==chineseleftbracket){
                        strformula+='(';
                    }
                    else if(onechar==chineserightbracket){
                        strformula+=')';
                    }
                }
                else {
                    strformula+=onechar;
                }
            }
			try{
              var ishide = 'no';
                var cur_obj_index=-1;
                for (var m = 0; m < this.ProductField.length; m++) {
                    if(this.ProductField[m]['columnname'] == reverseobj.columnname){
                        cur_obj_index=m;
                        break;
                    }
                }
				if(cur_obj_index==-1){
					//如果需要计算值的文本是用户输入的文本框，则不需要计算了(例如含税单价和不含税单价可以互相反算)
                    var tmp_hideproductField_array = [];
                    if(this.vueobj.hideproductField){
                        for(let hideindex = 0;hideindex<this.vueobj.hideproductField.length;hideindex++){
                            tmp_hideproductField_array.push(this.vueobj.hideproductField[hideindex].columnname);
                        }
                    }
                    if($.inArray(reverseobj.columnname,tmp_hideproductField_array)){
                        ishide = 'yes';
                    }
                    else{
                        continue;
                    }
				}

				if(reverseobj.columnname=='taxprice'||reverseobj.columnname=='listprice' || reverseobj.uitype == 163){
				  if(ishide == 'no') {
            this.ProductField[cur_obj_index]['text'] = parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
          }else{
				    this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula), 10).toFixed(this.lengthPrice);
          }
				}
                else{
					if(reverseobj.uitype>=10&&reverseobj.uitype<15){
					  if(ishide == 'no') {
              this.ProductField[cur_obj_index]['text'] = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
            }else{
              this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula), 10).toFixed(this.lengthDecimaldigits);
            }
					}
                    else if(reverseobj.uitype>=25&&reverseobj.uitype<50){
                        //单据头和单据分录“金额/货币”类型
                        var stypeofdata =reverseobj.typeofdata.split(',');
                        if(stypeofdata[1] == undefined || stypeofdata[1] == 'undefined' ||stypeofdata[1] ==''){
                            stypeofdata[1] = 2;
                        }
                        if(ishide == 'no'){
                          this.ProductField[cur_obj_index]['text']=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                        }else{
                          this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
                        }
                    }
                    else if(reverseobj.uitype ==20||reverseobj.uitype==15){
                        //数字类型字段根据小数位数控制,折扣率
						var stypeofdata =reverseobj.typeofdata.split(',');
            if(ishide == 'no'){
              this.ProductField[cur_obj_index]['text']=parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
            }else{
              this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula),10).toFixed(stypeofdata[1]);
            }
					}
                    else if(reverseobj.uitype ==24){

            if(ishide == 'no'){
              this.ProductField[cur_obj_index]['text']=parseFloat(eval(strformula));
            }else{
              this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula));
            }
					}
                    else{
					    //toFixed
                        //含税单价47245.7x0.05=2362.285，四舍五入应该是2362.29，
						//JsNumbertoFixed(parseFloat(eval(strformula),10),2);
            if(ishide == 'no'){
              this.ProductField[cur_obj_index]['text']=parseFloat(eval(strformula),10).toFixed(2);
            }else{
              this.vueobj.hiddenfieldvalue_arr[reverseobj.columnname] = parseFloat(eval(strformula),10).toFixed(2);
            }
					}
				}

				if(isNaN(this.ProductField[cur_obj_index]['text']) || this.ProductField[cur_obj_index]['text'] == 'Infinity'){
					this.ProductField[cur_obj_index]['text']=0;
				}
            }
            catch(ex){
            }
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



/**
edit:chj
reason:价税合计允许手动录入，以及触发反算其他信息
*
fieldFormula.prototype.setHtmlEventWhenTaxAmount = function(id_rowIndex){
    var _tax_amount_formulastring,_tax_amount_columnstring;
    for(var k=0;k<this.fieldneedFormualarr.length;k++)
    {
        if(this.fieldneedFormualarr[k].cur_columnname == 'tax_amount'){
            _tax_amount_formulastring=this.fieldneedFormualarr[k].formulastring.toLowerCase();//获取价税合计字段公式
            break;
        }
    }
    for(var i=0 ;i<this.restobj.length;i++)
    {
         if(this.restobj[i].columnname == 'tax_amount'){
            _tax_amount_columnstring = html_decode(this.restobj[i].columnstring);
            break;
         }
    }

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
        if(eval(quantity) <= 0)quantity = 1;
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
        if(document.getElementById('tax3'+id_rowIndex) != undefined){
            _tax += eval(document.getElementById('tax3'+id_rowIndex).value);
        }
        var _discount_presence_amount = _discount_percent/_discount_percent;
        if(isNaN(_discount_presence_amount) || _discount_presence_amount == 'Infinity'){
            _discount_presence_amount = 0;
        }
        var _discount_presence_amount1 = 100/_discount_percent;
        if(isNaN(_discount_presence_amount1) || _discount_presence_amount1 == 'Infinity'){
            _discount_presence_amount1 = 0;
        }

        //根据系统参数[单据分录明细中录入价税合计重算的字段]来判断反算字段
        if(this.systems_deploy_140 == 'listprice' || this.systems_deploy_140==''){
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
            if(document.getElementById('actualtaxprice'+id_rowIndex) != undefined){
                var _actualtaxprice = _tax_amount/quantity;
                fieldformulaobj.setFieldHtmlForValue('actualtaxprice',_actualtaxprice,id_rowIndex);
            }
        }else{
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
        //this.CountRowFormulaColumn(id_rowIndex);
    }
    return false;

}*/
