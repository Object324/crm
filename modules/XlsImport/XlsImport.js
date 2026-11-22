//document.write("<script language='JavaScript' type='text/javascript' src='modules/Settings/Mask.js'></script>");
var imprtcount=0;
var importNUm=1;
function showDivImportThirdAjax(importmodel,mapped_fieldsListListjson,defaultvalueListjson,isfieldnamevalueListjson,isfieldnameListjson){



    imprtcount=0;
    importNUm=1;
   // var urlvalue='&mapped_fields='+mapped_fieldsListListjson+'&defaultvalue='+defaultvalueListjson+'&isfieldnamevalue='+isfieldnamevalueListjson+'&isfieldname='+isfieldnameListjson;
    document.getElementById("canceltype").setAttribute("disabled", "disabled");  
    document.getElementById("edittype").setAttribute("disabled", "disabled"); 
    document.getElementById("mapped_fields").value=mapped_fieldsListListjson;
    document.getElementById("defaultvalue").value=defaultvalueListjson;
    document.getElementById("isfieldnamevalue").value=isfieldnamevalueListjson;
    document.getElementById("isfieldname").value=isfieldnameListjson;
    var imodel='XlsImport';
    var select2="";
    var select1="";
    
    var filetype =document.getElementById("filetype").value

    var radios=document.getElementsByName("choose");
        for(var i=0;i<radios.length;i++)
        {
            if(radios[i].checked==true)
            {
                var choose = radios[i].value; //导入页面，重复时导入方式 选中的值
            }
        }
   

   document.getElementById("select1").value=select1;
   document.getElementById("select2").value=select2;
   document.getElementById("xlsfiletype").value=filetype;
 
   document.getElementById("choose").value=choose;
   document.forms['frmimport'].submit();
        
           
                
		  
}

function setMsg(){
    var mun=Math.ceil(imprtcount/200);
    if(importNUm<=mun){
        openNewDivExport('newDiv',imprtcount,importNUm,'import');
        importNUm++;
        setTimeout(setMsg,10*300);
    }
}

function defaultImportXls(obj,rowindex)
 {
    
    var tab=document.getElementById('Importtable');
    rowindex=parseInt(rowindex)+1;
    var cellobj=tab.rows[rowindex].cells[3];
    var oldspanobj=cellobj.firstChild;
    var parentnode=cellobj;
    var optvalue=obj.options[obj.selectedIndex].value;
    var newspanobj=document.getElementById(optvalue+'-defaultvalue-container');
    var defaultValuesElementsContainer=document.getElementById('defaultValuesElementsContainer');
    var childhtml= parentnode.innerHTML;
  
    if(newspanobj != undefined && newspanobj != null){
         if(newspanobj.parentNode.id==undefined||newspanobj.parentNode.id=='')
         {
              parentnode.innerHTML='';
              defaultValuesElementsContainer.innerHTML+=childhtml;
            
             return ;
         }
           
         parentnode.innerHTML='';
         defaultValuesElementsContainer.removeChild(newspanobj); 
    }else{
        //alert(optvalue);
        var newNode = document.createElement('span');
    	var newNodeId = optvalue+'-defaultvalue-container';
        //var newNodeId = document.getElementById(optvalue+'-defaultvalue-container');
      	newNode.setAttribute('id',newNodeId);
      	newNode.setAttribute('name',optvalue+'-defaultvalue-container');
      	newNode.innerHTML = "<input id="+optvalue+"-defaultvalue name="+optvalue+"-defaultvalue type=\"text\" class=\"btn-radius-system\">";
        //newNode.innerHTML = "";
    	parentnode.appendChild(newNode);
        newspanobj=document.getElementById(newNodeId);
        parentnode.innerHTML='';
    } 
    
    parentnode.appendChild(newspanobj);  
    defaultValuesElementsContainer.innerHTML+=childhtml;;
   
 }
 
 //获取页面数组，并json传到php页面
 function ImportXlsSecondStepAjax(obj,importmodel)
 {
    
   
     var mappfields=document.getElementsByName('mapped_fields[]');
     var optvalues=''
     var arrimport;
     for(var i=0;i<mappfields.length;i++)
     {
        optvalues=optvalues+mappfields[i].options[mappfields[i].selectedIndex].value+',';
     }
     
     var mapped_fields=document.getElementsByName('mapped_fields[]');
     var mapped_fieldsList=new Array();
     var defaultvalueList=new Array();
     
     for(var i=0;i<mapped_fields.length;i++)
     {
        mapped_fieldsList[i]=mapped_fields[i].value;
        if(mapped_fields[i].value!='none-field'){
           
            if(document.getElementById(mapped_fields[i]+'-defaultvalue')!=undefined)
                    defaultvalueList[i]=document.getElementById(mapped_fields[i].value+'-defaultvalue').value;
            else
                    defaultvalueList[i]="";    
        }
     }
     
     var isfieldnamevalue=document.getElementsByName('isfieldnamevalue[]');
     var isfieldnamevalueList=new Array();
     for(var i=0;i<isfieldnamevalue.length;i++)
     {
        isfieldnamevalueList[i]=isfieldnamevalue[i].value;
     }
     
     var isfieldname=document.getElementsByName('isfieldname[]');
     var isfieldnameList=new Array();
     for(var i=0;i<isfieldname.length;i++)
     {
        isfieldnameList[i]=isfieldname[i].value;
     }
     
     for(var i=0;i<mappfields.length;i++)
     {
            
            importopt=mappfields[i].options[mappfields[i].selectedIndex].value;
          
             for(var j=0;j<mappfields.length;j++)
             {
                if(mappfields[i].options[mappfields[i].selectedIndex].value!='none-field'&&j!=i&&mappfields[i].options[mappfields[i].selectedIndex].value==mappfields[j].options[mappfields[j].selectedIndex].value&&mappfields[j].options[mappfields[j].selectedIndex].value != 'taxclass-field')
                {
					var jspop = arrJsPopLabel['FIELDMATCHESTIMES'];
					jspop = jspop.replace("$fldname$",mappfields[i].options[mappfields[i].selectedIndex].text);
                   // alert(jspop);
                     return false;
                }
             }
             
     }
     var mapped_fieldsListListjson=JSON.stringify(mapped_fieldsList);
     var defaultvalueListjson=JSON.stringify(defaultvalueList);
     var isfieldnamevalueListjson=JSON.stringify(isfieldnamevalueList);
     var isfieldnameListjson=JSON.stringify(isfieldnameList);
        //    openNewDiv('newDiv');
    showDivImportThirdAjax(importmodel,mapped_fieldsListListjson,defaultvalueListjson,isfieldnamevalueListjson,isfieldnameListjson);
 }