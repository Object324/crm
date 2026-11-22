function cls_mainfieldformula(formulainfo)
{
    this.popupobj=CrmPopup.getPopupObj('last');

    this.setPopupobj=function(popupobj)
    {
        this.popupobj=popupobj;
    }
    this.formulainfo=formulainfo;
    this.computerfieldnamesformula={};//参与计算的字段公式
    this.computerfieldnames=[];//参与计算的字段
    this.maincolumninfo=[];//主表字段属性
    this.mainfieldnameinfo=[];
    this.hadcomputerfieldnames=[];//已经计算的字段

    var that=this;
    that.formulafieldinfo=[];//获取需要计算的字段，有哪些字段参与

    that.formulaid_formulajson=[];


    that.html_decode=function(str)
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
    this.init=function(){
        that.computerfieldnames=[];
        that.computerfieldnamesformula={};
        that.hadcomputerfieldnames=[];
        //  if(this.popupobj.module!='ServiceContracts')
        //        return false;

        ld.each(that.popupobj.fields,function(detailindex,tmpfieldinfo){

            that.maincolumninfo[tmpfieldinfo.columnname]=tmpfieldinfo;
            that.mainfieldnameinfo[tmpfieldinfo.fieldname]=tmpfieldinfo;
        });
        if(this.formulainfo!=undefined)

            ld.each(this.formulainfo,function(tmpindex,tmpinfo){
                if(!empty(tmpinfo.functiontype) && tmpinfo.functiontype!='sql')
                    return true;
                var tmpcolumnstring=that.html_decode(tmpinfo.columnstring);

                var tmparr=eval('('+ tmpcolumnstring+')')?eval('('+tmpcolumnstring +')'):JSON.parse(tmpcolumnstring);

                if(tmparr.formulavar!=undefined)
                {
                    //公式为空  或者   普通用户没有公式字段的权限，导致JS报错。 这个先加个异常处理   chj   20220511

                    ld.each(tmparr.formulavar,function(formulvarindex,tmp_info){
                        if(tmp_info.column != '' && that.maincolumninfo[tmp_info.column] != undefined && that.maincolumninfo[tmp_info.column] != 'undefined'){
                            if(that.maincolumninfo[tmp_info.column]==undefined)
                                return true;//没有字段权限，或者 布局规则
                            if(ld.inArray(tmp_info.column,that.computerfieldnames)<0)
                            {
                                //获取触发计算字段
                                that.computerfieldnames.push(that.maincolumninfo[tmp_info.column].fieldname);

                            }
                            if(that.computerfieldnamesformula[that.maincolumninfo[tmp_info.column].fieldname]==undefined)
                            {
                                that.computerfieldnamesformula[that.maincolumninfo[tmp_info.column].fieldname]=[];
                            }
                            tmpinfo.columnname=tmp_info.column;
                            that.computerfieldnamesformula[that.maincolumninfo[tmp_info.column].fieldname].push(tmpinfo);
                        }
                    })

                }
            })
    }


    this.setPopupobj=function(popupobj){

        this.popupobj=popupobj;
    }



    this.setEvent=function(){

        // if(this.popupobj.module!='ServiceContracts')
        //return false;
console.log(that.computerfieldnames);
        ld.each(that.computerfieldnames, function (tmpindex, tmpfieldname) {
            var oldtmpfieldname = tmpfieldname;
            var typeofdata = that.mainfieldnameinfo[tmpfieldname].typeofdata;
            console.log(that.mainfieldnameinfo[tmpfieldname]);
            //BUG0071549 liushuia 20230825 填写起始日期跟截止日期后自动计算出实际工时（不生效）
            if (typeofdata.toLocaleLowerCase().indexOf("d~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("dt~") >= 0 || typeofdata.toLocaleLowerCase().indexOf("t~") >= 0) {
                var tmpobj = ld("#" + that.popupobj.divid + ' [name=' + tmpfieldname + "]");
                tmpobj.unbind("blur", that.startComputer);
                tmpobj.bind("blur", {formulafieldname: oldtmpfieldname}, that.startComputer);
            }else if(that.mainfieldnameinfo[tmpfieldname].bigtype == 'picklist'){
                //BUG0073690 liushuai 20231011 下拉框作为触发字段不生效
                // var tmpobj = ld("#" + that.popupobj.divid + ' [name=cmb_span_optiontext_' + tmpfieldname + "]");
                var tmpobj = ld("#" + that.popupobj.divid + ' [name=dv_cmb_' + tmpfieldname + "]");
                tmpobj.unbind("click", that.startComputer);
                tmpobj.bind("click", {formulafieldname: oldtmpfieldname}, that.startComputer);
            }else if(that.mainfieldnameinfo[tmpfieldname].bigtype == 'boolean'){
                //BUG20241121-07 ls 2411122 复选框字段不触发
                var tmpobj = ld("#" + that.popupobj.divid + ' [name=sel_' + tmpfieldname + "]");
                tmpobj.unbind("click", that.startComputer);
                tmpobj.bind("click", {formulafieldname: oldtmpfieldname}, that.startComputer);
            } else {
                if (that.mainfieldnameinfo[tmpfieldname].displaytype == 3) {
                    if (that.popupobj.module == "CashBill") {
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=total]');

                    } else if (that.popupobj.module == 'SendCashBill') {
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=total]');
                    } else if (tmpfieldname == 'hdnGrandTotal') {
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=total]');
                    }
                    //zkt 20220621 0051627(https://81mis.com/kfbtest/index.php)报价单页面设置》设置了字段  金额A  的公式为  合计*1  ；新建报价单时，分录显示异常
                    else if (tmpfieldname == 'hdnSubTotal') {
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=subtotal]');
                    } else if (tmpfieldname == 'txtAdjustment') {
                        //调整金额字段
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=adjustment]');
                    }else if (tmpfieldname == 'hdnDiscountAmount') {
                        //整单折扣字段
                        var tmpobj = ld("#" + that.popupobj.divid + ' [name=discount_amount]');
                    }
                } else {
                    var tmpobj = ld("#" + that.popupobj.divid + ' [name=' + tmpfieldname + "]");////ld("#"+that.popupobj.divid+" [name="+tmpcolumn+rowindex+"]")
                }
                console.log(tmpobj);
                if(tmpobj != undefined){
                    tmpobj.unbind("change", that.startComputer)
                    tmpobj.bind("change", {formulafieldname: oldtmpfieldname}, that.startComputer);
                }
            }
        })


    }
    this.CreatePageComputer=function()
    {
        //edit:can 2023411 64371 服务记录单模块，剩余工时=合约工时-已用工时-本次工时（本次工时是默认为1，已用工时、合约工时是引用项目立项里面的
        ld.each(that.computerfieldnamesformula,function(tmpfieldname,tmpfieldinfo){
            //新增界面有字段默认值
            that.setvaluebyformula(tmpfieldname);//BUG20240129-42 ls 240130 项目立项模块，相关信息，关联创建 对外付款申请， 部分字段无法显示值，该字段属性引用sql查询,，但重新选择项目，就会有值
        })
        if(that.popupobj.fieldSensitiveruleobj != undefined){
            that.popupobj.fieldSensitiveruleobj.getAllSensitiveData('');
        }

        that.hadcomputerfieldnames=[];

    }
    this.startComputer=function(event){




        var formulafieldname=event.data.formulafieldname;
        console.log(formulafieldname);
        console.log(that.computerfieldnamesformula);
        if(that.computerfieldnamesformula[formulafieldname]==undefined)
            return ;

        that.inputobj=ld(this);
        that.hadcomputerfieldnames=[];

        that.setvaluebyformula(formulafieldname);
        if(that.popupobj.fieldSensitiveruleobj != undefined && that.popupobj.fieldSensitiveruleobj.HaveSenditivefieldname(that.hadcomputerfieldnames)){
            that.popupobj.fieldSensitiveruleobj.getAllSensitiveData('');
        }
        that.hadcomputerfieldnames=[];
        that.popupobj.fieldruleobj.CheckReLoadPopup();

    }


    //formulafieldname：引发计算的字段公式
    this.setvaluebyformula=function(formulafieldname){


        var record=that.popupobj.record;

        var formulafieldnameinfo=that.computerfieldnamesformula[formulafieldname];
        if(formulafieldnameinfo==undefined)
        {
            return ;
        }
        //  var profilefieldsinfo=that.popupobj.detailobj.profiledetailfields;//有权限的字段


        var tmpneedcomputercols=[];
        //  var cls_encryptobj=new cls_encrypt();

        ld.each(formulafieldnameinfo,function(tmpindex,formulainfo){

            var formulastring=formulainfo.formulastring;
            var formulajson=that.html_decode(formulainfo.columnstring);
            var formulaarr=eval('('+ formulajson+')')?eval('('+formulajson +')'):JSON.parse(formulajson);
            var needcomputedfieldname=formulainfo.fieldname;//获取需要被计算的字段

            if (empty(formulainfo.functiontype)) {

                // try{
                var strformula='';
                var formulalen=formulastring.length;
                var letter='';

                for(var i=0;i<formulalen;i++)
                {

                    letter=formulastring.substr(i,1);
                    var tmpfieldname='';
                    var  tmpcolumn='';
                    if(ld.inArray(letter,letters)>=0)
                    {
                        //  console.log(formulaarr.formulavar);
                        ld.each(formulaarr.formulavar,function(tmp_index,tmp_info){

                            if(tmp_info.lettervar==letter)
                            {
                                //ls 20220712 BUG0053832(http://42.193.125.39:85/crm）材料采购合同新建无法保存(/被布局规则隐藏的字段参与计算公式计算需要重新初始化)
                                if (!empty(that.maincolumninfo[tmp_info.column])) {
                                    tmpfieldname=that.maincolumninfo[tmp_info.column].fieldname;
                                    tmpcolumn=tmp_info.column;
                                }
                                return false;
                            }
                        })

                        if (empty(tmpcolumn))
                        {
                            strformula+='0';
                            continue;
                        }
                        var tmpvalue=0;
                        var tmpobj=ld("#"+that.popupobj.divid+" [name="+that.maincolumninfo[tmpcolumn].fieldname+"]");
                        if(that.popupobj.pagetype==DetailViewPage.pagetype)
                        {
                            //查看界面(通过 后台处理 吧 )
                            // tmpobj=ld("#"+that.popupobj.divid+" [name='"+that.maincolumninfo[tmpcolumn].fieldname+"_name']");
                        }
                        if(that.maincolumninfo[tmpcolumn].displaytype==3)
                        {
                            if(that.popupobj.module=="CashBill")
                            {
                                tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                            }
                            else if(that.popupobj.module=='SendCashBill')
                            {
                                tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                            }
                            else if(tmpcolumn=='total')
                            {
                                tmpobj=ld("#"+that.popupobj.divid+' [name=total]');
                            }
                            else if(tmpcolumn=='adjustment'){
                                tmpobj=ld("#"+that.popupobj.divid+' [name=adjustment]');

                            }
                            else if (tmpfieldname == 'hdnDiscountAmount') {
                                //zkt 20240527 BUG20240523-22  合同订单：编号XSHT131，表头字段中的最终利润字段运算公式计算错误
                                //整单折扣字段
                                tmpobj = ld("#" + that.popupobj.divid + ' #proTabTotal [name=discount_amount]');
                            }
                        }
                        else if(that.maincolumninfo[tmpcolumn].savedatabase=='no')
                        {
                            tmpobj=ld("#"+that.popupobj.divid+" [name=span_"+that.maincolumninfo[tmpcolumn].fieldname+"]");
                        }

                        if(tmpobj.length>0)
                        {
                            if(that.maincolumninfo[tmpcolumn] != [] && that.maincolumninfo[tmpcolumn].havesensitivevalue != undefined && that.maincolumninfo[tmpcolumn].havesensitivevalue == 'yes'){
                                tmpvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(that.maincolumninfo[tmpcolumn].sensitiveencryptvalue,true,that.maincolumninfo[tmpcolumn]);
                            }
                            else{
                                if(tmpobj.is("input"))
                                {
                                    tmpvalue=ld(tmpobj).val();

                                }
                                else
                                {
                                    tmpvalue=ld(tmpobj).html();
                                }
                            }


                        }
                        if(that.maincolumninfo[tmpcolumn].displaytype==3&&tmpcolumn=='adjustment')
                        {
                            if(ld("#"+popupobj.divid+" [name=adjustmentType]").val()=="-")
                            {
                                tmpvalue=0-tmpvalue;
                            }
                        }

                        if(ld.trim(tmpvalue)=='')
                        {
                            tmpvalue=0;
                        }

                        if(eval(tmpvalue)<0)
                        {

                            tmpvalue='('+ tmpvalue +')'
                        }
                        strformula+=tmpvalue;
                    }
                    else if (ld.inArray(letter, chineseBrackets) >= 0)//如果中文括号
                    {
                        if (letter == chineseleftbracket)//中文左括号
                        {
                            strformula += '(';
                        } else if (letter == chineserightbracket) {
                            strformula += ')';
                        }
                    }
                    else
                    {
                        //日期变量{year},{halfyear} {quarter}{month}{week}{day};

                        strformula+=letter;
                    }
                }


                var tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"]");
                if(that.popupobj.pagetype==DetailViewPage.pagetype)
                {
                    //查看界面(通过后台处理吧)
                    // tmpobj=ld("#"+that.popupobj.divid+" [name="+needcomputedfieldname+"_name]");
                }
                if(tmpobj==that.inputobj||ld.inArray(needcomputedfieldname,that.hadcomputerfieldnames)>=0)
                {

                    return true;
                }

                that.hadcomputerfieldnames.push(needcomputedfieldname);
                //tmpneedcomputercols.push(needcomputedfieldname);
                if(tmpobj.length>0)
                {
                    //duan 20240327 如果更新前后的值相同,则不触发计算
                    var before_value = '';
                    var new_value = '';
                    if(tmpobj.is("input")){
                        before_value = ld(tmpobj).val();
                    }else{
                        before_value = ld(tmpobj).html();
                    }
                    var tmpevalvalue = eval(strformula);
                    if(isNaN(tmpevalvalue) || tmpevalvalue == 'Infinity'){
                        tmpevalvalue = 0;
                    }
                    //duan 20240327 如果更新前后的值相同,则不触发计算
                    if(!isNaN(before_value)){
                        before_value = Number(before_value).toFixed(2);
                    }
                    if(!isNaN(tmpevalvalue)){
                        new_value = Number(tmpevalvalue).toFixed(2);
                    }else{
                        new_value = tmpevalvalue;
                    }
                    if(before_value != new_value){
                        tmpneedcomputercols.push(needcomputedfieldname);
                    }
                    var tmphavesetvalue = false;
                    if(that.popupobj.fieldSensitiveruleobj != undefined){
                        var fieldSensitiveruleobj = that.popupobj.fieldSensitiveruleobj;
                        var needcomputedfieldinfo = fieldSensitiveruleobj.getFieldInfoByfieldname(needcomputedfieldname);
                        if(needcomputedfieldinfo && needcomputedfieldinfo.havesensitivevalue == 'yes')
                        {
                            //设置值和设置小数位数是分开的
                            var tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpevalvalue,false,needcomputedfieldinfo);//加密字段
                            fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                            tmpEncryptytvalue = that.setFieldLenDecimal(needcomputedfieldinfo);
                            tmpEncryptytvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(tmpEncryptytvalue,false,needcomputedfieldinfo);//加密字段
                            fieldSensitiveruleobj.setfieldSensitiveinfo(needcomputedfieldname,needcomputedfieldinfo.havesensitivevalue,tmpEncryptytvalue);
                            tmphavesetvalue = true;
                        }
                    }
                    //不是加密字段则直接设置界面值
                    if(!tmphavesetvalue){
                        if(tmpobj.is("input"))
                        {

                            ld(tmpobj).val(tmpevalvalue);
                        }
                        else
                        {
                            ld(tmpobj).html(tmpevalvalue);

                        }
                        ld(tmpobj).val(that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]));
                        if(that.popupobj.fieldname_fields[needcomputedfieldname].allowedit=='no')
                        {
                            ld("#"+that.popupobj.divid+" [name=span_"+needcomputedfieldname+"]").html(ld(tmpobj).val());
                        }
                    }

                    //duan 20240926字段变更后触发公共变化事件
                    if(!empty(that.popupobj.common_field_event_obj)){
                        that.popupobj.common_field_event_obj.common_changefun(tmpobj,needcomputedfieldname);
                    }
                    if(that.popupobj.pagetype==DetailViewPage.pagetype)
                    {
                        //(通过后台处理吧)
                        // ld("#"+that.popupobj.divid+" [name=dtlview_"+needcomputedfieldname+"]").html(ld(tmpobj).val());

                    }
                    // that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]);
                }

                /* }
                 catch(ex)
                 {

                 }*/

            }
            else{
                getScriptBackWithURL('include/js/cls_mainfieldsqlformula.js',function(){
                    that.popupobj.mainfieldsqlformulaobj = new cls_mainfieldsqlformula();
                    that.popupobj.mainfieldsqlformulaobj.setPopupobj(that.popupobj);
                    that.popupobj.mainfieldsqlformulaobj.setmainfieldformulaobj(that);
                    that.popupobj.mainfieldsqlformulaobj.getFldValueBySqlFormula(needcomputedfieldname,formulainfo);
                    if(that.popupobj.mainfieldsqlformulaobj.haschangefieldname_arr.includes(needcomputedfieldname)){
                        tmpneedcomputercols.push(needcomputedfieldname);
                    }
                });

            }
        })

        ld.each(tmpneedcomputercols,function(index,tmpcol){
            if(tmpcol!=''&&ld.inArray(tmpcol,that.computerfieldnames)>=0)
            {

                var tmp_formulainfo= that.computerfieldnamesformula[tmpcol];//查看当前被计算的字段，参与了哪些字段公式计算
                ld.each(tmp_formulainfo,function(tmpindex,tmpinfo){
                    var fieldname=tmpinfo.fieldname;
                    var tmp_arr_index=ld.inArray(fieldname,that.hadcomputerfieldnames);
                    if(tmp_arr_index>=0){
                        //已经计算的过的字段，但是其中参与计算的字段值改变，那么已经计算的字段需要重新计算
                        //例如导入
                        that.hadcomputerfieldnames.splice(tmp_arr_index,1);
                    }
                })

                that.setvaluebyformula(tmpcol);
            }
        })


    }


    that.setFieldLenDecimal = function(fieldinfo){

        var  typeofdata=fieldinfo.typeofdata;
        var  fieldname=fieldinfo.fieldname;
        var value=ld("#"+that.popupobj.divid+' [name='+fieldname+"]").val();
        if(fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            value = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
        }
        if(that.popupobj.pagetype==DetailViewPage.pagetype)
        {
            //查看界面(通过后台处理吧)
            //value=ld("#"+that.popupobj.divid+' [name='+fieldname+"_name]").val();
        }
        if(fieldinfo.bigtype=='date'||fieldinfo.bigtype=='datetime')
        {
            return value;
        }
        if(typeofdata==undefined)
        {
            return  JsNumbertoFixed(value,2);
        }
        var typeofdata_arr=typeofdata.split(",");
        var  tmplen=typeofdata_arr[1];

        if (typeofdata_arr.length < 2) {//其他没有精度的字段直接返回原值
            return value;
        }

        if(fieldinfo.bigtype=='currency'&&tmplen == ''){
            tmplen = 2;
        }
        var uitype = fieldinfo.uitype;
        if(fieldinfo.bigtype=='currency'&&((uitype!=71&&uitype!=72)||fieldname == 'unit_price'))
        {
            return  JsNumbertoFixed(value,2);
        }

        return JsNumbertoFixed(value,tmplen);
    }



}

var dateoperations = new Array('+', '-');
var operations = new Array('+', '-', '*', '/', '%');
var Brackets = new Array('(', ')', '[', ']');
var chineseBrackets = new Array('（', '）');//支持中文括号，单不支持中文【
var chineseleftbracket = '（';
var chineserightbracket = '）';
var digits = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
var letters = new Array('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
    , 'Z', 'Y', 'X', 'U', 'V', 'W', 'T', 'S', 'R', 'Q', 'L');