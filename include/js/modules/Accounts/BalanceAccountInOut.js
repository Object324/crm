function BalanceAccountInOut(popupobj)
{
    //往来对账
    
    var balanceaccountinoutmodules=ld("#"+popupobj.divid+" [name=balanceaccountinout]").val();
  //  alert(ld("#"+popupobj.divid+" [name=balanceaccountinout]").length);
    var that=this;
    that.popupobj=popupobj;
    that.advft_criteria={};
    that.advft_criteria_groups={};
    that.advancefieldnames={};
    that.fields={};
    that.viewids={};
    that.advanceset=[]; //相关信息栏-高级设置
    //that.searchscopes={};
    
    this.init=function()
    {
        var popupobj=this.popupobj;
        
        var tmparr=balanceaccountinoutmodules.split(',');
        var strhtml='';
        
         for(var i=0;i<tmparr.length;i++){
            strhtml+="<div name='balance_"+popupobj.divid+"_"+tmparr[i]+"'></div>";
         }
          ld('#'+popupobj.divid+' .DivCTable').html(strhtml);
          for(var i=0;i<tmparr.length;i++){
          that.callsearch(tmparr[i]);
        }
    }
    this.callsearch=function(related_module){
        var popupobj=this.popupobj;
        var divid = popupobj.divid;
        var module = popupobj.headermodule;//相关信息所关联的模块(查看界面的模块)
        var record = popupobj.detailpage_record;//相关信息所关联的
        var related_id=popupobj.relateid;
        ldAjaxNoProgresssync("index.php?module="+module+"&action="+module+"Ajax&file=getDetailViewRelateID&relatemodule="+related_module
            ,{},function(ajaxdata){
            related_id=ajaxdata.result.id;
        })
        /*if(related_module=='SalesOrder'){
            if(module=='ServiceCharge'){
                related_id=235;
            }
            else
            related_id=4;
        }
        else if(related_module=='CashBill'){
              if(module=='ServiceCharge'){
                related_id=246;
            }
            else
            related_id=141;
        }
         else if(related_module=='SalesBack'){
              if(module=='ServiceCharge'){
                related_id=250;
            }
            else
            related_id=191;
        }
        else if(related_module=='CashBack'){
             if(module=='ServiceCharge'){
                related_id=251;
            }
            else
            related_id=211;
        }*/
        var otherurl=popupobj.otherurl;
        var _start = 1;
        var urldata = "&header="+module+"&record="+record+"";
        urldata += "&relatedid="+related_id+"&currpage=1&related_left_type=1";
        urldata += "&SearchScope=SmOwner_Search_All";
        urldata += '&related_module='+related_module;
        urldata += '&fromtab=BalanceOfAccount';
        var viewid=0;
        if(ld("#"+divid+' [name=selectcustomview_'+related_module+']').length>0) {
            //edit:can 20210402 045261: （https://61mis.com/kfbcrm [^]）客户问题（普阳会计），客户查看详情界面，相关信息->往来对账列表界面，数据分类选项下拉选项后没有反应
//说明	（https://61mis.com/kfbcrm [^]）客户问题（普阳会计），客户查看详情界面，相关信息->往来对账列表界面，数据分类选项下拉选项后没有反应
            viewid=popupobj.viewid;
            urldata += '&viewid='+viewid;
        }
        //分页
        urldata+="&start="+popupobj.pagenum;
        if(that.advft_criteria[related_module]!=''&&that.advft_criteria[related_module]!=undefined) {
            urldata+="&advft_criteria="+that.advft_criteria[related_module];
            urldata+="&advft_criteria_groups="+that.advft_criteria_groups[related_module];
            urldata+="&searchtype=advance";
        }
        //数据分类
      // alert(ld("#"+popupobj.divid+" [name=selectcustomview_"+popupobj.module+"]").length);
        /* if(ld("#"+popupobj.divid+" [name=selectcustomview_"+related_module+"]").length>0&&that.viewids[related_module]!=undefined)
        {
            //alert(ld("#"+popupobj.divid+" [name=selectcustomview_"+popupobj.module+"]").val());
            urldata+="&viewid="+that.viewids[related_module];
        }*/
        // urldata+=otherurl;
        var url = 'index.php?module=Users&action=UsersAjax&file=setRelatedModList'+urldata;
        ldAjax(url,"",function(data){
            if(data.code=="-1") {
               // Popupobj.CancelEvent();
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                DelProgressObjs();
                return false;
            }
            if(data.code==1) {
                ld("#"+popupobj.divid+" [name=balance_"+popupobj.divid+"_"+related_module+"]").html(data.result.content);
                that.advancefieldnames[related_module]=data.result.advancefieldnames;
                that.fields[related_module]=data.result.fields;
                that.advanceset[related_module]=data.result.advanceset; //wym 240205 XUQIU1002043 单据相关信息显示数据的查询规则可定义
                DelProgressObjs();
            }
        })
        this.popupobj.advanceset=that.advanceset; //wym 240205 XUQIU1002043 高级设置要放到popobj上
        this.popupobj.module='BalanceOfAccount';
    }
    
    this.HighersearchPopup=function(event,jqueryobj)
    {
        var related_module=ld(jqueryobj).attr('relatetag');
        
        var detailviewpagepopup=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);//明细弹出层
        var popupobj=CrmPopup.getPopupObj("last");//明细界面的相关信息弹出层
       
        var Popupobj=new CrmPopup.load("","","","LdPopWidth800px",related_module,"","","","");
        Popupobj.prevshow();
        
        Popupobj.advanceSearchDivid=Popupobj.divid;
       ld('#rptContentLoading').hide();
       if(that.advancefieldnames[related_module]!=undefined)
                var params={'advft_criteria_groups':that.advft_criteria_groups[related_module],'advft_criteria':that.advft_criteria[related_module]};
       else
            var params={};
            
        ldAjaxNoProgress("index.php?module="+related_module+"&action="+related_module+"Ajax&file=ShowAdvanceFilter",params,function(data){
               Popupobj.setParams(data.result.title,that.highersearch,"","LdPopWidth800px",related_module,[related_module],data.result.oktext,data.result.canceltext);
              Popupobj.setInnerHtml=function()
               {
                    if(Popupobj.scrolldiv!="") {
                       ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.scrolldiv+Popupobj.htmlcontent+"</div>"+Popupobj.popupbottomhtml); 
                    }
                    else {
                        ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.htmlcontent+Popupobj.popupbottomhtml);
                    }
                    document.getElementById(Popupobj.divid).style.display="block";
               }
             Popupobj.show(data.result.content);

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = that.advancefieldnames[related_module];
            params.fLabels = data.result.fLabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.advfilterhtml;
            params.criteria_groups_arr = data.result.criteria_groups_arr;
            params.module = related_module;
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.showAdvanceFilter(Popupobj,params);
        });
        // Popupobj.divid=detailviewpagepopup.module+"_"+popupobj.module+"_advancesearchid";
    } 
    
    that.highersearch=function(related_module){
        var popupobj=CrmPopup.getPopupObj("last");//高级查询弹出层

        if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
        var advft_criteria =popupobj.advft_criteria;
        var advft_criteria_groups = popupobj.advft_criteria_groups;
        that.advft_criteria[related_module]=advft_criteria;
        that.advft_criteria_groups[related_module]=advft_criteria_groups;
        popupobj.CancelEvent();
        that.callsearch(related_module);
    }
}