var datetimestr;//日期查询条件
var fLabels;//查询条件下拉框翻译
function cls_pagelayout()
{
    //修改tab页签
    this.prevdvidname='cfList';
    this.changetabcontent=function(obj)
    {

        ld("#dv_quickcreate_content").html('');
        ld("#dv_relateinfo_content").html('');
        var dvidname=obj.getAttribute('dvidname');
        ld("#"+this.prevdvidname).css("display",'none');
        ld("li[dvidname="+this.prevdvidname+"]").find("a").attr("class",'');

        this.prevdvidname=dvidname;
        ld("li[dvidname="+dvidname+"]").find("a").attr("class",'On');
        ld('a[name=btn_addblock],a[name=btn_add]').hide();


        if(dvidname=='cfList')
        {
            hidePageLayOutDiv();
            ld("#cfList").css('display','');
            ld('a[name=btn_addblock]').show();
        }
        else if(dvidname=='dv_pagerule')
        {
            //布局规则
            hidePageLayOutDiv();
            var cls_pageruleobj=cls_pagerule.getInstance();
            cls_pageruleobj.getList();
            ld('a[name=btn_add]').show();
        }
        else if(dvidname=='dv_pagevalidata')
        {
            //验证规则
             hidePageLayOutDiv();
             var cls_pagevalidataobj=cls_PageValidata.getInstance();
             cls_pagevalidataobj.getList();
             ld('a[name=btn_add]').show();
        }
		else if(dvidname=='dv_advance')
        {
            //进度跟踪设置
            hidePageLayOutDiv();
            AdvanceRelation.getAdvanceList();
        }
        else if(dvidname=='dv_relateinfo')
        {
            //相关信息
            hidePageLayOutDiv();
            var cls_relateinfoobj=new cls_relateinfo();
            cls_relateinfoobj.getList();

        }
        else if(dvidname=='dv_quickcreate')
        {
            //快速创建
            var cls_quickcreateobj=new cls_quickcreate();
            cls_quickcreateobj.getList();
        }
        else if(dvidname=='dv_mapviewlist')
        {
            //地图视图列表
            hidePageLayOutDiv();
            var cls_mapviewlistobj=new cls_mapviewlist();
            cls_mapviewlistobj.getList('list');
        }
		else if(dvidname=='dv_mapviewdetails')
        {
            //地图视图详情
            hidePageLayOutDiv();
            var cls_mapviewlistobj=new cls_mapviewlist();
            cls_mapviewlistobj.getList('detail');
        }
        else if(dvidname=='dv_fieldlist')
        {
            //字段列表详情
            hidePageLayOutDiv();
            var cls_fieldlistobj=cls_fieldlist.getInstance();
            cls_fieldlistobj.getList();
        }
        else if(dvidname=='dv_cfoperationlog')
        {
            //自定义字段操作列表详情
            hidePageLayOutDiv();
            var cls_cfoplogobj=cls_cfoplog.getInstance();
            cls_cfoplogobj.getList();
        }
    }
}

function cls_pagerule()
{
    this.listid='dv_pagerule';//div的id
    var that=this;

    that.init=function()
    {
        this.record=0;
        this.arr_basicsearch=[];//触发字段的条件
        this.arr_advancesearch=[];//其他查询
        this.arr_triggeroperate=[];//触发操作
        this.triggerfieldname="";//触发字段的fieldname
        this.triggercolumnname='';
        this.editlabel='';//编辑的翻译
        this.deletelabel='';//删除的翻译
        this.setrequiredlabel='';//设置必填字段的翻译
        this.displayfieldlabel='';//显示字段的翻译
        this.fields=[];//界面所有的字段
        this.column_fields=[];//界面已columnname为关键字的所有字段
    }
    this.getList=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.frommodule;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockRuleList&frommodule='+frommodule,'', function(data)
        {
            if(data.code==1)
            {
                hidePageLayOutDiv();
                ld("#dv_pagerule").css("display",'');
                ld("#dv_pagerule").html(data.result.content);
                tooltip('.tip-items-lists', {transition: true, time: 200});
                ld('a[name=btn_add]').unbind('click').bind('click',function(){
                    //新增
                    that.init();
                    that.showrulepagepop();
                })
                ld("#"+that.listid+ ' [name=btn_stop]').unbind('click').bind('click',function(){
                    //停用
                    that.init();
                    that.record=ld(this).attr('record');
                    that.setrulestatus('no');
                })
                ld("#"+that.listid+ ' [name=btn_activate]').unbind('click').bind('click',function(){
                    //启用
                    that.init();
                    that.record=ld(this).attr('record');
                    that.setrulestatus('yes');
                })

                ld.each(ld("#"+that.listid+" [name=btn_edit]"),function(index,obj){
                    ld(this).unbind("click").bind("click",function(){
                        that.init();
                        that.record=ld(obj).attr('record');
                        that.showrulepagepop();
                    })
                });
                ld.each(ld("#"+that.listid+" [name=btn_delete]"),function(index,obj){
                    ld(this).unbind("click").bind("click",function(){
                        that.init();
                        that.record=ld(obj).attr('record');
                        that.deleterule();
                    })
                });
            }
        });
    }

    this.showrulepagepop=function()
    {
        //新增规则
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.frommodule;
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px",frommodule,"","","","");
        Popupobj.prevshow();
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockrulePop&frommodule='+frommodule+"&ruleid="+that.record,'',function(data)
        {

            if(data.code==1)
            {
                Popupobj.setParams(data.result.title,that.saverule,"","LdPopWidth800px",frommodule,"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
                CrmPopup.frommodule=frommodule;
                datetimestr=data.result.datetimestr;//日期的查询条件

                fLabels=data.result.flabel;
                that.editlabel=data.result.editlabel;//编辑的翻译
                that.deletelabel=data.result.deletelabel;//删除的翻译
                that.setrequiredlabel=data.result.setrequiredlabel;//设置必填字段的翻译
                that.displayfieldlabel=data.result.displayfieldlabel;//显示字段的翻译
                that.fields=data.result.fields;
                var triggercolumnname=data.result.triggercolumnname;
                var triggerfieldobj=ld("#"+Popupobj.divid+" [name=triggerfield]");

                ld.each(data.result.fields,function(fieldname,info){
                    that.column_fields[info.columnName]=info;
                    //37794: （1.6）页面设置-布局规则：触发字段下拉选项应该显示【可编辑字段】，目前只读字段也显示了
                    ////BUG0068505 lius 20230626 附件/图片设置了布局规则，但是不生效(附件/图片不支持作为布局规则的触发字段),附件虽然不能作为触发字段，但是可以作为触发操作的必填字段，由于这两个下拉框值取值用的同一个，所以不能从后台直接处理，需要前端处理触发字段
                    if(info.displaytype=='2'||info.savedatabase=='no'||info.bigtype=='selectsource'||ld.inArray(info.uitype,['28','69','1108','1109'])>0)
                    {
                        return true;
                    }
                    if(triggercolumnname==info.columnName)
                    {

                        triggerfieldobj.append("<option value='"+info.columnName+"' selected=''>"+info.fieldLableKey+"</option>");
                    }
                    else
                        triggerfieldobj.append("<option value='"+info.columnName+"'>"+info.fieldLableKey+"</option>");

                });
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml('triggerfield');
                cls_resetComboxHtmlobj.setComboxObjHtml();

                ld("#"+Popupobj.divid+" .dvpopupsroll").css("min-height",'350px');
                CrmPopup.center(ld("#"+Popupobj.divid),Popupobj);

                ld("#"+Popupobj.divid+" [name=btn_addlayoutrule]").unbind("click").bind("click",function(){
                    //“新增布局规则”按钮
                    that.addrulerow();
                });
                if(that.record>0)
                {
                    //显示布局规则列表
                    var strhtml="";
                    var rowindex=1;
                    ld.each((data.result.condition),function(index,info){
                        if(info.basicsearch==undefined)
                        {
                            return true;
                        }
                        that.arr_basicsearch.push(info.basicsearch);
                        that.arr_advancesearch.push(info.advancesearch);
                        that.arr_triggeroperate.push(info.triggeroperate);

                        var rowcount=ld("#"+Popupobj.divid+" [name=tablerulecondition]").find("tr").length;
                        var strhtml='<tr class="lvtColData" rowindex="'+rowcount+'">';
                        //触发字段
                        strhtml+='<td style="margin:0 auto;text-align:center">'+rowcount+'</td>';
                        var basicsearchid=info.basicsearch.basicsearchid;
                        strhtml+='<td valign="center" name="basicsearchtd">'+that.createbasicsearchtd(info,rowcount)+"</td>";

                        strhtml+='<td name="advancesearchtd">'+that.createadvancesearctd(info,rowcount)+"</td>";
                        strhtml+='<td valign="center" style="overflow:inherit;white-space: inherit;" name="triggeroperatetd">'+that.createtriggeroperatetd(info,rowcount)+"</td>";

                        strhtml+="</tr>";
                        ld("#"+Popupobj.divid+" [name=tablerulecondition]").append(strhtml);
                        that.setrowevent(rowcount);
                    })
                    that.setTriggerColumnEnable();//设置触发字段的下拉框是否可以点击
                }
                that.addrulerow();

            }
        });
    }

  //触发字段条件
    that.createbasicsearchtd=function(info,rowindex){
            var popupobj=CrmPopup.getPopupObj('last');

            var divid=popupobj.divid;
         // var rowcount=ld("#"+divid+" [name=tablerulecondition]").find("tr").length;
         var comparator=info.basicsearch.comparator;
         var comparatorlabel=fLabels[comparator];
         var basicsearchid=info.basicsearch.basicsearchid;
         var fieldinfo=that.column_fields[info.basicsearch.columnname];
         if(fieldinfo.typeofData.indexOf("D")>=0&&datetimestr[comparator]!=undefined)
         {
            //edit:can 2021-01-18 44294: （https://61mis.com/kfbcrm [^]）页面设置->布局规则，触发字段选择“日期”类型字段，设置条件保存后，布局规则编辑界面触发字段条件比较关系显示“undefined”（费用报销单模块测试）
           comparatorlabel= datetimestr[comparator][2];
         }
         var strhtml='';
          strhtml+='<div>';
          strhtml+='<span>';
          strhtml+='<a class="Anu3_a" herf="javascript:;" style="font-weight: bold;color: #666;font-size: 14px;">'+comparatorlabel+'</a>';
          strhtml+=" </span>";
          strhtml+='<span>';
          strhtml+='<a class="Anu3_a" tag="editbasicsearch" basicsearchid="'+basicsearchid+'"   childrowindex="'+rowindex+'">'+that.editlabel+'</a>';
          strhtml+='<a class="Anu3_a" tag="deletebasicsearch" basicsearchid="'+basicsearchid+'" childrowindex="'+rowindex+'">'+that.deletelabel+'</a>';
          strhtml+=" </span>";
          strhtml+="<div>";
         var fieldlabel='';

         fieldlabel=fieldinfo.fieldLableKey;


         strhtml+='<span style="padding-left:5px;">'+fieldlabel+'</span>';
         strhtml+='<span style="padding-left:5px;color: #888;">'+comparatorlabel+'</span>';
         strhtml+='<span style="padding-left:5px;">'+info.basicsearch.value+'</span>';
         strhtml+="</div>";
          return strhtml;
    }

    //其他条件
    that.createadvancesearctd=function(info,rowindex)
    {
       //  var rowcount=ld("#"+divid+" [name=tablerulecondition]").find("tr").length;
          var basicsearchid=info.basicsearch.basicsearchid;
          var strhtml="";

        strhtml+=' <div style="margin:0 auto;text-align:center">';
        strhtml+='<img src="themes/images/add.png" style="width:28px;height:28px" tag="editadvancesearch" basicsearchid="'+basicsearchid+'" childrowindex="'+rowindex+'"/>';
        strhtml+='</div>';
        return strhtml;

    }

    //触发操作
    that.createtriggeroperatetd=function(info,rowindex)
    {
        var basicsearchid=info.basicsearch.basicsearchid;
        var type=info.triggeroperate[0].type;
      //  var rowcount=ld("#"+divid+" [name=tablerulecondition]").find("tr").length;
        var strhtml="";
        strhtml+='<div>';
        strhtml+='<span>';
        if(type=='required')
        {
          strhtml+='<a class="Anu3_a" herf="javascript:;" style="font-weight: bold;color: #666;font-size: 14px;">'+that.setrequiredlabel+'</a>';
        }
        else{
          strhtml+='<a class="Anu3_a" herf="javascript:;" style="font-weight: bold;color: #666;font-size: 14px;">'+that.displayfieldlabel+'</a>';
        }
        strhtml+=" </span>";
        strhtml+='<span>';
        strhtml+='<a class="Anu3_a" tag="edittriggeroperate" basicsearchid="'+basicsearchid+'"  type="'+type+'" childrowindex="'+rowindex+'">'+that.editlabel+'</a>';
        strhtml+='<a class="Anu3_a" tag="deletetriggeroperate" basicsearchid="'+basicsearchid+'"   childrowindex="'+rowindex+'">'+that.deletelabel+'</a>';
        strhtml+='</span></div>';
        strhtml+='<div style="white-space: initial;line-height: 24px;">';
        ld.each(info.triggeroperate,function(index,operateinfo){
              var columnname=operateinfo.columnname;
              if(that.column_fields[columnname]!=undefined)
              {
                 var fieldlabel=that.column_fields[columnname].fieldLableKey;
                strhtml+='<span style="padding-left:5px;">'+fieldlabel+'</span>';
              }
        });

        strhtml+=' </div>';
        return strhtml;
    }
    that.addrulerow=function()
    {
        //新增布局规则按钮
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var rowcount=ld("#"+divid+" [name=tablerulecondition]").find("tr").length;
        var strhtml='<tr class="lvtColData" rowindex="'+rowcount+'" style="height:60px">';

        strhtml+='<td name="#" style="margin:0 auto;text-align:center">'+rowcount+'</td>';

        strhtml+='<td name="basicsearchtd">';
        strhtml+=that.addBasicSearchTdImageHtml(rowcount)+'</td>';
        strhtml+='<td name="advancesearchtd">';
        strhtml+=that.addAdvanceSearchTdImageHtml(rowcount)+'</td>';

        strhtml+='<td name="triggeroperatetd" style="overflow: inherit;">';
        strhtml+=that.addTriggerOperateTdImageHtml(rowcount)+'</td>';

        strhtml+='</tr>';
        ld("#"+divid+" [name=tablerulecondition]").append(strhtml);
        var triggerfieldcolumnname=ld("#"+popupobj.divid+" [name=triggerfield]").val();//获取触发字段

       that.setarr_basicsearchEmpty(rowcount);

        var tmpobj={"groupid":1, "columnname":"",'comparator':'',"value":'',"basicsearchid":0,'columncondition':''};
        this.arr_advancesearch.push(tmpobj);

       that.setarr_triggeroperateEmpty(rowcount);

        CrmPopup.center(ld("#"+popupobj.divid),popupobj);
        that.setrowevent(rowcount);
    }
    this.addBasicSearchTdImageHtml=function(rowindex)
    {
        var strhtml='<div style="margin:0 auto;text-align:center">';
        strhtml+='<img src="themes/images/add.png" title="'+arrJsPopLabel['SetTriggerFieldConditionJS']+'" style="width:28px;height:28px" tag="addbasicsearch" childrowindex="'+rowindex+'"/></div></td>';
        return strhtml;
    }
    this.addAdvanceSearchTdImageHtml=function(rowindex)
    {
        var strhtml='<div style="margin:0 auto;text-align:center">';
        strhtml+='<img src="themes/images/add.png" title="'+arrJsPopLabel['SettingOtherConditionJS']+'" style="width:28px;height:28px" tag="addadvancesearch" childrowindex="'+rowindex+'"/></div>';
        return strhtml;
    }
    this.addTriggerOperateTdImageHtml=function(rowindex)
    {
        var strhtml='<div class="divAddTriggerOperate">';
        strhtml+='<img src="themes/images/add.png" title="'+arrJsPopLabel['SetTriggerOperationJS']+'" tag="addtriggeroperate" childrowindex="'+rowindex+'"/>';
        strhtml+='<div name="dvtriggeroperate" class="divAddTriggerOperatePop"><ul><li childrowindex="'+rowindex+'" class="litriggeroperate" onclick="cls_pagerule.getInstance().litriggerOperateClick(ld(this))" type="display">'+that.displayfieldlabel+'</li><li childrowindex="'+rowindex+'" class="litriggeroperate" onclick="cls_pagerule.getInstance().litriggerOperateClick(ld(this))" type=\'required\'>'+that.setrequiredlabel+"</li></ul></div>";
         strhtml+='</div>';
        return strhtml;
    }
    //新增布局规则列表行的事件
    that.setrowevent=function(rowindex)
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var tableobj=ld("#"+popupobj.divid+" [name=tablerulecondition]");
        var objs= tableobj.find(" [childrowindex="+rowindex+"]");
         var rowobj=ld("#"+divid+" [rowindex="+rowindex+"]");
       /*
                     ld.each(ld(rowobj).find(" .litriggeroperate"),function(){
                        alert('wwww');
                       ld(this).unbind("click").bind("click",function(){

                                    ld(rowobj).find("[name=dvtriggeroperate]").css('display','none');
                                     that.showtriggeroperate(ld(this));
                        })
                     })*/
        ld.each(objs,function(index,obj){
            ld(obj).unbind('click').bind('click',function(){
                var thatobj=this;
                switch(ld(this).attr("tag"))
                {
                   case "addbasicsearch":
                    that.showbasisearchpop(ld(this));
                    //新增触发字段条件
                    break;
                   case 'editbasicsearch':

                    that.showbasisearchpop(ld(this));
                    //编辑触发字段条件
                    break;
                    case 'deletebasicsearch'://删除触发字段的条件
                        that.deletebasicsearch(ld(this));
                     break;
                   case "addadvancesearch":
                    that.showadvancesearchpop(ld(this));
                    //新增其他条件查询
                    break;
                   case 'editadvancesearch':
                    that.showadvancesearchpop(ld(this));
                   //编辑其他条件查询
                    break;
                   case 'addtriggeroperate':
                    var rowobj=ld("#"+divid+" [rowindex="+rowindex+"]");
                    //新增触发操作
                    var display = ld(rowobj).find("[name=dvtriggeroperate]").css('display');
                    if(display == 'none'){
                       ld(rowobj).find("[name=dvtriggeroperate]").css('display',"inline");
                    }
                    else{
                        ld(rowobj).find("[name=dvtriggeroperate]").css('display',"none");
                    }
                    // ld(rowobj).find("[name=dvtriggeroperate]").css('display',"inline");
                    // ld("#"+divid+" [name=dvtriggeroperate]").css('float',"right");
                    //ld(rowobj).find(" .litriggeroperate").unbind("click").bind("click",function(){
                     //   ld(rowobj).find("[name=dvtriggeroperate]").css('display','none');
                      //  that.showtriggeroperate(ld(this));
                    //})

                    break;
                   case 'edittriggeroperate':
                    //编辑触发条件的操作；
                    that.showtriggeroperate(ld(this));
                    break;
                   case 'deletetriggeroperate':
                   //删除触发条件的操作
                    that.deletetriggeroperate(ld(this));
                    break;
                }
            });
        });
    }
      that.litriggerOperateClick=function(jqueryobj){
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var rowindex=ld(jqueryobj).attr("childrowindex");
        var rowobj=ld("#"+divid+" [rowindex="+rowindex+"]");
                    //新增触发操作
        var display = ld(rowobj).find("[name=dvtriggeroperate]").css('display');
        if(display == 'none'){
                       ld(rowobj).find("[name=dvtriggeroperate]").css('display',"inline");
        }
        else{
                        ld(rowobj).find("[name=dvtriggeroperate]").css('display',"none");
        }
        ld(rowobj).find("[name=dvtriggeroperate]").css('display','none');
        that.showtriggeroperate(jqueryobj);
    }
     that.setarr_basicsearchEmpty=function(rowindex){
        var popupobj=CrmPopup.getPopupObj('last');
        var triggerfieldcolumnname=ld("#"+popupobj.divid+" [name=triggerfield]").val();//获取触发字段
        var tmpobj={"columnname":triggerfieldcolumnname,'comparator':'',"value":'','basicsearchid':0};
        if(that.arr_basicsearch[rowindex-1]==undefined)
        {
            that.arr_basicsearch.push(tmpobj);

        }
        else
        that.arr_basicsearch[rowindex-1]=tmpobj;
    }
    //删除触发字段的条件
    this.deletebasicsearch=function(jqueryobj)
    {
        var popupobj=CrmPopup.getPopupObj('last');

        var rowindex=ld(jqueryobj).attr('childrowindex');
         var triggerfieldcolumnname=ld("#"+popupobj.divid+" [name=triggerfield]").val();//获取触发字段

        var tmpobj={"columnname":triggerfieldcolumnname,'comparator':'',"value":'','basicsearchid':0};
        that.arr_basicsearch[rowindex-1]=tmpobj;
        var trobj=ld("#"+popupobj.divid+' [rowindex='+rowindex+']');
        trobj.find("[name=basicsearchtd]").html(that.addBasicSearchTdImageHtml(rowindex));//清空td内容
        that.setTriggerColumnEnable();//设置触发字段下拉框是否可以点击
        that.setrowevent(rowindex);

    }

    //触发字段查询弹出层
    //点击事件的对象（image(触发字段，其他条件，触发操作),编辑，删除）
    this.showbasisearchpop=function(jqueryobj)
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.module;
          var rowindex=ld(jqueryobj).attr('childrowindex');
           that.arr_basicsearch[rowindex-1].columnname=ld("#"+popupobj.divid+" [name=triggerfield]").val();//获取触发字段
          var tmpsearchobj=that.arr_basicsearch[rowindex-1];


          var columnname=tmpsearchobj.columnname;
          var comparator=tmpsearchobj.comparator;

           var Popupobj=CrmPopup.load("","","","LdPopWidth600px",frommodule,"","","","");
            Popupobj.prevshow();
            Popupobj.rowindex=rowindex;
            Popupobj.advanceSearchDivid=Popupobj.divid;
            //zkt 20231013 XUQIU1001341 SQL注入
            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=LayoutTriggerFieldSearchPop&frommodule='+frommodule+"&columnname="+columnname,'', function(data)
            {

                if(data.code==1)
                {
                    Popupobj.setParams(data.result.title,that.setarr_basicsearchValue,"","LdPopWidth600px",frommodule,"",data.result.oktext,"",data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
                    that.updatefOptions(ld("#"+Popupobj.divid+" [name=fcol0]").get(0), "fop0");//添加查询条件
                    //把查询的条件（包含，等于）的下拉框中"无"删除
                    if(bigtype!='picklist'){
                        var firstobj= ld("#"+Popupobj.divid+" [name=fop0]").find("option")[0];
                        firstobj.remove();
                    }

                    if(comparator!='')
                    {

                        ld("#"+Popupobj.divid+" [name=fop0]").val(comparator);
                    }
                    addRequiredElements(0);//添加查询内容
                    var value=tmpsearchobj.value;
                    var typeofdata=that.column_fields[columnname].typeofData;
                    var bigtype=that.column_fields[columnname].bigtype;
                    if(bigtype=='picklist')
                    {
                        var parentobj=ld("#"+Popupobj.divid+" [name=fval0]").parent();
                        ld("#"+Popupobj.divid+" [name=fval0]").remove();
                        ld("#"+Popupobj.divid+" [name=clear_text_ext0]").remove();
                        var html='<select name="fval0">';
                        html+="<option value=''></option>";
                        ld.each(data.result.picklistoptions,function(text,tmpvalue){
                            if(value==tmpvalue)
                                html+="<option value='"+text+"' selected>"+tmpvalue+"</option>";
                            else
                                html+="<option value='"+text+"'>"+tmpvalue+"</option>";
                        })
                        html+="</select>";
                        parentobj.append(html);
                        var cls_resetComboxHtmlobj=new cls_resetComboxHtml('fval0');
                        cls_resetComboxHtmlobj.setComboxObjHtml();
                        ld("#"+Popupobj.divid+" [name=cmb_span_optiontext_fval0]").val(value);
                        //edit:can 2021-01-19 044347: （本地php72，8.3.7）系统设置-页面设置-销售机会，新增布局规则，以销售阶段为触发字段时，在条件设置中有2个清除按钮
                        //parentobj.append( '<input type="button" id="clear_text_ext0" name="clear_text_ext0" class="icon-homeimg icon-clear inpb-advSearchreset" style="margin-left: 10px;margin-top: 2px;cursor: pointer;">');
                        ld("#"+Popupobj.divid+" .dvpopupsroll").css("overflow-y","inherit");
                    }
                    else
                    {
                        ld("#"+Popupobj.divid+" [name=clear_text_ext0]").css("margin-top","2px");
                    }

                    if(comparator=='bw'||isExistsDateTimeStr(comparator)=="yes")
                    {
                        //日期时间字段
                        var values=value.split(',');
                        ld("#"+Popupobj.divid+" [name=fval0]").val(values[0]);
                        ld("#"+Popupobj.divid+" [name=fval_ext0]").val(values[1]);

                    }
                    else
                    {

                        ld("#"+Popupobj.divid+" [name=fval0]").val(value);
                    }

                }
            });


    }
	that.trimfValues = function(value) {
		var string_array;
		string_array = value.split(":");
		return string_array[4];
	}
   that.updatefOptions =function(sel, opSelName) {
		var selObj = document.getElementById(opSelName);
		var fieldtype = null ;

	 if(selObj==undefined ||selObj==null ||sel==undefined || sel==null)
	 {
		 return;
	 }
	  if(selObj.selectedIndex<0 ||sel.selectedIndex<0 )
	  {
		return ;
	  }
		var currOption = selObj.options[selObj.selectedIndex];
		var currField = sel.options[sel.selectedIndex];

		if(currField.value != null && currField.value.length != 0) {
			fieldtype = that.trimfValues(currField.value);
			ops = typeofdata[fieldtype];
			//alert(fieldtype);
			var off = 0;
			if(ops != null) {

				var nMaxVal = selObj.length;
				for(nLoop = 0; nLoop < nMaxVal; nLoop++) {
					selObj.remove(0);
				}
			   //by LD Can 20121130 none修改为无
				selObj.options[0] = new Option (jsnone, '');
				if (currField.value == '') {
					selObj.options[0].selected = true;
				}
				off = 1;
				var k=0;

				for (var i = 0; i < ops.length; i++) {
					var label = fLabels[ops[i]];

					if (label == null) continue;

					if(currField.value.indexOf('publicaccount:publicaccount:Accounts')>0||currField.value.indexOf('currency_id')>0)//客户模块中是否公海字段
					{
						 if(ops[i]!='e'&& ops[i]!='n')
						 {
							continue;
						 }
					}
					if(currField.value.indexOf('content:content:PublicAnnouncement')>0)//客户模块中是否公海字段
					{
						 if(ops[i]!='c')
						 {
							continue;
						 }
					}
					if(currField.value.indexOf("conversion_rate")>0)
					{

						 if(ops[i]=='isnull'|| ops[i]=='isnotnull')
						 {
							continue;
						 }
					}

					var option = new Option (fLabels[ops[i]], ops[i]);
					selObj.options[k + off] = option;
					k++;
					if (currOption != null && currOption.value == option.value) {
						option.selected = true;
					}
				}
				//36087: 单据列表界面>高级查找弹出层>选择时间字段：区间字段默认放在第二。（所有的帐套都要更改）
				 if(fieldtype=='D'||fieldtype=='DT')
			   {
					var resultobj=datetimestr;//eval('.popupobj.datatimestr.');
					// var option = new Option (arrJsPopLabel['Interval'], 'bw');
				//	 selObj.options[k + off] = option;
					// k++;
					ld.each(datetimestr,function(value,resultobj){


						   var option = new Option (resultobj[2], value);
							selObj.options[k + off] = option;
							 k++;
					} );

			   }
			}
		} else {
			if (currField.value == '') {
				selObj.options[0].selected = true;
			}
		}
	}
    that.setarr_basicsearchValue=function()
    {
        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
        var prevdivid=prevpopupobj.divid;
        var popupobj=CrmPopup.getPopupObj('last');
        var rowindex=popupobj.rowindex;
        var divid=popupobj.divid;
        var comparator=ld("#"+popupobj.divid+" [name=fop0]").val();//查询条件

        var comparatorlabel=ld("#"+popupobj.divid+" [name=fop0]").text();//查询条件

        var tmpsearchobj=that.arr_basicsearch[rowindex-1];
        var columnname=tmpsearchobj.columnname;
        var fieldinfo=that.column_fields[columnname];
        var typeofdata=fieldinfo.typeofData;
        var value=ld("#"+divid+" [name=fval0]").val();
        if(comparator=='bw'||isExistsDateTimeStr(comparator)=="yes")
        {
            var value1=ld("#"+divid+" [name=fval_ext0]").val();
            value=value+","+value1;
        }
        else
        {
        }
        //"columnname":triggerfieldcolumnname,'comparator':'',"value":'','basicsearchid':0
        var tdinfo=[];

        tdinfo['basicsearch']={"columnname":columnname,'comparator':comparator,"value":value,'basicsearchid':tmpsearchobj.basicsearchid};
       that.arr_basicsearch[rowindex-1]=tdinfo['basicsearch'];
       popupobj.CancelEvent();

        var trobj=ld("#"+prevdivid+' [rowindex='+rowindex+']');
        trobj.find("[name=basicsearchtd]").html(that.createbasicsearchtd(tdinfo,rowindex));//清空td内容

        that.setrowevent(rowindex);//重新绑定事件
        that.setTriggerColumnEnable();

    }
    that.setarr_basicsearchValue.funname="setarr_basicsearchValue";

    //其他条件查询弹出层
    //点击事件的对象（image(触发字段，其他条件，触发操作),编辑，删除）
    this.showadvancesearchpop=function(jqueryobj)
    {
         var popupobj=CrmPopup.getPopupObj('last');
         var frommodule=popupobj.module;
          var rowindex=ld(jqueryobj).attr('childrowindex');
         var tmpsearchobj=that.arr_basicsearch[rowindex-1];
          var triggercolumnname=tmpsearchobj.columnname;

          var advancesearch=that.arr_advancesearch[rowindex-1];
          //CrmPopup.load("","","","LdPopWidth600px",module,"",'none',"","");
           var Popupobj=CrmPopup.load("","","","LdPopWidth800px",frommodule,"","","","");
            Popupobj.prevshow();
            Popupobj.rowindex=rowindex;
            Popupobj.advanceSearchDivid=Popupobj.divid;
            var advancesearchstr=JSON.stringify(advancesearch);
            //zkt 20231013 XUQIU1001341 SQL注入
            var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockRuleAdvancePop&frommodule='+frommodule+"&triggercolumnname="+triggercolumnname+"&advancesearch="+encodeURIComponent(advancesearchstr);
            ldAjaxNoProgress(urlstring,'',function(data)
            {

                if(data.code==1)
                {

                    Popupobj.setParams(data.result.title,that.set_arradvancesearch,"","LdPopWidth800px",frommodule,"",data.result.oktext,"",data.result.canceltext);
                    Popupobj.setInnerHtml=function()
                    {
                        //jquery执行脚本
                        if(Popupobj.scrolldiv!="")
                        {
                            ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.scrolldiv+Popupobj.htmlcontent+"</div>"+Popupobj.popupbottomhtml);
                        }
                        else
                            ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.htmlcontent+Popupobj.popupbottomhtml);
                        document.getElementById(Popupobj.divid).style.display="block";
                    }
                    CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
                    //edit:can 20210127 044442: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），布局规则，新增布局规则设置其他条件为【组合条件】保存后，设置的其他条件显示的不是组合条件，变成了多个新条件
                    ld("#"+Popupobj.divid+" [name=addNewConditionGroup]").css("display",'none');

                    var advancefilterobj = new cls_advanceFilter();
                    var params = {};
                    that.advancefilterobj = advancefilterobj;
                    params.columnOptionHtml = data.result.FIELDNAMES;
                    params.fLabels = data.result.fLabels;
                    params.datetimestr = data.result.datetimestr;
                    params.advfilterhtml = data.result.advfilterhtml;
                    params.fieldsinfo = data.result.fieldinfo;
                    params.criteria_groups_arr = data.result.criteria_groups_arr;
                    params.module = frommodule;
                    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                    params.advanceFields = data.result.advanceFields;
                    advancefilterobj.showAdvanceFilter(Popupobj,params);


                }
            });
    }

    //设置其他条件的值
    that.set_arradvancesearch=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var rowindex=popupobj.rowindex;
         if(!that.advancefilterobj.checkAdvancedFilter()) return false;
		var advft_criteria = that.advancefilterobj.advft_criteria;//$('advft_criteria').value;
		var advft_criteria_groups = that.advancefilterobj.advft_criteria_groups;//$('advft_criteria_groups').value;
        if(!empty(advft_criteria)){
            that.arr_advancesearch[rowindex-1]=ld.parseJSON(advft_criteria);
        }else{
            that.arr_advancesearch[rowindex-1]='';
        }
       popupobj.CancelEvent();

    }
    that.set_arradvancesearch.funname="set_arradvancesearch";


    that.setarr_triggeroperateEmpty=function(rowindex)
    {
        var tmpobj={"columnname":'','type':'','basicsearchid':0};
        var tmps=[];
        tmps.push(tmpobj);
        if(that.arr_triggeroperate[rowindex-1]==undefined)
        {
            that.arr_triggeroperate.push(tmps);
        }
        else
            that.arr_triggeroperate[rowindex-1]=tmps;
    }
      //删除触发字段的条件
    this.deletetriggeroperate=function(jqueryobj)
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var rowindex=ld(jqueryobj).attr('childrowindex');
        var triggerfieldcolumnname=ld("#"+popupobj.divid+" [name=triggerfield]").val();//获取触发字段
        that.setarr_triggeroperateEmpty(rowindex);
        var trobj=ld("#"+popupobj.divid+' [rowindex='+rowindex+']');
        trobj.find("[name=triggeroperatetd]").html(that.addTriggerOperateTdImageHtml(rowindex));//清空td内容
        that.setrowevent(rowindex);
    }
    //触发操作弹出层
   //点击事件的对象（image(触发字段，其他条件，触发操作),编辑）
    this.showtriggeroperate=function(jqueryobj)
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.module;
          var rowindex=ld(jqueryobj).attr('childrowindex');
          var tmpsearchobj=that.arr_basicsearch[rowindex-1];
          var triggercolumnname=tmpsearchobj.columnname;
           var type=ld(jqueryobj).attr("type");

        that.arr_triggeroperate[rowindex-1][0].type=type;
         var triggeroperate=that.arr_triggeroperate[rowindex-1];//点击事件的对象（image(触发字段，其他条件，触发操作),编辑，删除

          var triggeroperatestr=JSON.stringify(triggeroperate);

           var Popupobj=CrmPopup.load("","","","LdPopWidth600px",frommodule,"","","","");
            Popupobj.prevshow();
            Popupobj.rowindex=rowindex;
            var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=LayoutRuleTriggerOperatePop&frommodule='+frommodule+"&triggercolumnname="+triggercolumnname+"&triggeroperate="+encodeURIComponent(triggeroperatestr)+"&type="+type;
        //zkt 20231013 XUQIU1001341 SQL注入
            ldAjaxNoProgress(urlstring,'',function(data)
            {

                if(data.code==1)
                {

                    //触发操作函数（显示字段，设置必填项）
                    Popupobj.setParams(data.result.title,that.setarr_triggeroperateValue,"","LdPopWidth600px",frommodule,"",data.result.oktext,"",data.result.canceltext);
                    CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);

                    ld("#"+Popupobj.divid+" .selectfields").select2({closeOnSelect: true,
                        dropdownParent:ld("#"+Popupobj.divid)});
                    ld("#"+Popupobj.divid+" .select2").css('width',"90%");


                }
            });



    }
    that.setarr_triggeroperateValue=function()
    {
        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
        var prevdivid=prevpopupobj.divid;
        var popupobj=CrmPopup.getPopupObj('last');
        var rowindex=popupobj.rowindex;

        var divid=popupobj.divid;
        var selectdatas=  ld("#"+divid+" .selectfields").select2('data');
       if(selectdatas.length<=0)
       {
         popupobj.CancelEvent();
        return ;
       }
        var tmpobj=[];
          ld.each(selectdatas,function(index,info){

            var columnname=info.id;
            var strobj={'columnname':columnname,'type':that.arr_triggeroperate[rowindex-1][0].type};

            tmpobj.push(strobj);
          })
          that.arr_triggeroperate[rowindex-1]=tmpobj;
          var info={};
          info['basicsearch']={};
          info['basicsearch']['basicsearchid']=that.arr_basicsearch[rowindex-1].basicsearchid;
          info['triggeroperate']=tmpobj;
          popupobj.CancelEvent();

        var trobj=ld("#"+prevdivid+' [rowindex='+rowindex+']');
        trobj.find("[name=triggeroperatetd]").html(that.createtriggeroperatetd(info,rowindex));

        that.setrowevent(rowindex);//重新绑定事件


    }
    that.setarr_triggeroperateValue.funname="setarr_triggeroperateValue";

    //设置触发字段下拉框是否可以点击
    that.setTriggerColumnEnable=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;

        ld.each(that.arr_basicsearch,function(index,info){

            if(ld.trim(info.comparator)!='')
            {
                ld("#"+divid+" .chzn-container").css("pointer-events",'none');
                return false;
            }
            else
            {

                ld("#"+divid+" .chzn-container").css("pointer-events",'inherit');
            }
        })
    }
    this.deleterule=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.frommodule;
        var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
       RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        //删除规则
        url='index.php?module=Settings&action=SettingsAjax&file=LayoutRuleDelete&frommodule='+frommodule;
        url+="&ruleid="+that.record;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,'',function(data)
        {

            if(data.code==1)
            {
                that.record=0;
                that.getList();
            }
            else
            {
                RemindsMsg("","LdPopWidth400px",frommodule,"yes","yes",data.msg);
            }

        });
      })
    }
    this.saverule=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var frommodule=popupobj.module;
        var divid=popupobj.divid;
        var name=ld("#"+divid+" [name=rulename]").val();
        var triggercolumnname=ld("#"+divid+" [name=triggerfield]").val();
        var tmpbasicsearchinfo=[];
        var tmpadvancesearchinfo=[];
        var tmptriggeroperate=[];

        ld.each(that.arr_basicsearch,function(index,basicinfo){

             if(ld.trim(basicinfo.comparator)!='')
             {
                var triggeroperateinfo=that.arr_triggeroperate[index];
                if(triggeroperateinfo.columnname!='')
                {
                    var advancesearchinfo=that.arr_advancesearch[index];
                    tmpbasicsearchinfo.push(basicinfo);
                    tmpadvancesearchinfo.push(advancesearchinfo);
                    tmptriggeroperate.push(triggeroperateinfo);

                }
             }
        })
        url='index.php?module=Settings&action=SettingsAjax&file=LayoutRuleSave&frommodule='+frommodule+"&triggercolumnname="+triggercolumnname+"&rulename="+encodeURIComponent(name);

        url+="&ruleid="+that.record;
        var tmpurl="&basicsearch="+encodeURIComponent(JSON.stringify(tmpbasicsearchinfo))+"&advancesearch="+encodeURIComponent(JSON.stringify(tmpadvancesearchinfo))+"&triggeroperate="+JSON.stringify(tmptriggeroperate);
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,tmpurl,function(data)
        {

            if(data.code==1)
            {
                popupobj.CancelEvent();
                that.getList();
            }
            else
            {
                RemindsMsg("","LdPopWidth400px",frommodule,"yes","yes",data.msg);
            }
        });
    }
    this.saverule.funname='saverule';

    //停用和启用
    this.setrulestatus=function(status){

         url='index.php?module=Settings&action=SettingsAjax&file=LayoutBlockRuleActivate&status='+status;
        url+="&ruleid="+that.record;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,'',function(data)
        {

            if(data.code==1)
            {
                that.record=0;
                that.getList();
            }
            else
            {
                RemindsMsg("","LdPopWidth400px",frommodule,"yes","yes",data.msg);
            }

        });
    }

}
cls_pagerule.getInstance=function(){
    if(cls_pagerule.pageruleobj==undefined){
        cls_pagerule.pageruleobj=new cls_pagerule();

    }
    return cls_pagerule.pageruleobj;
}

function cls_relateinfo()
{
    //相关信息
    var that=this;
     var popupobj=CrmPopup.getPopupObj('last');
     var frommodule=popupobj.frommodule;
    that.getList=function()
    {
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetRelatedlists&modulename='+frommodule+'&ajax=true&blockidsetting=&fieldidsetting=','',function(data)
        {
            if(data.code==1)
            {
                hidePageLayOutDiv();
                ld("#dv_relateinfo_content").html(data.result.content);

                /*edit:weiyannan
                date:2023-11-14
                reason:XUQIU1002049 系统穿梭框界面样式统一 后台设置--页面设置--相关信息*/
                var tableobj =  ld("#dv_relateinfo_content").find(".commonMultipleSelect").parents("table");
                var LeftObj = tableobj.find(".commonMultipleSelect:first");
                var RightObj = tableobj.find(".commonMultipleSelect:last");
                //传入翻译参数
                var Drag_Transfer = new DragTransfer();
                var translabel = {
                    available: arrJsPopLabel['OptionModules'],
                    selected: arrJsPopLabel['Selectedmodule'],
                    placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
                };
                Drag_Transfer.SetTranslabel(translabel);
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','300');
                ld("#dv_relateinfo").css("display",'');
            }
        });
    }
}
var quickcreatetip='';
function cls_quickcreate()
{
    //快速创建

     var that=this;
     var popupobj=CrmPopup.getPopupObj('last');
     var frommodule=popupobj.frommodule;
    that.getList=function()
    {
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=QuickCreateSetting&modulename='+frommodule+'&ajax=true&blockidsetting=&fieldidsetting=','',function(data)
        {

            if(data.code==1)
            {   hidePageLayOutDiv();
                ld("#dv_quickcreate_content").html(data.result.content);

                /*edit:weiyannan
                date:2023-11-14
                reason:XUQIU1002049 系统穿梭框界面样式统一 后台设置--页面设置--快速创建*/
                var tableobj =  ld("#dv_quickcreate_content").find(".commonMultipleSelect").parents("table");
                var LeftObj = tableobj.find(".commonMultipleSelect:first");
                var RightObj = tableobj.find(".commonMultipleSelect:last");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','300');
                ld("#dv_quickcreate").css("display",'');
                quickcreatetip=data.result.quickcreatetip;
            }
        });
    }

}

//地图视图
function cls_mapviewlist(){
	var that=this;
	var popupobj=CrmPopup.getPopupObj('last');
	var frommodule=popupobj.frommodule;
    that.getList=function(maptype)
    {
		//alert('index.php?module=Settings&action=SettingsAjax&file=MapView&modulename='+frommodule+'&ajax=true&blockidsetting=&fieldidsetting=&maptype='+maptype);
		//return false;
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=MapView&modulename='+frommodule+'&ajax=true&blockidsetting=&fieldidsetting=&maptype='+maptype,'',function(data)
        {

            if(data.code==1)
            {   hidePageLayOutDiv();
                ld("#dv_mapview_content").html(data.result.content);
                var tableobj =  ld("#dv_mapview_content").find(".commonMultipleSelect").parents("table");
                var LeftObj = tableobj.find(".commonMultipleSelect:first");
                var RightObj = tableobj.find(".commonMultipleSelect:last");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','300');
                ld("#dv_mapview").css("display",'');
                quickcreatetip=data.result.quickcreatetip;
            }
        });
    }
}
//地图视图 保存
function savemapfield()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    divid="dv_mapview_content";
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);
	if(selectedColumnsObj.options.length < 2){
		var msg = arrJsPopLabel['displaycolumnselectatleasttwo'];
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",msg);
		return false;
	}
    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
    var ColumnsObj=getObj("AssmablyList")
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
		ColStr += ColumnsObj.options[i].value + ";"
    }
    var url='module=Settings&frommodule='+popupobj.frommodule+"&action=SettingsAjax&file=SaveMapField&selectedAssmablyColumnsString="+selectedColStr;
    url+="&map_type="+CrmPopup.findHtmlobj(divid,'map_type').val()+"&frommodule="+CrmPopup.findHtmlobj(divid,'frommodule').val();
    //alert(url);
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?',url,function(response) {
        //cancelCrmPopup();
        // RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['SUCCESSFULLYSAVED']);
        MessagePopup.TipOne_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
    });
}
//快速创建设置保存
function savequickcreatefieldsetting()
{
    	var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    divid="dv_quickcreate_content";
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);

    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
	// CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);

    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    var ColumnsObj=getObj("AssmablyList")
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
		ColStr += ColumnsObj.options[i].value + ";"
    }
//	CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
    var url='module=Settings&frommodule='+popupobj.frommodule+"&action=SettingsAjax&file=SaveQuickCreateSetting&AssmablyColumnsString="+ColStr+"&selectedAssmablyColumnsString="+selectedColStr;
    url+="&duplicate="+CrmPopup.findHtmlobj(divid,'tab_quickcreate').val();

    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?',url,function(response) {
        MessagePopup.TipOne_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
    });
}

// ls 2022-03-10 【1002521】页面设置，增加【字段列表】标签
function cls_fieldlist()
{
    this.listid = 'dv_fieldlist';//div的id
    var that = this;
    that.record = 0;

    var popupobj = CrmPopup.getPopupObj('last');
    that.frommodule = popupobj.frommodule;

    this.getList = function () {

        var url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockFieldList&fromodule=' + that.frommodule;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                hidePageLayOutDiv();
                ld("#"+that.listid).css("display", '');
                ld("#"+that.listid).html(data.result.content);
                ld("#"+that.listid+" [name=fieldlist_search]").focus();
            }
            DelProgressObjs();
        });
    }

    this.saveFieldInfo = function (obj,sub_mode,fieldid) {
        var presence = ld(obj).is(':checked');//.prop('checked')

        var url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockFieldList&fromodule=' + that.frommodule+'&ajax=true&sub_mode='+sub_mode+'&fieldid='+fieldid+'&isPresent='+presence;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                // layoutblockEventClick();
                // ld("#"+that.listid+" [name=fieldlist_table]").html(data.result.content);
                // ld("#"+that.listid+" [name=fieldlist_search]").focus();

                //刷新字段布局列表页面
                that.refreshCfList();
            }
            DelProgressObjs();
        });
    }

    this.fieldlistsearch=function(event)
    {
        var e = event || window.event;
        if(e.keyCode == 13){// Enter 回车键
            // ld('#usertitleDiv ').find('input[name=searchuserbtn]').click();

            that.callFieldlistSearch();
        }
    }

    this.fieldlistViewText = function () {
        var search_text = ld("#"+that.listid+" [name=fieldlist_search]").val();
        if(!empty(search_text)){
            ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','block');
        }
        else{
            ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','none');
        }
    }

    this.fieldlistClearText = function () {
        ld("#"+that.listid+" [name=fieldlist_search]").val('');
        ld("#"+that.listid+" [name=fieldlist_search]").focus();
        ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','none');
        that.callFieldlistSearch();
    }

    this.callFieldlistSearch = function () {
        var searchtext = ld("#"+that.listid+" [name=fieldlist_search]").val().trim();
        var url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockFieldList&fromodule=' + that.frommodule + '&ajax=true&searchtext=' + searchtext;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                ld("#"+that.listid+" [name=fieldlist_table]").html(data.result.content);
                ld("#"+that.listid+" [name=fieldlist_search]").focus();
            }
            DelProgressObjs();
        });
    }

    //刷新字段布局页面
    this.refreshCfList = function () {
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress('index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&fld_module='+that.frommodule+'&ajax=true','',function(rest)
        {
            sethtml(document.getElementById('cfList'),rest);
            layoutblockEventClick();

        });

    }

}
//页面设置，增加【自定义字段操作日志列表】标签
function cls_cfoplog(){
    this.listid = 'dv_cfoperationlog';//div的id
    var that = this;
    that.record = 0;

    var popupobj = CrmPopup.getPopupObj('last');
    that.frommodule = popupobj.frommodule;

    this.getList = function () {

        var url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_CFOperationLog&frommodule=' + that.frommodule;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                hidePageLayOutDiv();
                ld("#"+that.listid).css("display", '');
                ld("#"+that.listid).html(data.result.content);
                ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").focus();
            }
            DelProgressObjs();
        });
    }
    //回车键搜索自定义字段
    this.customedfieldlistsearch=function(event)
    {
        var e = event || window.event;
        if(e.keyCode == 13){// Enter 回车键
            // ld('#usertitleDiv ').find('input[name=searchuserbtn]').click();

            that.CFOperationLOGSearch();
        }
    }

    this.fieldlistCfopLogViewText = function () {
        var search_text = ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").val();
        if(!empty(search_text)){
            ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','block');
        }
        else{
            ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','none');
        }
    }

    this.fieldlistCfopLogClearText = function () {
        ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").val('');
        ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").focus();
        ld("#"+that.listid+' .ld-search-bar .ld-icon-clearsearch').css('display','none');
        that.CFOperationLOGSearch();
    }

    //自定义字段搜索功能
    this.CFOperationLOGSearch = function () {
        var searchtext = ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").val().trim();
        var url = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList_CFOperationLog&frommodule=' + that.frommodule + '&ajax=true&searchtext=' + searchtext;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                ld("#"+that.listid+" [name=fieldlist_cfoplogtable]").html(data.result.content);
                ld("#"+that.listid+" [name=fieldlist_cfoplogsearch]").focus();
            }
            DelProgressObjs();
        });
    }
}
cls_fieldlist.getInstance=function(){
    if(cls_fieldlist.fieldlistobj==undefined){
        cls_fieldlist.fieldlistobj=new cls_fieldlist();

    }
    return cls_fieldlist.fieldlistobj;
}
cls_cfoplog.getInstance=function(){
    if(cls_cfoplog.cfoplogobj==undefined){
        cls_cfoplog.cfoplogobj=new cls_cfoplog();

    }
    return cls_cfoplog.cfoplogobj;
}

function hidePageLayOutDiv()
{
    ld("#cfList").css("display",'none');
    ld("#dv_pagerule").css("display",'none');
    ld("#dv_pagevalidata").css("display",'none');//验证规则
    ld("#dv_relateinfo").css("display",'none');
    ld("#dv_quickcreate").css("display",'none');
	ld("#dv_mapview").css("display",'none');
	//chj 2021/1/20 44367: （本地php72，8.3.7）客户-页面设置；先点击“进度跟踪”的页签，再点击“布局规则”页签；此时进度跟踪设置的菜单会带过来
	ld("#dv_advance").css("display",'none');
	ld("#dv_fieldlist").css("display",'none');
    ld("#dv_cfoperationlog").css("display",'none');
}
