package com.jabbypanda.events {
    
    import flash.events.Event;
    
    public class ItemEditEvent extends Event {        
        
        public static const DATA_CHANGE : String = "itemDataChange";
        
        public function ItemEditEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
        }
    }
}