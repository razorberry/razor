/*****************************************************************************
* Razor Component Framework for ActionScript 3.
* Copyright 2009 Ashley Atkins (www.razorberry.com)
* 
* This file is part of the Razor Component Framework, which is made available
* under the MIT License.
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*******************************************************************************/

package razor.controls
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	
	/**
	 * Dispatched when the label content changes.
	 * @eventType razor.controls.Label.E_CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * Dispatched when enter is pressed in an editable label.
	 * @eventType razor.controls.Label.E_ENTER
	 */
	[Event(name="enter", type="flash.events.Event")]
	
	/**
	 * Dispatched when the label is scrolled.
	 * @eventType razor.controls.Label.E_SCROLL
	 */
	[Event(name="scroll", type="flash.events.Event")]
	
	/**
	* Base class for a styled label.
	* @example
	* <listing version="3.0">
	* var myLabel:Label = addChild(new Label());
	* label.autoSize = TextFieldAutoSize.LEFT;
	* label.html = true;
	* label.text = "Some <b>label</b> text.";
	* </listing>
	*/
	public class Label extends StyledContainer
	{
		use namespace razor_internal;
		
		public static const E_CHANGE:String = Event.CHANGE;
		public static const E_ENTER:String = "enter";
		public static const E_SCROLL:String = Event.SCROLL;
		
		/** @private */ override protected function getClass():String { return "Label"; }
		
		/** @private */ protected var _input:Boolean = false;
		/** @private */ protected var _wordWrap:Boolean = false;
		/** @private */ protected var _html:Boolean = false;
		
		/** A reference to the internal text field of this label
		 * @private
		 */
		public var textField:TextField;
	
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Focus this label
		 * TODO: Formalize this
		 */
		public function focus():void
		{
			if (stage)
			stage.focus = textField;
		}
		
		/**
		* Get/set the current text.
		* @param	str		A string to set the current contents to.
		*/
		public function set text(str:String):void
		{
			if (str == null) str = "";
			
			if (_html)
				textField.htmlText = str;
			else
				textField.text = str;
			
			onTFSet();
		}
		
		/** @private */
		public function get text():String
		{
			if (_html)
				return textField.htmlText;
			else
				return textField.text;
		}
		
		/**
		 * Get/set whether this label is editable by the user.
		 * @param	b	A boolean indicating whether this label is editable.
		 * @default false
		 */
		public function set editable(b:Boolean):void
		{
			_input = b;
			textField.type = _input ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			mouseChildren = b || textField.selectable;
			textField.mouseEnabled = b || textField.selectable;
		}
		
		/** @private */
		public function get editable():Boolean
		{
			return _input;
		}
		
		/**
		 * Get/set whether this label is selectable by the user.
		 * @param	b	A boolean indicating whether this label is selectable.
		 * @default true
		 */
		public function set selectable(b:Boolean):void
		{
			textField.selectable = b;
			mouseChildren = b || _input;
			textField.mouseEnabled = b || _input;
		}
		
		/** @private */
		public function get selectable():Boolean
		{
			return textField.selectable;
		}
		
		/**
		 * Set the current selection.
		 * @param	first	The index of the first character to select
		 * @param	last	The index+1 of the last character to select
		 */
		public function setSelection(first:int, last:int = -1):void
		{
			textField.setSelection(first, last >= 0 ? last : first);
		}
		
		/**
		 * Get/set whether this label renders text as HTML.
		 * @param	b	A boolean indicating whether the text will render as HTML.
		 * @default false
		 */
		public function set html(b:Boolean):void
		{
			var t:String = text;
			_html = b;
			text = t;
		}
		
		/** @private */
		public function get html():Boolean
		{
			return _html;
		}
		
		/**
		 * Get/set whether the text will wrap at the end of the label.
		 * @param	b	A boolean indicating the wordwrap setting.
		 * @default false
		 */
		public function set wordWrap(b:Boolean):void
		{
			_wordWrap = b;
			textField.wordWrap = b;
			doLayout();
		}
		
		/** @private */
		public function get wordWrap():Boolean
		{
			return _wordWrap;
		}
		
		/**
		 * Get/set whether this label will render multiple lines of text.
		 * @param	b	A boolean indicating the multiline setting.
		 * @default false
		 */
		public function set multiline(b:Boolean):void
		{
			textField.multiline = b;
		}
		
		/** @private */
		public function get multiline():Boolean
		{
			return textField.multiline;
		}
		
		/**
		* Get the current length of the content.
		* @return	The length of the current text string.
		*/
		public function get length():int
		{
			return textField.length;
		}
		
		/**
		* Set the current input restrictions on this label.
		* @see TextField#restrict
		* @param	str		A string representing the current input restrictions.
		*/
		public function set restrict(str:String):void
		{
			textField.restrict = str == "" ? null : str;
		}
		
		/** @private */
		public function get restrict():String
		{
			return textField.restrict;
		}
		
		/**
		* Get/set the maximum number of characters allowed to be input into this label.
		* @param	n	The number of characters.
		*/
		public function set maxChars(n:int):void
		{
			textField.maxChars = n;
		}
		
		/** @private */
		public function get maxChars():int
		{
			return textField.maxChars;
		}
		
		/**
		 * Get/set whether this label will render as a password field.
		 * @param	b	A boolean representing the password setting.
		 * @default false
		 */
		public function set password(b:Boolean):void
		{
			textField.displayAsPassword = b;
		}
		
		/** @private */
		public function get password():Boolean
		{
			return textField.displayAsPassword;
		}
		
		/**
		 * Get/set whether this label will embed fonts.
		 * @param	b	A boolean representing whether to embed fonts.
		 * @default false
		 */
		public function set embedFonts(b:Boolean):void
		{
			textField.embedFonts = b;
			sharpText = true; // TODO: don't do this by default
		}
		
		/** @private */
		public function get embedFonts():Boolean
		{
			return textField.embedFonts;
		}
		
		/**
		 * Get/set whether this label has a border.
		 * @param	b	A boolean representing whether to show a border.
		 * @default false
		 */
		public function set border(b:Boolean):void
		{
			textField.border = b;
		}
		
		/** @private */
		public function get border():Boolean
		{
			return textField.border;
		}
		
		/**
		 * Get/set the align of this label. Setting this will affect the attached Style object.
		 * @param	str		The align string, "left", "center", or "right".
		 * @default left
		 */
		public function set align(str:String):void
		{
			__style.align = str;
			doLayout();
		}
		
		/** @private */
		public function get align():String
		{
			return __style.textFormat.align;
		}
		
		/**
		 * Get/set whether this label should automatically size to the text.
		 * @see TextField#autoSize
		 * @param	str		The current autoSize setting.
		 * @default none
		 */
		[Inspectable(enumeration="none,left,center,right")]
		public function set autoSize(str:String):void
		{
			textField.autoSize = str;
			doLayout();
		}
		
		/** @private */
		public function get autoSize():String
		{
			return textField.autoSize;
		}
		
		public function set sharpText(b:Boolean):void
		{
			if (b)
			{
				textField.antiAliasType = AntiAliasType.ADVANCED;
				textField.sharpness = 100;
				textField.gridFitType = GridFitType.PIXEL;
			}
			else
			{
				textField.antiAliasType = AntiAliasType.NORMAL;
			}
		}
		
		/**
		* Get the current height of the text in this label.
		* @return	The current text height (in px).
		*/
		public function get textHeight():Number
		{
			return textField.textHeight;
		}
		
		/**
		* Get the current width of the text in this label.
		* @return	The current text width (in px).
		*/
		public function get textWidth():Number
		{
			return textField.textWidth;
		}
		
		/**
		public function getTextBounds():Metrics
		{
			var m:Metrics = new Metrics(0,textField.textHeight - 4,textField.textWidth,0,2,textField.textHeight - 2);
			for (var i:int = 0; i < textField.numLines; i++)
			{
				var l:TextLineMetrics = textField.getLineMetrics(i);
				m.width = Math.max(m.width, l.width);
				m.l = Math.min(m.l, l.x);
				m.r = Math.max(m.r, l.x+l.width);
			}
			return m;
		}
		*/
		
		/**
		* Associate a StyleSheet with this label. Setting this will override any Style settings.
		* @param	s	A StyleSheet instance.
		*/
		public function set styleSheet(s:StyleSheet):void
		{
			textField.styleSheet = s;
		}
		
		/** @private */
		public function get styleSheet():StyleSheet
		{
			return textField.styleSheet;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			textField = createTF();
			addChild(textField);
			sharpText = __style.sharpText;
			mouseChildren = false;
			mouseEnabled = false;
			textField.mouseEnabled = false;
		}
		
		/** @private */
		override protected function layout():void
		{
			var tt:String;
			// Preserve html formatting
			if (_html)
				tt = textField.htmlText;
			
			if (!textField.styleSheet)
			{
				var tf:TextFormat = __style.textFormat;
				textField.defaultTextFormat = tf;
				textField.setTextFormat(tf);
				
				//if (tf.font.charAt(0) == "_")
				//embedFonts = true;
			}
			
			if (_html)
				textField.htmlText = tt;
			else
				textField.text = textField.text;
			
			var a:String = textField.autoSize;
			if (a == null || a == TextFieldAutoSize.NONE || a == TextFieldAutoSize.CENTER)
			{
				textField.width = __width;
				
				if (_wordWrap)
					__height = textField.height;
				else
					textField.height = __height;
			}
			else  // autoSize is left or right
			{
				__width = textField.width;
				__height = textField.height;
			}
			textField.x = 0;
			textField.y = 0;
		}
		
		/**
		 * Create the internal text field.
		 */
		protected function createTF():TextField
		{
			var tf:TextField = new TextField();
			var tfm:TextFormat = __style.textFormat;
			tf.defaultTextFormat = tfm;
			//tf.setTextFormat(tfm);
			tf.type = _input ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			tf.wordWrap = _wordWrap;
			tf.multiline = true;
			tf.embedFonts = __style.embedFonts;
			//tf.border = true;
			tf.addEventListener(Event.CHANGE, onTFChanged);
			tf.addEventListener(FocusEvent.FOCUS_IN, onTFSetFocus);
			tf.addEventListener(FocusEvent.FOCUS_OUT, onTFKillFocus);
			tf.addEventListener(Event.SCROLL, onTFScroll);
			return tf;
		}
		
		// Textfield listeners:
		/**
		 * Called when the text field dispatches a change event.
		 * @private
		 */
		protected function onTFChanged(e:Event):void
		{
			doLayout();
			
			dispatchEvent(new Event(E_CHANGE));
		}
		
		/**
		 * Called when the text field dispatches a scroll event.
		 * @private
		 */
		private function onTFScroll(e:Event):void
		{
			onFieldScroll();
		}
		
		/**
		 * Act on a text field scroll.
		 */
		protected function onFieldScroll(target:TextField = null):void
		{
			dispatchEvent(new Event(E_SCROLL));
		}
		
		/**
		 * Called when enter is pressed in the text field.
		 * @see #onKeyDown
		 */
		private function onTFEnter():void
		{
			dispatchEvent(new Event(E_ENTER));
		}
		
		/**
		 * Called when the text field receives focus.
		 */
		private function onTFSetFocus(e:FocusEvent):void
		{
			//onSetFocus();
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		/**
		 * Called when the text field loses focus.
		 */
		private function onTFKillFocus(e:FocusEvent):void
		{
			//onKillFocus();
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		/**
		 * Called when the text in the field is set.
		 */
		protected function onTFSet():void
		{
			doLayout();
		}
		
		/**
		 * Called when the text field has focus and a key is pressed.
		 */
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
	    	{
	      		onTFEnter();
	    	}
		}
		
		override public function getPreferredMetrics() : Metrics
		{
			return new Metrics(Math.max(__width, textField.width), Math.max(__height, textField.height));
		}
		
		override protected function onStyleChange(evOb:RazorEvent=null) : void
		{
			super.onStyleChange(evOb);
			
			if (__initialized && textField)
			textField.setTextFormat(__style.textFormat);
		}
	}
}