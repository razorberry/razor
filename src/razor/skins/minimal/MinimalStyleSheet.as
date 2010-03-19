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

package razor.skins.minimal
{
	import razor.controls.Button;
	import razor.controls.Label;
	import razor.controls.grid.SelectableCell;
	import razor.core.tooltips.BasicTooltip;
	import razor.skins.StyleSheet;
	
	public class MinimalStyleSheet extends StyleSheet
	{
		public var Background:StyleSheet = new StyleSheet(null, MinimalRectangle,
			{ Over: new StyleSheet({modifyBrightness: 0.05}, MinimalRectangle),
			  Down: new StyleSheet({modifyBrightness: -0.05}, MinimalRectangle),
			  Disabled: new StyleSheet({fade: 50}, MinimalRectangle)
			});
		public var Label:StyleSheet = new StyleSheet(null, ClassRefs.labelClass);
		public var ListCell:StyleSheet = new StyleSheet(null, ClassRefs.cellClass);
		public var Arrow:StyleSheet = new StyleSheet(null, ClassRefs.arrowClass);
		public var Check:StyleSheet = new StyleSheet(null, ClassRefs.checkClass);
		public var Radio:StyleSheet = new StyleSheet(null, ClassRefs.radioClass);
		public var ToolTip:StyleSheet = new StyleSheet(null, BasicTooltip);
		public var UpButton:StyleSheet = new StyleSheet(null, Button);
		public var DownButton:StyleSheet = new StyleSheet(null, Button);
		public var Thumb:StyleSheet = new StyleSheet(null, Button);
	}
}
import razor.controls.Label;
import razor.controls.grid.SelectableCell;
import razor.graphics.*;

internal class ClassRefs
{
	public static var labelClass:Class = Label;
	public static var cellClass:Class = SelectableCell;
	public static var arrowClass:Class = Arrow;
	public static var checkClass:Class = Check;
	public static var radioClass:Class = Radio;
}