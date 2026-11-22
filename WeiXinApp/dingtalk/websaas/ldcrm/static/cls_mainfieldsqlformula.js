//liushuai 20230718 XUQIU1001661 单据头字段录入方式增加“通过SQL查询”
function cls_mainfieldsqlformula()
{
    this.setPopupobj=function(vuewobj)
    {
        this.vueobj=vuewobj;
        this.mainfieldformulaobj=this.vueobj.mainfieldformulaobj;

        this.fieldlist = [];
        var blocklist = that.vueobj.viewlist.list;
        for (var i = 0; i < blocklist.length; i++) {
          for (var j = 0; j < blocklist[i].fieldinfo.length; j++) {
            this.fieldlist.push(blocklist[i].fieldinfo[j].fieldname);
          }
        }
    }

    this.setmainfieldformulaobj=function(mainfieldformulaobj)
    {
        this.mainfieldformulaobj=mainfieldformulaobj;
    }

    var that=this;


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
              if (tmpfieldname = 'total') {
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
        tmpneedcomputercols.push(needcomputedfieldname);

        if (tmpobj.length > 0) {

          /*if(tmpobj.is("input"))
          {

                    $(tmpobj).val(eval(strformula));
          }
          else
          {
                    $(tmpobj).html(eval(strformula));

          }

        $(tmpobj).val(that.setFieldLenDecimal(that.mainfieldinfo_arr[needcomputedfieldname]));
         if(that.mainfieldinfo_arr[needcomputedfieldname].readyonly=='yes')
         {
            if($("#"+needcomputedfieldname+"]").is("span"))
              $("#"+needcomputedfieldname+"]").html($(tmpobj).val());
            else
                 $("#"+needcomputedfieldname+"]").val($(tmpobj).val());
         }*/

          that.setValue(needcomputedfieldname, eval(strformula));


          // that.setFieldLenDecimal(that.popupobj.fieldname_fields[needcomputedfieldname]);
        }

        /* }
         catch(ex)
         {

         }*/
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


    //访问后台去查询指定的sql
    this.getFldValueBySqlFormula=function(needcomputedfieldname,formulainfo){
        that.vueobj.hadusedtriggercolumnlist=[];
        that.vueobj.hadgivenvaluecolumnlist=[];//已经赋值过的字段

        var listObj = that.vueobj.getviewlistColumnname();
        let sensitiverequestfield = [];//敏感规则 被加密字段
        var blocklist = that.vueobj.listData.list;
        for (var i = 0; i < blocklist.length; i++) {
          for (var j = 0; j < blocklist[i].fieldinfo.length; j++) {
            if(blocklist[i].fieldinfo[j].sensitivepresence && blocklist[i].fieldinfo[j].sensitivepresence == 'yes' && blocklist[i].fieldinfo[j].havesensitivevalue == 'yes' && blocklist[i].fieldinfo[j].sensitiveencryptvalue != ''){
              sensitiverequestfield.push('requestvalues-'+blocklist[i].fieldinfo[j].fieldname);
              listObj[blocklist[i].fieldinfo[j].fieldname] = blocklist[i].fieldinfo[j].sensitiveencryptvalue;
            }
          }
        }

        var tmp_module = '';
        if(that.vueobj.mainmodule != '' && that.vueobj.mainmodule != undefined){
          tmp_module = that.vueobj.mainmodule;
        }else{
          tmp_module = that.vueobj.module;
        }


        if(tmp_module){
          that.vueobj.mob_ajax({
            'module': 'Users',
            'action': 'getFldValueBySqlFormula',
            "modulename":tmp_module,
            "requestvalues":JSON.stringify(listObj),
            "formulaid":formulainfo.formulaid
          }, (rest) => {
            if(rest.length <=0) return false;
            if(rest!= '' && rest!= 'null'){
              var restobj = rest;
              that.mainfieldformulaobj.hadcomputerfieldnames.push(needcomputedfieldname);
              //页面赋值
              that.setSqlFormulaValue(restobj,needcomputedfieldname);
            }
          });
        }
      }

    //给页面赋值
    this.setSqlFormulaValue=function(restobj,columnname)
    {
      var vueobj=that.vueobj;
      if(vueobj.hadusedtriggercolumnlist==undefined)
      {
        vueobj.hadgivenvaluecolumnlist=[];//已经赋值过的字段
        vueobj.hadusedtriggercolumnlist=[];
        vueobj.fieldrulevalues=[];//因为界面的布局规则导致没有显示的字段，暂存

      }
      if(columnname=='')
      {
        columnname='aabcedtfgh';
      }

      for(var i = 0; i<restobj.length; i++) {
        if (i > 150) {
          //edit:can 20200811 布局规则调用该函数，会进入死循环，没有找到原因，所以只能添加该判断
          break;
        }
        //其中负责人不允许修改
        if (restobj[i] == null || that.fieldlist.indexOf(restobj[i]['rawValue']['input_name']) < 0 || restobj[i]['rawValue']['input_name'].indexOf('assigned_user_id') >= 0 || restobj[i]['rawValue']['input_name'] == '') {
          if (restobj[i] != null && vueobj.fieldrulevalues && vueobj.fieldrulevalues!='') {
            vueobj.fieldrulevalues.push(restobj[i]);
          }
          continue;
        }

        if ($.inArray(restobj[i]['rawValue']['input_name'], vueobj.hadgivenvaluecolumnlist) >= 0) {
          //已经赋值过的字段不需要再赋值，例如客户和联系人可以循环赋值
          continue;
        }

        vueobj.hadgivenvaluecolumnlist.push(restobj[i]['rawValue']['input_name']);//已经赋值过的字段

        let blocklen=that.vueobj.listData.list.length;
        for(var ii=0;ii<blocklen;ii++)
        {
          let fieldinfo_arr=that.vueobj.listData.list[ii].fieldinfo;
          let fieldlen=fieldinfo_arr.length;
          for(var jj=0;jj<fieldlen;jj++)
          {
            if(fieldinfo_arr[jj].fieldname==restobj[i]['rawValue']['input_name'])
            {
              let beforeText = that.vueobj.listData.list[ii].fieldinfo[jj].value;
              let text = restobj[i]['rawValue']['value'];
              if(that.vueobj.listData.list[ii].fieldinfo[jj].type != 7){
                that.vueobj.listData.list[ii].fieldinfo[jj].value = restobj[i]['rawValue']['value'];
              }
              that.vueobj.listData.list[ii].fieldinfo[jj].text = restobj[i]['rawValue']['value'];
              if(restobj[i]['value'] && restobj[i]['value']['input_name'] && restobj[i]['value']['input_name'] == fieldinfo_arr[jj].fieldname+'_name'){
                that.vueobj.listData.list[ii].fieldinfo[jj].text = restobj[i]['value']['value'];
              }
              var param = {};
              param['data']={'formulafieldname':fieldinfo_arr[jj].fieldname};
              that.vueobj.Mainfieldformulaobj.startComputer(param);
              if(beforeText != text){
                // 布局规则，是否重新加载界面
                that.vueobj.fieldruleSelectedBefore(restobj[i]['rawValue']['input_name']);
              }
              break;
            }
          }
        }
      }

    }



}
