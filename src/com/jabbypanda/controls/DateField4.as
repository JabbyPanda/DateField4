package com.jabbypanda.controls {
    
    import com.jabbypanda.events.ItemEditEvent;
    import com.jabbypanda.utils.DateUtil;
    import com.jabbypanda.validators.DateI18nValidator;
    
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    
    import mx.controls.DateField;
    import mx.core.FlexVersion;
    import mx.core.mx_internal;
    import mx.events.CalendarLayoutChangeEvent;
    import mx.events.FlexEvent;
    import mx.formatters.DateFormatter;
    import mx.validators.DateValidator;
        
    use namespace mx_internal;
    
    [ResourceBundle("validators")]
    [ResourceBundle("SharedResources")]
    
    [Event(name='itemDataChange', type='com.jabbypanda.events.ItemEditEvent')]
    public class DateField4 extends DateField {
        
        protected var dateFormatter : DateFormatter;
        
        protected var dateValidator : DateValidator;
        
        public function DateField4() {
            super();
            
            // Allow manual text date input.
            editable = true;
            
            height = 20;
            
            labelFunction = displayDate;
            parseFunction = DateUtil.parseStringToDate;
                                    
            this.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
            this.addEventListener(FlexEvent.ENTER, onEnterKeyPressed);
            this.addEventListener(CalendarLayoutChangeEvent.CHANGE, onChangeDate);
        }
        
        public function get autoShowDropDown() : Boolean {
            return _autoShowDropDown;
        }
                
        public function set autoShowDropDown(value : Boolean) : void {
            _autoShowDropDown = value;
            _autoShowDropDownChanged = true;
            invalidateProperties();
        }
        
        override public function set formatString(value:String):void {
            super.formatString = value;
            
            if (!dateFormatter) {
                dateFormatter = new DateFormatter();                
            }
            
            dateFormatter.formatString = value;
            
            if (!dateValidator) {
                dateValidator = createDateValidator();                
            }
            
            dateValidator.inputFormat = formatString;
            
            restrict = DateUtil.getAllowedDateInputChars(formatString);
        }
                
        override protected function measure():void
        {
            // skip base class, we do our own calculation here
            // super.measure();
            
            var buttonWidth:Number = downArrowButton.getExplicitOrMeasuredWidth();
            var buttonHeight:Number = downArrowButton.getExplicitOrMeasuredHeight();
            
            var bigDate:Date = new Date(2004, 12, 31);
            var txt:String = (labelFunction != null) ? labelFunction(bigDate) : 
                dateToString(bigDate, formatString);
            
            measuredMinWidth = measuredWidth = measureText(txt).width + 15 + buttonWidth;
            measuredMinWidth = measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
            measuredMinHeight = measuredHeight = textInput.getExplicitOrMeasuredHeight();
        }
        
        override public function open() : void {
            _lastSelectedDate = selectedDate;
            super.open();
        }
        
        override protected function commitProperties():void {
            super.commitProperties();
            
            if (_autoShowDropDownChanged) {
                _autoShowDropDownChanged = false;
            }    
        }
        
        override protected function createChildren():void {
            super.createChildren();            
                                    
            textInput.addEventListener(Event.CHANGE, onTextInputChange);
        }
        
        override protected function textInput_changeHandler(event : Event) : void {
            super.textInput_changeHandler(event);            
            
            if (selectedDate) {
                dropdown.selectedDate = selectedDate;
            }            
        }
        
        override protected function keyDownHandler(event : KeyboardEvent) : void {
            if (event.keyCode == Keyboard.DELETE || 
                event.keyCode == Keyboard.BACKSPACE ||
                event.keyCode == Keyboard.SPACE ||
                event.keyCode == Keyboard.ENTER) {
                return;
            } 
                        
            if (event.keyCode == Keyboard.ESCAPE) {
                selectedDate = _lastSelectedDate;                
                close();
                event.stopPropagation();
            } else {
                
                //display dropdown on key click if it not yet displayed
                if (!showingDropdown) {
                    open();
                    return;
                }
                                
                var currentCaretPosition : int = textInput.selectionAnchorPosition;
                
                if (currentCaretPosition == text.length && event.keyCode == Keyboard.RIGHT ||
                    currentCaretPosition == 0 && event.keyCode == Keyboard.LEFT ||
                    event.keyCode == Keyboard.UP  ||
                    event.keyCode == Keyboard.DOWN ||
                    event.keyCode == Keyboard.PAGE_UP ||
                    event.keyCode == Keyboard.PAGE_DOWN) {                    
                    super.keyDownHandler(event);
                }
            }                        
        }
        
        protected function onChangeDate(event : CalendarLayoutChangeEvent = null) : void {
            callLater(bubbleDataChange);    
        }
        
        protected function onTextInputChange(event : Event = null) : void {
            callLater(bubbleDataChange);    
        }
         
        private function bubbleDataChange() : void {
            dispatchEvent(
                new ItemEditEvent(ItemEditEvent.DATA_CHANGE, true)                    
            );
        }
        
        private function createDateValidator() : DateI18nValidator{
            var dateValidator : DateI18nValidator = new DateI18nValidator();
            dateValidator.source = this;
            dateValidator.property = "text";
            dateValidator.triggerEvent = "itemDataChange";
            dateValidator.inputFormat = formatString;
            
            return dateValidator;
        }
        
        private function displayDate(item : Date) : String {
            return dateFormatter.format(item);
        }
        
        private function resetTextSelection() : void {
            textInput.selectRange(0, 0);            
        }                
        
        private function onFocusIn(event : FocusEvent) : void {
            if (!showingDropdown && _autoShowDropDown) {
                open();
            }
            
            if (editable) {
                callLater(resetTextSelection);
            }
        }
        
        // dispatch CalendarLayoutChangeEvent.CHANGE when pressing keyboard ENTER key
        private function onEnterKeyPressed(event : FlexEvent) : void {                        
            if (showingDropdown) {                
                close();
            }
            
            var changeEvent:CalendarLayoutChangeEvent =
                new CalendarLayoutChangeEvent(CalendarLayoutChangeEvent.CHANGE);
            changeEvent.newDate = selectedDate;
            changeEvent.triggerEvent = event;
            dispatchEvent(changeEvent);
        }
        
                
        private var _lastSelectedDate : Date;
        
        private var _autoShowDropDown : Boolean = true;
        
        private var _autoShowDropDownChanged : Boolean;
    }
}