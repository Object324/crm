//创建派息单

function  NewDividendOrder(obj,divid,salesorderid){
    var results;
    var cur_this=this;
   
    //修改成ajax
   ld.ajax({
         url:"index.php",
         data:{'module':'DividendOrder','action':'PopDividendOrder','salesorderid':salesorderid,'ReportHeader':'DHeader'},
         type:'POST',
         success:function(response)
         {
         
            results=response;
            
            var resultsCon = results.split('##NORULES##');
            
            if(resultsCon.length > 1) {

                createElementDiv('Remind_dividendRules');//创建DIV
               ld('#Remind_dividendRulestitlename').html(resultsCon[resultsCon.length-1]);
                sethtml
                (
                    document.getElementById('Remind_dividendRulescontent'),
                    '<div class="divPeople-Title" >' + resultsCon[0] + '</div>'
                );
                if (resultsCon[1] == 'yes') {
                    //edit:can 20210726 047037: （https://51mis.com/hy/liu0712 [^]）金融行业演示账套-销售管理-派息单-派息单无法创建
                    ld('#Remind_dividendRules .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                        fninvshnew('Remind_dividendRules');
                        getJsScript('include/js/modules/Products/ProductsDividendRules.js',function(){
                            Products_dividendRules.getInstance().Rules_In_CreateDividendOrder(obj, 'SalesOrder', resultsCon[2]);
                        });
                    });
                    ld('#Remind_dividendRules .E_pbtn .E_pbtncancel').unbind('click').on('click', function () {
                        fninvshnew('Remind_dividendRules');
                    });
                } else if (resultsCon[1] == 'no') {
                    ld('#Remind_dividendRules .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                        fninvshnew('Remind_dividendRules');
                    });
                    ld('#Remind_dividendRules .D_pbtn .D_pbtncancel').css('display', 'none');
                    return false;
                }
                
                
            }else{
                ld("#DividendOrder_form_div").html(results);
                fnvshobj(obj,divid);
              //  cur_this.triggerBind(obj,divid,salesorderid);
            
            }
            
         }
    
   });
   
    
}
	/*ld('#D_pbtncancel,#colose_create_dividend').click(function(){
		fninvshnew(divid);
	});*/
