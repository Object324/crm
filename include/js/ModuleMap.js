//模块图谱
function ModuleMap()
{
    var that = this;
    
    this.frommodule = '';//
    this.module = '';//图谱内容对应的模块
    this.fromrecordid = 0;//
    this.relatedid = 0;
    
    this.modulemaphtml = '';
    this.maxmapnodeid = 0;
    
    this.showeditmap = 'no';//是否为编辑界面
    this.showfullscreenmap = 'no';//是否为全屏显示界面
    this.popupobj = '';
    this.mapdata_arr = [];
    this.modulemapfieldinfo = [];
    this.moduledatainfo = [];
    
    this.searchvalue = '';
    this.editmap_tagsave_refreshdata = 'no';
    
    
    this.setmoduleinfobyobj = function(obj){
        this.module = ld(obj).data('module');
        this.fromrecordid = ld(obj).data('fromrecordid');
        this.relatedid = ld(obj).data('relatedid');
        this.frommodule = ld(obj).data('frommodule');
    }

    this.resize = function (showtype = ''){
        that.showtype = showtype;
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        if (showtype == 'view'){//相关信息查看界面
            var width= divobj.width()-30;
            divobj.find('#contactsmap_div').css('width',width);

            var height = CrmPopup.getClientHeight();
            height -= divobj.find('#'+popupobj.divid+'_head').outerHeight(true);//头部
            height -= divobj.find('[name=relatelisttab]').outerHeight(true);//相关信息
            var keyFieldHeight = divobj.find('#related_keywords_field').outerHeight(true);
            if (keyFieldHeight > 0){
                keyFieldHeight += 10;//关键信息底部的padding
                height -= keyFieldHeight;//关键信息栏
            }
            height -= divobj.find('#listmap_button').outerHeight(true);//放大缩小按钮
            height -= 20;//弹窗中间部分padding
            divobj.find('#map_view_div').css('max-height',height);
            if (divobj.find('#contactsmap_div').length > 0){
                divobj.find('.DivCTable').css('overflow','hidden');
            }
        }else {//全屏和编辑界面
            that.popupobj.proportion = 1;
            var height = that.popupobj.getPopContentHeight();
            //图谱
            var list_width = divobj.find('#edit_list_view_div').width();
            divobj.find('#edit_map_view_div').css('width',CrmPopup.getClientWidth()-list_width-5);
            divobj.find('#edit_map_view_div').css('max-height',height);
        }
    }

    this.showmap = function(popupobj,mapdata){
        that.popupobj = popupobj;
        that.popupobj.modulemapobj = that;
        that.modulemapfieldinfo = mapdata.modulemapfieldinfo;
        that.moduledatainfo = mapdata.moduledatainfo;
        that.moduledataindex_arr = mapdata.moduledataindex_arr;
        that.hreffieldcolumnname = mapdata.hreffieldcolumnname;
        
        that.mapdata_arr = mapdata.mapdata_arr;
        
        //@edit:ljj,2023-07-28,reason:XUQIU1001536 单据查看详情界面，相关信息联系人列表的“联系人图谱”修改为相关信息“联系人图谱”模块
        if(that.module=='ContactsMap') {
            that.module = 'Contacts';
        }
        //加载点击显示视图
        if(that.modulemaphtml == ''){
            that.getMaxmapnodeid();
        }
        //编辑界面联系人列表相关处理
        if(that.showeditmap == 'yes'||that.showfullscreenmap == 'yes'){
            that.initdatalistulHtml();
        }
        that.initnodewrapHtml();
    }
    this.editshow = function(){
        this.showeditmap = 'yes';
        that.editmap_tagsave_refreshdata = 'yes';
        var frommodule = that.frommodule;
        var module = that.module;
        var fromrecordid = that.fromrecordid;
        var relatedid = that.relatedid;
        var crmPopupobj=CrmPopup.load("","","","gwidth100",module,"","","","");
    	crmPopupobj.prevshow();
        //编辑模块图谱
        var url = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&frommodule="+frommodule+"&fromrecordid="+fromrecordid+"&relatedid="+relatedid+"&mode=edit";
        ld.ajax({
            url: url,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code == 1){
                    
                    crmPopupobj.setParams(data.result.title,that.SaveMapDateinfo,that.CancelMoudleMapPop,"gwidth100",module,"",data.result.oktext,"",data.result.canceltext,"");
        			crmPopupobj.getMaxHeight=function(){
        			     var maxheight=CrmPopup.getClientHeight()-ld("#"+this.divid+'_head').outerHeight()-ld("#"+this.divid+"_popupbottom").outerHeight();
                        this.maxheight=maxheight;
                        return this.maxheight;
        			};
                    crmPopupobj.createHeadHtml=function()
                    {
                        this.popupheadhtml='<div class="E_pop_tit" id="'+this.divid+'_head" style="cursor:move">';
                        this.popupheadhtml+='<strong class="E_ptita">'+this.headtitle+'</strong>';
                        this.popupheadhtml+='<button class="E_ptitc" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'" id="'+this.divid+'_imgclose"/></button>';
                        if(data.result.isadmin == 'on'){
                            this.popupheadhtml += '<a href="javascript:;" id="module_map_fieldset" style="float: right;">' + arrJsPopLabel['SETMAPDISPLAYFIED'] + '</a>';
                        }
                        this.popupheadhtml+='</div>';
         		    }
                    CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
                    crmPopupobj.frommodule = frommodule;
                    crmPopupobj.type = 'editmodulemappage';
                    var height = crmPopupobj.getMaxHeight();
                    ld("#"+crmPopupobj.divid).find("#edit_listmap_div").height(height);
                    crmPopupobj.center();
                    //设置图谱显示字段,对应点击事件
                    ld("#"+crmPopupobj.divid).find("#module_map_fieldset").on('click',function(){
                        that.setMapdisplayfield();
                    })
                    //编辑界面滚动条
                    ld("#"+crmPopupobj.divid+" .dvpopupsroll").css('overflow','visiable');
                    ld("#"+crmPopupobj.divid+" .dvpopupsroll").css('overflow-y','hidden');

                    that.popupobj = crmPopupobj;
                    var editdivobj = ld("#"+crmPopupobj.divid).find("#edit_listmap_div");
                    that.showmap(crmPopupobj,data.result);
                    that.addtagclick();
                    //20231211 BUG0077019 保存标签后直接点击x关闭编辑弹窗，相关信息图谱需要刷新
                    ld("#"+crmPopupobj.divid+" #"+crmPopupobj.divid+"_imgclose").bind('click',function () {
                        that.editmap_tagsave_refreshdata = 'no';
                        //刷新相关信息界面联系人图谱
                        var popupobj = CrmPopup.getlastPopupObjByType('relatelistpage');
                        if(!empty(popupobj)){
                            var listmodulemapobj = popupobj.modulemapobj;
                            var mapdata = {'modulemapfieldinfo':that.modulemapfieldinfo,'moduledatainfo':that.moduledatainfo,
                                'moduledataindex_arr':that.moduledataindex_arr,'hreffieldcolumnname':that.hreffieldcolumnname,
                                'mapdata_arr':that.mapdata_arr}
                            listmodulemapobj.showmap(popupobj,mapdata);
                            that.CancelMoudleMapPop();
                        }
                    });

                    that.resize();
                }
            }
        });
    }

    // ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    //给div框绑定事件：点击标签框刷新右边标签数据
    this.addtagclick = function (){
        var popupobj=CrmPopup.getPopupObj('last');
        ld("#"+popupobj.divid).find(" input[name=tagsave]").unbind('click').bind('click',function(){
            that.maptagsave();
        });
        ld("#"+popupobj.divid).find(" #modulemap_edittag").unbind('click').bind('click',function(){
            // that.maptagclose();
            ld("#"+popupobj.divid+" #edit_tag_div").css('display','none');
            var editmapdivwidth=ld("#"+popupobj.divid+" #edit_map_view_div").width();
            ld("#"+popupobj.divid+" #edit_map_view_div").css('width',editmapdivwidth+300+'px');
            ld("#"+popupobj.divid+" #edit_map_view_drag").css('right',20+'px');
        });
        ld("#"+popupobj.divid).find("div[name=content]").each(function () {
            var contact_record=ld(this).attr('contactrecord');
            if (contact_record != '' && contact_record != undefined){
                ld(this).find('div[name=tag]').unbind('click').bind('click',function (){
                    that.addtag(this,'Contacts',contact_record);
                });
                ld(this).find('div[name=tagprediv]').unbind('click').bind('click',function (){
                    that.addtag(this,'Contacts',contact_record);
                });
            }
            else {
                var tmp=ld(this).find('span[name=tobeadd]').parents('[tag=nodebox]');
                ld(tmp).unbind('click').bind('click',function (){
                    ld("#"+popupobj.divid+" #edit_map_view_div").find('[tag=nodebox]').each(function (){
                        ld(this).removeClass('hovered');
                    });
                    // ld(tmp).addClass('hovered');
                    that.closetag(popupobj);
                });
            }
        });
    }
    //图谱右侧关闭
    this.closetag=function (obj){
        var display=ld("#"+obj.divid+" #edit_tag_div").css('display');
        if (display!='none'){
            var editmapdivwidth=ld("#"+obj.divid+" #edit_map_view_div").width();
            ld("#"+obj.divid+" #edit_map_view_div").css('width',editmapdivwidth+300+'px');
            ld("#"+obj.divid+" #edit_map_view_drag").css('right',20+'px');
            ld("#"+obj.divid+" #edit_tag_div").css('display','none');
        }
        ld("#"+obj.divid+" #edit_tag_table").find('span[name=tagger_span]').empty();
        ld("#"+obj.divid+" #edit_tag_table").find('input[name=moduledata_record]').attr('value','');
        ld("#"+obj.divid+" #edit_tag_table").find('input[name=input_tagger]').attr('value','');
        ld("#"+obj.divid+" #edit_tag_table").find('input[name=input_tagger]').attr('tag_id','');
        ld("#"+obj.divid+" #edit_tag_table").find('input[name=input_tagger]').attr('tag_type','');
    }
    // ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    //联系人图谱编辑页面新增标签
    this.addtag = function (obj,module,record){
        var tagobj = ld(obj).parent().find('[name=tag]');
        if (tagobj.length == 0){
            return false;
        }
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=moduledata_tag&record='+record+'&ismodulemapedit=true';
        var popupobj=CrmPopup.getPopupObj("last");
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld("#"+popupobj.divid+" #edit_map_view_div").find('[tag=nodebox]').each(function (){
                    ld(this).removeClass('hovered');
                });
                ld(obj).parents('[tag=nodebox]').addClass('hovered');
                
                var display=ld("#"+popupobj.divid+" #edit_tag_div").css('display');
                if (display=='none'){
                    var editmapdivwidth=ld("#"+popupobj.divid+" #edit_map_view_div").width();
                    ld("#"+popupobj.divid+" #edit_map_view_div").css('width',editmapdivwidth-300+'px');
                    ld("#"+popupobj.divid+" #edit_map_view_drag").css('right',320+'px');
                    ld("#"+popupobj.divid+" #edit_tag_div").css('display','');
                }
                ld("#"+popupobj.divid+" #edit_tag_table").html(data.result.content);
                moduledata_tag.allmodulelabel = data.result.allmodulelabel;
                tagger_class({el:'#input_tagger'});
            }
            DelProgressObjs();
        });
    }
    // ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    //联系人图谱编辑右侧 标签部分保存
    this.maptagsave=function (){
        var popupobj=CrmPopup.getPopupObj("last");
        var new_moduledata_tag = ld("#"+popupobj.divid+" [name=new_moduledata_tag]").val();
        var selected_moduledata_tag = ld("#"+popupobj.divid+" [name=input_tagger]").attr('tag_id');
        var module = ld("#"+popupobj.divid+" [name=moduledata_module]").val();
        var record = ld("#"+popupobj.divid+" [name=moduledata_record]").val();
        var corp_tag = 'personal';
        //企业标签
        if(ld("#"+popupobj.divid+" [name=corp_tag]") != undefined && ld("#"+popupobj.divid+" [name=corp_tag]").is(':checked') == true){
            corp_tag = 'company';
        }
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&ajax=true&file=moduledata_tag&save=true&ismodulemapedit=true';
        urlstring += '&record='+record+'&new_moduledata_tag='+encodeURIComponent(new_moduledata_tag)+"&selected_moduledata_tag="+encodeURIComponent(selected_moduledata_tag)+"&corp_tag="+corp_tag;
        //alert(urlstring);return false;
        ldAjax(urlstring,"",function(data){
            if(data.code==1){
                DelProgressObjs();
                var moduledata_tag_content = data.result.tag;
                var moduledata_tag_type = data.result.tag_type;
                var moduledata_tag_id=data.result.tag_id;
                moduledata_tag.refreshdetail(record,moduledata_tag_content,moduledata_tag_type);
                var tmparra=new Array();
                tmparra.push(popupobj.record);
                //edit:can 54573:合同订单，标签添加到单据详情界面之后，打开单据详情，再添加标签，回到单据详情界面的标签栏不会更新，需要刷新才行
                var tmpobj= new AfterUpdatePrevPopupObjContent(module,data,tmparra);
                tmpobj.eachrefreshlistbyModules(new Array(module));
                that.refreshmodulemaptag(record,moduledata_tag_content,moduledata_tag_type,moduledata_tag_id);
                that.refreshdatalist();
                ld("#"+popupobj.divid+" span[name=module_list_tagger_span_"+record+"]").click();
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","",data.result.msg);
                return false;
            }
        });
    }
    // ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    //刷新联系人图谱编辑内右侧标签部分
    this.refreshmodulemaptag = function(record,moduledata_tag,moduledata_tag_type,moduledata_tag_id){
        var popupobj=CrmPopup.getPopupObj("last");
        var tagspan=ld("#"+popupobj.divid+" [name=module_list_tagger_span_"+record+"]");
        var tagobj =ld("#"+popupobj.divid+" [contactrecord="+record+"]").find('div[name=tag]');
        tagobj.find('[tag=no]').remove();
        if (tagspan.length > 0) {
            ld("#" + popupobj.divid + " [name=module_list_tagger_span_" + record + "]").find('span').each(function () {
                ld(this).remove();
            });
            if (!empty(moduledata_tag)) {
                var moduledata_tag_array = moduledata_tag.split(',');
                var moduledata_tag_id_array = moduledata_tag_id.split(',');
                var maptagger_obj = ld("#" + popupobj.divid + " [name=module_list_tagger_span_" + record + "]");
                var moduledata_tag_type_array=moduledata_tag_type.split(',');
                ld.each(moduledata_tag_array, function (ikey, tag) {
                    if(moduledata_tag_type_array[ikey] == 'personal'){
                        var tag_li_html = '<span class="module-map-tagger-fm-button '+moduledata_tag_type_array[ikey]+'" tag_id="' + moduledata_tag_id_array[ikey] + '">' + tag + '</span>';
                    }
                    else {
                        var tag_li_html = '<span class="module-map-tagger-fm-button '+moduledata_tag_type_array[ikey]+'" tag_id="' + moduledata_tag_id_array[ikey] + '">' + tag + '</span>';
                    }
                    maptagger_obj.append(tag_li_html);
                });
            }
        }
        else {
            var span='<span class="module_list_tagger_span" name="module_list_tagger_span_'+record+'" style="flex-wrap: wrap">';
            var tagspan = ld("#" + popupobj.divid + " [name=content]").parent().find('div [record='+record+']');
            tagobj.append(span);
            if (!empty(moduledata_tag)) {
                var moduledata_tag_array = moduledata_tag.split(',');
                var moduledata_tag_id_array = moduledata_tag_id.split(',');
                var moduledata_tag_type_array=moduledata_tag_type.split(',');
                var maptagger_obj = ld("#" + popupobj.divid + " [name=module_list_tagger_span_" + record + "]");
                ld.each(moduledata_tag_array, function (ikey, tag) {
                    if(moduledata_tag_type_array[ikey] == 'personal'){
                        var tag_li_html = '<span class="module-map-tagger-fm-button '+moduledata_tag_type_array[ikey]+'" tag_id="' + moduledata_tag_id_array[ikey] + '">' + tag + '</span>';
                    }
                    else {
                        var tag_li_html = '<span class="module-map-tagger-fm-button '+moduledata_tag_type_array[ikey]+'" tag_id="' + moduledata_tag_id_array[ikey] + '">' + tag + '</span>';
                    }
                    maptagger_obj.append(tag_li_html);
                });
            }
        }
        var span_obj = ld("#" + popupobj.divid + " [name=module_list_tagger_span_" + record + "]").find('span');
        if (span_obj.length == 0 && tagobj.find('[tag=no]').length == 0){
            tagobj.find('[tag=label]').after('<span tag="no">'+arrJsPopLabel['NONE']+'</span>');
        }
    }

    this.SaveMapDateinfo = function(){
        var mapdata_arr = that.mapdata_arr;
        var module = that.module;
        var frommodule = that.frommodule;
        var fromrecordid = that.fromrecordid;
        var relatedid = that.relatedid;
        var urlstring = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&frommodule="+frommodule+"&fromrecordid="+fromrecordid+"&relatedid="+relatedid+"&mapdataarr="+JSON.stringify(mapdata_arr)+"&mode=save";
        ldAjax(urlstring,"",function(data){
            if(data.code == 1){
                DelProgressObjs();
                that.popupobj.CancelEvent();
                that.editmap_tagsave_refreshdata = 'no';
                //刷新相关信息界面联系人图谱
                var popupobj = CrmPopup.getlastPopupObjByType('relatelistpage');
                if(!empty(popupobj)){
                    var listmodulemapobj = popupobj.modulemapobj;
                    var mapdata = {'modulemapfieldinfo':that.modulemapfieldinfo,'moduledatainfo':that.moduledatainfo,
                                'moduledataindex_arr':that.moduledataindex_arr,'hreffieldcolumnname':that.hreffieldcolumnname,
                                'mapdata_arr':that.mapdata_arr}
                    listmodulemapobj.showmap(popupobj,mapdata);
                    that.resize('view');
                }
                updateMapLock(popupobj,data.result.lockstate);
            }else {//被锁提示
                MessagePopup.TipOne_warning(data.msg);
            }
            
        });
    }
    /**
     * editor:ljj
     * time:20231229
     * reason:XUQIU1002228
     * content:联系人图谱增加锁定功能
     * node:编辑界面取消事件 获取该图谱lockstate(锁值)更新锁和编辑按钮的情况
     **/
    this.CancelMoudleMapPop= function (){
        var popupobj=CrmPopup.getPopupObj('last');
        var module = that.module;
        var frommodule = that.frommodule;
        var fromrecordid = that.fromrecordid;
        var urlstring = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&mode=getlockstate&frommodule="+frommodule+"&fromrecordid="+fromrecordid;
        ldAjaxNoProgress(urlstring,'',function (data){
            if (data.code == 1){
                //wym 240206 BUG20240202-19 客户-相关信息栏-联系人 点击联系人图谱编辑按钮，点击取消，再点高级查找，选择字段为空(详情页取消事件自带关闭窗口,不需要再关闭一层)
                var crmpopupobj=CrmPopup.getPopupObj('last');
                var lockstate=data.result.lockstate;
                updateMapLock(crmpopupobj,lockstate);//更新锁和编辑按钮的情况
            }
        });
    }
    
    this.getMaxmapnodeid = function(){
        for(var i=0;i<that.mapdata_arr.length;i++)
        {
            if(parseInt(that.mapdata_arr[i].nodeid)>this.maxmapnodeid)
            {
                this.maxmapnodeid=parseInt(that.mapdata_arr[i].nodeid);
            }
        }
    }
    this.showFullScreenMap = function(mapdata){
        this.showfullscreenmap = 'yes';
        var frommodule = that.frommodule;
        var module = that.module;
        var fromrecordid = that.fromrecordid;
        var relatedid = that.relatedid;
        var crmPopupobj=CrmPopup.load("","","","gwidth100",module,"","","","");
    	crmPopupobj.prevshow();
        //编辑模块图谱
        var url = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&frommodule="+frommodule+"&fromrecordid="+fromrecordid+"&relatedid="+relatedid+"&mode=fullscreen";
        ld.ajax({
            url: url,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code == 1){
                    // ljj 2023-08-21 BUG0071013 联系人图谱-点击页面的全屏按钮，进入的页面是无法编辑的，底下的保存跟取消按钮也没必要显示
                    crmPopupobj.setParams(data.result.title,that.SaveMapDateinfo,that.CancelMoudleMapPop,"gwidth100",module,"","","","","");
        			// crmPopupobj.getMaxHeight=function(){
        			//      var maxheight=CrmPopup.getClientHeight()-ld("#"+this.divid+'_head').outerHeight()-ld("#"+this.divid+"_popupbottom").outerHeight();
                    //     this.maxheight=maxheight;
                    //     return this.maxheight;
        			// };
                    
                    crmPopupobj.show(data.result.content);
                    crmPopupobj.frommodule = frommodule;
                    var height = crmPopupobj.getMaxHeight();
                    ld("#"+crmPopupobj.divid).find("#edit_listmap_div").height(height);
                    crmPopupobj.center();
                    that.popupobj = crmPopupobj;
                    that.showmap(crmPopupobj,mapdata);
                }
            }
        });
    }
    this.zoom=function(zoomtype){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        //放大缩小，恢复
        var scale=10;
        var zoomvalue=ld("#"+divid+" #map_zoom_value").html().substr(0,ld("#"+divid+" #map_zoom_value").html().length-1);
        if(zoomtype=='restore')
        {
            zoomvalue = 100;
        }
        else if(zoomtype=='out')
        {
            if(parseInt(zoomvalue)<=50)
            {
                return ;
            }
            zoomvalue=parseInt(zoomvalue)-scale;
        }
        else{
            if(parseInt(zoomvalue)>=300)
            {
                return ;
            }
            zoomvalue=parseInt(zoomvalue)+scale;
        }
        scale=parseFloat((zoomvalue/100)).toFixed(1);
        ld("#"+divid+" #map_zoom_value").html(zoomvalue+"%");
        ld("#"+divid+" #modulemapview").get(0).style.transform="scale("+scale+")";	
    }
    
    //绑定拖动
    this.drag = false;
    this.translateX = 0;
    this.translateX = 0;
    this.setdragEvent = function(){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        var nodewrapobj = ld("#"+popupobj.divid).find("[id=node_wrap_div]");
        ld(nodewrapobj).bind('mousedown').on('mousedown',function(event){
            if(ld("#"+popupobj.divid+" #map_drag").data('status')!='chosed'){
                return;
            }
            that.drag = true;
            if(empty(this.style.transform)){
                this.style.transform="translate(0px)";
            }
            var translates=document.defaultView.getComputedStyle(this,null).transform;
            //清除最后一个),便于后续取值
            translates = translates.replace(")","");
            //分割成数组
            var translatearr = translates.split(',');
            var len = translatearr.length;
            var translateX = Number(translatearr[len-2]);
            var translateY = Number(translatearr[len-1]);
            that.translateX = event.clientX-translateX;
            that.translateY = event.clientY-translateY;
            
        })
        ld(nodewrapobj).bind('mousemove').on('mousemove',function(event){
            if(that.drag != true){
                return false;
            }
            var translateX = event.clientX-that.translateX;
            var translateY = event.clientY-that.translateY;
            this.style.transform="translate("+translateX+"px,"+translateY+"px)";
            
        })
        ld(nodewrapobj).bind('mouseup').on('mouseup',function(event){
            that.drag = false;
        })
        
    }
    this.setEvent =function(){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        ld("#"+popupobj.divid).find("[id=search_mapdatalist]").unbind("keydown").bind("keydown",function(){
            //搜索
            that.search(this);
        })
        ld("#"+popupobj.divid).find("[id=map_show_fullScreen]").unbind("click").bind("click",function(){
            //全屏显示
            var modulemapobj = new ModuleMap();
            modulemapobj.module = that.module;
            modulemapobj.fromrecordid = that.fromrecordid;
            modulemapobj.relatedid = that.relatedid;
            modulemapobj.frommodule = that.frommodule;
            var mapdata = {'modulemapfieldinfo':that.modulemapfieldinfo,'moduledatainfo':that.moduledatainfo,
                            'moduledataindex_arr':that.moduledataindex_arr,'hreffieldcolumnname':that.hreffieldcolumnname,
                            'mapdata_arr':that.mapdata_arr};
            modulemapobj.showFullScreenMap(mapdata);
            
        })
        ld("#"+popupobj.divid).find("[id^=btu_zoom_]").unbind("click").bind("click",function(){
            
            //放大缩小，恢复
            var zoomtype = ld(this).data('type');
            that.zoom(zoomtype)
        })
        //绑定拖动
        this.setdragEvent();
        ld("#"+popupobj.divid+" #map_drag").unbind("click").bind("click",function(){
            //拖动
            var chosestatus = ld(this).data('status');
            var nodewrapobj = ld("#"+popupobj.divid).find("[id=node_wrap_div]");
            if(chosestatus == 'nochose'){
                ld(this).data('status','chosed');
                ld(this).attr('title',arrJsPopLabel['LOCKMAP']);
                ld(this).css('background-color','#00aaef');
                ld(nodewrapobj).css('cursor','pointer');
            }
            else{
                ld(this).data('status','nochose');
                ld(this).attr('title',arrJsPopLabel['DRAGMAP']);
                ld(this).css('background-color','');
                ld(nodewrapobj).css('cursor','');
            }
            
        })
        if(that.showeditmap=='yes'){
            this.setEditEvent();
        }
    }
    this.setEditEvent =function(){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        //给每个节点绑定hover事件，控制侧边按钮的显示
        ld("#"+popupobj.divid).find("[id^=node_box_]").hover(function(){
            ld(this).find("b").css("display","none");
            var parentnodeid = ld(this).data('parentnodeid');
            var nodeid = ld(this).data('nodeid');
            var nodeindex = that.getMapnodeIndex(nodeid);
            var nodeinfo = that.mapdata_arr[nodeindex];
            if(parentnodeid == 0){
                ld(this).find("#addtop_"+nodeid).css("display","");
            }
            ld(this).find("#addbottom_"+nodeid).css("display","");
            
            if(nodeinfo.parentnodeid!=0){
                ld(this).find("#addright_"+nodeid).css("display","");
            }
            
            if(nodeinfo.childrennodeid == ''&&nodeinfo.parentnodeid!=0){
                if(that.mapdata_arr.length>2){
                    ld(this).find("#deletebox_"+nodeid).css("display","");
                }
            }
            ld(this).find("#operation_"+nodeid).css("opacity","1");
            ld(this).find("#operation_"+nodeid).css("visibility","initial");

            var tipobj = ld(this).find('[name=tip]');
            if(tipobj.length > 0){
                var nodeid = ld(this).data('nodeid');
                ld(this).find('#deletebox_'+nodeid).css('display','none');
            }

        },function(){
            var parentnodeid = ld(this).data('parentnodeid');
            var nodeid = ld(this).data('nodeid');
            ld(this).find("#operation_"+nodeid).css("opacity","0");
            ld(this).find("#operation_"+nodeid).css("visibility","hidden");
        })
        
        //给每个操作按钮绑定对应的点击事件
        ld("#"+popupobj.divid).find("[id^='operation_']").find("b").unbind('click').on('click',function(){
            
            var operationdivobj = Tools.getParentobjByChild(this,'div');
            var contentobj = Tools.getParentobjByChild(operationdivobj,'div');//联系人图谱界面优化operation外添加了一层div name=content
            var nodeobj = Tools.getParentobjByChild(contentobj,'div');
            var operationtype = ld(this).data('type');
            if(operationtype=='addtop'){
                //上箭头，增加父节点
                that.addnode(nodeobj,'addtop');
            }
            else if(operationtype=='addbottom'){
                //下箭头，增加子节点
                that.addnode(nodeobj,'addbottom');
            }
            else if(operationtype=='addleft'){
                //左箭头，增加同级节点，暂时需求未要求
                //that.addnode(nodeobj,'addleft');
            }
            else if(operationtype == 'addright'){
                //右箭头，增加同级节点
                that.addnode(nodeobj,'addright');
            }
            else if(operationtype == 'deletebox'){
                //X，删除当前节点
                that.deletenode(nodeobj,'deletebox');
            }
            
        })
        
        //给每个节点清除内容按钮绑定对应的点击事件
        ld("#"+popupobj.divid).find("[id^='deleteinfo_']").find('img').unbind('click').on('click',function(){
            var deleteinfoobj = Tools.getParentobjByChild(this,'div');
            var nodeid = ld(deleteinfoobj).data('nodeid');
            var nodeindex = that.getMapnodeIndex(nodeid);
            //修改对应关系
            that.mapdata_arr[nodeindex].moduleindexid = 0;
            that.initdatalistulHtml();
            //清除html
            var contentdivobj = Tools.getParentobjByChild(deleteinfoobj,'div');
            ld(contentdivobj).html('<span name="tobeadd" style="line-height: 26px;font-size: 13px;">'+arrJsPopLabel['TOBEADD']+'</span>');
            ld(contentdivobj).prev().empty();
            that.addtagclick();// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
            that.closetag(popupobj);
        })
        
        //拖入div绑定，拖动事件；
        ld.each(ld("#"+divid+" #node_wrap_div").find("[id^='node_box_']"),function(index,obj){
            
            Sortable.create(ld(this).get(0), {
                //zkt 20230330 设置未不可向外拖拽pull:false  BUG0063486  “联系人图谱”，编辑时，直接将图谱中第一个区块的内容拖动到另第二个区块，第一个区块无法再添加新的内容，点击保存，刚刚编辑的内容没有保存 
                group:{name: 'node',pull:false},
        		animation: 150,
                sort:false,
                dropOnEmpty: true,
                onChoose: function (/**Event*/evt) {
                    //console.log(evt);
                },
                 // 拖拽元素改变位置的时候
                onChange: function(/**Event*/evt) {
                    ld(evt.to).find('li').css('display','none');
                },
                // 拖拽元素改变位置的时候
                onRemove: function(/**Event*/evt) {
                    //console.log(evt);
                },
                // 结束拖拽
                onEnd: function (/**Event*/evt) {
                    //尝试实现节点间拖拽
                    /*var toobj = ld(evt.to);
                    var fromobj = ld(evt.from);
                    if(ld(fromobj).attr('id').indexOf('node_box_')>=0){
                        var fromnodeid = ld(fromobj).data('nodeid');
                        var fromnodeindex = that.getMapnodeIndex(fromnodeid);
                        var frommoduleindexid = that.mapdata_arr[fromnodeindex].moduleindexid;
                        var tonodeid = ld(toobj).data('nodeid');
                        var tonodeindex = that.getMapnodeIndex(tonodeid);
                        var tomoduleindexid = that.mapdata_arr[tonodeindex].moduleindexid;
                        that.addnodeInfo(fromobj,tomoduleindexid);
                        that.addnodeInfo(toobj,frommoduleindexid);
                    }
                    that.initdatalistulHtml();*/
                }
        	});
        })
        
    }
    //nodeobj当前操作的节点对象
    //增加节点
    this.addnode=function(nodeobj,operation){
        var nodeid = ld(nodeobj).data('nodeid');
        var parentnodeid = ld(nodeobj).data('parentnodeid');
        var operationnodeindex = this.getMapnodeIndex(nodeid);
        var nodeindex = operationnodeindex;
        if(operation == 'addright'){
            var nodeindex = this.getMapnodeIndex(parentnodeid);
            nodeid = that.mapdata_arr[nodeindex].nodeid;
            parentnodeid = that.mapdata_arr[nodeindex].parentnodeid;
        }
        
        var newnodeid = this.maxmapnodeid+1;
        var newnode_parentnodeid = 0;
        var newnode_childrennodeid = '';
        
        if(operation == 'addtop'){
            newnode_parentnodeid = 0;
            newnode_childrennodeid = ''+nodeid+'';
            //增加上级节点时，修改被操作节点的parentnodeid
            that.mapdata_arr[nodeindex].parentnodeid = newnodeid;
        }
        else{
            newnode_parentnodeid = nodeid;
            newnode_childrennodeid = '';
            if(operation == 'addbottom'){
                //增加下级时，修改被操作节点的childrennodeid
                var children_arr = that.mapdata_arr[nodeindex].childrennodeid.split(",");
                children_arr.push(newnodeid);
                that.mapdata_arr[nodeindex].childrennodeid=children_arr.join(",");
            }
            else if(operation == 'addleft'){
                //增加同级时，修改操作节点上级节点的childrennodeid
                var operationnodeid = ld(nodeobj).data('nodeid');
                var children_arr = that.mapdata_arr[nodeindex].childrennodeid.split(",");
                
                var childoperationnodeindex = children_arr.indexOf(operationnodeid);
                if(childoperationnodeindex == 0){
                    children_arr.unshift(newnodeid);
                }
                else{
                    children_arr.splice(childoperationnodeindex-1,0,newnodeid);
                }
                that.mapdata_arr[nodeindex].childrennodeid=children_arr.join(",");
            }
            else if(operation == 'addright'){
                //增加同级时，修改操作节点上级节点的childrennodeid
                var operationnodeid = ld(nodeobj).data('nodeid');
                var children_arr = that.mapdata_arr[nodeindex].childrennodeid.split(",");
                var childoperationnodeindex = children_arr.indexOf(operationnodeid);
                children_arr.splice(childoperationnodeindex+1,0,newnodeid);
                that.mapdata_arr[nodeindex].childrennodeid=children_arr.join(",");
            }
            
        }
        var newnodeinfo = {'nodeid':newnodeid,'moduleindexid':'0','parentnodeid':newnode_parentnodeid,'childrennodeid':newnode_childrennodeid}
        
        if(operation == 'addleft'){
            if(operationnodeindex == 0){
                that.mapdata_arr.unshift(newnodeid);
            }
            else{
                that.mapdata_arr.splice(operationnodeindex-1,0,newnodeinfo);
            }
        }
        else if(operation == 'addright'){
            that.mapdata_arr.splice(operationnodeindex+1,0,newnodeinfo);
        }
        else{
            that.mapdata_arr.push(newnodeinfo);
        }
        
        this.maxmapnodeid++;
        //重新加载html
        this.initnodewrapHtml();
        this.addtagclick();// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    }
    
    //删除当前节点
    this.deletenode=function(nodeobj,operation){
        var nodeid = ld(nodeobj).data('nodeid');
        var parentnodeid = ld(nodeobj).data('parentnodeid');
        
        var nodeindex = this.getMapnodeIndex(nodeid);
        
        var parentnodeindex = this.getMapnodeIndex(parentnodeid);
        
        var moduleindexid = that.mapdata_arr[nodeindex].moduleindexid;
        var parentchildren_arr = that.mapdata_arr[parentnodeindex].childrennodeid.split(',');
        var operationnodeindex = parentchildren_arr.indexOf(nodeid);//当前节点在上级节点的childrennodeid中对应数组中的index
        parentchildren_arr.splice(operationnodeindex,1);
        
        that.mapdata_arr[parentnodeindex].childrennodeid = parentchildren_arr.join(",");
        
        that.mapdata_arr.splice(nodeindex,1);
        //重新加载html
        if(moduleindexid>0){
            this.initdatalistulHtml();
        }
        this.initnodewrapHtml();
        this.addtagclick();// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
    }
    
    //获取指定节点索引
    this.getMapnodeIndex=function(nodeid)
    {    
        var nodeindex='';
         ld.each(that.mapdata_arr,function(tmpindex,tmpinfo){
            if(tmpinfo.nodeid==nodeid)
            {
                nodeindex=tmpindex
                return false;
            }
        })
        return nodeindex;
    }
    
    //根据图谱节点id生成菜单列表html
    //id：图谱节点id
    //arry：菜单数组信息
    this.i=0;
    this.GetData=function(nodeid, arry){
         if(nodeid==undefined||parseInt(nodeid)<0)
         return ;
        var childArry = this.GetParentArry(nodeid, arry);
      
        var len=childArry.length;;
        if (len> 0) {
            if(nodeid !=0){
                this.modulemaphtml += '<div class="branch-box-wrap">'+
                    '<div class="branch-box">';
            }
            for (var i=0;i<len;i++) {
                 this.modulemaphtml += '<div id="colbox" class="col-box">';
                this.modulemaphtml += this.nodehtml(nodeid,childArry,i);
                this.GetData(childArry[i].nodeid, arry);
                this.modulemaphtml += '</div>';
            }
            if(nodeid != 0 ){
                this.modulemaphtml += '</div></div>';
            }
        }
    }
    //根据parentnodeid获取下级节点
    //parentnodeid：图谱节点parentnodeid
    //arry：节点数组信息
    this.GetParentArry=function(parentnodeid, arry) {
        var newArry=[];
       var len=arry.length;
        for (var i=0;i<len;i++) {
            if (parseInt(arry[i].parentnodeid) == parseInt(parentnodeid)){
                newArry.push(arry[i]);
            }
                
        }
        return newArry;
    }
    
    this.nodehtml=function(parentnodeid,childArry,index){
        var html='';
        var nodeinfo = childArry[index];
        //html = '<div class="condition-node-box">';
        if(index == 0 && nodeinfo.parentnodeid !=0){
            //下级节点中最左边节点添加，不显示左边横线
            html += '<div class="top-left-cover-line"></div>';
        }
        else{
            html += '';//<div class=""></div>
        }
        html +='<div class="condition-node-box">';
       
        var nodeid = nodeinfo.nodeid;
        if(nodeinfo.parentnodeid == 0){
            html +='<div data-nodeid="'+nodeid+'" data-parentnodeid="'+parentnodeid+'" id="node_box_'+nodeid+'" tag="nodebox" class="node-wrap-box node-wrap-box-first">';
        }
        else{
            html +='<div class="line"></div>';//有上级节点显示线
            html +='<div data-nodeid="'+nodeid+'" data-parentnodeid="'+parentnodeid+'" id="node_box_'+nodeid+'" tag="nodebox" class="node-wrap-box">';
        }
        var content = '<span name="tobeadd" style="line-height: 26px;font-size: 13px;">'+arrJsPopLabel['TOBEADD']+'</span>';
        if(parseInt(nodeinfo.moduleindexid)>0&&(that.moduledataindex_arr.indexOf(parseInt(nodeinfo.moduleindexid))>=0||that.moduledataindex_arr.indexOf(nodeinfo.moduleindexid)>=0))
        {
            content = this.getshowContent(nodeinfo.moduleindexid,nodeid);
        }

        html += '<div class="node-box-item" name="content" contactrecord="' + nodeinfo.moduleindexid + '">';
        html += '<div class="title" name="title">' + this.getshowTitle(nodeinfo.moduleindexid, nodeid) + '</div>' +
            '<div class="content" name="maincontent" id="content_' + nodeid + '" >' + content + '</div>';
        html += '<div class="operation" name="operation" id="operation_' + nodeid + '">' +
            '<b data-type="addtop" id="addtop_' + nodeid + '" class="operation-items addtop"></b>' +
            '<b data-type="addbottom" id="addbottom_' + nodeid + '" class="operation-items addbottom"></b>' +
            '<b data-type="addleft" id="addleft_' + nodeid + '" class="operation-items addleft"></b>' +
            '<b data-type="addright" id="addright_' + nodeid + '" class="operation-items addright"></b>' +
            '<b data-type="deletebox" id="deletebox_' + nodeid + '" class="operation-items deletebox"></b>' +
            '</div>';
        html += '</div>';
        html += '</div>';
         
        if(nodeinfo.childrennodeid != ''){
            //有下级节点显示线
            html += '<div class="line"></div>';
        }
        html += '</div>';      
        
        if(index == childArry.length-1&& nodeinfo.parentnodeid !=0){
            //下级节点中最右边节点添加，不显示右边横线
            html += '<div class="top-right-cover-line"></div>';
        }
        else{
            html += '';//<div class=""></div>
        }
        return html;
    }
    
    this.getshowTitle=function(moduleindexid,nodeid)
    {
        var modulemapfieldinfo = that.modulemapfieldinfo;
        var moduledatainfo = that.moduledatainfo;
        var contenthtml = '';
        if(!empty(moduledatainfo[moduleindexid])){
            var len = modulemapfieldinfo.length;
            for(var i=0;i<len;i++)
            {
                var columnname = modulemapfieldinfo[i]['columnname'];
                var fieldname = modulemapfieldinfo[i]['fieldname'];
                var fieldlabel = modulemapfieldinfo[i]['fieldlabel'];
                var columnvalue = moduledatainfo[moduleindexid][columnname];
                if(empty(columnvalue)){
                    columnvalue = '';
                }
                if(columnname == that.hreffieldcolumnname){
                    contenthtml = '<a class="ld_list_href_name tip-items-list" style="overflow: hidden;text-overflow: ellipsis;" name="contactsname" lasturl="" fieldname="'+fieldname+'" module="'+that.module+'" record="'+moduleindexid+'"'
                            + 'href="index.php?pageto_module='+that.module+'&pageto_action=index&pageto_record='+moduleindexid+'" onclick="ListLinkClick(ld(this),event)" data-tip="'+columnvalue+'" data-direction="top" data-type="position">'+columnvalue+'</a>';
                    break;
                }
            }
        }
        return contenthtml;
    }

    this.getshowContent=function(moduleindexid,nodeid)
    {
        var modulemapfieldinfo = that.modulemapfieldinfo;
        var moduledatainfo = that.moduledatainfo;
        var contenthtml = '';
        if(!empty(moduledatainfo[moduleindexid])){
            if (moduledatainfo[moduleindexid].permitted_msg != ''){
                contenthtml = '<div name="tip" >'+moduledatainfo[moduleindexid].permitted_msg+'</div>';
                return contenthtml;
            }
            var len = modulemapfieldinfo.length;
            for(var i=0;i<len;i++)
            {
                var columnname = modulemapfieldinfo[i]['columnname'];
                var fieldname = modulemapfieldinfo[i]['fieldname'];
                var fieldlabel = modulemapfieldinfo[i]['fieldlabel'];
                var columnvalue = moduledatainfo[moduleindexid][columnname];
                //ljj 20240605 XUQIU20240306-01 联系人图谱中显示的字段增加显示颜色，根据字段属性中的颜色或字段下拉选项颜色显示（史星磊）
                var style = moduledatainfo[moduleindexid][columnname+'_style'];
                var spanstyle = '<span>';
                if(!empty(style)){
                    spanstyle = '<span style="'+style+'">';
                }

                var showvalue = spanstyle+fieldlabel+':&ensp;'+columnvalue+'</span>';
                if(columnname == that.hreffieldcolumnname){
                    // showvalue = '<a style="line-height: 26px;color: #1771eb;font-size: 13px;">'+columnvalue+'</a>';
                    // showvalue = '<a class="ld_list_href_name tip-items-list" name="contactsname" lasturl="" fieldname="'+fieldname+'" module="'+that.module+'" record="'+moduleindexid+'"'
                    //         + 'href="index.php?pageto_module='+that.module+'&pageto_action=index&pageto_record='+moduleindexid+'" onclick="ListLinkClick(ld(this),event)" data-tip="'+columnvalue+'" data-direction="top" data-type="position" style="line-height: 26px;color: #1771eb;font-size: 13px;">'+columnvalue+'</a>';
                }
                if(columnname == 'tag'){
                    var divhtml = '<div name="tag" style="overflow: hidden "><span style="float: left;padding-right: 5px;" tag="label">'+fieldlabel+':</span>'+columnvalue+'</div>';
                }// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
                else if (columnname == that.hreffieldcolumnname){
                    // var divhtml = '<div >'+showvalue+'</div>';
                    var divhtml = '';
                }
                else {
                    var divhtml = '<div name="tagprediv" >'+showvalue+'</div>';
                }
                contenthtml += divhtml;
            }
            if(this.showeditmap == 'yes'){
                contenthtml += '<div class="deleteinfo" data-nodeid="'+nodeid+'" id="deleteinfo_'+nodeid+'"><img src="themes/softed/images/close_2023.png"></div>';
            }
        }
        return contenthtml;
    }
    //刷新编辑界面列表，需要到后台重新获取
    this.refreshdatalist=function(){
        var module = that.module;
        var frommodule = that.frommodule;
        var fromrecordid = that.fromrecordid;
        var relatedid = that.relatedid;
        var urlstring = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&frommodule="+frommodule+"&fromrecordid="+fromrecordid+"&relatedid="+relatedid+"&mode=refreshlist";
        ldAjaxNoProgress(urlstring,{},function(data){
            
            that.moduledatainfo = data.result.moduledatainfo;
            that.moduledataindex_arr = data.result.moduledataindex_arr;
            if(that.showeditmap == 'yes'||that.showfullscreenmap == 'yes'){
                that.initdatalistulHtml();
            }
            if (that.editmap_tagsave_refreshdata =='no'){
                that.initnodewrapHtml();
            }
            DelProgressObjs();
            that.addtagclick();// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
        })
    }
    //加载图谱节点
    this.initnodewrapHtml=function(){
        that.modulemaphtml = '';
        that.GetData(0,that.mapdata_arr);
        
        var wrapobj = ld("#"+this.popupobj.divid).find("#node_wrap_div");
        ld(wrapobj).html(that.modulemaphtml);
        that.setEvent();
    }
    //加载编辑界面列表
    this.initdatalistulHtml=function(){
        var listobj = ld("#"+this.popupobj.divid).find("#data_list_div");
        var chosedindexidarr = this.getChosedindexidarr();
        var moduledatainfo = that.moduledatainfo;
        var showcolmn = that.hreffieldcolumnname;
        var modulemapfieldinfo = that.modulemapfieldinfo;
        var len = modulemapfieldinfo.length;
        var showfieldname = showcolmn;
        for(var i=0;i<len;i++)
        {
            var columnname = modulemapfieldinfo[i]['columnname'];
            if(columnname == showcolmn){
                showfieldname = modulemapfieldinfo[i]['fieldname'];
                break ;
            }
        }
        var nochosehtml = '';
        var chosedhtml = '';
        var moudledataindex_arr = that.moduledataindex_arr;
        var searchvlaue = that.searchvalue;
        
        for(var i=0;i<moudledataindex_arr.length;i++)
        {
            var moduleindexid = moudledataindex_arr[i];
            var datainfo = moduledatainfo[moduleindexid];
            var columnvalue = datainfo[showcolmn];
            if(!empty(searchvlaue)){
                getScriptBackWithURL('include/js/multipingyin.js',null);//加载拼音代码
                var selT = columnvalue.indexOf(searchvlaue);
				var pinyin = makePy(columnvalue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
				pinyin=pinyin.join("").toLowerCase();
				var selP = pinyin.indexOf(searchvlaue);
                if(selT <0 && selP <0){
                    continue;
                }
            }
            
            var showhtml = columnvalue;
            showhtml = '<a class="ld_list_href_name tip-items-list" lasturl="" fieldname="'+showfieldname+'" module="'+that.module+'" record="'+moduleindexid+'"'
                            + 'href="index.php?pageto_module='+that.module+'&pageto_action=index&pageto_record='+moduleindexid+'" onclick="ListLinkClick(ld(this),event)" data-tip="'+columnvalue+'" data-direction="top" data-type="position" >'+columnvalue+'</a>';
            if(chosedindexidarr.indexOf(parseInt(moduleindexid))<0 && (datainfo.permitted_msg != undefined && datainfo.permitted_msg == '')){
                //没有被选择
                nochosehtml += '<li class="drag-handle"  style="background-color: #FFFFFF;height:48px;box-sizing:border-box;padding:15px 8px;border:1px solid #dee1e8;border-radius:2px;margin-bottom:10px;cursor:move;overflow:hidden;text-overflow: ellipsis;" data-moduleindexid="'+moduleindexid+'">'+showhtml+'</li>'
            }
            else{
                chosedhtml += '<li class="drag-handle" style="background-color: #FFFFFF;height:48px;box-sizing:border-box;padding:15px 8px;border:1px solid #dee1e8;border-radius:2px;margin-bottom:10px;overflow:hidden;background-color: #f0f0f0;text-overflow: ellipsis;" data-moduleindexid="'+moduleindexid+'">'+showhtml+'</li>'
            }
        }
        html = '';
        if(!empty(nochosehtml)){
            html += '<ul id="data_list_ul" style="padding:0 16px;">'+nochosehtml+'</ul>';
        }
        if(!empty(chosedhtml)){
            html += '<ul style="padding:0 16px;">'+chosedhtml+'</ul>';
        }
        ld(listobj).html(html);
        if(!empty(nochosehtml)){
            this.setlistDropEvent();
        }
        
    }
    this.setlistDropEvent = function(){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        Sortable.create(ld("#"+divid+" #data_list_ul").get(0), {
            group: {name: 'node',pull:'clone',put:false},
    		animation: 150,
            sort:false,
            draggable:".drag-handle",
            onChoose: function (/**Event*/evt) {
                evt.oldIndex;  // element index within parent
            },
             // 开始拖拽的时候
            onStart: function (/**Event*/evt) {
                evt.oldIndex;  // element index within parent
            },
            onChange: function (/**Event*/evt) {
                
                evt.oldIndex;  // element index within parent
            },
            // 结束拖拽
            onEnd: function (/**Event*/evt) {
                if (that.showfullscreenmap == 'yes'){
                    return false;
                }
                var toobj = ld(evt.to);
                if (toobj.find('[name=tip]').length>0){//不能替换无权限的联系人和树节点
                    return false;
                }
                var fromobj = ld(evt.from);
                var liobj = ld(evt.item);
                var moduleindexid = ld(liobj).data('moduleindexid');
                var mapdatainfo = that.moduledatainfo[moduleindexid];
                if (mapdatainfo.permitted_msg != undefined && mapdatainfo.permitted_msg != ''){//无权限的联系人不能拖动到节点
                    return false;
                }
                if(ld(toobj).attr('tag')=='nodebox'){
                    //添加节点
                    that.addnodeInfo(toobj,moduleindexid);
                    ld(evt.to).find('li').remove();
                }
                that.initdatalistulHtml();
                that.addtagclick();
                var content=ld(evt.to).find('div [name=maincontent]');
                that.addtag(content,'Contacts',moduleindexid);
            },
    	});
        document.body.ondrop = function (event) {
             event.preventDefault();
             event.stopPropagation();
        };
        
    }
    
    //添加节点信息
    this.addnodeInfo = function(nodeobj,moduleindexid){
        var nodeid = ld(nodeobj).data('nodeid');
        var nodeindex = that.getMapnodeIndex(nodeid);
        if(moduleindexid>0){
            //修改mapdata_arr数据
            that.mapdata_arr[nodeindex].moduleindexid = moduleindexid;
            //节点界面显示
            ld(nodeobj).find('[name=content]').attr('contactrecord',moduleindexid);
            var content = that.getshowContent(moduleindexid,nodeid);
            ld(nodeobj).find('.content').html(content);
            var title=that.getshowTitle(moduleindexid,nodeid);
            ld(nodeobj).find('[name=title]').html(title);
            ld(nodeobj).unbind('click');
            //zkt 20221104 BUG0058352客户（客户名称：111111111111111）相关信息->联系人列表，联系人图谱编辑界面，节点框中已添加的联系人点击×按钮点不动
            ld("#"+that.popupobj.divid).find("[id='deleteinfo_"+nodeid+"']").find('img').unbind('click').on('click',function(){
                var deleteinfoobj = Tools.getParentobjByChild(this,'div');
                var nodeid = ld(deleteinfoobj).data('nodeid');
                var nodeindex = that.getMapnodeIndex(nodeid);
                //修改对应关系
                that.mapdata_arr[nodeindex].moduleindexid = 0;
                that.initdatalistulHtml();
                //清除html
                var contentdivobj = Tools.getParentobjByChild(deleteinfoobj,'div');
                ld(contentdivobj).html('<span name="tobeadd" style="line-height: 26px;font-size: 13px;">'+arrJsPopLabel['TOBEADD']+'</span>');
                ld(contentdivobj).prev().empty();
                that.addtagclick();// ljj 20230907 XUQIU1000834 联系人图谱相关功能优化--可在联系人图谱中直接添加和打标签
            })
        }
        else{
            //修改对应关系
            that.mapdata_arr[nodeindex].moduleindexid = 0;
            //清除html
            ld(nodeobj).find('.content').html('<span name="tobeadd" style="line-height: 26px;font-size: 13px;">'+arrJsPopLabel['TOBEADD']+'</span>');
        }
        
        
    }
    
    this.getChosedindexidarr = function(){
        var mapdata = that.mapdata_arr;
        var len = mapdata.length;
        var chosedindexid_arr = [];
        for(var i=0;i<len;i++){
            
            if(parseInt(mapdata[i].moduleindexid)>0)
            {           
                chosedindexid_arr.push(parseInt(mapdata[i].moduleindexid));
            }
        }
        return chosedindexid_arr;
    }
    
    
    this.setMapdisplayfield = function(){
        var frommodule = that.frommodule;
        var module = that.module;
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px popMarginPadding",'Settings',"","","","");
	    crmPopupobj.prevshow();
        var urlstring='index.php?module='+module+'&action='+module+'Ajax&file=editModuleMapfield&frommodule='+frommodule+'&mode=edit';
        ldAjaxNoProgress(urlstring,{},function(data){
            if(data.code == 1){
                crmPopupobj.setParams(data.result.title,that.saveMapdisplayfield,'',"LdPopWidth800px popMarginPadding",module,"",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.frommodule = frommodule; 
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
                standardFilterDisplay();
                var tableobj = ld('#'+crmPopupobj.divid).find("table#ModuleMapfieldTable");
				var LeftObj = tableobj.find("#AssmablyList");
				var RightObj = tableobj.find("#selectedAssmablyColumns");
				var Drag_Transfer = new DragTransfer();
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','300');
				crmPopupobj.center();
            }
             
        })
    }
    this.saveMapdisplayfield = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var module = popupobj.module
        var frommodule = popupobj.frommodule;
        var selObj=CrmPopup.findHtmlobj(popupobj.divid,'selectedAssmablyColumns');
        
        var mapfields= "";
        if(selObj.find("option").length< 1)
        {
            var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONEFIELD'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        };
        //zkt 20221104 BUG0058296设置图谱显示字段，建议控制一下最多设置10个字段
        if(selObj.find("option").length> 10)
        {
            var confirm_str = arrJsPopLabel['ONLY10FIELDALLOWED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        };
        
        selObj.find("option").each(function(){
             mapfields+=ld(this).val()+","
        });
        var fromrecordid = that.fromrecordid;
        var relatedid = that.relatedid;
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=editModuleMapfield&frommodule='+frommodule+"&fromrecordid="+fromrecordid+"&relatedid="+relatedid+'&mapfields='+mapfields+'&mode=save';
        ldAjaxNoProgress(urlstring,{},function(data){
            if(data.code == 1)
            {
                var modulemapfieldinfo = data.result.modulemapfieldinfo;
                var moduledatainfo = data.result.moduledatainfo;
                
                var mapdata = {'modulemapfieldinfo':modulemapfieldinfo,'moduledatainfo':moduledatainfo,
                            'moduledataindex_arr':that.moduledataindex_arr,'hreffieldcolumnname':that.hreffieldcolumnname,
                            'mapdata_arr':that.mapdata_arr};
                //编辑图谱界面内容重新加载
                var editmappopupobj = that.popupobj;
                that.showmap(editmappopupobj,mapdata);
                //刷新相关信息界面联系人图谱
                var detailviewpopupobj = CrmPopup.getlastPopupObjByType('relatelistpage');
                if(!empty(detailviewpopupobj)){
                    var listmodulemapobj = detailviewpopupobj.modulemapobj;
                    var mapdata = {'modulemapfieldinfo':modulemapfieldinfo,'moduledatainfo':moduledatainfo,
                                'moduledataindex_arr':listmodulemapobj.moduledataindex_arr,'hreffieldcolumnname':listmodulemapobj.hreffieldcolumnname,
                                'mapdata_arr':listmodulemapobj.mapdata_arr}
                    listmodulemapobj.showmap(detailviewpopupobj,mapdata);
                }
                popupobj.CancelEvent();
                that.addtagclick();
                that.resize();
                
            }
        });
        
        
    }
    
    this.search = function(obj){
        var event = window.event || arguments.callee.caller.arguments[0];
        if (event.keyCode == 13)
        {
            var popupobj = that.popupobj;
            var searchobj = ld("#"+popupobj.divid).find("[id=search_mapdatalist]");
            var searchvalue = ld(searchobj).val();
            that.searchvalue = searchvalue;
            that.initdatalistulHtml();
        }
    }
}

function entersearch(){
    
}