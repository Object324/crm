<?php
class StyleSet
{
    public $styleset_header = [];
    public $styleset_body = [];
    public function __construct()
    {
        $this->styleset_header = $_REQUEST['styleset_header'];
        $this->styleset_body = $_REQUEST['styleset_body'];
    }

    public function getstyleset_header($columnkey){
        return $this->styleset_header[$columnkey];//暂时用不到
    }
    public function getstyleset_body($columnkey){
        return $this->styleset_body[$columnkey];
    }
}