/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	config.bodyClass = 'wysiwygeditor';
	config.coreStyles_bold = { element : 'strong', overrides : 'b' };
	config.coreStyles_italic = { element : 'em', overrides : 'i' };

	config.contentsCss = ['/assets/wayground-all.css','/assets/wayground-screen.css'];
	config.docType = '<!DOCTYPE html>';

	config.disableNativeTableHandles = false;
	
	config.stylesSet = 'wayground:/javascripts/ckeditor_styles.js';
	config.toolbar = 'WaygroundToolbar';
	config.toolbar_WaygroundToolbar =
	[
	['Maximize','ShowBlocks','-','Source','-','Preview'], //,'-','Templates'],
	['Cut','Copy','Paste','PasteText','PasteFromWord','-','SpellChecker','Scayt'],
	['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
	//['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],
	'/',
	['Format','-','Blockquote','-','NumberedList','BulletedList'],
	['Image','Flash','Table','SpecialChar','PageBreak'],
	'/',
	['Link','Unlink','Anchor'],
	['Styles'],
	['Bold','Italic','Strike','-','Subscript','Superscript'],
	['About']
	];
};
