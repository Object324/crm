<div>
    <span id="listviewtreeopen" class="tip-items-list listviewtreeopen {if $CURRENT_USER->user_type == 'prm'}treeinner{/if}" data-tip="" data-direction="right" data-type="position"></span>
    <div id="structuretree" class="webkit-scrollbar" style="width:{$MODULElISTTREE.tree_width}px;{if $MODULElISTTREE.tree_expand eq 'no'}display:none;{/if}">
    <input type="hidden" id="isshowModuleListTree" value="yes" />
    <ul class="filetree filetreeTop" id="moduletreelist" style="overflow-y: auto;">
        <li>
            <div class="groupuser-treediv" name="moudle_tree" onmouseover="showModuleTree(this)" onmouseout="hideModuleTree(this)">
                <div class="groupuser-treediv-span">
                    <span name="module_expand_collapse" depth="0" class="group_node_collapse tree-down">
                    </span><span class="file" show="yes" record="Picklist_0" depth="0" sourcefield="" targetfield="{$MODULElISTTREE.sourcefield}" tag="moudle_tree" parent="" data-tip="{'ALLDATA'|@getFixedLabel}" data-direction="top" data-type="position">
                        <label>{'ALLDATA'|@getFixedLabel}</label>
                        {if $IS_ADMIN eq true}
                            {*zkt 20220401 50792: （81mis.com/kfbcrm）客户》左上角全部数据设置按钮，点击出来显示的树结构弹窗，下拉框字段是产品模块的，点击设置按钮会进入产品页面设置*}
                            {*diony 20231201 BUG0076589 界面优化，去掉这个设置*}
                            <!-- <a name="tree_openModuleSettings" title="{getFixedLabel("treestruturesettings")}" class="icon-categorybtn categorymanager-set" style="cursor:pointer;margin-left:3px;" onclick="ListViewsetModuleTree('{$MODULE}',event);  return false;"></a> -->
                        {/if} 
                    </span>
                </div>
            </div>
            {assign var='moduletreelist' value=$MODULElISTTREE.list }
            {assign var='sourcefield' value=$MODULElISTTREE.sourcefield }
            {assign var='targetfield' value=$MODULElISTTREE.targetfield }
            <ul depth="0" style="display: block;">
                {foreach key = key item = picklistval from = $moduletreelist}
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
                                </span><span class="file" show="yes" record="Picklist_{$id}" depth="{$depth}" sourcefield="{$sourcefield}" targetfield="{$targetfield}" tag="moudle_tree"  parent="0"  key="{$picklistval.value}" parentchild="0^_^{$picklistval.value}" data-tip="{$picklistval.value}" data-direction="top" data-type="position">
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
    var MODULE_TREE_PICKLIST_ID='{$MODULE_TREE_PICKLIST_ID}';//选择列表
    ModuleListTree.module = '{$MODULE}';
{literal}
    function ListViewsetModuleTree(module,e){
        //阻止事件冒泡，如果不阻止则客户列表创建普通客户会有两个弹出层
        var e = e || window.event;  
        if(e.stopPropagation) { //W3C阻止冒泡方法  
            e.stopPropagation();  
        } else {  
            e.cancelBubble = true; //IE阻止冒泡方法  
        }
        getJsScript('include/js/cls_ModuleTree.js', function () {
            var moduletree = new cls_ModuleTree(module);
			moduletree.show();
        });
        return;
    }
    function ModuleListTree (htmlobj)
    {
        var that=this;
        this.htmlobj=htmlobj;
      
        this.initGroup =function(){
             this.mode="";//编辑edit，新增create，删除del
             this.htmlobj=htmlobj;
             this.parentgrouphtmlobj=that.htmlobj;
             this.recordhtmlobj=htmlobj;
            
             if(ModuleListTree.curr_moduletree_obj!=undefined&&ModuleListTree.curr_moduletree_obj!="")
             {
                ModuleListTree.curr_moduletree_obj.recordhtmlobj.find("label").css("color","").css("display","inherit");//#666        
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
             
           ModuleListTree.curr_moduletree_obj=this;
        }
          this.initGroup();
    }
    ModuleListTree.curr_moduletree_obj="";
    ModuleListTree.setEvent = function(){
        if(ld("#moduletreelist span[tag=moudle_tree]")!=undefined&&ld("#moduletreelist span[tag=moudle_tree]").length>0)
        {
                //部门节点点击事件
               ld("#moduletreelist span[tag=moudle_tree]").unbind("click").on("click",function(event){
                    event.stopPropagation();// ljj 20230915 BUG0072492 阻止冒泡
                    var parentliobj=Tools.getParentobjByChild(this,'li');
                    if(ld.inArray(ld(this).attr("record"), ModuleListTree.nodecount)<0&&ModuleListTree.nodecount[0]!="")
                    {
                        ModuleListTree.nodecount=[];
                    }
                    //ModuleListTree对象丢失时，获取当前的ModuleListTree对象（即选中的）
                    var popupobj=CrmPopup.getPopupObj('last');
                    if(popupobj.moduletreeobj!=undefined&&ModuleListTree.curr_moduletree_obj==""){
                        popupobj.moduletreeobj.initGroup();
                    }
                    ModuleListTree.nodecount.push(ld(this).attr("record"));
                    //用这样的方式否则会冒泡
                    var parentdivobj = Tools.getParentobjByChild(this,'div');
                    var module_expand_collapseobj = ld(parentdivobj).find("span[name=module_expand_collapse]");
                    if(module_expand_collapseobj!=undefined&&module_expand_collapseobj.length>0&&ld.inArray(ld(this).attr("record"), ModuleListTree.nodecount)>=0&&ModuleListTree.nodecount.length>=2)
                    {
                        module_expand_collapseobj.click();
                    }
                    else
                    {
                        ModuleListTree.CreateObj(ld(this)); 
                        ModuleListTree.showModuleTreeListView();
                    }
                    
               });

                // ljj 20230915 BUG0072492 kfbcrm-客户-树结构-应点击整块深色区域都能选中，目前是只有点击字的时候才可以选中
               ld("#moduletreelist div[name=moudle_tree]").unbind("click").on('click',function (){
                   ld(this).find('span[tag=moudle_tree]').click();
               });

              //展开收缩事件
              ld("#moduletreelist span[name=module_expand_collapse]").unbind("click").on("click",function(event){
                event.stopPropagation();// ljj 20230915 BUG0072492 阻止冒泡
                var parentliobj=Tools.getParentobjByChild(this,'li');
                var nowdepth=ld(this).attr("depth");
                if(ld(this).attr("class").indexOf("group_node_collapse")>=0)//如果是收缩
                {
                  // console.log('收缩');
                  parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','none');
                  ld(this).attr("class","group_node_expand");
                  ld(this).addClass("tree-right");
                  ld(parentliobj).find(" ul span[record^=Picklist_]").attr('show','no');
                }
                else //如果是展开
                {
                  // console.log('展开');
                  parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
                  ld(this).attr("class","group_node_collapse");
                  ld(this).addClass("tree-down");
                  ld(parentliobj).find(" div>div> span[record^=Picklist_]").attr('show','yes');
                }
                //console.log(ld("#structuretree ").find(' ul:not([style*="display: none"])>li>div>div> span[record^=Picklist_]:not([style*="display: none"])'));
                //console.log(ld("#structuretree").find('span[show="yes"]'));
                ModuleListTree.CreateObj(ld(this).next());  
                ModuleListTree.showModuleTreeListView();
                
              });
        }
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
    ModuleListTree.listfirst=1;
    ModuleListTree.listparams={CustomViewObj:"",viewid:0};
    ModuleListTree.nowdepth=0;
    ModuleListTree.nodecount=[];
    
    ModuleListTree.init=function()
    {
       
         if(ld("#moduletreelist span[tag=moudle_tree]")!=undefined&&ld("#moduletreelist span[tag=moudle_tree]").length>0)
        {
            
            if(ModuleListTree.listfirst==1)
                {
                    
                    if(MODULE_TREE_PICKLIST_ID>=1)
                    {
                        ld("#moduletreelist span[tag=moudle_tree]").each(function()
                        {
                             var records=ld(this).attr('record').split("_");
                             if(records[1]==MODULE_TREE_PICKLIST_ID)
                             {
                              
                                ModuleListTree.nowdepth=ld(this).attr("depth");
                             
                                ModuleListTree.CreateObj(ld(this));
                                ModuleListTree.expandAllParent(ld(this));
                                ModuleListTree.nodecount.push(ld(this).attr("record"));
                                return false;
                             }
                        });
                        
                        
                    }
                    else
                    {
                         ModuleListTree.nowdepth=0;
                       
                         ModuleListTree.nodecount.push(ld("#moduletreelist span[depth=0][tag=moudle_tree]").attr("record"));
                         ModuleListTree.CreateObj(ld("#moduletreelist span[depth=0][tag=moudle_tree]"));
                    }
                }
                ModuleListTree.listparams['CustomViewObj']="";
                ModuleListTree.listparams['CustomViewObj']=ld(".currdataClass").attr("viewid");
                ModuleListTree.listfirst++;
        }
        var pageheadheight=ld('#pagehead').height();
        var ulmaxheight = CrmPopup.getClientHeight()-pageheadheight;
        if(ld('.ld-listview-screen').length > 0){
            ulmaxheight = ulmaxheight - ld('.ld-listview-screen').get(0).offsetHeight - 9;
        }
        ld("#moduletreelist").css('height',ulmaxheight);
    }
    ModuleListTree.getInithtmlexpand = function(){
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ModuleTree&getInithtml=yes';
        ldAjaxsyncNoProgress(urlstring,'',function(ajaxdata){});
    }
    ModuleListTree.CreateObj=function(obj)
    {
        var popupobj=CrmPopup.getPopupObj('first');
        var moduletreeobj=new ModuleListTree(obj);
        popupobj.moduletreeobj=moduletreeobj;
        return moduletreeobj;
    }
    
    //showModuleTreeListView(ModuleListTree.listparams['CustomViewObj'],"Users","",ModuleListTree.listparams['viewid']);
    ModuleListTree.showModuleTreeListView =function(){
        //ModuleListTree对象丢失时，获取当前的ModuleListTree对象（即选中的）
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.moduletreeobj!=undefined&&ModuleListTree.curr_moduletree_obj==""){
            popupobj.moduletreeobj.initGroup();
        }
        var recordspanobj = ModuleListTree.curr_moduletree_obj.recordhtmlobj;
        var recorddivobj = Tools.getParentobjByChild(Tools.getParentobjByChild(ModuleListTree.curr_moduletree_obj.recordhtmlobj,'div'),'div'); //点击的对象所在div
        //ModuleListTree.curr_group_obj; //ModuleListTree对象
        //加载下级列表并设置$_SESSION
        var module = ModuleListTree.module;
        var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ModuleTree';
        var dataparam = '&setsession=yes';
        var selectrecord = ModuleListTree.curr_moduletree_obj.record;//点击下拉框值id
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
                if(ld("#moduletreelist span[depth="+i+"][tag=moudle_tree][record=Picklist_"+parentarr[i]+"][parent="+searchparent+"]")!=undefined){
                    var uperspanobj = ld("#moduletreelist span[depth="+i+"][tag=moudle_tree][record=Picklist_"+parentarr[i]+"][parent="+searchparent+"]").get(0);
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
                                addhtml  += "<span class='group_node_expand tree-right' name='module_expand_collapse' depth='"+depth+"'></span><span class='file' tag='moudle_tree' depth='"+depth+"' record='Picklist_"+key+"' sourcefield='"+sourcefield+"' targetfield='"+targetfield+"'   parent='"+spanparent+"' key='"+spanvalue+"' parentchild='"+parentchild+'^_^'+spanvalue+"' data-tip='"+spanvalue+"' data-direction='top' data-type='position'><label>"+spanvalue+"</label> </span></div></div></li>";
                            }
                            else{
                                addhtml  += "<span group_margin_right='"+depth+"' style='margin-right:15px'></span><span class='file' tag='moudle_tree' depth='"+depth+"' record='Picklist_"+key+"' sourcefield='"+sourcefield+"' targetfield='"+targetfield+"'   parent='"+spanparent+"' key='"+spanvalue+"' parentchild='"+parentchild+'^_^'+spanvalue+"' data-tip='"+spanvalue+"' data-direction='top' data-type='position'><label>"+spanvalue+"</label> </span></div></div></li>";
                            }
                        }
                        addhtml += '</ul>';
                        var recordhtmlobj =ModuleListTree.curr_moduletree_obj.recordhtmlobj;
                        var parentli=Tools.getParentobjByChild(recordhtmlobj,'li');
                        parentli.append(addhtml);
                        ModuleListTree.setEvent();
                        ld(parentli).find(" div>div> span[record^=Picklist_]").attr('show','yes');
                    }
                }
                else{

                }
            }
        });

        
        //跳转页面
        // showDefaultCustomView(ModuleListTree.listparams['CustomViewObj'],ModuleListTree.module,"",ModuleListTree.listparams['viewid']);


        var urlstring = '';
        search_fld_val = ld("select[name=search_field]").val();
        if (search_fld_val == 'all') {
            var optionvalues = ld("select[name=search_field]").eq(0).find(' option').map(function () {
                if (ld(this).val() != 'all') {
                    return ld(this).val();
                }
            }).get();
            var search_fld_val_arr = JSON.stringify(optionvalues);
            urlstring += 'search_field_arr=' + search_fld_val_arr;
        }
        var search_text_value = trim(ld("input[name=search_text]").val());
        search_txt_val = encodeURIComponent(search_text_value);
        urlstring += '&query=true&search_field=' + search_fld_val + '&searchtype=BasicSearch&search_text=' + search_txt_val;
        getListViewEntries_js(ModuleListTree.module,urlstring);
    }
    ModuleListTree.expandAllParent=function(obj)
    {
        
         if(obj==""||obj==undefined)
         {
            ld("#moduletreelist span[depth=0]").click();
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
    ModuleListTree.setEvent();
    ModuleListTree.init();
{/literal}
</script>