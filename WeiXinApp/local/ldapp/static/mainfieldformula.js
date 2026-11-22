function cls_mainfieldformula(formulainfo,vuewobj)
{

    var letters=Tools.letters;

     this.formulainfo=formulainfo;
    this.computerfieldnamesformula={};//参与计算的字段公式
    this.computerfieldnames=[];//参与计算的字段
    this.maincolumninfo=[];//主表字段属性
    this.mainfieldinfo_arr=[];
    this.hadcomputerfieldnames=[];//已经计算的字段
    this.HaveSenditivefieldname = [];
    this.vueobj=vuewobj;
    var that=this;
    that.formulafieldinfo=[];//获取需要计算的字段，有哪些字段参与

    that.formulaid_formulajson=[];
    this.cls_AESencryptionbykeyobj = new cls_AESencryptionbykey();


    that.html_decode=function(str)
    {
    	 var retstr='';
      var   strarr=str.split('&#039;');//目前转义单引号
       for(var k=0;k<strarr.length;k++)
       {

        retstr+=strarr[k];
    	if(k!=strarr.length-1)
          retstr+="'";
       }

       return retstr;
    }

    this.init=function(blocklist){



            $.each(blocklist,function(blockindex,blockinfo){

                      $.each(blockinfo.fieldinfo,function(tmpfieldindex,tmpfieldinfo){

                        that.mainfieldinfo_arr[tmpfieldinfo.fieldname]=tmpfieldinfo;
                        that.maincolumninfo[tmpfieldinfo.columnname]=tmpfieldinfo;
                      })

             });
             if(this.formulainfo!=undefined)

             $.each(this.formulainfo,function(tmpindex,tmpinfo){
                if(tmpinfo.functiontype!='' && tmpinfo.functiontype!='sql')
                 return true;
                var tmpcolumnstring=that.html_decode(tmpinfo.columnstring);

                var tmparr=eval('('+ tmpcolumnstring+')')?eval('('+tmpcolumnstring +')'):JSON.parse(tmpcolumnstring);

                if(tmparr.formulavar!=undefined)
                {
					//公式为空  或者   普通用户没有公式字段的权限，导致JS报错。 这个先加个异常处理   chj   20220511

                        $.each(tmparr.formulavar,function(formulvarindex,tmp_info){

                              if(tmp_info.column=='total')
                                {
                                    that.computerfieldnames.push('total');
                                    if(that.computerfieldnamesformula['total']==undefined)
                                    {
                                      that.computerfieldnamesformula['total']=[];
                                    }
                                    tmpinfo.columnname=tmp_info.column;
                                    that.computerfieldnamesformula['total'].push(tmpinfo);

                              }
              							if(tmp_info.column != '' && that.maincolumninfo[tmp_info.column] != undefined
                             && that.maincolumninfo[tmp_info.column] != 'undefined'){
                      								if(that.maincolumninfo[tmp_info.column]==undefined)
                      									return true;//没有字段权限，或者 布局规则
                                      var tmpfieldname=that.maincolumninfo[tmp_info.column].fieldname;
                      								if($.inArray(tmp_info.column,that.computerfieldnames)<0)
                      								{
                      									//获取触发计算字段
                      									that.computerfieldnames.push(tmpfieldname);

                      								}
                      								if(that.computerfieldnamesformula[tmpfieldname]==undefined)
                      								{
                      									that.computerfieldnamesformula[tmpfieldname]=[];
                      								}
                                      tmpinfo.columnname=tmp_info.column;
                      								that.computerfieldnamesformula[tmpfieldname].push(tmpinfo);
                                  }
                         })

                }
         })


    }


    this.setMainFieldEvent=function(){


            $.each(that.computerfieldnames,function(tmpindex,tmpfieldname){
            var oldtmpfieldname=tmpfieldname;

            var tmpobj=$("#"+tmpfieldname);
            tmpobj.unbind("change",that.startComputer)
            tmpobj.bind("change",{formulafieldname:oldtmpfieldname},that.startComputer);
        })


    }
    this.CreatePageComputer=function()
    {
        $.each(that.computerfieldnamesformula,function(tmpindex,tmpfieldname){
            //新增界面有字段默认值
            that.setvaluebyformula(tmpindex)
        })

        that.hadcomputerfieldnames=[];

    }
    this.startComputer=function(event){

      var formulafieldname=event.data.formulafieldname;

       if(that.computerfieldnamesformula[formulafieldname]==undefined)
       return ;

       that.inputobj=$(this);
       that.hadcomputerfieldnames=[];
        that.HaveSenditivefieldname = [];
        that.setvaluebyformula(formulafieldname);
        that.hadcomputerfieldnames=[];
        //布局 规则
        // that.vueobj.CheckReLoadFieldRule();

      that.vueobj.$nextTick(function(){
        that.vueobj.CheckReLoadFieldRule();
        if(that.HaveSenditivefieldname.length > 0){
          that.vueobj.fieldsensitiveruleobj.getAllSensitiveData_arr(that.HaveSenditivefieldname);
        }
      })
    }

    this.CountRowFormulaColumn=function(){
        if(this.computerfieldnamesformula){
          for(let columnname in this.computerfieldnamesformula){
            var param=[];
            param['data']={'formulafieldname':columnname};
            this.startComputer(param);
          }
        }
    }


    //formulafieldname：引发计算的字段公式
    this.setvaluebyformula=function(formulafieldname){

        var record=that.vueobj.recordid;

         var formulafieldnameinfo=that.computerfieldnamesformula[formulafieldname];
        if(formulafieldnameinfo==undefined)
        {
            return ;
        }

        var tmpneedcomputercols=[];

        $.each(formulafieldnameinfo,function(tmpindex,formulainfo){

             var formulastring=formulainfo.formulastring;
             var formulajson=that.html_decode(formulainfo.columnstring);
             var formulaarr=eval('('+ formulajson+')')?eval('('+formulajson +')'):JSON.parse(formulajson);
             var needcomputedfieldname=formulainfo.fieldname;//获取需要被计算的字段


            if(formulainfo.functiontype == '') {
              // try{
              var strformula = '';
              var formulalen = formulastring.length;
              var letter = '';

              for (var i = 0; i < formulalen; i++) {
                letter = formulastring.substr(i, 1);
                var tmpfieldname = '';
                var tmpcolumn = '';
                if ($.inArray(letter, letters) >= 0) {
                  $.each(formulaarr.formulavar, function (tmp_index, tmp_info) {
                    if (tmp_info.lettervar == letter) {
                      if (tmp_info.column != 'total') {
                        if (that.maincolumninfo[tmp_info.column]) {
                          tmpfieldname = that.maincolumninfo[tmp_info.column].fieldname;
                        }
                      }
                      tmpcolumn = tmp_info.column;
                      return false;
                    }
                  })

                  var tmpvalue = 0;
                  var tmpobj;
                  if (tmpcolumn == 'total') {
                    tmpobj = $("#total");
                    tmpfieldname = 'total';
                  } else {
                    if (that.maincolumninfo[tmpcolumn]) {
                      tmpobj = $("#" + that.maincolumninfo[tmpcolumn].fieldname);//ld("#"+that.popupobj.divid+" [name="+that.maincolumninfo[tmpcolumn].fieldname+"]");
                    } else {
                      return;
                    }
                  }

                  if (tmpobj && tmpobj.length > 0) {
                    if (tmpfieldname == 'total') {
                      tmpvalue = $(tmpobj).val();
                    } else {
                      tmpvalue = that.getValue(tmpfieldname);
                    }
                  }

                  if (Tools.trim(tmpvalue + "") == '') {
                    tmpvalue = 0;
                  }
                  if (eval(tmpvalue) < 0) {
                    tmpvalue = '(' + tmpvalue + ')';
                  }
                  strformula += tmpvalue;

                } else {

                  strformula += letter;
                }
              }


              var tmpobj = $("#" + needcomputedfieldname);

              if (tmpobj == that.inputobj || $.inArray(needcomputedfieldname, that.hadcomputerfieldnames) >= 0) {

                return true;
              }

              that.hadcomputerfieldnames.push(needcomputedfieldname);
              that.HaveSenditivefieldname.push(needcomputedfieldname);
              tmpneedcomputercols.push(needcomputedfieldname);

              if (tmpobj.length > 0) {

                that.setValue(needcomputedfieldname, eval(strformula));

              }

            }else{
                that.vueobj.mainfieldsqlformulaobj = new cls_mainfieldsqlformula();
                that.vueobj.mainfieldsqlformulaobj.setPopupobj(that.vueobj);
                that.vueobj.mainfieldsqlformulaobj.setmainfieldformulaobj(that);
                that.vueobj.mainfieldsqlformulaobj.getFldValueBySqlFormula(needcomputedfieldname,formulainfo);
                tmpneedcomputercols.push(needcomputedfieldname);
            }
        })


        $.each(tmpneedcomputercols,function(index,tmpcol){

            if(tmpcol!=''&&$.inArray(tmpcol,that.computerfieldnames)>=0)
            {

                 var tmp_formulainfo= that.computerfieldnamesformula[tmpcol];//查看当前被计算的字段，参与了哪些字段公式计算

                if(tmp_formulainfo!=undefined)
                {
                    $.each(tmp_formulainfo,function(tmpindex,tmpinfo){

                         var fieldname=that.maincolumninfo[tmpinfo.columnname.fieldname];
                          var tmp_arr_index=$.inArray(fieldname,that.hadcomputerfieldnames);
                          if(tmp_arr_index>=0){
                              //已经计算的过的字段，但是其中参与计算的字段值改变，那么已经计算的字段需要重新计算
                              //例如导入
                              that.hadcomputerfieldnames.splice(tmp_arr_index,1);
                          }
                   })
                   that.vueobj.$nextTick(function(){
                               that.setvaluebyformula(tmpcol);

                    })

                }
            }
        })

    }
    this.getValue=function(fieldname){


         let blocklen=that.vueobj.listData.list.length;
         for(var i=0;i<blocklen;i++)
         {
             let fieldinfo_arr=that.vueobj.listData.list[i].fieldinfo;
             let fieldlen=fieldinfo_arr.length;
             for(var j=0;j<fieldlen;j++)
             {
                 if(fieldinfo_arr[j].fieldname==fieldname)
                 {
                     var text = fieldinfo_arr[j].text;
                     if(fieldinfo_arr[j].sensitivepresence && fieldinfo_arr[j].sensitivepresence == 'yes' && fieldinfo_arr[j].havesensitivevalue == 'yes'){
                       text = that.cls_AESencryptionbykeyobj.getdecryption(fieldinfo_arr[j].sensitiveencryptvalue);
                     }
                     return text;
                 }
             }
         }

    }
    this.setValue=function(fieldname,value)
    {
        let blocklen=that.vueobj.listData.list.length;

         for(var i=0;i<blocklen;i++)
         {
             let fieldinfo_arr=that.vueobj.listData.list[i].fieldinfo;
             let fieldlen=fieldinfo_arr.length;
             for(var j=0;j<fieldlen;j++)
             {
                 if(fieldinfo_arr[j].fieldname==fieldname)
                 {
                      fieldinfo_arr[j].text=that.setFieldLenDecimal(fieldinfo_arr[j],value);
                      that.vueobj.fieldsensitiveruleobj.fieldnamechangeFun(fieldname);
                      break;
                 }
             }
         }
    }

    that.setFieldLenDecimal = function(fieldinfo,value){

            var  typeofdata=fieldinfo.typedata;
            var  fieldname=fieldinfo.fieldname;

            if(fieldinfo.bigtype=='date'||fieldinfo.bigtype=='datetime')
            {
                return value;
            }
            if(typeofdata==undefined)
            {
               return  Tools.Number.toDecimal(value,2);//JsNumbertoFixed(value,2);
            }
            var typeofdata_arr=typeofdata.split(",");
            var  tmplen=typeofdata_arr[1];
            if(tmplen == ''){
                tmplen = 2;
            }
            var uitype = fieldinfo.uitype;
            if(fieldinfo.bigtype=='currency'&&((uitype!=71&&uitype!=72)||fieldname == 'unit_price'))
            {
               return  Tools.Number.toDecimal(value,2);//JsNumbertoFixed(value,2);
            }

            var typeofdata_arr=typeofdata.split(",");
            var  tmplen=typeofdata_arr[1];
            return Tools.Number.toDecimal(value,tmplen);//JsNumbertoFixed(value,tmplen);
    }



}

export default {
    cls_mainfieldformula
}
