/**
 *@andy: 
 *@date:20140819
 *@reason:模块中英文名称保存
 *@version:v5.61
 */
 var prevtrobj=undefined;
function vtlib_showeditinput(event,row){
    if(ld('#span_subjectcode_'+row) != undefined){
        ld('#span_subjectcode_'+row).hide();
    }
    if(ld('#div_subjectcode_'+row) != undefined){
        ld('#div_subjectcode_'+row).show();
    }
    if(ld('#span_subjectcode2_'+row) != undefined){
        ld('#span_subjectcode2_'+row).hide();
    }
    if(ld('#div_subjectcode2_'+row) != undefined){
        ld('#div_subjectcode2_'+row).show();
    }
    if(ld('#span_subjectsummary_'+row) != undefined){
        ld('#span_subjectsummary_'+row).hide();
    }
    if(ld('#div_subjectsummary_'+row) != undefined){
        ld('#div_subjectsummary_'+row).show();
    }
    if(ld('#span_subjectsummary2_'+row) != undefined){
        ld('#span_subjectsummary2_'+row).hide();
    }
    if(ld('#div_subjectsummary2_'+row) != undefined){
        ld('#div_subjectsummary2_'+row).show();
    }
    if(ld('#btn_edit_'+row) != undefined){
        ld('#btn_edit_'+row).hide();
    }
    if(ld('#btn_save_'+row) != undefined){
        ld('#btn_save_'+row).show();
    }
}

function vtlib_savemodulename(row){
    var expensedetailid = document.getElementById("span_subjectcode_"+row).attributes["tag"].value; 

    var subjectcode=document.getElementById('subjectcode_'+row).value;
    var subjectsummary=document.getElementById('subjectsummary_'+row).value;
    var subjectcode2=document.getElementById('subjectcode2_'+row).value;
    var subjectsummary2=document.getElementById('subjectsummary2_'+row).value;
       
    var data = "module=Customreport&action=CustomreportAjax&file=SaveIndirectReportDetail&subjectcode=" +subjectcode + "&subjectsummary="+subjectsummary+"&subjectcode2="+subjectcode2+"&subjectsummary2="+subjectsummary2+"&expensedetailid="+expensedetailid+"&ajax=true";
    vtlib_cancelmodulename(row);
    
    $("status").style.display="inline";
    
    new Ajax.Request(
	  'index.php',
        {queue: {position: 'end', scope: 'command'},
    	   method: 'post',
            postBody: data,
            onComplete: function(response) {
                if(response.responseText.indexOf('SUCCESS')>-1){
                   $('status').hide();
                    document.getElementById('span_subjectsummary_'+row).innerHTML = subjectsummary;
                    document.getElementById('span_subjectcode_'+row).innerHTML = subjectcode;
                    document.getElementById('span_subjectsummary2_'+row).innerHTML = subjectsummary2;
                    document.getElementById('span_subjectcode2_'+row).innerHTML = subjectcode2;
                }else if(response.responseText.indexOf('USEDEN')>-1)
               {
                   alert(arrJsPopLabel['Savefailed']);
                   $('status').hide();
                }
            }
	  }
   );
}

function vtlib_cancelmodulename(row){
    if(ld('#span_subjectcode_'+row) != undefined){
            ld('#span_subjectcode_'+row).show();
        }
        if(ld('#div_subjectcode_'+row) != undefined){
            ld('#div_subjectcode_'+row).hide();
        }
        if(ld('#span_subjectcode2_'+row) != undefined){
            ld('#span_subjectcode2_'+row).show();
        }
        if(ld('#div_subjectcode2_'+row) != undefined){
            ld('#div_subjectcode2_'+row).hide();
        }
        if(ld('#span_subjectsummary_'+row) != undefined){
            ld('#span_subjectsummary_'+row).show();
        }
        if(ld('#div_subjectsummary_'+row) != undefined){
            ld('#div_subjectsummary_'+row).hide();
        }
        if(ld('#span_subjectsummary2_'+row) != undefined){
            ld('#span_subjectsummary2_'+row).show();
        }
        if(ld('#div_subjectsummary2_'+row) != undefined){
            ld('#div_subjectsummary2_'+row).hide();
        }
        if(ld('#btn_edit_'+row) != undefined){
            ld('#btn_edit_'+row).show();
        }
        if(ld('#btn_save_'+row) != undefined){
            ld('#btn_save_'+row).hide();
        }
}