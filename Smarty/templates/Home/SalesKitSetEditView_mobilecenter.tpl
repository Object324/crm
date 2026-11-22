{*之后再改吧*}
<div class="ld_saleskitview_stuff ld_saleskitview_block_stuff" style="width:calc(100% / {$SALESKITLAYOUT.colcount} - 10px);margin:5px;overflow: hidden;">
    <div class="ld_saleskitstuff hover drag-handle j-toBiSale sort-tip-items" style="overflow: hidden;height: 90%;width: 95%;top: 5%;left: 0%;position: relative;cursor: pointer"
         data-tip="{$saleskitinfo.label}" data-direction="top" data-type="position" id="saleskitstuff_{$stufflabel}" data-stufflabel="{$stufflabel}">
        <div class="ld-saleskitview-block-stuff-close" data-stufflabel="{$stufflabel}"><i class="icon-close"></i></div>
        <div class="ld-stuff-item-header">
            <div class="ld-stuff-item-header-icon {$saleskitinfo.css}">
            </div>
            <div class="ld-stuff-item-header-title">
                {$saleskitinfo.label}
            </div>
        </div>
        <div class="ld-stuff-item-content">
            <div  class="ld-stuff-item-content-l">
                <div class="ld-stuff-item-c-l-t">
                    <div class="ld-stuff-item-c-label">{'THISPERIOD'|@getFixedLabel}
                        <span class="ld-stuff-item-c-data">0</span>
                    </div>
                </div>
                <div class="ld-stuff-item-c-l-b" {if $SALESKITLAYOUT.isshowprevious eq 'no'}style="display:none;"{/if}>
                    <div class="ld-stuff-item-c-label">{'PREVIOUSDATA'|@getFixedLabel}
                        <span class="ld-stuff-item-c-data">0</span>
                    </div>
                </div>
            </div>
            <div class="ld-stuff-item-content-r" {if $SALESKITLAYOUT.isshowprevious eq 'no'}style="display:none;"{/if}>
                <div class="ld-stuff-item-content-r-t">
                <b class="ld-stuff-item-c-percent ld-stuff-item-c-percent-up"></b>
                </div>
                <div class="ld-stuff-item-content-r-b">
                    <b class="ld-stuff-item-c-percent" style="color:rgb(255, 102, 0)">+100%</b>
                </div>
            </div>
        </div>
    </div>
</div>




