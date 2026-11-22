function cls_detail2mainformula(mainfieldformula,vueobj,maindatalist,detaildata_entrylist){
  this.computerdetailcolumn_arr=[];
  this.computercolumnfunctiontype_arr=[];
  var that=this;
  that.vueobj=vueobj;
  that.maincolumninfo=[];
  this.detailtableobj;
  this.formulainfo=mainfieldformula;
  this.maindatalist=maindatalist;//主表 数据 双向 绑定
  this.detaildata_entrylist=detaildata_entrylist;//分录数据
  that.detailcolumninfo_arr=[];//分录字段
  that.mainfieldinfo_arr=[];//主表字段
  this.rowindex=0;
  that.needcomputedfieldname_arr=[];//本次计算 主表 被计算的 字段
  this.module = vueobj.mainmodule?vueobj.mainmodule:vueobj.module;
  //console.log(detaildata_entrylist)‘;
  // console.log(detaildata_entrylist);
  this.init=function(blocklist,productfield){
    $.each(productfield,function(tmpindex,tmpfieldinfo){
      that.detailcolumninfo_arr[tmpfieldinfo.columnname]=tmpfieldinfo;
    })

    $.each(blocklist,function(blockindex,blockinfo){
      $.each(blockinfo.fieldinfo,function(tmpfieldindex,tmpfieldinfo){
        that.mainfieldinfo_arr[tmpfieldinfo.fieldname]=tmpfieldinfo;
        that.maincolumninfo[tmpfieldinfo.columnname]=tmpfieldinfo;
      })
    });

    if(this.formulainfo!=undefined&&this.formulainfo!=null){
      $.each(this.formulainfo,function(tmpindex,tmpinfo){
        if(tmpinfo.functiontype=='' || tmpinfo.functiontype=='sql')
          return true;
        if(that.computercolumnfunctiontype_arr[Tools.trim(tmpinfo.columnstring)]==undefined)
          that.computercolumnfunctiontype_arr[Tools.trim(tmpinfo.columnstring)]=[];
        that.computercolumnfunctiontype_arr[Tools.trim(tmpinfo.columnstring)].push(tmpinfo);
        that.computerdetailcolumn_arr.push(Tools.trim(tmpinfo.columnstring))
      });
    }
  }


  this.setAllRowEvent=function(){
    // console.log('setAllRowEvent');
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      $.each(that.vueobj.entrylistData,function(tmpindex,tmpinfo){
        that.setRowEvent(tmpindex+1);
      })
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpinfo){
        that.setRowEvent(tmpindex+1);
      })
    }
  }

  this.changeRowEvent=function(){
    //分录新增行，删除行
    $.each(that.computerdetailcolumn_arr,function(tmpindex,tmpcolumn){
      var param=[];
      param['data']={'formulacolumn':tmpcolumn,rowindex:''};
      that.startComputer(param);
    });
    //反向计算
    that.vueobj.$nextTick(function(){
      that.revertComputerMainField();
    })
  }

  this.setRowEvent=function(idrow_index){
    this.rowindex=idrow_index;
    if(this.vueobj.detailfieldtype!=this.module+"detail")
      idrow_index='';
    $.each(that.computerdetailcolumn_arr,function(tmpindex,tmpcolumn){
      var tmpobj=$('#'+tmpcolumn+idrow_index);////ld("#"+that.popupobj.divid+" [name="+tmpcolumn+rowindex+"]")
      tmpobj.unbind("change",that.startComputer)
      tmpobj.bind("change",{formulacolumn:tmpcolumn,rowindex:idrow_index},that.startComputer);
    })
  }

  this.CheckisComputer=function(column_arr){
    // if(this.popupobj.module!='ServiceContracts')
    // return false;
    arr = column_arr.sort()
    var arrry= [arr[0]];
    for (var i = 1; i < arr.length; i++) {
      if (arr[i] !== arr[i-1]) {
        arrry.push(arr[i]);
      }
    }
    column_arr=arrry;
    // console.log(column_arr);
    $.each(column_arr  ,function(tmpindex,tmpcolumn){
      var param=[];
      param['data']={'formulacolumn':tmpcolumn};
      that.startComputer(param);
    })
  }

  this.startComputer=function(event){
    var formulacolumn=event.data.formulacolumn;
    var idrow_index=event.data.rowindex;//企业微信，钉钉，云之家没有用，小程序有用
    if(that.computercolumnfunctiontype_arr[formulacolumn]==undefined)
      return;

    var needcomputedfieldname_arr=[];
    $.each(that.computercolumnfunctiontype_arr[formulacolumn],function(tmpindex,tmpinfo){
      var needcomputedfieldname=tmpinfo.fieldname;//主表字段

      if($("#"+needcomputedfieldname).length<=0)
        return true;

      switch(tmpinfo.functiontype.toLowerCase()){
        case 'avg':
          var value=that.getAvg(formulacolumn,idrow_index);
          break;
        case 'max':
          var value=that.getmax(formulacolumn,idrow_index);
          break;
        case 'min':
          var value=that.getmin(formulacolumn,idrow_index);
          break;
        case 'sum':
          var value=that.getSum(formulacolumn,idrow_index);
          break;
        case 'count':
          var value=that.getCount(formulacolumn,idrow_index);
          break;
        case 'first':
          var value=that.getFirst(formulacolumn,idrow_index);
          break;
        case 'last':
          var value=that.getLast(formulacolumn,idrow_index);
          break;
        case 'countdistinct':
          var value = that.getCountDistinct(formulacolumn,idrow_index);
          break;
        }

        $.each(that.maindatalist,function(tmpindex,tmpblockfieldinfo){
          $.each(tmpblockfieldinfo.fieldinfo,function(tmpfieldindex,tmpfielditem){
            if(tmpfielditem.fieldname==needcomputedfieldname){
              if(tmpfielditem.typedata){
                let typedata = tmpfielditem.typedata;
                let typedataarr = typedata.split(",");
                let tmplen = 2;
                if(typedataarr.length > 1 && typedataarr[1] != ''){
                  tmplen = parseInt(typedataarr[1]);
                  that.maindatalist[tmpindex].fieldinfo[tmpfieldindex].text=Tools.Number.toDecimal(value,tmplen);
                }
                else{
                  that.maindatalist[tmpindex].fieldinfo[tmpfieldindex].text=value;
                }
              }
              else{
                that.maindatalist[tmpindex].fieldinfo[tmpfieldindex].text=value;
              }
              return false;
            }
          })
        })
      if($.inArray(needcomputedfieldname,that.needcomputedfieldname_arr)<0){
        that.needcomputedfieldname_arr.push(needcomputedfieldname);
      }
    })
  }

  this.revertComputerMainField=function(){
    let needcomputedfieldname_arr=that.needcomputedfieldname_arr;
    that.vueobj.Mainfieldformulaobj.hadcomputerfieldnames=[];
    $.each(needcomputedfieldname_arr,function(tmpindex,needcomputedfieldname){
      that.vueobj.Mainfieldformulaobj.setvaluebyformula(needcomputedfieldname);
    })
    that.vueobj.Mainfieldformulaobj.hadcomputerfieldnames=[];
    that.vueobj.checkFieldrule();
    that.needcomputedfieldname_arr=[];
  }

  this.getAvg=function(detailcolumnname,idrow_index){
    //平均值
    var total=0;
    var realrows=0;
    var strformula='0';
    if(that.detailcolumninfo_arr[detailcolumnname]==undefined){
      return 0;
    }

    if(this.vueobj.detailfieldtype==this.module+'detail'){
      $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes'){
          return true;
        }

        strformula=strformula+"+"+$("#"+detailcolumnname+(tmpindex+1)).val();
        realrows+=1;
      })
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpvalueinfo)=='yes')
          return true;
        if(tmpvalueinfo[detailcolumnname].value==''){
          tmpvalueinfo[detailcolumnname].value=0;
        }
        strformula=strformula+"+"+tmpvalueinfo[detailcolumnname].value;
        realrows+=1;
      })
    }
    var total=eval(strformula);
    if(realrows>0){
      total=total/realrows;
    }
    return total;
  }

  this.getCount=function(detailcolumnname,idrow_index){
    //计数
    var realrows=0;
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;
        realrows+=1;
     })
   }
   else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes'){
          return true;
        }
        realrows+=1;
      });
    }
    return realrows;
  }

  this.getCountDistinct=function(detailcolumnname,idrow_index){
    //去重计数
    var fieldvalue = '';
    var realrows=0;
    var fieldvalue_arr = new Array();

    if(that.detailcolumninfo_arr[detailcolumnname]==undefined)
      return '';

    var columnArr = that.detailcolumninfo_arr[detailcolumnname];

    if(this.vueobj.showDetailforOA){
      $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;

        if(columnArr.bigtype == "picklist"){
          fieldvalue= $("#"+detailcolumnname+(tmpindex+1)).html();
        }
        else{
          fieldvalue= $("#"+detailcolumnname+(tmpindex+1)).val();
        }

        if(fieldvalue!='' && ! fieldvalue_arr.includes(fieldvalue)){
          fieldvalue_arr.push(fieldvalue);
          realrows += 1;
        }
      })
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;

        fieldvalue= tmpvalueinfo[detailcolumnname].value;

        if(fieldvalue!='' && ! fieldvalue_arr.includes(fieldvalue)){
          fieldvalue_arr.push(fieldvalue);
          realrows += 1;
        }
      })
    }
    return realrows;
  }

  this.getFirst=function(detailcolumnname,idrow_index){
    //取第一行
    var firstvalue='';
    if(that.detailcolumninfo_arr[detailcolumnname]==undefined)
      return '';
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;
        firstvalue= $("#"+detailcolumnname+(tmpindex+1)).val();
        return false;
      })
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;
        firstvalue= tmpvalueinfo[detailcolumnname].value;
        return false;
      })
    }
    return firstvalue;
  }

  this.getLast=function(detailcolumnname,idrow_index){
    //取最后一行
    var len=that.detaildata_entrylist;
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      len=that.vueobj.entrylistData.length;
    }
    var lastvalue='';
    for(var i=len;i>0;i--){
      if(this.vueobj.detailfieldtype==this.module+'detail'){
        var tmpvalue= $("#"+detailcolumnname+(i)).val()
      }
      else{
        var tmpvalueinfo=that.detaildata_entrylist[i];
        var tmpvalue=tmpvalueinfo[detailcolumnname].value
      }

      if(that.CheckisEmptyRow(i)=='yes')
        continue;
      edit_permission=that.detailcolumninfo_arr[detailcolumnname].edit_permission;
      lastvalue= tmpvalueinfo[detailcolumnname].value;//.val();
      return false;
    }
    return lastvalue;
  }

  this.getmax=function(detailcolumnname,idrow_index){
    var strformula='0';
    //获取最大值或最小值
    var bigtype= that.detailcolumninfo_arr[detailcolumnname].bigtype;
    var arr=[];
    if(bigtype=='date')
      var maxvalue="1600-01-01";
    else
      var maxvalue=-99999999;

    if(that.detailcolumninfo_arr[detailcolumnname]==undefined){
      return '';
    }
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      if(this.vueobj.showDetailforOA || this.vueobj.showDetailforTimesheet){
        $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
          if(that.CheckisEmptyRow(tmpindex)=='yes'){
            return true;
          }
          if(bigtype=='date'){
            if($("#"+detailcolumnname+(tmpindex+1)).val()<maxvalue){
              maxvalue=$("#"+detailcolumnname+(tmpindex+1)).val();
            }
          }
          else{
            if($("#"+detailcolumnname+(tmpindex+1)).val()*1.00<maxvalue){
              maxvalue=$("#"+detailcolumnname+(tmpindex+1)).val()
            }
          }
        })
      }
      else{
        $.each(that.vueobj.viewlist.entry.list,function(tmpindex,tmpvalueinfo){
          if(that.CheckisEmptyRow(tmpindex)=='yes'){
            return true;
          }
          if(tmpvalueinfo[detailcolumnname].value==''){
            tmpvalueinfo[detailcolumnname].value=0
          }
          strformula=strformula+"+"+tmpvalueinfo[detailcolumnname].value
        })
      }
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes'){
          return true;
        }
        if(bigtype=='date'){
          if(tmpvalueinfo[detailcolumnname].value>maxvalue){
            maxvalue=tmpvalueinfo[detailcolumnname].value
          }
        }
        else{
          if(tmpvalueinfo[detailcolumnname].value*1.00>maxvalue){
            maxvalue=tmpvalueinfo[detailcolumnname].value
          }
        }
      })
    }
    return maxvalue;
  }

  this.getmin=function(detailcolumnname,idrow_index){
    //获取最小值
    var bigtype= that.detailcolumninfo_arr[detailcolumnname].bigtype;
    var arr=[];
    if(bigtype=='date')
      var minvalue="2100-12-01";
    else
      var minvalue=99999999999;
    if(that.detailcolumninfo_arr[detailcolumnname]==undefined){
      return '';
    }
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      $.each(that.vueobj.viewlist.entry.list,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes'){
          return true;
        }
        if(bigtype=='date'){
          if($("#"+detailcolumnname+(tmpindex+1)).val()<minvalue){
            minvalue=$("#"+detailcolumnname+(tmpindex+1)).val();
          }
        }
        else{
          if($("#"+detailcolumnname+(tmpindex+1)).val()*1.00<minvalue){
            minvalue=$("#"+detailcolumnname+(tmpindex+1)).val()
          }
        }
      })
   }
   else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes')
          return true;

        if(bigtype=='date'){
          if(tmpvalueinfo[detailcolumnname].value<minvalue){
            minvalue=tmpvalueinfo[detailcolumnname].value
          }
        }
        else{
          if(tmpvalueinfo[detailcolumnname].value*1.00<minvalue){
            minvalue=tmpvalueinfo[detailcolumnname].value
          }
        }
      });
    }
    return minvalue;
  }

  this.getSum=function(detailcolumnname,idrow_index){
    var total=0;
    var strformula='0';

    if(that.detailcolumninfo_arr[detailcolumnname]==undefined){
      return 0;
    }
    if(this.vueobj.detailfieldtype==this.module+'detail'){
      if(this.vueobj.showDetailforOA || this.vueobj.showDetailforTimesheet){
        $.each(that.vueobj.entrylistData,function(tmpindex,tmpvalueinfo){
          if(that.CheckisEmptyRow(tmpindex)=='yes'){
            return true;
          }
          if($("#"+detailcolumnname+(tmpindex+1)).val()==''){
            $("#"+detailcolumnname+(tmpindex+1)).val(0)
          }
          strformula=strformula+"+"+$("#"+detailcolumnname+(tmpindex+1)).val()
        })
      }
      else{
        $.each(that.vueobj.viewlist.entry.list,function(tmpindex,tmpvalueinfo){
          if(that.CheckisEmptyRow(tmpindex)=='yes'){
            return true;
          }
          if(tmpvalueinfo[detailcolumnname].value==''){
            tmpvalueinfo[detailcolumnname].value=0
          }
          strformula=strformula+"+"+tmpvalueinfo[detailcolumnname].value
        })
      }
    }
    else{
      $.each(that.detaildata_entrylist,function(tmpindex,tmpvalueinfo){
        if(that.CheckisEmptyRow(tmpindex)=='yes'){
          return true;
        }
        if(tmpvalueinfo[detailcolumnname].value==''){
          tmpvalueinfo[detailcolumnname].value=0;
        }
        strformula=strformula+"+"+tmpvalueinfo[detailcolumnname].value;
      })
    }
    total=eval(strformula);
    return total;
  }

  this.CheckisEmptyRow=function(rowindex){
    return 'no';

    if(that.popupobj.detailfieldmodule=='Products'){
      var productid = ld(rowobj).find(" [name=hdnProductId]").val();
      if(ld.trim(productid)==''||parseInt(productid)<=0){
        //判断是否为空行
        return 'yes';
      }
    }
    else{
      var ret='no';
      ld.each(that.popupobj.detailfields,function(tmpindex,tmpinfo){
        if(tmpinfo.typeofdata.indexOf("~M")>0){
          if(ld.trim(ld(rowobj).find(" [detailcolumnname="+tmpinfo.columnname+"]").val())==''){
            ret='yes';
            return false;
          }
        }
      })
      return ret;
    }
    return  'no';
  }
}

export default {
  cls_detail2mainformula
}
