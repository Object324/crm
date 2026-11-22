if( typeof( dtlViewAjaxSave )!="undefined")
{
    dtlViewAjaxSave.afterOperation=function (fieldName)
        {
           
            if(fieldName=='amount'||fieldName=='possibility')
            {
                if(document.getElementById('dtlview_cf_1308')!=undefined)
                {
                     if(fieldName=='amount')
                            var  amount=parseFloat(document.getElementById('txtbox_amount').value).toFixed(2);
                     else
                        var amount=parseFloat(ld('#dtlview_amount').text()).toFixed(2);
                     
                    if(document.getElementById('possibility')!=undefined&&document.getElementById('dtlview_amount')!=undefined)
                    {
                        var possible=document.getElementById('possibility').options[document.getElementById('possibility').selectedIndex].value;
                      
                        possible=parseFloat(possible).toFixed(2);
                        
                        ld('#dtlview_cf_1308').text(parseFloat(amount*possible/100).toFixed(2));
                        document.getElementById('txtbox_cf_1308').value=parseFloat(amount*possible/100).toFixed(2);
                            //=amount*document.getElementById('possibility').options[document.getElementById('possibility').selectedIndex].value/100;
                            
                        
                    }
                }
            }
        }
}
//else
//{
    if(document.getElementById('possibility')!=undefined)
    {
        document.getElementById('possibility').onchange=function()
        {
            setbudgetValue();
        }
    }
    
    if(document.getElementById('txtbox_amount')!=undefined)
    {
        document.getElementById('txtbox_amount').onchange=function()
        {
            setbudgetValue();
        }
    }
    function setbudgetValue()
    {
        if(document.getElementById('txtbox_cf_1308')!=undefined)
        {
            var amount= parseFloat(document.getElementById('txtbox_amount').value).toFixed(2);
             var possible=document.getElementById('possibility').options[document.getElementById('possibility').selectedIndex].value;
             possible=parseFloat(possible).toFixed(2);
            
            document.getElementById('txtbox_cf_1308').value=parseFloat(amount*possible/100).toFixed(2);
        }
        
    }
//}

