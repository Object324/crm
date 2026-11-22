/**
 *{*修改编码格式:统一编码：UTF-8*}
 * Convert a single file-input element into a 'multiple' input list
 *
 * Usage:
 *
 *   1. Create a file input element (no name)
 *      eg. <input type="file" id="first_file_element">
 *
 *   2. Create a DIV for the output to be written to
 *      eg. <div id="files_list"></div>
 *
 *   3. Instantiate a MultiSelector object, passing in the DIV and an (optional) maximum number of files
 *      eg. var multi_selector = new MultiSelector( document.getElementById( 'files_list' ), 3 );
 *
 *   4. Add the first element
 *      eg. multi_selector.addElement( document.getElementById( 'first_file_element' ) );
 *
 *   5. That's it.
 *
 *   You might (will) want to play around with the addListRow() method to make the output prettier.
 *
 *   You might also want to change the line 
 *       element.name = 'file_' + this.count;
 *   ...to a naming convention that makes more sense to you.
 * 
 * Licence:
 *   Use this however/wherever you like, just don't blame me if it breaks anything.
 *
 * Credit:
 *   If you're nice, you'll leave this bit:
 *  
 *   Class by Stickman -- http://www.the-stickman.com
 *      with thanks to:
 *      [for Safari fixes]
 *         Luis Torrefranca -- http://www.law.pitt.edu
 *         and
 *         Shawn Parker & John Pennypacker -- http://www.fuzzycoconut.com
 *      [for duplicate name bug]
 *         'neal'
 */
function MultiSelector( list_target, max ){
	var fieldtype = new Array('ext','bat','php','php3','php5','phtml','asp','aspx','ascx','jsp','cfm','cfc','pl','dll','reg','cgi');
	// Where to write the list
	this.list_target = list_target;
	// How many elements?
	this.count = 0;
	// How many elements?
	this.id = 0;
	// Is there a maximum?
	if( max ){
		this.max = max;
	} else {
		this.max = -1;
	};
	
	/**
	 * Add a new file input element
	 */
	this.addElement = function( element ){

		// Make sure it's a file input element
		if( element.tagName == 'INPUT' && element.type == 'file' ){

			// Element name -- what number am I?
           
			element.name = 'file_' + this.id++;
           // element.readOnly=true;
			// Add reference to this object
			element.multi_selector = this;
            //19728: IE8>客户>新建界面：身份证信息栏有多余文本框
            element.onkeydown=function()
            {
                return false;
            }
            element.onkeypress=function()
            {
                return false;
            }
            element.oncontextmenu=function()
            {
                return false;
            }
			// What to do when a file is selected
			element.onchange = function(){
				var fileinfo = element.value.split('.');
				if(document.EditView.module != undefined && (document.EditView.module.value == 'Contacts'||document.EditView.module.value == 'Users'||document.EditView.module.value == 'Products'))
				{
					if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(this.value))
					{
						alert(this.value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png、bmp、ico;');
						this.value = '';
						return false;
					}
				}
				if(fileinfo[1] == 'exe' || fileinfo[1] == 'bat'|| fileinfo[1] == 'php'|| fileinfo[1] == 'php3'|| fileinfo[1] == 'php5'|| fileinfo[1] == 'phtml'|| fileinfo[1] == 'asp'|| fileinfo[1] == 'aspx'|| fileinfo[1] == 'ascx'|| fileinfo[1] == 'jsp'|| fileinfo[1] == 'cfm'|| fileinfo[1] == 'cfc'|| fileinfo[1] == 'pl'|| fileinfo[1] == 'dll'|| fileinfo[1] == 'reg'|| fileinfo[1] == 'cgi')
				{
				    var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] + '\n' + element.value;
				    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					element.value = '';
					return false;
				}
				// New file input
				var new_element = document.createElement( 'input' );
				new_element.type = 'file';
                //new_element.readOnly =true;
				// Add new element
				this.parentNode.insertBefore( new_element, this );
				
				// Fix for: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/4876
				// SingleQuoted filename cannot be handled using $_FILES, we handle it through hidden field.
				// http://in.php.net/manual/en/features.file-upload.php#64087
				var new_element_hdn = null;
				if(typeof(element.form) != 'undefined') {
					new_element_hdn = element.form ["'" + this.name + '_hidden' + "'"];
				}
				if( new_element_hdn == null ) {
					new_element_hdn = document.createElement( 'input' );
					new_element_hdn.name = this.name + '_hidden';
					new_element_hdn.type = 'hidden';
					this.parentNode.insertBefore( new_element_hdn, this );
				}
				if(new_element_hdn.type == 'hidden') new_element_hdn.value = getFileNameOnly(this.value);
				// End

				// Apply 'update' to element
				this.multi_selector.addElement( new_element );

				// Update list
				this.multi_selector.addListRow( this );

				// Hide this: we can't use display:none because Safari doesn't like it
				this.style.position = 'absolute';
				this.style.left = '-1000px';

			};
			// If we've reached maximum number, disable input element
			if( this.max != -1 && this.count >= this.max ){
				element.disabled = true;
			};

			// File element counter
			this.count++;
			// Most recent element
			this.current_element = element;
			
		} else {
			// This can only be applied to file input elements!
			alert( 'Error: not a file input element' );
		};

	};

	/**
	 * Add a new row to the list of files
	 */
	this.addListRow = function( element ){

		// Row div
		var new_row = document.createElement( 'div' );
        new_row.className = 'marTB5';
		// Delete button
		var new_row_button = document.createElement( 'input' );
		new_row_button.type = 'button';
		//new_row_button.value = 'Delete';
        new_row_button.value = arrJsPopLabel['DELETE'];
		new_row_button.className = 'deletelist marL5';

		// References
		new_row.element = element;

		// Delete function
		new_row_button.onclick= function(){

			// Remove element from form
			this.parentNode.element.parentNode.removeChild( this.parentNode.element );

			// Remove this row from the list
			this.parentNode.parentNode.removeChild( this.parentNode );

			// Decrement counter
			this.parentNode.element.multi_selector.count--;

			// Re-enable input element (if it's disabled)
			this.parentNode.element.multi_selector.current_element.disabled = false;

			// Appease Safari
			//    without it Safari wants to reload the browser window
			//    which nixes your already queued uploads
			return false;
		};

		// Set row value
		new_row.innerHTML = element.value;

		// Add button
		new_row.appendChild( new_row_button );

		// Add it to the list
		this.list_target.appendChild( new_row );
		
	};

};