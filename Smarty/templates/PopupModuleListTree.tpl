<div>
    <span id="listviewtreeopen" class="listviewtreeopen" data-tip="" data-direction="right" data-type="position"></span>
    <div id="structuretree" class="webkit-scrollbar" style="width:{$POPUPMODULElISTTREE.tree_width}px;{if $POPUPMODULElISTTREE.tree_expand eq 'no'}display:none;{/if}">
<input type="hidden" id="isshowPopupModuleListTree" name="isshowPopupModuleListTree" value="yes" />
<ul class="filetree filetreeTop" id="popupmoduletreelist" style="overflow-y: auto;">
    <li>
        <div class="groupuser-treediv" name="moudle_tree" onmouseover="showModuleTree(this)" onmouseout="hideModuleTree(this)">
            <div class="groupuser-treediv-span">
                <span name="module_expand_collapse" depth="0" class="group_node_collapse tree-down">
                </span><span class="file" record="Picklist_0" depth="0" sourcefield="" targetfield="{$PopupModuleListTree.sourcefield}" tag="moudle_tree" parent="" data-tip="{'ALLDATA'|@getFixedLabel}" data-direction="top" data-type="position">
                    <label>{'ALLDATA'|@getFixedLabel}</label>
                </span>
            </div>
        </div>
        {assign var='popupmoduletreelist' value=$POPUPMODULElISTTREE.list }
        {assign var='sourcefield' value=$POPUPMODULElISTTREE.sourcefield }
        {assign var='targetfield' value=$POPUPMODULElISTTREE.targetfield }
        <ul depth="0" style="display: block;">
            {foreach key = key item = picklistval from = $popupmoduletreelist}
                {assign var='id' value=$key}
                {assign var='depth' value=$picklistval.depth}
                <li>
                    <div class="groupuser-treediv" name="moudle_tree" onmouseover="showModuleTree(this)" onmouseout="hideModuleTree(this)" >
                        <div class="groupuser-treediv-span">
                            {if $picklistval.targetenable eq 'yes'}
                                <span name="module_expand_collapse" depth="{$depth}" class="group_node_expand tree-right">
                            {else}
                                <span group_margin_right="{$depth}" style="margin-right:15px" depth="{$depth}">
                            {/if}
                            </span><span class="file" record="Picklist_{$id}" depth="{$depth}" sourcefield="{$sourcefield}" targetfield="{$targetfield}" tag="moudle_tree"  parent="0" key="{$picklistval.value}" parentchild="0^_^{$picklistval.value}" data-tip="{$picklistval.value}" data-direction="top" data-type="position">
                                <label>{$picklistval.value}</label>
                            </span>
                        </div>
                    </div>
                    {if is_array($Inithtmlexpand) && $Inithtmlexpand.record eq $id}
                        {$Inithtmlexpand.expendhtml}
                    {/if}
                </li>
            {/foreach}
        </ul>
    </li>
</ul>
</div>
</div>
<script type="text/javascript">


    var POPUPMODULE_TREE_PICKLIST_ID='{$POPUPMODULE_TREE_PICKLIST_ID}';//选择列表
    PopupModuleListTree.module = '{$MODULE}';
{literal}
    function PopupModuleListTree (htmlobj)
    {
         var that=this;
        this.htmlobj=htmlobj;
      
        this.initGroup =function(){
             this.mode="";//编辑edit，新增create，删除del
             this.htmlobj=htmlobj;
             this.parentgrouphtmlobj=that.htmlobj;
             this.recordhtmlobj=htmlobj;
            
             if(PopupModuleListTree.curr_moduletree_obj!=undefined&&PopupModuleListTree.curr_moduletree_obj!="")
             {
                PopupModuleListTree.curr_moduletree_obj.recordhtmlobj.find("label").css("color","").css("display","inherit");//#666        
             }
             this.recordhtmlobj.find("label").css("color","#3B7CFF").css("display","inherit");
        
              while(this.recordhtmlobj.prop("tagName")!=undefined&&this.recordhtmlobj.prop("tagName").toLowerCase()!="span")
              {
                this.recordhtmlobj=this.recordhtmlobj.parent();
              }
            
              this.records=this.recordhtmlobj.attr("record").split("_");
              this.record=this.records[1];//获取下拉框ID
             while(this.parentgrouphtmlobj.prop("tagName")!=undefined&&this.parentgrouphtmlobj.prop("tagName").toLowerCase()!="li")
             {
                this.parentgrouphtmlobj=Tools.getParentobjByChild(this.parentgrouphtmlobj,'li');
             }
             
           PopupModuleListTree.curr_moduletree_obj=this;
        }
          this.initGroup();
    }
    PopupModuleListTree.curr_moduletree_obj="";
    PopupModuleListTree.setHeight = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        var popuptype = popupobj.popuptype;
        var ulmaxheight = 0;
        var divobj = ld('#'+popupobj.divid);
        var popuptypeArr = ['MultiplePopup','specific_account_address_pop','specific_contact_address_pop',
            'AccountsChart','set_return_groupemails','set_return_groupmasssms',
            'inventory_prod',];
        if (popuptype == 'select_related_popup'){
            var popupListViewModuleListTree = divobj.find('[name=popupListViewModuleListTree]');
            popupListViewModuleListTree.hide();
            var popupListViewContentsobj = ld("#"+popupobj.divid+" [name=popupListViewContents]");
            // if(popupListViewContentsobj!=undefined && popupListViewContentsobj.length>0)
            //     ulmaxheight = popupListViewContentsobj.find('[name=hdScrolllistentries_yy]').outerHeight();
            // if(popupListViewContentsobj.find('#redfont_tip').length>0){//单选弹出文本部分高度
            //     ulmaxheight += popupListViewContentsobj.find('#redfont_tip').outerHeight(true);
            // }
            ulmaxheight = popupListViewContentsobj.outerHeight();
            popupListViewModuleListTree.show();
        }else if (popuptypeArr.indexOf(popuptype)){
            var popupListViewContentsobj = ld("#"+popupobj.divid+" [name=ListViewContents]");
            if(popupListViewContentsobj.find('#MultiplePopupSelect').length > 0){
                ulmaxheight = popupListViewContentsobj.find('#MultiplePopupSelect').outerHeight();
            }
            if ( popuptype == 'specific_account_address_pop' || popuptype == 'AccountsChart'){//工作汇报-新建-选择客户-翻页行
                ulmaxheight = ld("#"+popupobj.divid+" [name=ListViewContents]").find('table:first').outerHeight();
            }else if (popuptype == 'specific_contact_address_pop'){
                ulmaxheight = ld("#"+popupobj.divid+" [name=pagediv]").outerHeight()+10;//翻页+底部padding
            }
            if(popupListViewContentsobj.find('#resize_header_table_divid').length > 0){
                ulmaxheight += popupListViewContentsobj.find('#resize_header_table_divid').outerHeight();
                ulmaxheight += 8;//paddding-top
            }
            if(popupListViewContentsobj.find('#resize_content_table_divid').length > 0){
                ulmaxheight += popupListViewContentsobj.find('#resize_content_table_divid').outerHeight();
            }
            if (popupListViewContentsobj.find('[name=redtip_limitcount]').length>0){
                ulmaxheight +=popupListViewContentsobj.find('[name=redtip_limitcount]').outerHeight(true);
            }
        }else{
            if(ld("#"+popupobj.divid+" [name=ListViewContents]").length > 0){
                ulmaxheight = ld("#"+popupobj.divid+" [name=ListViewContents]").find('table:first').get(0).offsetHeight;
            }
        }
        var maxheight = ld("#"+popupobj.divid).outerHeight();
        if (parseInt(ulmaxheight) > parseInt(maxheight)){
            ulmaxheight = maxheight;
        }
        else if (parseInt(ulmaxheight) < 200){
            ulmaxheight = 200;
        }
        ld("#"+popupobj.divid+" #popupmoduletreelist").slimscroll({height: ulmaxheight});
        ld("#"+popupobj.divid+" #popupmoduletreelist").css('height',ulmaxheight);
    };
    PopupModuleListTree.setEvent = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var moudle_tree_obj = ld("#"+popupobj.divid+" #popupmoduletreelist span[tag=moudle_tree]");
        if(moudle_tree_obj != undefined && moudle_tree_obj.length>0)
        {
            //部门节点点击事件
            ld("#"+popupobj.divid+" #popupmoduletreelist span[tag=moudle_tree]").unbind("click").bind("click",function(event){

                    var parentliobj=Tools.getParentobjByChild(this,'li');
                    if(ld.inArray(ld(this).attr("record"), PopupModuleListTree.nodecount)<0&&PopupModuleListTree.nodecount[0]!="")
                    {
                        PopupModuleListTree.nodecount=[];
                    }
                    //PopupModuleListTree对象丢失时，获取当前的PopupModuleListTree对象（即选中的）
                    var popupobj=CrmPopup.getPopupObj('last');
                    if(popupobj.moduletreeobj!=undefined&&PopupModuleListTree.curr_moduletree_obj==""){
                        popupobj.moduletreeobj.initGroup();
                    }
                    PopupModuleListTree.nodecount.push(ld(this).attr("record"));
                    //用这样的方式否则会冒泡
                    var parentdivobj = Tools.getParentobjByChild(this,'div');
                    var module_expand_collapseobj = ld(parentdivobj).find("span[name=module_expand_collapse]");
                    if(module_expand_collapseobj!=undefined&&module_expand_collapseobj.length>0&&ld.inArray(ld(this).attr("record"), PopupModuleListTree.nodecount)>=0&&PopupModuleListTree.nodecount.length>=2)
                    {
                        module_expand_collapseobj.click();
                    }
                    else
                    {
                        PopupModuleListTree.CreateObj(ld(this));
                        PopupModuleListTree.showModuleTreeListView();
                    }

               });
               
              //展开收缩事件
              ld("#"+popupobj.divid+" #popupmoduletreelist span[name=module_expand_collapse]").unbind("click").bind("click",function(event){
                var parentliobj=Tools.getParentobjByChild(this,'li');
                var nowdepth=ld(this).attr("depth");
                if(ld(this).attr("class").indexOf("group_node_collapse")>=0)//如果是收缩
                {
                  // console.log('收缩');
                  parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','none');
                  ld(this).attr("class","group_node_expand");
                  ld(this).addClass("tree-right");
                }
                else //如果是展开
                {
                  // console.log('展开');
                  parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
                  ld(this).attr("class","group_node_collapse");
                  ld(this).addClass("tree-down");
                } 
                PopupModuleListTree.CreateObj(ld(this).next());  
                PopupModuleListTree.showModuleTreeListView();
                //showDefaultCustomView(PopupModuleListTree.listparams['CustomViewObj'],PopupModuleListTree.module,"",PopupModuleListTree.listparams['viewid']);
              });
        }
        // PopupModuleListTree.setHeight();
    }
    
    //zkt 鼠标离开事件，不显示上移、下移、更多按钮
    function  hideModuleTree()
    {
        
        ld("div[name=moudle_tree]").css('background-color','');//所有部门div背景色取消
        ld("div[name=moudle_tree]").find('span[tag=moudle_tree]').each(function(){
            ld(this).css('color','');//所有部门span color取消
            // var thiswidth = ld(this).parent().width()-15;
            // ld(this).css('width',thiswidth);
        });
        return ;
    }
    //鼠标经过部门事件，显示上移、下移、更多按钮
    function showModuleTree(obj)
    {
        var divobj=obj;
        ld("div[name=moudle_tree]").css('background-color','');
        var liobj=Tools.getParentobjByChild(divobj,'li');
        ld(divobj).css('background-color','#ebf3ff');//当前部门设置背景色
        ld(divobj).find('span[tag=moudle_tree]').css('color','#3B7CFF');//当前部门span color设置
        ld(divobj).find('div[name=moudle_tree]').css('display','inline-block');//当前部门操作按钮显示
        
        return ;
    }
    PopupModuleListTree.listfirst=1;
    PopupModuleListTree.listparams={CustomViewObj:"",viewid:0};
    PopupModuleListTree.nowdepth=0;
    PopupModuleListTree.nodecount=[];
    
    PopupModuleListTree.init=function()
    {
       
         if(ld("#popupmoduletreelist span[tag=moudle_tree]")!=undefined&&ld("#popupmoduletreelist span[tag=moudle_tree]").length>0)
        {
            if(PopupModuleListTree.listfirst==1)
                {
                    
                    if(POPUPMODULE_TREE_PICKLIST_ID>=1)
                    {
                        ld("#popupmoduletreelist span[tag=moudle_tree]").each(function()
                        {
                             var records=ld(this).attr('record').split("_");
                             if(records[1]==POPUPMODULE_TREE_PICKLIST_ID)
                             {
                              
                                PopupModuleListTree.nowdepth=ld(this).attr("depth");
                             
                                PopupModuleListTree.CreateObj(ld(this));
                                PopupModuleListTree.expandAllParent(ld(this));
                                PopupModuleListTree.nodecount.push(ld(this).attr("record"));
                                return false;
                             }
                        });
                        
                        
                    }
                    else
                    {
                         PopupModuleListTree.nowdepth=0;
                       
                         PopupModuleListTree.nodecount.push(ld("#popupmoduletreelist span[depth=0][tag=moudle_tree]").attr("record"));
                         PopupModuleListTree.CreateObj(ld("#popupmoduletreelist span[depth=0][tag=moudle_tree]"));
                    }
                }
                PopupModuleListTree.listparams['CustomViewObj']="";
                PopupModuleListTree.listparams['CustomViewObj']=ld(".currdataClass").attr("viewid");
                PopupModuleListTree.listfirst++;
        }
    }
    PopupModuleListTree.CreateObj=function(obj)
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var moduletreeobj=new PopupModuleListTree(obj);
        popupobj.moduletreeobj=moduletreeobj;
        return moduletreeobj;
    }
    
    PopupModuleListTree.showModuleTreeListView =function(){
        //PopupModuleListTree对象丢失时，获取当前的PopupModuleListTree对象（即选中的）
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.moduletreeobj!=undefined&&PopupModuleListTree.curr_moduletree_obj==""){
            popupobj.moduletreeobj.initGroup();
        }
        var recordspanobj = PopupModuleListTree.curr_moduletree_obj.recordhtmlobj;
        var recorddivobj = Tools.getParentobjByChild(Tools.getParentobjByChild(PopupModuleListTree.curr_moduletree_obj.recordhtmlobj,'div'),'div'); //点击的对象所在div
        //PopupModuleListTree.curr_moduletree_obj; //PopupModuleListTree对象
        //加载下级列表并设置$_SESSION
        var module = PopupModuleListTree.module;
        //zkt 20230419 (没有模块权限时产品模块权限选择产品)BUG0065162 http://81.70.87.230:85/crm/（沐宸科技）：项目设备清单选择产品时，单击左侧树结构右侧产品无变化；
        var urlstring = 'index.php?module=Users&action=UsersAjax&file=ModuleTree&setsessionmodule='+module;
        var dataparam = 'setsession=yes';
        var selectrecord = PopupModuleListTree.curr_moduletree_obj.record;//点击下拉框值id
        var sourcefield = ld(recordspanobj).attr('sourcefield');//点击内容对应字段名
        dataparam += '&sourcefield='+sourcefield;
        dataparam += '&selectrecord='+selectrecord;
        var moduletreedata = {};
        if(selectrecord>0){
            var parent = ld(recordspanobj).attr('parent');
            var parentarr = parent.split("_");
            var searchparent = '0';
            for (i = 1 ; i<parentarr.length; i++)
            {
                //049625: （https://81mis.com/kfbtest/index.php [^]）合同订单》新建》选择产品，弹窗中的树状图左侧筛选没反应
                if(ld("#popupmoduletreelist span[depth="+i+"][tag=moudle_tree][record=Picklist_"+parentarr[i]+"][parent="+searchparent+"]")!=undefined){
                    var uperspanobj = ld("#popupmoduletreelist span[depth="+i+"][tag=moudle_tree][record=Picklist_"+parentarr[i]+"][parent="+searchparent+"]").get(0);
                    var uperrecords=ld(uperspanobj).attr('record').split("_");
                    var uperrecord=uperrecords[1];//获取下拉框ID
                    var upersourcefield = ld(uperspanobj).attr('sourcefield');
                    moduletreedata[upersourcefield] = uperrecord;
                    searchparent += '_'+uperrecord;
                }
            }
            
            moduletreedata[sourcefield] = selectrecord;
            var moduletreejson = JSON.stringify(moduletreedata);
            dataparam += '&moduletreejson='+encodeURIComponent(moduletreejson);
        }
        //下级列表已加载或没有下级列表时不获取下级列表
        if((ld(recorddivobj).next()!=undefined&&ld(recorddivobj).next().length>0)||(ld(recorddivobj).find('group_margin_right')!=undefined&&ld(recorddivobj).find('group_margin_right').length>0)){
            
        }
        else{
            dataparam += '&getdependency=yes';
            var targetfield = ld(recordspanobj).attr('targetfield');//点击内容对应下级字段名
            dataparam += '&targetfield='+targetfield;
            
        }

        ldAjaxsync(urlstring,dataparam,function (data) {
            DelProgressObjs();
            if(data.code==1)
            {
                var dependencylist = data.result.dependencymoduletreelist;
                if(!empty(dependencylist)){
                    if(dependencylist.enable == 'yes' && !empty(dependencylist.list))
                    {
                        var listarr =dependencylist.list;
                        var dependencylistseq = data.result.dependencymoduletreelistseq;
                        var sourcefield = dependencylist.sourcefield;
                        var targetfield = dependencylist.targetfield;
                        var spanparent = ld(recordspanobj).attr('parent')+'_'+selectrecord;
                        var prevspanobj = ld(recordspanobj).prev();
                        var parentdepth = ld(recordspanobj).attr('depth');
                        var addhtml = "";
                        var parentchild = ld(recordspanobj).attr('parentchild');
                        if(ld(prevspanobj).attr("class").indexOf("tree-right")>=0){
                            addhtml = "<ul depth='"+parentdepth+"' style='display:none;'>";
                        }
                        else{
                            addhtml += "<ul depth='"+parentdepth+"'>";
                        }
                        var parentdiv=Tools.getParentobjByChild(recordspanobj,'div');
                        // var tmpwidth=parseInt(ld(parentdiv).width())-10;
                        //zkt 20220221 0050052: （81mis.com/kfbtest/index.php）产品管理》左侧树状图，树状图的选项顺序和级联设置的选项顺序不一样
                        for( i=0,len = dependencylistseq.length;i<len;i++)
                        {
                            var key = dependencylistseq[i];
                            var spanvalue = listarr[key].value;
                            var depth = listarr[key].depth;
                            addhtml += "<li><div class='groupuser-treediv' name='moudle_tree' onmouseover='showModuleTree(this)' onmouseout='hideModuleTree(this)'><div class='groupuser-treediv-span'>";
                            if(listarr[key].targetenable=='yes'){
                                addhtml  += "<span class='group_node_expand tree-right' name='module_expand_collapse' depth='"+depth+"'></span><span class='file' tag='moudle_tree' depth='"+depth+"' record='Picklist_"+key+"' sourcefield='"+sourcefield+"' targetfield='"+targetfield+"'   parent='"+spanparent+"' key='"+spanvalue+"' parentchild='"+parentchild+'^_^'+spanvalue+"' data-tip='"+spanvalue+"' data-direction='top' data-type='position'><label>"+spanvalue+"</label> </span></div></li>";
                            }
                            else{
                                addhtml  += "<span group_margin_right='"+depth+"' style='margin-right:15px'></span><span class='file' tag='moudle_tree' depth='"+depth+"' record='Picklist_"+key+"' sourcefield='"+sourcefield+"' targetfield='"+targetfield+"'   parent='"+spanparent+"' data-tip='"+spanvalue+"' key='"+spanvalue+"' parentchild='"+parentchild+'^_^'+spanvalue+"' data-direction='top' data-type='position'><label>"+spanvalue+"</label> </span></div></div></li>";
                            }
                        }
                        addhtml += '</ul>';
                        var recordhtmlobj =PopupModuleListTree.curr_moduletree_obj.recordhtmlobj;
                        var parentli=Tools.getParentobjByChild(recordhtmlobj,'li');
                        parentli.append(addhtml);

                    }
                }
                PopupModuleListTree.setEvent();

                //刷新列表
                popupobj.getSearch();
            }
        });
        
    }

    PopupModuleListTree.expandAllParent=function(obj)
    {
        
         if(obj==""||obj==undefined)
         {
            ld("#popupmoduletreelist span[depth=0]").click();
            return ;
         }
        if(obj.parent().next()!=undefined&&obj.parent().next().length>0)
        {
            obj.parent().next().css("display","block");
        }
      //  obj.prev().html("收缩");
        var parentobj=obj;
       
        while(parentobj!=undefined&&parentobj.length>0&&parseInt(parentobj.attr("depth"))>=0)
        {
           
            parentobj=Tools.getParentobjByChild(parentobj,'ul');//获取上级节点(ul);
            parentobj.css("display","block");
            parentobj.prev().find("span[name=module_expand_collapse]").attr("class","group_node_collapse");
            parentobj.prev().find("span[name=module_expand_collapse]").addClass('tree-down');
            
        }
     
    }
{/literal}
    PopupModuleListTree.setEvent();
    PopupModuleListTree.init();

</script>