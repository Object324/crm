<?php
class ProductPriceBooksQuery extends QueryGenerator
{
    public function __construct($module, $user,$customview='') {
        
            parent::__construct($module, $user,$customview);
        }
     public function getScopeOfAuthority_obj($db,$module)
    {
        $this->scopeobj = null;
        
    }
}


?>