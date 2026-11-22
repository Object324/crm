//多选单据弹出框
function MultiplePopup(){
    var that = this;
    this.choosemodule = '';
    this.frommodule = '';
    this.extra_url = '';
    this.common_url = '';
    this.width = CrmPopup.getSmallpopupwidth();
    this.popupobj = '';
    this.isshowModuleListTree = 'no'; //是否显示树结构
    this.saveChooseInfo = 'yes'; //是否支持跨页面多选
    this.selecttype = 'multiple';//多选单据类型 all全部,multiple多选,single单选,disable不允许选择(可能没什么用?)
    this.chooseentityid_arr = [];
    this.chooseentityname_arr = [];
    this.prevpopupobj = '';
    this.entityidlabel = '';
    this.entitynamelabel = '';

    this.setPopupobj = function (popupobj){
        this.popupobj = popupobj;
    }
    this.init = function (choosemodule,surl,frommodule){
        this.choosemodule = choosemodule;
        this.frommodule = frommodule;
        this.extra_url = surl;
    }
    this.setChooseEntityidArr = function (chooseentityidarr){
        this.chooseentityid_arr = chooseentityidarr;
    }
    this.setReturnField = function(prevpopupobj,entityidlabel,entitynamelabel){
        this.prevpopupobj = prevpopupobj;
        this.entityidlabel = entityidlabel;
        this.entitynamelabel = entitynamelabel;
    }
    //当前页面单据是否已被选中
    this.loadCheckbox = function (){
        if(this.chooseentityid_arr.length > 0){
            ld.each(this.chooseentityid_arr,function (index,value){
                if(ld('#'+that.popupobj.divid+' tr[id*=row_'+value+'] td input[type=checkbox][billinfo='+value+']').length > 0){
                    ld('#'+that.popupobj.divid+' tr[id*=row_'+value+'] td input[type=checkbox][billinfo='+value+']').prop('checked',true);
                    // ljj 20231107 BUG0075103 选择源单点击搜索等功能后，选中效果（底色）消失
                    ld('#'+that.popupobj.divid+' [record='+value+']').attr('class','lvtColDataSelected');
                }
            });
            //@edit:ljj,2023-07-26,reason:BUG0069939 kfbcrm-目标管理-新建指标-指标对象选择产品管理-勾选产品，右上角已选单据数量显示错误
            var array=[that.chooseentityid_arr.length];
            var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
            ld("#"+that.popupobj.divid+" [name=choosebilltotal_div]").html(confirm_str);
        }
    }
    this.showPopup=function(){

        var crmPopupobj=CrmPopup.load("","","",this.width,this.choosemodule,"",'none',"","");
        crmPopupobj.isShowFullscreen='yes';
        crmPopupobj.Fullscreencallback = function (switchtotype){
            if(crmPopupobj.listresizeobj != undefined){
                crmPopupobj.listresizeobj.setPopupResizeTable_Init(crmPopupobj.module);
            }
            var fullscreen_obj = ld("#" + crmPopupobj.divid + "_fullscreen");
            var windowHeight = CrmPopup.getClientHeight();
            //弹窗标题固定为50px
            var minusheight= ld('#'+crmPopupobj.divid+'_head').outerHeight(true);
            //查询分类/搜索框/查找按钮
            if(CrmPopup.isExistsObj(crmPopupobj.divid,'resize_popupsearch_tableid')){
                minusheight+=CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_popupsearch_tableid').height();
            }
            //确定按钮/分页信息
            var tableobj=CrmPopup.findHtmlobj(crmPopupobj.divid,'ListViewContents').find("table.small");
            var trobj =ld(tableobj).children('tbody').children('tr:not(:has(#hdScrolllistentries_yy))');//排除掉包含列表的tr
            if (trobj.length > 0) {
                trobj.each(function() {
                    minusheight += ld(this).height();
                });
            }
            //表格内边距为10
            minusheight+=10;
            //红字提醒
            if(CrmPopup.isExistsObj(crmPopupobj.divid,'redtip_limitcount')){
                minusheight+=CrmPopup.findHtmlobj(crmPopupobj.divid,'redtip_limitcount').height();
                minusheight+=10;//红字的上下外边距为10
            }
            if(switchtotype=="fullscreen"){//全屏
                var headerheight = CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_header_table_divid').height();
                if(CrmPopup.isExistsObj(crmPopupobj.divid,'hdScrolllistentries_yy')){
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'hdScrolllistentries_yy').css('height',windowHeight-minusheight);
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_content_table_divid').css("height",windowHeight-minusheight-headerheight);
                }else{
                    Tools.getParentobjByChild(ld('#producttable'),'div').css('height',windowHeight-minusheight);
                }
            }else{//缩小
                var preheight = parseInt(fullscreen_obj.attr('small-height'));
                if(preheight === null || preheight === undefined ){
                    preheight= windowHeight*0.8 ;
                }
                if(CrmPopup.isExistsObj(crmPopupobj.divid,'hdScrolllistentries_yy')){
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'hdScrolllistentries_yy').css('height',preheight-minusheight);
                    CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_content_table_divid').css("height",400);
                }else{
                    Tools.getParentobjByChild(ld('#producttable'),'div').css('height',preheight-minusheight);
                }
            }
            if (ld('#'+crmPopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+crmPopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'&&PopupModuleListTree!=undefined){
                PopupModuleListTree.setHeight();
                if(switchtotype!="fullscreen"){
                    crmPopupobj.center();
                }
            }
        }
        crmPopupobj.prevshow();

        crmPopupobj.type=selectDataPopup.type;
        crmPopupobj.advanceSearchDivid="dv_popup_listhighersearch"  ;
        this.setPopupobj(crmPopupobj);
        crmPopupobj.Multipleobj = this;
        // ljj 20231107 BUG0075102 销售订单-新建-采购询价单（多选）字段，勾选一个单据，并点击搜索，会出现勾选三个框
        crmPopupobj.isMultiple='yes';

        var urlstring = "index.php?action=Popup&popup=yes&page_popup=yes&html=Popup_picker&select=enable";
        urlstring += "&module="+this.choosemodule+"&selectmodule="+this.choosemodule+"&frommodule="+this.frommodule+"&returnmodule="+this.frommodule;
        urlstring += "&popuptype=MultiplePopup";

        var popup_url = '';
        popup_url += 'isshowModuleListTree='+this.isshowModuleListTree;
        popup_url += this.extra_url;

        //BUG20240112-70 ls 20240115 自定义表单36，多选订单字段“正常订单/费用货补”没有受 ld_relatecreatecondition 控制
        var requestvaluearr = getPageValueByCrmPopupFields(CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype));
        popup_url += "&requestvalues="+requestvaluearr['requestvalue'];

        var selectmodule = this.choosemodule;
        getJsScript('include/js/SystemPopup/CrmPopupWindows.js',function(){})

        ldAjax(urlstring,popup_url,function(data){
            if(data.code==1)
            {
                if(data.result.fieldname!=undefined)
                {
                    crmPopupobj.fieldname=data.result.fieldname;
                }
                else
                {
                    crmPopupobj.fieldname='';
                }
                crmPopupobj.fields=JSON.parse(data.result.fields);//字段信息
                crmPopupobj.advancefieldnames=data.result.advancefieldnames;//高级查询
                crmPopupobj.advft_criteria='';
                crmPopupobj.selectmodule=selectmodule;
                crmPopupobj.chooseproductid_arr=[];//edit:can 20220711 选择的产品ID
                crmPopupobj.chooseSourceInfo_arr=[];//选择原单
                crmPopupobj.url=urlstring.replace("popup=yes",'popup=no');
                crmPopupobj.extral_url = that.extra_url;
                //36711: （1.6）合同订单明细界面>关联创建出库单>将联系人或者客户字段擦除：擦除时会将源单也清除掉，编辑历史的出库单也有该问题，直接新增出库是正常的
                getJsScript('include/js/FieldDependencies.js',function(){
                    crmPopupobj.setParams(data.result.title,'',"",this.width,selectmodule,"","","","");
                    crmPopupobj.curr_row=data.result.curr_row;//选择的当前行（合同订单产品明细）
                    crmPopupobj.contentdivid=crmPopupobj.divid+"_content";
                    crmPopupobj.setInnerHtml=function(){
                        if(crmPopupobj.scrolldiv!="")
                        {

                            document.getElementById(crmPopupobj.divid).html(crmPopupobj.popupheadhtml+crmPopupobj.scrolldiv+"<div id='"+crmPopupobj.contentdivid+"'>"+crmPopupobj.htmlcontent+"</div></div>"+this.popupbottomhtml);
                        }
                        //else  if(module=="PriceBooks"&&selectmodule=="Products")
                        else
                            ld("#"+crmPopupobj.divid).html(crmPopupobj.popupheadhtml+"<div id='"+crmPopupobj.contentdivid+"'>"+crmPopupobj.htmlcontent+"</div>"+crmPopupobj.popupbottomhtml);
                    };

                    // crmPopupobj.show(data.result.content);
                    crmPopupobj.show(data.result.content);
                    //zkt 20221010 BUG0057125在费用报销单，单据分录中，点击‘源单’之后的加号，进入搜索界面，光标应该停留在搜索框（查找内容）里面。涉及合同订单里的选择源单后的框，合同订单里的团队成员
                    if(ld("#"+crmPopupobj.divid+" [name=search_text]").length>0){
                        ld("#"+crmPopupobj.divid+" [name=search_text]").focus();
                    }
                    crmPopupobj.popuptype = 'MultiplePopup';

                    ListView_Page.fullwidth_divid = 'hdScrolllistentries_yy';
                    ListView_Page.header_table_divid='resize_header_table_divid';//列头table所在div的id
                    ListView_Page.header_tableid='resize_header_tableid';//列头所在table的id

                    ListView_Page.content_tableid="resize_content_tableid";//内容所在table的id
                    ListView_Page.content_table_divid="resize_content_table_divid";//内容table所在div的id
                    var listresizeobj=new List_ResizeTable(crmPopupobj);
                    crmPopupobj.listresizeobj=listresizeobj;
                    listresizeobj.setPopupResizeTable_Init(selectmodule);
                    //默认全屏的话，需要先将非全屏状态的界面加载完毕，否则记录的small-height错误
                    if(data.result.fullscreen=='yes'){
                        crmPopupobj.switchFullscreen();
                    }

                    crmPopupobj.center();
                    that.showPopupAfter();

                    var array=[that.chooseentityid_arr.length];
                    var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
                    ld("#"+that.popupobj.divid+" [name=choosebilltotal_div]").html(confirm_str);


                    crmPopupobj.getSearch=function (){
                        fun_setCrmPopupWindow.callSearch('Basic');
                    };


                });
            }else{
                cancelCrmPopup();
                ld('#rptContentLoading').hide();
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }
        })
    }
    //弹出层显示后触发事件
    this.showPopupAfter = function(){
        //记录选中的单据id以及顺序
        var popupobj = that.popupobj;
        if(this.saveChooseInfo == 'yes'){
            this.setCheckBoxEvent();
        }
        //重新设置选择单据的点击事件
        if(this.selecttype == 'all' || this.selecttype == 'multiple'){
            ld("#"+popupobj.divid+" #MultiplePopupSelect").show().unbind('click').bind("click",function(){
                that.MultiplePopupSelectRecord();
            })
        }
        that.loadCheckbox();
    }
    //设置单选框选中事件
    this.setCheckBoxEvent = function(){
        var popupobj = that.popupobj;
        ld("#"+popupobj.divid+" [name=selected_id]").unbind('click').bind("click",function(){
            that.setChooseInfo_arr(ld(this))
        })
        ld("#"+popupobj.divid+" [name=selected_all]").unbind('click').bind("click",function(){
            ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
                that.setChooseInfo_arr(ld(this))
            })
        })
        ld("#"+popupobj.divid+" [name=select_all]").unbind('click').bind("click",function(){
            ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
                that.setChooseInfo_arr(ld(this))
            })
        })
    }
    //记录选中的单据id
    this.setChooseInfo_arr = function(chkboxobj){
        var popupobj = this.popupobj;
        var billinfo = ld(chkboxobj).attr("billinfo")
        var entityname = ld("#"+popupobj.divid+" [name=linkfield][bill_info="+billinfo+"]").text();
        if(ld(chkboxobj).prop("checked"))
        {
            if(!that.chooseentityid_arr.includes(billinfo)){
                that.chooseentityid_arr.push(billinfo);
                that.chooseentityname_arr.push(entityname);
            }
        }
        else{
            ld.each(that.chooseentityid_arr,function(tmpindex,tmpproductid){
                if(tmpproductid==billinfo)
                {
                    that.chooseentityid_arr.splice(tmpindex,1);
                    that.chooseentityname_arr.splice(tmpindex,1);
                    return false;
                }
            })
        }
        //@edit:ljj,2023-07-26,reason:BUG0069939 kfbcrm-目标管理-新建指标-指标对象选择产品管理-勾选产品，右上角已选单据数量显示错误 
        var array=[that.chooseentityid_arr.length];
        var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
        ld("#"+that.popupobj.divid+" [name=choosebilltotal_div]").html(confirm_str);
    }

    //单选单据
    this.ChooseSingleRecord = function (obj){
        var entityid = ld(obj).attr('bill_info');
        var entityname = ld(obj).text();
        this.chooseentityid_arr = new Array(entityid);
        this.chooseentityname_arr = new Array(entityname);

        that.popupobj.CancelEvent();
        that.ClickAfterReturn()
    }

    //多选单据
    this.MultiplePopupSelectRecord = function (){
        var popupobj = that.popupobj;
        if(this.saveChooseInfo == 'yes'){
        }else{
            that.chooseentityid_arr = [];
            ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function (){
                var billinfo = ld(this).attr("billinfo");
                // var entityname = ld("#"+popupobj.divid+" [name=linkfield][bill_info="+billinfo+"]").text();
                if(ld(this).prop("checked"))
                {
                    if(!that.chooseentityid_arr.includes(billinfo)){
                        that.chooseentityid_arr.push(billinfo);
                        //that.chooseentityname_arr.push(entityname);
                    }
                }
            })
        }
        if(that.chooseentityid_arr.length > 0){
            var url = 'index.php?module='+that.choosemodule+'&action='+that.choosemodule+'Ajax&file=lingdangAble&mode=getlinkfieldlabel&selectmodule='+that.choosemodule+'&chooseentityid='+that.chooseentityid_arr;
            ldAjaxNoProgress(url,'',function (data){
                if(data.code == 1){
                    if(!empty(data.result.chooseentityname)){
                        that.chooseentityname_arr = data.result.chooseentityname.split(',');
                        that.popupobj.CancelEvent();
                        that.ClickAfterReturn()
                    }
                }
            });
        }else{
            that.popupobj.CancelEvent();
            that.ClickAfterReturn()
        }
        //ld("#rptContentLoading").hide();

    }
    //单据选择后回调函数
    this.ClickAfterReturn = function (){
        ld("#"+that.prevpopupobj.divid+" [name='"+that.entityidlabel+"']").val(that.chooseentityid_arr.join(','));
        ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").html(that.chooseentityname_arr.join(','));
        ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").val(that.chooseentityname_arr.join(','));
        ld("#"+that.prevpopupobj.divid+" [name='"+that.entitynamelabel+"']").attr('title',that.chooseentityname_arr.join(','));

        //BUG20240112-62 ls 20240112 自定义表单20  关联选择单据多选  无法触发sql 查询
        ld("#"+that.prevpopupobj.divid+" [name='"+that.entityidlabel+"']").change();
    }
}
