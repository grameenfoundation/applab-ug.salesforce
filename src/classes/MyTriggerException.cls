/* 
 * Placeholder exception to throw in triggers.
 * Apex never allows us to throw Exception,
 * instead we have to throw a subclass of Exception. Class is empty as there is
 * nothing to do.
 */
public with sharing class MyTriggerException extends Exception {
 
}