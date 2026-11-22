/**
edit:can
reason:富文本框
**/
function RichKinde(ockEditor,textAreaname)
{
    this.ockEditor=ockEditor;
    this.textAreaname=textAreaname;
   
}

RichKinde.prototype.richclick=function(textAreaname,ockEditor)
{
    
   document.getElementById('Rich'+textAreaname).onclick=function()
            {
                 
                       
                    OpenRichTextTemplate(textAreaname,ockEditor);
            }
}

