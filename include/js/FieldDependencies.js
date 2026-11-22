
/**
 * Class FieldDependencies
 * *{*修改编码格式:统一编码：UTF-8*}
 * @param datasource
 */
function FieldDependencies(datasource) {
	this.baseform = false;	
	this.DS = {};
	
	this.initDS(datasource);
}

/**
 * Initialize the data source
 */
FieldDependencies.prototype.initDS = function(datasource) {
	if(typeof(datasource) != 'undefined') {
		this.DS = datasource;
	}
}

/**
 * Initialize the form fields (setup onchange and dependent:change) listeners
 * and trigger the onchange handler for the loaded select fields.
 *
 * NOTE: Only select fields are supported.
 *
 */
FieldDependencies.prototype.setup = function(sourceform, datasource) {
	var thisContext = this;
    var popupobj=CrmPopup.getPopupObj("last");
	if(typeof(sourceform) == 'undefined') {
		this.baseform = document.forms['EditView'];
	} else {
		this.baseform = sourceform;
	}
    if(popupobj!=undefined&&popupobj.type=='detailviewpage')
     {
        //明细界面
        this.baseform=document.forms['DetailView'];
        
     }
	this.initDS(datasource);
    
	if(!this.baseform) return;
    
     
     if(popupobj!=undefined&&popupobj.type=='detailviewpage')
     {
         //明细界面
        ld("#"+popupobj.divid).find("select").bind('change',function(ev){
            
            
            thisContext.actOnSelectChange(ev);
        });
     }
     else
	jQuery('select', this.baseform).
		bind('change', function(ev){thisContext.actOnSelectChange(ev);});
}

/**
 * Initialize the form fields (setup onchange and dependent:change) listeners
 * 
 * NOTE: Only select fields are supported.
 * 
 */
FieldDependencies.prototype.init = function(sourceform, datasource) {	
	this.setup(sourceform, datasource);
     var popupobj=CrmPopup.getPopupObj("last");
     if(popupobj!=undefined&&popupobj.type=='detailviewpage')
     {
         for(var sourcename in this.DS) {
          
            ld("#"+popupobj.divid+' [name="'+sourcename+'"]').trigger('change');
    		//jQuery('[name="'+sourcename+'"]', this.baseform).trigger('change');
    	}
     }
     else
     {
            for(var sourcename in this.DS) {
    		jQuery('[name="'+sourcename+'"]', this.baseform).trigger('change');
    	}
     }
	
}

/**
 * On Change handler for select box.
 */
FieldDependencies.prototype.actOnSelectChange = function(event) {
 
	var sourcenode = event.target;		
	var sourcename = sourcenode.name;
	var sourcevalue = sourcenode.value;	
  
	this.fieldValueChange(sourcename, sourcevalue);
};

/**
 * Core function to handle the state of field value changes and 
 * trigger dependent:change event if (Event.fire API is available - Prototype 1.6)
 */
FieldDependencies.prototype.fieldValueChange = function(sourcename, sourcevalue) {
	var targetinfo = null;
	if(this.DS != undefined && typeof(this.DS[sourcename]) != 'undefined') {
		if(typeof(this.DS[sourcename][sourcevalue])  != 'undefined' ) {
			targetinfo = this.DS[sourcename][sourcevalue];
		} else {
			targetinfo = this.DS[sourcename]['__DEFAULT__'];
		}
	}

	var popupobj=CrmPopup.getPopupObj("last");
	if(targetinfo != null) {
	  
		for(var targetname in targetinfo) {
		
			var targetnode = CrmPopup.findHtmlobj(popupobj.divid,targetname);
			var selectedtargetvalue = targetnode.val();
			var targetvalues = targetinfo[targetname];
          
            
            //var jstargetnode=document.getElementById(targetname);
            var jstargetnode=CrmPopup.findHtmlobj(popupobj.divid,targetname);
			if(typeof(targetnode.data('allOptions')) == 'undefined') {
				 var allOptions = [];
				jQuery('option', targetnode).each(function(index,option) {
					allOptions.push(option);
				});
				targetnode.data('allOptions', allOptions);
			}
			var targetoptions = targetnode.data('allOptions');
             if(targetoptions==undefined)
             {
                continue;
             }
			// Remove the existing options nodes from the target selection
			jQuery('option', targetnode).remove();
			if(picklist == true && typeof(this.DS[sourcename][sourcevalue])  == 'undefined'){
				for(var index = 0; index < 1; ++index) {
					var optionNode = jQuery(document.createElement('option'));
					targetnode.append(optionNode);
					optionNode.text('');
					optionNode.val('');
				}
			}else{
				for(var index = 0; index < targetoptions.length; ++index) {
					var targetoption = jQuery(targetoptions[index]);
				  
					// Show the option if field mapping matches the option value or there is not field mapping available.
					if(targetvalues == false || targetvalues.indexOf(targetoption.val()) != -1) {
						var optionNode = jQuery(document.createElement('option'));
						targetnode.append(optionNode);
						optionNode.text(targetoption.text());
						optionNode.val(targetoption.val());
					}
				}
			}
              
            if(picklist==false)
            {
               
               
                for(var k=0;k<jstargetnode.find("option").length;k++)
                {
                  //  alert(jstargetnode.find("option")[k].text);
                    if(jstargetnode.find("option")[k].text==trim(CrmPopup.findHtmlobj(popupobj.divid,"cmb_span_optiontext_"+targetname).val()))
                    {
                      
                        jstargetnode.find("option")[k].selected=true;
                        break;
                    }
                }
                setCodeNumPrefix(sourcename,sourcevalue,'action');//设置编号(初始化获取默认值得拼音省份或城市的)
            }
			targetnode.trigger('change');
            this.changeULContent(targetname);
		}
	}
}
FieldDependencies.prototype.changeULContent=function(targetname)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var ultargert=CrmPopup.findHtmlobj(popupobj.divid,"cmb_ul_"+targetname);
    var targetnode =CrmPopup.findHtmlobj(popupobj.divid,targetname);
    if(ultargert!=undefined)
    {
        var childs =ultargert.find("li");    
        for(var i = childs.length - 1; i >= 0; i--) 
        {      
           
            childs[i].remove();      
        }
        var strli="";
        var j=1;
        if(picklist==true)
        CrmPopup.findHtmlobj(popupobj.divid,"cmb_span_optiontext_"+targetname).val(targetnode.find("option")[0].text);
            
        for(var i=0;i<targetnode.find("option").length;i++)
    	 {
            strli=strli+'<li name="dv_chzn_'+j+'_'+targetname+'" class="active-result" onmouseover="cmb_limouseover(event,\''+targetname+'\')" onclick="cmb_liclick(\''+targetnode.find("option")[i].text+'\',\''+targetname+'\')"> '+targetnode.find("option")[i].text+'</li>';
            j++;
    	 }
         strli=strli+'<li  name="li_chzn_'+targetname+'" >'+arrJsPopLabel['NOMATCHINGITEMS']+'</li>';
        ultargert.html(strli);
      //  <li id="dv_chzn_2_salutationtype" class="active-result" onmouseover="cmb_limouseover(event,'salutationtype')" onclick="cmb_liclick('先生','salutationtype')" style=""> 先生</li> 
    }
    
}