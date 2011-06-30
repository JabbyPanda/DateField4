package com.jabbypanda.utils {
    import flash.events.Event;
    
    import mx.formatters.DateFormatter;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.utils.ArrayUtil;
    import mx.utils.StringUtil;
    
    [ResourceBundle("SharedResources")]
    [ResourceBundle("formatters")]
    [ResourceBundle("validators")]
    public class DateUtil {
                
        public static const REGEXP_SPECIAL_CHARS : String = "^$\.*+?()[]{}|";                
        
        public static const DECIMAL_DIGITS : String = "0123456789";
        
        protected static const BEGIN_CURRENT_CENTURY_YEAR : Number = 2000;
        
        public static var resourceManager : IResourceManager = ResourceManager.getInstance();
                                
        public static function getInputFormatArray(dateSeparator: String, inputFormat : String) : Array {
            var inputFormatsArray : Array = inputFormat.split(dateSeparator);
            return inputFormatsArray;
        }
        
        public static function getAllowedDateInputChars(inputFormat : String) : String {
            var dateSeparator : String;
            var inputFormatsArray : Array;
            var allowedFormatChars : String = resourceManager.getString("validators", "dateValidatorAllowedFormatChars");
            var validInput : String = DECIMAL_DIGITS + allowedFormatChars;     
            var stringValue : String;
                        
            dateSeparator = getDateSeparator(allowedFormatChars, inputFormat);   
            
            if (!dateSeparator) {                
                return validInput;
            }
            
            inputFormatsArray = getInputFormatArray(dateSeparator, inputFormat);
            
            if (ArrayUtil.getItemIndex("MMM", inputFormatsArray) > 0) {                
                validInput += resourceManager.getString("formatters", "monthNamesShort"); 
            }
            if (ArrayUtil.getItemIndex("MMMM", inputFormatsArray) > 0) {             
                validInput += resourceManager.getString("SharedResources", "monthNames"); 
            }
            
            return validInput;
        }
        
        public static function getDateSeparator(valueString : String, inputFormat : String) : String {
            var allowedFormatChars : String = resourceManager.getString("validators", "dateValidatorAllowedFormatChars");
            var dateSeparator : String;            
            var i : int;
            
            if (!allowedFormatChars) {
                return '';
            }
            
            var l : int = allowedFormatChars.length;
            for (i = 0; i < l; i++) {
                var allowedFormatChar : String = allowedFormatChars.charAt(i);
                if ((valueString.indexOf(allowedFormatChar) != -1) && 
                    (inputFormat.indexOf(allowedFormatChar) != -1)) {
                    dateSeparator = allowedFormatChar;
                    break;
                }
            }
                        
            return dateSeparator;            
        }
        
        public static function parseStringToDate(dateString:String, inputFormat : String) : Date {
            dateString = formatDateStringToEnglishFormat(dateString, inputFormat);
            
            if (!dateString) {                
                return null;
            }
            
            var resultDate : Date = new Date(Date.parse(dateString));            
            return resultDate;
        }
        
        public static function parseStringToObject(valueString : String, inputFormat : String) : Object {
            var dateObject : Object = {};    
                                                
            var dateSeparator : String = getDateSeparator(valueString, inputFormat);
            
            var valuesArray : Array = valueString.split(dateSeparator);
            var inputFormatsArray : Array = getInputFormatArray(dateSeparator, inputFormat);        
            
            if (valuesArray.length != inputFormatsArray.length) {
                return null;
            }
                        
            var formatsLength : int = inputFormatsArray.length; 
            
            var mask:String;            
            for (var i : int  = 0; i < formatsLength; i++) {
                mask = inputFormatsArray[i];                
                switch (mask) {
                    case "M" :
                    case "MM" :
                        dateObject.month = valuesArray[i];
                        break;
                    case "MMM" :                        
                        var monthNamesShort : String = resourceManager.getString("formatters", "monthNamesShort");
                        var monthNamesShortArray : Array = monthNamesShort.split(",");
                        var monthNamesShortCount : int = monthNamesShortArray.length;
                        
                        for (var j : int  = 0; j < monthNamesShortCount; j++) {                            
                            var monthShortName : String = monthNamesShortArray[j];                            
                            if (valuesArray[i] == monthShortName) {
                                dateObject.month = j + 1;
                                break;
                            }
                        } 
                    case "MMMM" :
                        var monthNamesLong : String = resourceManager.getString("SharedResources", "monthNames");
                        var monthNamesLongArray : Array = monthNamesLong.split(",");
                        var monthNamesLongCount : int = monthNamesLongArray.length; 
                        for (var k : int  = 0; k < monthNamesLongCount; k++) {
                            var monthLongName : String = monthNamesLongArray[k]; 
                            if (valuesArray[i] == monthLongName) {
                                dateObject.month = k + 1;
                                break;
                            }
                        }
                        break;
                    case "YY" :
                        var yearTwoDigitsValue : String = valuesArray[i] as String;
                        if (yearTwoDigitsValue.length == mask.length) {
                            dateObject.year = BEGIN_CURRENT_CENTURY_YEAR + Number(yearTwoDigitsValue);
                        } else {
                            dateObject.year = NaN;
                        }
                        break;
                    case "YYYY" :
                        var yearValue : String = valuesArray[i] as String;
                        if (yearTwoDigitsValue.length == mask.length) {
                            dateObject.year = valuesArray[i];
                        } else {
                            dateObject.year = NaN;
                        }
                        break;                    
                    case "D" :
                    case "DD" :
                        dateObject.day = valuesArray[i];                        
                        break;                        
                }    
            }
                        
            return dateObject;
        }
        
        public static function formatDateStringToEnglishFormat(valueString : String, inputFormat : String) : String {
            var dateObject : Object = parseStringToObject(valueString, inputFormat);
                        
            if (dateObject && dateObject.year && dateObject.month && dateObject.day) {           
                var enUSDateFormatter : DateFormatter = new DateFormatter();
                enUSDateFormatter.formatString = "MM/DD/YYYY";                
                var date : Date = new Date(dateObject.year, dateObject.month - 1, dateObject.day);
                var monthNum : int = dateObject.month - 1;
                var dayNum : int = dateObject.day;
                if (dayNum == date.getDate() && monthNum == date.getMonth()) {                    
                    return enUSDateFormatter.format(date);                    
                } else {
                    return null;
                }
            } else {
                return '';
            }            
        }
        
        public static function getDateFormatterNoYearFormatString() : String {
                        
            var dateAllowedSeparators : String = resourceManager.getString("validators", "dateValidatorAllowedFormatChars");             
            var currentDateFormat : String = resourceManager.getString("SharedResources", "dateFormat");
            var yearFormatCode : String = "Y";
            var monthFormatCode : String = "M";
            var newSeparatorChar : String = " ";
            var dateFormatterNoYearFormatString : String = "";            
            var dateAllowedSeparatorsLength : int = dateAllowedSeparators.length;
            
            for (var charIndex :int = 0; charIndex < dateAllowedSeparatorsLength; charIndex++) {
                var separatorChar : String = dateAllowedSeparators.charAt(charIndex);
                if (currentDateFormat.indexOf(separatorChar) != -1) {
                    var dateTokens : Array = currentDateFormat.split(separatorChar);
                    var dateTokensLength : int = dateTokens.length;
                    for (var dateTokenIndex :int = 0; dateTokenIndex < dateTokensLength; dateTokenIndex++) {
                        var dateToken : String = dateTokens[dateTokenIndex] as String;
                        if (dateToken.indexOf(monthFormatCode) != -1) {
                            //Display months as short text
                            dateToken = "MMM";
                        }
                        
                        if (dateToken.indexOf(yearFormatCode) == -1) {
                            if (dateTokenIndex > 0 && dateTokenIndex < dateTokensLength - 1) {
                                dateFormatterNoYearFormatString += newSeparatorChar;
                            }
                            dateFormatterNoYearFormatString += dateToken;                            
                        }
                    }
                }
            }   
            
            return dateFormatterNoYearFormatString; 
        }
        
    }
//--    
}