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

package razor.skins.plastic
{
	import razor.skins.StyleSheet;
	import razor.skins.plastic.stylesheets.*;
	
	public class PlasticStyleSheet extends StyleSheet
	{
		public var Arrow:StyleSheet = new ArrowStyles();
		public var Background:StyleSheet = new BackgroundStyles();
		public var Button:StyleSheet = new ButtonStyles();
		public var Calendar:StyleSheet = new CalendarStyles();
		public var CheckBox:StyleSheet = new CheckBoxStyles();
		public var AccordionPane:StyleSheet = new AccordionPaneStyles();
		public var ColorPicker:StyleSheet = new ColorPickerStyles();
		public var ColorSwatch:StyleSheet; // inherited
		public var ComboBox:StyleSheet = new ComboBoxStyles();
		public var DateChooser:StyleSheet = new DateChooserStyles();
		public var Label:StyleSheet = new LabelStyles();
		public var ListCell:StyleSheet = new ListCellStyles();
		public var Overlay:StyleSheet = new OverlayStyles();
		public var Pane:StyleSheet = new PaneStyles();
		public var ProgressBar:StyleSheet = new ProgressBarStyles();
		public var RadioButton:StyleSheet = new RadioButtonStyles();
		public var ScrollBar:StyleSheet = new ScrollBarStyles();
		public var TextArea:StyleSheet; // inherited
		public var TextInput:StyleSheet = new TextInputStyles();
		public var ToolTip:StyleSheet = new TooltipStyles();
	}
	
}