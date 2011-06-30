package com.jabbypanda.validators {
    
    import com.jabbypanda.utils.DateUtil;
    
    import mx.formatters.DateFormatter;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.utils.ArrayUtil;
    import mx.utils.ObjectUtil;
    import mx.utils.StringUtil;
    import mx.validators.DateValidator;
    import mx.validators.ValidationResult;
     
    [ResourceBundle("SharedResources")]
    [ResourceBundle("formatters")]
    [ResourceBundle("validators")]
    public class DateI18nValidator extends DateValidator {        
        
        public function DateI18nValidator() {
            super();
        }
        
        override protected function doValidation(value:Object):Array {
            return DateI18nValidator.validateDate(this, value, null);
        }
                
        // accepts only values of String or Date types
        public static function validateDate(validator : DateI18nValidator,
                                                 value : Object,
                                                 baseField : String):Array {
                        
            var results:Array = [];
                        
            // Resource-backed properties of the validator.            
            var inputFormat : String = validator.inputFormat;
            var dateSeparator : String;
            var inputFormatsArray : Array;
            
            var resourceManager : IResourceManager = ResourceManager.getInstance();
            
            var validInput : String = DateUtil.getAllowedDateInputChars(inputFormat);
                        
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
            
            if (value is String) {
                stringValue = String(value)
            } else {
                stringValue = (value as Date).toDateString();
            }
            
            dateSeparator = DateUtil.getDateSeparator(stringValue, inputFormat);   
            
            if (!dateSeparator) {
                var dateSeparatorInvalid : ValidationResult = new ValidationResult(
                    true, baseField, "format",
                    validator.formatError);
                
                results.push(dateSeparatorInvalid);
                return results;
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
            
            inputFormatsArray = DateUtil.getInputFormatArray(dateSeparator, inputFormat);
            
            var validDateStringResult : ValidationResult = 
                DateI18nValidator.validateFormatString(validator, dateSeparator, inputFormatsArray, baseField);
            
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
                //TODO : Create separate resource string for this type of error
                results.push(new ValidationResult(
                    true, yearProp, "wrongLength",
                    validator.wrongLengthError + " " + inputFormat));
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
            
            if (yearRequired && isNaN(yearNum)) {
                results.push(new ValidationResult(
                    true, yearProp, "wrongYear",
                    validator.wrongYearError));
                return results;
            } 
            
            return results;
        }
                
        /**
         *  @private
         */
        private static function validateFormatString(validator : DateI18nValidator,
                                                        separatorSign : String,
                                                        formatPartsArray : Array,
                                                        baseField : String) : ValidationResult {
            
            var formatPartsValidationObject : Object = {dayValid : false,
                                                        monthValid : false,
                                                        yearValid : false};
            var formatsLength : int = formatPartsArray.length; 
            
            var mask:String;            
            for (var i : int  = 0; i < formatsLength; i++) {
                mask = formatPartsArray[i];                
                switch (mask) {
                    case "M" :
                    case "MM" :
                    case "MMM" :                        
                    case "MMMM" :
                        formatPartsValidationObject.monthValid = true;
                        break;
                    case "YY" :
                    case "YYYY" :
                        formatPartsValidationObject.yearValid = true;
                        break;                    
                    case "D" :
                    case "DD" :                    
                        formatPartsValidationObject.dayValid = true;                        
                        break;                        
                }    
            }           
            if (formatPartsValidationObject.monthValid && 
                formatPartsValidationObject.dayValid &&
                formatPartsValidationObject.yearValid) {
                return null; // Passes format validation
            } else {
                return new ValidationResult(
                    true, baseField, "format",
                    validator.formatError);
            }
        }        
    }
}