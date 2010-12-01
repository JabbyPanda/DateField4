package com.jabbypanda.utils {
    import flash.events.Event;
    
    import mx.formatters.DateFormatter;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import mx.utils.StringUtil;
    
    [ResourceBundle("validators")]
    public class DateUtil {
                
        public static const REGEXP_SPECIAL_CHARS : String = "^$\.*+?()[]{}|";                
        
        public static var resourceManager : IResourceManager = ResourceManager.getInstance();
                
        
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
                        
            var allowedFormatChars : String = resourceManager.getString("validators", "dateValidatorAllowedFormatChars");            
            var dateSeparator : String;
            
            var i : int;
            
            var l : int = allowedFormatChars.length;
            for (i = 0; i < l; i++) {
                var allowedFormatChar : String = allowedFormatChars.charAt(i);
                if ((valueString.indexOf(allowedFormatChar) != -1) && 
                    (inputFormat.indexOf(allowedFormatChar) != -1)) {
                    dateSeparator = allowedFormatChar;
                    break;
                }
            }
                        
            if (!dateSeparator) {
                return null;
            }
                        
            var valuesArray : Array = valueString.split(dateSeparator);
            var inputFormatsArray : Array = inputFormat.split(dateSeparator);        
            
            if (valuesArray.length != inputFormatsArray.length) {
                return null;
            }
                        
            var formatsLength : int = inputFormatsArray.length; 
            
            var mask:String;            
            for (i = 0; i < formatsLength; i++) {
                mask = inputFormatsArray[i];                
                switch (mask) {
                    case "M" :
                    case "MM" :
                    case "MMM" :                        
                    case "MMMM" :
                        dateObject.month = valuesArray[i];
                        break;
                    case "YY" :
                        break;
                    case "YYYY" :
                        var yearValue : String = valuesArray[i] as String;
                        if (yearValue.length == mask.length) { 
                            dateObject.year = valuesArray[i];
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