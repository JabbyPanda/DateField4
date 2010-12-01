package com.jabbypanda.validators {
    
    import com.jabbypanda.utils.DateUtil;
    
    import mx.formatters.DateFormatter;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.utils.ObjectUtil;
    import mx.utils.StringUtil;
    import mx.validators.DateValidator;
    import mx.validators.ValidationResult;
        
    public class DateRangeValidator extends DateValidator {        

        public static const MIN_YEAR_VALUE : int = 1900;
        
        public static const MAX_YEAR_VALUE : int = 9999;
        
        public function DateRangeValidator() {
            super();
        }
        
        public function get minValue() : Date {
            return _minValue;
        }
        
        public function set minValue(value:Date):void {         
            _minValue = value; 
        }
        
        public function get maxValue() : Date {
            return _maxValue;
        }
        
        public function set maxValue(value : Date) : void {         
            _maxValue = value; 
        }
        
        private var _exceedsMaxErrorOverride:String;
        
        [Inspectable(category="Errors", defaultValue="max error")]
        public function get exceedsMaxError() : String {
            return _exceedsMaxError;
        }
        
        
        public function set exceedsMaxError(value:String):void {
            _exceedsMaxErrorOverride = value;            
            
            _exceedsMaxError = value != null ?
                value : resourceManager.getString(
                    "OdysseyValidators", "exceedsMaxDateError");
        }
        
        private var _lowerThanMinErrorOverride : String;
        
        [Inspectable(category="Errors", defaultValue="min error")]
        public function get lowerThanMinError() : String {
            return _lowerThanMinError;
        }
        
        public function set lowerThanMinError(value : String) : void {            
            _lowerThanMinErrorOverride = value;
            
            _lowerThanMinError = value != null ?
                value :
                resourceManager.getString(
                    "OdysseyValidators", "lowerThanMinDateError");
        }
        
        // accepts only values of String or Date types
        public static function validateDateRange(validator : DateRangeValidator,
                                                 value : Object,
                                                 baseField : String):Array {
            var results:Array = [];
                        
            // Resource-backed properties of the validator.
            var allowedFormatChars:String = validator.allowedFormatChars;
            var inputFormat:String = validator.inputFormat;            
            
            var resourceManager:IResourceManager = ResourceManager.getInstance();
            
            var validInput:String = DECIMAL_DIGITS + allowedFormatChars;
            
            var maxValue:Date = validator.maxValue;
            var minValue:Date = validator.minValue;
                        
            var dayProp:String = baseField;
            var yearProp:String = baseField;
            var monthProp:String = baseField;
            
            var advanceValueCounter:Boolean = true;
            var monthRequired:Boolean = false;
            var dayRequired:Boolean = false
            var yearRequired:Boolean = false;           
            var foundMonth:Boolean = false;
            var foundYear:Boolean = false;
            
            var objValue:Object;
            var stringValue : String;            
            
            var n:int;
            var i:int;
            var temp:String;
            
            if (value is String) {
                stringValue = String(value)
            } else {
                stringValue = (value as Date).toDateString();
            }
            
            // Check each character to see if it is allowed.
            n = stringValue.length;            
            for (i = 0; i < n; i++) {                                
                if (validInput.indexOf(stringValue.charAt(i)) == -1) {
                    results.push(new ValidationResult(
                        true, baseField, "invalidChar",
                        validator.invalidCharError));
                    return results;
                }                
            }
            
            var validDateStringResult : ValidationResult = DateRangeValidator.validateFormatString(
                validator, inputFormat, baseField);
            
            //Check format string itself
            if (validDateStringResult != null) {
                results.push(validDateStringResult);                    
                return results;    
            }
            
            if (value is String) {                                
                objValue = DateUtil.parseStringToObject(stringValue, inputFormat);
            } else if (value is Date) {                
                var date:Date = value as Date;
                objValue = {year: date.fullYear,
                    month: date.month + 1,
                    day: date.date};
            } 
            
            if (!objValue) {
                if (validator.required) {
                    results.push(new ValidationResult(
                        true, baseField, "wrongLength", 
                        validator.wrongLengthError + " " +
                        inputFormat));
                }
                return results;
            }
                        
            var baseFieldDot:String = baseField ? baseField + "." : "";
            dayProp = baseFieldDot + "day";
            yearProp = baseFieldDot + "year";
            monthProp = baseFieldDot + "month";
            
            if (isNaN(objValue.month)) {
                results.push(new ValidationResult(
                    true, monthProp, "wrongMonth",
                    validator.wrongMonthError));
            } else if (validator.required && (!objValue.month || objValue.month == "")) {
                results.push(new ValidationResult(
                    true, monthProp,"requiredField",
                    validator.requiredFieldError));
            } else {
                monthRequired = true;
            }
            
            if (isNaN(objValue.year)) {
                results.push(new ValidationResult(
                    true, yearProp, "wrongYear",
                    validator.wrongYearError));
            } else if (validator.required && (!objValue.year || objValue.year == "")) {
                results.push(new ValidationResult(
                    true, yearProp, "requiredField",
                    validator.requiredFieldError));
            } else {
                yearRequired = true;
            }
            
            var dayMissing : Boolean = (!objValue.day || objValue.day == "");
            var dayInvalid : Boolean = dayMissing || isNaN(objValue.day);
            var dayWrong : Boolean = !dayMissing && isNaN(objValue.day);
            var dayOptional : Boolean = yearRequired && monthRequired;			
            
            
            // Day is not optional and is NaN.
            if (!dayOptional || dayWrong) {
                results.push(new ValidationResult(
                    true, dayProp, "wrongDay",
                    validator.wrongDayError));
            }
            // The day is valid (a number).
            else if (!dayInvalid) {
                dayRequired = true;
            }
            // If the validator is required and there is no day specified			
            else if (validator.required && dayMissing) {
                results.push(new ValidationResult(
                    true, dayProp, "requiredField",
                    validator.requiredFieldError));
            }
                                                  
            var len : Number = stringValue.length;
            // 2 - maximum length of separators
            if (len + 2 < inputFormat.length) {
                results.push(new ValidationResult(
                    true, baseField, "wrongLength",
                    validator.wrongLengthError + " " + inputFormat));
                return results;
            }
                                    
            if (results.length > 0) {
                return results;
            }
            
            var monthNum:Number = Number(objValue.month);
            var dayNum:Number = Number(objValue.day);
            var yearNum:Number = Number(objValue.year).valueOf();
            
            if (monthNum > 12 || monthNum < 1) {
                results.push(new ValidationResult(
                    true, monthProp, "wrongMonth",
                    validator.wrongMonthError));
                return results;
            }
            
            var maxDay:Number = 31;
            
            if (monthNum == 4 || monthNum == 6 ||
                monthNum == 9 || monthNum == 11) {
                maxDay = 30;
            } else if (monthNum == 2) {
                if (yearNum % 4 > 0) {
                    maxDay = 28;
                } else if (yearNum % 100 == 0 && yearNum % 400 > 0) {
                    maxDay = 28;
                } else {
                    maxDay = 29;
                }
            }
            
            if (dayRequired && (dayNum > maxDay || dayNum < 1)) {
                results.push(new ValidationResult(
                    true, dayProp, "wrongDay",
                    validator.wrongDayError));
                return results;
            }
            
            if (yearRequired && (yearNum > MAX_YEAR_VALUE || yearNum < MIN_YEAR_VALUE)) {
                results.push(new ValidationResult(
                    true, yearProp, "wrongYear",
                    validator.wrongYearError));
                return results;
            } 
            
            if (minValue) {                        
                var minValidatonResultObj : ValidationResult = validateMinValue(validator, minValue, objValue);
                if (minValidatonResultObj) {
                    results.push(minValidatonResultObj);
                    return results;
                }
            }
            
            if (maxValue) {
                var maxValidatonResultObj : ValidationResult = validateMaxValue(validator, maxValue, objValue);
                if (maxValidatonResultObj) {
                    results.push(maxValidatonResultObj);
                    return results;
                }
            }
            
            return results;
        }
                
        private static function validateMinValue(validator : DateRangeValidator, minValue : Date, objValue : Object) : ValidationResult {
            var dateValue : Date = new Date(objValue.year, objValue.month - 1, objValue.day);
            var minValueWithoutDayTime : Date = new Date(minValue.fullYear, minValue.month, minValue.date);
            if (ObjectUtil.dateCompare(minValueWithoutDayTime, dateValue) == 1) {                
                return new ValidationResult(
                    true, null, "lowerThanMin",
                    validator.lowerThanMinError);                    
            }                
            return null;                                    
        }
        
        private static function validateMaxValue(validator : DateRangeValidator, maxValue : Date, objValue : Object) : ValidationResult {
            var dateValue : Date = new Date(objValue.year, objValue.month - 1, objValue.day);
            var maxValueWithoutDayTime : Date = new Date(maxValue.fullYear, maxValue.month, maxValue.date);
            if (ObjectUtil.dateCompare(dateValue, maxValueWithoutDayTime) == 1) {                
                return new ValidationResult(
                    true, null, "exceedsMax",
                    validator.exceedsMaxError);                    
            }
            
            return null;
        }
        
        /**
         *  @private
         */
        private static function validateFormatString(
            validator:DateRangeValidator,
            format:String,
            baseField:String):ValidationResult {
            var monthCounter:Number = 0;
            var dayCounter:Number = 0;
            var yearCounter:Number = 0;
            
            var n:int = format.length;
            for (var i:int = 0; i < n; i++) {
                var mask:String = "" + format.substring(i, i + 1);
                
                // Check for upper and lower case to maintain backwards compatibility.
                if (mask == "m" || mask == "M") {
                    monthCounter++;
                } else if (mask == "d" || mask == "D") {
                    dayCounter++;
                } else if (mask == "y" || mask == "Y") {
                    yearCounter++;
                }
            }
            
            if ((monthCounter == 2 || monthCounter == 1 &&
                (yearCounter == 2 || yearCounter == 4)) ||
                ((monthCounter == 2 || monthCounter == 1) && 
                 (dayCounter == 2 || dayCounter == 1) &&
                 (yearCounter == 0 || yearCounter == 2 || yearCounter == 4))) {
                return null; // Passes format validation
            } else {
                return new ValidationResult(
                    true, baseField, "format",
                    validator.formatError);
            }
        }
        
        override protected function resourcesChanged() : void {
            super.resourcesChanged();
            
            lowerThanMinError = _lowerThanMinErrorOverride;
            exceedsMaxError = _exceedsMaxErrorOverride;
        }
        
        private var _minValue : Date;
        
        private var _maxValue : Date;
        
        private var _exceedsMaxError : String;
        
        private var _lowerThanMinError : String;
        
    }
}